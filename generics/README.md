# generics

Gon **v1.8** (M3): contracts are attached to a **declaration position**, never
to a type argument. Instantiation substitutes types; it never adds, removes,
or carries a `!`.

```bash
gon check generics.gon
# error GN003: non-nil modifier ! is not valid on type parameter X: its constraint does not restrict it to nilable kinds …
# error GN003: non-nil modifier ! is not valid in a type argument; …
# error GN002: missing required non-nil field Box.v
# error GN001: cannot assign nil to non-nil field Box.v
# error GN002: missing required non-nil field v
# warning GW001: p is non-nil; comparison with nil is always false
# exit 1  (5 errors: 2×GN003, 2×GN002, 1×GN001 — plus 1×GW001)
```

Shows:

- **G2** — `!X` on a type parameter is valid only when `X`'s constraint
  restricts it to nilable kinds (`~*Handler`, `~[]E`, `*A | *B`, …).
  `func Bad[X any](x !X)` is **GN003**; `func Use[P ~*Handler](p !P)` is fine.
- **G3** — a field contract survives instantiation: `Box[Handler]{}` and
  `var z Box[Handler]` are **GN002**, `Box[Handler]{v: nil}` is **GN001**.
- **G5** — a `!` result resolves through the instantiation, explicit
  (`NN[Handler]()`) or inferred (`Must(x)`): `p == nil` is **GW001**.
- **G4** — `!` inside a type argument (`Plain[!*Handler]`) is **GN003**: a
  type argument's identity is Go's, so it cannot carry a contract. The same
  goes for `!` inside a constraint (`~!*T`).

Not shown (by design):

- Contracts carried *by* type arguments — `Id(nonNil)` returns a plain `*T`.
- Generic `.gna` declarations / external generic contracts — M5b (v1.9).
- Source-declared **method** contracts — untracked for every receiver.

Spec: [rfc-generic-semantics.md](https://github.com/daniel-juvito/gon/blob/v1.8.0/docs/rfc-generic-semantics.md)

Requires Gon **v1.8.0+**.
