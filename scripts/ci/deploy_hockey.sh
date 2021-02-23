#!/usr/bin/env bash

# This script is run from CircleCI to publish newly cut builds to HockeyApp

echo "********************************"
echo "*    Getting Release Notes     *"
echo "********************************"

if [ "$CIRCLE_BRANCH" == "$PREVIEW_BRANCH" ]; then
    # Release notes for preview builds
    RELEASE_NOTES=$(git log --oneline HEAD~1 -n 1)
else
    # Release notes for beta builds made from release tags
    NOTES=()
    CURRENT_TAG=$(git describe --abbrev=0 --tags)
    TAGS=$(git tag | sort -r -t$'.' -n -k1,1 -k2,2 -k3,3 -k4,4)


    for tag in $TAGS; do
        if [ "$tag" = "$CURRENT_TAG" ]; then
            PREVIOUS_TAG=$tag
        elif [ "$PREVIOUS_TAG" = "$CURRENT_TAG" ]; then
            PREVIOUS_TAG=$tag
            break
        fi
    done

    # Generate release notes from the tag difference
    GITHUB_TOKEN=$GITHUB_RELEASE_NOTES_TOKEN
    USER_AGENT="Release Notes Script"
    REPO="skillshare-android"
    PR_ID_LIST=$(git log --oneline $PREVIOUS_TAG..$CURRENT_TAG | grep "Merge pull request" | grep -o '\#[0-9]*' | cut -d '#' -f 2)
    for PR_ID in $PR_ID_LIST; do
        NOTES+=("$(curl --silent -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: $USER_AGENT" -H "Accept:application/vnd.github.v3+json" https://api.github.com/repos/Skillshare/$REPO/pulls/$PR_ID | python -c "import json,sys;obj=json.load(sys.stdin);print obj['title'];";)")
    done
    RELEASE_NOTES=$(for NOTE in "${NOTES[@]}"; do echo "$NOTE<br/>";  done | sort)
fi

echo $RELEASE_NOTES

echo "*****************************"
echo "*    Uploading to Hockey    *"
echo "*****************************"

ALPHA_BUILD='alpha'
if [[ $CIRCLE_BRANCH == 'release/'* ]]
then
    BUILD_TYPE='beta'
    RELEASE_TYPE='0'
else
    # Currently all alpha builds (tags and preview builds)
    BUILD_TYPE=$ALPHA_BUILD
    RELEASE_TYPE='2'
fi


OUTPUT_DIR="app/build/outputs"
APK_PATH="$OUTPUT_DIR/apk/$BUILD_TYPE/app-$BUILD_TYPE.apk"
FORM_DATA=("status=2"
    "notify=0"
    "release_type=$RELEASE_TYPE"
    "notes=\"$RELEASE_NOTES\""
    "notes_type=1"
    "ipa=@$APK_PATH")

if [ "$BUILD_TYPE" != "$ALPHA_BUILD" ]; then
    # Used to de-obfuscate code that has been run through pro-guard
    # so we get accurate line numbers for crash reports
    MAPPING_PATH="$OUTPUT_DIR/mapping/$BUILD_TYPE/mapping.txt"
    FORM_DATA+=("dsym=@$MAPPING_PATH")
fi

curl -v "${FORM_DATA[@]/#/-F}" https://rink.hockeyapp.net/api/2/apps/upload \
  -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"
