# return-value

Gon **v1.1** return-value contracts: an annotated `!T` result becomes a
non-nil source at its immediate use site (`:=` or `var` without an explicit type).

```bash
gon check return.gon
# return.gon:…: warning GW001: name is non-nil; comparison with nil is always false
# return.gon:…: warning GW001: f is non-nil; comparison with nil is always false
# exit 0 — warnings alone do not fail
```

Shows:

- `MustName() !*string` → binding is non-nil source (GW001 on `== nil`)
- Multi-return: only the annotated position is promoted
- Explicit type on the binding still works
- Conversion does **not** propagate source-ness (not flagged here)

Spec: [rfc-return-value-contracts.md](https://github.com/daniel-juvito/gon/blob/v1.2.0/docs/rfc-return-value-contracts.md)
