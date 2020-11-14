#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

echo -n "Collecting information on pull request"
PR_URL=$(jq -er ".pull_request.url" "$GITHUB_EVENT_PATH")
echo -n .
PR_JSON=$(api_get $PR_URL)
echo -n .
ISSUE_URL=$(echo "$PR_JSON" | jq -er ".issue_url")
echo -n .
HEAD_REPO=$(echo "$PR_JSON" | jq -er .head.repo.full_name)
echo -n .
HEAD_BRANCH=$(echo "$PR_JSON" | jq -er .head.ref)
echo .
HEAD_URL="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/$HEAD_REPO"

bot_comment() {
  (set +x; api_post $ISSUE_URL/comments "{\"body\":\"$1\"}" > /dev/null)
}

bot_error() {
  (set +x; echo "$1"; bot_comment "Error: $1"; exit 1)
}

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
