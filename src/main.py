
from snowflake.snowpark import Session

print("Running Python script")

connection_name = "<your_connection_name>"  # Replace with your actual connection name
session = Session.builder.configs({'connection_name': connection_name}).getOrCreate()

qh_df = session.sql("""SELECT *
            FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
            ORDER BY start_time""") \
    .select("QUERY_ID", "QUERY_TEXT") \
    .limit(10)

print("Hello from npo!")

qh_df.show()

