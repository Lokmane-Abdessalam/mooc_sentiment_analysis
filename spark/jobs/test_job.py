from pyspark.sql import SparkSession
from pyspark.sql.functions import col

def main():
    # 1. Initialize SparkSession pointing to the master
    spark = SparkSession.builder \
        .appName("MOOC_Production_Preprocessing") \
        .master("spark://spark-master:7077") \
        .getOrCreate()

    print("--- Starting MOOC Preprocessing Job ---")

    # 2. Your processing logic goes here
    df = spark.read \
        .option("header", "true") \
        .option("multiLine", "true") \
        .option("quote", "\"") \
        .option("escape", "\"") \
        .csv("hdfs://namenode:9000/data/mooc/raw/Comments.csv")
    
    df_count = df.count()
    print(f"Total records found: {df_count}")

    # 3. Always stop the session cleanly at the end of a script
    spark.stop()
    print("--- Job Finished ---")

if __name__ == "__main__":
    main()