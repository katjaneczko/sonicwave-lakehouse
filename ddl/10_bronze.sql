-- 10 - Bronze: data drops as received + provenance
--
-- Every source column is STRING: Bronze lands data exactly as the source sent it.
-- A line that is not valid JSON is kept in _corrupted (column) so nothing arrives without a trace.
--
-- Idempotent load: MERGE ... WHEN NOT MATCHED THEN INSERT, keyed on
-- snapshot_date plus every source column (compared null-safe). Re-running a day
-- inserts nothing; a re-dropped day with one extra line inserts exactly that
-- line. Two byte-identical lines in the same drop collapse into one Bronze row
-- (documented in README); a repeated play_id with different values does not.
--
-- CLUSTER BY (snapshot_date): the MERGE's ON clause and Silver's read are both
-- "one snapshot_date", so that is the clustering key.

CREATE TABLE IF NOT EXISTS ${catalog}.bronze.plays (
    play_id STRING COMMENT 'The source systems unique identifier for this play event',
    user_id STRING COMMENT 'The user who performed the play event',
    content_id STRING COMMENT 'The content that was played',
    device_id STRING COMMENT 'The device on which the content was played',
    played_at STRING COMMENT 'When the user played the content',
    created_at STRING COMMENT 'When the source system created the event. Later than played_at if event is late',
    updated_at STRING COMMENT 'When the source last changed the row. NULL if never changed',
    ms_played STRING COMMENT 'How many milliseconds the user played the content',
    _corrupted STRING COMMENT 'JSON string for rows that could not be parsed',
    snapshot_date DATE NOT NULL COMMENT 'The date of the source system drop that produced this row',
    source_file STRING NOT NULL COMMENT 'The file from which the row was ingested',
    ingested_at TIMESTAMP NOT NULL COMMENT 'When the row was ingested into Bronze'
)
USING DELTA
CLUSTER BY (snapshot_date)
COMMENT 'Raw plays event feed, one folder per day, every row as received (all values as text). Append-only, loaded by MERGE keyed on snapshot_date plus every source column, so re-running a day changes nothing.';