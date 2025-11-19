#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Theming Module - Shell styling and formatting utilities

.DESCRIPTION
    Provides consistent theming, colors, and formatting for KENL shell interfaces,
    banners, and output styling.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-THEMING-20251110-001
#>

#region Theme Configuration

$script:KenlTheme = @{
    Colors = @{
        Primary = "Cyan"
        Secondary = "Yellow"
        Success = "Green"
        Warning = "Yellow"
        Error = "Red"
        Info = "Blue"
        Highlight = "Magenta"
        Gray = "Gray"
        White = "White"
    }

    Symbols = @{
        Success = "[✓]"
        Warning = "[!]"
        Error = "[✗]"
        Info = "[i]"
        Arrow = "→"
        Bullet = "•"
        Check = "✓"
        Cross = "✗"
        Star = "★"
    }

    Borders = @{
        TopLeft = "╔"
        TopRight = "╗"
        BottomLeft = "╚"
        BottomRight = "╝"
        Horizontal = "═"
        Vertical = "║"
        Cross = "╣"
        TTop = "╦"
        TBottom = "╩"
        TLeft = "╠"
        TRight = "╣"
    }

    Boxes = @{
        Single = @{
            TopLeft = "┌"
            TopRight = "┐"
            BottomLeft = "└"
            BottomRight = "┘"
            Horizontal = "─"
            Vertical = "│"
        }
        Double = @{
            TopLeft = "╔"
            TopRight = "╗"
            BottomLeft = "╚"
            BottomRight = "╝"
            Horizontal = "═"
            Vertical = "║"
        }
        Rounded = @{
            TopLeft = "╭"
            TopRight = "╮"
            BottomLeft = "╰"
            BottomRight = "╯"
            Horizontal = "─"
            Vertical = "│"
        }
    }
}

#endregion

#region Banner Functions

function New-KenlBanner {
    <#
    .SYNOPSIS
        Creates a formatted banner

    .PARAMETER Title
        Banner title

    .PARAMETER Subtitle
        Banner subtitle

    .PARAMETER Width
        Banner width

    .PARAMETER Style
        Border style (Single, Double, Rounded)

    .PARAMETER Color
        Banner color

    .EXAMPLE
        New-KenlBanner -Title "KENL Framework" -Subtitle "Gaming Infrastructure"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [string]$Subtitle,

        [int]$Width = 80,

        [ValidateSet("Single", "Double", "Rounded")]
        [string]$Style = "Double",

        [string]$Color = $script:KenlTheme.Colors.Primary
    )

    $box = $script:KenlTheme.Boxes.$Style
    $top = $box.TopLeft + ($box.Horizontal * ($Width - 2)) + $box.TopRight
    $bottom = $box.BottomLeft + ($box.Horizontal * ($Width - 2)) + $box.BottomRight

    Write-Host $top -ForegroundColor $Color

    # Title line
    $titleLine = $box.Vertical + " " + $Title.PadRight($Width - 4) + " " + $box.Vertical
    Write-Host $titleLine -ForegroundColor $Color

    if ($Subtitle) {
        $subtitleLine = $box.Vertical + " " + $Subtitle.PadRight($Width - 4) + " " + $box.Vertical
        Write-Host $subtitleLine -ForegroundColor $Color
    }

    Write-Host $bottom -ForegroundColor $Color
}

function Write-KenlBanner {
    <#
    .SYNOPSIS
        Writes a banner with content

    .PARAMETER Title
        Banner title

    .PARAMETER Content
        Array of content lines

    .PARAMETER Style
        Border style

    .EXAMPLE
        Write-KenlBanner -Title "System Status" -Content @("CPU: 45%", "Memory: 60%")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [string[]]$Content,

        [ValidateSet("Single", "Double", "Rounded")]
        [string]$Style = "Single",

        [string]$Color = $script:KenlTheme.Colors.Primary
    )

    $box = $script:KenlTheme.Boxes.$Style
    $width = 60

    $top = $box.TopLeft + ($box.Horizontal * ($width - 2)) + $box.TopRight
    Write-Host $top -ForegroundColor $Color

    # Title
    $titleLine = $box.Vertical + " $Title".PadRight($width - 1) + $box.Vertical
    Write-Host $titleLine -ForegroundColor $Color

    # Separator
    $sep = $box.TLeft + ($box.Horizontal * ($width - 2)) + $box.TRight
    Write-Host $sep -ForegroundColor $Color

    # Content
    foreach ($line in $Content) {
        $contentLine = $box.Vertical + " $line".PadRight($width - 1) + $box.Vertical
        Write-Host $contentLine -ForegroundColor White
    }

    $bottom = $box.BottomLeft + ($box.Horizontal * ($width - 2)) + $box.BottomRight
    Write-Host $bottom -ForegroundColor $Color
}

#endregion

#region Status Messages

function Write-KenlStatus {
    <#
    .SYNOPSIS
        Writes a status message with icon

    .PARAMETER Message
        Status message

    .PARAMETER Type
        Status type (Success, Warning, Error, Info)

    .EXAMPLE
        Write-KenlStatus "Operation completed" -Type Success
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("Success", "Warning", "Error", "Info", "Highlight")]
        [string]$Type = "Info"
    )

    $symbol = $script:KenlTheme.Symbols.$Type
    $color = $script:KenlTheme.Colors.$Type

    Write-Host "$symbol " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

function Write-KenlProgress {
    <#
    .SYNOPSIS
        Writes a progress indicator

    .PARAMETER Current
        Current value

    .PARAMETER Total
        Total value

    .PARAMETER Label
        Progress label

    .EXAMPLE
        Write-KenlProgress -Current 50 -Total 100 -Label "Processing"
    #>
    [CmdletBinding()]
    param(
        [int]$Current,

        [int]$Total,

        [string]$Label = "Progress"
    )

    $percent = [math]::Round(($Current / $Total) * 100)
    $barWidth = 20
    $filled = [math]::Round(($Current / $Total) * $barWidth)
    $empty = $barWidth - $filled

    $bar = "█" * $filled + "░" * $empty

    Write-Host "$Label [" -NoNewline -ForegroundColor Cyan
    Write-Host $bar -NoNewline -ForegroundColor Green
    Write-Host "] $percent%" -ForegroundColor Cyan
}

#endregion

#region Table Formatting

function Format-KenlTable {
    <#
    .SYNOPSIS
        Formats data as a themed table

    .PARAMETER Data
        Data to format

    .PARAMETER Properties
        Properties to display

    .PARAMETER Headers
        Custom headers

    .EXAMPLE
        Get-Process | Select-Object -First 5 | Format-KenlTable -Properties Name, CPU
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [PSObject[]]$Data,

        [string[]]$Properties,

        [string[]]$Headers
    )

    begin {
        $collected = @()
    }

    process {
        $collected += $Data
    }

    end {
        if (-not $collected) { return }

        if (-not $Properties) {
            $Properties = $collected[0].PSObject.Properties.Name
        }

        if (-not $Headers) {
            $Headers = $Properties
        }

        # Calculate column widths
        $widths = @{}
        for ($i = 0; $i -lt $Properties.Count; $i++) {
            $prop = $Properties[$i]
            $header = $Headers[$i]
            $maxWidth = [math]::Max($header.Length, ($collected | ForEach-Object { $_.PSObject.Properties[$prop].Value.ToString().Length } | Measure-Object -Maximum).Maximum)
            $widths[$prop] = $maxWidth
        }

        # Header
        $headerLine = "┌"
        foreach ($prop in $Properties) {
            $headerLine += ("─" * ($widths[$prop] + 2)) + "┬"
        }
        $headerLine = $headerLine.TrimEnd("┬") + "┐"
        Write-Host $headerLine -ForegroundColor Cyan

        # Headers
        $headerText = "│"
        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $headerText += " $($Headers[$i].PadRight($widths[$Properties[$i]])) │"
        }
        Write-Host $headerText -ForegroundColor Cyan

        # Separator
        $sepLine = "├"
        foreach ($prop in $Properties) {
            $sepLine += ("─" * ($widths[$prop] + 2)) + "┼"
        }
        $sepLine = $sepLine.TrimEnd("┼") + "┤"
        Write-Host $sepLine -ForegroundColor Cyan

        # Data rows
        foreach ($item in $collected) {
            $row = "│"
            for ($i = 0; $i -lt $Properties.Count; $i++) {
                $prop = $Properties[$i]
                $value = $item.PSObject.Properties[$prop].Value.ToString()
                $row += " $($value.PadRight($widths[$prop])) │"
            }
            Write-Host $row -ForegroundColor White
        }

        # Footer
        $footerLine = "└"
        foreach ($prop in $Properties) {
            $footerLine += ("─" * ($widths[$prop] + 2)) + "┴"
        }
        $footerLine = $footerLine.TrimEnd("┴") + "┘"
        Write-Host $footerLine -ForegroundColor Cyan
    }
}

#endregion

#region Shell Customization

function Set-KenlPrompt {
    <#
    .SYNOPSIS
        Sets a themed PowerShell prompt

    .PARAMETER Style
        Prompt style

    .EXAMPLE
        Set-KenlPrompt -Style "Minimal"
    #>
    [CmdletBinding()]
    param(
        [ValidateSet("Minimal", "Full", "Gaming")]
        [string]$Style = "Minimal"
    )

    $promptScript = switch ($Style) {
        "Minimal" {
            {
                $symbol = if ($?) { "✓" } else { "✗" }
                Write-Host "$symbol " -ForegroundColor $(if ($?) { "Green" } else { "Red" }) -NoNewline
                Write-Host "$(Split-Path $pwd -Leaf)" -ForegroundColor Cyan -NoNewline
                Write-Host " >" -ForegroundColor Gray -NoNewline
                " "
            }
        }
        "Full" {
            {
                $time = Get-Date -Format "HH:mm:ss"
                $path = $pwd.Path.Replace($HOME, "~")
                $symbol = if ($?) { "✓" } else { "✗" }

                Write-Host "[$time] " -ForegroundColor Gray -NoNewline
                Write-Host "$symbol " -ForegroundColor $(if ($?) { "Green" } else { "Red" }) -NoNewline
                Write-Host "$path" -ForegroundColor Cyan -NoNewline
                Write-Host "`n>" -ForegroundColor Gray -NoNewline
                " "
            }
        }
        "Gaming" {
            {
                $symbol = if ($?) { "🎮" } else { "💥" }
                Write-Host "$symbol KENL " -ForegroundColor Magenta -NoNewline
                Write-Host "$(Split-Path $pwd -Leaf)" -ForegroundColor Cyan -NoNewline
                Write-Host " >" -ForegroundColor Yellow -NoNewline
                " "
            }
        }
    }

    Set-Item -Path Function:\prompt -Value $promptScript -Force
    Write-KenlStatus "Prompt updated to $Style style" -Type Success

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type THEMING -Action "Set PowerShell prompt to $Style style"
    }
}

function Show-KenlColorPalette {
    <#
    .SYNOPSIS
        Displays the KENL color palette

    .EXAMPLE
        Show-KenlColorPalette
    #>
    [CmdletBinding()]
    param()

    Write-Host "KENL Color Palette:" -ForegroundColor White
    Write-Host ""

    foreach ($color in $script:KenlTheme.Colors.GetEnumerator()) {
        Write-Host "  $($color.Key.PadRight(10)): " -NoNewline
        Write-Host "████████" -ForegroundColor $color.Value
    }

    Write-Host ""
    Write-Host "Symbols:" -ForegroundColor White
    foreach ($symbol in $script:KenlTheme.Symbols.GetEnumerator()) {
        Write-Host "  $($symbol.Key.PadRight(10)): $($symbol.Value)" -ForegroundColor Cyan
    }
}

#endregion

#region Export

Export-ModuleMember -Function @(
    'New-KenlBanner',
    'Write-KenlBanner',
    'Write-KenlStatus',
    'Write-KenlProgress',
    'Format-KenlTable',
    'Set-KenlPrompt',
    'Show-KenlColorPalette'
) -Alias @(
    'kbanner',
    'kstatus',
    'kprogress',
    'ktable',
    'kprompt',
    'kcolors'
) -Variable @(
    'KenlTheme'
)

#endregion

# Module banner
$themeBanner = @"

╔══════════════════════════════════════════════════════════════╗
║                     KENL THEMING LOADED                     ║
║               Consistent Shell Styling Active               ║
╚══════════════════════════════════════════════════════════════╝

Available Styles:
  New-KenlBanner          # Create formatted banners
  Write-KenlStatus        # Themed status messages
  Set-KenlPrompt          # Customize shell prompt
  Show-KenlColorPalette   # View color scheme

"@
Write-Host $themeBanner -ForegroundColor Magenta

Write-Host "KENL.Theming module loaded" -ForegroundColor Magenta
Write-Host "Run 'Show-KenlColorPalette' to see available colors" -ForegroundColor Gray