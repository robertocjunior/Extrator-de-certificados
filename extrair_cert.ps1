param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$PfxPath
)

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

$OpenSslPath = Join-Path $ScriptDir "openssl\bin\openssl.exe"

if (-not (Test-Path $OpenSslPath)) {
    Write-Host "[ERRO] Executavel do OpenSSL nao encontrado em:`n$OpenSslPath" -ForegroundColor Red
    Write-Host "Certifique-se de que a pasta 'openssl\bin' esta localizada na mesma pasta deste script.`n" -ForegroundColor Yellow
    Pause
    exit 1
}

if (-not $PfxPath) {
    $PfxPath = Read-Host "Arraste o arquivo .pfx para ca e pressione Enter"
    $PfxPath = $PfxPath.Trim('"').Trim("'")
}

if (-not (Test-Path $PfxPath)) {
    Write-Host "[ERRO] Arquivo informado nao existe: $PfxPath" -ForegroundColor Red
    Pause
    exit 1
}

$pfxItem   = Get-Item $PfxPath
$parentDir = $pfxItem.DirectoryName
$baseName  = $pfxItem.BaseName

$crtOut = Join-Path $parentDir "$baseName.crt"
$keyOut = Join-Path $parentDir "$baseName.key"

Write-Host "`nProcessando: $($pfxItem.FullName)" -ForegroundColor Cyan
$securePass = Read-Host "Digite a senha do certificado" -AsSecureString
$password   = [System.Net.NetworkCredential]::new('', $securePass).Password

Write-Host "`nExtraindo Certificado (.crt)..." -ForegroundColor Yellow
& $OpenSslPath pkcs12 -in $pfxItem.FullName -clcerts -nokeys -out $crtOut -passin "pass:$password" -legacy

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha ao extrair o certificado. Verifique a senha informada." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "Extraindo Chave Privada sem senha (.key)..." -ForegroundColor Yellow
& $OpenSslPath pkcs12 -in $pfxItem.FullName -nocerts -nodes -out $keyOut -passin "pass:$password" -legacy

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha ao extrair a chave privada." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "`n[SUCESSO] Arquivos gerados com sucesso:" -ForegroundColor Green
Write-Host " - $crtOut"
Write-Host " - $keyOut`n"
Pause