# Set your desired name here
object_name=my_python_project

# Deploy the project to Snowflake
snow notebook project create $object_name \
    --source . \  # Uploads the current directory as the project source 
    --overwrite \

# Execute the main.py file in the project
snow notebook project execute $object_name \
    --main-file=src/main.py
