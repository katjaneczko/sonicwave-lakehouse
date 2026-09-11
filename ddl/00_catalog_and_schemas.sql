-- requires: unity-catalog
-- 00 - catalog and one schema per layer.
--
-- One catalog per environment (sonicwave_dev, sonicwave_prod): dev and prod are
-- isolated at the top of the namespace, so a grant on prod never leaks to dev.
-- One schema per layer inside it, so grants can follow the layers.
--
-- ${catalog} is then substituted by the DDL runner. Every statement is re-runnable:
-- running this file twice is not an error and changes nothing.

CREATE CATALOG IF NOT EXISTS ${catalog}
  COMMENT 'SonicWave lakehouse: one catalog per environment, one schema per layer.';

CREATE SCHEMA IF NOT EXISTS ${catalog}.landing
  COMMENT 'Raw daily drops from the source systems (a Volume, no tables).';

CREATE SCHEMA IF NOT EXISTS ${catalog}.bronze
  COMMENT 'Every drop as received (all columns STRING) plus provenance. Append-only, loaded by MERGE.';


