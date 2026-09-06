# ecosystem-contracts

Gon **v1.5** (M4a + M4b): external `.gna` contracts cross the package
boundary. An imported package's `types:` field contracts and its `!` result
contracts are enforced at the **call site**, exactly like local ones.

This example is a small self-contained module:

```
ecosystem-contracts/
├── go.mod
├── store/store.go                                   # the "imported" library
├── annotations/…/ecosystem/store.gna                # its contracts
└── demo.gon                                         # uses store, gets checked
```

```bash
cd ecosystem-contracts
gon check demo.gon
```

Expected (a set — order within a construction site is not significant):

```
GN002  Conn.DB / Conn.Log / Conn.W missing        # 3 construction sites
GN001  cannot assign nil to non-nil field Conn.Log
GN001  cannot assign ordinary interface value to non-nil field Conn.W
GN001  cannot assign nil to non-nil field DB       # mutation
GW001  Log / r / conn is non-nil                   # non-nil sources
exit 1
```

## What it shows

**M4a — external field contracts.**

- `store.Conn` has `DB "!*DB"`, `Log "!*Logger"`, `W "!io.Writer"` in
  `store.gna`. A keyed `store.Conn{DB: db}`, `new(store.Conn)`, and
  `&store.Conn{}` are all construction sites — a missing `!` field is
  **GN002**.
- An explicit `nil` written for a `!` field → **GN001**.
- `c.DB = nil` (mutation of an external `!` field) → **GN001**.
- `c.Log` is a **non-nil source**: `c.Log == nil` → **GW001**.
- Unkeyed `store.Conn{db, lg, w}` would stay behind the firewall (no
  diagnostic) — Gon does not reconstruct external field order.

**M4b — interface-typed positions.**

- `W` is `!io.Writer`: a concrete writer (`&bytes.Buffer{}`) satisfies it —
  even a typed-nil one — but an **ordinary `io.Writer` value** does not →
  **GN001** (D3b).
- `store.Open()` is annotated `!io.Reader`; its result is a non-nil source
  and satisfies a local `!io.Reader` (`r == nil` → **GW001**).
- `store.Connect()` is annotated `!*Conn`; same, for a pointer result.

**M5a — `.gna` validation against the real package.** Try breaking
`store.gna`:

- give `Connect` `results: ["!*Conn", "error"]` → **GN003** — arity
  mismatch vs `func Connect() *Conn`; that entry is dropped (its `!` flags
  stop applying) so a stale annotation can't shift a claim onto the wrong
  position.
- rename the `Conn` type key to `Connn`, or add `functions: { Frobnicate: … }`
  → **GW004** — the `.gna` names a `functions:` / `methods:` / `types:`
  symbol the package does not provide (once per bad symbol, not per call).

## Not shown (by design)

- Any check on an interface's **dynamic value** — `!I` never constrains it.
- Multi-hop `external → external → external` structural traversal — the
  zero-value walk is one hop across the boundary in v1.5.
- Positional / unkeyed external construction — deferred.

Spec:
[rfc-ecosystem-contract-expansion.md](https://github.com/daniel-juvito/gon/blob/v1.5.1/docs/rfc-ecosystem-contract-expansion.md)
·
[.gna spec](https://github.com/daniel-juvito/gon/blob/v1.5.1/docs/gna-spec-v1.md)

Requires Gon **v1.5.1+** (v1.5.0 checks this correctly but its post-check Go
re-validation cannot resolve the module-local `store` import).
