#!/usr/bin/env bash
set -euo pipefail

PASS_COUNT=0
FAIL_COUNT=0

pass() { echo "PASS: $*"; PASS_COUNT=$((PASS_COUNT+1)); }
fail() { echo "FAIL: $*"; FAIL_COUNT=$((FAIL_COUNT+1)); }
section() { echo; echo "== $* =="; }

section "1) Non-loopback listener check (openclaw/node)"
LISTEN_LINES="$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null || true)"
OFFENDERS="$(printf '%s\n' "$LISTEN_LINES" | awk 'NR>1 && ($1 ~ /openclaw|node/) && ($9 ~ /(^|[^0-9])(\*|0\.0\.0\.0):[0-9]+$/ || $9 ~ /^\[::\]:[0-9]+$/)')"
if [[ -n "$OFFENDERS" ]]; then
  fail "Found openclaw/node listeners on non-loopback bind addresses:" 
  printf '%s\n' "$OFFENDERS"
else
  pass "No openclaw/node listeners bound to 0.0.0.0, *, or [::]."
fi

section "2) Gateway loopback port checks (18789, 18791, 18792)"
check_port_loopback() {
  local port="$1"
  local out
  out="$(lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -z "$(printf '%s\n' "$out" | awk 'NR>1')" ]]; then
    fail "Port $port is not LISTENING."
    return
  fi

  local non_loop
  non_loop="$(printf '%s\n' "$out" | awk 'NR>1 && !($9 ~ /(127\.0\.0\.1|localhost):'"$port"'$/ || $9 ~ /^\[::1\]:'"$port"'$/)')"
  if [[ -n "$non_loop" ]]; then
    fail "Port $port is listening, but not strictly on loopback:" 
    printf '%s\n' "$non_loop"
  else
    pass "Port $port LISTEN is loopback-only (127.0.0.1/::1)."
  fi
}

check_port_loopback 18789
check_port_loopback 18791
check_port_loopback 18792

section "3) GitHub CLI auth status"
if gh auth status >/dev/null 2>&1; then
  pass "gh auth status OK (logged in)."
else
  fail "gh auth status failed (not logged in or auth unavailable)."
fi

section "4) Hook enablement in ~/.openclaw/openclaw.json"
CONFIG_PATH="$HOME/.openclaw/openclaw.json"
if [[ ! -f "$CONFIG_PATH" ]]; then
  fail "Config file missing: $CONFIG_PATH"
else
  PY_OUT="$(python3 - "$CONFIG_PATH" << 'PY'
import json, sys
path = sys.argv[1]
required = ["token-budget-guard", "image-confirm-guard", "retry-policy-guard"]

try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception as e:
    print("ERROR: could not parse config:", e)
    sys.exit(2)

hooks = cfg.get("hooks")
state = {k: False for k in required}

def mark(name, enabled):
    if name in state and enabled:
        state[name] = True

# Existing supported structures under top-level "hooks"
if isinstance(hooks, list):
    for h in hooks:
        if isinstance(h, str):
            mark(h, True)
        elif isinstance(h, dict):
            name = h.get("name") or h.get("id") or h.get("hook")
            enabled = h.get("enabled", True)
            mark(name, bool(enabled))
elif isinstance(hooks, dict):
    for name, val in hooks.items():
        if isinstance(val, dict):
            enabled = bool(val.get("enabled", True))
        elif isinstance(val, bool):
            enabled = val
        else:
            enabled = bool(val)
        mark(name, enabled)

# Also support nested structure: hooks.internal.entries.<hook>.enabled
nested_entries = None
if isinstance(hooks, dict):
    internal = hooks.get("internal")
    if isinstance(internal, dict):
        entries = internal.get("entries")
        if isinstance(entries, dict):
            nested_entries = entries

if isinstance(nested_entries, dict):
    for name, val in nested_entries.items():
        if isinstance(val, dict):
            enabled = bool(val.get("enabled", True))
        elif isinstance(val, bool):
            enabled = val
        else:
            enabled = bool(val)
        mark(name, enabled)

missing = [k for k, v in state.items() if not v]
if missing:
    print("MISSING:", ", ".join(missing))
    sys.exit(1)
print("OK")
PY
)" || true

  if [[ "$PY_OUT" == "OK" ]]; then
    pass "All required hooks are enabled in openclaw.json."
  else
    fail "Hook enablement check failed: $PY_OUT"
  fi
fi

section "Summary"
printf 'PASS: %d\n' "$PASS_COUNT"
printf 'FAIL: %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "RESULT: FAIL"
  exit 1
else
  echo "RESULT: PASS"
  exit 0
fi
