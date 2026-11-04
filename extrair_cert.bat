@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "OPENSSL=%SCRIPT_DIR%openssl\bin\openssl.exe"

if not exist "%OPENSSL%" (
    echo [ERRO] Binario do OpenSSL nao encontrado em:
    echo "%OPENSSL%"
    echo.
    echo Certifique-se de que a pasta "openssl\bin" esta junto deste script.
    echo.
    pause
    exit /b 1
)

if "%~1"=="" (
    echo [ERRO] Arraste e solte o arquivo .pfx sobre este script.
    echo.
    pause
    exit /b 1
)

set "PFX_PATH=%~f1"
set "DIR_PATH=%~dp1"
set "FILE_NAME=%~n1"

echo ======================================================
echo OpenSSL: %OPENSSL%
echo Processando: %PFX_PATH%
echo ======================================================

set /p "PASSWORD=Digite a senha do certificado: "

echo.
echo Extraindo Certificado (.crt)...
"%OPENSSL%" pkcs12 -in "%PFX_PATH%" -clcerts -nokeys -out "%DIR_PATH%%FILE_NAME%.crt" -passin "pass:%PASSWORD%" -legacy
if errorlevel 1 goto erro

echo Extraindo Chave Privada sem senha (.key)...
"%OPENSSL%" pkcs12 -in "%PFX_PATH%" -nocerts -nodes -out "%DIR_PATH%%FILE_NAME%.key" -passin "pass:%PASSWORD%" -legacy
if errorlevel 1 goto erro

echo.
echo [SUCESSO] Arquivos gerados com sucesso em %DIR_PATH%:
echo  - %FILE_NAME%.crt
echo  - %FILE_NAME%.key
echo.
pause
exit /b 0

:erro
echo.
echo [ERRO] Falha ao extrair os arquivos. Verifique a senha digitada ou a integridade do certificado.
echo.
pause
exit /b 1