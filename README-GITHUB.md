# Unstructured Data Vectorization Pipeline (UDVP)

[![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![Cortex AI](https://img.shields.io/badge/Cortex_AI-Powered-blue?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> 🚀 **Production-ready pipeline** for transforming unstructured documents into searchable vector embeddings using Snowflake and Cortex AI.

---

## ✨ Features

- 📄 **Multi-Format Support**: PDF, DOCX, TXT, and more
- 🤖 **AI-Powered Classification**: Open-ended document classification using LLMs
- 🧩 **Smart Chunking**: Automatic page-level splitting for optimal embedding
- 🔍 **Semantic Search**: Vector similarity search with 768-dimensional embeddings
- 📊 **Real-Time Monitoring**: Built-in observability and pipeline health tracking
- ⚡ **Fully Automated**: Scheduled tasks process documents every 5 minutes
- 🏗️ **Scalable Architecture**: Built on Snowflake's serverless platform

## 🎯 Quick Start

### Prerequisites

- Snowflake account with Cortex AI access
- Snowflake CLI installed
- Access to `PARSE_DOCUMENT`, `COMPLETE`, and `EMBED_TEXT_768` functions

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/udvp.git
cd udvp

# Configure Snowflake connection
snow connection add

# Deploy the pipeline
bash deploy.sh
```

### Upload Documents

```bash
# Upload documents to the internal stage
snow sql -q "PUT file://path/to/documents/* @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE" -c cursor
```

### Search Your Documents

```sql
-- Semantic search example
WITH search_vector AS (
    SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2', 'payment terms') AS query_embedding
)
SELECT
    FILE_PATH,
    TEXT_CHUNK,
    VECTOR_COSINE_SIMILARITY(VECTOR_EMBEDDING, query_embedding) AS SIMILARITY
FROM UDVP_DB.UDVP_SCHEMA.DOC_EMBEDDINGS
CROSS JOIN search_vector
ORDER BY SIMILARITY DESC
LIMIT 10;
```

## 🏗️ Architecture

```
┌─────────────────┐
│ Internal Stage  │  ← Upload documents (PDF, DOCX, TXT)
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ PROCESS_DOCUMENTS_TASK  │  ← Runs every 5 minutes
│ • Parse (page_split)    │
│ • Classify (AI)         │
└────────┬────────────────┘
         │
         ▼
┌─────────────────┐
│ PARSED_DOCUMENTS│  ← Full text + classifications
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ DOC_EMBEDDINGS  │  ← 768-dim vectors for search
│ Dynamic Table   │
└─────────────────┘
```

## 📊 Performance

Tested with real-world documents:
- ✅ **15 documents** processed successfully
- ✅ **24 vector embeddings** generated
- ✅ **100% success rate**
- ✅ **87% semantic similarity** on relevant queries
- ⚡ **~30 seconds** average processing time per document

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| Platform | Snowflake Data Cloud |
| Document Parsing | Cortex AI PARSE_DOCUMENT |
| Classification | Cortex AI COMPLETE (mistral-large2) |
| Embeddings | Cortex AI EMBED_TEXT_768 (e5-base-v2) |
| Orchestration | Snowflake Tasks & Dynamic Tables |
| Storage | Internal Stages & Tables |

## 📚 Documentation

- [Quick Start Guide](QUICK_START.md) - Get up and running fast
- [Project Structure](PROJECT_STRUCTURE.md) - Code organization
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [Git Setup](GIT_SETUP_GUIDE.md) - Version control setup
- [Test Results](PIPELINE_TEST_RESULTS.md) - Validation and testing

## 🔍 Example Use Cases

1. **Contract Management**: Search across legal documents for specific clauses
2. **Policy Q&A**: Find relevant sections in company policies
3. **Technical Documentation**: Semantic search through manuals and guides
4. **Email Archives**: Search historical correspondence
5. **Research Papers**: Find related content across academic documents

## 🚀 Advanced Features

### AI Classification

```sql
-- Open-ended classification automatically categorizes documents
SELECT CLASSIFICATION, COUNT(*) 
FROM UDVP_DB.UDVP_SCHEMA.PARSED_DOCUMENTS
GROUP BY CLASSIFICATION;

-- Results:
-- CONTRACT AMENDMENT      | 4
-- Service Agreement       | 4
-- Logistics Contract      | 2
-- Marketing Agreement     | 2
```

### Monitoring

```sql
-- Pipeline health at a glance
SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH;

-- Track processing latency
SELECT * FROM UDVP_DB.UDVP_SCHEMA.PROCESSING_LATENCY;

-- Identify failures
SELECT * FROM UDVP_DB.UDVP_SCHEMA.FAILED_DOCUMENTS;
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Snowflake Cortex AI team for powerful AI functions
- The open-source community for inspiration and tools

## 📞 Support

- 🐛 [Report a Bug](https://github.com/YOUR_USERNAME/udvp/issues)
- 💡 [Request a Feature](https://github.com/YOUR_USERNAME/udvp/issues)
- 💬 [Discussions](https://github.com/YOUR_USERNAME/udvp/discussions)

---

**Made with ❤️ using Snowflake and Cortex AI**

⭐ Star this repo if you find it useful!
