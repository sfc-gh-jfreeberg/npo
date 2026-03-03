
def count_words(sql_text: str) -> int:
    """
    Simple example of a UDF handler to convey the creation lifecyle in udf_example.py.
    Counts the number of words in a SQL query.
    """
    return len(sql_text.split()) if sql_text else 0
