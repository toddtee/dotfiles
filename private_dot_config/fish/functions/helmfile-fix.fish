function helmfile-fix
    set WORKSPACE $HOME/workspace/src/bitbucket.org/ffxblue
    set GOLDEN_HELMFILE_SIMPLE "$WORKSPACE/nxgp-work/helmfile-simple.yaml"
    set GOLDEN_HELMFILE_SIMPLE_COMMON_OVERRIDE "$WORKSPACE/nxgp-work/helmfile-simple-common-override.yaml"
    set NAMESPACE $(git basename )-{{ trimPrefix '\"'nxgp-'\"' .Environment.Name }}-v1 | string join ''

    #whitespace is important in this string
    # set APPENDAGE \
    #     "    {{- if hasPrefix \"nxgp\" .Environment.Name }}
    #   - ../helm/values-{{ .Environment.Name }}-override.yaml
    # {{- end }}"

    #Get Gitty
    git checkout master
    git pull
    git checkout add-instance-pipelines

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

    #Find the existing helmfile
    if test -e "$PWD/infrastructure/helmfile.d"
        set HELMFILE_DIR "$PWD/infrastructure/helmfile.d"
    else if test -e "$PWD/helmfile.d"
        set HELMFILE_DIR "$PWD/helmfile.d"
    else
        set HELMFILE_DIR "$PWD/infrastructure"
    end

    #Restore legacy helmfile
    if test -e "$HELMFILE_DIR/app.yaml"
        echo "Removing app.yaml"
        rm "$HELMFILE_DIR/app.yaml"
    end
    echo "Restoring helmfile.yaml from master"
    # git checkout master -- $HELMFILE_DIR/helmfile.yaml; and yolo
    set HELMFILE_ORIGINAL $HELMFILE_DIR/helmfile.yaml
    git checkout master -- $HELMFILE_DIR/helmfile.yaml
    if test $status != 0
        set HELMFILE_ORIGINAL $HELMFILE_DIR/app.yaml
        git checkout master -- $HELMFILE_DIR/app.yaml
        if test $status != 0
            echo "Could not find original helmfile"
            return 1
        end
    end
    #Ensure existing helmfile plays nice with helmfile-nxgp.yaml
    echo "Adding some templating to play nice with nxgp."
    echo "$(sed -e 's/\- \<\<\: \*{{ \.Environment.Name }}/- {{ if not \(hasPrefix \"nxgp\-\" \.Environment.Name\) }}\n    \<\<\: \*{{ \.Environment\.Name }}\n    {{ end }}/' $HELMFILE_ORIGINAL)" >$HELMFILE_ORIGINAL

    #Copy nextgen helmfile.yaml
    if test -e "$HELM_CONFIG_DIR/values-nxgp-common-override.yaml"
        cp $GOLDEN_HELMFILE_SIMPLE_COMMON_OVERRIDE $HELMFILE_DIR/helmfile-nxgp.yaml
    else
        cp $GOLDEN_HELMFILE_SIMPLE $HELMFILE_DIR/helmfile-nxgp.yaml
    end
    string match -rq '(?<major>\\d+).(?<minor>\\d+).(?<patch>\\d+)' -- $(cat $CI_DIR/helm_config.yaml)
    set BLUE_APP_VERSION "$major.$minor.$patch"
    set YQ_BLUE_APP_STRING ".releases[0].version = ""\"$BLUE_APP_VERSION\""
    set YQ_NAMESPACE_STRING ".releases[0].namespace = ""\"$NAMESPACE\""
    echo $YQ_NAMESPACE_STRING
    yq e -i $YQ_BLUE_APP_STRING $HELMFILE_DIR/helmfile-nxgp.yaml
    yq e -i $YQ_NAMESPACE_STRING $HELMFILE_DIR/helmfile-nxgp.yaml

end
