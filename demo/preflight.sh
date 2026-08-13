#!/usr/bin/env bash
#
# Run this before every demo. It takes two seconds and catches the failure
# modes that are invisible until you are already in front of an audience.
#
# The dangerous failures here are not loud errors — they are a push that
# quietly SUCCEEDS. If push protection is off, or the demo token doesn't match
# the detection pattern, the secret sails through and the demo shows the
# opposite of the intended message.
#
# Usage: ./demo/preflight.sh [owner/repo]

set -uo pipefail

REPO="${1:-erinhav/push-protection-demo}"
fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }

echo "Preflight for $REPO"
echo

# 1. Push protection must be enabled, or the push silently succeeds.
status="$(gh api "repos/$REPO" --jq '.security_and_analysis.secret_scanning_push_protection.status' 2>/dev/null)"
[ "$status" = "enabled" ] && ok "push protection: enabled" \
                          || bad "push protection: ${status:-unknown} — the demo will NOT block"

# 2. Secret scanning underpins it.
ss="$(gh api "repos/$REPO" --jq '.security_and_analysis.secret_scanning.status' 2>/dev/null)"
[ "$ss" = "enabled" ] && ok "secret scanning: enabled" \
                      || bad "secret scanning: ${ss:-unknown}"

# 3. A clean start matters: the payoff shot is an empty security tab.
alerts="$(gh api "repos/$REPO/secret-scanning/alerts" --jq 'length' 2>/dev/null)"
[ "$alerts" = "0" ] && ok "open alerts: 0" \
                    || bad "open alerts: ${alerts:-?} — resolve before demoing"

# 4. The generated token must match the pattern, or nothing fires.
#    Body is [a-zA-Z]{34}. Digits look plausible but are NOT detected.
tok="$(./demo/make-demo-secret.sh 2>/dev/null)"
if printf '%s' "$tok" | grep -qE '^hf_[A-Za-z]{34}$'; then
  ok "demo token: correct shape (letters-only body, 34 chars)"
else
  bad "demo token: WRONG shape [len ${#tok}] — it will not be detected"
fi

# 5. A dirty tree turns step 3 into a confusing diff.
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  ok "working tree: clean"
else
  bad "working tree: dirty — commit or stash first"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "Ready to demo."
else
  echo "NOT ready — fix the above first." >&2
  exit 1
fi
