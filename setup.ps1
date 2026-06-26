$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando configuracao do ambiente..." -ForegroundColor Cyan

$certsDir = Join-Path $PWD "certs"
if (-not (Test-Path $certsDir)) {
    New-Item -ItemType Directory -Path $certsDir | Out-Null
}

Write-Host "🔐 Gerando certificado SSL e Keyfile para o MongoDB..." -ForegroundColor Yellow
$unixCertsPath = "/certs"
docker run --rm -v "$($certsDir):$unixCertsPath" alpine sh -c "apk add --no-cache openssl >/dev/null 2>&1 && openssl req -x509 -newkey rsa:4096 -keyout $unixCertsPath/mongodb.key -out $unixCertsPath/mongodb.crt -days 3650 -nodes -subj '/CN=mongodb' && cat $unixCertsPath/mongodb.key $unixCertsPath/mongodb.crt > $unixCertsPath/mongodb.pem && openssl rand -base64 756 > $unixCertsPath/mongo-keyfile"

Write-Host "🔧 Aplicando patch no conector MongoDB do Airbyte..." -ForegroundColor Yellow
docker build -t airbyte/source-mongodb-v2:1.0.3 -f Dockerfile.mongo-connector .

Write-Host "🐳 Subindo os containers..." -ForegroundColor Yellow
docker compose up -d

Write-Host "⏳ Aguardando o MongoDB iniciar para configurar o Replica Set..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker exec mongodb mongosh --tls --tlsAllowInvalidCertificates -u mongo_user -p mongo_password123 --authenticationDatabase admin --eval "try { rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'mongodb:27017'}]}) } catch(e) { print('Replica set ja iniciado ou erro: ' + e) }"

Write-Host "✅ Ambiente pronto! O Airbyte pode demorar alguns minutos para inicializar completamente." -ForegroundColor Green
