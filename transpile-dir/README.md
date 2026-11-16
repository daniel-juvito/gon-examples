# transpile-dir

Gon **v1.12** (M9): `gon transpile` and `gon build` accept a **directory**
(or `dir/...`). The directory is checked as one package, and `.go` files are
written next to the `.gon` sources **only if the package passes**.

```
transpile-dir/
├── go.mod
├── shop/            # one package, two files that need each other
│   ├── item.gon     # Item, NewItem (a !*Item result)
│   └── price.gon    # Total uses Item from item.gon
└── cmd/app/
    └── main.gon     # imports shop
```

```bash
cd transpile-dir

gon transpile shop/price.gon
# gon: Go type error: … undefined: Item      <- a file alone cannot see its sibling

gon transpile ./...
# transpiled: shop/item.go
# transpiled: shop/price.go
# transpiled: cmd/app/main.go

gon build ./cmd/app          # transpile, then go build ./cmd/app
./app
# total: 15
```

## What it shows

- **A package is transpiled as a whole.** `price.gon` alone fails (it uses
  `Item` from `item.gon`); the directory form checks both files together.
- **Dependency order.** `./...` transpiles `shop` before `cmd/app`, which imports
  it, so a fresh tree with **no `.go` at all** works: `cmd/app` is checked
  against the `.go` of `shop` that was just written.
- **All or nothing per package.** If a package has a contract error or a Go type
  error, nothing is written for it (an existing `.go` stays as it was); other
  packages are still checked and the passing ones are written; the exit code is 1.
- **`gon build <dir> [go flags]`** is `transpile` then `go build <dir>`; nothing
  is forced (no `-o`).
- The `.go` files are generated output and are not committed in this
  repository (`.gitignore`).

A fresh tree has no `.go`, so `gon check ./...` before the first `transpile`
cannot import `shop` (`invalid package name`): checking a package that imports
another module-local package reads that package's **Go** source. Run
`gon transpile ./...` first, then `gon check ./...` is `ok`.
