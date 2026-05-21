# Snowpark with uv

Template for running [Snowpark for Python](https://docs.snowflake.com/en/developer-guide/snowpark/python/setup) locally or deploying as a Snowflake Notebook Project Object. Dependencies are managed with [uv](https://docs.astral.sh/uv/) and `pyproject.toml`.

## Prerequisites

Install the development [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) as a [uv tool](https://docs.astral.sh/uv/guides/tools/) (isolated from the project `.venv`):

```bash
uv tool install git+https://github.com/snowflakedb/snowflake-cli@notebook-project
```

If `snow` is not on your `PATH`, run `uv tool update-shell` and restart your terminal.

Notebook project commands (`snow notebook project create`, `snow notebook project execute`) require this branch until the feature is in a stable release.

- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- A Snowflake account
- Python 3.12 (required by `pyproject.toml`). uv can install a managed runtime with `--managed-python`

## Connection configuration

Snowpark sessions use a TOML connection file. This template expects a connection named `snowpark` (passed as `-c snowpark` when deploying). Use the same name in `src/main.py` for local runs.

### Option 1: Snowflake CLI

```bash
snow connection add
```

When prompted, use `snowpark` as the connection name. Verify it works:

```bash
snow connection test --connection snowpark
```

### Option 2: Manual `connections.toml`

Create or edit `~/.snowflake/connections.toml` (restrict permissions to the owner):

```bash
chmod 0600 ~/.snowflake/connections.toml
```

```toml
[snowpark]
host="my_account.snowflakecomputing.com"
account="my_account"
user="my_user"
password="my_password"
warehouse="my_wh"
database="my_db"
schema="public"
```

See [Configure Snowflake connections](https://docs.snowflake.com/en/developer-guide/snowflake-cli/connecting/configure-connections) and [Creating a Snowpark session](https://docs.snowflake.com/en/developer-guide/snowpark/python/creating-session).

## Install and setup

From this directory, sync the project environment (creates `.venv` and installs dependencies from `pyproject.toml`):

```bash
cd snowpark-uv
uv sync --managed-python
```

To add development tools (for example, `pytest`):

```bash
uv add --dev pytest
```

Runtime dependencies for Snowflake deploys are read from `pyproject.toml` (see `snow_app.yml`).

## Local development

```bash
uv run src/main.py
```

The script creates a Snowpark `Session` and queries `INFORMATION_SCHEMA.QUERY_HISTORY()`:

```python
from snowflake.snowpark import Session

connection_name = "snowpark"
session = Session.builder.configs({"connection_name": connection_name}).getOrCreate()
```

Run tests (after adding `pytest` as a dev dependency):

```bash
uv run pytest
```

Additional examples live under `src/` (`udf_example.py`, `args_example.py`).

## Deployment

Notebook Project Objects run on Snowflake using the warehouse associated with your session. Runtime and dependencies are defined in `snow_app.yml` (Python 3.12, `pyproject.toml`).

Deploy steps:

1. Update `pyproject.toml` (and run `uv lock` if needed) when you add dependencies.

2. From this directory, set `object_name` and run the Snowflake CLI commands below (defaults: `my_snowpark_job`, `snowpark`):

```bash
object_name=my_snowpark_job
connection=snowpark

snow notebook project create "$object_name" \
    --source . \
    --overwrite \
    -c "$connection"

snow notebook project execute "$object_name" \
    --main-file=src/main.py \
    -c "$connection"
```

`snow notebook project create` uploads this directory and creates (or overwrites) the notebook project. `snow notebook project execute` runs `src/main.py` on Snowflake using the `snowpark` connection.

For more on notebook projects, see [Snowflake Notebook Project Objects](https://docs.snowflake.com/en/developer-guide/snowflake-ml/notebooks-projects).
