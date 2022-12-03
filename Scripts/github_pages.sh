#!/bin/sh
set -e

echo -e "$hr\nDEPLOYMENT\n$hr"
echo -e "Deploying to ${GITHUB_REPOSITORY} on branch ${BRANCH}"
echo -e "Deploying to https://github.com/${GITHUB_REPOSITORY}.git\n"

deploy_remote() {
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/${REPOSITORY}.git" && \
  git config user.email "${ACTOR}@users.noreply.github.com" && \
  git config user.name "${ACTOR}" && \
  git add . && \
  git commit -m "jekyll build from Action ${GITHUB_SHA}" && \
  git push --force --quiet $REMOTE_REPO master:$BRANCH && \
  cd ..
}

# Tell GitHub Pages not to run Jekyll
if [[ "${GITHUB_REPOSITORY_OWNER}" == "eq19" ]]; then
  cd ${VENDOR_BUNDLE}/keras && touch .nojekyll
  apt-get install git-lfs &>/dev/null
  export REPOSITORY=eq19/default
  git init && git lfs install
  mv -f /maps/.gitattributes .
  deploy_remote || {
    git fetch && \
    git push
}

fi

cd ${WORKING_DIR}/build && touch .nojekyll
export REPOSITORY=${GITHUB_REPOSITORY}
git init && deploy_remote

exit $?
