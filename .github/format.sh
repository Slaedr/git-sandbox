#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

if [[ "$BASE_REPO" != "$HEAD_REPO" ]]; then
  error "I can't operate on forks!"
fi

set -xe

git config user.email "bot@upsj.de"
git config user.name "Bot"
git checkout -t origin/$HEAD_BRANCH
for f in *.cpp; do
  clang-format -i $f
done
LIST_FILES=$(git diff --name-only)
git commit *.cpp -m "Format files

Co-authored-by: $USER_COMBINED" || true
git push
if [[ "$LIST_FILES" != "" ]]; then
  bot_comment "Formatted the following files:\n"'```'"\n$LIST_FILES\n"'```'
fi
