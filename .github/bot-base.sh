#!/bin/bash

set -xe

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ISSUE_URL=$(jq -er ".issue.url" "$GITHUB_EVENT_PATH")
USER_LOGIN=$(jq -er ".comment.user.login" "$GITHUB_EVENT_PATH")
USER_URL=$(jq -er ".comment.user.url" "$GITHUB_EVENT_PATH")

cat "$GITHUB_EVENT_PATH" | jq .

api_get() {
  curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1"
}

api_post() {
  curl -X POST -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1" -d "$2"
}

bot_comment() {
  api_post $ISSUE_URL/comments "{\"body\":\"$1\"}" > /dev/null
}

bot_error() {
  echo "$1"
  bot_comment "Error: $1"
  exit 1
}

PR_URL=$(jq -er ".issue.pull_request.url" "$GITHUB_EVENT_PATH")

# collect info on the PR we are checking
PR_JSON=$(api_get $PR_URL)

BASE_REPO=$(echo "$PR_JSON" | jq -er .base.repo.full_name)
BASE_BRANCH=$(echo "$PR_JSON" | jq -er .base.ref)
BASE_URL="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/$BASE_REPO"
HEAD_REPO=$(echo "$PR_JSON" | jq -er .head.repo.full_name)
HEAD_BRANCH=$(echo "$PR_JSON" | jq -er .head.ref)
BASE_URL="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/$HEAD_REPO"

# collect info on the user that invoked the bot
USER_JSON=$(api_get $USER_URL)

USER_NAME=$(echo "$USER_JSON" | jq -r ".name")
if [[ "$USER_NAME" == "null" ]]; then
	USER_NAME=$USER_LOGIN
fi
USER_EMAIL=$(echo "$USER_JSON" | jq -r ".email")
if [[ "$USER_EMAIL" == "null" ]]; then
	USER_EMAIL="$USER_LOGIN@users.noreply.github.com"
fi
USER_COMBINED="$USER_NAME <$USER_EMAIL>"
