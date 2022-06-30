function yolo --description 'Commit and force a push.'
    git commit --amend --no-edit
    git push --force
end
