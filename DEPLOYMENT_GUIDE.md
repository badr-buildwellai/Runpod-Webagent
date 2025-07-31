# WebAgent Deployment Troubleshooting Guide

## Current Issue Summary
The WebDancer demo is failing because the model server is not running on port 8004. The error shows: `Connection refused` when trying to connect to `http://127.0.0.1:8004/v1`.

## Root Cause Analysis
1. **No Model Server Running**: Port 8004 is not occupied by any service
2. **Missing Model Files**: WebDancer-32B model needs to be downloaded (currently downloading with aria2c)
3. **Fixed Dependencies**: libnuma.so.1 was missing but has been installed
4. **CUDA Compatibility Warning**: GPU supports sm_120 but PyTorch only supports up to sm_90

## Step-by-Step Fix

### 1. Wait for Model Download to Complete
The WebDancer-32B model is currently being downloaded using aria2c. This is a large model (~60GB+) with 14 safetensor files.

**Current Status**: Downloading with aria2c (8 connections, 3 parallel downloads)
**Location**: `/workspace/WebAgent/models/`

### 2. Start the Model Server
Once download completes, deploy the model server:

```bash
# Activate virtual environment
source /workspace/WebAgent/webagent_env/bin/activate

# Deploy model server
cd /workspace/WebAgent/WebDancer/scripts
bash deploy_model.sh /workspace/WebAgent/models

# Alternative manual deployment:
python -m sglang.launch_server --model-path /workspace/WebAgent/models --host 0.0.0.0 --tp 4 --port 8004
```

### 3. Verify Model Server is Running
```bash
# Check if port 8004 is listening
ss -tulpn | grep :8004

# Test API endpoint
curl http://localhost:8004/v1/models
```

### 4. Configure Environment Variables
Make sure your `.env` file is properly configured:
```bash
# Copy example file
cp .env.example .env

# Edit with your API keys
# GOOGLE_SEARCH_KEY=your_serper_key
# JINA_API_KEY=your_jina_key  
# DASHSCOPE_API_KEY=your_dashscope_key
```

### 5. Start WebDancer Demo
```bash
cd /workspace/WebAgent/WebDancer/scripts
bash run_demo.sh
```

## Known Issues & Solutions

### Issue: CUDA Compatibility Warning
**Warning**: NVIDIA RTX PRO 6000 Blackwell with sm_120 not compatible with current PyTorch
**Impact**: May affect GPU acceleration but shouldn't prevent CPU inference
**Solution**: Consider upgrading PyTorch for better GPU support

### Issue: Tensor Parallelism (--tp 4)
**Current**: Deployment script uses --tp 4 (4-way tensor parallelism)
**Requirement**: Needs 4 GPUs or adjust to available GPU count
**Solution**: Modify deploy_model.sh to match your hardware

### Issue: Memory Requirements
**WebDancer-32B**: Requires significant RAM/VRAM
**Minimum**: 64GB RAM or appropriate GPU memory
**Solution**: Use smaller model or increase swap if needed

## Alternative Solutions

### Option 1: Use Smaller Model
If hardware is insufficient, consider using a smaller model or CPU-only inference.

### Option 2: External Model Service
Point to an external API service instead of local deployment:
```python
# In WebDancer/demos/llm/oai.py
# Modify model_server to point to external service
'model_server': 'https://your-external-api-endpoint/v1'
```

### Option 3: Mock Server for Testing
Create a simple mock server for testing the UI:
```bash
# Simple test server on port 8004
python -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class MockHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {'choices': [{'message': {'content': 'Mock response'}}]}
        self.wfile.write(json.dumps(response).encode())

HTTPServer(('0.0.0.0', 8004), MockHandler).serve_forever()
"
```

## Next Steps
1. Monitor aria2c download progress
2. Once complete, test model server deployment
3. Verify API endpoints are responding
4. Test WebDancer demo functionality
5. Configure proper API keys for full functionality

## Monitoring Download Progress
```bash
# Check download status
cd /workspace/WebAgent/models
ls -lah *.safetensors

# Monitor aria2c progress
# (Currently running in background)
```