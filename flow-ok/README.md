# flow-ok

Documents a **non-guarantee** of v1.0.

```bash
gon check flow.gon    # ok — no diagnostic
```

`var x !*string = get()` is accepted because Gon v1 does not propagate
nilability across assignments or from return values. Only **literal** `nil`
into a `!T` slot is rejected.

See [v1 scope](https://github.com/daniel-juvito/gon/blob/v1.0.0/docs/v1-scope.md).
