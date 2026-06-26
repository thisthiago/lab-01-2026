$ErrorActionPreference = "Stop"

Write-Host "Iniciando configuracao do ambiente..." -ForegroundColor Cyan

# --- Cria diretório de certificados se não existir ---
$certsDir = Join-Path $PWD "certs"
if (-not (Test-Path $certsDir)) {
    New-Item -ItemType Directory -Path $certsDir | Out-Null
}

# --- Verifica se os certificados já existem ---
$certFiles = @("mongodb.key", "mongodb.crt", "mongodb.pem", "mongo-keyfile")
$todosExistem = $certFiles.ForEach({ Test-Path (Join-Path $certsDir $_) }) -notcontains $false

if ($todosExistem) {
    Write-Host "Certificados ja existem, pulando geracao..." -ForegroundColor Yellow
}
else {
    Write-Host "Gerando certificado SSL e Keyfile para o MongoDB..." -ForegroundColor Yellow

    # Cria script shell gerador dentro da pasta certs
    $shScript = Join-Path $certsDir "generate-certs.sh"
    @'
#!/bin/sh
apk add --no-cache openssl >/dev/null 2>&1
openssl req -x509 -newkey rsa:4096 -keyout /certs/mongodb.key -out /certs/mongodb.crt -days 3650 -nodes -subj "/CN=mongodb"
cat /certs/mongodb.key /certs/mongodb.crt > /certs/mongodb.pem
openssl rand -base64 756 > /certs/mongo-keyfile
'@ | Set-Content -Path $shScript -Encoding ASCII

    docker run --rm -v "${certsDir}:/certs" alpine sh /certs/generate-certs.sh
    Remove-Item $shScript
}

Write-Host "Aplicando patch no conector MongoDB do Airbyte..." -ForegroundColor Yellow
docker build -t airbyte/source-mongodb-v2:1.0.3 -f Dockerfile.mongo-connector .

Write-Host "Subindo os containers..." -ForegroundColor Yellow
docker compose up -d

Write-Host "Aguardando o MongoDB iniciar para configurar o Replica Set..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Comando eval separado para evitar problemas com aspas
$evalCmd = 'try { rs.initiate({_id: "rs0", members: [{_id: 0, host: "mongodb:27017"}]}) } catch(e) { print("Replica set ja iniciado ou erro: " + e) }'
docker exec mongodb mongosh --tls --tlsAllowInvalidCertificates -u mongo_user -p mongo_password123 --authenticationDatabase admin --eval $evalCmd

Write-Host "Ambiente pronto! O Airbyte pode demorar alguns minutos para inicializar completamente." -ForegroundColor Green