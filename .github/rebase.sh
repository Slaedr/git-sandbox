#!/bin/bash

set -e

git remote add base "$BASE_URL"
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"

git remote add fork "$HEAD_URL"

set -o xtrace

# make sure branches are up-to-date
git fetch base $BASE_BRANCH
git fetch fork $HEAD_BRANCH

# do the rebase
git checkout -b $HEAD_BRANCH fork/$HEAD_BRANCH
git rebase base/$BASE_BRANCH

# push back
git push --force-with-lease fork $HEAD_BRANCH
