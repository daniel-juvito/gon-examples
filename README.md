# Gon examples

Small programs that exercise [Gon](https://github.com/daniel-juvito/gon) v1.0 — static non-nil checking for Go.

Gon adds `!T` type modifiers so you can express non-nil contracts at **vet time**. The toolchain strips annotations and emits ordinary Go.

> Gon v1.0 provides static non-nil checking for explicit cases and `.gna` contracts; it does **not** perform flow-sensitive nil analysis or runtime enforcement.

## Install Gon

```bash
go install github.com/daniel-juvito/gon/cmd/gon@v1.0.0
```

## Examples

| Path | What it shows |
|------|----------------|
| [`hello/`](hello/) | `!T` params, returns, and required struct fields |
| [`reject-nil/`](reject-nil/) | GN001 when literal `nil` is passed to `!T` |
| [`struct-fields/`](struct-fields/) | GN002 when a required `!T` field is missing |
| [`flow-ok/`](flow-ok/) | Non-literal assignment is allowed (v1 is not flow-sensitive) |

## Quick start

```bash
# check (exit 1 on errors; warnings alone exit 0)
gon check hello/hello.gon

# emit clean Go next to the source
gon transpile hello/hello.gon

# transpile + go build
gon build hello/hello.gon
./hello
```

## Docs

- [Gon README](https://github.com/daniel-juvito/gon)
- [v1 scope](https://github.com/daniel-juvito/gon/blob/v1.0.0/docs/v1-scope.md)
- [.gna spec](https://github.com/daniel-juvito/gon/blob/v1.0.0/docs/gna-spec-v1.md)
