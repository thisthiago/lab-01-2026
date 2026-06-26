#!/bin/bash
set -e

echo "🚀 Iniciando configuração do ambiente..."

mkdir -p certs

echo "🔐 Gerando certificado SSL e Keyfile para o MongoDB..."
docker run --rm -v "$(pwd)/certs:/certs" alpine sh -c "apk add --no-cache openssl >/dev/null 2>&1 && openssl req -x509 -newkey rsa:4096 -keyout /certs/mongodb.key -out /certs/mongodb.crt -days 3650 -nodes -subj '/CN=mongodb' && cat /certs/mongodb.key /certs/mongodb.crt > /certs/mongodb.pem && openssl rand -base64 756 > /certs/mongo-keyfile"

echo "🔧 Aplicando patch no conector MongoDB do Airbyte..."
docker build -t airbyte/source-mongodb-v2:1.0.3 -f Dockerfile.mongo-connector .

echo "🐳 Subindo os containers..."
docker compose up -d

echo "⏳ Aguardando o MongoDB iniciar para configurar o Replica Set..."
sleep 10
docker exec mongodb mongosh --tls --tlsAllowInvalidCertificates -u mongo_user -p mongo_password123 --authenticationDatabase admin --eval "try { rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'mongodb:27017'}]}) } catch(e) { print('Replica set ja iniciado ou erro: ' + e) }"

echo "✅ Ambiente pronto! O Airbyte pode demorar alguns minutos para inicializar completamente."
