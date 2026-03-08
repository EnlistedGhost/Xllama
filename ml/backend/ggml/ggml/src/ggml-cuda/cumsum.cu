#include "cumsum.cuh"

// Cumulative sum along the first dimension (each row independently).
// Each block processes one row sequentially (prefix sum is inherently serial per row).
static __global__ void cumsum_f32(const float * src, float * dst, const int64_t nc, const int64_t nr) {
    const int64_t row = (int64_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= nr) {
        return;
    }

    const float * s = src + row * nc;
    float * d = dst + row * nc;

    float sum = 0.0f;
    for (int64_t i = 0; i < nc; i++) {
        sum += s[i];
        d[i] = sum;
    }
}

static void cumsum_f32_cuda(const float * src, float * dst, const int64_t nc, const int64_t nr, cudaStream_t stream) {
    const int num_blocks = (nr + CUDA_CUMSUM_BLOCK_SIZE - 1) / CUDA_CUMSUM_BLOCK_SIZE;
    cumsum_f32<<<num_blocks, CUDA_CUMSUM_BLOCK_SIZE, 0, stream>>>(src, dst, nc, nr);
}

void ggml_cuda_op_cumsum(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    const ggml_tensor * src0 = dst->src[0];
    const float * src0_d = (const float *)src0->data;
    float * dst_d = (float *)dst->data;
    cudaStream_t stream = ctx.stream();

    GGML_ASSERT(src0->type == GGML_TYPE_F32);
    GGML_ASSERT( dst->type == GGML_TYPE_F32);
    GGML_ASSERT(ggml_is_contiguous(src0));

    const int64_t nc = src0->ne[0];
    const int64_t nr = ggml_nrows(src0);

    cumsum_f32_cuda(src0_d, dst_d, nc, nr, stream);
}
