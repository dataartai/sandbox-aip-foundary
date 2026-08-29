# ..\_shared\.env → .\.env 순으로 읽어 환경변수로 주입한 뒤 JupyterLab 을 띄웁니다.
# 같은 키가 양쪽에 있으면 실습 폴더의 .env 가 우선합니다.
#
# 사용법:  conda activate osdk-hello ;  .\run-jupyter.ps1

$ErrorActionPreference = "Stop"

function Import-DotEnv([string]$Path, [string]$Label) {
    if (-not (Test-Path $Path)) { Write-Host "skip: $Label (없음)" -ForegroundColor DarkGray; return }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { return }
        $idx = $line.IndexOf("=")
        if ($idx -lt 1) { return }
        $key = $line.Substring(0, $idx).Trim()
        $val = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($val -ne "") {
            Set-Item -Path "env:$key" -Value $val
            Write-Host "  $key  <- $Label" -ForegroundColor DarkGray
        }
    }
}

Import-DotEnv (Join-Path $PSScriptRoot "..\_shared\.env") "_shared"
Import-DotEnv (Join-Path $PSScriptRoot ".env")            "project"

if (-not $env:FOUNDRY_TOKEN) {
    Write-Host ""
    Write-Host "FOUNDRY_TOKEN 이 비어 있습니다." -ForegroundColor Red
    Write-Host "Developer Console > Start Developing 탭에서 토큰을 받아 .env 에 넣으세요." -ForegroundColor Yellow
    exit 1
}
if (-not $env:FOUNDRY_HOSTNAME) {
    Write-Host "FOUNDRY_HOSTNAME 이 비어 있습니다. ..\_shared\.env 를 확인하세요." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "hostname: $env:FOUNDRY_HOSTNAME" -ForegroundColor Green
Write-Host "token   : 주입 완료 ($($env:FOUNDRY_TOKEN.Length)자)" -ForegroundColor Green
Write-Host "JupyterLab 을 시작합니다..." -ForegroundColor Green
jupyter lab
