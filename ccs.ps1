# ccs.ps1 - AI service client selector (PowerShell) using .conf
param()

function Show-Help {
    @"
ccs - AI service client selector with configuration files

Usage: ccs.ps1 <config_name> [options]

Configuration:
  config_name    Name of the configuration file (without .conf extension)
                 Looks for $env:USERPROFILE\.aiconf\<config_name>.conf

  No arguments   Show this help message

Configuration file format ($env:USERPROFILE\.aiconf\<name>.conf):
  api_key=<your_api_key>
  claude_url=<claude_api_base_url>
  openai_url=<openai_api_base_url>
  model=<model_name>

Environment variables (fallback):
  ANTHROPIC_AUTH_TOKEN  API key
  ANTHROPIC_BASE_URL    Base URL

Examples:
  .\ccs.ps1              Show this help message
  .\ccs.ps1 k2           Use k2.conf configuration
  .\ccs.ps1 myai         Use myai.conf configuration
  .\ccs.ps1 --help       Show this help message

Configuration files should be placed in $env:USERPROFILE\.aiconf\
"@
}

function Show-Version {
    & claude --version 2>$null
}

function Read-Config([string]$ConfigName) {
    $configFile = Join-Path $env:USERPROFILE ".aiconf\$ConfigName.conf"
    if (-not (Test-Path -LiteralPath $configFile)) {
        Write-Error "Error: Configuration file not found: $configFile"
        exit 1
    }

    Get-Content -LiteralPath $configFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { return }
        $parts = $line -split '=', 2
        if ($parts.Count -lt 2) { return }
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"', "'")
        switch -Regex ($key) {
            '^api_key$'     { $env:ANTHROPIC_API_KEY = $value }
            '^claude_url$'  { $env:ANTHROPIC_BASE_URL = $value }
            '^openai_url$'  { # present for compatibility; ignored here }
            '^model$'       { $env:ANTHROPIC_MODEL = $value }
        }
    }

    Write-Host "Using configuration: $ConfigName"
    if ($env:ANTHROPIC_API_KEY) {
        $prefix = $env:ANTHROPIC_API_KEY.Substring(0, [Math]::Min(8, $env:ANTHROPIC_API_KEY.Length)) + '...'
        Write-Host "  API Key: $prefix"
    } else {
        Write-Host "  API Key: "
    }
    Write-Host "  Claude URL: $($env:ANTHROPIC_BASE_URL)"
    Write-Host "  Model: $($env:ANTHROPIC_MODEL)"
}

# Argument parsing
if ($args.Count -eq 0 -or $args[0] -eq '-h' -or $args[0] -eq '--help') {
    Show-Help
    exit 0
}
if ($args[0] -eq '-v' -or $args[0] -eq '--version') {
    Show-Version
    exit $LASTEXITCODE
}

$ConfigName = $args[0]
$remaining = @()
if ($args.Count -gt 1) { $remaining = $args[1..($args.Count-1)] }

# Ensure config directory exists (no-op if already exists)
$null = New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE '.aiconf')

Read-Config -ConfigName $ConfigName

# Execute claude/claude.exe with remaining args
$cmd = Get-Command claude -ErrorAction SilentlyContinue
if ($cmd) {
    & $cmd.Source @remaining
    exit $LASTEXITCODE
}
$cmd = Get-Command claude.exe -ErrorAction SilentlyContinue
if ($cmd) {
    & $cmd.Source @remaining
    exit $LASTEXITCODE
}

Write-Error "Error: claude executable not found in PATH"
exit 1

