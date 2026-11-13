# element-contracts

Gon **v1.7** (M2b): `!` in **element / value position** — `[]!*T`,
`[N]!*T`, `map[K]!*V`, `[]!I` — means "every element (or map value) is
non-nil **at construction**". It is a construction-time obligation, not a
lifetime invariant of the container.

```bash
gon check element-contracts.gon
# error GN003: non-nil modifier ! is not valid on a channel element type; …
# error GN003: non-nil modifier ! is not valid on a map key type; …
# error GN003: non-nil modifier ! is not valid on element type int; …
# error GN002: fixed-array literal leaves non-nil element index 0 at its zero value
# error GN001: cannot use nil as non-nil element *Handler
# error GN001: cannot use nil as non-nil map value *Handler
# exit 1  (6 errors: 3×GN003, 1×GN002, 2×GN001)
```

Shows:

- **GN001** — an explicit `nil` written as an element or map value.
  Ordinary expressions (even calls that may return nil) are accepted,
  conservatively, exactly as for outer `!`.
- **GN002** — a fixed-array literal that leaves a `!` nilable index at its
  zero value (one diagnostic per literal). `[...]!*T{x}` (inferred length)
  never fires.
- **GN003** — element `!` on a channel element, a map key, or a non-nilable
  element kind.
- Compositional binding: `![]!*T` constrains both the slice and its elements.

Not tracked (by design): after construction, `s[i] = nil`, `append`, and map
assignment are ordinary Go.

Spec: [rfc-element-contract-construction.md](https://github.com/daniel-juvito/gon/blob/v1.7.0/docs/rfc-element-contract-construction.md)

Requires Gon **v1.7.0+**.
