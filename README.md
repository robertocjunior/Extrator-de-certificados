# 🔐 Extrator de Certificados (.pfx ➔ .crt + .key)

[![GitHub Release](https://img.shields.io/github/v/release/robertocjunior/Extrator-de-certificados?color=blue&label=Vers%C3%A3o)](https://github.com/robertocjunior/Extrator-de-certificados/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Plataforma-Windows-informational?logo=windows)](https://github.com/robertocjunior/Extrator-de-certificados)
[![OpenSSL](https://img.shields.io/badge/OpenSSL-Portable%20Ready-orange?logo=openssl)](https://github.com/robertocjunior/Extrator-de-certificados)

Utilitário simples, rápido e portátil para Windows que extrai o **Certificado Público (`.crt`)** e a **Chave Privada sem senha (`.key`)** a partir de um arquivo **PKCS#12 (`.pfx` ou `.p12`)**.

Perfeito para configurar servidores web (Apache, Nginx, IIS), sistemas de emissão de NF-e/NFS-e, ERPs (Protheus, SAP), APIs e integrações que exigem os arquivos de chave e certificado desmembrados.

---

## ⚡ Por que este extrator?

1. **Pronto para Usar (Plug & Play):** Na versão distribuída em [Releases](https://github.com/robertocjunior/Extrator-de-certificados/releases), o pacote já acompanha o OpenSSL Portable. O usuário **não precisa** instalar nada, compilar ou configurar variáveis de ambiente (`PATH`).
2. **Compatível com Certificados ICP-Brasil / Legados:** O OpenSSL 3 desativou algoritmos criptográficos legados por padrão (como 3DES e RC2). Este script utiliza o provider `-legacy`, garantindo extração imediata de certificados digitais brasileiros (e-CNPJ, e-CPF, A1) sem falhas.
3. **100% Offline e Seguro:** Todo o processamento ocorre estritamente na sua máquina. A senha e as chaves privadas nunca são enviadas para a internet.
4. **Múltiplos modos de uso:** Funciona tanto por **Arrastar e Soltar (Drag & Drop)** quanto por **Duplo Clique** interativo.

---

## 🚀 Como Usar

### Opção 1: Download Rápido (Recomendado)
1. Acesse a aba [Releases](https://github.com/robertocjunior/Extrator-de-certificados/releases) e baixe o arquivo `Cert.zip`.
2. Extraia o arquivo `.zip` em qualquer pasta do seu computador.
3. Execute o extrator de uma das seguintes formas:

#### Modo A: Arrastar e Soltar (Drag & Drop)
* Arraste o seu arquivo `.pfx` e solte-o em cima de `extrair_cert.bat`.
* Digite a senha do certificado quando solicitado no terminal.
* Os arquivos `.crt` e `.key` serão gerados na **mesma pasta** do seu arquivo `.pfx`.

#### Modo B: Duplo Clique
* Dê dois cliques em `extrair_cert.bat` (ou execute `extrair_cert.ps1`).
* Uma janela abrirá pedindo para você arrastar o arquivo `.pfx` para a tela ou colar o caminho completo.
* Digite a senha e pressione Enter. Pronto!

---

## 📁 Estrutura da Pasta (Release)

Ao descompactar a versão portátil (`Cert.zip`), a estrutura será:

```text
Cert/
├── extrair_cert.bat         # Script Batch (compatível com qualquer Windows)
├── extrair_cert.ps1         # Script PowerShell (com mascaramento seguro de senha)
└── openssl/
    ├── bin/
    │   ├── openssl.exe      # Executável OpenSSL portátil (64-bit)
    │   ├── libcrypto-*.dll  # Biblioteca de criptografia
    │   └── libssl-*.dll     # Biblioteca SSL/TLS
    └── ...
```

> **Nota para Desenvolvedores:** Caso você clone o repositório diretamente via `git clone`, certifique-se de ter o OpenSSL instalado no seu sistema (`PATH`) ou adicione a pasta portátil `openssl/bin/` na raiz do projeto.

---

## ⚙️ O que é executado por baixo dos panos?

Os scripts executam dois comandos otimizados do OpenSSL:

1. **Extração do Certificado Público:**
   ```bash
   openssl pkcs12 -in "certificado.pfx" -clcerts -nokeys -out "certificado.crt" -passin "pass:SUA_SENHA" -legacy
   ```
2. **Extração da Chave Privada (sem senha / pronta para serviços):**
   ```bash
   openssl pkcs12 -in "certificado.pfx" -nocerts -nodes -out "certificado.key" -passin "pass:SUA_SENHA" -legacy
   ```

---

## ❓ Dúvidas Frequentes (FAQ)

### 1. Tem problema distribuir o OpenSSL junto no `.zip`?
**Não, nenhum problema!**  
O OpenSSL é software de código aberto licenciado sob a [Apache License 2.0](https://www.openssl.org/source/license.html). Essa licença permite explicitamente redistribuição comercial e não-comercial, inclusive de binários embutidos. Distribuir o OpenSSL portable em ferramentas para Windows é uma prática consagrada no mercado (utilizada por ferramentas como Git for Windows, cURL, XAMPP, entre outras), pois garante que o usuário final não precise passar pelo processo chato de instalar dependências de sistema.

### 2. O Windows SmartScreen ou Antivírus exibiu aviso ao executar. É seguro?
Sim, 100% seguro! Scripts `.bat` / `.ps1` e arquivos `.zip` recém-baixados da internet que não possuem assinatura digital comercial (certificado EV pago) podem gerar avisos preventivos do Windows SmartScreen:
* Para continuar, basta clicar em **"Mais informações"** ➔ **"Executar assim mesmo"**.
* O código-fonte dos scripts é totalmente aberto e transparente neste repositório.

### 3. Onde os arquivos extraídos são salvos?
Os arquivos `.crt` e `.key` são sempre salvos **no mesmo diretório onde o arquivo `.pfx` original está localizado**, mantendo o mesmo nome base do arquivo.

---

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE).

O OpenSSL distribuído junto ao pacote portátil é de propriedade do OpenSSL Software Foundation e regido pela [Apache License 2.0](https://www.openssl.org/source/license.html).
