#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-pr-comment-base.sh

echo -n "Collecting information on pull request"
PR_JSON=$(api_get $PR_URL)
echo -n .
HEAD_REPO=$(echo "$PR_JSON" | jq -er .head.repo.full_name)
echo -n .
HEAD_BRANCH=$(echo "$PR_JSON" | jq -er .head.ref)
echo .
HEAD_URL="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/$HEAD_REPO"

set -x

git remote add fork "${HEAD_URL}"
git fetch fork "$HEAD_BRANCH"
git checkout -t "fork/$HEAD_BRANCH"
for f in *.cpp; do
  clang-format -i $f
done
LIST_FILES=$(git diff --name-only)

if [[ "$LIST_FILES" != "" ]]; then
  bot_error "The following files need to be formatted:\n"'```'"\n$LIST_FILES\n"'```'
fi
