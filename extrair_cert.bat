@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"

:: 1. Localiza o executavel do OpenSSL (pasta openssl\bin, openssl\ ou no PATH do sistema)
set "OPENSSL="
if exist "%SCRIPT_DIR%openssl\bin\openssl.exe" (
    set "OPENSSL=%SCRIPT_DIR%openssl\bin\openssl.exe"
) else if exist "%SCRIPT_DIR%openssl\openssl.exe" (
    set "OPENSSL=%SCRIPT_DIR%openssl\openssl.exe"
) else (
    where openssl.exe >nul 2>nul
    if !errorlevel! equ 0 set "OPENSSL=openssl.exe"
)

if "%OPENSSL%"=="" (
    echo ======================================================
    echo [ERRO] Binario do OpenSSL nao encontrado!
    echo ======================================================
    echo Certifique-se de que a pasta "openssl\bin" esta junto deste script,
    echo ou que o OpenSSL esta instalado no PATH do Windows.
    echo.
    pause
    exit /b 1
)

:: 2. Identifica o arquivo .pfx (via parametro arrastado ou solicitando ao usuario)
set "PFX_INPUT=%~1"
if "%PFX_INPUT%"=="" (
    echo ======================================================
    echo       EXTRATOR DE CERTIFICADOS (.PFX para .CRT / .KEY)
    echo ======================================================
    echo.
    set /p "PFX_INPUT=Arraste o arquivo .pfx para ca e pressione ENTER: "
    echo.
)

:: Remove possiveis aspas extras
set "PFX_INPUT=!PFX_INPUT:"=!"

if "!PFX_INPUT!"=="" (
    echo [ERRO] Nenhum arquivo foi informado.
    pause
    exit /b 1
)

if not exist "!PFX_INPUT!" (
    echo [ERRO] Arquivo informado nao encontrado: "!PFX_INPUT!"
    echo.
    pause
    exit /b 1
)

for %%F in ("!PFX_INPUT!") do (
    set "PFX_PATH=%%~fF"
    set "DIR_PATH=%%~dpF"
    set "FILE_NAME=%%~nF"
)

echo ======================================================
echo OpenSSL: %OPENSSL%
echo Processando: !PFX_PATH!
echo ======================================================
echo.

set /p "PASSWORD=Digite a senha do certificado: "

echo.
echo Extraindo Certificado (.crt)...
"%OPENSSL%" pkcs12 -in "!PFX_PATH!" -clcerts -nokeys -out "!DIR_PATH!!FILE_NAME!.crt" -passin "pass:!PASSWORD!" -legacy
if errorlevel 1 goto erro

echo Extraindo Chave Privada sem senha (.key)...
"%OPENSSL%" pkcs12 -in "!PFX_PATH!" -nocerts -nodes -out "!DIR_PATH!!FILE_NAME!.key" -passin "pass:!PASSWORD!" -legacy
if errorlevel 1 goto erro

echo.
echo ======================================================
echo [SUCESSO] Arquivos gerados com sucesso em:
echo  !DIR_PATH!
echo.
echo  - !FILE_NAME!.crt
echo  - !FILE_NAME!.key
echo ======================================================
echo.
pause
exit /b 0

:erro
echo.
echo ======================================================
echo [ERRO] Falha ao extrair os arquivos.
echo Verifique se a senha esta correta ou a integridade do certificado.
echo ======================================================
echo.
pause
exit /b 1
