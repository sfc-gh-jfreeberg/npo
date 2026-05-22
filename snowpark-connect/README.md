# Snowpark Connect

Template for running [Snowpark Connect for Spark](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-local-ide) workloads from a local IDE or deploying them as a Snowflake Notebook Project Object. Spark code runs on Snowflake compute; you use a standard PySpark DataFrame API locally via `snowpark-connect`.

## Prerequisites

Install the development [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) globally (outside any project virtual environment). Do not install it in the same venv as `snowpark-connect`—the two packages conflict.

```bash
pip install 'snowflake-cli @ git+https://github.com/snowflakedb/snowflake-cli@notebook-project'
```

Notebook project commands (`snow notebook project create`, `snow notebook project execute`) require this branch until the feature is in a stable release.

You will also need a Snowflake account with access to Snowpark Connect for Spark, and Python 3.10–3.12 (not 3.13+). Confirm your version:

```bash
python3 --version
```

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

From this directory, create a virtual environment and install dependencies:

```bash
cd snowpark-connect
python3 -m venv .venv
source .venv/bin/activate
pip install snowpark-connect
pip install pyspark==3.5.6
```

The `snowpark-connect` package bundles PySpark, but installing `pyspark==3.5.6` separately enables IDE features (for example, IntelliSense) and lets you import PySpark directly in your code.

## Local development

`main.py` starts a Spark session and runs a small example DataFrame:

```bash
python main.py
```

After activating the virtual environment, `python` refers to the venv interpreter. The session is created with:

```python
from snowflake import snowpark_connect

spark = snowpark_connect.init_spark_session()
```

By default, `init_spark_session()` uses the `spark-connect` entry from your connection file. You can pass `connection_parameters` instead if you prefer not to use TOML. See the [package reference](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-reference).

## Deployment

Notebook Project Objects run on Snowflake using the warehouse associated with your session. Runtime and dependencies are defined in `snow_app.yml` (Python 3.11, `requirements.txt`).

Deploy steps:

1. Pin your environment dependencies (from the activated venv):

```bash
pip freeze > requirements.txt
```

2. From this directory, set `object_name` and run the Snowflake CLI commands below (default name: `my_snowpark_connect_job`):

```bash
# Set your desired name here
object_name=my_snowpark_connect_job

# Deploy the project to Snowflake
snow notebook project create $object_name \
    --source . \
    --overwrite \
    --exclude ".venv" \
    -c spark-connect

# Execute the main.py file in the project
snow notebook project execute $object_name \
    --main-file=main.py \
    -c spark-connect
```

`snow notebook project create` uploads this directory and creates (or overwrites) the notebook project. `snow notebook project execute` runs `main.py` on Snowflake using the `spark-connect` connection.

For more on notebook projects, see [Snowflake Notebook Project Objects](https://docs.snowflake.com/en/developer-guide/snowflake-ml/notebooks-projects).
