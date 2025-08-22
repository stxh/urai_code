# qw.ps1 - Qwen Code AI service selector (PowerShell) using .conf
param()

function Show-Help {
    @"
qw - Qwen Code AI service selector with configuration files

Usage: qw.ps1 <config_name> [options]

Configuration:
  config_name    Name of the configuration file (without .conf extension)
                 Looks for $env:USERPROFILE\.aiconf\<config_name>.conf

  No arguments   Show this help message

Configuration file format ($env:USERPROFILE\.aiconf\<name>.conf):
  api_key=<your_api_key>
  base_url=<api_base_url>
  model=<model_name>

Environment variables (fallback):
  OPENAI_KEY      API key
  OPENAI_URL      Base URL
  OPENAI_MODEL    Model name

Examples:
  .\qw.ps1              Show this help message
  .\qw.ps1 k2           Use k2.conf configuration
  .\qw.ps1 myai         Use myai.conf configuration
  .\qw.ps1 --help       Show this help message

Configuration files should be placed in $env:USERPROFILE\.aiconf\
"@
}

function Show-Version {
    & qwen -v 2>$null
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
            '^api_key$'   { $env:OPENAI_API_KEY = $value }
            '^base_url$'  { $env:OPENAI_BASE_URL = $value }
            '^model$'     { $env:OPENAI_MODEL = $value }
        }
    }

    Write-Host "Using configuration: $ConfigName"
    if ($env:OPENAI_API_KEY) {
        $prefix = $env:OPENAI_API_KEY.Substring(0, [Math]::Min(8, $env:OPENAI_API_KEY.Length)) + '...'
        Write-Host "  API Key: $prefix"
    } else {
        Write-Host "  API Key: "
    }
    Write-Host "  Base URL: $($env:OPENAI_BASE_URL)"
    Write-Host "  Model: $($env:OPENAI_MODEL)"
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

# Ensure config directory exists
$null = New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE '.aiconf')

Read-Config -ConfigName $ConfigName

# Execute qwen/qwen.exe with remaining args
$cmd = Get-Command qwen -ErrorAction SilentlyContinue
if ($cmd) {
    & $cmd.Source @remaining
    exit $LASTEXITCODE
}
$cmd = Get-Command qwen.exe -ErrorAction SilentlyContinue
if ($cmd) {
    & $cmd.Source @remaining
    exit $LASTEXITCODE
}

Write-Error "Error: qwen executable not found in PATH"
exit 1

