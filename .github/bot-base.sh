#!/bin/bash

set -xe

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ISSUE_URL=$(jq -er ".issue.url" "$GITHUB_EVENT_PATH")
USER_LOGIN=$(jq -er ".comment.user.login" "$GITHUB_EVENT_PATH")
USER_URL=$(jq -er ".comment.user.url" "$GITHUB_EVENT_PATH")

jq < $GITHUB_EVENT_PATH

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

PR_URL=$(jq -er ".pull_request.url" "$GITHUB_EVENT_PATH")
PR_NUMBER=$(jq -er ".pull_request.number" "$GITHUB_EVENT_PATH")

# collect info on the PR we are checking
PR_JSON=$(api_get $PR_URL)

BASE_REPO=$(echo "$PR_JSON" | jq -er .base.repo.full_name)
BASE_BRANCH=$(echo "$PR_JSON" | jq -er .base.ref)
HEAD_REPO=$(echo "$PR_JSON" | jq -er .head.repo.full_name)
HEAD_BRANCH=$(echo "$PR_JSON" | jq -er .head.ref)

# collect info on the user that invoked the bot
USER_JSON=$(api_get $USER_URL)

USER_NAME=$(echo "$USER_JSON" | jq -er ".name")
USER_EMAIL=$(echo "$USER_JSON" | jq -er ".email")
USER_COMBINED="$USER_NAME <$USER_EMAIL>"
