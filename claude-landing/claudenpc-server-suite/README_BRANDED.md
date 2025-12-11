# ⚡ ClaudeNPC Server Suite

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║      ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗███╗   ██╗██████╗      ║
║     ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝████╗  ██║██╔══██╗     ║
║     ██║     ██║     ███████║██║   ██║██║  ██║█████╗  ██╔██╗ ██║██████╔╝     ║
║     ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ██║╚██╗██║██╔═══╝      ║
║     ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗██║ ╚████║██║          ║
║      ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝          ║
║                                                                              ║
║                    🤖 AI-Powered Minecraft NPCs                              ║
║                    Powered by Claude Sonnet 4                               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

           >>> Modular PowerShell Framework for PaperMC Setup <<<
                    Production-Ready | Fully Documented
```

---

## 🌟 What is This?

**ClaudeNPC Server Suite** is a professional-grade, modular PowerShell framework that sets up a complete Minecraft PaperMC server with AI-powered NPCs. Talk to NPCs powered by Claude AI - they remember conversations, understand context, and roleplay naturally.

### ✨ Key Features

```
🎨 Branded UI           Consistent, beautiful terminal interface
📝 Smart Logging        Complete audit trail of all operations  
🛡️ Safety First         Backups, validation, error recovery
⚙️ Flexible Config      Multiple install profiles, JSON support
🔧 Modular Design       Drop-in components, independent testing
🤖 AI NPCs             Claude-powered conversational characters
📦 One-Click Setup      Automated installation with progress tracking
🎯 Production Ready     Error handling, logging, best practices
```

---

## 🚀 Quick Start (30 Seconds)

```powershell
# 1. Extract this ZIP to your desired location
# 2. Open PowerShell as Administrator
# 3. Navigate to the extracted folder
cd C:\ClaudeNPC-Server-Suite

# 4. Run the setup
cd setup
.\Setup.ps1

# That's it! The wizard will guide you through everything.
```

---

## 📦 What's Inside This Package

```
ClaudeNPC-Server-Suite/
│
├── 📖 README.md                          ← You are here
├── 🎯 QUICKSTART.md                      ← 5-minute setup guide
├── 📊 PROJECT_STATE.md                   ← Complete status
├── 🤖 IMPLEMENTATION_PROMPTS.md          ← Build advanced features
│
├── setup/                                ← Installation framework
│   ├── core/                             ← 4 core modules (production ready)
│   ├── phases/                           ← Installation phases
│   └── Setup.ps1                         ← Main installer
│
├── scripts/                              ← Utility scripts
│   ├── Start-Server.bat                  ← Launch server
│   ├── Backup-Server.ps1                 ← Automated backups
│   └── Monitor-Server.ps1                ← Health monitoring
│
├── configs/                              ← Configuration & templates
│   ├── templates/                        ← Server config templates
│   └── examples/                         ← Example configurations
│
├── docs/                                 ← Full documentation
│   ├── guides/                           ← Step-by-step guides
│   └── api/                              ← Module API reference
│
└── examples/                             ← Example implementations
    ├── custom-personalities/             ← NPC personality configs
    ├── advanced-features/                ← Advanced plugin configs
    └── integrations/                     ← Third-party integrations
```

---

## 🎓 Documentation Structure

### 📚 Start Here (Recommended Order)

```
1. 📖 README.md                    ← Overview (this file)
2. 🎯 QUICKSTART.md                ← Get running in 5 minutes
3. 📊 PROJECT_STATE.md             ← Complete project status
4. 📘 docs/USER_GUIDE.md           ← Detailed user guide
5. 🔧 docs/DEPLOYMENT_GUIDE.md     ← Advanced deployment
```

### 🤖 For Developers

```
1. 🏗️ docs/ARCHITECTURE.md         ← System design
2. 📝 docs/API_REFERENCE.md        ← Module APIs
3. 🧪 docs/TESTING_GUIDE.md        ← Testing strategies
4. 🎨 docs/CUSTOMIZATION.md        ← Extend the framework
```

### 🚀 For Next-Level Features

```
1. 🤖 IMPLEMENTATION_PROMPTS.md    ← Build advanced AI features
   - Virtual Claude Interface
   - Redstone Morse Communication
   - Persistent Memory Systems
   - Multi-NPC Coordination
```

---

## 💡 Usage Examples

### Basic Installation

```powershell
# Interactive installation with defaults
.\setup\Setup.ps1

# Unattended installation
.\setup\Setup.ps1 -Unattended

# Use a specific configuration file
.\setup\Setup.ps1 -ConfigFile ".\configs\examples\creative-server.json"

# Install with specific profile
.\setup\Setup.ps1 -InstallProfile "Full"
```

### Server Management

```powershell
# Start the server
.\scripts\Start-Server.bat

# Create backup
.\scripts\Backup-Server.ps1 -ServerPath "C:\MinecraftServer"

# Monitor server health
.\scripts\Monitor-Server.ps1 -ServerPath "C:\MinecraftServer"
```

### Using Core Modules in Your Scripts

```powershell
# Load the display module
. .\setup\core\Display.ps1

# Show branded banner
Show-Banner

# Display status with visual feedback
Write-StatusBox -Title "Deployment" -Status "Complete" -Type "Success"

# Get user confirmation
$proceed = Read-Confirmation -Message "Deploy to production?" -DefaultYes:$false
```

---

## 🎨 Install Profiles

Choose the perfect setup for your server:

### 🎯 Minimal
```
Perfect for: Testing, development, lightweight servers
Includes: Citizens (NPC plugin) only
Memory: 2-4GB recommended
```

### ⚙️ Standard (Recommended)
```
Perfect for: Most survival servers
Includes: Citizens, Vault, LuckPerms, CoreProtect, PlaceholderAPI
Memory: 4-8GB recommended
```

### 🚀 Full
```
Perfect for: Feature-rich servers, advanced builds
Includes: Standard + WorldEdit, WorldGuard, EssentialsX, Spark, GriefPrevention
Memory: 8-16GB recommended
```

---

## 🤖 ClaudeNPC Features

### Conversational AI NPCs

```yaml
# NPCs powered by Claude AI
- Natural language understanding
- Context-aware responses
- Personality customization
- Memory of past conversations
- Roleplaying capabilities
- Multi-NPC coordination
```

### Example Interactions

```
Player: "Hey, what's your name?"
NPC: "I'm Eldrin, the village blacksmith. Been forging weapons here 
for twenty years. Need something sharpened?"

Player: "Do you know where I can find diamonds?"
NPC: "Aye, there's a deep cave system southwest of here, past the 
old oak tree. Be careful though - I've heard strange noises coming 
from those depths lately."

Player: "Thanks! I'll check it out."
NPC: "Good luck, friend. Come back in one piece, and I'll craft you 
something special with whatever you find."
```

---

## 🎯 Advanced Features (Build These!)

See `IMPLEMENTATION_PROMPTS.md` for detailed specifications:

### 🖥️ Virtual Claude Interface
```
A persistent in-game terminal/screen where you can have full Claude.ai 
conversations. Walk away, come back - your chat is still there. Includes:
- Persistent conversation history
- Multi-line input support
- Code block rendering
- Screenshot capability
- Share conversations with friends
```

### 📡 Redstone Morse Communication
```
Communicate with Claude through redstone contraptions! Type messages,
they convert to morse, flash via redstone lamps, Claude decodes and 
responds. Includes:
- English ↔ Morse conversion
- Redstone signal encoding/decoding
- Visual feedback with lamps
- Integration with chat system
- Timing calibration tools
```

---

## 🏗️ Architecture Highlights

### Modular Design
```
✅ Independent modules - Use what you need
✅ Zero dependencies - Each module is self-contained
✅ Easy testing - Test modules individually
✅ Drop-in ready - Use in any PowerShell project
```

### Production Quality
```
✅ Comprehensive error handling
✅ Complete audit logging
✅ Progress indication
✅ User confirmation prompts
✅ Data backup before changes
✅ Validation at every step
```

### Best Practices
```
✅ SAIF methodology
✅ Separation of concerns
✅ DRY principles
✅ Consistent patterns
✅ Full documentation
✅ Real-world tested
```

---

## 🛠️ System Requirements

### Minimum
```
OS: Windows 10/11
PowerShell: 5.1 or higher
RAM: 4GB (for Minimal profile)
Disk: 10GB free space
Java: 17+ (auto-installed by setup)
```

### Recommended
```
OS: Windows 11
PowerShell: 7.4 or higher
RAM: 8GB or more
Disk: 20GB+ free space (SSD recommended)
Java: Latest LTS (21+)
Network: Stable broadband
```

---

## 📊 Project Status

```
Core Framework:     ✅ 100% Complete (Production Ready)
Installation Wizard: ✅ 100% Complete  
Core Modules:       ✅ 100% Complete (Display, Logger, Safety, Config)
Phase Modules:      ✅ 100% Complete (All 5 phases implemented)
Utility Scripts:    ✅ 100% Complete (Start, Backup, Monitor)
Documentation:      ✅ 100% Complete (9 comprehensive guides)
Testing:            ✅ Manual testing complete
Advanced Features:  📋 Specs ready (see IMPLEMENTATION_PROMPTS.md)
```

---

## 🎓 Learning Resources

### Video Tutorials (Coming Soon)
```
□ Installation walkthrough
□ NPC personality customization
□ Advanced features tutorial
□ Troubleshooting common issues
```

### Community Resources
```
□ Discord server (Coming Soon)
□ Example configurations
□ Community plugins
□ Best practices guide
```

---

## 🐛 Troubleshooting

### Common Issues

**"Module not found"**
```powershell
# Ensure you're in the correct directory
cd C:\ClaudeNPC-Server-Suite\setup
# Use absolute paths
$scriptRoot = $PSScriptRoot
. "$scriptRoot\core\Display.ps1"
```

**"Execution policy error"**
```powershell
# Run as Administrator:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**"Java not found"**
```
The setup will automatically install Java if not found. Just ensure
you have the OpenJDK ZIP in your Downloads folder, or let the setup
guide you to download it.
```

**"Port 25565 already in use"**
```
1. Check if another server is running
2. Change the port in server.properties
3. Restart the server
```

See `docs/TROUBLESHOOTING.md` for comprehensive solutions.

---

## 🤝 Contributing

We welcome contributions! See `docs/CONTRIBUTING.md` for:
- Code style guidelines
- Testing requirements
- Pull request process
- Feature request template

---

## 📜 License

**MIT License**

Copyright (c) 2024 ClaudeNPC Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

---

## 🎉 What's Next?

### Get Started Now
```powershell
cd setup
.\Setup.ps1
```

### Build Advanced Features
```
Open IMPLEMENTATION_PROMPTS.md and start building:
- Virtual Claude Interface
- Redstone Morse Communication
- Multi-NPC Coordination
- Persistent Memory Systems
```

### Join the Community
```
□ Star the repository
□ Share your configurations
□ Report bugs and suggestions
□ Contribute improvements
```

---

## 📞 Support

### Documentation
- Full docs in `docs/` directory
- API reference for developers
- Examples and templates included

### Community
- GitHub Issues (for bugs)
- GitHub Discussions (for questions)
- Discord (coming soon)

---

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                     🚀 Ready to Build Something Amazing?                     ║
║                                                                              ║
║                         cd setup && .\Setup.ps1                              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Built with ❤️ using Claude AI • SAIF Methodology • Production Ready**

**Version 1.0.0 • December 2024**
