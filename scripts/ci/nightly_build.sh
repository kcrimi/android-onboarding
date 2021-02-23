#!/usr/bin/env bash

# This script is run by CircleCI in order to check the `develop` branch for recent commits in the
# past 24 hours and triggers the build to increment and make a new build

set -euo pipefail
LAST_TAG=$(git describe --tags --abbrev=0)
NEW_COMMITS=$(git rev-list --count $LAST_TAG..HEAD)
echo "$NEW_COMMITS changes found since last tag"
# If commits other than the last version increment exist, cut a new build
if [ "$NEW_COMMITS" -gt 1 ]; then
    bash ./scripts/ci/cut_build_with_git_user.sh
else
    echo "Not cutting a new build.  Most recent change was:"
    git --no-pager log -n 1
fi
