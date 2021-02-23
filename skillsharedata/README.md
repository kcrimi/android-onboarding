# Data Module

This module contains all API-related code for communicating with the Skillshare backend.

## Initialization
When used by an application, this module needs to be initialized as early as possible by calling
``` Java
ApiConfig.initializeWith(
     this,
     userAgent, 
     null,
     new AppSettingsApiConfigurationDataSource());
```
| Param | Type | Description |
|---|---|---|
| context | Context | The app's context |
| userAgent | String | The user agaent to be sent in requests |
| httpClientBuilderConfiguration | SkillshareHttpClient.Configuration? | Optional custom implementation that allows the app to modify the HTTP client (eg add interceptor) | 
| apiConfigurationDataSource | ApiConfigurationDataSource | Backing datasource that stores settings for this module |

## Endpoint Environments
There is a large array of environments which the api module can point to which can be seen in the APIConfig class corresponding to [different server environments](https://skillsharenyc.atlassian.net/wiki/spaces/EN/pages/449904647/Environments).

## REST
The REST endpoints for skillshare are located at `https://api.skillshare.com/`

API services use [Retrofit](https://square.github.io/retrofit/) to expose the endpoint calls as RxJava obserable objects.

Gson is used to parse the responses into the data models in this module.

## GraphQL
The endpoint for the Skillshare GraphQL API is located at `https://api.skillshare.com/api/graphql`

### GQL files
The files defining the queries, mutations, and fragments can be found in `graphql`. 

These files are used by Apollo to generate classes which allow the app to make the api calls as well as the data classes from the responses.

### Apollo Implementation
The Apollo code related to making those calls is encapsulated in classes and functions found in `java/graphql`.

Here you can find:
- Classes emitting the RxJava responses, generally scoped to the use case in the app
- Custom Scalar implmentations (eg URI, DateTime)
- Error Handline
- Apollo Client setup

## Stitch _DEPRECATED_
These are a set of deprecated endpoints that were used to serve clients json payloads describing views to be rendered rather than raw data. 

This is moved to its own package in order to make removal easier once usages are fully removed from the app.

## OkHttp
All network calls use OkHttp as an Http Client. in `java/okhttp` you can find the base builder for all our clients.

### Headers

#### Authentication
Our current authentication system relies on a cookie being set by the server. The key of the cookie is `skillshare_user_` but can change depending on the environment (eg `staging_skillshare_user`, `sandbox_skillshare_user`)

#### Device session ID
Also passed up in the `COOKIE`, this is a client-generated, sticky ID corresponding to the installation of the app. It should only change when uninstalling or clearing all app data.

This value is used by the backend to generate analytics IDs, as well as to bin the app into a treatment group for remote configuration/feature flags.


