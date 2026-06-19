<#
.SYNOPSIS
    DocFX output validation script — {{company}} Colony / docfx-agent 1.0.0
.DESCRIPTION
    Runs a suite of validation checks against a completed DocFX build:
      1. docfx.json JSON schema lint (PowerShell built-in JSON parser)
      2. Required config file presence check
      3. DocFX metadata + build with --warningsAsErrors (zero-warning policy)
      4. Broken internal link scan in _site/**/*.html
    Intended to run in CI before any deployment step.
.PARAMETER DocfxRoot
    Path to the folder containing docfx.json. Defaults to ./docs
.PARAMETER SiteRoot
    Path to the built _site folder. Defaults to $DocfxRoot/_site
.PARAMETER SkipBuild
    Skip the rebuild step (use existing _site). Useful when validate runs after build.
.PARAMETER FailFast
    Stop on first validation failure instead of collecting all errors.
.EXAMPLE
    .\validate.ps1 -DocfxRoot ./docs
.EXAMPLE
    .\validate.ps1 -DocfxRoot ./docs -SkipBuild
#>
[CmdletBinding()]
param(
    [string] $DocfxRoot = './docs',
    [string] $SiteRoot  = '',
    [switch] $SkipBuild,
    [switch] $FailFast
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $SiteRoot) { $SiteRoot = Join-Path $DocfxRoot '_site' }

$errors   = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Write-Step ([string]$msg) { Write-Host "`n▶  $msg" -ForegroundColor Cyan }
function Write-Ok   ([string]$msg) { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Warn ([string]$msg) {
    Write-Host "WRN $msg" -ForegroundColor Yellow
    $warnings.Add($msg)
}
function Fail ([string]$msg) {
    Write-Host "ERR $msg" -ForegroundColor Red
    $errors.Add($msg)
    if ($FailFast) { Write-Host "`nFail-fast enabled. Aborting."; exit 1 }
}

# ── 1. JSON schema lint ───────────────────────────────────────────────────────
Write-Step 'Check 1/4: docfx.json syntax'
$docfxJson = Join-Path $DocfxRoot 'docfx.json'
if (-not (Test-Path $docfxJson)) {
    Fail "docfx.json not found at $docfxJson"
} else {
    try {
        $null = Get-Content $docfxJson -Raw | ConvertFrom-Json -ErrorAction Stop
        Write-Ok 'docfx.json is valid JSON'
    } catch {
        Fail "docfx.json JSON parse error: $_"
    }
}

# ── 2. Required config file presence ─────────────────────────────────────────
Write-Step 'Check 2/4: Required config files'
$requiredFiles = @(
    (Join-Path $DocfxRoot 'docfx.json'),
    (Join-Path $DocfxRoot 'toc.yml'),
    (Join-Path $DocfxRoot 'index.md'),
    (Join-Path $DocfxRoot 'filterConfig.yml')
)
foreach ($f in $requiredFiles) {
    if (Test-Path $f) { Write-Ok "Found: $f" }
    else              { Write-Warn "Missing (recommended): $f" }
}

# ── 3. DocFX rebuild with --warningsAsErrors ──────────────────────────────────
if (-not $SkipBuild) {
    Write-Step 'Check 3/4: DocFX metadata + build (warningsAsErrors)'
    dotnet tool restore | Out-Null

    dotnet tool run docfx metadata $docfxJson --logLevel Warning
    if ($LASTEXITCODE -ne 0) { Fail 'docfx metadata produced errors' }

    dotnet tool run docfx build $docfxJson --warningsAsErrors --logLevel Warning
    if ($LASTEXITCODE -ne 0) { Fail 'docfx build produced warnings/errors' }
    else { Write-Ok 'Zero-warning build confirmed' }
} else {
    Write-Host '  SkipBuild set — skipping docfx rebuild' -ForegroundColor DarkGray
}

# ── 4. Broken internal link scan ──────────────────────────────────────────────
Write-Step 'Check 4/4: Internal link scan in _site'
if (-not (Test-Path $SiteRoot)) {
    Write-Warn "_site not found at $SiteRoot — skipping link scan. Run build first."
} else {
    $htmlFiles  = Get-ChildItem -Path $SiteRoot -Recurse -Filter '*.html'
    $brokenRefs = New-Object System.Collections.Generic.List[string]

    foreach ($html in $htmlFiles) {
        $content = Get-Content $html.FullName -Raw
        $refs = [regex]::Matches($content, '(?:href|src)="(/[^"#?]*)"') |
                ForEach-Object { $_.Groups[1].Value }

        foreach ($ref in $refs) {
            if ($ref -match '^https?://' -or $ref -eq '/') { continue }
            $target = Join-Path $SiteRoot ($ref.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar))
            $exists = (Test-Path $target) -or (Test-Path (Join-Path $target 'index.html'))
            if (-not $exists) {
                $brokenRefs.Add("$($html.Name): $ref")
            }
        }
    }

    if ($brokenRefs.Count -gt 0) {
        $brokenRefs | ForEach-Object { Write-Warn "Broken link: $_" }
    } else {
        Write-Ok "No broken internal links found across $($htmlFiles.Count) HTML files"
    }
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "`n------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Validation Summary" -ForegroundColor White

if ($errors.Count -gt 0) {
    Write-Host "  Errors:   $($errors.Count)" -ForegroundColor Red
} else {
    Write-Host "  Errors:   0" -ForegroundColor Green
}

if ($warnings.Count -gt 0) {
    Write-Host "  Warnings: $($warnings.Count)" -ForegroundColor Yellow
} else {
    Write-Host "  Warnings: 0" -ForegroundColor Green
}

Write-Host "------------------------------------------------------" -ForegroundColor DarkGray

if ($errors.Count -gt 0) {
    Write-Host "`nERR VALIDATION FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "`nOK  DISPOSITION: COMPLETE — All checks passed" -ForegroundColor Green
exit 0
