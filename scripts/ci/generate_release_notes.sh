#!/usr/bin/env bash

# This script is run from CircleCI to publish newly cut builds to HockeyApp

echo "********************************"
echo "*    Getting Release Notes     *"
echo "********************************"

if [[ ${CIRCLE_BRANCH} == ${PREVIEW_BRANCH} ]]; then
    # Release notes for preview builds
    RELEASE_NOTES=$(git log --oneline HEAD~1 -n 1)
else
    # Release notes for beta builds made from release tags
    NOTES=()
    CURRENT_TAG=$(git describe --abbrev=0 --tags)
    TAGS=$(git tag | sort -r -t$'.' -n -k1,1 -k2,2 -k3,3 -k4,4)


    if [[ ${CURRENT_TAG} == "release/"* ]]; then
        # If this is a beta build, compare against previous release
        V1=$(cut -d'.' -f1 <<<${CURRENT_TAG})
        V2=$(cut -d'.' -f2 <<<${CURRENT_TAG})
        V2=$(($V2-1))
        PREVIOUS_TAG_PREFIX="$V1.$V2."

        # Find the most recent tag of the previous release version
        for TAG in ${TAGS}; do
            if [[ "$TAG" == "$PREVIOUS_TAG_PREFIX"* ]]; then
                PREVIOUS_TAG=${TAG}
                break
            fi
        done
    else
        # If this is an alpha build, compare against previous alpha
        for TAG in ${TAGS}; do
            if [[ "$TAG" == "$CURRENT_TAG" ]]; then
                PREVIOUS_TAG=${TAG}
            elif [ "$PREVIOUS_TAG" = "$CURRENT_TAG" ]; then
                PREVIOUS_TAG=${TAG}
                break
            fi
        done
    fi

    # Generate release notes from the tag difference
    GITHUB_TOKEN=${GITHUB_RELEASE_NOTES_TOKEN}
    USER_AGENT="Release Notes Script"
    REPO="skillshare-android"
    PR_ID_LIST=$(git log --oneline ${PREVIOUS_TAG}..${CURRENT_TAG} | grep "Merge pull request" | grep -o '\#[0-9]*' | cut -d '#' -f 2)
    for PR_ID in $PR_ID_LIST; do
        NOTES+=("$(curl --silent -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: $USER_AGENT" -H "Accept:application/vnd.github.v3+json" https://api.github.com/repos/Skillshare/${REPO}/pulls/${PR_ID} | python -c "import json,sys;obj=json.load(sys.stdin);print obj['title'];";)")
    done
    RELEASE_NOTES=$(for NOTE in "${NOTES[@]}"; do echo "$NOTE\n";  done | sort)
fi

echo "$RELEASE_NOTES"
printf "$RELEASE_NOTES" > app/build/outputs/release_notes.txt
