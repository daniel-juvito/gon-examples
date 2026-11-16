package billing

import "fmt"

// Describe is plain Go (no .gon source). Package mode loads it as it is, so the
// .gon files can call it.
func Describe(o *Order) string {
	return fmt.Sprintf("order %d for %s", o.ID, o.Customer.Name)
}
