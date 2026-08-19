# Gon examples

Small programs that exercise [Gon](https://github.com/daniel-juvito/gon) — static non-nil checking for Go.

Gon adds `!T` type modifiers so you can express non-nil contracts at **vet time**. The toolchain strips annotations and emits ordinary Go.

> Gon v1.x provides static non-nil checking for explicit cases and `.gna` contracts; it does **not** perform flow-sensitive nil analysis or runtime enforcement.

## Install Gon

```bash
go install github.com/daniel-juvito/gon/cmd/gon@v1.3.0
```

## Examples

| Path | Version | What it shows |
|------|---------|----------------|
| [`hello/`](hello/) | v1.0 | `!T` params, returns, and required struct fields |
| [`reject-nil/`](reject-nil/) | v1.0 | GN001 when literal `nil` is passed to `!T` |
| [`struct-fields/`](struct-fields/) | v1.0 | GN002 when a required `!T` field is missing |
| [`flow-ok/`](flow-ok/) | v1.0 | Non-literal assignment is allowed (not flow-sensitive) |
| [`return-value/`](return-value/) | **v1.1** | Annotated `!T` result is a non-nil source (GW001); local multi-return |
| [`field-contracts/`](field-contracts/) | **v1.2** | Field invariant: construction, mutation, selector; indirection stops |
| [`construction/`](construction/) | **v1.3** | `new(T)`, unkeyed local literals, nested walk; stop at indirection |

## Quick start

```bash
# check (exit 1 on errors; warnings alone exit 0)
gon check hello/hello.gon

# emit clean Go next to the source
gon transpile hello/hello.gon

# build from inside the example dir (binary name matches the stem)
cd hello
gon build hello.gon
./hello
# hello, gon
# running gon on :8080
```

Negative / feature examples:

```bash
gon check reject-nil/reject.gon           # GN001, exit 1
gon check struct-fields/fields.gon        # GN001 + GN002, exit 1
gon check flow-ok/flow.gon                # ok — non-guarantee of v1
gon check return-value/return.gon         # GW001 warnings, exit 0
gon check field-contracts/fields.gon      # GN002 + GN001 + GW001, exit 1
gon check construction/construction.gon  # GN002 (new/unkeyed/nested), exit 1
```

## Docs

- [Gon README](https://github.com/daniel-juvito/gon)
- [v1 scope](https://github.com/daniel-juvito/gon/blob/v1.3.0/docs/v1-scope.md)
- [.gna spec](https://github.com/daniel-juvito/gon/blob/v1.3.0/docs/gna-spec-v1.md)
- [Return-value contracts (v1.1)](https://github.com/daniel-juvito/gon/blob/v1.3.0/docs/rfc-return-value-contracts.md)
- [Field contracts (v1.2)](https://github.com/daniel-juvito/gon/blob/v1.3.0/docs/rfc-field-contracts.md)
