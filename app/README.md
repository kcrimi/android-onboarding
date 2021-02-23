# App Module

## Responsibilities
This is the main module used to build the android app and contains the following.

1. View-related code (view, layouts, assets, presenters, viewmodels, etc)
2. Local data storage (SharedPreferences, SQLite, Room, etc)
3. Use cases encapsulating business logic or caching
4. Implementations of app wide systems defined in [skillsharecore](../skillsharecore) (logging, exception handling)
5. Initialization of libraries  (modules and 3rd party SDKs)

## Build Types
There are 5 build types which each play a specific role in our release process.

- **Debug** - Unsigned build used in development
- **Alpha** - Signed version of Debug
- **Beta** - Features merged and tested, prepping for release. Adds code minification and obfuscation steps to catch bugs with regression testing.
- **Regression** - Identical to Beta but does not allow switching of environments. Built for 3rd party regression testers.
- **Release** - Released to the Google Play store on their beta track after a successful regression as Beta.

## Environments

### Client Environments
Along with the build types above fall into 3 "client environments" which can be installed side-by-side on a device:
1. Alpha (Debug, Alpha)
2. Beta (Beta, Regression)
3. Prod (Release)

With our 3rd party vendors (eg Sentry, Firebase, Blueshift, etc), we typically set each of these up as a separate project to keep data separated.

### Server Environments
Builds within the Alpha and Beta client environments can point to different server environments, controlled in Developer settings. [More info on confluence](https://skillsharenyc.atlassian.net/wiki/spaces/EN/pages/449904647/Environments)

## Package Structure

- [**com.skillshare.Skillshare**](src/main/java/com/skillshare/Skillshare) - Main package of our codebase, view readme internal structure details.
- [**cc.fuze.inapp**](src/main/java/cc/fuze/inapp) - Some library code which powers our in-app subscriptions
- [**com.skillshare.stitch**](src/main/java/com/skillshare/stitch) - A legacy system which would parse REST responses describing views into native code. Theoretically built for flexibility, ironically a disaster to change any of the views it powers. Deprecated except for usage in the lists in My Classes tab.

## Build Configuration
We have a single class called BuildConfigurationManager which allows various settings to change the functioning of the app. Many of these are backed by values defined in our `build.gradle` and defined at compile time.

### Feature Flags / Remote Configs
We use an in-house remote configuration system fed by the endpoint `https://api.skillshare.com/clientConfig` which returns a map of flag names to config values which can then be used to alter functionality in the app without involving a release. 

These values are fed through the BuildConfigurationManager to allow us to change some values at runtime (eg phased rollout of a specific feature or an A/B test).

For more information about our remote configuration strategy, see [our confluence doc](https://skillsharenyc.atlassian.net/wiki/spaces/MOB/pages/325222401/Remote+Configuration+and+Event+Tracking+on+the+Mobile+Apps)

### Developer Settings
Developer settings are available on Alpha and Beta app types through the normal Setting page which is accessible via 3 routes
1. Clicking on the gear in the My Classes/ Profile tab
1. Long pressing on "Explore your Creativity" on the welcome page

For remote config-backed settings, we usually offer the ability to force them to be **On** rather than overriding them completely.

## MVVM Architecture
We have moved to the practice of MVVM architecture with the viewModels exposing LiveData properties though you will likely find many examples of MVP throughout the app from ye olden days.

## Local Data Storage

### Shared Preferences
We've made efforts to try to consolidate these usages which have historically been spread out over multiple different Shared Preferences files. The main grouping we've been using can be found in the [AppSettings class](src/main/java/com/skillshare/Skillshare/core_library/data_source/appsettings) which exposes different data stores scoped by their lifecycle, be it for the lifetime of the install, the duration of the current signed-in session, or whenever a specific user is signed in.

### SQLite
Our current convention is to use Room for all SQLite interactions exposed via RxJava2. There are a handful of older SQLite implementations in the app that you may find.

### Downloaded Files
Along with SQLite which is used to store a queue and metadata of classes which the user downloads, we also use the Android system downloader to download the files themselves. The main entry point for this code is in the DownloadManager class.

## Push Notifications
The app currently has a few ways to receive push notifications.

_For related information deeplink routing architecture, you can reference [this architecture diagram](https://miro.com/app/board/o9J_ksT4XOE=/)_

### Local (Weekly Reminders)
This feature allows the users to set their own reminders for a specific time of day and day of week. Reminders will be built using data from their relevant saved, in-progress, or recommended classes

### Blueshift
Similar to Braze but with the benefit that marketing campaigns can span across push notifications and email communication. [Dashboard link](https://app.getblueshift.com/)

## Events and Logs
We have a variety of ways to get visibility into app usage

### Analytic Events
For monitoring user behavior, we send events to our own back end at `https://api.skillshare.com/events/track` which then will augment the properties and send the enent to various consumers, the primary feeder being [Mixpanel](https://mixpanel.com/). The entry point for this within the app is `SkillshareEventTracker`. These events are queued while offline and synced later.

### Time Tracking
We pay our teachers based on the number of seconds watched which we send to `https://api.skillshare.com/trackTime`. This data is queued while offline and synced later.

### Logs
For remote monitoring, we have a burgeoning logging system which sends custom logs and context to [Datadog](https://app.datadoghq.com/logs?cols=service%2Csource%2C%40http.status_code%2C%40http.referer%2C%40http.url_details.queryString.via&from_ts=1607449928383&index=&live=true&messageDisplay=inline&query=%40context.service%3Askillshare-android&stream_sort=desc&to_ts=1607450828383) which is mainly accessed through SSLogger. This data is queued while offline and synced later

## Errors and Crash Monitoring.
We currently have visibility in a variety of services
- [Firebase](https://console.firebase.google.com/) - Catches mostly everything
- [Sentry](https://sentry.io/organizations/skillshare/issues/?project=1368081) - Used Organization-wide, may lack some of the events in Firebase due to later adoption
- [Google Play](https://play.google.com/console) - Good for catching ANRs which are not captured in the other services


## Versioning
Versioning of the app is defined in the file `app/build.gradle` and is made up of the `versionCode` and `versionNumber` parameters.

Developers should not have to manually edit either of these in the release process as incrementing should be handled in the automated release process.

### Version Name
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

### Version Code
The version code is a monotonically increasing integer used internally and by Android to determine if one app build is newer than another.

We use the number of commits into the branch to determine the `versionCode`.

_**Caveat:** one potential corner case with this that we may want to address is when release branches are created, additional fixes may be merged into the release, causing `develop` to have fewer commits despite technically tracking a later release._
