param (
    [ValidateSet("github_copilot", "openrouter", "openai_anthropic_direct")]
    [string]$Provider = "github_copilot"
)

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Files = Get-ChildItem -Path "$RepoRoot\agents\ARC-7\arc7-*.md"
$AgentMap = @{}

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw
    if ($Content -match 'recommended_model:\s*"([^"]+)"') {
        $Model = $Matches[1]
        $ProviderModel = $Model

        if ($Provider -eq "github_copilot") {
            $ProviderModel = "github-copilot/$Model"
        } elseif ($Provider -eq "openai_anthropic_direct") {
            if ($Model -match "claude") { $ProviderModel = "anthropic/claude-3-opus-20240229" }
            elseif ($Model -match "gemini") { $ProviderModel = "google/gemini-1.5-pro-preview" }
            else { $ProviderModel = "openai/gpt-4o" }
        } elseif ($Provider -eq "openrouter") {
            if ($Model -match "claude") { $ProviderModel = "openrouter/anthropic/claude-3-opus" }
            elseif ($Model -match "gemini") { $ProviderModel = "openrouter/google/gemini-pro-1.5" }
            else { $ProviderModel = "openrouter/openai/gpt-4o" }
        }

        $AgentMap[$File.BaseName] = @{ "model" = $ProviderModel }
    }
}

$Output = @{ "agent" = $AgentMap }

Write-Host "✅ Generated Configuration for Provider: $Provider" -ForegroundColor Green
Write-Host "Copy and paste this block into your global opencode.json or agent config file:`n" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor Cyan
$Output | ConvertTo-Json -Depth 3
Write-Host "--------------------------------------------------" -ForegroundColor Cyan