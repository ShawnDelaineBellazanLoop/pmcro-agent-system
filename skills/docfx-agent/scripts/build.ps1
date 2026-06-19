<#
.SYNOPSIS
    Enterprise DocFX build script — {{company}} Colony / docfx-agent 1.0.0
.DESCRIPTION
    Bootstraps the .NET local tool manifest + docfx 2.78.5 if absent,
    then runs a full metadata + build pipeline.
    Safe to run from any working directory — DocfxRoot defaults to S:\docs.
.PARAMETER DocfxRoot
    Absolute path to the folder containing docfx.json. Defaults to S:\docs.
.PARAMETER Output
    Override the _site output folder. Defaults to the value in docfx.json.
.PARAMETER WarningsAsErrors
    Treat DocFX warnings as build errors (recommended for CI).
.PARAMETER Serve
    After a successful build, launch the built-in HTTP server on port 8080.
.EXAMPLE
    .\build.ps1
.EXAMPLE
    .\build.ps1 -WarningsAsErrors
.EXAMPLE
    .\build.ps1 -DocfxRoot S:\docs -Serve
#>
[CmdletBinding()]
param(
    [string]  $DocfxRoot        = 'S:\docs',
    [string]  $Output           = '',
    [switch]  $WarningsAsErrors,
    [switch]  $Serve
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Helpers ───────────────────────────────────────────────────────────────────
function Write-Step ([string]$msg) { Write-Host "`n▶  $msg" -ForegroundColor Cyan }
function Write-Ok   ([string]$msg) { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Fail ([string]$msg) { Write-Host "ERR $msg" -ForegroundColor Red }

# ── 0. Resolve DocfxRoot ──────────────────────────────────────────────────────
Write-Step 'Pre-flight checks'

$DocfxRoot = $DocfxRoot.TrimEnd('\').TrimEnd('/')
$docfxJson = Join-Path $DocfxRoot 'docfx.json'

if (-not (Test-Path $docfxJson)) {
    Write-Fail "docfx.json not found at: $docfxJson"
    Write-Host "  Hint: pass -DocfxRoot with the absolute path to the docs folder." -ForegroundColor DarkGray
    exit 1
}

Write-Ok "docfx.json found at $docfxJson"

# ── 1. Bootstrap tool manifest ────────────────────────────────────────────────
# EarnedConstraint EC-TOOL-MANIFEST: always bootstrap if absent — never fail.
# EarnedConstraint EC-MANIFEST-PATH: `dotnet new tool-manifest` writes to
#   <cwd>/dotnet-tools.json (not .config/dotnet-tools.json).
#   Check the actual output location after Push-Location $DocfxRoot.
Write-Step 'Bootstrapping .NET local tool manifest'

Push-Location $DocfxRoot
try {
    # dotnet new tool-manifest creates dotnet-tools.json in the CWD
    $toolManifest = Join-Path $DocfxRoot 'dotnet-tools.json'

    if (-not (Test-Path $toolManifest)) {
        Write-Host "  No dotnet-tools.json found — creating manifest and installing docfx 2.78.5" -ForegroundColor DarkGray

        dotnet new tool-manifest --force
        if ($LASTEXITCODE -ne 0) { Write-Fail 'dotnet new tool-manifest failed'; exit $LASTEXITCODE }

        dotnet tool install docfx --version 2.78.5
        if ($LASTEXITCODE -ne 0) { Write-Fail 'docfx tool install failed'; exit $LASTEXITCODE }

        Write-Ok "Manifest created and docfx 2.78.5 installed"
    } else {
        Write-Ok "Tool manifest found at $toolManifest"
    }
} finally {
    Pop-Location
}

# ── 2. Restore dotnet tools ───────────────────────────────────────────────────
Write-Step 'Restoring .NET local tools'

Push-Location $DocfxRoot
try {
    dotnet tool restore
    if ($LASTEXITCODE -ne 0) { Write-Fail 'dotnet tool restore failed'; exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Ok 'Tools restored'

# ── 3. docfx metadata ─────────────────────────────────────────────────────────
# Skipped: no S:\src C# projects exist. Metadata phase only needed when
# API reference generation is active. EarnedConstraint EC-NO-SRC-METADATA.
Write-Host "`n▶  docfx metadata" -ForegroundColor Cyan
Write-Host "  Skipping — no C# src projects configured (EC-NO-SRC-METADATA)" -ForegroundColor DarkGray

# ── 4. docfx build ───────────────────────────────────────────────────────────
Write-Step 'Running docfx build'

Push-Location $DocfxRoot
try {
    $buildArgs = @('tool', 'run', 'docfx', 'build', $docfxJson)
    if ($Output)            { $buildArgs += '--output', $Output }
    if ($WarningsAsErrors)  { $buildArgs += '--warningsAsErrors' }
    if ($env:CI -eq 'true') { $buildArgs += '--logLevel', 'Warning' }

    dotnet @buildArgs
    if ($LASTEXITCODE -ne 0) { Write-Fail 'docfx build failed'; exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Ok 'Build complete'

# ── 5. Optional: serve ───────────────────────────────────────────────────────
if ($Serve) {
    Write-Step 'Launching DocFX dev server on http://localhost:8080'
    Push-Location $DocfxRoot
    dotnet tool run docfx serve (Join-Path $DocfxRoot '_site') --port 8080
    Pop-Location
}

Write-Ok 'DISPOSITION: COMPLETE'
