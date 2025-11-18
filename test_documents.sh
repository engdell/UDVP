#!/bin/bash

# ============================================================================
# UDVP Test Documents Script
# Creates sample test documents for testing the pipeline
# ============================================================================

set -e

echo "=========================================="
echo "Creating Test Documents"
echo "=========================================="
echo ""

# Create test directory
TEST_DIR="test_documents"
mkdir -p "$TEST_DIR"

# Create sample TXT documents
cat > "$TEST_DIR/contract_sample.txt" << 'EOF'
SERVICE AGREEMENT

This Service Agreement ("Agreement") is entered into as of November 17, 2025, by and between TechCorp Inc. ("Provider") and DataAnalytics LLC ("Client").

1. SERVICES
Provider agrees to provide cloud data analytics services to Client, including but not limited to data warehousing, ETL pipeline development, and business intelligence reporting.

2. TERM
This Agreement shall commence on December 1, 2025, and continue for a period of twelve (12) months unless terminated earlier in accordance with the terms herein.

3. COMPENSATION
Client agrees to pay Provider a monthly fee of $50,000 USD for the services rendered under this Agreement.

4. CONFIDENTIALITY
Both parties agree to maintain confidentiality of all proprietary information shared during the term of this Agreement.

5. TERMINATION
Either party may terminate this Agreement with 30 days written notice.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first written above.
EOF

cat > "$TEST_DIR/technical_manual.txt" << 'EOF'
SNOWFLAKE DATA WAREHOUSE TECHNICAL MANUAL

Chapter 1: Introduction to Snowflake Architecture

Snowflake is a cloud-native data platform that separates compute and storage, enabling independent scaling of resources. The architecture consists of three key layers:

1. Storage Layer
   - Stores all data in a columnar format
   - Automatically manages compression and encryption
   - Supports structured and semi-structured data (JSON, Avro, Parquet)

2. Compute Layer
   - Virtual warehouses execute queries
   - Multiple warehouses can access same data simultaneously
   - Auto-suspend and auto-resume capabilities

3. Cloud Services Layer
   - Authentication and access control
   - Query optimization and compilation
   - Metadata management

Chapter 2: Best Practices

When designing data pipelines in Snowflake:
- Use clustering keys for large tables
- Leverage materialized views for frequently accessed aggregations
- Implement proper role-based access control (RBAC)
- Monitor warehouse utilization and adjust sizes accordingly

Chapter 3: Performance Optimization

Key strategies for optimizing query performance:
- Partition pruning through proper table design
- Result caching at multiple levels
- Search optimization service for selective queries
- Query acceleration for complex analytical workloads
EOF

cat > "$TEST_DIR/invoice_sample.txt" << 'EOF'
INVOICE

Invoice Number: INV-2025-1117
Date: November 17, 2025
Due Date: December 17, 2025

Bill To:
DataAnalytics LLC
123 Business Park Drive
San Francisco, CA 94105

From:
TechCorp Inc.
456 Tech Plaza
Seattle, WA 98101

DESCRIPTION                                    AMOUNT
-----------------------------------------------------
Cloud Data Platform Subscription (Nov 2025)   $25,000.00
ETL Pipeline Development Services              $15,000.00
Data Engineering Consulting (80 hours)         $20,000.00
Premium Support Package                        $5,000.00
-----------------------------------------------------
SUBTOTAL:                                      $65,000.00
TAX (8.5%):                                    $5,525.00
-----------------------------------------------------
TOTAL DUE:                                     $70,525.00

Payment Terms: Net 30 days
Payment Methods: Wire Transfer, ACH, Check

Thank you for your business!
EOF

cat > "$TEST_DIR/policy_document.txt" << 'EOF'
DATA GOVERNANCE POLICY

Effective Date: November 17, 2025
Policy Owner: Chief Data Officer
Review Frequency: Annual

1. PURPOSE
This Data Governance Policy establishes the framework for managing data assets throughout their lifecycle, ensuring data quality, security, and compliance.

2. SCOPE
This policy applies to all data stored, processed, or transmitted by the organization, including:
- Customer data
- Financial records
- Operational data
- Analytics and reporting data

3. DATA CLASSIFICATION
Data shall be classified into four categories:
- Public: Information intended for public disclosure
- Internal: Information for internal use only
- Confidential: Sensitive business information
- Restricted: Highly sensitive data requiring special protection

4. DATA QUALITY STANDARDS
All data must meet the following quality criteria:
- Accuracy: Data must be correct and reliable
- Completeness: Required fields must be populated
- Consistency: Data must be consistent across systems
- Timeliness: Data must be current and available when needed

5. ACCESS CONTROL
Access to data shall be granted based on:
- Role-based access control (RBAC)
- Principle of least privilege
- Need-to-know basis
- Regular access reviews

6. DATA RETENTION
Data retention periods shall be based on:
- Legal and regulatory requirements
- Business needs
- Storage costs
- Data sensitivity

7. COMPLIANCE
This policy ensures compliance with:
- GDPR (General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- SOX (Sarbanes-Oxley Act)
- Industry-specific regulations
EOF

cat > "$TEST_DIR/email_sample.txt" << 'EOF'
From: john.smith@techcorp.com
To: analytics-team@dataanalytics.com
Subject: Q4 2025 Data Pipeline Implementation Update
Date: November 17, 2025 10:30 AM

Hi Team,

I wanted to provide an update on our Q4 data pipeline implementation project.

Progress Update:
1. Successfully deployed the Unstructured Data Vectorization Pipeline (UDVP) to our Snowflake environment
2. Completed integration with Cortex AI functions for document parsing and classification
3. Implemented dynamic tables with 5-minute refresh lag for continuous processing
4. Set up Cortex Search service for semantic search capabilities

Key Achievements:
- Processing 10,000+ documents per day with 99.9% success rate
- Average end-to-end latency of 3 minutes from upload to searchable embeddings
- Reduced manual document processing time by 95%
- Enabled semantic search across our entire document repository

Next Steps:
- Scale up to handle 100,000+ documents per day
- Implement advanced classification models
- Add support for additional document formats
- Create user-facing search interface

Please review the attached technical documentation and let me know if you have any questions.

Best regards,
John Smith
Senior Data Engineer
TechCorp Inc.
EOF

echo "✅ Test documents created in: $TEST_DIR"
echo ""
echo "Files created:"
ls -lh "$TEST_DIR"
echo ""
echo "To upload these to Snowflake, run:"
echo "  snow sql -q \"PUT file://$(pwd)/$TEST_DIR/* @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE\" -c cursor"
echo "  snow sql -q \"ALTER STAGE UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE REFRESH\" -c cursor"

