param(
    [string]$ConfigPath = $env:FEISHU_MCP_CONFIG
)

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path $PSScriptRoot -Parent
$PyDir = Join-Path $KitRoot "scripts\feishu"

if ($ConfigPath) {
    $ConfigFile = (Resolve-Path $ConfigPath).Path
} else {
    $ConfigFile = Join-Path $env:USERPROFILE ".feishu-mcp\config.env"
}

if (-not (Test-Path $ConfigFile)) {
    throw "Missing config: $ConfigFile — run scripts/install.ps1 or pass -ConfigPath"
}

$env:FEISHU_MCP_CONFIG = $ConfigFile

function Import-DotEnvFile {
    param([string]$Path)
    Get-Content $Path -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $idx = $line.IndexOf("=")
        if ($idx -lt 1) { return }
        $key = $line.Substring(0, $idx).Trim()
        $val = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($key) { Set-Item -Path "Env:$key" -Value $val }
    }
}

Import-DotEnvFile -Path $ConfigFile

Write-Host "== verify feishu-cursor-mcp ==" -ForegroundColor Cyan
Write-Host "Config: $ConfigFile"

npx -y feishu-mcp@latest --version 2>&1 | Select-Object -Last 1

$body = @{ app_id = $env:FEISHU_APP_ID; app_secret = $env:FEISHU_APP_SECRET } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post `
    -Uri "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" `
    -ContentType "application/json" -Body $body
if ($resp.code -ne 0) { throw "tenant token failed: $($resp.msg)" }
Write-Host "tenant_access_token ok, expire=$($resp.expire)s" -ForegroundColor Green

if ($env:FEISHU_COLLABORATOR_OPEN_ID) {
    Write-Host "FEISHU_COLLABORATOR_OPEN_ID is set" -ForegroundColor Green
} elseif ($env:FEISHU_COLLABORATOR_MOBILE -or $env:FEISHU_COLLABORATOR_EMAIL) {
    python (Join-Path $PyDir "resolve_feishu_open_id.py")
} else {
    Write-Host "WARN: set FEISHU_COLLABORATOR_OPEN_ID for auto grant" -ForegroundColor Yellow
}

python (Join-Path $PyDir "smoke_test.py")
if ($LASTEXITCODE -ne 0) { throw "smoke_test failed" }
Write-Host "OK" -ForegroundColor Green
