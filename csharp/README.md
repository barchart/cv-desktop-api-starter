# C# Starter

Setup, credentials, `cvdesk` and updating work the same in every language: see the
[main README](../README.md). This page covers what's specific to C#.

## Needs
.NET SDK 10+, from [dotnet.microsoft.com](https://dotnet.microsoft.com/download).
(Earlier versions of this project used .NET 8.)

## Examples
In [examples/](examples/): [start-guide.cs](examples/start-guide.cs) (credentials:
`username` / `password`).

## Writing scripts
- Each script is one `.cs` file, run as a program of its own. Start it with the
  same two lines as the examples:
  ```csharp
  #:package openfeed.net@*
  #:property PublishAot=false
  ```
- Need another NuGet package? Add a `#:package Name@version` line.
- The first run of a new or changed script builds it, which takes a few seconds.

## Troubleshooting
- Login rejected -> check the credentials in `my-scripts/start-guide.cs`.
- `cvdesk: command not found` -> open a new terminal window, or run setup again.
- Your start guide from an older version (in `OpenFeedStartGuide/`) is moved into
  `my-scripts/` by the update, if you had changed it.
