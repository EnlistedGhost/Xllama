#!/bin/sh
# go-1.24.2.sh - Go 1.24.2 environment configuration
# This script adds Go 1.24.2 binary directory to PATH

export PATH=/usr/local/go/bin${PATH:+:${PATH}}
