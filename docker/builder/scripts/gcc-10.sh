#!/bin/sh
# gcc-10.sh - GCC 10 library path configuration
# This script configures LD_LIBRARY_PATH for custom-built GCC 10

export LD_LIBRARY_PATH=/usr/local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
