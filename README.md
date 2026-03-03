# NPO

## Setup Instructions

1. Install the project dependencies: `uv sync`
2. Install the Snowflake CLI: `uv tool install git+https://github.com/snowflakedb/snowflake-cli@notebook-project`.
    If you haven't used the Snowflake CLI before, run `snow connection add` to connect the CLI to your Snowflake account.

## Local Development

1. Run the demo script: `uv run src/main.py`
    Other examples are also provided: `args_example.py` shows how to pass and process command-line arguments, and `udf_example.py` shows how to register and reference UDFs.
1. Run tests: `uv run -m pytest`


## Deployment

1. Create a stage: `snow stage create npo_stage`
1. Copy the project contents: `snow stage copy . @npo_stage`
1. Create the NPO: `snow notebook project create --name 'qs_project' –location '@npo_stage/'`
1. Execute the NPO: `snow notebook project execute -n 'qs_project'`
