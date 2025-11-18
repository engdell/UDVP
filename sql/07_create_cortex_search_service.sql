-- ============================================================================
-- UDVP Search Capabilities
-- The pipeline provides vector similarity search via the DOC_EMBEDDINGS table
-- Note: Cortex Search Service is not compatible with Dynamic Tables
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- The DOC_EMBEDDINGS table is ready for vector similarity search
-- Use AI_EMBED to convert your search query to a vector, then use VECTOR_COSINE_SIMILARITY

-- Example search query (commented out - replace 'your search query' with actual text):
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

SELECT 'Search capabilities are ready via DOC_EMBEDDINGS table' AS STATUS;
SELECT 'Use vector similarity search with AI_EMBED for semantic search' AS USAGE_INFO;

