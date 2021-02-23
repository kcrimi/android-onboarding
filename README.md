# Skillshare Android App

## Setting up the project
Follow the [step by step instructions](setting-up-repo.md)

## App Architecture
The app is organized into modules which can be seen in [diagram form on Miro](https://miro.com/app/board/o9J_kxy2Tik=/). The modularization has been a low-priority project with the goal of making the libraries reusable to other clients in the future and enforcing scope of responsibilities with hard lines between libraries. The 

3 modules are currently:

### App
The main module from which the application is built. Includes view-related code, presenters, use cases, local data storage, and any code related to the funcitoning of the app. This module depends on the others. Ideally, this would be the only module with Android dependencies. Read more in this [module's readme](app)

### Skillsharedata
This contains all code related to API calls in the App, both REST and GraphQL. Read more in this [module's readme](skillsharedata)

### Skillsharecore
This is a general-purpose module housing things like util classes and things which should be available in all modules (eg Logging and ExceptionHandling). Usually only the interfaces are in this module while the implementations exist on a highter level and are injected into this library. Read more in this [module's readme](skillsharecore)

## Workflow
This repo follows [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching strategy which uses a variety of special git objects and branches to trigger various parts of our CI automation.

### Important Git Objects
1. `master` branch - corresponds with the build in the store. Code merged into `master` will kick off publishing to the beta track of the Google Play Console
1. `develop` branch - main trunk for developers to branch off of
1. `release/#.#.#` branches - branches tracking code which has passed feature testing and has advanced to the Beta stage, named for the targeted major, minor, and patch release number. Eg. `release/4.1.1`
1. `build-preview` branch - branch used kicks off ad-hoc preview builds

### Release Lifecycle
Read more about each of them and how they fit into the development lifecycle in our [release process documentation](release-process.md)

### Creating PRs
All code must go through code review and be approved by at least one other member in the `android-devs` codeowners github group.
1. Create A PR for your work
1. Title the PR with your jira ticket `[SK-######] - .....`
1. Add any relevent links in description (eg figma designs)
1. Apply related labels and milestone of targeted release, if known
1. Leave any comments if needed throughout the code
1. Get approval :+1:
1. **SQUASH AND MERGE** to develop!

_Note, if you are merging a release branch into master, DO NOT squash. This helps us retain the commit history and ensures the merge commit triggers CI_

## Code In Flux
There are some conventions in various stages of adoption in the app. Some decisions to be aware of despite counterexamples in the app:
- Kotlin should be used over Java when possible
- RxJava2 should be used over RxJava1
- GraphQL should be used over REST for new API calls
- MVVM should be used over MVP
- SQL tables should be managed by Room

## Encrypted Files

### Git Crypt
All sensitive information should be encrypted with Git Crypt which you can [read about here](https://github.com/AGWA/git-crypt).

After installing and unlocking the repo as directed in the [setup doc](setting-up-repo.md), new sensitive strings should be added to the `skillshare.properties` file (detailed below) but if you find yourself adding a new sensitive file, you will need to add this to the `.gitattributes` file. This file uses similar syntax as `.gitignore` with the exception of directory `/*` wildcards with the following format:
```
{path/to/file} filter=git-crypt diff=git-crypt
```

### Development properties
We try to keep all of our sensitive information (API keys, tokens, and other data) in a centralized location so it's easy to encrypt. Sensitive strings should be stored in the `skillshare.properties` file.

To add a new value, you should add the entry in `skillshare.properties`, then add a blank value in the buildProps array in the `build_properties.gradle` script. After doing this, your constant will be available accessible in `build.gradle` on the next build.

### Signing Builds:
The configuration for creating signed builds is stored in the encrypted `signing.properties` file.

The `signing.gradle` script takes these values, loading the keystore file and handles all the signing for you :)
