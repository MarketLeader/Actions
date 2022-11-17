#!/bin/sh
set -e

echo -e "$hr\nDEPLOYMENT\n$hr"
echo -e "Deploying to ${GITHUB_REPOSITORY} on branch ${BRANCH}"
echo -e "Deploying to https://github.com/${GITHUB_REPOSITORY}.git\n"

deploy_remote() {
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/${REPOSITORY}.git" && \
  git init && \
  git config user.name "${ACTOR}" && \
  git config user.email "${ACTOR}@users.noreply.github.com" && \
  git add . && \
  git commit -m "jekyll build from Action ${GITHUB_SHA}" && \
  git push --force $REMOTE_REPO master:$BRANCH && \
  rm -rf .git && \
  cd ..
}

# Tell GitHub Pages not to run Jekyll
cd ${WORKING_DIR}/build && touch .nojekyll
export REPOSITORY=${GITHUB_REPOSITORY}
deploy_remote

cd ${VENDOR_BUNDLE} && touch .nojekyll
export REPOSITORY=eq19/default
deploy_remote

exit $?
