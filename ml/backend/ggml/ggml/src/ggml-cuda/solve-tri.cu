#include "solve-tri.cuh"

// Triangular solve: solve A * X = B for X, where A is lower triangular.
// Each thread handles one column of the RHS for one batch.
// Forward substitution: x[i] = (b[i] - sum(A[i,j]*x[j], j<i)) / A[i,i]
//
// A: [n, n, batch0, batch1]
// B: [n, k, batch0, batch1]
// X: [n, k, batch0, batch1]
static __global__ void solve_tri_f32(const float * A, const float * B, float * X,
                                     const int64_t n, const int64_t k,
                                     const int64_t total_cols) {
    const int64_t idx = (int64_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= total_cols) {
        return;
    }

    // idx = batch_idx * k + col
    const int64_t batch_idx = idx / k;
    const int64_t col = idx % k;

    const float * A_batch = A + batch_idx * n * n;
    const float * B_batch = B + batch_idx * n * k;
    float * X_batch = X + batch_idx * n * k;

    // Forward substitution
    for (int64_t i = 0; i < n; i++) {
        float sum = 0.0f;
        for (int64_t j = 0; j < i; j++) {
            sum += A_batch[i * n + j] * X_batch[j * k + col];
        }
        const float diag = A_batch[i * n + i];
        X_batch[i * k + col] = (B_batch[i * k + col] - sum) / diag;
    }
}

static void solve_tri_f32_cuda(const float * A, const float * B, float * X,
                                const int64_t n, const int64_t k,
                                const int64_t total_cols, cudaStream_t stream) {
    const int num_blocks = (total_cols + CUDA_SOLVE_TRI_BLOCK_SIZE - 1) / CUDA_SOLVE_TRI_BLOCK_SIZE;
    solve_tri_f32<<<num_blocks, CUDA_SOLVE_TRI_BLOCK_SIZE, 0, stream>>>(A, B, X, n, k, total_cols);
}

void ggml_cuda_op_solve_tri(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    const ggml_tensor * src0 = dst->src[0]; // A (triangular matrix)
    const ggml_tensor * src1 = dst->src[1]; // B (RHS)
    const float * src0_d = (const float *)src0->data;
    const float * src1_d = (const float *)src1->data;
    float * dst_d = (float *)dst->data;
    cudaStream_t stream = ctx.stream();

    GGML_ASSERT(src0->type == GGML_TYPE_F32);
    GGML_ASSERT(src1->type == GGML_TYPE_F32);
    GGML_ASSERT( dst->type == GGML_TYPE_F32);

    const int64_t k = src1->ne[0]; // number of RHS columns
    const int64_t n = src1->ne[1]; // matrix size (A is n x n)
    const int64_t batch = src0->ne[2] * src0->ne[3];
    const int64_t total_cols = batch * k;

    solve_tri_f32_cuda(src0_d, src1_d, dst_d, n, k, total_cols, stream);
}
