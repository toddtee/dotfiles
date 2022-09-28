function clone --description 'Clone a bitbucket repo.' --argument repo
    git clone git@bitbucket.org:ffxblue/$repo.git
    cd $repo
end
