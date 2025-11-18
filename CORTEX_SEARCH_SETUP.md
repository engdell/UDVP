# Cortex Search Service Setup

## ✅ Status: CONFIGURED

The Cortex Search Service has been successfully created for the UDVP pipeline!

## 📊 Current Configuration

### Dynamic Table (Source)
- **Name**: `DOC_EMBEDDINGS`
- **Mode**: `INCREMENTAL` (required for Cortex Search)
- **Target Lag**: 5 minutes
- **Rows**: 24 embeddings from 14 documents

### Cortex Search Service
- **Name**: `DOCUMENT_SEARCH_SERVICE`
- **Search Column**: `TEXT_CHUNK`
- **Attribute Columns**: `CLASSIFICATION`, `FILE_PATH`, `CHUNK_ID`
- **Target Lag**: `DOWNSTREAM` (inherits from source DT)
- **Status**: Active (may be indexing initially)

## 🔍 How to Use Cortex Search

### Basic Search
```sql
SELECT * FROM TABLE(
    UDVP_DB.UDVP_SCHEMA.DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'payment terms and invoicing',
        LIMIT => 10
    )
);
```

### Search with Filters
```sql
SELECT * FROM TABLE(
    UDVP_DB.UDVP_SCHEMA.DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'termination clause',
        FILTER => {'@eq': {'CLASSIFICATION': ' Service Agreement'}},
        LIMIT => 10
    )
);
```

### Search with Specific Columns
```sql
SELECT 
    TEXT_CHUNK,
    CLASSIFICATION,
    FILE_PATH,
    CHUNK_ID
FROM TABLE(
    UDVP_DB.UDVP_SCHEMA.DOCUMENT_SEARCH_SERVICE!SEARCH(
        QUERY => 'contract renewal conditions',
        COLUMNS => ['TEXT_CHUNK', 'CLASSIFICATION', 'FILE_PATH', 'CHUNK_ID'],
        LIMIT => 10
    )
);
```

## ⏱️ Initial Indexing

When first created, Cortex Search Service needs time to index documents:
- **Small datasets** (< 100 docs): 1-2 minutes
- **Medium datasets** (100-1K docs): 5-10 minutes
- **Large datasets** (1K+ docs): 10+ minutes

**Current dataset**: 24 chunks from 14 documents → should be ready in **1-2 minutes**

## 🔧 Key Changes Made

### 1. Dynamic Table - INCREMENTAL Mode
**File**: `sql/06_create_doc_embeddings_dynamic_table.sql`

```sql
CREATE OR REPLACE DYNAMIC TABLE DOC_EMBEDDINGS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = UDVP_WH
    REFRESH_MODE = INCREMENTAL  -- Required for Cortex Search
    ...
```

**Changes**:
- Added `REFRESH_MODE = INCREMENTAL`
- Removed `CURRENT_TIMESTAMP()` (non-deterministic, not allowed in INCREMENTAL mode)

### 2. Cortex Search Service Definition
**File**: `sql/07_create_cortex_search_service.sql`

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE DOCUMENT_SEARCH_SERVICE
ON TEXT_CHUNK
ATTRIBUTES CLASSIFICATION, FILE_PATH, CHUNK_ID
WAREHOUSE = UDVP_WH
TARGET_LAG = DOWNSTREAM  -- Inherits from source Dynamic Table
AS (
    SELECT 
        TEXT_CHUNK,
        CLASSIFICATION,
        FILE_PATH,
        CHUNK_ID
    FROM DOC_EMBEDDINGS
    WHERE TEXT_CHUNK IS NOT NULL
);
```

**Key Points**:
- ❌ Don't include `VECTOR_EMBEDDING` column (Cortex Search computes its own embeddings)
- ✅ Use `TARGET_LAG = DOWNSTREAM` to match source table lag
- ✅ Only select text and attribute columns

## 🎯 PRD Compliance

| Requirement | Status |
|------------|--------|
| Cortex Search Service | ✅ Created |
| Dynamic Tables as Source | ✅ Configured with INCREMENTAL mode |
| Semantic Search | ✅ Enabled |
| Classification Filters | ✅ Available as attributes |
| Continuous Updates | ✅ Auto-refreshes with source data |

## 🐛 Troubleshooting

### Service Not Found Error
```
Unknown user-defined table function DOCUMENT_SEARCH_SERVICE!SEARCH
```

**Solution**: Service may still be indexing. Wait 1-2 minutes and try again.

### Check Service Status
```sql
-- View service details
DESC CORTEX SEARCH SERVICE UDVP_DB.UDVP_SCHEMA.DOCUMENT_SEARCH_SERVICE;

-- Show all services
SHOW CORTEX SEARCH SERVICES;
```

### Verify Source Data
```sql
-- Check source table has data
SELECT COUNT(*) FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS;

-- View sample data
SELECT FILE_PATH, CLASSIFICATION, LEFT(TEXT_CHUNK, 100) 
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS 
LIMIT 5;
```

### Refresh Service Manually
```sql
-- Force refresh of search service
ALTER CORTEX SEARCH SERVICE UDVP_DB.UDVP_SCHEMA.DOCUMENT_SEARCH_SERVICE REFRESH;
```

## 📝 Alternative: Direct Vector Similarity Search

If you prefer direct control over embeddings and similarity, you can still use the vector embeddings:

```sql
WITH search_vector AS (
    SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2', 'your query') AS query_embedding
)
SELECT
    FILE_PATH,
    CLASSIFICATION,
    TEXT_CHUNK,
    VECTOR_COSINE_SIMILARITY(VECTOR_EMBEDDING, query_embedding) AS SIMILARITY_SCORE
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS
CROSS JOIN search_vector
WHERE VECTOR_EMBEDDING IS NOT NULL
ORDER BY SIMILARITY_SCORE DESC
LIMIT 10;
```

**Advantages of Cortex Search Service**:
- ✅ Simpler syntax
- ✅ Optimized performance
- ✅ Built-in filters
- ✅ Automatic embedding generation

**Advantages of Direct Vector Search**:
- ✅ Full control over embedding model
- ✅ Custom similarity functions
- ✅ Access to raw similarity scores
- ✅ No indexing delay

## 🚀 Next Steps

1. **Wait 1-2 minutes** for initial indexing to complete
2. **Test the search** with your first query
3. **Upload more documents** to test continuous updates
4. **Monitor performance** using pipeline health views

---

**Pipeline is now fully compliant with PRD requirements!** 🎉

