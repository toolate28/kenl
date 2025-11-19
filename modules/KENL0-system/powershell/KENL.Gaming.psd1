@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'KENL Framework'
    CompanyName = 'KENL'
    Copyright = '(c) KENL Framework. All rights reserved.'
    Description = 'KENL Gaming Module - Play card management and gaming optimizations'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'New-KenlPlayCard',
        'Get-KenlPlayCard',
        'Edit-KenlPlayCard',
        'Export-KenlPlayCard',
        'Get-KenlHardwareProfile',
        'Test-KenlHardware',
        'Export-KenlHardwareProfile',
        'Optimize-KenlGaming',
        'Get-KenlGamingStatus',
        'Find-KenlInstalledGames',
        'Get-KenlLaunchOptions',
        'Get-KenlPriorityHosts'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @(
        'kcard-new',
        'kcard-get',
        'kcard-edit',
        'khw-profile',
        'khw-test',
        'kgame-opt',
        'kgame-status'
    )
    PrivateData = @{
        PSData = @{
            Tags = @('gaming', 'optimization', 'playcard', 'hardware')
            LicenseUri = ''
            ProjectUri = ''
            IconUri = ''
            ReleaseNotes = 'Initial release of KENL Gaming module'
        }
    }
}