-- ============================================================================
-- UDVP Parsed Documents Table and Task
-- Creates table and task for parsing documents (Dynamic Tables don't support directory tables)
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

CREATE OR REPLACE VIEW STAGE_FILES AS
SELECT 
    RELATIVE_PATH AS FILE_PATH,
    MD5,
    SIZE AS FILE_SIZE_BYTES,
    LAST_MODIFIED::TIMESTAMP_NTZ AS LAST_MODIFIED
FROM DOCUMENTS_STREAM
WHERE METADATA$ACTION = 'INSERT'
    AND RELATIVE_PATH IS NOT NULL
    AND SIZE > 0;

-- Create regular table for parsed documents
CREATE TABLE IF NOT EXISTS PARSED_DOCUMENTS (
    FILE_PATH VARCHAR,
    DOCUMENT_ID VARCHAR PRIMARY KEY,
    FILE_SIZE_BYTES NUMBER,
    LAST_MODIFIED TIMESTAMP_NTZ,
    PARSED_DOCUMENT VARIANT,
    FULL_TEXT VARCHAR,
    CLASSIFICATION VARCHAR,
    PROCESSED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create task to process new documents every 5 minutes
CREATE OR REPLACE TASK PROCESS_DOCUMENTS_TASK
    WAREHOUSE = UDVP_WH
    WHEN SYSTEM$STREAM_HAS_DATA('DOCUMENTS_STREAM')
AS
/* Processes documents with AI_PARSE_DOCUMENT page_split for chunking */
MERGE INTO PARSED_DOCUMENTS AS target
USING (
    SELECT 
        FILE_PATH,
        DOCUMENT_ID,
        FILE_SIZE_BYTES,
        LAST_MODIFIED,
        PARSED_PAGES AS PARSED_DOCUMENT,
        DOCUMENT_SUMMARY AS FULL_TEXT,
        AI_COMPLETE(
            'mistral-large2',
            CONCAT(
                'Classify this document in 1-3 words: ',
                SUBSTR(DOC_TEXT_SNIPPET, 1, 3000)
            ),
            OBJECT_CONSTRUCT('max_tokens', 20, 'temperature', 0.1)
        ) AS CLASSIFICATION,
        CURRENT_TIMESTAMP() AS PROCESSED_AT
    FROM (
        SELECT 
            FILE_PATH,
            DOCUMENT_ID,
            FILE_SIZE_BYTES,
            LAST_MODIFIED,
            PARSED_PAGES,
            DOC_TEXT_SNIPPET,
            AI_COMPLETE(
                'mistral-large2',
                CONCAT(
                    'Provide a concise 4 sentence summary highlighting document type, purpose, key clauses, and any monetary amounts. Document text: ',
                    SUBSTR(DOC_TEXT_SNIPPET, 1, 4000)
                ),
                OBJECT_CONSTRUCT('max_tokens', 120, 'temperature', 0.2)
            ) AS DOCUMENT_SUMMARY
        FROM (
            SELECT 
                parsed.FILE_PATH,
                parsed.DOCUMENT_ID,
                parsed.FILE_SIZE_BYTES,
                parsed.LAST_MODIFIED,
                parsed.PARSED_PAGES,
                COALESCE(text_snippet.DOC_TEXT_SNIPPET, '') AS DOC_TEXT_SNIPPET
            FROM (
                SELECT 
                    FILE_PATH,
                    MD5 AS DOCUMENT_ID,
                    FILE_SIZE_BYTES,
                    LAST_MODIFIED,
                    AI_PARSE_DOCUMENT(
                        FILE_REFERENCE,
                        OBJECT_CONSTRUCT('mode', 'LAYOUT', 'page_split', true)
                    ) AS PARSED_PAGES
                FROM (
                    SELECT 
                        FILE_PATH,
                        MD5,
                        FILE_SIZE_BYTES,
                        LAST_MODIFIED,
                        TO_FILE('@UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE', FILE_PATH) AS FILE_REFERENCE
                    FROM STAGE_FILES
                )
            ) parsed,
            LATERAL (
                SELECT 
                    LISTAGG(page.value:content::string, '\n\n') WITHIN GROUP (ORDER BY page.index) AS DOC_TEXT_SNIPPET
                FROM LATERAL FLATTEN(input => parsed.PARSED_PAGES:pages) page
            ) text_snippet
        )
    )
) AS source
ON target.DOCUMENT_ID = source.DOCUMENT_ID
WHEN MATCHED AND source.LAST_MODIFIED > target.LAST_MODIFIED THEN
    UPDATE SET
        target.FILE_PATH = source.FILE_PATH,
        target.FILE_SIZE_BYTES = source.FILE_SIZE_BYTES,
        target.LAST_MODIFIED = source.LAST_MODIFIED,
        target.PARSED_DOCUMENT = source.PARSED_DOCUMENT,
        target.FULL_TEXT = source.FULL_TEXT,
        target.CLASSIFICATION = source.CLASSIFICATION,
        target.PROCESSED_AT = source.PROCESSED_AT
WHEN NOT MATCHED THEN
    INSERT (FILE_PATH, DOCUMENT_ID, FILE_SIZE_BYTES, LAST_MODIFIED, PARSED_DOCUMENT, FULL_TEXT, CLASSIFICATION, PROCESSED_AT)
    VALUES (source.FILE_PATH, source.DOCUMENT_ID, source.FILE_SIZE_BYTES, source.LAST_MODIFIED, source.PARSED_DOCUMENT, source.FULL_TEXT, source.CLASSIFICATION, source.PROCESSED_AT);

-- Resume (start) the task
ALTER TASK PROCESS_DOCUMENTS_TASK RESUME;

SELECT 'PARSED_DOCUMENTS table and task created successfully' AS STATUS;
SELECT 'Task will run every 5 minutes to process new documents' AS INFO;

