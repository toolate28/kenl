---
project: kenl - Bazza-DX SAGE Framework
status: active
version: 1.0.0
classification: OWI-DOC
atom: ATOM-CFG-20251112-005
owi-version: 1.0.0
---

# Workflow Diagrams - 1.8TB External Drive Setup

**Purpose:** Visual guide for complete dual-boot partition setup

**ATOM Tag:** `ATOM-CFG-20251112-005`

---

## Complete Workflow Overview

```mermaid
graph TD
    A[Start: 1.8TB External Drive] --> B{OS?}

    B -->|Windows| C[Windows Phase]
    B -->|Linux| Z[ERROR: Start in Windows first]

    C --> C1[STEP1: Wipe Disk]
    C1 --> C2[STEP2: Create Partitions]
    C2 --> C3[STEP3: Verify Layout]
    C3 --> D{Success?}

    D -->|No| E[Check HANDOVER docs]
    E --> F[Fix issues]
    F --> C2

    D -->|Yes| G[Reboot to Bazzite-DX Linux]

    G --> H[Linux Phase]
    H --> H1[Format ext4 partitions]
    H1 --> H2[Configure /etc/fstab]
    H2 --> H3[Mount all partitions]
    H3 --> I{Mounted?}

    I -->|No| J[Check UUIDs]
    J --> H2

    I -->|Yes| K[Setup Complete]

    K --> L[Configure Steam Library]
    K --> M[Setup Claude AI Workspace]
    K --> N[Configure Development Env]

    L --> O[Install games once]
    O --> P[Play on both OSes!]

    style C fill:#0078d4,color:#fff
    style H fill:#06c,color:#fff
    style K fill:#0c6,color:#fff
    style Z fill:#d00,color:#fff
```

---

## Windows Phase Detail

```mermaid
stateDiagram-v2
    [*] --> CheckDisk: Get-Disk

    CheckDisk --> VerifyNotSystem: Is external drive?
    VerifyNotSystem --> [*]: ABORT - System disk!

    VerifyNotSystem --> STEP1: Confirmed

    state STEP1 {
        [*] --> OnlineDisk
        OnlineDisk --> ClearPartitions
        ClearPartitions --> WipeDisk: Clear-Disk
        WipeDisk --> CreateHandover: Success
        CreateHandover --> [*]
    }

    STEP1 --> STEP2: HANDOVER-WIPE created

    state STEP2 {
        [*] --> InitGPT: Initialize-Disk
        InitGPT --> CreateP1: Partition 1 (NTFS)
        CreateP1 --> CreateP2: Partition 2 (RAW)
        CreateP2 --> CreateP3: Partition 3 (RAW)
        CreateP3 --> CreateP4: Partition 4 (NTFS)
        CreateP4 --> CreateP5: Partition 5 (exFAT)
        CreateP5 --> WriteTest: Test all formatted
        WriteTest --> [*]
    }

    STEP2 --> STEP3: HANDOVER-PARTITION created

    state STEP3 {
        [*] --> CountPartitions
        CountPartitions --> VerifyFS: Count = 5?
        VerifyFS --> TestNTFS: Check filesystems
        TestNTFS --> TestExFAT
        TestExFAT --> TestRAW
        TestRAW --> Report: Generate verification
        Report --> [*]
    }

    STEP3 --> RebootLinux: All verified
    RebootLinux --> [*]
```

---

## Linux Phase Detail

```mermaid
flowchart TD
    A[Boot Bazzite-DX] --> B[Open Terminal]
    B --> C[Identify disk]
    C --> D[lsblk /dev/sdb]

    D --> E{5 partitions?}
    E -->|No| F[Check Windows STEP3]
    F --> A

    E -->|Yes| G[Format Partition 2]
    G --> G1["mkfs.ext4 -L Claude-AI-Data /dev/sdb2"]
    G1 --> H[Format Partition 3]
    H --> H1["mkfs.ext4 -L Development /dev/sdb3"]

    H1 --> I[Verify formatting]
    I --> I1["lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb"]

    I1 --> J{ext4 created?}
    J -->|No| K[Check error messages]
    K --> G

    J -->|Yes| L[Create mount points]
    L --> L1[mkdir /mnt/games-universal etc.]

    L1 --> M[Get UUIDs]
    M --> M1["blkid /dev/sdb* > partition-uuids.txt"]

    M1 --> N[Edit /etc/fstab]
    N --> N1[Add UUID mount entries]

    N1 --> O[Test mount]
    O --> O1["mount -a"]

    O1 --> P{All mounted?}
    P -->|No| Q[Check /etc/fstab syntax]
    Q --> N

    P -->|Yes| R[Setup complete!]

    R --> S1[Steam library config]
    R --> S2[Claude AI workspace]
    R --> S3[Development setup]

    style G1 fill:#06c,color:#fff
    style H1 fill:#06c,color:#fff
    style R fill:#0c6,color:#fff
```

---

## Partition Layout Visualization

```mermaid
graph LR
    subgraph "1.8TB External Drive /dev/sdb"
        P1["Partition 1<br/>Games-Universal<br/>900GB NTFS<br/>H: | /mnt/games-universal"]
        P2["Partition 2<br/>Claude-AI-Data<br/>500GB ext4<br/>I: WSL | /mnt/claude-ai"]
        P3["Partition 3<br/>Development<br/>200GB ext4<br/>L: WSL | /mnt/development"]
        P4["Partition 4<br/>Windows-Only<br/>150GB NTFS<br/>K: | /mnt/windows-only"]
        P5["Partition 5<br/>Transfer<br/>50GB exFAT<br/>J: | /mnt/transfer"]
    end

    P1 -.->|Windows| W1[Steam Library]
    P1 -.->|Linux| L1[Steam Library]

    P2 -.->|Linux Only| L2[Ollama/Qwen Models]
    P3 -.->|Linux Only| L3[Distrobox Containers]

    P4 -.->|Windows Only| W2[BF6/EA App]

    P5 -.->|Both OSes| T[File Exchange]

    style P1 fill:#0078d4,color:#fff
    style P2 fill:#06c,color:#fff
    style P3 fill:#06c,color:#fff
    style P4 fill:#0078d4,color:#fff
    style P5 fill:#0c6,color:#fff
```

---

## Filesystem Access Matrix

```mermaid
graph TB
    subgraph "Filesystem Compatibility"
        NTFS["NTFS<br/>(Partitions 1, 4)"]
        EXT4["ext4<br/>(Partitions 2, 3)"]
        EXFAT["exFAT<br/>(Partition 5)"]
    end

    subgraph "Operating Systems"
        WIN["Windows Native"]
        WSL["WSL2"]
        LIN["Linux Native<br/>(Bazzite-DX)"]
    end

    NTFS -->|Read/Write| WIN
    NTFS -->|Read/Write<br/>ntfs-3g| LIN
    NTFS -.->|Read-only<br/>Limited| WSL

    EXT4 -.->|WSL2 mount<br/>⚠️ Not recommended| WIN
    EXT4 -.->|Read/Write<br/>⚠️ Via WSL only| WSL
    EXT4 -->|Native Read/Write| LIN

    EXFAT -->|Native Read/Write| WIN
    EXFAT -.->|Read/Write| WSL
    EXFAT -->|Read/Write<br/>exfat-fuse| LIN

    style WIN fill:#0078d4,color:#fff
    style LIN fill:#06c,color:#fff
    style WSL fill:#f90,color:#000
```

---

## Error Handling Flow

```mermaid
flowchart TD
    A[Script Error] --> B{Which Step?}

    B -->|STEP1| C1[Wipe Failed]
    B -->|STEP2| C2[Partition Failed]
    B -->|STEP3| C3[Verification Failed]

    C1 --> D1{Error Type?}
    D1 -->|Access Denied| E1[Run as Administrator]
    D1 -->|Disk Offline| E2[Set-Disk -IsOffline $false]
    D1 -->|Wrong Disk| E3[Check disk number]

    C2 --> D2{Error Type?}
    D2 -->|Format Failed| E4[Wait 5s, retry]
    D2 -->|Drive Letter| E5[Choose different letter]
    D2 -->|Insufficient Space| E6[Adjust partition sizes]

    C3 --> D3{Error Type?}
    D3 -->|No NTFS Found| E7[Re-run STEP2]
    D3 -->|Write Test Failed| E8[Check disk health]
    D3 -->|Wrong Count| E9[Verify STEP2 completed]

    E1 --> F[Check HANDOVER doc]
    E2 --> F
    E3 --> F
    E4 --> F
    E5 --> F
    E6 --> F
    E7 --> F
    E8 --> F
    E9 --> F

    F --> G[Retry from failed step]

    style A fill:#d00,color:#fff
    style F fill:#f90,color:#000
    style G fill:#0c6,color:#fff
```

---

## Safety Decision Tree

```mermaid
graph TD
    A[Want to partition disk] --> B{Which OS currently?}

    B -->|Windows| C{Target disk type?}
    B -->|Linux| Z1[Boot Windows first]
    B -->|WSL2| Z2[❌ NEVER partition from WSL2]

    C -->|External USB/SATA| D[✅ Safe - Proceed]
    C -->|Internal NVMe| E{Is it system disk?}
    C -->|Unknown| F[Run Get-Disk first]

    E -->|Yes| Z3[❌ DANGER - Scripts will block]
    E -->|No| G[✅ Proceed with caution]

    D --> H[Run STEP1-STEP2-STEP3]
    G --> H

    H --> I[Reboot to Linux]
    I --> J{Native Linux boot?}

    J -->|Yes - Bazzite-DX| K[✅ Format ext4 partitions]
    J -->|No - WSL2| Z4[❌ Boot native Linux instead]

    K --> L[Setup complete]

    style D fill:#0c6,color:#fff
    style G fill:#f90,color:#000
    style K fill:#0c6,color:#fff
    style L fill:#0c6,color:#fff
    style Z1 fill:#d00,color:#fff
    style Z2 fill:#d00,color:#fff
    style Z3 fill:#d00,color:#fff
    style Z4 fill:#d00,color:#fff
```

---

## Usage Patterns

### Pattern 1: Gaming Setup

```mermaid
sequenceDiagram
    participant User
    participant Windows
    participant P1 as Partition 1 (NTFS)
    participant Linux

    User->>Windows: Install Steam
    Windows->>P1: Set library path H:\SteamLibrary
    User->>Windows: Download Cyberpunk 2077
    Windows->>P1: Write game files (100GB)

    Note over User,P1: Reboot to Linux

    User->>Linux: Open Steam
    Linux->>P1: Read library /mnt/games-universal/SteamLibrary
    Linux->>P1: Verify Cyberpunk files (no download!)
    User->>Linux: Play game via Proton

    Note over User,P1: Both OSes share same files
```

### Pattern 2: Anti-Cheat Gaming

```mermaid
sequenceDiagram
    participant User
    participant Windows
    participant P4 as Partition 4 (NTFS)
    participant P1 as Partition 1 (NTFS)

    User->>Windows: Install EA App
    Windows->>P4: Set install path K:\
    User->>Windows: Download BF6
    Windows->>P4: Write game (80GB)
    Windows->>P4: Install Javelin anti-cheat

    Note over User,P4: Windows-only, kernel drivers

    User->>Windows: Play BF6
    Windows->>P4: Load anti-cheat driver

    Note over User,P1: Other games in P1 work on Linux<br/>BF6 stays in P4 (Windows-only)
```

### Pattern 3: AI Development

```mermaid
sequenceDiagram
    participant User
    participant Linux
    participant P2 as Partition 2 (ext4)
    participant Ollama

    User->>Linux: Install Ollama
    Linux->>P2: Move models to /mnt/claude-ai/models
    User->>Linux: Pull qwen2.5:14b
    Ollama->>P2: Download 8GB model

    User->>Linux: Create symlink ~/.ollama/models
    Linux->>P2: Link to /mnt/claude-ai/models

    User->>Linux: Run AI query
    Linux->>P2: Load model from external drive
    Ollama->>P2: Cache results in /mnt/claude-ai/cache

    Note over User,P2: Fast ext4 performance<br/>Models survive OS reinstalls
```

---

## Troubleshooting Decision Flow

```mermaid
graph TD
    A[Issue Detected] --> B{Where in process?}

    B -->|Before STEP1| C[Pre-flight checks]
    B -->|During STEP1-3| D[Windows phase issues]
    B -->|During Linux format| E[Linux phase issues]
    B -->|After completion| F[Post-setup issues]

    C --> C1[Check disk visible: Get-Disk]
    C --> C2[Check permissions: Admin?]
    C --> C3[Check PowerShell: Version 5.1+?]

    D --> D1[Check HANDOVER docs]
    D --> D2[Review error messages]
    D --> D3[Verify disk not in use]

    E --> E1[Check lsblk output]
    E --> E2[Verify mkfs.ext4 installed]
    E --> E3[Check partition numbers]

    F --> F1[Check mount points: df -h]
    F --> F2[Verify /etc/fstab syntax]
    F --> F3[Test write access]

    C1 --> G[Read USAGE_PRIVACY.md]
    C2 --> G
    C3 --> G
    D1 --> G
    D2 --> G
    D3 --> G
    E1 --> G
    E2 --> G
    E3 --> G
    F1 --> G
    F2 --> G
    F3 --> G

    G --> H[Follow specific guide]

    style A fill:#f90,color:#000
    style G fill:#06c,color:#fff
```

---

**Last Updated:** 2025-11-12
**ATOM:** ATOM-CFG-20251112-005
