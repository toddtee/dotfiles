function inst
    set WORKSPACE $HOME/workspace/src/bitbucket.org/ffxblue
    set GOLDEN_HELMFILE_SIMPLE "$WORKSPACE/nxgp-work/helmfile-simple.yaml"
    set GOLDEN_HELMFILE_COMPLEX "$WORKSPACE/nxgp-work/helmfile-complex.yaml"
    set DEPLOY_CONFIG "$WORKSPACE/nxgp-work/deploy.yaml"
    set NAMESPACE $(git basename )-{{ trimPrefix '\"'nxgp-'\"' .Environment.Name }}-v1 | string join ''
    set NEW_SET_PIPELINE "generic/set-pipeline.yaml"
    set GIT_SUBJECT "👷 PE-15709 - [ci] Add instanced pipelines for NXGP targets [patch]"
    set GIT_MESSAGE "This change introduces the ability to deploy to NextGen clusters. To achieve this, instanced pipelines are created via the generic set-pipeline job. Therefore the existing set-pipeline job has been removed from the main pipeline config and is now referenced in `pipeline.list`
An instanced pipeline is created for each target environment which takes care of the authentication to target clusters as well as the helm deployment.
The `deploy.yaml` that is added declares the environment information which is parsed by tasks in the set-pipeline job to assist with the instanced pipeline creation."

    #Get Gitty
    git checkout master
    git pull
    git checkout -b add-instance-pipelines

    #Find the Helm Directory
    if test -e "./helm"
        set HELM_CONFIG_DIR "$PWD/helm"
    else if test -e "./infrastructure/helm"
        set HELM_CONFIG_DIR "$PWD/infrastructure/helm"
    else
        echo "Could not locate a helm directory."
        return 1
    end
    echo "HELM DIRECTORY LOCATED: $HELM_CONFIG_DIR"

    #Find the CI Directory
    if test -e "./ci"
        set CI_DIR "$PWD/ci"
    else if test -e "./infrastructure/ci"
        set CI_DIR "$PWD/infrastructure/ci"
    else
        echo "Could not locate a CI directory."
        return 1
    end
    echo "CI DIRECTORY LOCATED: $CI_DIR"
    #Guess the deploy method
    if test -e "$CI_DIR/helm_config.yaml"
        set DEPLOY_METHOD helm
    else
        set DEPLOY_METHOD helmfile
    end
    echo "Deploy method is: $DEPLOY_METHOD"

    #Find the existing helmfile
    if test -e "$PWD/infrastructure/helmfile.d"
        set HELMFILE_DIR "$PWD/infrastructure/helmfile.d"
    else if test -e "$PWD/helmfile.d"
        set HELMFILE_DIR "$PWD/helmfile.d"
    else
        mkdir "$PWD/infrastructure/helmfile.d"
        set HELMFILE_DIR "$PWD/infrastructure/helmfile.d"
    end

    #Copy golden helmfile
    if test $DEPLOY_METHOD = helm
        cp $GOLDEN_HELMFILE_SIMPLE $HELMFILE_DIR/helmfile-nxgp.yaml
        echo "Simple helmfile copied."
    else if test $DEPLOY_METHOD = helmfile
        cp $GOLDEN_HELMFILE_COMPLEX $HELMFILE_DIR/helmfile-nxgp.yaml
        echo "Complex helmfile copied."
    end

    #get the blueapp version
    if test $DEPLOY_METHOD = helm
        string match -rq '(?<major>\\d+).(?<minor>\\d+).(?<patch>\\d+)' -- $(cat $CI_DIR/helm_config.yaml)
        set BLUE_APP_VERSION "$major.$minor.$patch"
        set YQ_BLUE_APP_STRING ".releases[0].version = ""\"$BLUE_APP_VERSION\""
        set YQ_NAMESPACE_STRING ".releases[0].namespace = ""\"$NAMESPACE\""
        echo $YQ_NAMESPACE_STRING
        yq e -i $YQ_BLUE_APP_STRING $HELMFILE_DIR/helmfile-nxgp.yaml
        yq e -i $YQ_NAMESPACE_STRING $HELMFILE_DIR/helmfile-nxgp.yaml
    else if test $DEPLOY_METHOD = helmfile

        echo dunno
    end

    #Create helm value override files 
    echo "Creating Helm Override Files"
    for e in development test staging production
        if test -e $HELM_CONFIG_DIR/"values-$e.yaml"
            cp $HELM_CONFIG_DIR/"values-$e.yaml" $HELM_CONFIG_DIR/"values-nxgp-$e-override.yaml"
        else
            touch $HELM_CONFIG_DIR/"values-nxgp-$e-override.yaml"
        end
        echo Created $HELM_CONFIG_DIR/"values-nxgp-$e-override.yaml"
    end
    # for f in values-nxgp-development-override.yaml values-nxgp-production-override.yaml values-nxgp-staging-override.yaml values-nxgp-test-override.yaml
    #     touch $HELM_CONFIG_DIR/$f
    #     echo "Created $HELM_CONFIG_DIR/$f"
    # end

    #Bring over the deploy.yaml file
    echo "Adding deploy.yaml file."
    cp $DEPLOY_CONFIG $CI_DIR/deploy.yaml

    #Remove old set-pipeline.yaml
    if test -e "$CI_DIR/jobs/set-pipeline.yaml"
        echo "Removing local set-pipeline.yaml"
        rm "$CI_DIR/jobs/set-pipeline.yaml"
    else
        echo "No local set-pipeline.yaml found"
    end

    #Update pipeline.list; create the pipeline.list or update the existing.
    if not test -e "$CI_DIR/pipeline.list"
        echo "Creating new pipeline.list"
        touch $CI_DIR/pipeline.list
        set PIPELINE_LIST "$CI_DIR/pipeline.list"
        echo $NEW_SET_PIPELINE >>$PIPELINE_LIST
        echo "pipeline.yaml" >>$PIPELINE_LIST
    else
        set PIPELINE_LIST "$CI_DIR/pipeline.list"
        echo "Updating existing pipeline.list"
        cp $PIPELINE_LIST $CI_DIR/pipeline.list.old
        cat $CI_DIR/pipeline.list.old | grep -v "jobs/set-pipeline.yaml" >$PIPELINE_LIST
        echo $NEW_SET_PIPELINE >>$PIPELINE_LIST
        rm $CI_DIR/pipeline.list.old
    end

    #Git Add and Commit
    git add $CI_DIR $HELMFILE_DIR $HELM_CONFIG_DIR
    git commit -m $GIT_SUBJECT -m $GIT_MESSAGE
    git push --set-upstream "origin" $BRANCHNAME
end
