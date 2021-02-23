# Automation Scripts

The android repo has a variety of basch scripts used to automate the error process and remove most human intervention from things like incrementing version numbers, creating builds, and publishing builds to different channels.

In general, there are 2 types of scripts:
- [**Developer scripts**](#developer-scripts) - to be run locally in the console
- [**CI scripts**](#ci-scripts) - to be used by CI to automate the release process

## Developer Scripts
Scripts to be run by developers in console, located in `/scripts/`

### increment_version_and_commit.sh
**Params**
	- DESIRED_VERSION_NAME - optional parameter of the desired versionName to change to. If none is specified, the trailing build digit is incremented by 1.

Most often, the developer or CI will use this script indirectly through other scripts. In general, it is used when we want to change the version number and version code of the app.

Steps:
1. Change the versionName to the desired version and versionCode to the current number of commits + 1 (to account for the commit at the end of this script) in `app/build.gradle`
1. Create a commit for the version change
1. Push to origin

### cut_build.sh
This may only be run from the `develop` branch or a release branch`.

A developer can use this to create a new alpha build from `develop` with changes that have not already been included in a nightly build.

This is also indirectly called via other scripts like the CI's [`nightly_build.sh`](#nightly_buildsh)

Steps:
1. If there is already a tag for the current versionName, abort
1. Otherwise, create a new tag for the versionName (eg `4.1.5-a.12`)
1. Push tag to origin, triggering alpha build steps on CI.
1. Increment version on the branch by calling [`increment_version_and_commit.sh`](#increment_version_and_commitsh)

### cut_preview.sh
**Params**
- PREVIEW_SUFFIX - optional string to append a flag for easy identification for the tester since preview builds will have the same version number as the alpha build off which the feature branch is based.

This is a similar process to [`cut_build.sh`](#cut_buildsh), but is used when a developer would like to create an ad-hoc test build outside of the normal release workflow (eg from a feature branch)

Instead of using tags to trigger the CI, it kicks off builds via a special `hockey-preview` branch.

Steps:
1. Delete local copy of `hockey-preview` branch if it exists
1. Checkout the local branch changes to the `hockey-preview` branch
1. Add the specified preview suffix to `app/build.gradle` if applicable and commit changes
1. Force push the `hockey-preview` branch to origin, kicking off CI's process to build an Alpha build
1. Checkout the original working branch
1. Delete the local `hockey-preview` branch

### create_release.sh
This branch can only be run from the `develop` branch and is used to create a new release branch when the code should be advanced to Beta.

It also resets the versioning of the `develop` branch, leaving the new release branch to track the current targeted release, while `develop` begins tracking the next targeted release.

Steps:
1. Pull newest changes to `develop`
1. Checkout changes to a new release branch named after the major and minor version numbers of the current versionName. _eg. versionName = 4.1.5-a.9 -> branch name = `release/4.1.5`, new versionName = 4.1.5-b.0_
1. Push new release branch to origin, triggering CI's process to build a Beta build
1. Move back to `develop` and call [`increment_version_and_commit.sh`](#increment_version_and_commitsh) with the next patch version as the `DESIRED_VERSION` param. _eg. `4.1.5-a.9` -> `4.1.6-a.0`_

### create_hotfix.sh
This branch can only be run from the `master` branch and is used to create a new release branch to fix a bug discovered post-release.

It also increments the currently tracking patch version in `develop` since this will conflict with the new release branch
Steps:
1. Pull newest changes to `master`
1. Checkout changes to a new release branch named after the the next patch version from the one in master. _eg. versionName = 4.1.5-b.9 -> branch name = `release/4.1.6`, new versionName = 4.1.6-b.0_
1. Call [`increment_version_and_commit.sh`](#increment_version_and_commitsh)
1. Push new release branch to origin, triggering CI's process to build a Beta build
1. Move back to `develop` and call [`increment_version_and_commit.sh`](#increment_version_and_commitsh) with the next patch version as the `DESIRED_VERSION` param. _eg. `4.1.6-a.3` -> `4.1.7-a.0`_

### update_apollo_schema.sh
This is a convenience script to update the app's graphql. It requires that the system has [apollo-cli](https://www.apollographql.com/docs/ios/downloading-schema.html) installed

## CI Scripts
These scripts are found in the `/scripts/ci` and are run as part of CI jobs in order to generate and publish builds without user intervention.

### add_gradle_play_publisher_key.sh
Takes the key stored in CI's environment variables and copies it into the `/assets/deploy/gradle_play_publisher.json` file.

This allows CI to publish to the Google Play store on our behalf via the TripleT gradle plugin.

### cut_build_with_git_user.sh
This is a wrapper for the user-facing [`cut_build.sh`](#cut_buildsh) which first sets the git user to allow CI to commit and push to our repo.

### generate_signing_properties.sh
This compiles all the necessary creds for signing an app into a  `signing.properties` file from the CI's environment variables

### nightly_build.sh
This script is run by the CI every 24 hours and is used to kickoff [`ci/cut_build_with_git_user.sh`](#cut_build_with_git_usersh) when there are one or more new commits in the `develop` branch since the most recent tag made from it.

### deploy_hockey.sh
Called in CI workflows after apps are built, this compiles release notes and publishes the builds to their respective channels on HockeyApp.

This handles publishing Alpha and Beta apps from the regular release workflow as well as ad-hoc Preview builds.

Steps:
1. Generate release notes
    - If this is a preview branch, just use the last commit message since we are on a diverged branch
    - If deploying Alpha or Beta builds cut from `develop` or release branches, respectively, compile release notes from all PR titles since the last version tag in the branch.
1. Upload apk, release notes, and all relevent files to HockeyApp via cURL call
    - If this is a beta build, we include the dsym mapping files for code de-obfuscation and publish to HockeyApp's Beta channel
    - Alpha and Preview builds do not have dsym mapping due to their `debug` buildTypes and are both published to HockeyApp's Alpha channel
