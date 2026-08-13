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

# Note: read a bounded chunk first, and finish with `cut` rather than `head`.
# `head -c` closes the pipe early, which kills `tr` with SIGPIPE and trips
# `pipefail`, silently yielding an empty token.
PREFIX="h""f_"
BODY="$(head -c 2048 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | cut -c1-34)"

printf '%s%s\n' "$PREFIX" "$BODY"
