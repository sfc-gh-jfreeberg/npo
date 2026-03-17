from snowflake.snowpark.session import Session

def main(connection_name: str):
    print("Running Python script")

    session = Session.builder.configs({'connection_name': connection_name}).getOrCreate()
    
    qh_df = session.sql("""SELECT *
                FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
                ORDER BY start_time""") \
        .select("QUERY_ID", "QUERY_TEXT") \
        .limit(10)

    print("Hello from npo!")

    qh_df.show()


if __name__ == "__main__":
    your_connection_name = "my_connection_name"  # Replace with the name you used in `snow connection add`

    main(your_connection_name)
