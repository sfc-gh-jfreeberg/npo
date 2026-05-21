# Snowpark Connect with uv

Template for running [Snowpark Connect for Spark](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-local-ide) workloads from a local IDE or deploying them as a Snowflake Notebook Project Object. Spark code runs on Snowflake compute; you use a standard PySpark DataFrame API locally via `snowpark-connect`. Dependencies are managed with [uv](https://docs.astral.sh/uv/) and `pyproject.toml`.

## Prerequisites

Install the development [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) as a [uv tool](https://docs.astral.sh/uv/guides/tools/) (isolated from the project `.venv`):

```bash
uv tool install git+https://github.com/snowflakedb/snowflake-cli@notebook-project
```

If `snow` is not on your `PATH`, run `uv tool update-shell` and restart your terminal.

Notebook project commands (`snow notebook project create`, `snow notebook project execute`) require this branch until the feature is in a stable release.

- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- A Snowflake account with access to Snowpark Connect for Spark
- Python 3.11 or 3.12 (required by `pyproject.toml`; not 3.13+). uv can install a managed runtime with `--managed-python`

## Connection configuration

Snowpark Connect reads credentials from a TOML connection file. This template expects a connection named `spark-connect` (passed as `-c spark-connect` when deploying).

### Option 1: Snowflake CLI

```bash
snow connection add
```

When prompted, use `spark-connect` as the connection name. Verify it works:

```bash
snow connection test --connection spark-connect
```

### Option 2: Manual `connections.toml`

Create or edit `~/.snowflake/connections.toml` (restrict permissions to the owner):

```bash
chmod 0600 ~/.snowflake/connections.toml
```

```toml
[spark-connect]
host="my_account.snowflakecomputing.com"
account="my_account"
user="my_user"
password="my_password"
warehouse="my_wh"
database="my_db"
schema="public"
```

See the [local IDE setup guide](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-local-ide) for full connection options.

## Install and setup

From this directory, sync the project environment (creates `.venv` and installs dependencies from `pyproject.toml`):

```bash
cd snowpark-connect-uv
uv sync --managed-python
```

The `snowpark-connect` package bundles PySpark, but `pyproject.toml` also pins `pyspark==3.5.6` for IDE features (for example, IntelliSense) and direct PySpark imports in your code.

Runtime dependencies for Snowflake deploys are read from `pyproject.toml` (see `snow_app.yml`).

Do not install the Snowflake CLI in the same environment as `snowpark-connect`—the two packages conflict. Use `uv tool install` for the CLI instead.

## Local development

`main.py` starts a Spark session and runs a small example DataFrame:

```bash
uv run main.py
```

The session is created with:

```python
from snowflake import snowpark_connect

spark = snowpark_connect.init_spark_session()
```

By default, `init_spark_session()` uses the `spark-connect` entry from your connection file. You can pass `connection_parameters` instead if you prefer not to use TOML. See the [package reference](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-reference).

## Deployment

Notebook Project Objects run on Snowflake using the warehouse associated with your session. Runtime and dependencies are defined in `snow_app.yml` (Python 3.11, `pyproject.toml`).

Deploy steps:

1. Update `pyproject.toml` (and run `uv lock` if needed) when you add dependencies.

2. From this directory, set `object_name` and run the Snowflake CLI commands below (defaults: `my_snowpark_connect_uv_job`, `spark-connect`):

```bash
object_name=my_snowpark_connect_uv_job
connection=spark-connect

snow notebook project create "$object_name" \
    --source . \
    --overwrite \
    -c "$connection"

snow notebook project execute "$object_name" \
    --main-file=main.py \
    -c "$connection"
```

`snow notebook project create` uploads this directory and creates (or overwrites) the notebook project. `snow notebook project execute` runs `main.py` on Snowflake using the `spark-connect` connection.

For more on notebook projects, see [Snowflake Notebook Project Objects](https://docs.snowflake.com/en/developer-guide/snowflake-ml/notebooks-projects).
