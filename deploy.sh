#!/bin/bash

# ============================================================================
# UDVP Deployment Script
# Deploys the Unstructured Data Vectorization Pipeline to Snowflake
# ============================================================================

set -e  # Exit on error

echo "=========================================="
echo "UDVP Deployment Script"
echo "=========================================="
echo ""

# Check if Snowflake CLI is installed
if ! command -v snow &> /dev/null; then
    echo "❌ Error: Snowflake CLI (snow) is not installed"
    echo "Please install it: https://docs.snowflake.com/en/developer-guide/snowflake-cli/index"
    exit 1
fi

# Check if .pat file exists
if [ ! -f ".pat" ]; then
    echo "❌ Error: .pat file not found"
    echo "Please create a .pat file with your Snowflake private key"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Set connection
CONNECTION="your_cli_connection_name"

echo "📊 Using connection: $CONNECTION"
echo ""

# Deploy SQL scripts in order
SQL_FILES=(
    "sql/01_setup_infrastructure.sql"
    "sql/02_create_stage_and_directory.sql"
    "sql/03_create_chunking_udf.sql"
    "sql/04_create_stream.sql"
    "sql/05_create_parsed_documents_table_and_task.sql"
    "sql/06_create_doc_embeddings_dynamic_table.sql"
    "sql/07_create_cortex_search_service.sql"
    "sql/08_monitoring_and_observability.sql"
)

for sql_file in "${SQL_FILES[@]}"; do
    echo "📝 Executing: $sql_file"
    snow sql -f "$sql_file" -c "$CONNECTION"
    
    if [ $? -eq 0 ]; then
        echo "✅ Success: $sql_file"
    else
        echo "❌ Failed: $sql_file"
        exit 1
    fi
    echo ""
done

echo "=========================================="
echo "✅ Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Upload documents to the stage:"
echo "   snow sql -q \"PUT file://<your_file_path> @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE\" -c $CONNECTION"
echo ""
echo "2. Refresh the stage directory:"
echo "   snow sql -q \"ALTER STAGE UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE REFRESH\" -c $CONNECTION"
echo ""
echo "3. Monitor pipeline health:"
echo "   snow sql -q \"SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH\" -c $CONNECTION"
echo ""
echo "4. View sample queries in: sql/09_sample_queries.sql"
echo ""

