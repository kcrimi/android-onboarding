
# Release Process
The release process for android has been automated to avoid developer bottlenecks, avoid human error, and keep QA testers supplied with necessary builds.

## Important Git Objects
1. `master` branch - code merged into `master` will kick off publishing to the beta track of the Google Play Console
1. `develop` branch - main trunk for developers to branch off of
1. `release/#.#.#` branches - branches tracking code which has passed feature testing and has advanced to the Beta stage, named for the targeted major, minor, and patch release number. Ex. release/4.1.1
1. `build-preview` branch - branch used kicks off ad-hoc preview builds

## Release Workflow
Below you can find the key steps to interact with the automated process. **Steps needing developer intervention have been bolded**

### Alpha Phase

#### Early Development
1. **Feature work is merged into develop via a PR**
1. A git tag is generated from develop and pushed to origin. This is done in one of 2 ways:
  1. Automated creation via CircleCI's nightly workflow - Runs nightly, running the [cut_build.sh](scripts#cut_buildsh) script if there have been changes on the develop branch since the most recent version tag.
  1. Manually running the [cut_build.sh](scripts#cut_buildsh) script from the console.
1. The new Tag triggers the build_debug job on CircleCI
1. Assembles the app in the debug buildType
1. Publishes the new build to Firebase App Distribution in the Skillshare Alpha channel

#### Preview Builds (as needed)
If testing is required on feature branches before merging into develop (usually in long running feature branches with large changesets), preview builds can be used. These are ad hoc builds published to the Alpha channel on Fabric Beta with an optional version suffix tag for easy identification by the tester.

1. **The developer commits all desired changes to their feature branch**
1. **The developer runs [cut_preview.sh](scripts#cut_previewsh) from the console, optionally providing a suffix tag.**
  -. Example: `> ./cut_preview.sh refactor`
1. Commits are made to add the suffix to app/build.gradle if necessary
1. Changes are pushed to the build-preview branch
1. CircleCI assembles app with debug buildType
1. App is published to Firebase App Distribution in the Skillshare Alpha channel

### Beta Phase

#### Promoting Alpha to Beta
Once feature testing is complete and all code changes for the targeted release have been merged into develop, it's time to promote the current Alpha builds to Beta to being regression testing.

1. **A developer creates a release branch using the automation script, [create_release.sh](scripts#create_releasesh)** which makes the following changes:
  1. Creates the release branch from develop with the major, minor, and patch version numbers. Ex. `release/4.2.1`
  1. Resets the develop branch to the next targeted release. Ex. `4.2.1-b.4` -> `4.2.2-a.0`
  1. Commits the version reset and pushes to origin
1. The pushed release branch runs build_beta job on CircleCI
1. Cuts a new alpha build if needed (ie similar to the nightly build or manual [cut_build.sh](scripts#cut_buildsh) script mentioned above)
1. Assembles the app in the beta and regression buildTypes 
1. Publishes the new builds to Firebase App Distribution in the Skillshare Beta channel

#### Making fixes to Beta Releases
If bugs are found in regression or new changes are needed prior to release.

1. **Fixes are merged into the release branch via PR** doing the following:
1. The pushed release branch runs build_beta job on CircleCI
1. Increments the version build number and cut a new alpha build similar to the nightly build or manual [cut_build.sh](scripts#cut_buildsh) script mentioned above
1. Assembles the app in the beta and regression buildTypes 
1. Publishes the new builds to Firebase App Distribution in the Skillshare Beta channel

### Release Phase

#### Promoting Beta to Release Candidate
Once the Beta build has been determined to be free from regressions and stable, it is deemed ready for release

1. **A developer merges the release branch into master** 
1. The changes run the build_release job on CircleCI
1. Assembles the app in the release buildType
1. Publishes the build to Google Play in the Beta Track

#### Promoting Release Candidate to Production
Once the release candidate is published to Google Play's Beta Track, it is up to a developer to manually roll it out to the general public via the Google Play Console.

1. **Release notes are entered on Google Play**
1. **The release is initially set to a small percentage (eg 5%)**
1. **In the subsequent days, crashes are monitored and rollout is doubled until reaching 100%**

#### Creating Hotfix for Post-Release Issues
When an issue is released to users and we need to put out a fix that cannot wait for the next scheduled release

1. **The developer halts the release rollout of the problem version**
1. **The developer runs [create_hotfix.sh](scripts#create_hotfixsh)** which does the following
  1. Creates a new release branch, incrementing the patch number from master (`4.2.1-b.5` -> `4.2.2-b.0`)
  1. Increments the patch number tracked by develop to not conflict with the new release
  1. Pushes changes to origin
1. **The developer pushes the fix to the new release branch**
1. Developer releases this new hotfix as usual.

# Versioning
Versioning of the app is defined in the file `app/build.gradle` and is made up of the `versionCode` and `versionNumber` parameters.

Developers should not have to manually edit either of these in the release process as incrementing should be handled in the automated release process.

## Version Name
The user-facing version is defined by the string parameter, `versionName`, which follows [semver convention](https://semver.org/). 

The base code is held in the parameter `ext.skillshareVersion` to allow the preview suffix to be appended when making preview builds.
```
[Major].[Minor].[Patch]-[Build Phase].[Build Number]{+[Preview Suffix]}
                                          
2.1.3
2.1.4-b.2
3.1.4-a.5+new-button-styles
```
- **Major** - Incremented on major releases and large features
- **Minor** - Incremented on releases of smaller notable features
- **Patch** - Incremented on normal releases or bug fixes
- **Build Phase** - `a` or `b` Denoting if the build is in alpha or beta phase of the release process
- **Build Number** - Starting at 0 when the build pahse is changes and incremented on every new tagged version as part of the release process
- **Preview Suffix _(Optional)_** - A string tag used when creating preview builds for advance testing on feature branches

## Version Code
The version code is a monotonically increasing integer used internally and by Android to determine if one app build is newer than another.

We use the number of commits into the branch to determine the `versionCode`. 

_**Caveat:** one potential corener case with this that we may want to address is when release branches are created, additional fixes may be merged into the release, causing `develop` to have fewer commits despite technically tracking a later release._
