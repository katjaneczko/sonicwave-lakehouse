# SonicWave on the Lakehouse

Module 3 capstone. The Module 2 SonicWave ingestion pipeline, migrated onto
Databricks: Unity Catalog, Delta tables declared by versioned DDL, entry-points
running as `python_wheel_task`s, deployed from a Databricks Asset Bundle.

## Status

Phase 0 — repo bootstrapped: the Module 2 wheel (`src/sonicwave_ingestion_pipeline`)
and its offline test suite carried forward. `pyspark` is a dev dependency only;
the wheel declares no runtime deps because the Databricks runtime provides them.

Not yet built: DDL, scaled seed generator, wheel-task entry-points, the three
jobs, the bundle, the performance investigation, `docs/`.

## Setup

```
uv sync
uv run pre-commit install
```

## Run the tests / quality gate

```
uv run ruff check .
uv run ruff format --check .
uv run mypy
uv run pytest -q
```

The same commands run in CI (`.github/workflows/ci.yml`) on every PR. The tests
run fully offline, with no Databricks workspace.
