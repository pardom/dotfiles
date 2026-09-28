#!/usr/bin/env bash
# Shared registered entry point. A permitted stop is not successful verification.
set -uo pipefail
if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' '{"decision":"block","reason":"verify-on-stop requires python3; install Python 3 and rerun the project gate."}'
  exit 0
fi
exec python3 "$(dirname "$0")/verify-on-stop.py"
