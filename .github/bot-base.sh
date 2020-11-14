#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ISSUE_URL=$(jq -r ".issue.url" "$GITHUB_EVENT_PATH")

if [[ "$ISSUE_URL" == "null" ]]; then
  echo "Could not determine issue URL"
  exit 1
fi

api_get() {
  curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1"
}

api_post() {
  curl -X POST -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1" -d "$2"
}

bot_comment() {
  api_post $ISSUE_URL/comments "{\"body\":\"$1\"}" | jq -r .url
}

bot_error() {
  echo "$1"
  bot_comment "Error: $1" > /dev/null
  exit 1
}

PR_URL=$(jq -r ".pull_request.url" "$GITHUB_EVENT_PATH")
PR_NUMBER=$(jq -r ".pull_request.number" "$GITHUB_EVENT_PATH")

if [[ "PR_URL" == "null" ]]; then
  error "I can only operate on PRs!"
fi

set -o xtrace
