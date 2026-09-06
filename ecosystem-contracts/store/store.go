// Package store is a stand-in imported library. Its .gna file (under
// ../annotations/) attaches non-nil field and result contracts that Gon
// enforces at the call site.
package store

import "io"

// DB and Logger are opaque handles used as non-nil pointer fields.
type DB struct{}
type Logger struct{}

// Conn is the annotated struct. Per store.gna: DB and Log are "!*T",
// W is "!io.Writer".
type Conn struct {
	DB  *DB
	Log *Logger
	W   io.Writer
}

// Connect is annotated to return a non-nil *Conn ("!*Conn").
func Connect() *Conn { return &Conn{} }

// Open is annotated to return a non-nil io.Reader ("!io.Reader") — the
// interface value, not its dynamic value.
func Open() io.Reader { return nil }
