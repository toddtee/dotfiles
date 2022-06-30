function ink-dp --description 'Removes pipeline from ink concourse instance.' --argument pipeline team
    echo Removing pipeline: $pipeline
    fly -t ink dp -p $pipeline --team $team
end
