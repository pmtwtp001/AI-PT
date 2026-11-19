# 檢查 Netlify 線上站是否含圖片（部署後必跑）
$Base = 'https://lambent-pothos-ddb830.netlify.app'
$Files = @(
    '/',
    '/data/top.png',
    '/data/top1.png',
    '/data/top10.png',
    '/data/top12.png',
    '/data/top13.png',
    '/data/top14.png',
    '/styles.css',
    '/script.js'
)
$bad = 0
Write-Host "Checking $Base ..." -ForegroundColor Cyan
foreach ($p in $Files) {
    $url = $Base + $p
  try {
    $r = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 20
    $ct = $r.Headers['Content-Type']
    if ($p -like '/data/*' -and $ct -notmatch 'image|video') {
      Write-Host "FAIL $p -> $ct (expected image/video, got HTML?)" -ForegroundColor Red
      $bad++
    } else {
      Write-Host "OK   $p -> $($r.StatusCode) $ct" -ForegroundColor Green
    }
  } catch {
    Write-Host "FAIL $p -> $($_.Exception.Message)" -ForegroundColor Red
    $bad++
  }
}
if ($bad -gt 0) {
  Write-Host "`n部署有問題：請重新拖放 netlify-deploy 整個資料夾（須含 data 子目錄）" -ForegroundColor Yellow
  exit 1
}
Write-Host "`n線上站正常。" -ForegroundColor Green