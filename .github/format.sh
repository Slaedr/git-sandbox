#!/bin/bash

set -e

USER_TOKEN=${USER_LOGIN//-/_}_TOKEN
UNTRIMMED_COMMITTER_TOKEN=${!USER_TOKEN:-$GITHUB_TOKEN}
COMMITTER_TOKEN="$(echo -e "${UNTRIMMED_COMMITTER_TOKEN}" | tr -d '[:space:]')"

git remote set-url origin https://x-access-token:$COMMITTER_TOKEN@github.com/$GITHUB_REPOSITORY.git
git config --global user.email "bot@upsj.de"
git config --global user.name "bot"

set -o xtrace

for f in *.cpp; do clang-format-8 -i $f; done

git commit *.cpp -m 'Format code'

# push back
git push
