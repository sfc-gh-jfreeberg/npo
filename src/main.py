from snowflake.snowpark_connect import init_spark_session
from snowflake.snowpark_connect.snowflake_session import SnowflakeSession

def main():
    print("Running Python script")

    spark = init_spark_session()
    session = SnowflakeSession(spark)

    session.sql("""SELECT *
                FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
                ORDER BY start_time""") \
        .select("QUERY_ID", "QUERY_TEXT") \
        .limit(10) \
        .show()


if __name__ == "__main__":

    main()
