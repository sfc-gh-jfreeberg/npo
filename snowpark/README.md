# Snowpark

Template for running [Snowpark for Python](https://docs.snowflake.com/en/developer-guide/snowpark/python/setup) locally or deploying as a Snowflake Notebook Project Object. Install dependencies into a virtual environment (`pip install` as shown below); the Notebook Project deployment uses pinned dependencies in `requirements.txt` (`pip freeze` after install).

## Prerequisites

Install the development [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) globally (outside any project virtual environment):

```bash
pip install 'snowflake-cli @ git+https://github.com/snowflakedb/snowflake-cli@notebook-project'
```

Notebook project commands (`snow notebook project create`, `snow notebook project execute`) require this branch until the feature is in a stable release.

Confirm you are using Python 3.10–3.12. Confirm your version:

```bash
python3 --version
```

## Connection configuration

Snowpark sessions use a TOML connection file. This template expects a connection named `snowpark` (passed as `-c snowpark` when deploying). For local runs, use the same name in `src/main.py`, or override deploy with the `SNOWFLAKE_CONNECTION` environment variable.

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

From this directory, create a virtual environment and install dependencies:

```bash
cd snowpark
python3 -m venv .venv
source .venv/bin/activate
pip install snowflake-snowpark-python
pip install pytest
```

## Local development

From this directory, run:

```bash
python src/main.py
```

The script creates a Snowpark `Session` and queries `INFORMATION_SCHEMA.QUERY_HISTORY()`:

```python
from snowflake.snowpark import Session

connection_name = "snowpark"
session = Session.builder.configs({"connection_name": connection_name}).getOrCreate()
```

Run tests from this directory:

```bash
pytest
```

Additional examples live under `src/` (`udf_example.py`, `args_example.py`).

## Deployment

Notebook Project Objects run on Snowflake using the warehouse associated with your session. Runtime and dependencies are defined in `snow_app.yml` (Python 3.12, `requirements.txt`).

Deploy steps:

1. Freeze your virtual environment:

    ```python
    pip freeze > requirements.txt
    ```

2. From this directory, set `object_name` (and optionally `connection`) and run the Snowflake CLI commands below (defaults: `my_python_project`, `snowpark`):

```bash
object_name=my_python_project
connection=snowpark

snow notebook project create "$object_name" \
    --source . \
    --overwrite \
    --exclude ".venv" \
    -c "$connection"

snow notebook project execute "$object_name" \
    --main-file=src/main.py \
    -c "$connection"
```

`snow notebook project create` uploads this directory and creates (or overwrites) the notebook project. `snow notebook project execute` runs `src/main.py` on Snowflake using the `snowpark` connection.

For more on notebook projects, see [Snowflake Notebook Project Objects](https://docs.snowflake.com/en/developer-guide/snowflake-ml/notebooks-projects).
