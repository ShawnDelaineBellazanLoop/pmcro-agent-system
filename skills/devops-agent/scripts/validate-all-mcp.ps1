# Validate all Colony MCP servers simultaneously
# Run before any multi-agent workflow to confirm full infrastructure health
$servers = @(
    @{ name = "playwright-mcp";  port = $env:PLAYWRIGHT_MCP_PORT  ?? "8931" },
    @{ name = "filesystem-mcp";  port = $env:FILESYSTEM_MCP_PORT  ?? "7095" },
    @{ name = "terminal-mcp";    port = $env:TERMINAL_MCP_PORT    ?? "7032" }
)

$allPass = $true
foreach ($s in $servers) {
    $url = "http://localhost:$($s.port)/health"
    try {
        $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
        if ($r.StatusCode -eq 200) {
            Write-Host "[PASS] $($s.name) on port $($s.port)" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] $($s.name) — status $($r.StatusCode)" -ForegroundColor Red
            $allPass = $false
        }
    } catch {
        Write-Host "[FAIL] $($s.name) on port $($s.port) — $_" -ForegroundColor Red
        $allPass = $false
    }
}

if (-not $allPass) {
    Write-Host "`n[COLONY] MCP infrastructure incomplete — HIL_ESCALATE before proceeding" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n[COLONY] All MCP servers healthy" -ForegroundColor Green
    exit 0
}
