# package-check

Gon **v1.10** (M8): package-aware checking. `gon check <file.gon>` checks one
file as a synthetic one-file package, so a contract declared in a sibling file
is invisible to it. Name a **directory** (or `./...`) instead and its `.gon`
files are type-checked together where they live: a `!` parameter, field or
result declared in one file is enforced in the others, and each diagnostic is
reported against its own file.

```
package-check/
├── go.mod
├── billing/                 # one package, three .gon files + one plain .go
│   ├── types.gon            # Customer, Order (Order.Customer is `!*Customer`)
│   ├── store.gon            # Save(o !*Order), Lookup(id) !*Order
│   ├── main.gon             # uses both: the violations are here
│   ├── format.go            # plain Go, loaded as it is (Describe)
│   └── helper_test.gon      # skipped: *_test.gon is not part of package mode
└── ledger/                  # a clean package (two files)
    ├── account.gon
    └── ledger.gon
```

```bash
cd package-check
gon check billing
# billing/main.gon:7:7:   error   GN001: cannot pass nil as non-nil argument 1 to Save
# billing/main.gon:9:7:   error   GN002: missing required non-nil field Order.Customer
# billing/main.gon:13:16: error   GN001: cannot assign nil to non-nil field Customer
# billing/main.gon:16:5:  warning GW001: found is non-nil; comparison with nil is always false
# exit 1   (3 errors, 1 warning)

gon check ledger         # ok
gon check ./...          # every directory below that holds .gon files: billing + ledger
gon check --json billing # one Diagnostic Protocol v1 document for the whole package
```

## What it shows

- **Cross-file contracts.** Every diagnostic in `main.gon` depends on a
  declaration in another file: `Save`'s parameter (`store.gon`),
  `Order.Customer` (`types.gon`), `Lookup`'s result (`store.gon`).
- **Single-file mode is unchanged and cannot see them.**
  `gon check billing/main.gon` stops at a Go type error
  (`undefined: Save`) because the other files are not part of that synthetic
  package. Package mode is opt-in by naming a directory.
- **Other `.go` files are loaded.** `format.go` has no `.gon` source; `main.gon`
  and `store.gon` call `Describe` from it.
- **`*_test.gon` is skipped,** like `*_test.go`: the `Save(nil)` in
  `helper_test.gon` is not reported.
- **A `.gon` replaces the `.go` of the same base name** (what `gon transpile`
  emits next to it), so a converted codebase keeps checking cleanly.
- **A Go type error does not hide contract diagnostics.** Contract diagnostics
  print first, then `gon: Go type error: …` lines, then exit 1; with `--json`
  the type error goes to stderr and the document holds only Protocol v1
  diagnostics.

Contracts of **imported** packages still come from `.gna` (see
`ecosystem-contracts/` and `generic-gna/`); reading another package's `.gon`
sources is not part of v1.10.
