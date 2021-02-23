# Core Module
This module contains common code shared by multiple modules and interfaces for functionality which should be available to all modules but implemented on the app level.

In general, we should try to resist putting code in this library and only do so if the usecase and module dependencies make sense

In an ideal world, we should try to get this library to be a plain Java library rather than an Android library (_though written in kotlin :smile:_)

## Utils
Only util classes which should be used in all modules should be here. Generally, these are very basic things like String utils.

## Exception Handling
The SSExceptionHandler takes in throwable exceptions and delegates them to any consumers registered by the app.

In the case that no exception handlers are registered, the throwables are ignored. Because of this, it is recommended to register them as soon as possible, such as within a ContentProvider. 

## Logging
The SSLogger class takes in a defined log structure as [defined here](https://skillsharenyc.atlassian.net/wiki/spaces/MOB/pages/727777718/Unified+Logging+From+the+Native+Apps). It then feeds this log to consumers which are defined by the app. 

In the case that no log consumers have been set, these logs are ignored.
