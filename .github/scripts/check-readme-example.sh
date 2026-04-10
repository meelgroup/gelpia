#!/usr/bin/env bash

set -euo pipefail

readonly readme_function='x=[1,10]; y=[5,15]; x^2 + x*y + y*sin(x/10)'
readonly expected_output=$'Maximum lower bound 262.6220647721184\nMaximum upper bound 262.6220647721185'

raw_output="$(./bin/gelpia --function "$readme_function")"
filtered_output="$(printf '%s\n' "$raw_output" | sed '/^Solver calls /d')"

printf '%s\n' "$raw_output"

if [[ "$filtered_output" != "$expected_output" ]]; then
  echo
  echo "README example output mismatch."
  echo "Expected:"
  printf '%s\n' "$expected_output"
  echo
  echo "Actual:"
  printf '%s\n' "$filtered_output"
  exit 1
fi
