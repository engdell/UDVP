-- ============================================================================
-- UDVP Document Embeddings Dynamic Table
-- Final output table with chunked text and vector embeddings
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Create the final DOC_EMBEDDINGS dynamic table
-- This table uses page_split from AI_PARSE_DOCUMENT for automatic chunking
CREATE OR REPLACE DYNAMIC TABLE DOC_EMBEDDINGS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = UDVP_WH
    COMMENT = 'Document embeddings for semantic search and RAG applications'
AS
WITH page_chunks AS (
    SELECT 
        FILE_PATH,
        DOCUMENT_ID,
        CLASSIFICATION,
        PROCESSED_AT,
        -- Flatten the pages array from AI_PARSE_DOCUMENT
        f.INDEX AS CHUNK_ID,
        f.VALUE:content::VARCHAR AS TEXT_CHUNK
    FROM PARSED_DOCUMENTS,
    LATERAL FLATTEN(input => PARSED_DOCUMENT:pages) f
    WHERE PARSED_DOCUMENT:pages IS NOT NULL
)
SELECT 
    FILE_PATH,
    DOCUMENT_ID,
    CLASSIFICATION,
    CHUNK_ID,
    TEXT_CHUNK,
    -- Generate vector embedding using modern AI_EMBED
    TRY_CAST(
        AI_EMBED(
            'e5-base-v2',
            TEXT_CHUNK
        ) AS VECTOR(FLOAT, 768)
    ) AS VECTOR_EMBEDDING,
    PROCESSED_AT,
    CURRENT_TIMESTAMP() AS EMBEDDING_GENERATED_AT
FROM page_chunks
WHERE TEXT_CHUNK IS NOT NULL 
    AND LENGTH(TEXT_CHUNK) > 10;

SELECT 'DOC_EMBEDDINGS dynamic table created successfully' AS STATUS;
SELECT 'Pipeline is now active and will process documents automatically' AS INFO;

