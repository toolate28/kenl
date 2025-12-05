#!/usr/bin/env bash
# KENL Modules - Ollama/Qwen Installation via KENL Tools
# ATOM-KENL-MOD-20251205-001
# SAIF-KENL-SETUP-20251205-001

set -e

echo "=== KENL Modules: Ollama/Qwen Setup ==="
echo "SAIF-KENL-SETUP-20251205-001"
echo ""

# Check if we're in the KENL directory
if [ ! -d "$HOME/.kenl/modules" ]; then
    echo "ERROR: KENL modules directory not found"
    echo "Expected: $HOME/.kenl/modules"
    exit 1
fi

echo "✓ KENL modules directory found"
echo ""

# Step 1: Create dedicated Ollama distrobox
echo "[1/5] Creating dedicated Ollama distrobox..."
if distrobox list | grep -q "ollama"; then
    echo "  ✓ Ollama distrobox already exists"
else
    echo "  Creating ollama distrobox (Fedora latest)..."
    distrobox create --name ollama \
        --image fedora:latest \
        --init \
        --additional-packages "curl git procps"
    echo "  ✓ Ollama distrobox created"
fi
echo ""

# Step 2: Install Ollama in dedicated distrobox
echo "[2/5] Installing Ollama in dedicated distrobox..."
distrobox enter ollama -- bash -c '
    if ! command -v ollama &> /dev/null; then
        echo "  Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo "  ✓ Ollama installed"
    else
        echo "  ✓ Ollama already installed"
    fi
'
echo ""

# Step 3: Start Ollama service
echo "[3/5] Starting Ollama service..."
distrobox enter ollama -- bash -c '
    # Check if ollama is already running
    if pgrep -x "ollama" > /dev/null; then
        echo "  ✓ Ollama already running"
    else
        echo "  Starting Ollama service..."
        nohup ollama serve > /tmp/ollama.log 2>&1 &
        sleep 2
        echo "  ✓ Ollama service started (PID: $(pgrep -x ollama))"
    fi
'
echo ""

# Step 4: Pull Qwen model
echo "[4/5] Pulling Qwen 2.5 Coder model..."
distrobox enter ollama -- bash -c '
    if ollama list | grep -q "qwen2.5-coder:7b"; then
        echo "  ✓ qwen2.5-coder:7b already pulled"
    else
        echo "  Pulling qwen2.5-coder:7b (this may take a while)..."
        ollama pull qwen2.5-coder:7b
        echo "  ✓ Model pulled successfully"
    fi
'
echo ""

# Step 5: Configure environment
echo "[5/5] Configuring environment variables..."
if ! grep -q "OLLAMA_ENDPOINT" ~/.kenl/.secrets/.env; then
    cat >> ~/.kenl/.secrets/.env << 'ENVEOF'

# Ollama Configuration (in dedicated distrobox)
export OLLAMA_ENDPOINT="http://localhost:11434"
export OLLAMA_MODEL="qwen2.5-coder:7b"
ENVEOF
    echo "  ✓ Environment variables added to ~/.kenl/.secrets/.env"
else
    echo "  ✓ Environment variables already configured"
fi
echo ""

# Test Ollama connection
echo "=== Testing Ollama Connection ==="
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✓ Ollama is accessible at http://localhost:11434"
    echo ""
    echo "Available models:"
    curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "  (jq not installed, cannot parse)"
else
    echo "⚠ Ollama not responding on localhost:11434"
    echo "  Make sure Ollama service is running in the ollama distrobox"
fi
echo ""

# Log to ATOM trail
echo "ATOM-KENL-MOD-20251205-001: Ollama distrobox created" >> ~/.kenl/.atom-trail.log
echo "ATOM-KENL-MOD-20251205-002: Qwen 2.5 Coder model pulled" >> ~/.kenl/.atom-trail.log
echo "ATOM-KENL-MOD-20251205-003: Ollama configured via KENL modules" >> ~/.kenl/.atom-trail.log

echo "=== Setup Complete! ==="
echo ""
echo "Usage:"
echo "  # Enter Ollama distrobox:"
echo "  distrobox enter ollama"
echo ""
echo "  # Run Qwen from any distrobox:"
echo "  curl http://localhost:11434/api/generate -d '{\"model\": \"qwen2.5-coder:7b\", \"prompt\": \"Hello\"}'"
echo ""
echo "  # Or use Ollama CLI (in ollama distrobox):"
echo "  ollama run qwen2.5-coder:7b"
echo ""

echo "SAIF-KENL-SETUP-20251205-001: Complete"
