function nxgp-setup --argument config_file
    set OVERRIDE 'nxgp_values_override: nxgp-pipeline'
    git checkout -b nxgp-pipeline
    echo $OVERRIDE >>$config_file
    git add $config_file
    git commit -m "PE-0: Deployment for NextGen Clusters"
    git push
end
