from __future__ import annotations

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def test_merge_same_batch_twice_inserts_nothing(spark: SparkSession) -> None:
    spark.sql("CREATE SCHEMA IF NOT EXISTS spark_catalog.bronze")
    spark.sql(
        """
        CREATE TABLE IF NOT EXISTS spark_catalog.bronze.smoke (
            play_id STRING,
            snapshot_date DATE
        ) USING DELTA
        """
    )

    batch = spark.createDataFrame(
        [("1", "2026-03-01"), ("2", "2026-03-01")],
        schema="play_id string, snapshot_date string",
    ).withColumn("snapshot_date", F.to_date("snapshot_date"))
    batch.createOrReplaceTempView("batch")

    merge = """
        MERGE INTO spark_catalog.bronze.smoke AS t
        USING batch AS s
        ON t.play_id = s.play_id AND t.snapshot_date = s.snapshot_date
        WHEN NOT MATCHED THEN INSERT *
    """
    spark.sql(merge)
    spark.sql(merge)  # re-run of the same batch

    assert spark.table("spark_catalog.bronze.smoke").count() == 2
