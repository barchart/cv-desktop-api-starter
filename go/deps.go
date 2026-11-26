// The scripts in examples/ and my-scripts/ carry the "ignore" build tag, so
// `go mod tidy` doesn't see what they import. This file keeps the Openfeed SDK
// in go.mod for them.
package deps

import _ "github.com/openfeed-org/sdk-go/openfeed"
