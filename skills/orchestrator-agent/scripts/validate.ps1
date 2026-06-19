# validate.ps1 — Orchestrator Agent Skill Integrity Check
# Colony: {{colony_name}} · MAF 1.10.0 · Schema 2.0
# ============================================================
# Run this script to verify the orchestrator-agent skill package
# is complete and schema 2.0 compliant.
# Usage: .\validate.ps1 [-WhatIf] [-Fix]
# ============================================================

param(
    [switch]$WhatIf,
    [switch]$Fix
)

$skillRoot = "S:\skills\orchestrator-agent"
$errors    = @()
$warnings  = @()

Write-Host "`n🔍 PMCR-O Skill Validator — orchestrator-agent" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ── Required files ───────────────────────────────────────────
$requiredFiles = @(
    "SKILL.md",
    "domain_config.json",
    "prompts\prompt_index.json",
    "prompts\system.prompt.md",
    "prompts\developer.prompt.md",
    "prompts\user.prompt.md",
    "prompts\o-mode-optimize.prompt.md",
    "prompts\o-mode-output.prompt.md",
    "prompts\o-mode-orchestrate.prompt.md",
    "prompts\o-mode-topology.prompt.md",
    "references\versions.md",
    "references\patterns.md",
    "evals\smoke_test.md"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $skillRoot $file
    if (-not (Test-Path $fullPath)) {
        $errors += "MISSING: $file"
        Write-Host "  ❌ MISSING: $file" -ForegroundColor Red
    } else {
        Write-Host "  ✅ EXISTS:  $file" -ForegroundColor Green
    }
}

# ── Required directories ─────────────────────────────────────
$requiredDirs = @("prompts", "references", "scripts", "evals", "assets", "logs", "meta")

foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $skillRoot $dir
    if (-not (Test-Path $fullPath)) {
        if ($Fix -and -not $WhatIf) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            Write-Host "  🔧 CREATED: $dir\" -ForegroundColor Yellow
        } else {
            $warnings += "MISSING DIR: $dir"
            Write-Host "  ⚠️  MISSING DIR: $dir (use -Fix to create)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✅ DIR:     $dir\" -ForegroundColor Green
    }
}

# ── Schema 2.0 check on SKILL.md ─────────────────────────────
$skillMd = Join-Path $skillRoot "SKILL.md"
if (Test-Path $skillMd) {
    $content = Get-Content $skillMd -Raw
    if ($content -notmatch 'schema_version:\s*"2\.0"') {
        $errors += "SKILL.md does not declare schema_version: '2.0'"
        Write-Host "  ❌ SCHEMA:  SKILL.md missing schema_version: '2.0'" -ForegroundColor Red
    } else {
        Write-Host "  ✅ SCHEMA:  schema_version: '2.0' confirmed" -ForegroundColor Green
    }
    if ($content -match '\{\{company\}\}|\{\{colony_name\}\}') {
        $warnings += "SKILL.md contains unreplaced {{tokens}} — expected in template mode"
        Write-Host "  ⚠️  TOKENS:  Unreplaced {{tokens}} detected (OK if template)" -ForegroundColor Yellow
    }
}

# ── Summary ──────────────────────────────────────────────────
Write-Host "`n── Summary ──────────────────────────────────────" -ForegroundColor Cyan
if ($errors.Count -eq 0) {
    Write-Host "  ✅ PASS — $($requiredFiles.Count) required files verified" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL — $($errors.Count) error(s) found:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "     • $_" -ForegroundColor Red }
}
if ($warnings.Count -gt 0) {
    Write-Host "  ⚠️  $($warnings.Count) warning(s):" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "     • $_" -ForegroundColor Yellow }
}

if ($WhatIf) { Write-Host "`n  [WhatIf mode — no changes made]" -ForegroundColor Gray }
