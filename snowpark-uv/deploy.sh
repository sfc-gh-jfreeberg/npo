# Set your desired name here
object_name=my_snowpark_job

# Deploy the project to Snowflake
snow notebook project create $object_name \
    --source . \
    --overwrite \
    -c pm-acct

# Execute the main.py file in the project
snow notebook project execute $object_name \
    --main-file=src/main.py \
    -c pm-acct
