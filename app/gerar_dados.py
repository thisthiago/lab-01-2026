import random
import string
import datetime
import argparse
from pymongo import MongoClient

# ============================================================
# Configuração de conexão
# ============================================================
MONGO_URI = "mongodb://mongodb:27017/"
USERNAME = "mongo_user"
PASSWORD = "mongo_password123"
AUTH_SOURCE = "admin"
DATABASE = "source_db"

# ============================================================
# Dados base para geração aleatória
# ============================================================
SEGMENTOS = ["premium", "standard"]
STATUS_PEDIDO = ["completed", "processing", "cancelled"]
MOEDA = "BRL"
ESTADOS = ["SP"]  # Poderia expandir, mas mantendo o exemplo focado em SP

PRODUTOS = [
    ("PROD-01", "Notebook Stand"),
    ("PROD-02", "Mouse Pad XL"),
    ("PROD-03", "Teclado Mecânico"),
    ("PROD-04", "Webcam HD"),
    ("PROD-05", "Cabo USB-C"),
    ("PROD-06", 'Monitor 27"'),
    ("PROD-07", "Suporte Monitor"),
    ("PROD-08", "Headset Gamer"),
    ("PROD-09", "Hub USB 3.0"),
    ("PROD-10", "Cadeira Ergonômica"),
]

RUA_NOMES = [
    "Rua das Flores",
    "Av. Paulista",
    "Rua Consolação",
    "Rua Oscar Freire",
    "Av. Brigadeiro Faria Lima",
    "Rua Augusta",
    "Rua da Consolação",
    "Alameda Santos",
]
CIDADES = ["São Paulo"]

def gerar_cliente():
    """Gera um documento aleatório para a coleção customers."""
    nome = random.choice(["João Silva", "Maria Oliveira", "Carlos Santos", "Ana Lima",
                          "Pedro Costa", "Juliana Alves", "Fernanda Rocha", "Ricardo Nunes"])
    sobrenome = random.choice(["Silva", "Oliveira", "Santos", "Lima", "Costa", "Pereira", "Souza", "Rocha"])
    nome_completo = nome if random.random() < 0.5 else f"{nome} {sobrenome}"
    email_domain = random.choice(["example.com", "email.com", "webmail.com.br"])
    email = nome_completo.lower().replace(" ", ".") + "@" + email_domain
    customer_id = "CUST-" + str(random.randint(200, 999))
    segmento = random.choice(SEGMENTOS)
    created_at = datetime.datetime.now() - datetime.timedelta(days=random.randint(1, 365))
    return {
        "customer_id": customer_id,
        "name": nome_completo,
        "email": email,
        "phone": f"+55 11 9{random.randint(1000,9999)}-{random.randint(1000,9999)}",
        "segment": segmento,
        "created_at": created_at,
    }

def gerar_pedido(clientes_ids):
    """Gera um documento aleatório para a coleção orders, associado a um cliente existente."""
    if not clientes_ids:
        raise ValueError("É necessário ter pelo menos um cliente cadastrado.")
    cliente = random.choice(clientes_ids)  # Espera um dict com customer_id, name, email
    order_id = "ORD-" + str(random.randint(100, 999)).zfill(3)
    status = random.choice(STATUS_PEDIDO)

    # Gera de 1 a 3 itens
    num_itens = random.randint(1, 3)
    itens = []
    total = 0.0
    for _ in range(num_itens):
        prod = random.choice(PRODUTOS)
        qty = random.randint(1, 5)
        price = round(random.uniform(20.0, 1500.0), 2)
        total += qty * price
        itens.append({
            "product_id": prod[0],
            "name": prod[1],
            "qty": qty,
            "price": price
        })

    # Endereço de entrega
    rua = random.choice(RUA_NOMES)
    numero = random.randint(10, 2000)
    shipping = {
        "street": f"{rua}, {numero}",
        "city": random.choice(CIDADES),
        "state": "SP",
        "zip": f"{random.randint(1000,1999)}-{random.randint(100,999)}"
    }

    created_at = datetime.datetime.now() - datetime.timedelta(days=random.randint(1, 30))
    updated_at = created_at + datetime.timedelta(hours=random.randint(1, 72))

    return {
        "order_id": order_id,
        "customer_id": cliente["customer_id"],
        "customer_name": cliente["name"],
        "customer_email": cliente["email"],
        "status": status,
        "total_amount": round(total, 2),
        "currency": MOEDA,
        "items": itens,
        "shipping_address": shipping,
        "created_at": created_at,
        "updated_at": updated_at,
    }

def conectar_mongo():
    """Estabelece conexão com MongoDB via TLS (ignorando certificados autoassinados)."""
    client = MongoClient(
        MONGO_URI,
        username=USERNAME,
        password=PASSWORD,
        authSource=AUTH_SOURCE,
        tls=True,
        tlsAllowInvalidCertificates=True,
    )
    return client.get_database(DATABASE)

def main():
    parser = argparse.ArgumentParser(description="Gerador de dados aleatórios para MongoDB")
    parser.add_argument("--clientes", type=int, default=5, help="Quantidade de novos clientes a inserir")
    parser.add_argument("--pedidos", type=int, default=10, help="Quantidade de novos pedidos a inserir")
    parser.add_argument("--usar-faker", action="store_true", help="Usar biblioteca Faker para dados mais realistas")
    args = parser.parse_args()

    if args.usar_faker:
        try:
            from faker import Faker
            fake = Faker("pt_BR")
            # Sobrescreve as funções de geração com Faker
            global gerar_cliente, gerar_pedido
            def gerar_cliente_faker():
                nome = fake.name()
                email = fake.email()
                return {
                    "customer_id": f"CUST-{random.randint(200,999)}",
                    "name": nome,
                    "email": email,
                    "phone": fake.phone_number(),
                    "segment": random.choice(SEGMENTOS),
                    "created_at": fake.date_time_between(start_date="-1y", end_date="now"),
                }
            gerar_cliente = gerar_cliente_faker

            def gerar_pedido_faker(clientes_ids):
                cliente = random.choice(clientes_ids)
                order_id = f"ORD-{random.randint(100,999):03d}"
                status = random.choice(STATUS_PEDIDO)
                num_itens = random.randint(1, 3)
                itens = []
                total = 0.0
                for _ in range(num_itens):
                    prod = random.choice(PRODUTOS)
                    qty = random.randint(1, 5)
                    price = round(random.uniform(20, 1500), 2)
                    total += qty * price
                    itens.append({"product_id": prod[0], "name": prod[1], "qty": qty, "price": price})
                shipping = {
                    "street": fake.street_address(),
                    "city": fake.city(),
                    "state": random.choice(["SP", "RJ", "MG", "RS"]),
                    "zip": fake.postcode()
                }
                created_at = fake.date_time_between(start_date="-30d", end_date="now")
                updated_at = created_at + datetime.timedelta(hours=random.randint(1, 72))
                return {
                    "order_id": order_id,
                    "customer_id": cliente["customer_id"],
                    "customer_name": cliente["name"],
                    "customer_email": cliente["email"],
                    "status": status,
                    "total_amount": round(total, 2),
                    "currency": MOEDA,
                    "items": itens,
                    "shipping_address": shipping,
                    "created_at": created_at,
                    "updated_at": updated_at,
                }
            gerar_pedido = gerar_pedido_faker
        except ImportError:
            print("Faker não instalado. Execute 'pip install faker' e tente novamente.")
            return

    print("Conectando ao MongoDB...")
    db = conectar_mongo()
    print(f"Inserindo {args.clientes} clientes...")
    clientes_inseridos = []
    for _ in range(args.clientes):
        doc = gerar_cliente()
        resultado = db.customers.insert_one(doc)
        doc["_id"] = resultado.inserted_id
        clientes_inseridos.append(doc)
        print(f"  Cliente: {doc['name']} ({doc['customer_id']})")

    # Busca todos os clientes (inclusive os existentes) para associar aos pedidos
    todos_clientes = list(db.customers.find({}, {"customer_id": 1, "name": 1, "email": 1}))
    if not todos_clientes:
        print("Nenhum cliente encontrado. Não é possível gerar pedidos.")
        return

    print(f"Inserindo {args.pedidos} pedidos...")
    for _ in range(args.pedidos):
        doc = gerar_pedido(todos_clientes)
        db.orders.insert_one(doc)
        print(f"  Pedido: {doc['order_id']} ({doc['status']}) - R$ {doc['total_amount']:.2f}")

    print("Concluído!")

if __name__ == "__main__":
    main()