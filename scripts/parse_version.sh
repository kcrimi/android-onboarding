#!/usr/bin/env bash
## Utility function that can build the current version name from the build.gradle file as well as
# decompose a full version name into its components
#
# Usage for current version: ./scripts/parse_version.sh  > 5.3.0-a.1
#
# Usage for string version ./scripts/parse_version.sh -i 5.3.0-a.1 -v > 5.3.0
#
##  Options ##
#  Outputs
#  -v = the base version of the versionName (5.3.0-a.1 > 5.3.0)
#  -s = the stage of the biuld (5.3.0-a.1 > a)
#  -b = the trailing build number (5.3.0-a.1 > 1)
#
#  Upgrades
#  -u -- Upgrade a particular part of the version name
#       - Ex. ./scripts/parse_version.sh -i 5.3.0-a.1 -u minor > 5.4.0-a.0
#       - Ex. ./scripts/parse_version.sh -i 5.3.0-a.4 -u stage > 5.3.0-b.0

## Determine desire output of call
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--input-version) INPUT_VERSION_STRING=$2; shift ;;
    -v|--base-version) OUTPUT="base_version";;
    -b|--build-number) OUTPUT="build_number" ;;
    -s|--stage)  OUTPUT="build_stage" ;;
    -u|--upgrade) UPGRADE=$2; shift ;;
    * ) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift;
done

if [ ! -z $INPUT_VERSION_STRING ]; then
  # If we passed in a version name
  if echo $INPUT_VERSION_STRING | grep -q '^[0-9]\+.[0-9]\+.[0-9]\+-[ab].[0-9]\+$'; then
    # If the version name matches the format we expect
    VERSION=$(echo $INPUT_VERSION_STRING | cut -d "-" -f1);
    STAGE=$(echo $INPUT_VERSION_STRING | cut -d "-" -f2 | cut -d "." -f1);
    BUILD_NUMBER=$(echo $INPUT_VERSION_STRING | cut -d "-" -f2 | cut -d "." -f2);
  else
    echo "Malformed input version (ex 5.12.10-a.12)"; exit 1;
  fi
else
  # No input version name, read it from build.gradle
  VERSION=$(grep "skillshareVersion = '[0-9]\+.[0-9]\+.[0-9]\+'" app/build.gradle | cut -d "'" -f2)
  STAGE=$(grep "buildStage = '[ab]'" app/build.gradle | cut -d "'" -f2)
  BUILD_NUMBER=$(grep "buildNumber = '[0-9]\+'" app/build.gradle | cut -d "'" -f2)
fi

MAJOR=$( echo $VERSION | cut -d "." -f1)
MINOR=$( echo $VERSION | cut -d "." -f2)
PATCH=$( echo $VERSION | cut -d "." -f3)

## Upgrage the current version name if specified
if [ ! -z $UPGRADE ]; then
  if echo $UPGRADE | grep -q -E 'major|minor|patch|stage|build'; then
    case $UPGRADE in
      build)
        BUILD_NUMBER=$((BUILD_NUMBER+1))
        ;;
      stage)
        BUILD_NUMBER=0;
        case $STAGE in
          a) STAGE='b' ;;
          *) echo "Cannot upgrade past stage 'b'"; exit 1 ;;
        esac
        ;;
      patch)
        BUILD_NUMBER=0;
        STAGE='a';
        PATCH=$((PATCH+1));
        ;;
      minor)
        BUILD_NUMBER=0;
        STAGE='a';
        PATCH=0;
        MINOR=$((MINOR+1));
        ;;
      major)
        BUILD_NUMBER=0;
        STAGE='a';
        PATCH=0;
        MINOR=0;
        MAJOR=$((MAJOR+1));
        ;;
    esac
  else
    echo 'Unrecognized upgrade type please use major, minor, patch, stage, or build';
  fi
fi

VERSION_NAME=$MAJOR.$MINOR.$PATCH-$STAGE.$BUILD_NUMBER

case $OUTPUT in
  base_version) echo $VERSION;;
  build_number) echo $BUILD_NUMBER ;;
  build_stage) echo $STAGE ;;
  * ) echo $VERSION_NAME ;;
esac
exit 0;