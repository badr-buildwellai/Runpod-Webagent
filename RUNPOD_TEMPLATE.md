# 🚀 RunPod Configuration Template for WebAgent

## Quick Template Configuration

When creating your RunPod pod, use these settings for optimal WebAgent deployment:

### 🖥️ **Template Configuration**

**Base Template**: `PyTorch 2.0+` or `Ubuntu 22.04 + CUDA 12.1+`

**Container Settings**:
```
Image: runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel-ubuntu22.04
Ports: 7860, 30000
Volume Size: 100GB+
```

### 🔑 **Environment Variables (Global Secrets)**

**IMPORTANT**: Add these as environment variables in your RunPod template for secure, automatic API key management:

```bash
# Search API Keys (Required for full functionality)
GOOGLE_SEARCH_KEY=your_serper_key_here
JINA_API_KEY=your_jina_key_here  
DASHSCOPE_API_KEY=your_dashscope_key_here

# Optional: Custom ports
WEBDANCER_PORT=30000
```

### 🔗 **API Key Sources**

1. **GOOGLE_SEARCH_KEY**: Get from [serper.dev](https://serper.dev/)
   - Free tier: 2,500 searches/month
   - Used for web search functionality

2. **JINA_API_KEY**: Get from [jina.ai/api-dashboard](https://jina.ai/api-dashboard/)
   - Free tier: 1M tokens/month
   - Used for text processing and embeddings

3. **DASHSCOPE_API_KEY**: Get from [dashscope.aliyun.com](https://dashscope.aliyun.com/)
   - Alibaba's AI service platform
   - Used for additional LLM capabilities

---

## 🎯 Complete RunPod Template JSON

Copy this template configuration for easy setup:

```json
{
  "name": "WebAgent-Optimized",
  "imageUri": "runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel-ubuntu22.04",
  "dockerArgs": "",
  "ports": "7860/http,30000/http",
  "volumeInGb": 100,
  "volumeMountPath": "/workspace",
  "env": [
    {
      "key": "GOOGLE_SEARCH_KEY",
      "value": "your_serper_key_here"
    },
    {
      "key": "JINA_API_KEY", 
      "value": "your_jina_key_here"
    },
    {
      "key": "DASHSCOPE_API_KEY",
      "value": "your_dashscope_key_here"
    }
  ],
  "startJupyter": true,
  "startSsh": true
}
```

---

## 🚀 **One-Click Setup Commands**

Once your pod is running, execute this single command:

```bash
# Clone and auto-deploy WebAgent
git clone https://github.com/badr-buildwellai/Runpod-Webagent.git && \
cd Runpod-Webagent && \
./setup_and_run.sh
```

**This will:**
- ✅ Auto-detect your GPU configuration
- ✅ Download WebDancer-32B model with parallel downloads
- ✅ Configure optimal tensor parallelism
- ✅ Load API keys from RunPod environment variables
- ✅ Start WebDancer demo on `http://0.0.0.0:7860`

---

## 🎯 **GPU Recommendations by Use Case**

### **Development/Testing**
- **RTX 4090 (24GB)** - $0.50-0.70/hr - Perfect balance
- **RTX 3090 (24GB)** - $0.40-0.60/hr - Great value

### **Production/Demo**  
- **A6000 (48GB)** - $0.80-1.20/hr - Professional reliability
- **A100 (80GB)** - $1.50-2.50/hr - Enterprise performance

### **Budget/Multi-GPU**
- **2x RTX 4080 (16GB each)** - $0.70-1.10/hr total
- **2x RTX 3080 Ti (12GB each)** - $0.60-0.90/hr total

---

## 🔧 **Advanced RunPod Configuration**

### **Custom Startup Script**

Add this to your template's startup script:

```bash
#!/bin/bash
cd /workspace
git clone https://github.com/badr-buildwellai/Runpod-Webagent.git
cd Runpod-Webagent
./setup_and_run.sh --auto-start
```

### **Persistent Storage Setup**

For model persistence across pod restarts:

```bash
# Create persistent model storage
mkdir -p /workspace/persistent/models
ln -s /workspace/persistent/models /workspace/Runpod-Webagent/models

# Models will persist across pod restarts
```

### **Multi-GPU Template**

For tensor parallelism across multiple GPUs:

```bash
# The setup script auto-detects multi-GPU configurations
# No additional configuration needed
```

---

## 🆘 **Troubleshooting RunPod Setup**

### **Issue**: API keys not working
**Solution**: 
```bash
# Check if environment variables are set
echo "GOOGLE_SEARCH_KEY: $GOOGLE_SEARCH_KEY"
echo "JINA_API_KEY: $JINA_API_KEY"  
echo "DASHSCOPE_API_KEY: $DASHSCOPE_API_KEY"

# If empty, add them to your RunPod template
```

### **Issue**: Port not accessible externally
**Solution**:
```bash
# Ensure ports are exposed in RunPod configuration
# WebDancer demo: 7860
# Model API: 30000
```

### **Issue**: Out of storage space
**Solution**:
```bash
# Increase volume size to 150GB+ for models
# Or use persistent storage for models
```

---

## 🎉 **Ready to Deploy!**

With this template configuration, your RunPod pod will have:

- ✅ **Automatic API key management** via environment variables
- ✅ **Optimal GPU configuration** detection
- ✅ **One-command deployment** of WebAgent
- ✅ **Persistent model storage** options
- ✅ **External network access** for demos
- ✅ **Professional monitoring** and health checks

**Start your pod and run `./setup_and_run.sh` - WebAgent will be ready in minutes!**