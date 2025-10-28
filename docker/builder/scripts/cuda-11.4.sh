#!/bin/sh
# cuda-11.4.sh - CUDA 11.4 environment configuration for Tesla K80 support
# This script configures PATH and LD_LIBRARY_PATH for CUDA 11.4 toolkit

export PATH=/usr/local/cuda-11.4/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
