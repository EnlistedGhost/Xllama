#include "tri.cuh"

// Triangular matrix: keep elements based on type, zero the rest.
// Enum values: UPPER_DIAG=0, UPPER=1, LOWER_DIAG=2, LOWER=3
static __global__ void tri_f32(const float * src, float * dst,
                               const int64_t ne0, const int64_t ne01,
                               const int64_t n_total, const int ttype) {
    const int64_t idx = (int64_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= n_total) {
        return;
    }

    const int64_t col = idx % ne0;
    const int64_t row = (idx / ne0) % ne01;

    bool keep;
    switch (ttype) {
        case 0: keep = (col >= row); break; // GGML_TRI_TYPE_UPPER_DIAG
        case 1: keep = (col >  row); break; // GGML_TRI_TYPE_UPPER
        case 2: keep = (col <= row); break; // GGML_TRI_TYPE_LOWER_DIAG
        case 3: keep = (col <  row); break; // GGML_TRI_TYPE_LOWER
        default: keep = false;
    }

    dst[idx] = keep ? src[idx] : 0.0f;
}

static void tri_f32_cuda(const float * src, float * dst, const int64_t ne0,
                          const int64_t ne01, const int64_t n_total,
                          const int ttype, cudaStream_t stream) {
    const int num_blocks = (n_total + CUDA_TRI_BLOCK_SIZE - 1) / CUDA_TRI_BLOCK_SIZE;
    tri_f32<<<num_blocks, CUDA_TRI_BLOCK_SIZE, 0, stream>>>(src, dst, ne0, ne01, n_total, ttype);
}

void ggml_cuda_op_tri(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    const ggml_tensor * src0 = dst->src[0];
    const float * src0_d = (const float *)src0->data;
    float * dst_d = (float *)dst->data;
    cudaStream_t stream = ctx.stream();

    GGML_ASSERT(src0->type == GGML_TYPE_F32);
    GGML_ASSERT( dst->type == GGML_TYPE_F32);

    int ttype;
    memcpy(&ttype, dst->op_params, sizeof(int));

    const int64_t n_total = ggml_nelements(dst);

    tri_f32_cuda(src0_d, dst_d, dst->ne[0], dst->ne[1], n_total, ttype, stream);
}
