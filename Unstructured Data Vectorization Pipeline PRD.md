---

# **🚀 Product Requirements Document (PRD): Unstructured Data Ingestion and Vectorization Pipeline**

| Attribute | Value |
| :---- | :---- |
| **Product Name** | Unstructured Data Vectorization Pipeline (UDVP) |
| **Target System** | Snowflake Data Cloud |
| **Target Users** | Data Scientists, Search Engineers, Analytics Teams |
| **Document Version** | 1.0 |
| **Date** | November 17, 2025 |

---

## **1\. 🎯 Goal & Objectives**

### **1.1. Goal**

To establish a **managed, continuous, and scalable data pipeline within Snowflake** that automatically ingests unstructured documents, extracts their content, classifies them, chunks the text, and generates high-quality vector embeddings for consumption by downstream search and AI services (e.g., Snowflake Cortex Search).

### **1.2. Key Objectives**

* **Continuous Flow:** Support a continuous flow of new documents with configurable latency.  
* **Management Simplicity:** Utilize Snowflake's managed services (Stages, Streams, Dynamic Tables) to minimize operational overhead.  
* **Vectorization Output:** Produce a **Dynamic Table** containing text chunks, corresponding vector embeddings, and crucial metadata for retrieval-augmented generation (RAG) and semantic search.  
* **Core Feature Utilization:** Leverage Snowflake **Cortex AI Functions** (AI\_PARSE\_DOCUMENT, AI\_CLASSIFY) for automated document processing.  
* **Format Flexibility:** Handle various supported document formats (PDF, DOCX, TXT, etc.).

---

## **2\. 🏗️ Pipeline Design & Requirements**

The pipeline follows the proposed design, using Snowflake's native capabilities for a **declarative, continuous ETL/ELT** process.

### **2.1. Ingestion Stage: Unstructured Data Stage & Stream**

| Component | Requirement | Detail |
| :---- | :---- | :---- |
| **Source Stage** | **External Stage** (S3/Azure Blob/GCS) | Must be configured to point to the raw document repository. |
| **File Formats** | **Compatibility** | Must support all file formats compatible with SNOWFLAKE.CORTEX.AI\_PARSE\_DOCUMENT. |
| **Directory Table** | **Tracking** | A **Directory Table** must be created over the Stage to expose file metadata (e.g., RELATIVE\_PATH, SIZE). |
| **Stream** | **Change Data Capture (CDC)** | A **Stream** must be created on the **Directory Table** to track new or updated files, ensuring a continuous flow. |

### **2.2. Processing Stage: AI Functions & Classification**

This stage will be implemented as a **Dynamic Table** to manage dependencies and continuous updates automatically.

#### **Step 1: Document Parsing**

* **Function:** SNOWFLAKE.CORTEX.AI\_PARSE\_DOCUMENT  
* **Input:** Raw document binary (@Stage/path/file.ext).  
* **Output:** Structured text content for the document.  
* **Requirement:** The Dynamic Table must join the Stream data with the raw document Stage data to execute the parsing function upon new file arrival.

#### **Step 2: Open-Ended Classification**

* **Function:** SNOWFLAKE.CORTEX.AI\_CLASSIFY  
* **Input:** The parsed text content from Step 1\.  
* **Requirement:** The classification must be **open-ended**, allowing for custom labels (e.g., *Contract*, *Invoice*, *Technical Manual*). This result will be stored as a key piece of metadata.

### **2.3. Output Stage: Chunking and Vectorization**

The final stage produces the output table optimized for Cortex Search.

#### **Step 3: Text Chunking and Embedding**

* **Chunking:** The parsed, classified text is broken down into smaller, semantically meaningful **chunks**.  
  * **Tooling:** Use a **SQL UDF** or **External Function** (if necessary) to manage chunk size and overlap, ensuring high-quality input for vectorization. A simpler approach would be to use a **FLATTEN** operation on a structured array of chunks generated in a preceding step.  
* **Vector Embedding:**  
  * **Function:** SNOWFLAKE.CORTEX.EMBED\_TEXT  
  * **Input:** Each generated text chunk.  
  * **Output:** A high-dimensional **VECTOR** for each chunk.

### **2.4. Deliverable: Snowflake Dynamic Table**

The final output must be a **Dynamic Table** (DOC\_EMBEDDINGS) with the following schema:

| Column Name | Data Type | Purpose |
| :---- | :---- | :---- |
| FILE\_PATH | VARCHAR | Full path to the original document in the Stage (Reference). |
| DOCUMENT\_ID | VARCHAR | Unique ID for the document (e.g., hash of FILE\_PATH). |
| CLASSIFICATION | VARCHAR | Result from AI\_CLASSIFY. |
| CHUNK\_ID | INTEGER | Index of the chunk within the document. |
| **TEXT\_CHUNK** | VARCHAR | The specific text segment. |
| **VECTOR\_EMBEDDING** | VECTOR | The result of EMBED\_TEXT on the TEXT\_CHUNK. |

---

## **3\. 🛡️ Non-Functional Requirements (NFRs)**

| Category | Requirement | Description |
| :---- | :---- | :---- |
| **Scalability** | **Cloud Services Utilization** | Must utilize Snowflake's automatic scaling and compute management to handle burst loads of document ingestion. |
| **Cost Management** | **Dynamic Table Configuration** | Dynamic Table refresh frequency (TARGET\_LAG) must be configured to balance freshness with compute cost (e.g., TARGET\_LAG \= '5 minutes'). |
| **Security** | **Data Access** | Access to the raw Stage and the final Dynamic Table must be restricted using appropriate Role-Based Access Control (RBAC). |
| **Observability** | **Monitoring** | Pipeline activity (latency, failures, row count) must be monitored via **Query History** and **ACCOUNT\_USAGE** views. Error handling should log failed file paths. |

---

## **4\. ✅ Acceptance Criteria**

The pipeline is considered complete and operational when the following criteria are met:

1. **Stage to Output Latency:** New files dropped into the Stage appear in the DOC\_EMBEDDINGS Dynamic Table (fully processed with embeddings) within the defined TARGET\_LAG.  
2. **Functionality:** A test set of documents (PDF, DOCX, TXT) successfully passes through all AI\_PARSE\_DOCUMENT, AI\_CLASSIFY, and EMBED\_TEXT steps without error.  
3. **Search Readiness:** The DOC\_EMBEDDINGS table is successfully registered and consumed by a test **Snowflake Cortex Search** Service, enabling accurate semantic search queries.  
4. **Metadata Integrity:** The FILE\_PATH and CLASSIFICATION columns are correctly populated for every record in the output Dynamic Table.

---

