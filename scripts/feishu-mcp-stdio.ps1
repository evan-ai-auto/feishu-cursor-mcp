# Launch feishu-mcp (stdio) for Cursor MCP.
# Reads unified config: FEISHU_MCP_CONFIG or ~/.feishu-mcp/config.env

$ErrorActionPreference = "Stop"

function Import-DotEnvFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $idx = $line.IndexOf("=")
        if ($idx -lt 1) { return }
        $key = $line.Substring(0, $idx).Trim()
        $val = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($key) { Set-Item -Path "Env:$key" -Value $val }
    }
    return $true
}

$configPath = $env:FEISHU_MCP_CONFIG
if (-not $configPath) {
    $configPath = Join-Path $env:USERPROFILE ".feishu-mcp\config.env"
}

$loaded = Import-DotEnvFile -Path $configPath
if (-not $loaded) {
  # Legacy fallback: project .env.feishu
  $rootDir = (Get-Location).Path
  $legacy = Join-Path $rootDir ".env.feishu"
  if (Test-Path $legacy) { Import-DotEnvFile -Path $legacy | Out-Null }
}

if (-not $env:FEISHU_APP_ID -or -not $env:FEISHU_APP_SECRET) {
    [Console]::Error.WriteLine(
        "[feishu-mcp] Missing FEISHU_APP_ID or FEISHU_APP_SECRET.`n" +
        "Create $configPath from config/config.env.example`n" +
        "Run: powershell -File scripts/install.ps1"
    )
    exit 1
}

$authType = if ($env:FEISHU_AUTH_TYPE) { $env:FEISHU_AUTH_TYPE } else { "tenant" }
$modules = if ($env:FEISHU_ENABLED_MODULES) { $env:FEISHU_ENABLED_MODULES } else { "document" }
$userKey = if ($env:FEISHU_USER_KEY) { $env:FEISHU_USER_KEY } else { "stdio" }

$args = @(
    "-y", "feishu-mcp@latest",
    "--stdio",
    "--feishu-app-id=$($env:FEISHU_APP_ID)",
    "--feishu-app-secret=$($env:FEISHU_APP_SECRET)",
    "--feishu-auth-type=$authType",
    "--enabled-modules=$modules",
    "--user-key=$userKey"
)

if ($env:FEISHU_SCOPE_VALIDATION -eq "false") {
    $args += "--feishu-scope-validation=false"
}

& npx @args
exit $LASTEXITCODE
