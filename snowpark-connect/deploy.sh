#!/usr/bin/env bash
set -euo pipefail

object_name=my_snowpark_connect_job
connection="${SNOWFLAKE_CONNECTION:-spark-connect}"

if [[ "${SNOWFLAKE_CI:-}" == "true" ]]; then
  conn_args=(-x)
else
  conn_args=(-c "$connection")
fi

snow notebook project create "$object_name" \
    --source . \
    --overwrite \
    --exclude ".venv" \
    "${conn_args[@]}"

snow notebook project execute "$object_name" \
    --main-file=main.py \
    "${conn_args[@]}"
