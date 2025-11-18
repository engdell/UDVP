# 🚀 Unstructured Data Vectorization Pipeline (UDVP)

A fully managed, continuous data pipeline in Snowflake that automatically ingests unstructured documents, extracts content, classifies them, chunks text, and generates vector embeddings for semantic search and RAG applications.

## 📋 Overview

This pipeline leverages Snowflake's native features to provide a declarative, continuous ETL/ELT process for unstructured data:

- **Modern Cortex AI Functions**: `AI_PARSE_DOCUMENT`, `AI_CLASSIFY`, `AI_EMBED`
- **Dynamic Tables**: Automatic refresh and dependency management
- **Streams**: Change data capture for continuous processing
- **Internal Stages**: Secure document storage within Snowflake
- **Vector Similarity Search**: Semantic search using vector embeddings

## 🏗️ Architecture

```
Unstructured Data    →    Stream    →    AI Parse     →    AI Classify    →    Chunking    →    Embeddings
    Stage                 (CDC)         Document                                                   (Dynamic Table)
     ↓                                      ↓                    ↓                                       ↓
Internal Stage        Directory        Parsed Text         Classification           Text Chunks        Vector DB
                       Table                                                                          (Search Ready)
```

## 📁 Project Structure

```
UDVP project/
├── .snowflake/
│   └── config                          # Snowflake CLI configuration
├── sql/
│   ├── 01_setup_infrastructure.sql     # Database, schema, warehouse
│   ├── 02_create_stage_and_directory.sql  # Internal stage setup
│   ├── 03_create_chunking_udf.sql      # (Deprecated - using page_split)
│   ├── 04_create_stream.sql            # CDC stream on directory table
│   ├── 05_create_parsed_documents_dynamic_table.sql  # Parse & classify with page_split
│   ├── 06_create_doc_embeddings_dynamic_table.sql    # Page-based embeddings
│   ├── 07_create_cortex_search_service.sql  # Semantic search service
│   ├── 08_monitoring_and_observability.sql  # Health monitoring views
│   └── 09_sample_queries.sql           # Example usage queries
├── deploy.sh                            # Deployment script
├── snowflake.yml                        # Snowflake project definition
└── README.md                            # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Snowflake CLI**: Install from [Snowflake Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index)
2. **Snowflake Account**: With Cortex AI features enabled
3. **Authentication**: `.pat` file with your Snowflake private key

### Installation

1. **Clone or navigate to the project directory**:
   ```bash
   cd /path/to/udvp
   ```

2. **Configure authentication**:
   - Ensure your `.pat` file contains your Snowflake private key
   - The `.snowflake/config` file is already configured to use the "cursor" connection

3. **Deploy the pipeline**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 📤 Usage

### 1. Upload Documents

Upload documents to the internal stage:

```bash
# Single file
snow sql -q "PUT file:///path/to/document.pdf @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE" -c cursor

# Multiple files
snow sql -q "PUT file:///path/to/documents/* @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE" -c cursor
```

Supported formats: PDF, DOCX, TXT, and other formats supported by `PARSE_DOCUMENT`.

### 2. Refresh Stage Directory

After uploading files, refresh the directory table:

```bash
snow sql -q "ALTER STAGE UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE REFRESH" -c cursor
```

### 3. Monitor Pipeline

Check pipeline health:

```bash
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH" -c cursor
```

View processing latency:

```bash
snow sql -q "SELECT * FROM UDVP_DB.UDVP_SCHEMA.PROCESSING_LATENCY" -c cursor
```

### 4. Query Documents

View parsed documents:

```sql
SELECT 
    FILE_PATH,
    CLASSIFICATION,
    LEFT(PARSED_TEXT, 200) AS PREVIEW
FROM UDVP_DB.UDVP_SCHEMA.PARSED_DOCUMENTS;
```

View embeddings:

```sql
SELECT 
    FILE_PATH,
    CLASSIFICATION,
    CHUNK_ID,
    TEXT_CHUNK
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS
LIMIT 100;
```

### 5. Semantic Search

Perform semantic search using vector similarity:

```sql
WITH search_vector AS (
    SELECT AI_EMBED('e5-base-v2', 'your search query here') AS query_embedding
)
SELECT 
    d.FILE_PATH,
    d.CLASSIFICATION,
    d.TEXT_CHUNK,
    d.CHUNK_ID,
    VECTOR_COSINE_SIMILARITY(d.VECTOR_EMBEDDING, s.query_embedding) AS SIMILARITY_SCORE
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS d
CROSS JOIN search_vector s
WHERE d.VECTOR_EMBEDDING IS NOT NULL
ORDER BY SIMILARITY_SCORE DESC
LIMIT 10;
```

## 🔧 Configuration

### Dynamic Table Refresh Frequency

Adjust the `TARGET_LAG` to balance freshness with compute costs:

```sql
-- Faster refresh (more compute)
ALTER DYNAMIC TABLE UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS 
    SET TARGET_LAG = '1 minute';

-- Slower refresh (less compute)
ALTER DYNAMIC TABLE UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS 
    SET TARGET_LAG = '15 minutes';
```

### Page Split Configuration

The pipeline uses `AI_PARSE_DOCUMENT` with the `page_split` option for automatic chunking by page. This works for PDF, DOCX, and PPTX files. For other formats or custom chunking needs, you can modify `05_create_parsed_documents_dynamic_table.sql`:

```sql
-- Current: {'mode': 'LAYOUT', 'page_split': true}

-- Without page splitting (single document)
{'mode': 'LAYOUT', 'page_split': false}

-- Process specific page ranges
{'mode': 'LAYOUT', 'page_filter': [{'start': 0, 'end': 10}]}
```

## 📊 Monitoring Views

| View Name | Description |
|-----------|-------------|
| `PIPELINE_HEALTH` | Overall pipeline metrics and document counts |
| `FAILED_DOCUMENTS` | Documents that failed to parse |
| `PROCESSING_LATENCY` | Time taken for each processing stage |
| `DOCUMENT_STATISTICS` | Statistics by document classification |

## 🎯 Key Features

- ✅ **Fully Managed**: Leverages Snowflake's native services
- ✅ **Continuous Processing**: Automatic processing of new documents
- ✅ **Scalable**: Automatic compute scaling via Snowflake
- ✅ **AI-Powered**: Uses modern Cortex AI functions (`AI_PARSE_DOCUMENT` with `page_split`, `AI_CLASSIFY`, `AI_EMBED`)
- ✅ **Intelligent Chunking**: Built-in page-level chunking for PDFs, DOCX, and PPTX
- ✅ **Search Ready**: Vector similarity search for semantic retrieval
- ✅ **Monitored**: Built-in observability and health checks

## 📝 Schema

### DOC_EMBEDDINGS Table

| Column | Type | Description |
|--------|------|-------------|
| `FILE_PATH` | VARCHAR | Original document path in stage |
| `DOCUMENT_ID` | VARCHAR | Unique document identifier (MD5 hash) |
| `CLASSIFICATION` | VARCHAR | AI-generated document classification |
| `CHUNK_ID` | INTEGER | Chunk index within document |
| `TEXT_CHUNK` | VARCHAR | Text segment |
| `VECTOR_EMBEDDING` | VECTOR(FLOAT, 768) | Embedding vector for semantic search |
| `PROCESSED_AT` | TIMESTAMP | When document was parsed |
| `EMBEDDING_GENERATED_AT` | TIMESTAMP | When embedding was generated |

## 🔒 Security

- **RBAC**: Uses role-based access control (SYSADMIN role)
- **Internal Stage**: Documents stored securely within Snowflake
- **JWT Authentication**: Uses private key authentication via `.pat` file

## 🛠️ Troubleshooting

### Documents not processing

1. Verify files are uploaded:
   ```sql
   SELECT * FROM DIRECTORY(@UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE);
   ```

2. Check for failed documents:
   ```sql
   SELECT * FROM UDVP_DB.UDVP_SCHEMA.FAILED_DOCUMENTS;
   ```

3. Manually refresh the stage:
   ```sql
   ALTER STAGE UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE REFRESH;
   ```

### Dynamic tables not refreshing

1. Check dynamic table status:
   ```sql
   SHOW DYNAMIC TABLES IN SCHEMA UDVP_DB.UDVP_SCHEMA;
   ```

2. Manually refresh:
   ```sql
   ALTER DYNAMIC TABLE UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS REFRESH;
   ```

### Embeddings are NULL

- Ensure text chunks are not empty
- Verify Cortex AI functions are available in your Snowflake account
- Check query history for errors

## 📚 Resources

- [Snowflake Documentation](https://docs.snowflake.com/)
- [AI_PARSE_DOCUMENT](https://docs.snowflake.com/en/sql-reference/functions/ai_parse_document)
- [AI_CLASSIFY](https://docs.snowflake.com/en/sql-reference/functions/ai_classify)
- [AI_EMBED](https://docs.snowflake.com/en/sql-reference/functions/ai_embed)
- [Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)
- [Vector Data Type](https://docs.snowflake.com/en/sql-reference/data-types-vector)

## 📄 License

This project is provided as-is for use with Snowflake Data Cloud.

## 🤝 Support

For issues or questions, refer to the Snowflake documentation or your Snowflake account team.

