# Setting Up The Repository

## Passwords
You will require access to the 1Password vault, `AndroidApp` which contains many of the passwords and files you will need on a daily basis.

## Repo
Get the latest code by cloning the [repo](https://github.com/Skillshare/skillshare-android)

                            git@github.com:Skillshare/skillshare-android.git

## Android Studio
Getting the android repository up and running is fairly straight forward. It's recommended to use [Android Studio](https://developer.android.com/studio) to work in the codebase
Choose the option to 'Import a project(Eclipse, Gradle, etc)' to load the repo into Android Studio.

### Install SDK
Install java 8 if not installed
```
brew cask install homebrew/cask-versions/adoptopenjdk8
```
Initialize a local android config
```
touch ~/.android/repositories.cfg
```
Install the android sdks
```
brew cask install android-sdk
```
Accept SDK licenses
```
cd ~/Library/Android/sdk/tools/bin && ./sdkmanager —licenses
```

### Git-Crypt
To keep our API keys, tokens, and other data safe, we encrypt sensitive files with git-crypt.

#### Installation
First, you'll need to install git-crypt.

The easiest way is installing through brew like this:
```
brew install git-crypt
```
If you don't want to use homebrew, you can find additional instructions [here](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md)

#### Getting the key
To decrypt the files in the android repo, you will need our `skillshare.crypt-key` file which is stored in the AndroidApp 1Password. You'll need to put this file in the root directory of your project.

#### Using Git-Crypt
To unlock a newly cloned repo with the key you just downloaded, you'll need to first run
```
git-crypt unlock ./skillshare.crypt-key
```
From this point on, all encryption/decryption will happen automatically. Any changes you make to currently encrypted files will be re-encrypted and any encrypted files changed by other devs will be decrypted without any further effort.

New sensitive strings should be added to the `skillshare.properties` file (detailed below) but if you find yourself adding a new sensitive file, you will need to add this to the `.gitattributes` file. This file uses similar syntax as `.gitignore` with the exception of directory `/*` wildcards with the following format:
```
{path/to/file} filter=git-crypt diff=git-crypt
```

For additional information on git-crypt usage, go [here.](https://github.com/AGWA/git-crypt#using-git-crypt)

## GraphQL
With the migration of the backend to GraphQL endpoints, we are using the Apollo Android client contained in the [`skillsharedata`](skillsharedata) module of the project. While you won't need these tools for simply running the repo, you will need to install the following to work on GraphQL code

### Apollo CLI
Download [here](https://www.apollographql.com/docs/ios/downloading-schema.html).

This will enabled you to refresh the schema from our server. A convenience script for doing this is located at [`./scripts/update_apollo_schema.sh`](scripts#update_apollo_schemash)

### GraphQL IntelliJ Plugin
Not necessary but HIGHLY recommended.

This plugin provides syntax highlighting for `.graphql` files, code completion taken from the structure in the current `.schema` file, as well as the ability to run queries against the server from the IDE based on the configuration in [the scripts directory](scripts)

It can be installed within Android Studio's plugin system. More information can be found [here](https://github.com/jimkyndemeyer/js-graphql-intellij-plugin/tree/android-studio)

## Setting Up the Facebook SDK:
* In order to allow the app to communicate with Facebook, you will need to update our Facebook app and add your keystore key hash to the list of trusted key hashes.
* Open up our Facebook app: https://developers.facebook.com/apps/169419436428655/settings/

        *You will need to ask one of the engineers to give you access to the app*

* Get the key hash for your **Debug** environment by typing this in to your terminal (the password is **android**)

`keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64`

* Paste the result into the Android - Key Hashes section of the Facebook app settings page.

## Extra Credit:
* If you'd like to lead a zero warning build lifestyle, you'll want to ensure that you have the NDK (side-by-side) versions downloaded. They can be found by going to Tools > SDK Manager > SDK Tools and ensuring that the NDK (side-by-side) box is checked. You can also Show Package Details for a list of specific side by side NDKs and pick the ones required to fix your build error. *Choosing not to do this will in no way impact your ability to build the project.*
