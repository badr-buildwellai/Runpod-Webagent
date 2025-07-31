#!/bin/bash

cd $(dirname $0) || exit

# Load environment variables from .env file in parent directory
ENV_FILE="../../.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Warning: .env file not found at $ENV_FILE"
    echo "Please copy .env.example to .env and fill in your API keys"
    exit 1
fi

cd ..

python -m demos.assistant_qwq_chat