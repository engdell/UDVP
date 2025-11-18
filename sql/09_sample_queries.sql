-- ============================================================================
-- UDVP Sample Queries
-- Example queries for using the UDVP pipeline
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- ============================================================================
-- QUERY 1: View all documents in the stage
-- ============================================================================
SELECT 
    RELATIVE_PATH,
    SIZE,
    LAST_MODIFIED,
    MD5
FROM DIRECTORY(@RAW_DOCUMENTS_STAGE)
ORDER BY LAST_MODIFIED DESC;

-- ============================================================================
-- QUERY 2: View parsed documents with classifications
-- ============================================================================
SELECT 
    FILE_PATH,
    DOCUMENT_ID,
    CLASSIFICATION,
    LEFT(PARSED_TEXT, 100) AS TEXT_PREVIEW,
    LENGTH(PARSED_TEXT) AS TEXT_LENGTH,
    PROCESSED_AT
FROM PARSED_DOCUMENTS
ORDER BY PROCESSED_AT DESC;

-- ============================================================================
-- QUERY 3: View document embeddings
-- ============================================================================
SELECT 
    FILE_PATH,
    DOCUMENT_ID,
    CLASSIFICATION,
    CHUNK_ID,
    LEFT(TEXT_CHUNK, 100) AS CHUNK_PREVIEW,
    LENGTH(TEXT_CHUNK) AS CHUNK_LENGTH,
    VECTOR_EMBEDDING IS NOT NULL AS HAS_EMBEDDING,
    EMBEDDING_GENERATED_AT
FROM DOC_EMBEDDINGS
ORDER BY FILE_PATH, CHUNK_ID
LIMIT 100;

-- ============================================================================
-- QUERY 4: Semantic search using vector similarity with AI_EMBED
-- ============================================================================
-- Note: Replace 'your search query' with actual search terms
/*
WITH search_vector AS (
    SELECT AI_EMBED('e5-base-v2', 'your search query here') AS query_embedding
)
SELECT 
    d.FILE_PATH,
    d.CLASSIFICATION,
    d.TEXT_CHUNK,
    d.CHUNK_ID,
    VECTOR_COSINE_SIMILARITY(d.VECTOR_EMBEDDING, s.query_embedding) AS SIMILARITY_SCORE
FROM DOC_EMBEDDINGS d
CROSS JOIN search_vector s
WHERE d.VECTOR_EMBEDDING IS NOT NULL
ORDER BY SIMILARITY_SCORE DESC
LIMIT 10;
*/

-- ============================================================================
-- QUERY 5: Monitor pipeline health
-- ============================================================================
SELECT * FROM PIPELINE_HEALTH;

-- ============================================================================
-- QUERY 6: View processing latency
-- ============================================================================
SELECT 
    FILE_PATH,
    CLASSIFICATION,
    PARSING_LATENCY_SECONDS,
    EMBEDDING_LATENCY_SECONDS,
    TOTAL_LATENCY_SECONDS
FROM PROCESSING_LATENCY
ORDER BY FILE_UPLOADED_AT DESC
LIMIT 20;

-- ============================================================================
-- QUERY 7: View document statistics by classification
-- ============================================================================
SELECT * FROM DOCUMENT_STATISTICS;

-- ============================================================================
-- QUERY 8: Find similar documents using vector similarity
-- ============================================================================
-- Note: Replace <target_embedding> with an actual embedding vector
/*
SELECT 
    d1.FILE_PATH,
    d1.CLASSIFICATION,
    d1.CHUNK_ID,
    d1.TEXT_CHUNK,
    VECTOR_COSINE_SIMILARITY(d1.VECTOR_EMBEDDING, d2.VECTOR_EMBEDDING) AS SIMILARITY
FROM DOC_EMBEDDINGS d1
CROSS JOIN (
    SELECT VECTOR_EMBEDDING 
    FROM DOC_EMBEDDINGS 
    WHERE DOCUMENT_ID = '<target_document_id>' 
    AND CHUNK_ID = 0
) d2
WHERE d1.VECTOR_EMBEDDING IS NOT NULL
ORDER BY SIMILARITY DESC
LIMIT 10;
*/

-- ============================================================================
-- QUERY 9: Check for failed documents
-- ============================================================================
SELECT * FROM FAILED_DOCUMENTS;

-- ============================================================================
-- QUERY 10: Refresh stage directory (run after uploading new files)
-- ============================================================================
-- ALTER STAGE RAW_DOCUMENTS_STAGE REFRESH;

SELECT 'Sample queries loaded. Uncomment and modify as needed.' AS INFO;

