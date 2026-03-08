#include "fill.cuh"

static __global__ void fill_f32(float * dst, const float value, const int64_t n) {
    const int64_t idx = (int64_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= n) {
        return;
    }
    dst[idx] = value;
}

static void fill_f32_cuda(float * dst, const float value, const int64_t n, cudaStream_t stream) {
    const int num_blocks = (n + CUDA_FILL_BLOCK_SIZE - 1) / CUDA_FILL_BLOCK_SIZE;
    fill_f32<<<num_blocks, CUDA_FILL_BLOCK_SIZE, 0, stream>>>(dst, value, n);
}

void ggml_cuda_op_fill(ggml_backend_cuda_context & ctx, ggml_tensor * dst) {
    float * dst_d = (float *)dst->data;
    cudaStream_t stream = ctx.stream();

    GGML_ASSERT(dst->type == GGML_TYPE_F32);

    float value;
    memcpy(&value, dst->op_params, sizeof(float));

    fill_f32_cuda(dst_d, value, ggml_nelements(dst), stream);
}
