#!/bin/bash
set -e
export WORKING_DIR=${PWD}
chown -R $(whoami) ${WORKING_DIR}
export hr=$(printf '=%.0s' {1..80})

# Initial default value
TOKEN=${INPUT_TOKEN}
ACTOR=${GITHUB_ACTOR}
REPOSITORY=${INPUT_REPOSITORY}
OWNER=${GITHUB_REPOSITORY_OWNER}
BRANCH=${INPUT_BRANCH:=gh-pages}
PROVIDER=${INPUT_PROVIDER:=github}
BUNDLER_VER=${INPUT_BUNDLER_VER:=>=0}
JEKYLL_BASEURL=${INPUT_JEKYLL_BASEURL:=}
PRE_BUILD_COMMANDS=${INPUT_PRE_BUILD_COMMANDS:=}

# https://stackoverflow.com/a/42137273/4058484
export JEKYLL_SRC=${WORKING_DIR}
export JEKYLL_GITHUB_TOKEN=${TOKEN}
if [[ "${OWNER}" == "chetabahana" ]]; then
  export JEKYLL_SRC=${WORKING_DIR}/docs
fi
export JEKYLL_CFG=${JEKYLL_SRC}/_config.yml
sed -i -e "s/eq19/${OWNER}/g" ${JEKYLL_CFG}

if [[ -z "${TOKEN}" ]]; then
  echo -e "Please set the TOKEN environment variable."
  exit 1
fi

# Pre-handle Jekyll baseurl
if [[ -n "${JEKYLL_BASEURL-}" ]]; then
  JEKYLL_BASEURL="--baseurl ${JEKYLL_BASEURL}"
fi

# Initialize environment
export RUBYOPT=W0
export RAILS_VERSION=5.0.1
export BUNDLER_VER=${BUNDLER_VER}
export BUNDLE_GEMFILE=/maps/Gemfile
export PATH=${PATH}:/root/.local/bin
export BUNDLE_SILENCE_ROOT_WARNING=1
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1
export PAGES_REPO_NWO=$GITHUB_REPOSITORY
export REQUIREMENT=/maps/requirements.txt
export VENDOR_BUNDLE=${WORKING_DIR}/vendor/bundle
# export GEM_HOME=/github/home/.gem/ruby/${RUBY_VERSION}
# export PATH=$PATH:${GEM_HOME}/bin:$HOME/.local/bin
export SSL_CERT_FILE=$(realpath .github/hook-scripts/cacert.pem)

# identity
echo -e "\n$hr\nWHOAMI\n$hr"
whoami
pwd
id

# os version
echo -e "\n$hr\nOS VERSION\n$hr"
cat /etc/os-release
uname -r

# file system
echo -e "\n$hr\nFILE SYSTEM\n$hr"
df -h

# pckages
echo -e "$hr\nROOT DIR\n$hr"
cd / && pwd && ls -al

echo -e "$hr\nPRIOR INSTALLATION\n$hr"
chown -R root ${HOME}
source /maps/bin/activate && dpkg -l
apt-get install -qq --no-install-recommends apt-utils &>/dev/null
 
apt-get install -qq git &>/dev/null
git config --global credential.helper store &>/dev/null
echo "https://{ACTOR}:${TOKEN}@github.com" > ~/.git-credentials
git clone --recurse-submodules -j8 ${REPOSITORY} /maps/feed/default &>/dev/null

python -m pip install -U --force-reinstall pip setuptools six wheel &>/dev/null
pip install pytest-cov -r ${REQUIREMENT} --root-user-action=ignore &>/dev/null

apt-get install -qq npm &>/dev/null
npm install --prefix /maps &>/dev/null

apt-get install -qq ruby ruby-dev ruby-bundler build-essential &>/dev/null
gem install rails --version "$RAILS_VERSION" --quiet --silent &>/dev/null

# installed packages
echo -e "\n$hr\nUPON INSTALLATION\n$hr"
dpkg -l

# Setting default ruby version
echo -e "$hr\nTENSORFLOW VERSION\n$hr"
pip show tensorflow-gpu && pip -V

# https://stackoverflow.com/a/60945404/4058484
ruby -v && bundler version && python -V
node -v && npm -v

# Restore modification time (mtime) of git files
echo -e "$hr\nEPOCH TEST\n$hr"
/maps/Scripts/restore.sh
/maps/Scripts/prime_list.sh
/maps/Scripts/init_environment.sh

# Clean up bundler cache
CLEANUP_BUNDLER_CACHE_DONE=false
bundle config path $VENDOR_BUNDLE
bundle config cache_all true

cleanup_bundler_cache() {
  /maps/Scripts/cleanup_bundler.sh
  gem install bundler -v "${BUNDLER_VER}" &>/dev/null
  
  rm -rf ${VENDOR_BUNDLE} && mkdir -p ${VENDOR_BUNDLE}
  echo -e "\nGEM BUNDLE\n$hr" && bundle install
  CLEANUP_BUNDLER_CACHE_DONE=true
}

# If the vendor/bundle folder is cached in a differnt OS (e.g. Ubuntu),
# it would cause `jekyll build` failed, we should clean up the uncompatible
# cache firstly.
OS_NAME_FILE=${VENDOR_BUNDLE}/os-name
os_name=$(cat /etc/os-release | grep '^NAME=')
os_name=${os_name:6:-1}

if [[ "$os_name" != "$(cat $OS_NAME_FILE 2>/dev/null)" ]]; then
  cleanup_bundler_cache
  echo -e $os_name > $OS_NAME_FILE
fi

# Check and execute pre_build_commands commands
cd ${JEKYLL_SRC}

if [[ ${PRE_BUILD_COMMANDS} ]]; then
  eval "${PRE_BUILD_COMMANDS}"
fi

build_jekyll() {
  echo -e "\n$hr\nJEKYLL BUILD\n$hr"
  pwd
  JEKYLL_GITHUB_TOKEN=${TOKEN} bundle exec jekyll build --trace --profile \
    ${JEKYLL_BASEURL} -c ${JEKYLL_CFG} -d ${WORKING_DIR}/build

  # vendor/bundle
  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  echo -e "\n$hr\nVENDOR BUNDLE\n$hr"
  cd ${VENDOR_BUNDLE}
  chown -R root ${HOME}
  ln -s ${HOME}/.gem gem
  ln -s ${HOME}/.npm npm
  ln -s ${HOME}/.keras keras
  ln -s ${HOME}/.cache/pip pip

  echo ${VENDOR_BUNDLE}/ruby/2.7.0
  ls -al ${VENDOR_BUNDLE}/ruby/2.7.0
}

build_jekyll || {
  $CLEANUP_BUNDLER_CACHE_DONE && exit -1
  echo -e "\nRebuild all gems and try to build again\n"
  cleanup_bundler_cache
  build_jekyll
}

# Check if deploy on the same repository branch
cd ${WORKING_DIR}/build && rm -rf grammar
if [[ "${PROVIDER}" == "github" ]]; then
  source "/maps/Scripts/github_pages.sh"
else
  echo -e "${PROVIDER} is an unsupported provider."
  exit 1
fi

apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* &>/dev/null
exit $?