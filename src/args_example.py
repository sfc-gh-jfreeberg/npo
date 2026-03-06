# This is an example of using argparse to pass arguments to a Snowflake Snowpark Python script.
# Example usage:
# python src/args_example.py --rows 25 --wh DEX_WH

import argparse
from snowflake.snowpark.session import Session

def main(connection_name: str):
    parser = argparse.ArgumentParser(description="A simple argparse example.")
    parser.add_argument('--rows', type=int, help='Rows to sample')
    parser.add_argument('--wh', type=str, help='Warehouse name to filter on')
    args = parser.parse_args()

    print(f"Arguments received: rows={args.rows}, wh={args.wh}")

    session = Session.builder.configs({'connection_name': connection_name}).create()

    qh_df = session.sql("""SELECT *
                FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
                ORDER BY start_time""") \
        .select("QUERY_ID", "QUERY_TEXT", "WAREHOUSE_NAME") \
        .limit(args.rows if args.rows else 10)
    
    if args.wh:
        print(f"Filtering on warehouse: {args.wh}")
        qh_df = qh_df.filter(qh_df["WAREHOUSE_NAME"] == args.wh)
    
    qh_df.show()

if __name__ == "__main__":
    your_connection_name = "my_connection_name"  # Replace with the name you used in `snow connection add`

    main(your_connection_name)