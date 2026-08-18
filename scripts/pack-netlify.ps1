# 打包 Netlify 手動拖放部署包（與 LON 相同方式）
# 用法：powershell -ExecutionPolicy Bypass -File scripts/pack-netlify.ps1
#
# 複製網站檔案與 data/ 內所有素材（排除備份、舊版檔），含 IG6.mp4。

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$deploy = Join-Path $root 'netlify-deploy'
$zip = Join-Path $root 'ai-pt-netlify-deploy.zip'

if (Test-Path $deploy) { Remove-Item $deploy -Recurse -Force }
New-Item -ItemType Directory -Path (Join-Path $deploy 'data') | Out-Null

$files = @(
    'index.html',
    'script.js',
    'styles.css',
    'translations.js',
    'netlify.toml'
)

foreach ($f in $files) {
    $src = Join-Path $root $f
    if (Test-Path $src) {
        Copy-Item $src $deploy -Force
    }
}

$dataSrc = Join-Path $root 'data'
$dataDst = Join-Path $deploy 'data'
$excludePattern = '(backup|old|複製)'
Get-ChildItem $dataSrc -File | Where-Object { $_.Name -notmatch $excludePattern } | ForEach-Object {
    Copy-Item $_.FullName $dataDst -Force
}

if (Test-Path $zip) { Remove-Item $zip -Force }
Push-Location $deploy
Compress-Archive -Path * -DestinationPath $zip -Force
Pop-Location

$count = (Get-ChildItem $deploy -Recurse -File | Measure-Object).Count
$dataCount = (Get-ChildItem $dataDst -File | Measure-Object).Count
$size = (Get-Item $zip).Length
$mb = [math]::Round($size / 1MB, 2)
Write-Host "Done."
Write-Host "Folder: $deploy ($count files, data=$dataCount)"
Write-Host "Zip:    $zip ($mb MB)"
Write-Host ''
Write-Host 'Deploy: open https://app.netlify.com/drop and drag netlify-deploy (or the zip)'
