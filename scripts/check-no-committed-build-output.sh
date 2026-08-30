#!/usr/bin/env bash
set -euo pipefail

# Cargo normally writes to a directory named `target`, but checking only that
# name is easy to bypass accidentally when a tool overrides CARGO_TARGET_DIR.
# The marker files below are Cargo-specific and catch renamed/custom output
# directories as well as the conventional path.
violations=()
while IFS= read -r -d '' path; do
  case "$path" in
    target/*|*/target/*|*/.fingerprint/*|*/.rustc_info.json|*/CACHEDIR.TAG|*/.cargo-artifact-lock|*/.cargo-build-lock|*/.cargo-lock)
      violations+=("$path")
      ;;
  esac
done < <(git ls-files -z)

if (( ${#violations[@]} > 0 )); then
  printf 'Committed Cargo build output detected (%d path(s)):\n' "${#violations[@]}" >&2
  printf '  %s\n' "${violations[@]}" >&2
  printf '\nRemove generated output from the index and keep it ignored.\n' >&2
  exit 1
fi

printf 'No committed Cargo build output detected.\n'
