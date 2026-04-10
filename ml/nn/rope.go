package nn

import (
	"github.com/ollama/ollama/ml"
	"github.com/ollama/ollama/ml/nn/fast"
	"github.com/ollama/ollama/ml/nn/rope"
)

// RoPE applies rotary positional embedding to tensor t.
// This delegates to the fast (fused) implementation.
func RoPE(ctx ml.Context, t, positions ml.Tensor, dim int, base, scale float32, options ...func(*rope.Options)) ml.Tensor {
	return fast.RoPE(ctx, t, positions, dim, base, scale, options...)
}
