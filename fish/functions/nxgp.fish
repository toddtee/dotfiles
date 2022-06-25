function nxgp --argument team env --description "Setup an application repo for nextgen clusters."
    set FFXBLUE "$HOME/workspace/src/bitbucket.org/ffxblue"
    set REPO (path basename $PWD)
    set OLD_PATH "$PWD/ci/config.yaml"
    set NEW_PATH "$PWD/infrastructure/ci/config.yaml"
    set HELM_CONFIG "$FFXBLUE/infrastructure-ci-pipelines/templates/golang-service/jobs/instanced-release-deploy.yaml"
    set HELM_ENV --instance-var="namespace=$REPO-$env-v1"
    set HELMFILE_CONFIG "$FFXBLUE/infrastructure-ci-pipelines/templates/golang-service/jobs/instanced-release-deploy-helmfile.yaml"
    set HELMFILE_ENV --instance-var="helmfile-env=$env"
    set CLUSTER dev-01a

    if test $env = production
        set CLUSTER prod-01a
    end

    if test -e $OLD_PATH
        set CI_CONFIG_PATH $OLD_PATH
    else if test -e $NEW_PATH
        set CI_CONFIG_PATH $NEW_PATH
    else
        echo CI Config Not Found!
        return 1
    end

    nxgp-setup $CI_CONFIG_PATH

    set -l helmfiles $PWD/helmfile*
    set -l helmfiles $helmfiles $PWD/infrastructure/helmfile*
    if test (count $helmfiles) -gt 0
        echo "Helmfiles found! Setting pipeline as helmfile deploy."
        set DEPLOY_CONFIG $HELMFILE_CONFIG
        set DEPLOY_ENV $HELMFILE_ENV
        set UNPAUSE_VAR "helmfile-env:$env"
    else
        echo "No helmfiles found! Setting pipeline as helm deploy."
        set DEPLOY_CONFIG $HELM_CONFIG
        set DEPLOY_ENV $HELM_ENV
        set UNPAUSE_VAR "namespace:$REPO-$env-v1"
    end

    fly -t ink \
        set-pipeline \
        --team=$team \
        -p $REPO \
        -c ( concourse-pipeline-merge -config $CI_CONFIG_PATH $DEPLOY_CONFIG | psub ) \
        -l $FFXBLUE/concourse-util/ci_configs/common.yaml \
        -l $CI_CONFIG_PATH \
        --instance-var="environment=$CLUSTER" \
        --instance-var="eks-clusterid=$CLUSTER" \
        $DEPLOY_ENV

    fly -t ink \
        unpause-pipeline \
        --team=$team \
        -p "$REPO/environment:$CLUSTER,eks-clusterid:$CLUSTER,$UNPAUSE_VAR"
end
