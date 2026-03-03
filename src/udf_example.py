from snowflake.snowpark.session import Session
from snowflake.snowpark.functions import udf, col
from snowflake.snowpark.types import IntegerType    
from src.utils.udfs import count_words

def main(connection_name: str):
    
    session = Session.builder.configs({'connection_name': connection_name}).create()

    print('registering UDF...')
    
    # UDF is registered on every execution of the script
    count_words_udf = udf(count_words, return_type=IntegerType(), imports=["src/utils/udfs.py"])

    print('querying and applying UDF...')
    
    session.table("SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY") \
        .select("QUERY_ID", "QUERY_TEXT") \
        .limit(10) \
        .with_column("WORD_COUNT", count_words_udf(col("QUERY_TEXT"))) \
        .show()


if __name__ == "__main__":
    
    # Replace this with the name of your preferred connection from ~/.snowflake/connections.toml
    your_connection_name = "pm-acct"

    main(your_connection_name)
