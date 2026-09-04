#!/bin/zsh
set -euo pipefail

if (( $# == 0 )); then
  print -u2 "usage: $0 <artifact> [artifact ...]"
  exit 64
fi

shasum -a 256 "$@" > SHA256SUMS
print "Wrote SHA256SUMS for $# artifact(s)"
