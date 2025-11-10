#!/usr/bin/env bash
#
# setup-monitoring.sh - Setup monitoring stack (Prometheus + Grafana)
#
# Usage: ./setup-monitoring.sh
#

set -euo pipefail

echo "📊 Setting up KENL4 monitoring stack"
echo ""

# Check if distrobox available
if ! command -v distrobox &> /dev/null; then
    echo "❌ distrobox not found!"
    echo "   Required for running Prometheus/Grafana containers"
    echo ""
    echo "Install on Bazzite:"
    echo "  rpm-ostree install distrobox"
    echo "  systemctl reboot"
    exit 1
fi

# Create monitoring container
CONTAINER_NAME="kenl-monitoring"

echo "📦 Creating monitoring container..."
if distrobox list | grep -q "$CONTAINER_NAME"; then
    echo "✅ Container already exists: $CONTAINER_NAME"
else
    distrobox create \
        --name "$CONTAINER_NAME" \
        --image docker.io/library/ubuntu:24.04 \
        --additional-packages "curl wget" \
        --init \
        --yes

    echo "✅ Container created: $CONTAINER_NAME"
fi

echo ""
echo "📥 Installing monitoring tools..."
echo ""

distrobox enter "$CONTAINER_NAME" -- bash -c '
set -euo pipefail

# Install Prometheus
echo "📈 Installing Prometheus..."
PROM_VERSION="2.47.0"
wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
tar xzf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
sudo mv "prometheus-${PROM_VERSION}.linux-amd64/prometheus" /usr/local/bin/
sudo mv "prometheus-${PROM_VERSION}.linux-amd64/promtool" /usr/local/bin/
rm -rf "prometheus-${PROM_VERSION}.linux-amd64"*
echo "✅ Prometheus installed"

# Install node_exporter
echo "📊 Installing node_exporter..."
NODE_EXP_VERSION="1.6.1"
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXP_VERSION}/node_exporter-${NODE_EXP_VERSION}.linux-amd64.tar.gz"
tar xzf "node_exporter-${NODE_EXP_VERSION}.linux-amd64.tar.gz"
sudo mv "node_exporter-${NODE_EXP_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
rm -rf "node_exporter-${NODE_EXP_VERSION}.linux-amd64"*
echo "✅ node_exporter installed"

# Install Grafana
echo "📊 Installing Grafana..."
sudo apt update -qq
sudo apt install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update -qq
sudo apt install -y grafana
echo "✅ Grafana installed"

# Install Logdy
echo "📝 Installing Logdy..."
wget -q "https://github.com/logdyhq/logdy-core/releases/latest/download/logdy_linux_amd64" -O /tmp/logdy
sudo mv /tmp/logdy /usr/local/bin/logdy
sudo chmod +x /usr/local/bin/logdy
echo "✅ Logdy installed"
'

# Create Prometheus config
echo ""
echo "📝 Creating Prometheus configuration..."

mkdir -p prometheus/rules
cat > prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'atom_trail'
    static_configs:
      - targets: ['localhost:9091']
EOF

echo "✅ Prometheus config created"

# Create systemd user services (for autostart)
echo ""
echo "🔧 Creating systemd user services..."

mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/distrobox enter kenl-monitoring -- prometheus --config.file=\$HOME/kenl/KENL4-monitoring/prometheus/prometheus.yml --storage.tsdb.path=\$HOME/.prometheus
Restart=on-failure

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/node_exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/distrobox enter kenl-monitoring -- node_exporter
Restart=on-failure

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/grafana.service <<EOF
[Unit]
Description=Grafana Dashboard
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/distrobox enter kenl-monitoring -- sudo grafana-server --config=/etc/grafana/grafana.ini
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload

echo "✅ Systemd services created"
echo ""

# Instructions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ KENL4 Monitoring Stack Installed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Start services:"
echo "  systemctl --user start prometheus"
echo "  systemctl --user start node_exporter"
echo "  systemctl --user start grafana"
echo ""
echo "Enable autostart:"
echo "  systemctl --user enable prometheus"
echo "  systemctl --user enable node_exporter"
echo "  systemctl --user enable grafana"
echo ""
echo "Access dashboards:"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana:    http://localhost:3000 (admin/admin)"
echo "  Metrics:    http://localhost:9100/metrics"
echo ""
echo "View logs:"
echo "  journalctl --user -u prometheus -f"
echo "  journalctl --user -u grafana -f"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed KENL4 monitoring stack" "Prometheus + Grafana + node_exporter + Logdy"
fi
