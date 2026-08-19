# cli

Gon **v1.3** CLI tooling: `fmt`, `check`, and the `vet` alias.

```bash
# format in place — go/format on the clean form, then re-insert !
gon fmt demo.gon
cat demo.gon   # !*string / !*Config still present

# check (canonical)
gon check demo.gon   # ok

# vet is a compatibility alias of check
gon vet demo.gon     # ok
```

Shows:

- `gon fmt` does not strip `!` (word-boundary re-insertion)
- `gon check` / `gon vet` share the same pipeline
- Happy-path file (no diagnostics)

`demo.gon` is intentionally lightly messy so `fmt` has something to normalize.

Not a full LSP walkthrough (`gon lsp` is interactive stdio). Use this folder
to confirm the release binary formats and checks the same way as `go install`.

Requires Gon **v1.3.0+**.
