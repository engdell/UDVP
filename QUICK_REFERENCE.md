# UDVP Quick Reference Card

## 🚀 One-Command Deploy
```bash
bash deploy.sh
```

## 📤 Upload Documents
```bash
# Single file
PUT file://document.pdf @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE;

# Multiple files
PUT file://documents/* @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE;
```

## 🔍 Semantic Search
```sql
WITH search_vector AS (
    SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2', 'your query') AS q
)
SELECT FILE_PATH, TEXT_CHUNK, 
       VECTOR_COSINE_SIMILARITY(VECTOR_EMBEDDING, q) AS SCORE
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS, search_vector
ORDER BY SCORE DESC LIMIT 10;
```

## 📊 Monitor Pipeline
```sql
-- Overall health
SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH;

-- Failed documents
SELECT * FROM UDVP_DB.UDVP_SCHEMA.FAILED_DOCUMENTS;

-- Processing latency
SELECT * FROM UDVP_DB.UDVP_SCHEMA.PROCESSING_LATENCY;
```

## 🔄 Manual Task Execution
```sql
-- Trigger document processing immediately
EXECUTE TASK UDVP_DB.UDVP_SCHEMA.PROCESS_DOCUMENTS_TASK;

-- Refresh embeddings
ALTER DYNAMIC TABLE UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS REFRESH;
```

## 🎯 Filter by Classification
```sql
-- Search within specific document types
WHERE CLASSIFICATION = 'Service Agreement'
-- or
WHERE CLASSIFICATION LIKE '%Contract%'
```

## 📈 Statistics
```sql
-- Document counts by type
SELECT CLASSIFICATION, COUNT(*) 
FROM UDVP_DB.UDVP_SCHEMA.PARSED_DOCUMENTS 
GROUP BY CLASSIFICATION;

-- Embedding stats
SELECT COUNT(*) AS total_embeddings,
       AVG(LENGTH(TEXT_CHUNK)) AS avg_chunk_size
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS;
```

## 🛠️ Troubleshooting

### Task not running?
```sql
-- Check task status
SHOW TASKS LIKE 'PROCESS_DOCUMENTS_TASK';

-- Resume task
ALTER TASK UDVP_DB.UDVP_SCHEMA.PROCESS_DOCUMENTS_TASK RESUME;
```

### No embeddings?
```sql
-- Check if dynamic table needs refresh
ALTER DYNAMIC TABLE UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS REFRESH;
```

### Classification stuck?
```sql
-- Manually classify documents
MERGE INTO UDVP_DB.UDVP_SCHEMA.PARSED_DOCUMENTS AS target
USING (
    SELECT DOCUMENT_ID,
           SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', 
               CONCAT('Classify: ', SUBSTR(FULL_TEXT, 1, 3000))
           ) AS NEW_CLASS
    FROM UDVP_DB.UDVP_SCHEMA.PARSED_DOCUMENTS
    WHERE CLASSIFICATION = 'Pending Classification'
) AS source
ON target.DOCUMENT_ID = source.DOCUMENT_ID
WHEN MATCHED THEN UPDATE SET CLASSIFICATION = source.NEW_CLASS;
```

## 🔑 Key Objects

| Object | Type | Purpose |
|--------|------|---------|
| `RAW_DOCUMENTS_STAGE` | Stage | Document storage |
| `PARSED_DOCUMENTS` | Table | Parsed text + metadata |
| `DOC_EMBEDDINGS` | Dynamic Table | Vector embeddings |
| `PROCESS_DOCUMENTS_TASK` | Task | Automated processing |
| `PIPELINE_HEALTH` | View | Health monitoring |

## 📞 Support

- Documentation: `README.md`
- Setup Guide: `GIT_SETUP_GUIDE.md`
- Structure: `PROJECT_STRUCTURE.md`
- Examples: `sql/09_sample_queries.sql`

---
💡 **Tip**: Task runs every 5 minutes. Documents are typically ready in 5-10 minutes.

