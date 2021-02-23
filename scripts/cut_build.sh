#!/usr/bin/env bash

# Auto-increment the versionCode and versionName and push tag for a new build.
# Note - must run from the root of the repo (./scripts/cut_build.sh), or it
# will fail to find build.gradle. Also, must be run from `develop` branch
#
# Usage: ./scripts/cut_build.sh

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ $CURRENT_BRANCH != "develop" ]] && [[ $CURRENT_BRANCH != 'release/'* ]]
then
    echo 'ERROR: Builds can only be cut from the `develop` branch or a release branch'
    exit 1
fi

TAG_VERSION=$(bash ./scripts/parse_version.sh)

# Check if tag already exists for this version and abort to avoid failed tags and version commits
if git rev-parse $TAG_VERSION >/dev/null 2>&1
then
    echo "Tag already created for $TAG_VERSION, if trying to manually cut a build, your local branch may be behind"
    exit 0
fi

# Create release tag
echo "Creating $TAG_VERSION tag..."
git tag -a "$TAG_VERSION" -m "$TAG_VERSION"
git push origin $TAG_VERSION

# Increment build and tag version number to match
bash ./scripts/increment_version_and_commit.sh

