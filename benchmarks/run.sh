#!/usr/bin/env bash
benchmarks=$(pwd)/$( dirname "${BASH_SOURCE[0]}" )/*

for benchmark in $benchmarks
do
  if ! [[ "${benchmark#*.}" =~ (rb|sh)$ ]]; then
    $benchmark
    echo "================================================================================="
    echo ""
  fi
done
