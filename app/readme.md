# Gerador de Dados Aleatórios para MongoDB

Este script insere documentos aleatórios nas coleções `customers` e `orders` do banco `source_db`, seguindo exatamente a estrutura do seed de inicialização (`init.js`).

## Pré-requisitos

- Docker (para executar o container Python na mesma rede do MongoDB)
- Ambiente Docker em execução (MongoDB e rede `data_engineering_network` já criados via `docker compose up -d`)

## Execução (modo recomendado)

O script é executado dentro de um container Python temporário, montando o diretório `app`.  
Todos os parâmetros são passados diretamente no comando:

```bash
docker run -it --rm `
  --network data_engineering_network `
  -v "${PWD}\app:/app" `
  -w /app `
  python:3.12-slim bash -c "pip install -q pymongo faker && python gerar_dados.py --clientes 5 --pedidos 10 --usar-faker"
```

### Explicação dos parâmetros do Docker:
- `--network data_engineering_network`: conecta o container à mesma rede do MongoDB.
- `-v "${PWD}\app:/app"`: monta a pasta `app` do host no container.
- `-w /app`: define o diretório de trabalho como `/app`.
- `bash -c "..."`: executa instalação das dependências e o script.

### Personalizando os dados gerados

Altere os argumentos `--clientes` e `--pedidos` conforme necessário:

```bash
# Gerar 20 clientes e 50 pedidos com Faker
docker run -it --rm `
  --network data_engineering_network `
  -v "${PWD}\app:/app" `
  -w /app `
  python:3.12-slim bash -c "pip install -q pymongo faker && python gerar_dados.py --clientes 20 --pedidos 50 --usar-faker"
```

Para desativar o Faker (dados pseudoaleatórios simples), remova a flag `--usar-faker`:

```bash
docker run -it --rm `
  --network data_engineering_network `
  -v "${PWD}\app:/app" `
  -w /app `
  python:3.12-slim bash -c "pip install -q pymongo faker && python gerar_dados.py --clientes 10 --pedidos 30"
```

## Configuração da conexão (automática)

O script já está configurado para conectar via TLS ignorando certificados autoassinados.  
A URI de conexão padrão é:

```
mongodb://mongodb:27017/
```

Esse endereço funciona **apenas dentro da rede Docker** `data_engineering_network`.  
Se precisar executar o script fora do Docker (não recomendado), altere a variável `MONGO_URI` no arquivo `app/gerar_dados.py`.

## Exemplo de saída

```
Conectando ao MongoDB...
Inserindo 5 clientes...
  Cliente: Pedro Costa (CUST-204)
  Cliente: Juliana Alves (CUST-372)
  ...
Inserindo 10 pedidos...
  Pedido: ORD-120 (completed) - R$ 1345.70
  Pedido: ORD-453 (processing) - R$ 89.90
  ...
Concluído!

