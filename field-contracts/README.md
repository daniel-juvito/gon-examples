# field-contracts

Gon **v1.2** field contracts: a `!T` field is an invariant of its storage
location, checked only at construction, mutation, and selector use.

```bash
gon check fields.gon
# fields.gon:…: error GN002: … missing required non-nil field …Client
# fields.gon:…: error GN001: cannot assign nil to non-nil field …
# fields.gon:…: warning GW001: … is non-nil; comparison with nil is always false
# exit 1 — errors fail the process
```

Shows:

- `var c Config` / `Config{}` → **GN002** (zero-value containment)
- Embedded `Wrapper` and `[2]Config` → traversed
- `cfg.Client = nil` → **GN001**
- `ok.Client == nil` → **GW001** (selector is non-nil source)
- `Indirect{Ptr, Slice}` → **accepted** (no traversal past indirection)

Spec: [rfc-field-contracts.md](https://github.com/daniel-juvito/gon/blob/v1.2.0/docs/rfc-field-contracts.md)
