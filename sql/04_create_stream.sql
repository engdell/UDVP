-- ============================================================================
-- UDVP Stream for Change Data Capture
-- Creates stream on directory table to track new/updated files
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Create stream directly on the stage directory table
CREATE OR REPLACE STREAM DOCUMENTS_STREAM
    ON STAGE RAW_DOCUMENTS_STAGE
    COMMENT = 'Stream to capture new and updated documents in the stage';

-- Refresh the stage so the stream baseline is current
ALTER STAGE RAW_DOCUMENTS_STAGE REFRESH;

SELECT 
    'Stream created successfully' AS STATUS,
    'Stream will track file changes in RAW_DOCUMENTS_STAGE' AS INFO;

