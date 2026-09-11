-- requires: unity-catalog
-- 01 - the landing Volume.
--
-- The seed generator (run once, by hand, before the pipeline exists) writes the
-- daily drops here:
--
--     /Volumes/${catalog}/landing/raw/plays/<snapshot_date>/*.json
--     /Volumes/${catalog}/landing/raw/users/<snapshot_date>/*.json
--
-- Bronze reads exactly one <snapshot_date> folder per run. A managed Volume, so
-- the files are governed by the same catalog as the tables they feed.

CREATE VOLUME IF NOT EXISTS ${catalog}.landing.raw
  COMMENT 'Raw daily drops from the source systems: <table>/<snapshot_date>/*.json, every value as text.';
