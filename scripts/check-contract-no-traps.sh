#!/usr/bin/env bash
set -euo pipefail

contract_src="onchain/contracts/stello_pay_contract/src"

# `mock_contract.rs` is a native-only test fixture imported by integration
# tests. Its two legacy traps are intentionally retained to model an external
# upgradeable-contract failure. All deployable contract source must use typed
# PayrollError results or `panic_with_error!` instead.
violations=$(rg -n '\.unwrap\(\)|\.expect\(|panic!' \
  "$contract_src" \
  --glob '*.rs' \
  --glob '!**/tests/**' \
  --glob '!**/src/tests/**' \
  --glob '!mock_contract.rs' || true)

if [[ -n "$violations" ]]; then
  printf 'Unguarded trap found in deployable payroll source:\n%s\n' "$violations" >&2
  exit 1
fi
