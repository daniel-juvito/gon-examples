# flow-ok

Gon is **not flow-sensitive**: it does not follow a value through assignments or
return values, so an ordinary `*string` is never taken to be non-nil.

```bash
gon check flow.gon    # exit 1 — one GN001 (the `var x` line)
```

- `var x !*string = get()` is **GN001** since **v1.22**: `get()` is an ordinary
  value that may be nil, and Gon cannot prove otherwise. (Until v1.20 it was
  accepted without a diagnostic, and in v1.21 it was the warning GW006.)
- `var y !*string = (!*string)(get())` is accepted: the explicit conversion is the
  author's claim that the value is non-nil. It performs **no run-time check**, so if
  the claim is wrong the nil shows up later, as in Go.
- Declaring `get` as `func get() !*string` instead makes its `return` checked and its
  callers silent, with no conversion.

Only a **literal** `nil` into a `!T` slot is a different error (see
[`reject-nil/`](reject-nil/)).
