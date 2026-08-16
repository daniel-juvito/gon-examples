# reject-nil

Expected failure: literal `nil` passed to a non-nil parameter.

```bash
gon check reject.gon
# reject.gon:6:8: error GN001: cannot pass nil as non-nil argument 1 to greet
```

Exit code **1**.
