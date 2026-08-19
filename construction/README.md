# construction

Gon **v1.3** M2a construction completeness: `new(T)`, unkeyed literals, and
nested local-struct walk.

```bash
gon check construction.gon
# construction.gon:…: error GN002: … missing required non-nil field …
# exit 1
```

Shows:

- `new(Outer)` → **GN002** (zero-value construction site)
- Unkeyed `Outer{&n, Inner{&x}}` → accepted (declaration-order mapping)
- `Outer{}` → **GN002** (missing `Name` / nested `In.X`)
- `Hold{P *Outer; S []Outer}` → **accepted** (stop at indirection)

Not shown (still deferred):

- External / `SelectorExpr` unkeyed mapping (**M4 firewall** — keyed + `.gna` only)
- Interface `!I`, type coverage, flow-sensitive nilability

Requires Gon **v1.3.0+**.
