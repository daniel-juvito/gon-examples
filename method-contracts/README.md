# method-contracts

Gon **v1.11** (M7): a `!` written on a **method's** parameter or result is
enforced at its callers, like a plain function's. Until v1.11 only the method's
own body was checked; none of the ways to call it was.

```bash
gon check methods.gon
# methods.gon:24:9:  error   GN001: cannot pass nil as non-nil argument 1 to Queue.Push
# methods.gon:25:9:  error   GN001: cannot pass nil as non-nil argument 1 to Queue.Push
# methods.gon:26:9:  error   GN001: cannot pass nil as non-nil argument 1 to Pusher.Push
# methods.gon:27:19: error   GN001: cannot pass nil as non-nil argument 1 to Queue.Push
# methods.gon:31:5:  warning GW001: t is non-nil; comparison with nil is always false
# exit 1   (4 errors, 1 warning)
```

Gon v1.10 reports nothing on the same file (`ok`, exit 0).

## What it shows

- **Matched by object identity, never by name.** `Stack.Push` has no `!`, so
  `s.Push(nil)` is accepted even though `Queue.Push` shares the name.
- **Every call form that `go/types` resolves to a declaration:** a direct call
  (`q.Push(nil)`), a call **promoted through embedding** (`w.Push(nil)` resolves
  to `Queue.Push`), a call **through an interface** (`p.Push(nil)`: the
  interface's own `!` applies; an implementing method need not repeat it) and a
  **method expression** (`(*Queue).Push(q, nil)`).
- **A `!` result is a non-nil source.** `t := q.Pop(); t == nil` is **GW001**.
- **A method value carries nothing.** `push := q.Push; push(nil)` is not
  checked: contracts are not followed through values (no flow analysis).
- Scope is the files checked together: this file in file mode, or every `.gon`
  file of the package in package mode (`gon check <dir>`, v1.10).

Not part of v1.11: a `!` on the receiver itself (`.gna` `receivers:` stays
reserved), and contracts read from another package's `.gon` source.
