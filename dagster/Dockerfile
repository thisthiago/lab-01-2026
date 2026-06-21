FROM python:3.11-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Diretório de trabalho
WORKDIR /opt/dagster/app

# Copiar requirements e instalar
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código da aplicação
COPY . .

# Variável de ambiente do Dagster Home
ENV DAGSTER_HOME=/opt/dagster/dagster_home

# Criar diretório dagster home
RUN mkdir -p $DAGSTER_HOME

# Copiar configuração do dagster
COPY dagster.yaml $DAGSTER_HOME/dagster.yaml
