param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$ConfigPath = $env:FEISHU_MCP_CONFIG
)

$ErrorActionPreference = "Stop"

$KitRoot = (Resolve-Path (Split-Path $PSScriptRoot -Parent)).Path
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Launcher = (Join-Path $KitRoot "scripts\feishu-mcp-stdio.ps1") -replace '\\', '/'
$CursorDir = Join-Path $ProjectPath ".cursor"
$RuleTarget = Join-Path $CursorDir "rules\feishu-docs.mdc"
$McpTarget = Join-Path $CursorDir "mcp.json"
$FeishuScripts = Join-Path $ProjectPath "scripts\feishu"
$LinkMeta = Join-Path $ProjectPath ".feishu-mcp.json"

$ResolvedConfig = ""
if ($ConfigPath) {
    $ResolvedConfig = ((Resolve-Path $ConfigPath).Path) -replace '\\', '/'
}

Write-Host "== link feishu-mcp to project ==" -ForegroundColor Cyan
Write-Host "Kit:     $KitRoot"
Write-Host "Project: $ProjectPath"
if ($ResolvedConfig) {
    Write-Host "Config:  $ResolvedConfig (via FEISHU_MCP_CONFIG in mcp.json)"
}

New-Item -ItemType Directory -Force -Path (Join-Path $CursorDir "rules") | Out-Null
Copy-Item (Join-Path $KitRoot "templates\cursor-rule-feishu-docs.mdc") $RuleTarget -Force

New-Item -ItemType Directory -Force -Path $FeishuScripts | Out-Null
Copy-Item (Join-Path $KitRoot "scripts\feishu\*.py") $FeishuScripts -Force

$mcpEntry = [ordered]@{
    command = "powershell"
    args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $Launcher
    )
}

if ($ResolvedConfig) {
    $mcpEntry.env = [ordered]@{
        FEISHU_MCP_CONFIG = $ResolvedConfig
    }
}

if (Test-Path $McpTarget) {
    $existing = Get-Content $McpTarget -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $existing.mcpServers) {
        $existing | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{})
    }
    $existing.mcpServers."feishu-mcp" = [pscustomobject]$mcpEntry
    $json = $existing | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($McpTarget, $json + "`n", [System.Text.UTF8Encoding]::new($false))
} else {
    $payload = @{ mcpServers = @{ "feishu-mcp" = [pscustomobject]$mcpEntry } }
    $json = $payload | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($McpTarget, $json + "`n", [System.Text.UTF8Encoding]::new($false))
}

$defaultConfig = (Join-Path $env:USERPROFILE ".feishu-mcp\config.env") -replace '\\', '/'
$meta = @{
    kit_path = $KitRoot
    linked_at = (Get-Date -Format "o")
    config = if ($ResolvedConfig) { $ResolvedConfig } else { $defaultConfig }
    feishu_mcp_config_env = if ($ResolvedConfig) { $ResolvedConfig } else { $null }
}
$meta | ConvertTo-Json -Depth 3 | Set-Content $LinkMeta -Encoding UTF8

Write-Host "Updated $McpTarget" -ForegroundColor Green
Write-Host "Copied scripts to $FeishuScripts"
Write-Host "Restart Cursor and check Tools & MCP -> feishu-mcp"
