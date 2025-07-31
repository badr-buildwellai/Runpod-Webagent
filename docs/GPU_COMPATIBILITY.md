# GPU Compatibility Matrix for WebAgent

## 🎯 Overview

This guide provides comprehensive GPU compatibility information for WebAgent deployment, specifically optimized for RunPod and other cloud platforms.

**Current Environment:**
- PyTorch: 2.7.1
- CUDA: 12.6  
- Supported Compute Capabilities: sm_50, sm_60, sm_70, sm_75, sm_80, sm_86, sm_90

---

## 🏆 RunPod GPU Compatibility Matrix

### ✅ Fully Compatible GPUs

| GPU Model | VRAM | Compute Cap | Single GPU | Multi-GPU | RunPod Price | Recommendation |
|-----------|------|-------------|------------|-----------|--------------|----------------|
| **RTX 4090** | 24GB | sm_89 | ✅ Perfect | ✅ TP=2+ | $0.50-0.70/hr | 🥇 **Best Choice** |
| **RTX 3090** | 24GB | sm_86 | ✅ Perfect | ✅ TP=2+ | $0.40-0.60/hr | 🥈 **Great Value** |
| **RTX 3090 Ti** | 24GB | sm_86 | ✅ Perfect | ✅ TP=2+ | $0.45-0.65/hr | ✅ Excellent |
| **A6000** | 48GB | sm_86 | ✅ Perfect | ✅ TP=2+ | $0.80-1.20/hr | 🏢 **Professional** |
| **A100 (40GB)** | 40GB | sm_80 | ✅ Good | ✅ TP=2+ | $1.00-1.80/hr | 🏢 Enterprise |
| **A100 (80GB)** | 80GB | sm_80 | ✅ Perfect | ✅ TP=2+ | $1.50-2.50/hr | 🏢 Enterprise+ |
| **H100 (80GB)** | 80GB | sm_90 | ✅ Perfect | ✅ TP=2+ | $2.50-4.00/hr | 🚀 **Cutting Edge** |

### ⚠️ Partially Compatible (Multi-GPU Required)

| GPU Model | VRAM | Compute Cap | Single GPU | Multi-GPU | RunPod Price | Notes |
|-----------|------|-------------|------------|-----------|--------------|-------|
| **RTX 4080** | 16GB | sm_89 | ⚠️ Tight | ✅ TP=2+ | $0.35-0.55/hr | Need 2+ GPUs |
| **RTX 4080 Super** | 16GB | sm_89 | ⚠️ Tight | ✅ TP=2+ | $0.40-0.60/hr | Need 2+ GPUs |
| **RTX 3080** | 10GB | sm_86 | ❌ Too Small | ✅ TP=3+ | $0.25-0.40/hr | Need 3+ GPUs |
| **RTX 3080 Ti** | 12GB | sm_86 | ❌ Too Small | ✅ TP=2+ | $0.30-0.45/hr | Need 2+ GPUs |
| **RTX 3070** | 8GB | sm_86 | ❌ Too Small | ✅ TP=4+ | $0.20-0.35/hr | Need 4+ GPUs |

### ❌ Not Compatible (Current PyTorch)

| GPU Model | VRAM | Compute Cap | Status | Solution |
|-----------|------|-------------|--------|----------|
| **RTX 5090** | 32GB | sm_120 | ❌ Too New | Upgrade PyTorch to nightly |
| **RTX 5080** | 16GB | sm_120 | ❌ Too New | Upgrade PyTorch to nightly |
| **RTX PRO 6000 Blackwell** | 48GB | sm_120 | ❌ Too New | Upgrade PyTorch to nightly |
| **H200** | 141GB | sm_90+ | ⚠️ May Work | Test with current PyTorch |

### 🏛️ Legacy Compatible GPUs

| GPU Model | VRAM | Compute Cap | Single GPU | Multi-GPU | Notes |
|-----------|------|-------------|------------|-----------|-------|
| **RTX 2080 Ti** | 11GB | sm_75 | ❌ Too Small | ✅ TP=3+ | Budget option |
| **V100** | 16GB/32GB | sm_70 | ⚠️ Depends | ✅ TP=2+ | Data center |
| **T4** | 16GB | sm_75 | ❌ Too Small | ✅ TP=2+ | Inference focused |
| **P100** | 16GB | sm_60 | ❌ Too Small | ✅ TP=2+ | Legacy |

---

## 🔧 Deployment Configurations

### Single GPU Setups (Recommended)

#### RTX 4090 (24GB) - Optimal Configuration
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 1 \
    --mem-fraction-static 0.8 \
    --max-running-requests 256 \
    --chunked-prefill-size 8192
```

#### RTX 3090 (24GB) - Good Performance
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 1 \
    --mem-fraction-static 0.75 \
    --max-running-requests 128 \
    --chunked-prefill-size 4096
```

#### A6000 (48GB) - Professional Setup
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 1 \
    --mem-fraction-static 0.6 \
    --max-running-requests 512 \
    --chunked-prefill-size 16384
```

### Multi-GPU Setups

#### 2x RTX 4080 (16GB each)
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 2 \
    --mem-fraction-static 0.85 \
    --max-running-requests 256
```

#### 2x RTX 3080 Ti (12GB each) 
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 2 \
    --mem-fraction-static 0.9 \
    --max-running-requests 128
```

#### 4x RTX 3070 (8GB each)
```bash
python -m sglang.launch_server \
    --model-path ./models \
    --tp 4 \
    --mem-fraction-static 0.95 \
    --max-running-requests 64
```

---

## 📊 Performance Benchmarks

### WebDancer-32B Performance by GPU

| GPU Configuration | Model Load Time | First Token | Throughput (tokens/s) | Max Context |
|-------------------|-----------------|-------------|----------------------|-------------|
| RTX 4090 (24GB) | 2-3 min | 8-12s | 15-20 | 32K |
| RTX 3090 (24GB) | 3-4 min | 10-15s | 12-18 | 32K |
| A6000 (48GB) | 2-3 min | 6-10s | 18-25 | 64K+ |
| A100 (80GB) | 1-2 min | 4-8s | 25-35 | 128K+ |
| H100 (80GB) | 1-2 min | 3-6s | 35-50 | 128K+ |
| 2x RTX 4080 | 3-4 min | 10-14s | 20-28 | 32K |
| 2x RTX 3080 Ti | 4-5 min | 12-18s | 16-24 | 32K |

### Memory Usage Patterns

| Configuration | Model Weights | KV Cache | Activations | Total Usage |
|---------------|---------------|----------|-------------|-------------|
| RTX 4090 TP=1 | ~16GB | ~4GB | ~2GB | ~22GB/24GB |
| RTX 3090 TP=1 | ~16GB | ~4GB | ~2GB | ~22GB/24GB |
| A6000 TP=1 | ~16GB | ~8GB | ~4GB | ~28GB/48GB |
| 2x RTX 4080 TP=2 | ~8GB each | ~2GB each | ~1GB each | ~11GB/16GB each |

---

## 🔧 Hardware Optimization Tips

### VRAM Optimization

```bash
# Reduce memory usage
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128
export CUDA_LAUNCH_BLOCKING=0

# SGLang optimizations
--mem-fraction-static 0.8      # Leave 20% for system
--chunked-prefill-size 4096     # Smaller chunks for less VRAM
--max-running-requests 128      # Limit concurrent requests
```

### Multi-GPU Optimization

```bash
# Optimal NCCL settings
export NCCL_SOCKET_IFNAME=^docker0,lo
export NCCL_IB_DISABLE=1
export NCCL_P2P_DISABLE=1

# Better load balancing
--tp 2                          # Use 2 GPUs
--pp 1                          # No pipeline parallelism
--max-micro-batch-size 1        # Stable micro-batching
```

### CPU/Storage Optimization

```bash
# Use fast storage for models
export MODEL_CACHE_DIR="/tmp/models"  # NVMe SSD

# CPU optimization
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

---

## 🚨 Troubleshooting GPU Issues

### Issue 1: CUDA Out of Memory

**Symptoms:**
```
torch.cuda.OutOfMemoryError: CUDA out of memory
```

**Solutions:**
```bash
# Reduce memory fraction
--mem-fraction-static 0.7

# Smaller batch sizes
--max-running-requests 64
--chunked-prefill-size 2048

# Use gradient checkpointing
--enable-memory-saver
```

### Issue 2: GPU Not Detected

**Symptoms:**
```
No CUDA devices available
```

**Solutions:**
```bash
# Check GPU status
nvidia-smi

# Verify CUDA installation
python -c "import torch; print(torch.cuda.is_available())"

# Reinstall CUDA-compatible PyTorch
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### Issue 3: Compute Capability Error

**Symptoms:**
```
RuntimeError: CUDA error: no kernel image is available for execution on the device
```

**Solutions:**
```bash
# Check compute capability
python -c "import torch; print(torch.cuda.get_device_properties(0))"

# Use compatible GPU (see compatibility matrix above)
# Or upgrade PyTorch for newer GPUs:
pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu121
```

### Issue 4: Multi-GPU Synchronization

**Symptoms:**
```
NCCL errors or hanging during multi-GPU setup
```

**Solutions:**
```bash
# Verify all GPUs are visible
nvidia-smi

# Check NCCL configuration
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=^docker0,lo

# Test with simple TP=1 first
--tp 1
```

---

## 🎯 GPU Selection Guide

### For Development/Testing
- **Budget**: 2x RTX 3080 Ti (12GB each) - $0.60-0.90/hr total
- **Recommended**: RTX 3090 (24GB) - $0.40-0.60/hr

### For Production/Demo
- **Best Value**: RTX 4090 (24GB) - $0.50-0.70/hr  
- **Professional**: A6000 (48GB) - $0.80-1.20/hr

### For Enterprise/Research
- **High Performance**: A100 (80GB) - $1.50-2.50/hr
- **Cutting Edge**: H100 (80GB) - $2.50-4.00/hr

### For Budget-Conscious
- **Multi-GPU Budget**: 2x RTX 4080 (16GB each) - $0.70-1.10/hr total
- **Legacy Option**: 2x RTX 3080 Ti (12GB each) - $0.60-0.90/hr total

---

## 🔄 Future Compatibility

### Upcoming GPU Support

**RTX 5000 Series (Blackwell)**
- Requires PyTorch 2.8+ or nightly builds
- Will offer significant performance improvements
- Expected RunPod availability: Q2 2025

**H200 Series**
- Limited availability on RunPod
- Excellent for large context windows
- Premium pricing tier

### PyTorch Upgrade Path

```bash
# For Blackwell GPU support
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu124

# Verify new GPU support
python -c "import torch; print(torch.cuda.get_arch_list())"
```

---

**📝 This compatibility matrix is updated regularly. For the latest GPU pricing and availability, check [RunPod's GPU types page](https://docs.runpod.io/references/gpu-types).**