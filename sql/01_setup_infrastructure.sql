-- ============================================================================
-- UDVP Infrastructure Setup
-- Creates database, schema, warehouse, and roles for the pipeline
-- ============================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS UDVP_DB
    COMMENT = 'Unstructured Data Vectorization Pipeline Database';

-- Create Schema
CREATE SCHEMA IF NOT EXISTS UDVP_DB.UDVP_SCHEMA
    COMMENT = 'Main schema for UDVP pipeline objects';

-- Create Warehouse for processing
CREATE WAREHOUSE IF NOT EXISTS UDVP_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'Warehouse for UDVP pipeline processing';

-- Set context
USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

SELECT 'Infrastructure setup completed successfully' AS STATUS;

