#!/usr/bin/env bash
set -euo pipefail
# Print a JSON object with the current gcloud access token (or empty token)
TOKEN=""
if command -v gcloud >/dev/null 2>&1; then
  TOKEN=$(gcloud auth print-access-token 2>/dev/null || true)
fi
printf '{"token":"%s"}' "$TOKEN"
