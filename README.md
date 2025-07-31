# RunPod WebAgent - Optimized for Cloud Deployment

<div align="center">

<h2>WebAgent for Information Seeking + RunPod Optimization <img src="./assets/tongyi.png" width="30px" style="display:inline;"></h2>

**One-Click Cloud Deployment with Automatic GPU Detection**

</div>

<p align="center">
🤗 <a href="https://huggingface.co/datasets/Alibaba-NLP/WebShaper" target="_blank">WebShaperQA</a> ｜
🤗 <a href="https://huggingface.co/Alibaba-NLP/WebSailor-3B" target="_blank">WebSailor-3B</a> ｜
🤗 <a href="https://huggingface.co/Alibaba-NLP/WebDancer-32B" target="_blank">WebDancer-QwQ-32B</a> ｜
🤗 <a href="https://huggingface.co/datasets/callanwu/WebWalkerQA" target="_blank">WebWalkerQA</a>
</p>

> 🚀 **NEW**: One-click RunPod deployment with automatic GPU detection and optimization!

## 📰 What's New in This Fork

- ✅ **RunPod Optimized Deployment** - Automatic GPU detection and configuration
- ✅ **Enhanced Setup Scripts** - Smart dependency management with version checking
- ✅ **Improved Environment Configuration** - Secure `.env` file management
- ✅ **GPU Compatibility Guide** - Complete RunPod GPU compatibility matrix
- ✅ **Troubleshooting Documentation** - Comprehensive deployment troubleshooting
- ✅ **Network Accessibility** - Configured for external access (0.0.0.0 binding)

---

## 🚀 Quick Start Options

### Option 1: RunPod Deployment (Recommended)

**1. Choose Compatible RunPod GPU:**
- **RTX 4090 (24GB)** - Best performance/cost ratio
- **RTX 3090 (24GB)** - Good value option
- **A6000 (48GB)** - Professional grade
- **A100/H100 (80GB)** - Data center grade

**2. Deploy with One Command:**
```bash
# Clone and deploy
git clone https://github.com/badr-buildwellai/Runpod-Webagent.git
cd Runpod-Webagent
./setup_and_run.sh
```

The script will:
- ✅ Auto-detect your GPU configuration
- ✅ Set optimal tensor parallelism
- ✅ Download models with aria2c (fast parallel downloads)
- ✅ Configure environment variables
- ✅ Start WebDancer demo on `0.0.0.0:7860`

### Option 2: Local Development

```bash
# Standard setup
git clone https://github.com/badr-buildwellai/Runpod-Webagent.git
cd Runpod-Webagent
./setup_and_run.sh

# Configure API keys
cp .env.example .env
# Edit .env with your API keys

# Deploy model server
./runpod_deploy.sh deploy

# Run demo
cd WebDancer/scripts && bash run_demo.sh
```

---

## 🎯 Components Overview

### 🌐 WebDancer (Preprint 2025)
**Native agentic search reasoning model using ReAct framework**
- 32B parameters optimized for information seeking
- Pass@3 score of 64.1% on GAIA and 62.0% on WebWalkerQA
- Requires 24GB+ VRAM or multi-GPU setup

### ⛵ WebSailor (Preprint 2025) 
**Agentic search model for complex information seeking**
- Available in 3B and 72B variants
- Specialized in extremely complex browsing tasks
- Includes SailorFog-QA benchmark

### 🚶 WebWalker (ACL 2025)
**Multi-agent framework for web traversal**
- Benchmarking LLMs in web traversal scenarios
- Includes WebWalkerQA dataset

### 🔨 WebShaper (Preprint 2025)
**Agentically Data Synthesizing via Information-Seeking Formalization**
- SOTA results on GAIA (60.19) and WebWalkerQA (52.50)

---

## 🏗️ Deployment Architecture

### RunPod GPU Configurations

| GPU Type | VRAM | Tensor Parallelism | Status | RunPod Availability |
|----------|------|-------------------|--------|-------------------|
| RTX 4090 | 24GB | TP=1 | ✅ Recommended | High |
| RTX 3090 | 24GB | TP=1 | ✅ Good | High |
| A6000 | 48GB | TP=1 | ✅ Professional | Medium |
| A100 | 80GB | TP=1 | ✅ Enterprise | Medium |
| H100 | 80GB | TP=1 | ✅ Latest | Low |
| 2x RTX 4080 | 16GB each | TP=2 | ✅ Multi-GPU | Medium |
| 2x RTX 3080 | 10GB each | TP=2 | ⚠️ Tight | High |
| RTX 5090/5080 | Various | N/A | ❌ Not Compatible* | Low |

*Requires PyTorch nightly for Blackwell support

### Network Configuration

- **WebDancer Demo**: `http://0.0.0.0:7860` (Gradio interface)
- **Model API Server**: `http://0.0.0.0:30000` (SGLang server) 
- **Health Check**: `http://0.0.0.0:30000/health`

---

## 🔧 Advanced Configuration

### Environment Variables

**🏆 RECOMMENDED: RunPod Global Variables (Secrets)**

Add these environment variables in your RunPod template:
```bash
GOOGLE_SEARCH_KEY=your_serper_key        # Get from https://serper.dev/
JINA_API_KEY=your_jina_key              # Get from https://jina.ai/api-dashboard/
DASHSCOPE_API_KEY=your_dashscope_key    # Get from https://dashscope.aliyun.com/
```

**📁 ALTERNATIVE: .env File**

```bash
# Copy .env.example to .env and edit
cp .env.example .env

# Search API Keys  
GOOGLE_SEARCH_KEY=your_serper_key        # Get from https://serper.dev/
JINA_API_KEY=your_jina_key              # Get from https://jina.ai/api-dashboard/
DASHSCOPE_API_KEY=your_dashscope_key    # Get from https://dashscope.aliyun.com/

# Optional: Custom model server port
WEBDANCER_PORT=30000
```

**💡 RunPod secrets are automatically loaded and take priority over .env files**

### GPU Memory Optimization

For memory-constrained setups:
```bash
# Lower memory usage
python -m sglang.launch_server \
    --model-path ./models \
    --tp 1 \
    --mem-fraction-static 0.7 \
    --max-running-requests 128 \
    --chunked-prefill-size 2048
```

### Multi-GPU Setup

For tensor parallelism:
```bash
# 2-GPU setup
./runpod_deploy.sh deploy  # Auto-detects and configures TP=2

# Manual 4-GPU setup
python -m sglang.launch_server \
    --model-path ./models \
    --tp 4 \
    --host 0.0.0.0
```

---

## 🐛 Troubleshooting

### Common Issues

**1. CUDA Compatibility Error**
```
RuntimeError: CUDA error: no kernel image is available for execution on the device
```
**Solution**: Use compatible GPU (see table above) or upgrade PyTorch

**2. Model Server Connection Refused**
```
httpcore.ConnectError: [Errno 111] Connection refused
```
**Solutions**:
- Ensure model server is running: `./runpod_deploy.sh check`
- Check correct port configuration
- Verify model files downloaded completely

**3. Out of Memory**
```
torch.cuda.OutOfMemoryError
```
**Solutions**:
- Use GPU with 24GB+ VRAM
- Enable multi-GPU tensor parallelism
- Reduce batch size in configuration

**4. Dependency Conflicts**
```
ERROR: pip's dependency resolver does not currently take into account all the packages...
```
**Solution**: Our setup script handles this automatically with version pinning

### Health Checks

```bash
# Check GPU status
nvidia-smi

# Check model server
curl http://localhost:30000/health

# Check WebDancer demo
curl http://localhost:7860

# View logs
tail -f ~/.cache/sglang/server.log
```

---

## 📋 System Requirements

### Minimum Requirements
- **GPU**: 24GB VRAM (RTX 3090/4090) or 2x 16GB GPUs
- **RAM**: 32GB system RAM
- **Storage**: 100GB free space
- **Python**: 3.10+ (3.12 recommended)
- **CUDA**: 12.1+

### Recommended RunPod Configuration
- **GPU**: RTX 4090 (24GB)
- **RAM**: 64GB
- **Storage**: 200GB NVMe SSD
- **Network**: High bandwidth for model downloads

---

## 📚 Additional Resources

### Scripts Included
- `setup_and_run.sh` - Complete environment setup with smart dependency management
- `runpod_deploy.sh` - RunPod-optimized deployment with GPU auto-detection
- `DEPLOYMENT_GUIDE.md` - Comprehensive deployment troubleshooting

### Documentation
- [RunPod Deployment Guide](./docs/RUNPOD_DEPLOYMENT.md)
- [GPU Compatibility Matrix](./docs/GPU_COMPATIBILITY.md)
- [Troubleshooting Guide](./DEPLOYMENT_GUIDE.md)
- [API Documentation](./docs/API_REFERENCE.md)

### Original Papers
- [WebDancer: Towards Autonomous Information Seeking Agency](https://arxiv.org/pdf/2505.22648)
- [WebSailor: Navigating Super-human Reasoning for Web Agent](https://arxiv.org/pdf/2507.02592)
- [WebWalker: Benchmarking LLMs in Web Traversal](https://arxiv.org/pdf/2501.07572)
- [WebShaper: Agentically Data Synthesizing via Information-Seeking Formalization](https://arxiv.org/pdf/2507.15061)

---

## 🤝 Contributing

This fork focuses on improved deployment and RunPod compatibility. Contributions welcome for:

- Additional cloud platform support (AWS, GCP, Azure)
- GPU optimization improvements
- Documentation enhancements
- Bug fixes and performance improvements

**Repository**: [https://github.com/badr-buildwellai/Runpod-Webagent](https://github.com/badr-buildwellai/Runpod-Webagent)

## 📄 License

The content of this project itself is licensed under [LICENSE](LICENSE).

## 🌟 Acknowledgments

- Original WebAgent team at Tongyi Lab, Alibaba Group
- SGLang team for the efficient inference engine
- RunPod for cloud GPU infrastructure
- Community contributors for testing and feedback

---

<div align="center">

**Ready to deploy? Start with `./setup_and_run.sh` on your RunPod instance!**

[![RunPod](https://img.shields.io/badge/Deploy%20on-RunPod-purple?style=for-the-badge&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==)](https://runpod.io)

</div>