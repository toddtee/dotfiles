function inst-fix
    echo "Attempting to fix helmfile.\n"
    helmfile-fix
    echo "Attempting to fix deploy.yaml.\n"
    ci-fix
end
