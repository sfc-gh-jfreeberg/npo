from snowflake import snowpark_connect

spark = snowpark_connect.init_spark_session()

from pyspark.sql import Row

df = spark.createDataFrame([
    Row(id=1, name="Alice", age=25),
    Row(id=2, name="Bob", age=30),
    Row(id=3, name="Charlie", age=35),
])

df.show()
df.filter(df.age > 28).show()
print(df.count())
