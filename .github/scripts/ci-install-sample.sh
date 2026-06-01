#!/usr/bin/env bash
# Install each sample exactly as documented in its README, then freeze when `code_bundle.yml`
# declares `dependencies: requirements.txt`.
set -euo pipefail

# GitHub-hosted runners expose `python` after setup-python; macOS often only ships `python3`.
if command -v python >/dev/null 2>&1; then
	PY=python
elif command -v python3 >/dev/null 2>&1; then
	PY=python3
else
	echo "Neither python nor python3 found on PATH" >&2
	exit 1
fi

project="${1:?Usage: ci-install-sample.sh <snowpark|snowpark-connect|snowpark-uv|snowpark-connect-uv>}"
repo_root="${GITHUB_WORKSPACE:-$(cd "$(dirname "$0")/../.." && pwd)}"
proj_dir="${repo_root}/${project}"

cd "${proj_dir}"

case "${project}" in
  snowpark)
    # README: python3 -m venv .venv; pip install snowflake-snowpark-python; pip install pytest
    "${PY}" -m venv .venv
    .venv/bin/pip install snowflake-snowpark-python pytest
    .venv/bin/pip freeze >requirements.txt
    .venv/bin/pytest -q
    ;;
  snowpark-connect)
    # README: venv + snowpark-connect[jdk] + pyspark==3.5.6; deploy pins with pip freeze
    "${PY}" -m venv .venv
    .venv/bin/pip install --upgrade pip
    .venv/bin/pip install --upgrade --force-reinstall snowpark-connect
    .venv/bin/pip install pyspark==3.5.6
    .venv/bin/pip freeze >requirements.txt
    .venv/bin/python -c 'from snowflake import snowpark_connect; import pyspark'
    ;;
  snowpark-uv)
    uv sync --managed-python
    uv run pytest -q
    ;;
  snowpark-connect-uv)
    uv sync --managed-python
    uv run python -c 'from snowflake import snowpark_connect; import pyspark'
    ;;
  *)
    echo "Unknown project: ${project}" >&2
    exit 1
    ;;
esac
