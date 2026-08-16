# struct-fields

Expected failures for required non-nil fields.

```bash
gon check fields.gon
# fields.gon:9:6: error GN002: struct literal of Config missing required non-nil field Name
# fields.gon:10:18: error GN001: cannot assign nil to non-nil field Config.Name
```
