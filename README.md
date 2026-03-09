# NPO

## Setup Instructions

1. `python3 -m venv .venv`
1. `source .venv/bin/activate`
1. `pip install -r requirements-prod.txt -r requirements-dev.txt`

    `requirements-dev.txt` will install the Snowflake CLI. If you haven't used the Snowflake CLI before, run `snow connection add` to connect the CLI to your Snowflake account.

## Local Development

1. Run the demo script: `python src/main.py`
    Other examples are also provided: `args_example.py` shows how to pass and process command-line arguments, and `udf_example.py` shows how to register and reference UDFs.
1. Run tests: `python -m pytest`

## Deployment

1. Create a stage: `snow stage create npo_stage`
1. Copy the project contents: `snow stage copy . @npo_stage`
1. Create the NPO: `snow notebook project create --name 'qs_project' –location '@npo_stage/'`
1. Execute the NPO: `snow notebook project execute -n 'qs_project'`
