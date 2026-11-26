# Java Starter

Setup, credentials, `cvdesk` and updating work the same in every language: see the
[main README](../README.md). This page covers what's specific to Java.

## Needs
JDK 17+, from [adoptium.net](https://adoptium.net/). No Maven install needed: setup
uses the included `mvnw` wrapper.

## Examples
In [examples/](examples/): [StartGuide.java](examples/StartGuide.java) (credentials:
the `setUserName` / `setPassword` values).

## Writing scripts
- Each script is one `.java` file with a `main` method, run straight from source.
  It can't use classes from your other files, so keep each script self-contained.
- Scripts get the libraries in [pom.xml](pom.xml), which setup copies into `lib/`.
  Add a library there and `cvdesk` downloads it on the next run. VS Code's Java
  support finds `lib/` by itself.
- Logging settings: [resources/simplelogger.properties](resources/simplelogger.properties).

## Troubleshooting
- Login rejected -> check the credentials in `my-scripts/StartGuide.java`.
- `cvdesk: command not found` -> open a new terminal window, or run setup again.
- Your start guide from an older version (in `src/main/java/...`) is moved into
  `my-scripts/` by the update, if you had changed it.
