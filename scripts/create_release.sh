#!/usr/bin/env bash

# Create a new release branch from develop and increment the develop branch to the next release version
# Note - must run from the root of the repo (./scripts/cut_build.sh), or it
# will fail to find build.gradle. Also, must be run from `develop` branch
#
# Usage: ./scripts/create_release.sh

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "develop" ]
then
    echo 'ERROR: Release branches can only be cut from the `develop` branch'
    exit 1
fi
git pull

# Create a new release branch
CURRENT_VERSION=$(bash ./scripts/parse_version.sh -v)
RELEASE_VERSION_NAME=$(bash ./scripts/parse_version.sh -u stage)
git checkout -b "release/$CURRENT_VERSION"
bash ./scripts/increment_version_and_commit.sh $RELEASE_VERSION_NAME --ci
git push -u origin "release/$CURRENT_VERSION"

# Upgrade `develop` to track the next release
git checkout $CURRENT_BRANCH
NEW_VERSION=$(bash ./scripts/parse_version.sh -u patch)
bash ./scripts/increment_version_and_commit.sh $NEW_VERSION