-- ============================================================================
-- UDVP Stage and Directory Table Setup
-- Creates internal stage and directory table for document ingestion
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Create Internal Stage for unstructured documents
CREATE STAGE IF NOT EXISTS RAW_DOCUMENTS_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Internal stage for raw unstructured documents (PDF, DOCX, TXT, etc.)';

-- Enable directory table on the stage
-- The directory table tracks file metadata automatically
ALTER STAGE RAW_DOCUMENTS_STAGE 
    SET DIRECTORY = (ENABLE = TRUE);

-- Refresh the directory table to capture any existing files
ALTER STAGE RAW_DOCUMENTS_STAGE REFRESH;

-- Create a view over the directory table for easier querying
CREATE OR REPLACE VIEW DOCUMENT_DIRECTORY AS
SELECT 
    RELATIVE_PATH AS FILE_PATH,
    FILE_URL,
    SIZE AS FILE_SIZE_BYTES,
    LAST_MODIFIED,
    MD5
FROM DIRECTORY(@RAW_DOCUMENTS_STAGE);

SELECT 'Stage and directory table created successfully' AS STATUS;
SELECT 'You can upload documents using: PUT file://<local_path> @RAW_DOCUMENTS_STAGE' AS USAGE_INFO;

