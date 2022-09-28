function ci-fix
    #Find the CI Directory
    if test -e "./ci"
        set CI_DIR "$PWD/ci"
    else if test -e "./infrastructure/ci"
        set CI_DIR "$PWD/infrastructure/ci"
    else
        echo "Could not locate a CI directory."
        return 1
    end

    if test -e "$CI_DIR/deploy.yaml"
        echo "Found deploy.yaml, attempting to overwrite."
        echo "$(sed -n '2,9!p' $CI_DIR/deploy.yaml)" >$CI_DIR/deploy.yaml
        echo "Overwrite of completed."
    else
        echo "Could not find deploy.yaml"
    end
end
