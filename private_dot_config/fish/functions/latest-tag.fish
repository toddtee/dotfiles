function latest-tag --description 'Gets the latest git tag for a repo.'
    git tag -l | sort -V | tail -1
end
