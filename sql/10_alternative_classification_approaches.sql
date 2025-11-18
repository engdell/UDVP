-- ============================================================================
-- Alternative Classification Approaches
-- Different methods for classifying documents in UDVP
-- ============================================================================

USE DATABASE UDVP_DB;
USE SCHEMA UDVP_SCHEMA;
USE WAREHOUSE UDVP_WH;

-- ============================================================================
-- APPROACH 1: Truly Open-Ended with AI_COMPLETE (Recommended)
-- ============================================================================
-- Allows AI to determine any document type without constraints

/*
AI_COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'system',
            'content': 'You are a document classification assistant. Analyze the document and provide a concise classification category (1-3 words maximum). Be specific about the document type.'
        },
        {
            'role': 'user',
            'content': CONCAT('Classify this document. Respond with only the document type. Document text: ', document_text)
        }
    ],
    {
        'max_tokens': 20,
        'temperature': 0.1
    }
):choices[0]:messages
*/

-- ============================================================================
-- APPROACH 2: Constrained with AI_CLASSIFY (Current Default)
-- ============================================================================
-- Faster but limited to predefined categories

/*
AI_CLASSIFY(
    document_text,
    ['Contract', 'Invoice', 'Technical Manual', 'Report', 'Email', 'Letter', 'Form', 'Policy', 'Agreement', 'Other']
)
*/

-- ============================================================================
-- APPROACH 3: Hierarchical Classification with AI_COMPLETE
-- ============================================================================
-- Provides category + subcategory for more detailed classification

/*
AI_COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'system',
            'content': 'You are a document classification assistant. Classify documents into a category and subcategory. Format: "Category: Subcategory" (e.g., "Legal: Employment Contract", "Financial: Invoice")'
        },
        {
            'role': 'user',
            'content': CONCAT('Classify this document with category and subcategory. Document text: ', document_text)
        }
    ],
    {
        'max_tokens': 30,
        'temperature': 0.1
    }
):choices[0]:messages
*/

-- ============================================================================
-- APPROACH 4: Multi-Label Classification
-- ============================================================================
-- Assigns multiple tags to a document

/*
AI_COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'system',
            'content': 'You are a document tagging assistant. Provide 2-4 relevant tags for the document, separated by commas.'
        },
        {
            'role': 'user',
            'content': CONCAT('Tag this document with relevant categories. Document text: ', document_text)
        }
    ],
    {
        'max_tokens': 50,
        'temperature': 0.1
    }
):choices[0]:messages
*/

-- ============================================================================
-- APPROACH 5: Structured JSON Classification with Confidence
-- ============================================================================
-- Returns classification with metadata and confidence score

/*
AI_COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'system',
            'content': 'You are a document classification assistant. Respond in JSON format: {"category": "...", "subcategory": "...", "confidence": "high/medium/low", "reasoning": "brief explanation"}'
        },
        {
            'role': 'user',
            'content': CONCAT('Classify this document and explain your reasoning. Document text: ', document_text)
        }
    ],
    {
        'max_tokens': 100,
        'temperature': 0.1
    }
):choices[0]:messages
*/

-- ============================================================================
-- APPROACH 6: Domain-Specific with Examples (Few-Shot Learning)
-- ============================================================================
-- Provides examples to guide classification

/*
AI_COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'system',
            'content': 'You are a document classification assistant. Examples:
            - "This Service Agreement..." → "Legal Contract"
            - "Invoice #12345..." → "Financial Invoice"
            - "Technical specifications for..." → "Technical Documentation"
            Classify the following document similarly.'
        },
        {
            'role': 'user',
            'content': CONCAT('Classify this document: ', document_text)
        }
    ],
    {
        'max_tokens': 30,
        'temperature': 0.1
    }
):choices[0]:messages
*/

-- ============================================================================
-- Example: Update Task to Use Open-Ended Classification
-- ============================================================================

-- To switch to truly open-ended classification, replace the CLASSIFICATION 
-- field in PROCESS_DOCUMENTS_TASK with Approach 1 above

SELECT 'Alternative classification approaches documented' AS STATUS;
SELECT 'Choose the approach that best fits your use case' AS INFO;

