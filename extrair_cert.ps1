param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$PfxPath
)

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# 1. Localiza o OpenSSL (pasta openssl\bin, openssl\ ou no PATH do Windows)
$OpenSslPath = $null
$candidates = @(
    (Join-Path $ScriptDir "openssl\bin\openssl.exe"),
    (Join-Path $ScriptDir "openssl\openssl.exe")
)

foreach ($c in $candidates) {
    if (Test-Path $c) {
        $OpenSslPath = $c
        break
    }
}

if (-not $OpenSslPath) {
    $systemOpenSsl = Get-Command openssl -ErrorAction SilentlyContinue
    if ($systemOpenSsl) {
        $OpenSslPath = $systemOpenSsl.Source
    }
}

if (-not $OpenSslPath) {
    Write-Host "[ERRO] Executavel do OpenSSL nao encontrado!" -ForegroundColor Red
    Write-Host "Certifique-se de que a pasta 'openssl\bin' esta localizada na mesma pasta deste script ou configurada no PATH.`n" -ForegroundColor Yellow
    Pause
    exit 1
}

# 2. Obtem o arquivo .pfx caso nao tenha sido passado via parametro
if (-not $PfxPath) {
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "      EXTRATOR DE CERTIFICADOS (.PFX para .CRT / .KEY)" -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor Cyan
    $PfxPath = Read-Host "Arraste o arquivo .pfx para ca e pressione Enter"
}

$PfxPath = $PfxPath.Trim('"').Trim("'")

if (-not $PfxPath -or -not (Test-Path $PfxPath)) {
    Write-Host "`n[ERRO] Arquivo informado nao existe ou e invalido: '$PfxPath'" -ForegroundColor Red
    Pause
    exit 1
}

$pfxItem   = Get-Item $PfxPath
$parentDir = $pfxItem.DirectoryName
$baseName  = $pfxItem.BaseName

$crtOut = Join-Path $parentDir "$baseName.crt"
$keyOut = Join-Path $parentDir "$baseName.key"

Write-Host "`nProcessando: $($pfxItem.FullName)" -ForegroundColor Cyan
Write-Host "OpenSSL:     $OpenSslPath" -ForegroundColor DarkGray
$securePass = Read-Host "Digite a senha do certificado" -AsSecureString
$password   = [System.Net.NetworkCredential]::new('', $securePass).Password

Write-Host "`n[1/2] Extraindo Certificado (.crt)..." -ForegroundColor Yellow
& $OpenSslPath pkcs12 -in $pfxItem.FullName -clcerts -nokeys -out $crtOut -passin "pass:$password" -legacy

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERRO] Falha ao extrair o certificado. Verifique a senha informada ou integridade do arquivo." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "[2/2] Extraindo Chave Privada sem senha (.key)..." -ForegroundColor Yellow
& $OpenSslPath pkcs12 -in $pfxItem.FullName -nocerts -nodes -out $keyOut -passin "pass:$password" -legacy

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERRO] Falha ao extrair a chave privada." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "[SUCESSO] Arquivos gerados com sucesso!" -ForegroundColor Green
Write-Host "Pasta de destino: $parentDir" -ForegroundColor Green
Write-Host " - $(Split-Path $crtOut -Leaf)" -ForegroundColor Green
Write-Host " - $(Split-Path $keyOut -Leaf)" -ForegroundColor Green
Write-Host "======================================================`n" -ForegroundColor Green
Pause
