<#
.SYNOPSIS
    DocFX local development server — {{company}} Colony / docfx-agent 1.0.0
.DESCRIPTION
    Runs `docfx --serve` with metadata generation for local authoring.
    Serves _site on http://localhost:8080.
    Prerequisite: .config/dotnet-tools.json with docfx 2.78.5 installed.
.PARAMETER DocfxRoot
    Path to folder containing docfx.json. Defaults to ./docs
.PARAMETER Port
    HTTP port to serve on. Defaults to 8080.
.PARAMETER SkipMetadata
    Skip the metadata phase (faster reload when only editing Markdown, not C# code).
.EXAMPLE
    .\serve.ps1
.EXAMPLE
    .\serve.ps1 -DocfxRoot ./docs -Port 9000 -SkipMetadata
#>
[CmdletBinding()]
param(
    [string] $DocfxRoot    = './docs',
    [int]    $Port         = 8080,
    [switch] $SkipMetadata
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step ([string]$msg) { Write-Host "`n▶  $msg" -ForegroundColor Cyan }
function Write-Ok   ([string]$msg) { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Fail ([string]$msg) { Write-Host "ERR $msg" -ForegroundColor Red }

# ── Pre-flight ────────────────────────────────────────────────────────────────
$docfxJson = Join-Path $DocfxRoot 'docfx.json'
if (-not (Test-Path $docfxJson)) {
    Write-Fail "docfx.json not found at: $docfxJson"
    exit 1
}

# ── Restore tools ─────────────────────────────────────────────────────────────
Write-Step 'Restoring .NET local tools'
dotnet tool restore
if ($LASTEXITCODE -ne 0) { Write-Fail 'dotnet tool restore failed'; exit $LASTEXITCODE }

# ── Metadata (optional) ───────────────────────────────────────────────────────
if (-not $SkipMetadata) {
    Write-Step 'Running docfx metadata'
    dotnet tool run docfx metadata $docfxJson
    if ($LASTEXITCODE -ne 0) { Write-Fail 'docfx metadata failed'; exit $LASTEXITCODE }
    Write-Ok 'Metadata ready'
}

# ── Build + Serve ─────────────────────────────────────────────────────────────
Write-Step "Building and serving at http://localhost:$Port"
Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray

# Open browser after a short delay — pass Port via ArgumentList (PS5 compatible)
$browserJob = Start-Job -ArgumentList $Port -ScriptBlock {
    param($p)
    Start-Sleep -Seconds 3
    Start-Process "http://localhost:$p"
}

# Run docfx with --serve flag (blocks until Ctrl+C)
dotnet tool run docfx $docfxJson --serve --port $Port

# Cleanup
Stop-Job  $browserJob -ErrorAction SilentlyContinue
Remove-Job $browserJob -ErrorAction SilentlyContinue
