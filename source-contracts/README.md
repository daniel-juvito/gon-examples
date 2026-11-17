# source-contracts

Gon **v1.14** (M10): a package that **imports** another package of your module
sees the `!` contracts written in that package's `.gon` sources. You no longer
write a `.gna` for your own packages; `.gna` stays for the standard library and
for dependencies.

```
source-contracts/
├── go.mod
├── lib/store.gon      # the contracts: Open() !*Store, (*Store).Put(!*Item), Entry.Item !*Item
├── app/main.gon       # imports lib and breaks them
└── annotations/gonexample.local/sourcecontracts/lib.gna   # a stale .gna (ignored)
```

```bash
cd source-contracts
gon transpile ./lib   # lib's .go is needed to type-check its importer
gon check ./app
# app/main.gon:6:2:  warning GW005: .gna for gonexample.local/sourcecontracts/lib is ignored: the package has .gon sources, which are authoritative
# app/main.gon:11:5: warning GW001: s is non-nil; comparison with nil is always false
# app/main.gon:14:8: error   GN001: cannot pass nil as non-nil argument 1 to gonexample.local/sourcecontracts/lib.Store.Put
# app/main.gon:15:6: error   GN002: missing required non-nil field Entry.Item
# exit 1
```

Gon v1.13 reports `ok` on the same `app` (it read `lib`'s contracts from `.gna`
only).

## What it shows

- **Contracts cross the package boundary from source.** `Open`'s `!*Store`
  result, `Put`'s `!*Item` parameter and `Entry`'s required `Item` field are
  all declared in `lib/store.gon`; `app` gets GW001, GN001 and GN002 for them.
- **An ordinary result stays ordinary.** `s.Get("x")` may return nil; comparing
  it with nil is fine.
- **The `.gon` sources are authoritative.** The stale `.gna` claims `Get`'s
  result is non-nil; it is ignored, so `it == nil` gets no GW001, and the
  import gets one **GW005** saying so. Delete such a `.gna` once the package is
  written in Gon.
- **Only your module.** A dependency outside the main module keeps its `.gna`,
  even if it ships `.gon` files.

`lib` has to be transpiled first: checking `app` type-checks it against `lib`'s
Go form (as in [`transpile-dir/`](../transpile-dir/)). Without `lib/store.go`,
`gon check ./app` stops with `could not import …/lib`.
