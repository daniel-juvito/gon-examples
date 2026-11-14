# generic-gna

Gon **v1.9** (M5b): `.gna` contracts on **generic** symbols of an imported
package. Contracts attach to a *declaration position* of the symbol's real
signature, never to a type argument, so an explicit instantiation resolves to
the same entry as an inferred one, and every `!` flag is validated against
that signature.

This is a small self-contained module:

```
generic-gna/
├── go.mod
├── cache/cache.go                                      # the "imported" generic library
├── annotations/gonexample.local/genericgna/cache.gna   # its contracts
└── demo.gon                                            # uses cache, gets checked
```

```bash
cd generic-gna
gon check demo.gon
# demo.gon:3:8:  error   GN003: .gna for …/cache: ! on parameter 1 (s) of Describe: string is not a nilable kind …; the flag is ignored
# demo.gon:10:22: error  GN001: cannot pass nil as non-nil argument 1 to …/cache.Must
# demo.gon:12:5:  warning GW001: inferred is non-nil; comparison with nil is always false
# demo.gon:15:5:  warning GW001: explicit is non-nil; comparison with nil is always false
# demo.gon:19:33: error  GN001: cannot pass nil as non-nil argument 1 to …/cache.Keys
# demo.gon:22:6:  error  GN002: missing required non-nil field Cache.Items
# demo.gon:22:6:  error  GN002: missing required non-nil field Cache.Log
# demo.gon:23:38: error  GN001: cannot assign nil to non-nil field Cache.Items
# exit 1   (6 errors: 3×GN001, 2×GN002, 1×GN003 — plus 2×GW001)
```

Gon v1.8.1 reports only the inferred `GW001` on the same file and exits 0.

## What it shows

- **Explicit = inferred.** `cache.Must(&x)` and `cache.Must[int](&x)` both
  expose `Must`'s `"!*V"` result as a non-nil source (**GW001**), and
  `cache.Must[int](nil)` is **GN001** like any nil argument to a `!`
  parameter. Before v1.9 the explicit form was not resolved at all.
- **A `!` over a nilable type parameter is valid.** `Keys[M ~map[K]V, …]`
  carries `"!M"`: `M` is restricted to a map type, so `cache.Keys[…](nil)` is
  **GN001**.
- **Field contracts survive instantiation.** `cache.Cache[string, int]{}`
  leaves `Items` and `Log` unset (**GN002** ×2), and `Items: nil` is
  **GN001**. The instantiated type arguments never change which fields
  carry a contract.
- **An invalid flag is dropped, only that flag.** `Describe` claims
  `"!string"` on a `string` parameter on purpose. A `!` is only meaningful on
  a nilable kind, so Gon reports **GN003** (anchored at the import) and
  ignores that one flag; the rest of the file keeps working.

## Not shown (by design)

- A `!` over a type parameter such as `[X any]` is also **GN003** — `any` can
  be `int`. Use a concrete outer constructor (`"!*X"`, `"![]E"`) or a
  nilable constraint (`~*E`, `~[]E`, `~map[K]V`).
- A `!` inside a type argument of a `.gna` string (`"Box[!*T]"`) is a load
  error: a type argument carries no contract.
- Contracts on source-declared **methods** are not tracked for any receiver;
  only `.gna` carries method contracts.

Spec: [rfc-generic-gna.md](https://github.com/daniel-juvito/gon/blob/v1.9.0/docs/rfc-generic-gna.md)

Requires Gon **v1.9.0+**.
