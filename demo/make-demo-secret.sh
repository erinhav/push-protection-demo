#!/usr/bin/env bash
#
# Generates a SYNTHETIC Hugging Face-format user access token for the demo.
#
# The output matches the detection pattern but is random and worthless — there
# is nothing to revoke and nothing to leak. Push protection matches on pattern,
# not validity, so this produces exactly the same block as a live credential.
#
# The prefix is assembled at run time so that this script itself contains no
# matching string and can be committed safely.

set -euo pipefail

# Note: the token body is letters only — `[a-zA-Z]{34}`, no digits. Including
# digits yields a string that *looks* right but is not detected, so the push
# would silently succeed. This was found the hard way; see SCRIPT.md Appendix A.
#
# Note: read a bounded chunk first, and finish with `cut` rather than `head`.
# `head -c` closes the pipe early, killing `tr` with SIGPIPE, which trips
# `pipefail` and silently yields an empty token.
PREFIX="h""f_"
BODY="$(head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z' | cut -c1-34)"

printf '%s%s\n' "$PREFIX" "$BODY"
