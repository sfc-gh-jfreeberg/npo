#!/usr/bin/env bash
# Generate requirements files from a clean venv install (portable across machines/CI).
set -euo pipefail

project="${1:?Usage: generate-requirements.sh <snowpark|snowpark-connect>}"

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
project_dir="${repo_root}/${project}"
venv_dir="${project_dir}/.venv"

# Prefer an explicit interpreter (CI sets this via setup-python); otherwise pick 3.12+.
if [[ -z "${PYTHON:-}" ]]; then
  case "${project}" in
    snowpark-connect) candidates=(python3.11 python3.12 python3.10 python3) ;;
    *) candidates=(python3.12 python3.11 python3.10 python3) ;;
  esac
  for candidate in "${candidates[@]}"; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      PYTHON="${candidate}"
      break
    fi
  done
fi
PYTHON="${PYTHON:?No suitable python3 found}"

rm -rf "${venv_dir}"
"${PYTHON}" -m venv "${venv_dir}"
# shellcheck source=/dev/null
source "${venv_dir}/bin/activate"

pip install --upgrade pip

case "${project}" in
  snowpark)
    pip install snowflake-snowpark-python
    pip install pytest
    pip freeze > "${project_dir}/requirements.txt"
    ;;
  snowpark-connect)
    pip install 'snowpark-connect[jdk]' 'pyspark==3.5.6'
    pip freeze > "${project_dir}/requirements.txt"
    ;;
  *)
    echo "Unknown project: ${project}" >&2
    exit 1
    ;;
esac

deactivate
echo "Generated requirements in ${project_dir}/"
