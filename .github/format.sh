#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

if [[ "$BASE_REPO" != "$HEAD_REPO" ]]; then
  error "I can't operate on forks!"
fi

git config user.email "bot@upsj.de"
git config user.name "Bot"
git remote add tmp-origin "$HEAD_URL"
git fetch tmp-origin
git checkout -t tmp-origin/$HEAD_BRANCH
for f in *.cpp; do
  clang-format -i $f
done
LIST_FILES=$(git diff --name-only)
git commit *.cpp -m "Format files

Co-authored-by: $USER_COMBINED"
git push
if [[ "$LIST_FILES" != "yes" ]]; then
  bot_comment "Formatted the following files:\n"'```'"$LIST_FILES\n"'```'
fi
