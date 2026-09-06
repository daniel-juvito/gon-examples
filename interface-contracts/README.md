# interface-contracts

Gon **v1.4** (M1a): `!I` is an *interface-value* non-nil contract. It
guarantees the interface value itself is non-nil — never its dynamic value.

```bash
gon check interface.gon
# interface.gon:…: error GN001: cannot assign ordinary interface value to non-nil type !Reader
# interface.gon:…: error GN001: cannot assign nil to non-nil type !Reader
# interface.gon:…: warning GW001: src is non-nil; comparison with nil is always false
# interface.gon:…: error GN001: type assertion target cannot carry a non-nil contract (!I); …
# exit 1  (6 × GN001, 1 × GW001)
```

Shows:

- **D3a** — a concrete value (even a typed-nil `*File`) assigned to `!Reader`
  is **accepted**: the interface value is non-nil, and Gon does not look at
  the dynamic value.
- **D3b** — an ordinary `Reader` value → `!Reader` is **GN001**,
  unconditionally. A preceding `if r != nil` does **not** narrow it (no flow
  analysis).
- **D3c** — `nil` → `!Reader` is **GN001**.
- **D3d / D4** — an existing `!Reader` value (here, the result of `mkReader()`)
  satisfies `!Reader` and is a non-nil source (`src == nil` → **GW001**).
- **§3.7** — embedding does not propagate `!`: a `!ReadCloser` value is **not**
  a `!Reader` source → **GN001**.
- **D6c** — an explicit conversion `Reader(p)` has interface static type and
  cannot satisfy `!Reader` → **GN001**.
- **D6a** — `x.(!Reader)` is not a Gon mechanism → **GN001**.

Not shown (out of scope, by design):

- Any check on the interface's **dynamic value** — `!I` never constrains it.
- `x.(!*T)` (a `!` on a *concrete* assertion target) — left for a later RFC.

Spec: [rfc-interface-semantics.md](https://github.com/daniel-juvito/gon/blob/v1.4.1/docs/rfc-interface-semantics.md)

Requires Gon **v1.4.1+** (v1.4.0 checks this file correctly, but its
`gon fmt` mis-aligns `!` on files that use a type as both `!I` and `I`).
