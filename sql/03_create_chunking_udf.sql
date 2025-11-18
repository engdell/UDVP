-- ============================================================================
-- UDVP Text Chunking - DEPRECATED
-- This UDF is no longer needed as we use AI_PARSE_DOCUMENT with page_split
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- Note: We now use AI_PARSE_DOCUMENT with 'page_split': true option
-- This provides built-in, optimized chunking by page for PDF, DOCX, and PPTX files
-- No custom chunking UDF is needed

SELECT 'Chunking is handled by AI_PARSE_DOCUMENT with page_split option' AS INFO;

