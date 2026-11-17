# return-contracts

Gon **v1.13**: the operands of a `return` are checked like every other
expression, and a function literal is checked as a function.

```bash
gon check returns.gon
# returns.gon:15:19: error   GN001: cannot assign nil to non-nil field Job.Task
# returns.gon:19:9:  error   GN002: missing required non-nil field Job.Task
# returns.gon:23:13: error   GN001: cannot pass nil as non-nil argument 1 to Run
# returns.gon:27:9:  warning GW001: t is non-nil; comparison with nil is always false
# returns.gon:41:10: error   GN001: cannot return nil from function with non-nil return type
# exit 1   (4 errors, 1 warning)
```

Gon v1.12 reports nothing on the same file (`ok`, exit 0).

## What it shows

- **Return operands** (v1.13). `return Job{Task: nil}`, `return Job{}`,
  `return Run(nil)` and `return t == nil` are reported exactly as
  `_ = Job{Task: nil}`, `_ = Job{}`, `Run(nil)` and `_ = t == nil` always were.
  Before, `return` was the one position that was skipped (measured: 1 of 17).
- **A function literal is a function.** `shadowed` returns a closure whose
  parameter `t` shadows the outer `!*Task` parameter `t`: `t == nil` inside it is
  fine (no diagnostic). Before v1.13 it was mistaken for the outer `t`.
  `closureResult` returns a closure whose result is `!*Task`; its `return nil` is
  **GN001**, against the closure's own contract.

Not changed: what a contract means, and flow analysis (none).
