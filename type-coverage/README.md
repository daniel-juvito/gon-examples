# type-coverage

Gon **v1.6** (M1b): `!` means the same thing on every nilable Go kind — the
**reference value** is non-nil. `![]T` / `!map` / `!chan` / `!func` (and
named types / aliases of them) say nothing about length, emptiness, or
channel state, exactly as `!I` says nothing about an interface's dynamic
value.

```bash
gon check type-coverage.gon
# type-coverage.gon:…: error GN003: non-nil modifier ! is not valid on Point; …
# type-coverage.gon:…: error GN002: non-nil variable s declared without an initializer; …
# type-coverage.gon:…: error GN001: cannot assign nil to non-nil type ![]byte
# type-coverage.gon:…: warning GW001: hs is non-nil; comparison with nil is always false
# exit 1  (9 errors: 5×GN002, 3×GN001, 1×GN003 — plus 2×GW001)
```

Shows:

- **C5** — a bare `var x !S` of a nilable reference kind (`![]byte`,
  `!map[string]int`, the named `!Handler`, the alias `!Bytes`) with **no
  initializer** is **GN002**: the zero value of the reference is nil. This
  also closes the pre-v1.6 gap where `var p !*T` was silently accepted. A
  non-nil initializer — `make(...)`, a composite literal (even an empty one),
  a function literal / name — is accepted.
- **C2** — non-nil is not non-empty: `[]Handler{}` and `map[string]Handler{}`
  satisfy `![]Handler` / `!map`.
- **C3** — the `nil` literal never satisfies a `!` reference contract → **GN001**.
- **C8** — an annotated `![]T` **result** is a non-nil source at the call
  site (`hs == nil` → **GW001**).
- **C6** — `append`, reslice, and conversion produce ordinary values; the
  `!` contract is **not** carried onto them (`grown == nil` → *no* GW001).
- **C11** — a `![]T` / `!map` / `!func` **field** is an invariant of its
  storage: zero construction → **GN002**, `f = nil` → **GN001**, the
  selector is a non-nil source → **GW001**.
- **C7** — `!` on **any** type-assertion target (`box.(![]byte)`) is
  **GN001**; assertions never establish a non-nil guarantee.
- **O4** — `!` on a non-nilable kind (`!Point`, where `Point` is a struct)
  is a malformed contract → **GN003**.

Not shown (out of scope, by design):

- Element-position contracts (`[]!T`, `map[K]!V`) — reserved for M2b (v1.7).
- Any length / non-emptiness / channel open-state claim — `!` is nilability
  only.

Spec: [rfc-type-coverage.md](https://github.com/daniel-juvito/gon/blob/v1.6.0/docs/rfc-type-coverage.md)

Requires Gon **v1.6.0+**.
