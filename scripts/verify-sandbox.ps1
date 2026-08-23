param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath,

    [string]$SandboxRoot = "E:\sandbox",

    [string]$ProjectName = "cursor-mcp-test"
)

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path $PSScriptRoot -Parent

$ConfigPath = (Resolve-Path $ConfigPath).Path
$PrivateDir = Join-Path $SandboxRoot "feishu-mcp-private"
$KitDir = Join-Path $SandboxRoot "feishu-cursor-mcp"
$ProjectDir = Join-Path $SandboxRoot $ProjectName

Write-Host "== feishu-cursor-mcp sandbox verify ==" -ForegroundColor Cyan
Write-Host "Config:  $ConfigPath"
Write-Host "Kit:     $KitDir"
Write-Host "Project: $ProjectDir"

if (-not (Test-Path $ConfigPath)) {
    throw "Config not found: $ConfigPath"
}

# 1) CLI verify with isolated config
& (Join-Path $KitRoot "scripts\verify.ps1") -ConfigPath $ConfigPath

# 2) link-project with config env injected into mcp.json
& (Join-Path $KitRoot "scripts\link-project.ps1") `
    -ProjectPath $ProjectDir `
    -ConfigPath $ConfigPath

Write-Host ""
Write-Host "Sandbox verify CLI: OK" -ForegroundColor Green
Write-Host ""
Write-Host "Next (manual):"
Write-Host "  1. Open NEW Cursor window (not your main project)"
Write-Host "  2. Folder: $ProjectDir"
Write-Host "  3. Settings -> Tools & MCP -> feishu-mcp should be green"
Write-Host "  4. Run smoke prompt from QUICKSTART.md"
Write-Host ""
Write-Host "See docs/VERIFY_SANDBOX.md for details."
