# One-time setup: create ~/.feishu-mcp/config.env
$ErrorActionPreference = "Stop"

$KitRoot = Split-Path $PSScriptRoot -Parent
$ConfigDir = Join-Path $env:USERPROFILE ".feishu-mcp"
$ConfigFile = Join-Path $ConfigDir "config.env"
$Example = Join-Path $KitRoot "config\config.env.example"

Write-Host "== feishu-cursor-mcp install ==" -ForegroundColor Cyan
Write-Host "Kit: $KitRoot"

foreach ($cmd in @("node", "npx", "python")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "Missing prerequisite: $cmd"
    }
}

New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

if (-not (Test-Path $ConfigFile)) {
    $example = Get-Content $Example -Raw -Encoding UTF8
    [System.IO.File]::WriteAllText($ConfigFile, $example, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Created $ConfigFile" -ForegroundColor Green
    Write-Host "Edit it with your Feishu app credentials and wiki settings."
    Write-Host "Tip: save as UTF-8 (not GBK) if config contains Chinese." -ForegroundColor Yellow
} else {
    Write-Host "Keep existing $ConfigFile"
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $ConfigFile"
Write-Host "  2. Import templates/feishu-tenant-scopes.json in Feishu console (once per tenant)"
Write-Host "  3. powershell -File scripts/verify.ps1"
Write-Host "  4. powershell -File scripts/link-project.ps1 -ProjectPath <your-project>"
Write-Host "  5. Restart Cursor"
