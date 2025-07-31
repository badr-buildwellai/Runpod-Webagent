#!/bin/bash

cd $(dirname $0) || exit

# Function to load environment variables with RunPod secrets priority
load_env_vars() {
    echo "🔑 Loading environment variables..."
    
    # Check for RunPod global variables (secrets) first
    if [ -n "$RUNPOD_AI_API_KEY" ] || [ -n "$GOOGLE_SEARCH_KEY" ] || [ -n "$JINA_API_KEY" ] || [ -n "$DASHSCOPE_API_KEY" ]; then
        echo "✅ Found RunPod global variables (secrets)"
        
        # Use RunPod secrets if available, otherwise try to load from .env
        export GOOGLE_SEARCH_KEY="${GOOGLE_SEARCH_KEY:-}"
        export JINA_API_KEY="${JINA_API_KEY:-}"
        export DASHSCOPE_API_KEY="${DASHSCOPE_API_KEY:-}"
        
        # Check if we have all required keys
        missing_keys=()
        [ -z "$GOOGLE_SEARCH_KEY" ] && missing_keys+=("GOOGLE_SEARCH_KEY")
        [ -z "$JINA_API_KEY" ] && missing_keys+=("JINA_API_KEY")
        [ -z "$DASHSCOPE_API_KEY" ] && missing_keys+=("DASHSCOPE_API_KEY")
        
        if [ ${#missing_keys[@]} -gt 0 ]; then
            echo "⚠️  Missing RunPod secrets: ${missing_keys[*]}"
            echo "💡 Add these as global variables in your RunPod template"
            echo "   Or create a .env file as fallback"
        fi
    else
        echo "🔍 No RunPod global variables found, checking .env file..."
    fi
    
    # Load from .env file as fallback or if RunPod secrets are incomplete
    ENV_FILE="../../.env"
    if [ -f "$ENV_FILE" ]; then
        echo "📁 Loading environment variables from $ENV_FILE"
        # Only export if not already set (preserves RunPod secrets)
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^[[:space:]]*# ]] && continue
            [[ -z $key ]] && continue
            
            # Only set if not already defined (RunPod secrets take priority)
            if [ -z "${!key}" ]; then
                export "$key=$value"
            fi
        done < <(grep -v '^[[:space:]]*#' "$ENV_FILE" | grep -v '^[[:space:]]*$')
    else
        echo "⚠️  No .env file found at $ENV_FILE"
        echo "💡 RunPod Setup:"
        echo "   1. Add secrets to RunPod template:"
        echo "      - GOOGLE_SEARCH_KEY (from https://serper.dev/)"
        echo "      - JINA_API_KEY (from https://jina.ai/api-dashboard/)"
        echo "      - DASHSCOPE_API_KEY (from https://dashscope.aliyun.com/)"
        echo "   2. Or create .env file: cp .env.example .env"
        
        # Check if we have any API keys at all
        if [ -z "$GOOGLE_SEARCH_KEY" ] && [ -z "$JINA_API_KEY" ] && [ -z "$DASHSCOPE_API_KEY" ]; then
            echo "❌ No API keys found in RunPod secrets or .env file"
            echo "   WebDancer will start but search functionality will be limited"
        fi
    fi
    
    # Show what we have
    echo "🔧 Configuration:"
    echo "   GOOGLE_SEARCH_KEY: $([ -n "$GOOGLE_SEARCH_KEY" ] && echo "✅ Set" || echo "❌ Missing")"
    echo "   JINA_API_KEY: $([ -n "$JINA_API_KEY" ] && echo "✅ Set" || echo "❌ Missing")"
    echo "   DASHSCOPE_API_KEY: $([ -n "$DASHSCOPE_API_KEY" ] && echo "✅ Set" || echo "❌ Missing")"
}

# Load environment variables
load_env_vars

cd ..

echo "🚀 Starting WebDancer demo..."
python -m demos.assistant_qwq_chat