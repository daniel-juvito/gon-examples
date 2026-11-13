# element-contracts

Gon **v1.7** (M2b): `!` in **element / value position** — `[]!*T`, `[N]!*T`,
`map[K]!*V`, `[]!I` — is a **construction-time** obligation. Every explicitly
written element of a composite literal, and every zero-filled index of a fixed
array, must be non-nil **at the construction site**. It is *not* a lifetime
invariant of the container: `s[i] = nil`, `append`, and map assignment after
construction are ordinary Go and are not tracked.

```bash
gon check element-contracts.gon
# element-contracts.gon:21:…: error GN001: cannot use nil as non-nil element *T
# element-contracts.gon:32:…: error GN002: fixed-array literal leaves non-nil element index 1 at its zero value
# element-contracts.gon:49:…: error GN003: non-nil modifier ! is not valid on a channel element type; …
# exit 1  (11 errors: 5×GN001, 3×GN002, 3×GN003)
```

Shows:

- **E4** — an explicitly written `nil` element or map value under an element
  `!` is **GN001** (`[]!*T{mk(), nil}`, `map[string]!*T{"a": nil}`). An
  ordinary expression is accepted even if it might be nil at runtime
  (`maybe()` — conservative, same as Type Coverage C4). Non-nil is not
  non-empty: `[]!*T{}` and `map[string]!*T{}` are fine.
- **E5** — a **fixed-array** literal that leaves one or more indices at their
  zero value is **GN002** — one per literal. Coverage is by *index*: an
  unkeyed element covers the running position, a keyed element `k: v` covers
  index `k`. `[3]!*T{mk()}` and `[3]!*T{2: mk()}` are each GN002;
  `[3]!*T{0: mk(), 1: mk(), 2: mk()}` is clean. `[...]!*T{mk()}` (inferred
  length) never has a shortfall.
- **E6** — the outer reference contract (`![]…`) and the element contract are
  independent. `var s ![]!*T = nil` is GN001 on the *outer* slice;
  `var u ![]!*T = []!*T{nil}` is GN001 on the *element*; a bare
  `var z ![]!*T` is GN002 for the outer zero value (the v1.6 rule).
- **E12** — an interface element (`[]!Handler`) follows the v1.4
  interface-value rule: `[]!Handler{nil}` is **GN001** (the interface value
  is nil); the dynamic value is never constrained.
- **E11 / O1 / O4** — a malformed element `!` is **GN003**: on a channel
  element (`chan !*T` — no construction site), on a map key (`map[!*T]int` —
  key contracts are not in v1), or on a non-nilable element kind (`[]!int`).
- **Non-goals** — after `ok := []!*T{mk()}`, both `ok[0] = nil` and
  `ok = append(ok, nil)` produce **no diagnostic**; `range` yields an
  ordinary `*T`. Element contracts do not descend through indirection or
  survive past the construction expression.

`NewHandlers() ![]!*T` shows both contracts satisfied at once — the slice is
non-nil *and* every element is non-nil.

`.gna` type strings accept element `!` for slice/array/map values
(`"[]!*Handler"`, `"map[string]!*Service"`); the recorded flag still reflects
only the outermost `!`. Channel-element and map-key `!` remain a load error.
No `.gna` schema bump — still schema **1**.

Spec: [rfc-element-contract-construction.md](https://github.com/daniel-juvito/gon/blob/v1.7.0/docs/rfc-element-contract-construction.md)

Requires Gon **v1.7.0+**.
