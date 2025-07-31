#!/bin/bash
# RunPod WebAgent Deployment Script
# Compatible with most RunPod GPU types

set -e

echo "🚀 RunPod WebAgent Deployment Script"
echo "======================================"

# Function to detect GPU and set appropriate configuration
detect_gpu_config() {
    echo "🔍 Detecting GPU configuration..."
    
    # Get GPU info
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1 2>/dev/null || echo "No GPU detected")
    GPU_MEMORY=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1 2>/dev/null || echo "0")
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits 2>/dev/null || echo "0")
    
    echo "GPU: $GPU_NAME"
    echo "VRAM: ${GPU_MEMORY}MB"
    echo "Count: $GPU_COUNT"
    
    # Convert MB to GB for easier comparison
    GPU_MEMORY_GB=$((GPU_MEMORY / 1024))
    
    # Set tensor parallelism based on GPU configuration
    if [[ $GPU_MEMORY_GB -ge 24 ]]; then
        # Single high-memory GPU (RTX 4090, 3090, A6000, etc.)
        TP_SIZE=1
        echo "✅ Single GPU deployment (TP=1) - Sufficient VRAM"
    elif [[ $GPU_COUNT -ge 2 && $GPU_MEMORY_GB -ge 16 ]]; then
        # Multiple GPUs with good memory (2x RTX 4080, etc.)
        TP_SIZE=2
        echo "✅ Multi-GPU deployment (TP=2) - Using tensor parallelism"
    elif [[ $GPU_COUNT -ge 4 && $GPU_MEMORY_GB -ge 10 ]]; then
        # Many GPUs with moderate memory
        TP_SIZE=4
        echo "✅ Multi-GPU deployment (TP=4) - Using tensor parallelism"
    else
        echo "❌ Insufficient GPU memory for WebDancer-32B"
        echo "   Minimum requirements:"
        echo "   - 1x GPU with 24GB+ VRAM (RTX 4090, 3090, A6000, H100, A100)"
        echo "   - 2x GPU with 16GB+ VRAM each (RTX 4080, etc.)"
        echo "   - 4x GPU with 10GB+ VRAM each"
        exit 1
    fi
}

# Function to check RunPod GPU compatibility
check_gpu_compatibility() {
    echo "🔍 Checking GPU compatibility with PyTorch..."
    
    # Check if GPU is supported by current PyTorch
    if python -c "
import torch
if torch.cuda.is_available():
    gpu_props = torch.cuda.get_device_properties(0)
    major = gpu_props.major
    minor = gpu_props.minor
    compute_cap = f'sm_{major}{minor}'
    supported_caps = torch.cuda.get_arch_list()
    
    print(f'GPU Compute Capability: {compute_cap}')
    print(f'Supported: {compute_cap in supported_caps}')
    
    if compute_cap not in supported_caps:
        print('❌ GPU not supported by current PyTorch')
        print(f'Supported capabilities: {supported_caps}')
        exit(1)
    else:
        print('✅ GPU compatible with PyTorch')
else:
    print('❌ CUDA not available')
    exit(1)
" 2>/dev/null; then
        echo "✅ GPU compatibility verified"
    else
        echo "❌ GPU compatibility check failed"
        echo "💡 Consider upgrading PyTorch or using a compatible GPU"
        exit 1
    fi
}

# Main deployment function
deploy_webdancer() {
    echo "🚀 Starting WebDancer model deployment..."
    
    # Activate virtual environment
    if [ -f "webagent_env/bin/activate" ]; then
        source webagent_env/bin/activate
        echo "✅ Virtual environment activated"
    else
        echo "❌ Virtual environment not found. Run setup_and_run.sh first."
        exit 1
    fi
    
    # Check if model exists
    if [ ! -d "models" ] || [ ! -f "models/config.json" ]; then
        echo "❌ WebDancer model not found in models/ directory"
        echo "💡 Run the setup script first to download the model"
        exit 1
    fi
    
    echo "✅ Model files found"
    
    # Detect GPU configuration
    detect_gpu_config
    check_gpu_compatibility
    
    # Set appropriate port (use default sglang port)
    PORT=${WEBDANCER_PORT:-30000}
    
    echo "🚀 Launching WebDancer model server..."
    echo "   Port: $PORT"
    echo "   Tensor Parallelism: $TP_SIZE"
    echo "   Model Path: $(pwd)/models"
    
    # Launch model server with detected configuration
    python -m sglang.launch_server \
        --model-path "$(pwd)/models" \
        --host 0.0.0.0 \
        --port $PORT \
        --tp $TP_SIZE \
        --mem-fraction-static 0.8 \
        --max-running-requests 256 \
        --disable-cuda-graph \
        --chunked-prefill-size 4096 &
    
    SERVER_PID=$!
    echo "🔄 Model server starting (PID: $SERVER_PID)..."
    
    # Wait for server to be ready
    echo "⏳ Waiting for model server to be ready..."
    for i in {1..60}; do
        if curl -s http://localhost:$PORT/health >/dev/null 2>&1; then
            echo "✅ Model server is ready!"
            break
        fi
        if [ $i -eq 60 ]; then
            echo "❌ Model server failed to start within 5 minutes"
            kill $SERVER_PID 2>/dev/null || true
            exit 1
        fi
        echo "   Attempt $i/60..."
        sleep 5
    done
    
    echo "🎯 WebDancer model server running on http://0.0.0.0:$PORT"
    echo "   Health check: http://0.0.0.0:$PORT/health"
    echo "   API endpoint: http://0.0.0.0:$PORT/v1"
    
    # Update WebDancer configuration to use correct port
    update_webdancer_config $PORT
    
    echo "✅ Deployment complete!"
    echo "💡 You can now run the WebDancer demo with: bash WebDancer/scripts/run_demo.sh"
}

# Function to update WebDancer configuration
update_webdancer_config() {
    local port=$1
    local config_file="WebDancer/demos/assistant_qwq_chat.py"
    
    if [ -f "$config_file" ]; then
        # Update the port in the configuration
        sed -i "s/'model_server': f'http:\/\/127\.0\.0\.1:{[^}]*}\/v1'/'model_server': f'http:\/\/127.0.0.1:$port\/v1'/g" "$config_file"
        sed -i "s/'model_server': 'http:\/\/127\.0\.0\.1:[0-9]*\/v1'/'model_server': 'http:\/\/127.0.0.1:$port\/v1'/g" "$config_file"
        echo "✅ Updated WebDancer configuration to use port $port"
    fi
}

# RunPod GPU Recommendations
show_runpod_recommendations() {
    echo ""
    echo "🏆 RUNPOD GPU RECOMMENDATIONS FOR WEBDANCER-32B"
    echo "=================================================="
    echo ""
    echo "🥇 BEST OPTIONS (Single GPU):"
    echo "   • RTX 4090 (24GB) - Perfect balance of price/performance"
    echo "   • RTX 3090 (24GB) - Good value option"
    echo "   • A6000 (48GB) - Professional, lots of headroom"
    echo "   • A100 (80GB) - Data center grade"
    echo "   • H100 (80GB) - Latest and fastest"
    echo ""
    echo "🥈 MULTI-GPU OPTIONS:"
    echo "   • 2x RTX 4080 (16GB each) - Good for TP=2"
    echo "   • 2x RTX 3080 (10GB each) - Budget TP=2 option"
    echo "   • 4x RTX 3070 (8GB each) - Budget TP=4 option"
    echo ""
    echo "❌ NOT COMPATIBLE (Current PyTorch):"
    echo "   • RTX 5090/5080 (Blackwell - sm_120+)"
    echo "   • RTX PRO 6000 Blackwell"
    echo ""
    echo "💡 For RunPod, RTX 4090 is usually the best choice!"
    echo ""
}

# Check command line arguments
case "${1:-deploy}" in
    "deploy")
        deploy_webdancer
        ;;
    "recommendations"|"gpus")
        show_runpod_recommendations
        ;;
    "check")
        detect_gpu_config
        check_gpu_compatibility
        ;;
    *)
        echo "Usage: $0 [deploy|recommendations|check]"
        echo ""
        echo "Commands:"
        echo "  deploy         - Deploy WebDancer with auto-detected GPU config"
        echo "  recommendations - Show RunPod GPU recommendations"  
        echo "  check          - Check current GPU compatibility"
        echo ""
        show_runpod_recommendations
        exit 1
        ;;
esac