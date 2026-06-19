# Verify .NET SDK matches global.json pin
# Run as Cycle 0 of every build workflow (DEVOPS-002)
param(
    [string]$SolutionRoot = $env:SOLUTION_ROOT ?? "S:\"
)

$globalJsonPath = Join-Path $SolutionRoot "global.json"
if (-not (Test-Path $globalJsonPath)) {
    Write-Host "[WARN] global.json not found at $globalJsonPath — skipping SDK pin check" -ForegroundColor Yellow
    exit 0
}

$globalJson    = Get-Content $globalJsonPath | ConvertFrom-Json
$pinnedVersion = $globalJson.sdk.version
$installedVersion = (dotnet --version).Trim()

if ($installedVersion -ne $pinnedVersion) {
    Write-Host "[FAIL] SDK mismatch — global.json pins $pinnedVersion but installed is $installedVersion" -ForegroundColor Red
    Write-Host "Action: HIL_ESCALATE — install correct SDK or update global.json" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "[PASS] SDK $installedVersion matches global.json pin" -ForegroundColor Green
    exit 0
}
