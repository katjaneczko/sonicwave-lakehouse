"""Shared pytest fixtures. `spark` lives here so every test can use it without
importing it explicitly (pytest auto-discovers fixtures from conftest.py).
"""

from __future__ import annotations

import os
import sys
from collections.abc import Iterator

import pytest
from delta import configure_spark_with_delta_pip
from pyspark.sql import SparkSession


@pytest.fixture(scope="session")
def spark(tmp_path_factory: pytest.TempPathFactory) -> Iterator[SparkSession]:
    # On Windows, a bare "python" on PATH can resolve to the Microsoft Store's
    # App Execution Alias stub instead of this venv's interpreter so declared explicitly
    os.environ.setdefault("PYSPARK_PYTHON", sys.executable)
    os.environ.setdefault("PYSPARK_DRIVER_PYTHON", sys.executable)

    # Managed tables created in tests (CREATE TABLE ... USING DELTA) land here,
    # not in a spark-warehouse/ folder inside the repo
    warehouse_dir = tmp_path_factory.mktemp("spark-warehouse")

    builder = (
        SparkSession.builder.master("local[1]")
        .appName("sonicwave-ingestion-pipeline-tests")
        .config("spark.sql.shuffle.partitions", "1")
        .config("spark.ui.enabled", "false")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.driver.bindAddress", "127.0.0.1")
        # Prevents Spark from guessing data types from partition folder names (e.g. reading
        # snapshot_date=2026-03-01 back as a DateType instead of the string that
        # was written) - Bronze must land data exactly as written.
        .config("spark.sql.sources.partitionColumnTypeInference.enabled", "false")
        # Delta Lake: the SQL extension (MERGE, DESCRIBE HISTORY, ...) and a Delta-aware
        # session catalog so `USING DELTA` tables work locally the way they do on Databricks
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config(
            "spark.sql.catalog.spark_catalog",
            "org.apache.spark.sql.delta.catalog.DeltaCatalog",
        )
        .config("spark.sql.warehouse.dir", str(warehouse_dir))
    )
    # delta-spark (pip) ships only the Python side - this adds the matching Delta JARs
    # to the session (downloaded from Maven Central on first use)
    session = configure_spark_with_delta_pip(builder).getOrCreate()
    yield session
    session.stop()
