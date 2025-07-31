# RunPod Deployment Guide for WebAgent

## 🚀 Quick RunPod Setup

### Step 1: Create RunPod Instance

1. **Go to [RunPod](https://runpod.io) and sign up/login**
2. **Choose a GPU template:**
   - **Recommended**: RTX 4090 (24GB) - Best performance/cost
   - **Alternative**: RTX 3090 (24GB) - Good value
   - **Premium**: A6000 (48GB) or A100 (80GB) - Enterprise grade

3. **Configure your pod:**
   ```
   Template: PyTorch 2.0+ (or Ubuntu + CUDA)
   Storage: 100GB+ (for model files)
   Ports: 7860, 30000 (for WebDancer demo and API)
   ```

### Step 2: Connect and Deploy

```bash
# SSH into your RunPod instance
ssh root@<your-pod-ip>

# Clone the RunPod-optimized WebAgent repository
git clone https://github.com/admindev-buildwellai/Runpod-Webagent.git
cd Runpod-Webagent

# Run the automated setup (handles everything)
./setup_and_run.sh
```

**That's it!** The script will:
- ✅ Auto-detect your GPU configuration
- ✅ Download WebDancer-32B model (aria2c parallel download)
- ✅ Install all dependencies with smart version checking
- ✅ Configure optimal tensor parallelism
- ✅ Start the WebDancer demo on port 7860

### Step 3: Access Your Demo

- **WebDancer Interface**: `http://<pod-ip>:7860`
- **API Endpoint**: `http://<pod-ip>:30000/v1`
- **Health Check**: `http://<pod-ip>:30000/health`

---

## 🎯 GPU-Specific Configurations

### RTX 4090 / RTX 3090 (24GB) - Single GPU
```bash
# Optimal configuration (auto-detected)
./runpod_deploy.sh deploy
# Uses: TP=1, mem-fraction=0.8, full model loaded
```

### A6000 (48GB) - Single GPU with Headroom
```bash
# Professional configuration
WEBDANCER_PORT=30000 ./runpod_deploy.sh deploy
# Uses: TP=1, mem-fraction=0.6, extra memory for large batches
```

### 2x RTX 4080 (16GB each) - Multi-GPU
```bash
# Tensor parallelism configuration
./runpod_deploy.sh deploy
# Auto-detects: TP=2, distributed across 2 GPUs
```

### H100 / A100 (80GB) - Enterprise
```bash
# High-performance configuration
./runpod_deploy.sh deploy
# Uses: TP=1, optimized for maximum throughput
```

---

## 🔧 RunPod-Specific Optimizations

### Network Configuration

RunPod requires external access configuration:

```python
# Already configured in our scripts
server_name='0.0.0.0'  # Binds to all interfaces
server_port=7860       # WebDancer demo port
```

### Storage Optimization

```bash
# Use RunPod's fast NVMe storage
export MODEL_CACHE_DIR="/workspace/models"
export HF_HOME="/workspace/.cache/huggingface"

# Pre-download models to persistent storage
./setup_and_run.sh
```

### Memory Management

```bash
# RunPod memory optimization
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128
export CUDA_LAUNCH_BLOCKING=0  # Async CUDA operations
```

---

## 🐛 RunPod-Specific Troubleshooting

### Issue 1: Port Access Problems

**Problem**: Can't access demo on port 7860
```bash
# Check if port is exposed in RunPod dashboard
# Solution: Add port 7860 to your pod configuration
```

**Verify ports are listening:**
```bash
ss -tulpn | grep :7860
ss -tulpn | grep :30000
```

### Issue 2: Model Download Interruption

**Problem**: Large model download interrupted
```bash
# Resume download with aria2c
cd models
aria2c -c -x 8 -s 8 --input-file=download_urls.txt
```

### Issue 3: GPU Memory Issues on Shared Instances

**Problem**: GPU memory conflicts with other processes
```bash
# Check GPU usage
nvidia-smi
# Kill competing processes if needed
pkill -f python
./runpod_deploy.sh deploy
```

### Issue 4: Slow Model Loading

**Problem**: Model takes too long to load
```bash
# Use RunPod's NVMe storage
mv models /workspace/models
ln -s /workspace/models models
```

---

## 💰 RunPod Cost Optimization

### GPU Cost Comparison (approximate)

| GPU Type | VRAM | RunPod $/hour | Best For |
|----------|------|---------------|----------|
| RTX 4090 | 24GB | $0.50-0.70 | **Recommended** |
| RTX 3090 | 24GB | $0.40-0.60 | **Budget** |
| A6000 | 48GB | $0.80-1.20 | **Professional** |
| A100 | 80GB | $1.50-2.50 | **Enterprise** |
| H100 | 80GB | $2.50-4.00 | **Cutting Edge** |

### Cost-Saving Tips

1. **Use Spot Instances**: 50-90% cost reduction
2. **Stop when not in use**: RunPod charges by the minute
3. **Persistent storage**: Keep models downloaded between sessions
4. **Choose right GPU**: RTX 4090 offers best value for WebDancer-32B

### Persistent Storage Setup

```bash
# Create persistent volume for models
mkdir -p /workspace/persistent/models
ln -s /workspace/persistent/models models

# Setup script will detect and use existing models
./setup_and_run.sh
```

---

## 🚀 Advanced RunPod Configurations

### Multi-Pod Setup (Load Balancing)

For high-traffic deployments:

```bash
# Pod 1: Model server only
./runpod_deploy.sh deploy
# Expose port 30000

# Pod 2: WebDancer demo only  
cd WebDancer/scripts
WEBDANCER_API_URL="http://pod1-ip:30000/v1" bash run_demo.sh
```

### Custom Docker Container

Create optimized container for repeated deployments:

```dockerfile
FROM runpod/pytorch:2.1.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Copy WebAgent and dependencies
COPY . /workspace/WebAgent
WORKDIR /workspace/WebAgent

# Pre-install dependencies
RUN ./setup_and_run.sh --deps-only

# Setup entrypoint
ENTRYPOINT ["./runpod_deploy.sh", "deploy"]
```

### Jupyter Integration

Run WebAgent in RunPod Jupyter:

```python
import subprocess
import os

# Deploy model server
os.chdir('/workspace/WebAgent')
subprocess.run(['./runpod_deploy.sh', 'deploy'], check=True)

# Access via API
import requests
response = requests.post('http://localhost:30000/v1/chat/completions', 
    json={'messages': [{'role': 'user', 'content': 'Search for AI news'}]})
```

---

## 📊 Performance Benchmarks

### Model Loading Times (RunPod)

| GPU | Model Load Time | First Response | Throughput |
|-----|----------------|----------------|------------|
| RTX 4090 | ~2-3 minutes | ~10-15s | ~15 tokens/s |
| RTX 3090 | ~3-4 minutes | ~12-18s | ~12 tokens/s |
| A6000 | ~2-3 minutes | ~8-12s | ~18 tokens/s |
| A100 | ~1-2 minutes | ~5-8s | ~25 tokens/s |

### Network Performance

- **Model Download**: 5-15 minutes (depending on connection)
- **API Latency**: <100ms (RunPod to client)
- **Demo Response**: 2-10s (depending on query complexity)

---

## 🔄 Updating Your Deployment

### Update WebAgent Code

```bash
cd Runpod-Webagent
git pull origin main
./setup_and_run.sh --update-only
```

### Update Model

```bash
# Download newer model version
./runpod_deploy.sh deploy --force-download
```

### Update Dependencies

```bash
# Update Python packages
source webagent_env/bin/activate
pip install -r requirements.txt --upgrade
```

---

## 🆘 RunPod Support Resources

### Getting Help

1. **Check our troubleshooting**: `./DEPLOYMENT_GUIDE.md`
2. **RunPod Discord**: [discord.gg/runpod](https://discord.gg/runpod)
3. **GitHub Issues**: [Create issue](https://github.com/admindev-buildwellai/Runpod-Webagent/issues)

### Monitoring

```bash
# Check system resources
htop
nvidia-smi -l 1

# Check logs
tail -f ~/.cache/sglang/server.log
journalctl -u your-service -f

# API health check
curl http://localhost:30000/health
```

### Backup & Recovery

```bash
# Backup models and config
tar -czf webagent-backup.tar.gz models/ .env webagent_env/

# Restore on new pod
tar -xzf webagent-backup.tar.gz
./runpod_deploy.sh deploy
```

---

**🎉 You're ready to run WebAgent on RunPod! For support, check our [main README](../README.md) or create an [issue](https://github.com/admindev-buildwellai/Runpod-Webagent/issues).**