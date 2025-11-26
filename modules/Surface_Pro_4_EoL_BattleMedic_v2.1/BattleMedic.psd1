#
# Module manifest for module 'BattleMedic'
# Version 2.1.0 - Production Ready with Full Dependency Management
#

@{

# Script module or binary module file associated with this manifest
RootModule = 'BattleMedic.psm1'

# Version number of this module
ModuleVersion = '2.1.0'

# Supported PSEditions - Works with Windows PowerShell and PowerShell Core
CompatiblePSEditions = @('Desktop', 'Core')

# ID used to uniquely identify this module
GUID = 'f8d4e3c2-9a6b-4d2e-8c1f-3b7a5e9d2f4c'

# Author of this module
Author = 'Battle Medic Recovery Team'

# Company or vendor of this module
CompanyName = 'Surface Pro 4 EoL Support Initiative'

# Copyright statement for this module
Copyright = '(c) 2024 Battle Medic Recovery. MIT License.'

# Description of the functionality provided by this module
Description = @'
Battle Medic Recovery Suite v2.1 - Enterprise-ready Windows recovery framework
===============================================================================

CAPABILITIES:
• Automated system triage with P0-P3 priority classification
• Surface Pro 4 hardware issue mitigation (screen flicker, Type Cover, thermals)
• WOF.SYS BSOD recovery (Error 0xD3)
• Windows Recovery Environment (WinRE) integration
• Idempotent operations with automatic rollback
• Cross-version PowerShell compatibility (3.0-7.x)

COMPATIBILITY:
• Windows PowerShell 3.0, 4.0, 5.0, 5.1
• PowerShell Core 6.x, 7.x
• Windows 10 (1507+), Windows 11, Windows Server 2012 R2+
• Special optimizations for Surface Pro 4

DESIGN PRINCIPLES:
• All operations are idempotent and safe to re-run
• Automatic environment detection and adaptation
• Comprehensive logging with SAIF compliance
• Zero external dependencies for core functionality
'@

# Minimum version of PowerShell engine - Set to 3.0 for maximum compatibility
PowerShellVersion = '3.0'

# Minimum version of Microsoft .NET Framework required
DotNetFrameworkVersion = '4.0'

# CLR version for Windows PowerShell compatibility
CLRVersion = '4.0'

# Processor architecture
ProcessorArchitecture = 'None'

# Required modules - Only built-in Windows modules
RequiredModules = @()

# Optional modules that enhance functionality if available
# These are NOT required - module will work without them
# @{ModuleName = 'CimCmdlets'; ModuleVersion = '1.0.0'; Optional = $true}
# @{ModuleName = 'Microsoft.PowerShell.Management'; ModuleVersion = '3.0.0'; Optional = $true}

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files run in caller's environment prior to importing this module
ScriptsToProcess = @('Scripts\Initialize-Environment.ps1')

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @('Types\BattleMedic.Types.ps1xml')

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('Formats\BattleMedic.Format.ps1xml')

# Modules to import as nested modules
NestedModules = @(
    'Modules\BattleMedic.Core.psm1',        # Core functionality (no dependencies)
    'Modules\BattleMedic.Diagnostics.psm1', # System diagnostics
    'Modules\BattleMedic.Recovery.psm1',    # Recovery operations
    'Modules\BattleMedic.SP4.psm1',         # Surface Pro 4 specific
    'Modules\BattleMedic.WinRE.psm1',       # Windows RE integration
    'Modules\BattleMedic.Logging.psm1',     # SAIF-compliant logging
    'Modules\BattleMedic.Compatibility.psm1' # Version compatibility layer
)

# Functions to export from this module
FunctionsToExport = @(
    # Core Functions (Always Available)
    'Initialize-BattleMedic',
    'Test-BattleMedicEnvironment',
    'Get-BattleMedicVersion',
    'Get-BattleMedicConfig',
    'Set-BattleMedicConfig',

    # Diagnostic Functions
    'Get-BattleMedicDiagnostic',
    'Get-SystemHealthReport',
    'Test-SystemPriority',
    'Get-HardwareStatus',

    # Recovery Operations (Idempotent)
    'Start-BattleMedicRecovery',
    'Repair-WOFDriver',
    'Repair-SystemFiles',
    'Start-EmergencyCleanup',
    'Reset-WindowsUpdate',
    'New-RecoveryCheckpoint',
    'Restore-RecoveryCheckpoint',

    # SP4 Specific (Auto-detected)
    'Get-SP4Status',
    'Repair-SP4ScreenFlicker',
    'Repair-SP4TypeCover',
    'Reset-SP4GPUDriver',
    'Start-SP4ThermalMitigation',

    # WinRE Integration
    'Install-BattleMedicToWinRE',
    'Start-WinRERecovery',
    'Get-WinREStatus',
    'Test-WinREAvailable',

    # Logging and Reporting (SAIF Compliant)
    'Get-BattleMedicLog',
    'Export-BattleMedicReport',
    'New-SAIFAuditEntry',
    'Get-RecoveryHistory',

    # User Interface
    'Show-RecoveryMenu',
    'Start-GuidedRecovery',
    'Start-AutomatedRecovery',
    'Start-InteractiveRecovery'
)

# Cmdlets to export
CmdletsToExport = @()

# Variables to export
VariablesToExport = @(
    'BattleMedicVersion',
    'BattleMedicConfig',
    'BattleMedicCompatibilityMode'
)

# Aliases to export - Short commands for common operations
AliasesToExport = @(
    'bmr',       # Start-BattleMedicRecovery
    'bmdiag',    # Get-BattleMedicDiagnostic
    'bmlog',     # Get-BattleMedicLog
    'bmhelp',    # Get-BattleMedicHelp
    'sp4fix',    # Start-SP4Recovery
    'woffix',    # Repair-WOFDriver
    'bmcheck',   # Test-BattleMedicEnvironment
    'bminit'     # Initialize-BattleMedic
)

# DSC resources to export
DscResourcesToExport = @()

# List of all files in this module
FileList = @(
    # Core Module Files
    'BattleMedic.psd1',
    'BattleMedic.psm1',
    'LICENSE',
    'README.md',

    # Initialization Scripts
    'Scripts\Initialize-Environment.ps1',
    'Scripts\Test-Prerequisites.ps1',

    # Nested Modules
    'Modules\BattleMedic.Core.psm1',
    'Modules\BattleMedic.Diagnostics.psm1',
    'Modules\BattleMedic.Recovery.psm1',
    'Modules\BattleMedic.SP4.psm1',
    'Modules\BattleMedic.WinRE.psm1',
    'Modules\BattleMedic.Logging.psm1',
    'Modules\BattleMedic.Compatibility.psm1',

    # Type and Format Definitions
    'Types\BattleMedic.Types.ps1xml',
    'Formats\BattleMedic.Format.ps1xml',

    # Configuration
    'Config\DefaultConfig.json',
    'Config\SP4Config.json',
    'Config\SAIFTemplate.json',

    # Resources
    'Resources\RecoveryMenu.xaml',
    'Resources\Messages.psd1',
    'Resources\ErrorCodes.json',

    # Documentation
    'Documentation\BattleMedic-Manual.md',
    'Documentation\QuickStart.md',
    'Documentation\TechnicalReference.md',
    'Documentation\SP4-KnownIssues.md',
    'Documentation\SAIF-Compliance.md',

    # Tests
    'Tests\BattleMedic.Tests.ps1',
    'Tests\Compatibility.Tests.ps1',
    'Tests\Idempotency.Tests.ps1'
)

# Private data to pass to the module
PrivateData = @{

    # PSData for PowerShell Gallery
    PSData = @{

        # Tags for module discovery
        Tags = @(
            'Recovery', 'Diagnostics', 'Surface', 'SurfacePro4', 'SP4',
            'Windows10', 'Windows11', 'WindowsRecovery', 'WinRE',
            'SystemRepair', 'BSOD', 'WOF', 'EndOfLife', 'EoL',
            'Maintenance', 'ThermalManagement', 'Idempotent',
            'CrossPlatform', 'PSEdition_Desktop', 'PSEdition_Core',
            'Windows', 'SAIF', 'Audit', 'Compliance'
        )

        # URLs
        LicenseUri = 'https://github.com/battlemedic/BattleMedic/blob/main/LICENSE'
        ProjectUri = 'https://github.com/battlemedic/BattleMedic'
        IconUri = 'https://github.com/battlemedic/BattleMedic/blob/main/Resources/icon.png'

        # Release Notes
        ReleaseNotes = @'
Version 2.1.0 - Production Ready
================================
NEW FEATURES:
• Full PowerShell 3.0-7.x compatibility
• Idempotent operations with automatic state detection
• SAIF-compliant audit logging
• Claude Code integration support
• Obsidian-compatible documentation

IMPROVEMENTS:
• Zero external dependencies for core functionality
• Automatic environment detection and adaptation
• Enhanced error handling with graceful degradation
• Comprehensive rollback capabilities
• Better SP4 hardware detection

BUG FIXES:
• Fixed WMI queries on PowerShell 3.0
• Resolved CIM cmdlet compatibility issues
• Fixed Unicode handling in logs
• Corrected thermal reading conversions

BREAKING CHANGES:
• None - Full backward compatibility maintained
'@

        # Requirements
        RequireLicenseAcceptance = $false

        # Dependencies handled internally
        ExternalModuleDependencies = @()
    }

    # Internal Configuration
    ModuleConfig = @{
        # Compatibility Settings
        MinPSVersion = '3.0'
        MaxPSVersion = '7.99'

        # Feature Flags
        Features = @{
            AutoDetectSP4 = $true
            EnableSAIFLogging = $true
            UseCompatibilityMode = $true
            AutoCreateCheckpoints = $true
            EnableTelemetry = $false
        }

        # Environment Detection
        SupportedOS = @(
            'Microsoft Windows 10*',
            'Microsoft Windows 11*',
            'Microsoft Windows Server 2012 R2*',
            'Microsoft Windows Server 2016*',
            'Microsoft Windows Server 2019*',
            'Microsoft Windows Server 2022*'
        )

        # Claude Code Integration
        ClaudeCodeCompatible = $true
        ClaudeCodeVersion = '1.0+'
    }
}

# HelpInfo URI
HelpInfoURI = 'https://github.com/battlemedic/BattleMedic/wiki'

# Default command prefix (can be overridden with Import-Module -Prefix)
# DefaultCommandPrefix = ''

}
