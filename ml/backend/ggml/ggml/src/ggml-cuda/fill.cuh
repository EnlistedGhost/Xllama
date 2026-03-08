#include "common.cuh"

#define CUDA_FILL_BLOCK_SIZE 256

void ggml_cuda_op_fill(ggml_backend_cuda_context & ctx, ggml_tensor * dst);
