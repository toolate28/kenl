# modules/KENL8: Security & Privacy

**Icon:** 🔐 | **Color:** Magenta | **Status:** Production

Security-first operations - GPG encryption, security analysis, red/blue/purple teaming.

## Quick Start

```bash
# Encrypt a file
cd ~/kenl/KENL8-security/gpg-keyring
./encrypt-file.sh encrypt myfile.txt

# Export public key for sharing
./encrypt-file.sh export-key

# Launch JupyterLab for security analysis
cd ~/kenl/KENL8-security
jupyter lab security-analysis.ipynb

# Switch to security context
cd ~/kenl/KENL5-facades
./switch-kenl.sh security
```

## Features

- 🔑 GPG key management
- 🔐 File encryption/decryption
- ✍️ Digital signatures
- 🛡️ Red/Blue/Purple team analysis (Jupyter notebook)
- 📊 Security visualization and reporting
- 🎯 HackTheBox Academy-inspired techniques

**Used by:** modules/KENL6 (Play Card sharing), modules/KENL10 (encrypted backups)

## Security Analysis Notebook

The `security-analysis.ipynb` notebook provides advanced security analysis capabilities inspired by techniques from the earlier dotfiles-llr repository and HackTheBox Academy methodologies.

### Red Team Functions
- 🔴 Network reconnaissance and mapping
- 🔴 Vulnerability scanning and assessment
- 🔴 Exploit development and testing
- 🔴 Penetration testing automation

### Blue Team Functions
- 🔵 Log analysis and pattern detection
- 🔵 Incident response workflows
- 🔵 Security monitoring and alerting
- 🔵 Threat intelligence integration

### Purple Team Functions
- 🟣 Attack simulation and validation
- 🟣 Defense effectiveness testing
- 🟣 Security posture assessment
- 🟣 Continuous improvement metrics

### Visualization Capabilities
- 📈 Network topology mapping
- 📊 Vulnerability heat maps
- 📉 Timeline analysis
- 🎯 Attack surface visualization

### Installation

```bash
# Install Jupyter and security analysis dependencies
pip install --user jupyter jupyterlab pandas numpy matplotlib seaborn networkx scapy

# Launch notebook
cd ~/kenl/modules/KENL8-security
jupyter lab security-analysis.ipynb
```

**Note**: The security analysis notebook is based on techniques from the dotfiles-llr repository and HackTheBox Academy curriculum, adapted for KENL's intent-driven approach with ATOM trail logging. Users with HackTheBox Academy student access can extend these functions with additional academy-specific techniques.
