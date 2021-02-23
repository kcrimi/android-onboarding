#!/usr/bin/env bash

# To be used when a release has been published to the store but a severe bug requires a hotfix
# which cannot wait until the next scheduled release.
#
# Create a new release branch from master, incrementing the patch number. If the new version number
# is already being used in `develop`, we should increment the patch number there as well.
# ex. Creating a hotfix from `master with 1.2.3 will create `release/1.2.4` with 1.2.4-b.0. If
# `develop` is currently tracking 1.2.4-a.2, this will be incremented to 1.2.5-a.0.
#
# Note - must run from the root of the repo (./scripts/cut_build.sh), or it
# will fail to find build.gradle. Also, must be run from `master` branch
#
# Usage: ./scripts/create_hotfix.sh

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
if [ "$CURRENT_BRANCH" != "master" ]
then
    echo 'ERROR: Hotfix release branches can only be cut from the `master` branch'
    exit 1
fi
git pull;

# Create a new release branch
CURRENT_VERSION=$(bash ./scripts/parse_version.sh -v);
HOTFIX_VERSION_NAME=$(bash ./scripts/parse_version.sh -u patch); # next patch
HOTFIX_VERSION_NAME=$(bash ./scripts/parse_version.sh -i $HOTFIX_VERSION_NAME -u stage); # beta
HOTFIX_VERSION=$(bash ./scripts/parse_version.sh -i $HOTFIX_VERSION_NAME -v);

git checkout -b "release/$HOTFIX_VERSION";
bash ./scripts/increment_version_and_commit.sh $HOTFIX_VERSION_NAME --ci;
git push -u origin "release/$HOTFIX_VERSION";

# Upgrade `develop` to track the next release if needed
git checkout develop;
git pull;
CURRENT_DEVELOP_VERSION=$(bash ./scripts/parse_version.sh -v);
if [ "$HOTFIX_VERSION" = "$CURRENT_DEVELOP_VERSION" ]; then
  echo "Updating develop to track patch version after hotfix";
  NEW_DEVELOP_VERSION=$(bash ./scripts/parse_version.sh -u patch);
  bash ./scripts/increment_version_and_commit.sh $NEW_DEVELOP_VERSION;
fi
git checkout $CURRENT_BRANCH;