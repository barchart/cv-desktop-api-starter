# Go Starter

Setup, credentials, `cvdesk` and updating work the same in every language: see the
[main README](../README.md). This page covers what's specific to Go.

## Needs
Go 1.21+, from [go.dev/dl](https://go.dev/dl/).

## Examples
In [examples/](examples/): [start-guide.go](examples/start-guide.go) (credentials:
`username` / `password`).

## Writing scripts
- Each script is one `.go` file with `package main` and a `main` function.
- Start it with `//go:build ignore` and an empty line, like the examples: that lets
  every script have its own `main` (`cvdesk` builds one file at a time).
- Scripts use the packages in [go.mod](go.mod); add more with `go get` from this folder.

## Troubleshooting
- Login rejected -> check the credentials in `my-scripts/start-guide.go`.
- `cvdesk: command not found` -> open a new terminal window, or run setup again.
- Your start guide from an older version (in `cmd/start-guide/`) is moved into
  `my-scripts/` by the update, if you had changed it.
