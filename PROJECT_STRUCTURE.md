# UDVP Project Structure

This document describes the organization of the Unstructured Data Vectorization Pipeline project.

## Directory Layout

```
udvp/
├── README.md                          # Main documentation
├── QUICK_START.md                     # Quick reference guide
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # MIT License
├── PROJECT_STRUCTURE.md              # This file
├── DEPLOYMENT_SUMMARY.md             # Deployment details
├── PIPELINE_TEST_RESULTS.md          # Test results and validation
│
├── Unstructured Data Vectorization Pipeline PRD.md  # Product requirements
├── UDVP schema.png                   # Architecture diagram
│
├── snowflake.yml                     # Snowflake CLI project definition
├── deploy.sh                         # Deployment automation script
├── test_documents.sh                 # Test document generator
├── .git-init.sh                      # Git initialization helper
├── .gitignore                        # Git ignore rules
│
├── .github/
│   └── workflows/
│       └── deploy.yml                # CI/CD workflow template
│
└── sql/                              # SQL scripts (executed in order)
    ├── 01_setup_infrastructure.sql           # Database, schema, warehouse
    ├── 02_create_stage_and_directory.sql     # Internal stage setup
    ├── 03_create_chunking_udf.sql            # Deprecated (using page_split)
    ├── 04_create_stream.sql                  # Stream on stage (for future CDC)
    ├── 05_create_parsed_documents_table_and_task.sql  # Parsing task
    ├── 06_create_doc_embeddings_dynamic_table.sql     # Embeddings generation
    ├── 07_create_cortex_search_service.sql   # Search setup and examples
    ├── 08_monitoring_and_observability.sql   # Monitoring views
    ├── 09_sample_queries.sql                 # Example queries
    └── 10_alternative_classification_approaches.sql   # Classification examples
```

## File Descriptions

### Documentation Files

- **README.md**: Complete project documentation including architecture, setup, usage, and troubleshooting
- **QUICK_START.md**: Condensed reference for common operations
- **CONTRIBUTING.md**: Guidelines for contributors
- **DEPLOYMENT_SUMMARY.md**: Details of the deployment process and components
- **PIPELINE_TEST_RESULTS.md**: Validation results from testing with real documents

### Configuration Files

- **snowflake.yml**: Snowflake CLI project definition
- **.gitignore**: Files and directories to exclude from version control
- **LICENSE**: MIT License for the project

### Scripts

- **deploy.sh**: Automated deployment script that executes all SQL files in order
- **test_documents.sh**: Generates sample documents for testing
- **.git-init.sh**: Helper script to initialize Git repository with proper initial commit

### SQL Scripts (Deployment Order)

#### 1. Infrastructure Setup
```sql
01_setup_infrastructure.sql
```
- Creates `UDVP_DB` database
- Creates `UDVP_SCHEMA` schema
- Creates `UDVP_WH` warehouse

#### 2. Storage Configuration
```sql
02_create_stage_and_directory.sql
```
- Creates internal stage `RAW_DOCUMENTS_STAGE`
- Enables directory table
- Creates `DOCUMENT_DIRECTORY` view

#### 3. Legacy Chunking (Deprecated)
```sql
03_create_chunking_udf.sql
```
- Placeholder for custom chunking UDF
- Now using `page_split` option in `PARSE_DOCUMENT`

#### 4. Change Data Capture
```sql
04_create_stream.sql
```
- Creates stream on stage
- Prepared for future CDC-based processing

#### 5. Document Parsing
```sql
05_create_parsed_documents_table_and_task.sql
```
- Creates `PARSED_DOCUMENTS` table
- Creates `PROCESS_DOCUMENTS_TASK` (runs every 5 minutes)
- Parses documents with `page_split`
- Classifies using `SNOWFLAKE.CORTEX.COMPLETE`

#### 6. Embeddings Generation
```sql
06_create_doc_embeddings_dynamic_table.sql
```
- Creates `DOC_EMBEDDINGS` dynamic table
- Flattens pages from parsed documents
- Generates 768-dimensional embeddings with `e5-base-v2`

#### 7. Search Capabilities
```sql
07_create_cortex_search_service.sql
```
- Documents vector similarity search approach
- Provides example queries

#### 8. Monitoring & Observability
```sql
08_monitoring_and_observability.sql
```
- Creates monitoring views:
  - `PIPELINE_HEALTH`: Overall health metrics
  - `FAILED_DOCUMENTS`: Documents that failed processing
  - `PROCESSING_LATENCY`: End-to-end latency tracking
  - `DOCUMENT_STATISTICS`: Document-level statistics

#### 9. Sample Queries
```sql
09_sample_queries.sql
```
- Example queries for common operations
- Semantic search examples
- Filtering and aggregation examples

#### 10. Classification Examples
```sql
10_alternative_classification_approaches.sql
```
- Various classification strategies
- Open-ended, constrained, hierarchical
- Multi-label and few-shot examples

## Key Components

### Snowflake Objects Created

| Object Type | Name | Purpose |
|------------|------|---------|
| Database | `UDVP_DB` | Container for all UDVP objects |
| Schema | `UDVP_SCHEMA` | Logical grouping of objects |
| Warehouse | `UDVP_WH` | Compute for processing |
| Stage | `RAW_DOCUMENTS_STAGE` | Internal storage for documents |
| Table | `PARSED_DOCUMENTS` | Parsed and classified documents |
| Dynamic Table | `DOC_EMBEDDINGS` | Vector embeddings |
| Task | `PROCESS_DOCUMENTS_TASK` | Automated document processing |
| Stream | `DOCUMENTS_STREAM` | CDC on stage (future use) |
| Views | Various monitoring views | Observability |

### Functions Used

- `SNOWFLAKE.CORTEX.PARSE_DOCUMENT(stage, path, {page_split: true})`
- `SNOWFLAKE.CORTEX.COMPLETE(model, prompt)`
- `SNOWFLAKE.CORTEX.EMBED_TEXT_768(model, text)`
- `VECTOR_COSINE_SIMILARITY(vector1, vector2)`

## Development Workflow

1. **Make changes** to SQL files
2. **Test locally**:
   ```bash
   bash deploy.sh
   ```
3. **Verify** with monitoring queries:
   ```sql
   SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH;
   ```
4. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: Your changes"
   git push
   ```

## CI/CD

The `.github/workflows/deploy.yml` provides a template for automated deployment via GitHub Actions. Configure secrets in your GitHub repository:

- `SNOWFLAKE_CONFIG`: Snowflake CLI config
- `SNOWFLAKE_PASSWORD`: Snowflake password or PAT

## Notes

- All SQL scripts are idempotent (safe to run multiple times)
- Scripts use `CREATE OR REPLACE` where possible
- The pipeline processes documents every 5 minutes
- Dynamic tables refresh based on 5-minute target lag

## Version History

- **v1.0**: Initial release with Cortex AI integration
  - Document parsing with page_split
  - AI classification with mistral-large2
  - Vector embeddings with e5-base-v2
  - Full monitoring suite

