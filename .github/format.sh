#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

if [[ "$BASE_REPO" != "$HEAD_REPO" ]]; then
  error "I can't operate on forks!"
fi

git checkout "$HEAD_BRANCH"
LIST_FILES=""
for f in *.cpp; do
  clang-format $f > tmp
  if diff $f tmp; then
    LIST_FILES="$LIST_FILES\n$f"
    cat tmp > $f
  fi
done
git commit *.cpp -m "Format files\n\nCo-authored-by: USER_COMBINED"
git push
if [[ "$LIST_FILES" != "yes" ]]; then
  bot_comment "Formatted the following files:\n```$LIST_FILES\n```"
fi
