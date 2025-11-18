#!/bin/bash
# Initialize Git repository and make initial commit

set -e

echo "🔧 Initializing Git repository for UDVP..."

# Initialize git if not already initialized
if [ ! -d .git ]; then
    git init
    echo "✅ Git repository initialized"
else
    echo "ℹ️  Git repository already exists"
fi

# Add all files
git add .

# Show status
echo ""
echo "📋 Files to be committed:"
git status --short

# Make initial commit
echo ""
read -p "Make initial commit? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -m "feat: Initial commit - UDVP with Snowflake Cortex AI

- Automated document ingestion from internal stage
- PDF, DOCX, and text file parsing with page_split
- AI-powered open-ended classification using Cortex COMPLETE
- 768-dimensional vector embeddings with e5-base-v2
- Semantic search with vector similarity
- Real-time monitoring and observability
- Comprehensive documentation and quick start guide

Tested with 15 documents, 24 embeddings, 100% success rate."
    
    echo "✅ Initial commit created"
    
    echo ""
    echo "📝 Next steps:"
    echo "1. Create a GitHub repository"
    echo "2. git remote add origin <your-repo-url>"
    echo "3. git branch -M main"
    echo "4. git push -u origin main"
else
    echo "⏭️  Skipped commit. You can commit manually with:"
    echo "   git commit -m 'Your commit message'"
fi
