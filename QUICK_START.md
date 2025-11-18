# UDVP Quick Start Guide

## Upload Your First Documents

```bash
cd /path/to/udvp

# Upload documents
for file in /path/to/your/documents/*; do 
    snow sql -q "PUT file://$file @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE" -c cursor
done

# Refresh stage
snow sql -q "ALTER STAGE UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE REFRESH" -c cursor

# Trigger processing immediately
snow sql -q "EXECUTE TASK UDVP_DB.UDVP_SCHEMA.PROCESS_DOCUMENTS_TASK" -c cursor

# Wait 30-60 seconds, then check status
sleep 60
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH" -c cursor
```

## Search Your Documents

```sql
-- Connect to Snowflake and run:
USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Semantic search example
WITH search_vector AS (
    SELECT AI_EMBED('e5-base-v2', 'machine learning deployment strategies') AS query_embedding
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
```

## Monitor Your Pipeline

```bash
# Check pipeline health
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH" -c cursor

# View document statistics
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.DOCUMENT_STATISTICS" -c cursor

# Check processing latency
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.PROCESSING_LATENCY LIMIT 10" -c cursor
```

## Common Operations

```sql
-- View all parsed documents
SELECT FILE_PATH, CLASSIFICATION, PROCESSED_AT 
FROM PARSED_DOCUMENTS 
ORDER BY PROCESSED_AT DESC;

-- View embeddings
SELECT FILE_PATH, CHUNK_ID, LEFT(TEXT_CHUNK, 100) AS PREVIEW
FROM DOC_EMBEDDINGS 
ORDER BY FILE_PATH, CHUNK_ID 
LIMIT 20;

-- Check for failed documents
SELECT * FROM FAILED_DOCUMENTS;

-- Manually trigger processing
EXECUTE TASK PROCESS_DOCUMENTS_TASK;
```

That's it! Your UDVP pipeline is ready to use! 🎉

