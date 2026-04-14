param (
    [ValidateSet("github_copilot", "openrouter", "openai_anthropic_direct", "aws_bedrock", "opencode_zen")]
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
            if ($Model -match "claude") { $ProviderModel = "anthropic/claude-3-5-sonnet-latest" }
            elseif ($Model -match "gemini") { $ProviderModel = "google/gemini-3.1-pro-preview" }
            else { $ProviderModel = "openai/gpt-4o" }
        } elseif ($Provider -eq "openrouter") {
            if ($Model -match "claude") { $ProviderModel = "openrouter/anthropic/claude-3.5-sonnet" }
            elseif ($Model -match "gemini") { $ProviderModel = "openrouter/google/gemini-3.1-pro" }
            else { $ProviderModel = "openrouter/openai/gpt-4o" }
        } elseif ($Provider -eq "aws_bedrock") {
            if ($Model -match "claude") { $ProviderModel = "bedrock/anthropic.claude-3-5-sonnet-20241022-v2:0" }
            elseif ($Model -match "gemini") { $ProviderModel = "bedrock/amazon.nova-pro-v1:0" }
            else { $ProviderModel = "bedrock/meta.llama3-1-405b-instruct-v1:0" }
        } elseif ($Provider -eq "opencode_zen") {
            if ($Model -match "claude") { $ProviderModel = "claude-3-5-sonnet" }
            elseif ($Model -match "gemini") { $ProviderModel = "gemini-3.1-pro-preview" }
            else { $ProviderModel = "gpt-4o" }
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