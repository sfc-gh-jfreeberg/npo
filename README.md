# NPO

## Setup Instructions

1. Install this branch of the Snowflake CLI in your global Python installation: `pip install git+https://github.com/snowflakedb/snowflake-cli@notebook-project`

    Run `snow --version` to check you have the right installation. This command should output a version with `.dev0`, for example: `3.16.0.dev0`.

1. `python3 -m venv .venv`
1. `source .venv/bin/activate`
1. `pip install -r requirements-prod.txt -r requirements-dev.txt`

## Local Development

1. Run the demo script: `python src/main.py`
    Other examples are also provided: `args_example.py` shows how to pass and process command-line arguments, and `udf_example.py` shows how to register and reference UDFs.
1. Run tests: `python -m pytest`

## Deployment

1. Create a stage: `snow stage create npo_stage`
1. Copy the project contents: `snow stage copy . @npo_stage`
1. Create the NPO: `snow notebook project create --name 'qs_project' –location '@npo_stage/'`
1. Execute the NPO: `snow notebook project execute -n 'qs_project'`
