# Contributing to UDVP

Thank you for your interest in contributing to the Unstructured Data Vectorization Pipeline!

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/udvp.git
   cd udvp
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Snowflake account with appropriate permissions
- Snowflake CLI installed
- Access to Cortex AI functions (PARSE_DOCUMENT, COMPLETE, EMBED_TEXT_768)

### Configuration

1. Configure your Snowflake connection:
   ```bash
   snow connection add
   ```

2. Update `snowflake.yml` if needed for your environment

3. Test your setup:
   ```bash
   bash deploy.sh
   ```

## Making Changes

### Code Style

- **SQL Files**: Use uppercase for SQL keywords, lowercase for identifiers
- **Comments**: Add clear comments explaining complex logic
- **Documentation**: Update README.md if adding new features

### Testing

Before submitting a PR:

1. **Deploy and test** your changes:
   ```bash
   bash deploy.sh
   ```

2. **Verify pipeline health**:
   ```sql
   SELECT * FROM UDVP_DB.UDVP_SCHEMA.PIPELINE_HEALTH;
   ```

3. **Test with sample documents**:
   ```bash
   bash test_documents.sh
   PUT file://test_documents/* @UDVP_DB.UDVP_SCHEMA.RAW_DOCUMENTS_STAGE;
   ```

4. **Check monitoring views**:
   ```sql
   SELECT * FROM UDVP_DB.UDVP_SCHEMA.FAILED_DOCUMENTS;
   SELECT * FROM UDVP_DB.UDVP_SCHEMA.PROCESSING_LATENCY;
   ```

## Submitting Changes

1. **Commit your changes** with clear messages:
   ```bash
   git add .
   git commit -m "feat: Add support for new document format"
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request** on GitHub with:
   - Clear description of changes
   - Test results
   - Screenshots if applicable

## Pull Request Guidelines

### PR Title Format
- `feat: Add new feature`
- `fix: Fix bug in parsing`
- `docs: Update README`
- `perf: Improve embedding performance`
- `refactor: Restructure SQL files`

### PR Description Should Include
- What changed and why
- Testing performed
- Breaking changes (if any)
- Related issues

## Code Review Process

1. Maintainers will review your PR
2. Address any feedback
3. Once approved, your PR will be merged

## Areas for Contribution

### High Priority
- Support for additional document formats (HTML, RTF, etc.)
- Performance optimizations for large-scale deployments
- Enhanced classification models and prompts
- Cost optimization strategies
- Additional monitoring and alerting capabilities

### Documentation
- Tutorial videos
- Use case examples
- Troubleshooting guides
- Architecture diagrams

### Testing
- Automated test suites
- Performance benchmarks
- Integration tests

## Questions?

- Open an issue for bugs or feature requests
- Use discussions for questions and ideas
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to UDVP! 🚀

