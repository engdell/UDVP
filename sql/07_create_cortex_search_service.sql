-- ============================================================================
-- UDVP Cortex Search Service
-- Creates a Cortex Search Service for semantic search on document embeddings
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Create Cortex Search Service on DOC_EMBEDDINGS Dynamic Table
-- Note: Cortex Search computes its own embeddings - don't include VECTOR_EMBEDDING column
-- TARGET_LAG must match or exceed the source Dynamic Table's lag (5 minutes)
CREATE OR REPLACE CORTEX SEARCH SERVICE DOCUMENT_SEARCH_SERVICE
    ON TEXT_CHUNK
    ATTRIBUTES CLASSIFICATION, FILE_PATH, CHUNK_ID, DOCUMENT_SUMMARY
WAREHOUSE = UDVP_WH
TARGET_LAG = DOWNSTREAM
AS (
    SELECT 
        TEXT_CHUNK,
        CLASSIFICATION,
        FILE_PATH,
        CHUNK_ID,
        SUMMARY.TEXT_SUMMARY AS DOCUMENT_SUMMARY
    FROM DOC_EMBEDDINGS
    JOIN (
        SELECT DOCUMENT_ID, FULL_TEXT AS TEXT_SUMMARY
        FROM PARSED_DOCUMENTS
    ) SUMMARY ON DOC_EMBEDDINGS.DOCUMENT_ID = SUMMARY.DOCUMENT_ID
    WHERE TEXT_CHUNK IS NOT NULL
);

-- Wait a moment for the service to initialize
SELECT 'Cortex Search Service created successfully' AS STATUS;
SELECT 'Service Name: DOCUMENT_SEARCH_SERVICE' AS INFO;

-- Show service details
SHOW CORTEX SEARCH SERVICES LIKE 'DOCUMENT_SEARCH_SERVICE';

-- Example 1: Simple text search
/*
SELECT * FROM TABLE(
    DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'payment terms and invoicing',
        LIMIT => 10
    )
);
*/

-- Example 2: Search with filters
/*
SELECT * FROM TABLE(
    DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'termination clause',
        FILTER => {'@eq': {'CLASSIFICATION': 'Service Agreement'}},
        LIMIT => 10
    )
);
*/

-- Example 3: Get columns with results
/*
SELECT 
    TEXT_CHUNK,
    CLASSIFICATION,
    FILE_PATH,
    CHUNK_ID
FROM TABLE(
    DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'contract renewal conditions',
        COLUMNS => ['TEXT_CHUNK', 'CLASSIFICATION', 'FILE_PATH', 'CHUNK_ID'],
        LIMIT => 10
    )
);
*/

