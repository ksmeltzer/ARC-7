param (
    [Parameter(Mandatory=$true)]
    [string]$Target,
    
    [ValidateSet("copy", "symlink")]
    [string]$Mode = "copy"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Resolve-Path -Path $Target -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
if (-not $TargetDir) {
    $TargetDir = Join-Path -Path (Get-Location) -ChildPath $Target
}

Write-Host "Installing ARC-7 to $TargetDir (Mode: $Mode)..." -ForegroundColor Cyan

# Create directories if they don't exist
$null = New-Item -ItemType Directory -Force -Path "$TargetDir\skills", "$TargetDir\commands", "$TargetDir\agents"

if ($Mode -eq "symlink") {
    try {
        # Using Junctions for directories, SymbolicLink for files
        $null = New-Item -ItemType Junction -Force -Path "$TargetDir\skills\ARC-7" -Target "$RepoRoot\skills\ARC-7"
        $null = New-Item -ItemType SymbolicLink -Force -Path "$TargetDir\commands\ARC-7.md" -Target "$RepoRoot\commands\ARC-7.md"
        $null = New-Item -ItemType Junction -Force -Path "$TargetDir\agents\ARC-7" -Target "$RepoRoot\agents\ARC-7"
        Write-Host "✅ Symlinked ARC-7 to $TargetDir" -ForegroundColor Green
    } catch {
        Write-Warning "Symlinks require Administrator privileges on Windows."
        Write-Warning "Please run as Administrator, or run without --Mode symlink to use 'copy'."
        exit 1
    }
} else {
    Copy-Item -Recurse -Force "$RepoRoot\skills\ARC-7" "$TargetDir\skills\"
    Copy-Item -Force "$RepoRoot\commands\ARC-7.md" "$TargetDir\commands\"
    Copy-Item -Recurse -Force "$RepoRoot\agents\ARC-7" "$TargetDir\agents\"
    Write-Host "✅ Copied ARC-7 to $TargetDir" -ForegroundColor Green
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\configure_models.ps1 -Provider <your_provider> to map models in opencode.json (Fixes ProviderModelNotFoundError)."
Write-Host "  2. Restart your agent tool to load the /ARC-7 command."