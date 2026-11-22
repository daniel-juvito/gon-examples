# flow-ok

Documents a **non-guarantee** of v1.0.

```bash
gon check flow.gon    # exit 0 — one warning, GW006
```

`var x !*string = get()` is accepted (exit 0) because Gon v1 does not propagate
nilability across assignments or from return values. Only **literal** `nil`
into a `!T` slot is rejected.

Since v1.21 the ordinary `*string` flowing into the `!*string` slot is the
warning **GW006**; `(!*string)(get())` is the explicit claim that silences it.

See [v1 scope](https://github.com/daniel-juvito/gon/blob/v1.0.0/docs/v1-scope.md).
