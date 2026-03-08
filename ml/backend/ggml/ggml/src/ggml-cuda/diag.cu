#include "diag.cuh"

// Create a diagonal matrix from a 1D vector.
// Input: [n], Output: [n, n] with input on diagonal, zeros elsewhere.
static __global__ void diag_f32(const float * src, float * dst, const int64_t n) {
    const int64_t idx = (int64_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= n * n) {
        return;
    }

    const int64_t col = idx % n;
    const int64_t row = idx / n;

    dst[idx] = (col == row) ? src[col] : 0.0f;
}

static void diag_f32_cuda(const float * src, float * dst, const int64_t n, cudaStream_t stream) {
    const int64_t total = n * n;
    const int num_blocks = (total + CUDA_DIAG_BLOCK_SIZE - 1) / CUDA_DIAG_BLOCK_SIZE;
    diag_f32<<<num_blocks, CUDA_DIAG_BLOCK_SIZE, 0, stream>>>(src, dst, n);
}

void ggml_cuda_op_diag(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    const ggml_tensor * src0 = dst->src[0];
    const float * src0_d = (const float *)src0->data;
    float * dst_d = (float *)dst->data;
    cudaStream_t stream = ctx.stream();

    GGML_ASSERT(src0->type == GGML_TYPE_F32);
    GGML_ASSERT( dst->type == GGML_TYPE_F32);

    const int64_t n = src0->ne[0];

    diag_f32_cuda(src0_d, dst_d, n, stream);
}
