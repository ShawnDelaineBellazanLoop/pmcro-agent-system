# Validate Playwright MCP Connection
# Run before any playwright-agent workflow to confirm MCP server is reachable
$port = $env:PLAYWRIGHT_MCP_PORT ?? "8931"
$url  = "http://localhost:$port/health"
try {
    $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
    if ($r.StatusCode -eq 200) {
        Write-Host "[PASS] Playwright MCP reachable on port $port" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Unexpected status: $($r.StatusCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[FAIL] Playwright MCP not reachable on port $port — $_" -ForegroundColor Red
    exit 1
}
