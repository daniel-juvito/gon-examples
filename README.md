# Gon examples

Small programs that exercise [Gon](https://github.com/daniel-juvito/gon) — static non-nil checking for Go.

Gon adds `!T` type modifiers so you can express non-nil contracts at **vet time**. The toolchain strips annotations and emits ordinary Go.

> Gon v1.x provides static non-nil checking for explicit cases and `.gna` contracts; it does **not** perform flow-sensitive nil analysis or runtime enforcement.

## Install Gon

```bash
go install github.com/daniel-juvito/gon/cmd/gon@v1.15.0
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
| [`cli/`](cli/) | **v1.3** | `gon fmt` preserves `!`; `check` / `vet` alias |
| [`interface-contracts/`](interface-contracts/) | **v1.4** | `!I` is interface-value non-nil only; typed-nil ok, ordinary `I` rejected, embedding does not propagate |
| [`ecosystem-contracts/`](ecosystem-contracts/) | **v1.5** | external `.gna` `types:` field contracts across the package boundary (construction / mutation / use); interface results; `.gna` validation (GN003 / GW004) |
| [`type-coverage/`](type-coverage/) | **v1.6** | `!` on slice / map / chan / func / named / alias means the reference value is non-nil; bare `var x !S` needs an initializer (GN002); `x.(!T)` → GN001; `!` on a non-nilable kind → GN003 |
| [`element-contracts/`](element-contracts/) | **v1.7** | element `!` (`[]!*T`, `[N]!*T`, `map[K]!*V`, `[]!I`) checked at the composite-literal site: nil element → GN001, fixed-array zero-fill → GN002, `!` on chan element / map key / non-nilable kind → GN003; construction-time only |
| [`generics/`](generics/) | **v1.8** | contracts attach to declaration positions and survive instantiation: `Box[T]{}` → GN002/GN001, `NN[T]()` result is a non-nil source (GW001), `!X` needs a nilable constraint (GN003), `!` in a type argument → GN003 |
| [`generic-gna/`](generic-gna/) | **v1.9** | `.gna` contracts on generic symbols: explicit instantiation resolves like inference, a `!` flag over a nilable type parameter is valid, field contracts survive `pkg.T[K, V]{}`, and an invalid flag (`"!string"`) is GN003 with only that flag dropped |
| [`package-check/`](package-check/) | **v1.10** | package mode: `gon check <dir>` / `./...` checks a directory's `.gon` files as one package, so a contract declared in one file (`!` parameter, field, result) is enforced in the others; a sibling plain `.go` is loaded as is; `*_test.gon` is skipped; one `--json` document; a single-file check of the same file cannot see the other files |
| [`method-contracts/`](method-contracts/) | **v1.11** | a `!` on a method's parameter or result is enforced at its callers: direct, promoted through embedding, through an interface, method expression; a `!` result is a non-nil source (GW001); matched by `go/types` identity so two types sharing a method name do not collide; a method value is not tracked |
| [`transpile-dir/`](transpile-dir/) | **v1.12** | `gon transpile` / `gon build` accept a directory or `./...`: the package is checked as a whole and `.go` is written only if it passes; packages are done after the ones they import, so a tree with no `.go` works; a file alone cannot be transpiled when it uses a sibling |
| [`return-contracts/`](return-contracts/) | **v1.13** | the operands of a `return` are checked like any other expression (`return Job{Task: nil}`, `return Run(nil)`, `return t == nil`), and a function literal is checked as a function (its own parameters shadow outer ones, its `return` answers to its own `!` result) |
| [`source-contracts/`](source-contracts/) | **v1.14** | an importer sees the `!` contracts written in another package's `.gon` sources of the same module (no `.gna` to write): GW001 / GN001 / GN002 across the package boundary; a stale `.gna` for that package is ignored (GW005) |

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
gon check interface-contracts/interface.gon  # GN001 ×6 + GW001, exit 1
(cd ecosystem-contracts && gon check demo.gon) # GN002/GN001 + GW001, exit 1
gon check type-coverage/type-coverage.gon  # GN002/GN001/GN003 + GW001, exit 1
gon check element-contracts/element-contracts.gon  # 5×GN001 + 3×GN002 + 3×GN003, exit 1
gon check generics/generics.gon  # GN003/GN002/GN001 + GW001, exit 1
(cd generic-gna && gon check demo.gon)  # GN001/GN002/GN003 + GW001, exit 1
gon check method-contracts/methods.gon  # v1.11: 4×GN001 + GW001 on method calls, exit 1
(cd source-contracts && gon transpile ./lib && gon check ./app)  # v1.14: GW005 + GW001 + GN001 + GN002, exit 1
gon check return-contracts/returns.gon  # v1.13: 3×GN001 + GN002 + GW001 in return operands, exit 1
(cd transpile-dir && gon transpile ./... && gon build ./cmd/app && ./app)  # v1.12: total: 15
(cd package-check && gon check billing)  # package mode: cross-file GN001 ×2 + GN002 + GW001, exit 1
(cd package-check && gon check ./...)    # same; ledger/ is clean
gon fmt cli/demo.gon && gon check cli/demo.gon  # fmt preserves !; ok
```

## CI

`scripts/check-examples.sh` runs `gon check` on every example listed in
[`expected.txt`](expected.txt) and compares the exit code and the count of each
diagnostic code (positions are not compared). The workflow installs the pinned
`gon` version (`GON_VERSION` in `.github/workflows/ci.yml`) and runs it on every
pull request. When you add or change an example, update its README and its line
in `expected.txt`; when you bump `GON_VERSION`, re-check both.

```bash
scripts/check-examples.sh          # uses `gon` from PATH
```

## Docs

- [Gon README](https://github.com/daniel-juvito/gon)
- [v1 scope](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/v1-scope.md)
- [.gna spec](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/gna-spec-v1.md)
- [Exit codes of package loading (v1.15, Protocol v1 §7)](https://github.com/daniel-juvito/gon/blob/v1.15.0/docs/diagnostic-protocol-v1.md#7-exit-codes)
- [Cross-package contracts from .gon sources (v1.14)](https://github.com/daniel-juvito/gon/blob/v1.14.0/docs/rfc-source-contracts.md)
- [v1.13 release notes (return operands, function literals)](https://github.com/daniel-juvito/gon/blob/v1.13.0/CHANGELOG.md)
- [Directory form for transpile / build (v1.12)](https://github.com/daniel-juvito/gon/blob/v1.12.0/docs/rfc-transpile-dir.md)
- [Method call-site contracts (v1.11)](https://github.com/daniel-juvito/gon/blob/v1.11.0/docs/rfc-method-contracts.md)
- [Package-aware checking (v1.10)](https://github.com/daniel-juvito/gon/blob/v1.10.0/docs/rfc-package-check.md)
- [Return-value contracts (v1.1)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-return-value-contracts.md)
- [Field contracts (v1.2)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-field-contracts.md)
- [Interface semantics (v1.4)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-interface-semantics.md)
- [Ecosystem contract expansion (v1.5)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-ecosystem-contract-expansion.md)
- [Type coverage (v1.6)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-type-coverage.md)
- [Element-contract construction (v1.7)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-element-contract-construction.md)
- [Generic semantics (v1.8)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-generic-semantics.md)
- [Generic `.gna` (v1.9)](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-generic-gna.md)
