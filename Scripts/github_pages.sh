#!/bin/sh
set -e

echo -e "$hr\nDEPLOYMENT\n$hr"
echo -e "Deploying to ${GITHUB_REPOSITORY} on branch ${BRANCH}"
echo -e "Deploying to https://github.com/${GITHUB_REPOSITORY}.git\n"

deploy_remote() {
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/${REPOSITORY}.git"
  git add . && git commit -m "jekyll build from Action ${GITHUB_SHA}"
  git push --force --quiet $REMOTE_REPO master:$BRANCH
}

# Tell GitHub Pages not to run Jekyll
if [[ "${GITHUB_REPOSITORY_OWNER}" == "eq19" ]]; then
  cd ${VENDOR_BUNDLE}/keras && touch .nojekyll
  apt-get install git-lfs &>/dev/null
  export REPOSITORY=eq19/default
  git init && git lfs install
  mv -f /maps/.gitattributes .
  deploy_remote || {
    git remote add origin $REMOTE_REPO && git fetch
    git push --force --quiet -u origin master:$BRANCH
  }
  rm -rf .git
fi

cd ${WORKING_DIR}/build && touch .nojekyll
export REPOSITORY=${GITHUB_REPOSITORY}
git init && deploy_remote
rm -rf .git

exit $?
