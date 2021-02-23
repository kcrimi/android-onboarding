#!/usr/bin/env bash

# This script will push the local branch state to the `build-preview` branch, causing CircleCI
# to publish a build to the alpha app through our app distro. This is typically used to build one-off
# builds from feature branches that require testing before merging into `develop`
#
# Usage: ./scripts/cut_preview.sh {VERSION_SUFFIX_TAG}

PREVIEW_BRANCH='build-preview'
CURRENT_GIT_LOCATION=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_GIT_LOCATION" = "HEAD" ]; then
    # User was in a detached state so lets find the commit rather than the branch
    CURRENT_GIT_LOCATION=$(git rev-parse HEAD)
fi
echo "## Moving local changes to $PREVIEW_BRANCH ##"
git branch -D "$PREVIEW_BRANCH"
git checkout -b "$PREVIEW_BRANCH"

# Add suffix if applicable
SUFFIX="${1// /-}"
if [ ! -z $SUFFIX ]; then
    echo "## Adding suffix '$SUFFIX' ##"
    sed "s/buildMetadata = null/buildMetadata = \'$SUFFIX\'/" app/build.gradle > app/build.gradle.tmp
    mv app/build.gradle.tmp app/build.gradle

    echo "## Committing suffix change to $PREVIEW_BRANCH ##"
    git add app/build.gradle
    git commit -m "Tagging build with suffix '$SUFFIX'"
fi

echo "## Pushing $PREVIEW_BRANCH to trigger build ##"
git push -u -f origin $PREVIEW_BRANCH

echo "## Returning to original git loaction and deleting $PREVIEW_BRANCH ##"
git checkout $CURRENT_GIT_LOCATION
git branch -D $PREVIEW_BRANCH