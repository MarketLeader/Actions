#!/bin/sh
set -e

echo -e "$hr\nDEPLOYMENT\n$hr"
echo -e "Deploying to ${GITHUB_REPOSITORY} on branch ${BRANCH}"
echo -e "Deploying to https://github.com/${GITHUB_REPOSITORY}.git\n"

deploy_remote() {
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/${REPOSITORY}.git"
  git remote add origin $REMOTE_REPO && git push origin --delete $BRANCH
  git add . && git commit -m "jekyll build from Action ${GITHUB_SHA}"
  rm -rf .git
}

# Tell GitHub Pages not to run Jekyll
if [[ "${GITHUB_REPOSITORY_OWNER}" == "eq19" ]]; then
  cd ${VENDOR_BUNDLE}/keras && touch .nojekyll && mv -f /maps/.gitattributes .
  export REPOSITORY=eq19/default && apt-get install git-lfs &>/dev/null
  git init && git lfs install && deploy_remote
fi

cd ${WORKING_DIR}/build && touch .nojekyll
export REPOSITORY=${GITHUB_REPOSITORY}
git init && deploy_remote

exit $?
