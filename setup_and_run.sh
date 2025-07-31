#!/bin/bash

# WebAgent Setup and Run Script
# This script sets up a virtual environment, installs dependencies, and runs the WebDancer demo

set -e  # Exit on any error

echo "🚀 Setting up WebAgent environment..."

# Check if Python 3.12 is available, fallback to python3
PYTHON_CMD="python3.12"
if ! command -v $PYTHON_CMD &> /dev/null; then
    echo "⚠️  Python 3.12 not found, using python3"
    PYTHON_CMD="python3"
fi

# Create virtual environment
echo "📦 Creating virtual environment..."
$PYTHON_CMD -m venv webagent_env

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source webagent_env/bin/activate

# Function to check if requirements are already satisfied
check_requirements() {
    local req_file="$1"
    local component_name="$2"
    
    if [ ! -f "$req_file" ]; then
        return 1
    fi
    
    echo "🔍 Checking $component_name requirements..."
    
    # Create a temporary file to capture output
    local temp_output=$(mktemp)
    
    # Try to install with --dry-run to see what would be installed
    if pip install --dry-run -r "$req_file" > "$temp_output" 2>&1; then
        # Count how many packages would be installed (not already satisfied)
        local install_count=$(grep -c "Would install" "$temp_output" 2>/dev/null || echo "0")
        local satisfied_count=$(grep -c "Requirement already satisfied" "$temp_output" 2>/dev/null || echo "0")
        
        rm -f "$temp_output"
        
        if [ "$install_count" -eq 0 ] && [ "$satisfied_count" -gt 0 ]; then
            echo "✅ $component_name requirements already satisfied"
            return 0
        else
            echo "📦 Installing $component_name requirements ($install_count packages need installation)..."
            return 1
        fi
    else
        rm -f "$temp_output"
        echo "📦 Installing $component_name requirements (unable to verify current state)..."
        return 1
    fi
}

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install WebDancer requirements with version checking
cd WebDancer
if ! check_requirements "requirements.txt" "WebDancer"; then
    # Install requirements - let pip resolve aiofiles version automatically
    # Based on research: Gradio 5.23.1 supports aiofiles>=22.0,<25.0
    # and Crawl4AI 0.7.2 requires aiofiles>=24.1.0
    # aiofiles 24.1.0 satisfies both requirements
    pip install -r requirements.txt
fi
cd ..

# Check for other component requirements and install them
echo "📚 Checking other component dependencies..."

if [ -f "WebSailor/requirements.txt" ]; then
    if ! check_requirements "WebSailor/requirements.txt" "WebSailor"; then
        pip install -r WebSailor/requirements.txt
    fi
fi

if [ -f "WebWalker/requirements.txt" ]; then
    if ! check_requirements "WebWalker/requirements.txt" "WebWalker"; then
        pip install -r WebWalker/requirements.txt
    fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔑 Before running the demo, you need to set up API keys:"
echo "   1. Copy .env.example to .env: cp .env.example .env"
echo "   2. Edit .env and add your API keys:"
echo "      - GOOGLE_SEARCH_KEY from https://serper.dev/"
echo "      - JINA_API_KEY from https://jina.ai/api-dashboard/"
echo "      - DASHSCOPE_API_KEY from https://dashscope.aliyun.com/"
echo ""
echo "🎯 To run the WebDancer demo:"
echo "   source webagent_env/bin/activate"
echo "   cd WebDancer/scripts"
echo "   bash run_demo.sh"
echo ""
echo "🎯 To run WebWalker:"
echo "   source webagent_env/bin/activate"
echo "   cd WebWalker/src"
echo "   python app.py"
echo ""

# Ask if user wants to run the demo now
read -p "🚀 Do you want to run the WebDancer demo now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Starting WebDancer demo..."
    cd WebDancer/scripts
    bash run_demo.sh
fi