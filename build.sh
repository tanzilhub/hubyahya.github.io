#!/bin/bash

SOURCE_BRANCH="website-master"
TARGET_BRANCH="master"
GH_REF="github.com/hubyahya/hubyahya.github.io"
DIST_FOLDER="_site"

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
  echo "this is a PR, exiting"
  exit 0
fi

# enable error reporting to the console
set -e

REPO=`git config remote.origin.url`

# DEPLOY_REPO="https://${DEBEZIUM}@github.com/hubyahya/hubyahya.github.io.git"

# clean
rm -rf ../hubyahya.github.io.${TARGET_BRANCH}

# make new folder for generated files
mkdir ../hubyahya.github.io.${TARGET_BRANCH}

# clone into target folder
git clone $REPO ../hubyahya.github.io.${TARGET_BRANCH}

# go to target folder
cd ../hubyahya.github.io.${TARGET_BRANCH}

# go to target branch
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH

# go back to original folder
cd ../hubyahya.github.io

# build site, stored in dist folder
bundle exec jekyll build --trace

# copy dist folder to target folder
cp -R ${DIST_FOLDER}/* ../hubyahya.github.io.${TARGET_BRANCH}

# go to target folder
cd ../hubyahya.github.io.${TARGET_BRANCH}

# git configuration
git config user.email "nasiba.ansari@gmail.com"
git config user.name "uidoyen"

# add files
git add -A .

# If there are no changes to the compiled _site (e.g. this is a README update) then just bail.
if [ -z `git diff --cached --exit-code` ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# commit files
git commit -am "Build from ${SOURCE_BRANCH} branch | Deployed by TravisCI (Build #$TRAVIS_BUILD_NUMBER)"

# force push to github
git push -f "https://${DEBEZIUM}@${GH_REF}" ${TARGET_BRANCH} > /dev/null 2>&1


# function main {
# 	clean
# 	build_site
# 	# get_current_site
# 	deploy
# }

# function clean { 
# 	echo "cleaning _site folder"
# 	if [ -d "_site" ]; then rm -Rf _site; fi 
# }

# function get_current_site { 
# 	echo "getting latest site"
# 	git clone --depth 1 $DEPLOY_REPO _site 
# }

# function build_site { 
# 	echo "building site"
# 	bundle exec jekyll build --trace
# }

# function deploy {
# 	echo "deploying changes"

# 	if [ -z "$TRAVIS_PULL_REQUEST" ]; then
# 	    echo "except don't publish site for pull requests"
# 	    exit 0
# 	fi  

# 	if [ "$TRAVIS_BRANCH" != "website-migration" ]; then
# 	    echo "except we should only publish the website-migration branch. stopping here"
# 	    exit 0
# 	fi

# 	cd _site
# 	git config --global user.name "hubyahya"
#     git config --global user.email shamshad.alam2@gmail.com
# 	git add -A
# 	git status
# 	git commit -m "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
# 	git push $DEPLOY_REPO HEAD:master --force
# }

# main