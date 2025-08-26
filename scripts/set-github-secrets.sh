#!/usr/bin/env bash
set -euo pipefail

# Usage: set-github-secrets.sh [--repo owner/repo] [--project PROJECT_ID] [--provider PROVIDER_NAME]
#                                [--sa-email SA_EMAIL] [--artifact ARTIFACT_REGISTRY] [--from-tf]
#
# Examples:
#  ./scripts/set-github-secrets.sh --project thedevopsproject --provider "projects/931968123240/..." --sa-email "sa@proj.iam.gserviceaccount.com" --artifact "europe-west4-docker.pkg.dev/..."
#  ./scripts/set-github-secrets.sh --from-tf

REPO=""
PROJECT=""
PROVIDER=""
SA_EMAIL=""
ARTIFACT=""
FROM_TF=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2;;
    --project) PROJECT="$2"; shift 2;;
    --provider) PROVIDER="$2"; shift 2;;
    --sa-email) SA_EMAIL="$2"; shift 2;;
    --artifact) ARTIFACT="$2"; shift 2;;
    --from-tf) FROM_TF=1; shift 1;;
    -h|--help) echo "See header comments in the script for usage"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

command -v gh >/dev/null 2>&1 || { echo "gh CLI not found. Install GitHub CLI and authenticate (gh auth login)." >&2; exit 2; }

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner) || { echo "Failed to determine repo (specify --repo)" >&2; exit 3; }
fi

if [[ $FROM_TF -eq 1 ]]; then
  command -v terraform >/dev/null 2>&1 || { echo "terraform not found; cannot read TF outputs" >&2; exit 4; }
  command -v jq >/dev/null 2>&1 || { echo "jq not found; please install jq to parse terraform outputs" >&2; exit 5; }
  SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
  echo "Reading terraform outputs from $REPO_ROOT/infra/terraform/bootstrap..."
  TF_JSON=$(cd "$REPO_ROOT/infra/terraform/bootstrap" && terraform output -json) || { echo "terraform output failed" >&2; exit 6; }
  # Extract values if present
  PROVIDER=$(echo "$TF_JSON" | jq -r '.github_oidc_provider_name.value // empty')
  SA_EMAIL=$(echo "$TF_JSON" | jq -r '.github_actions_service_account_email.value // empty')
  PROJECT=$(echo "$TF_JSON" | jq -r '.bucket_name.value // empty')
  # ARTIFACT is not produced by TF outputs; leave it to the user if empty
fi

echo "Setting secrets on GitHub repo: $REPO"

set_secret() {
  NAME="$1"; VAL="$2"
  if [[ -z "$VAL" ]]; then
    echo "Skipping $NAME because value is empty"
    return
  fi
  echo "Setting $NAME..."
  gh secret set "$NAME" -b"$VAL" -R "$REPO"
}

# Common secrets used by CI
set_secret GCP_PROJECT_ID "$PROJECT"
set_secret GCP_OIDC_PROVIDER "$PROVIDER"
set_secret GCP_SA_EMAIL "$SA_EMAIL"
set_secret ARTIFACT_REGISTRY "$ARTIFACT"

echo "Done. Verify secrets in https://github.com/$REPO/settings/secrets/actions"
