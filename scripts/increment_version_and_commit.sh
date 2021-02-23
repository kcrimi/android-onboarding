#!/usr/bin/env bash

## Increments the version and version code in the build.gradle file and then pushes a commit to the
# current branch. If a desired version is not passed in, the script will default to just incrementing
# the final digit of the version number
#
# Usage: ./increment_version_and_commit.sh 5.3.0-b.3 --ci

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_VERSION_NAME=$(bash ./scripts/parse_version.sh)
CURRENT_VERSION=$(bash ./scripts/parse_version.sh -v)
CURRENT_STAGE=$(bash ./scripts/parse_version.sh -s)
CURRENT_BUILD_NUMBER=$(bash ./scripts/parse_version.sh -b)

NEW_VERSION_NAME=${1:-$(bash ./scripts/parse_version.sh -u build)}
NEW_VERSION=$(bash ./scripts/parse_version.sh -i $NEW_VERSION_NAME -v)
NEW_STAGE=$(bash ./scripts/parse_version.sh -i $NEW_VERSION_NAME -s)
NEW_BUILD_NUMBER=$(bash ./scripts/parse_version.sh -i $NEW_VERSION_NAME -b)

CURRENT_VERSION_CODE=$(grep 'versionCode [0-9]\+' app/build.gradle | tr -s ' ' | cut -d ' ' -f 3)
COMMIT_COUNT=$(git rev-list --count $CURRENT_BRANCH)
NEW_VERSION_CODE=$((COMMIT_COUNT + 1))

echo "Incrementing Version from $CURRENT_VERSION_NAME to: $NEW_VERSION_NAME"
REPLACE_PATTERN="s/versionCode $CURRENT_VERSION_CODE/versionCode $NEW_VERSION_CODE/g;
    s/buildNumber = '$CURRENT_BUILD_NUMBER'/buildNumber = \'$NEW_BUILD_NUMBER\'/g
    s/buildStage = '$CURRENT_STAGE'/buildStage = \'$NEW_STAGE\'/g
    s/skillshareVersion = '$CURRENT_VERSION'/skillshareVersion = \'$NEW_VERSION\'/g"
sed "$REPLACE_PATTERN" app/build.gradle > app/build.gradle.tmp
mv app/build.gradle.tmp app/build.gradle
git add app/build.gradle
COMMIT_OPTION=" [skip ci]";
if [ "$2" = "--ci" ]; then
  COMMIT_OPTION="";
fi
git commit -m "Bump version to $NEW_VERSION_NAME$COMMIT_OPTION" #[skip ci] prevents triggering this script again off this commit
git push