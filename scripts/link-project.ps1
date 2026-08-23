param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"

$KitRoot = (Resolve-Path (Split-Path $PSScriptRoot -Parent)).Path
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Launcher = Join-Path $KitRoot "scripts\feishu-mcp-stdio.ps1"
$CursorDir = Join-Path $ProjectPath ".cursor"
$RuleTarget = Join-Path $CursorDir "rules\feishu-docs.mdc"
$McpTarget = Join-Path $CursorDir "mcp.json"
$FeishuScripts = Join-Path $ProjectPath "scripts\feishu"
$LinkMeta = Join-Path $ProjectPath ".feishu-mcp.json"

Write-Host "== link feishu-mcp to project ==" -ForegroundColor Cyan
Write-Host "Kit:     $KitRoot"
Write-Host "Project: $ProjectPath"

New-Item -ItemType Directory -Force -Path (Join-Path $CursorDir "rules") | Out-Null
Copy-Item (Join-Path $KitRoot "templates\cursor-rule-feishu-docs.mdc") $RuleTarget -Force

New-Item -ItemType Directory -Force -Path $FeishuScripts | Out-Null
Copy-Item (Join-Path $KitRoot "scripts\feishu\*.py") $FeishuScripts -Force

$mcpEntry = @{
    command = "powershell"
    args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $Launcher
    )
}

if (Test-Path $McpTarget) {
    $existing = Get-Content $McpTarget -Raw | ConvertFrom-Json
    if (-not $existing.mcpServers) {
        $existing | Add-Member -NotePropertyName mcpServers -NotePropertyValue @{}
    }
    $existing.mcpServers."feishu-mcp" = $mcpEntry
    $existing | ConvertTo-Json -Depth 6 | Set-Content $McpTarget -Encoding UTF8
} else {
    @{ mcpServers = @{ "feishu-mcp" = $mcpEntry } } |
        ConvertTo-Json -Depth 6 |
        Set-Content $McpTarget -Encoding UTF8
}

@{
    kit_path = $KitRoot
    linked_at = (Get-Date -Format "o")
    config = "$env:USERPROFILE\.feishu-mcp\config.env"
} | ConvertTo-Json -Depth 3 | Set-Content $LinkMeta -Encoding UTF8

Write-Host "Updated $McpTarget" -ForegroundColor Green
Write-Host "Copied scripts to $FeishuScripts"
Write-Host "Restart Cursor and check Tools & MCP -> feishu-mcp"
