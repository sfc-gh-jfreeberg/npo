# Set your desired name here
object_name=my_snowpark_connect_project2

# Deploy the project to Snowflake
snow notebook project create $object_name \
    --source . \
    --overwrite \
    -c spark-connect

# Execute the main.py file in the project
snow notebook project execute $object_name \
    --main-file=src/main.py \
    -c spark-connect