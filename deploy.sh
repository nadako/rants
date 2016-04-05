#!/bin/bash
set -e # exit with nonzero exit code if anything fails

if [ -z "$GH_TOKEN" ]; then
    echo "Skipping pushing to GitHub pages - missing $GH_TOKEN (probably in a PR build).";
    exit 0;
else
    echo "Pushing GitHub pages"
fi

# go to the out directory and create a *new* Git repo
cd output
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "nadako@gmail.com"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "https://${GH_TOKEN}@github.com/nadako/rants.git" master:gh-pages > /dev/null 2>&1
