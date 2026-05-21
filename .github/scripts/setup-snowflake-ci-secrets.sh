#!/usr/bin/env bash
# One-time setup: generate a CI key pair, register it on your Snowflake user,
# and push secrets to GitHub. Password auth with MFA cannot run in GitHub Actions.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
KEY_DIR="${HOME}/.snowflake/keys"
KEY_FILE="${KEY_DIR}/github_actions_rsa_key.p8"
PUB_FILE="${KEY_DIR}/github_actions_rsa_key.pub"
CONNECTIONS="${HOME}/.snowflake/connections.toml"
CONNECTION_NAME="${SNOWFLAKE_CONNECTION:-spark-connect}"

mkdir -p "$KEY_DIR"

if [[ ! -f "$KEY_FILE" ]]; then
  echo "Generating RSA key pair at ${KEY_DIR}..."
  openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out "$KEY_FILE" -nocrypt
  openssl rsa -in "$KEY_FILE" -pubout -out "$PUB_FILE"
fi

PUB_KEY="$(grep -v 'BEGIN\|END' "$PUB_FILE" | tr -d '\n')"
USER_NAME="$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^user' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"

echo "Registering public key for user ${USER_NAME} (connection: ${CONNECTION_NAME})..."
snow sql -c "$CONNECTION_NAME" -q "ALTER USER ${USER_NAME} SET RSA_PUBLIC_KEY='${PUB_KEY}';"

echo "Setting GitHub repository secrets..."
gh secret set SNOWFLAKE_PRIVATE_KEY_RAW < "$KEY_FILE"
gh secret set SNOWFLAKE_ACCOUNT --body "$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^account' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"
gh secret set SNOWFLAKE_USER --body "$USER_NAME"
gh secret set SNOWFLAKE_DATABASE --body "$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^database' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"
gh secret set SNOWFLAKE_SCHEMA --body "$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^schema' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"
gh secret set SNOWFLAKE_WAREHOUSE --body "$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^warehouse' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"
gh secret set SNOWFLAKE_ROLE --body "$(grep -A20 "\\[${CONNECTION_NAME}\\]" "$CONNECTIONS" | grep '^role' | head -1 | sed 's/.*= *"\?\([^"]*\)"\?.*/\1/')"

echo "Done. Test JWT locally (same env vars CI uses) with:"
echo "  export SNOWFLAKE_AUTHENTICATOR=SNOWFLAKE_JWT"
echo "  export SNOWFLAKE_PRIVATE_KEY_RAW=\"\$(cat ${KEY_FILE})\""
echo "  export SNOWFLAKE_ACCOUNT=... SNOWFLAKE_USER=...  # from your local connections.toml"
echo "  snow connection test -x"
