-- ============================================================================
-- UDVP Cortex Search Refresh Task
-- Automatically refreshes Cortex Search Service after documents are processed
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Triggered task: runs after PROCESS_DOCUMENTS_TASK completes
CREATE OR REPLACE TASK REFRESH_DOCUMENT_SEARCH_SERVICE_TASK
    WAREHOUSE = UDVP_WH
    AFTER PROCESS_DOCUMENTS_TASK
    COMMENT = 'Refresh Cortex Search index after document parsing task finishes'
AS
ALTER CORTEX SEARCH SERVICE DOCUMENT_SEARCH_SERVICE REFRESH;

-- Resume the task
ALTER TASK REFRESH_DOCUMENT_SEARCH_SERVICE_TASK RESUME;

SELECT 'REFRESH_DOCUMENT_SEARCH_SERVICE_TASK created successfully' AS STATUS;
SELECT 'Triggered AFTER PROCESS_DOCUMENTS_TASK to keep Cortex Search in sync' AS INFO;


