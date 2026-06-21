// =============================================================
// MongoDB Seed Script — Dados de exemplo para o pipeline
// =============================================================
// Este script é executado automaticamente pelo container MongoDB
// na primeira inicialização via /docker-entrypoint-initdb.d/

// Autenticar como admin
db = db.getSiblingDB('admin');
db.auth('mongo_user', 'mongo_password123');

// Mudar para o banco source_db
db = db.getSiblingDB('source_db');

// ----------------------------------------------------------
// Coleção: orders (Pedidos)
// ----------------------------------------------------------
db.createCollection('orders');

db.orders.insertMany([
  {
    _id: ObjectId(),
    order_id: "ORD-001",
    customer_id: "CUST-101",
    customer_name: "João Silva",
    customer_email: "joao.silva@example.com",
    status: "completed",
    total_amount: 299.90,
    currency: "BRL",
    items: [
      { product_id: "PROD-01", name: "Notebook Stand", qty: 1, price: 149.90 },
      { product_id: "PROD-02", name: "Mouse Pad XL",   qty: 2, price: 75.00  }
    ],
    shipping_address: {
      street: "Rua das Flores, 123",
      city: "São Paulo",
      state: "SP",
      zip: "01310-100"
    },
    created_at: new Date("2024-01-15T09:30:00Z"),
    updated_at: new Date("2024-01-15T14:22:00Z")
  },
  {
    _id: ObjectId(),
    order_id: "ORD-002",
    customer_id: "CUST-102",
    customer_name: "Maria Oliveira",
    customer_email: "maria.oliveira@example.com",
    status: "processing",
    total_amount: 1250.00,
    currency: "BRL",
    items: [
      { product_id: "PROD-03", name: "Teclado Mecânico", qty: 1, price: 750.00  },
      { product_id: "PROD-04", name: "Webcam HD",         qty: 1, price: 500.00  }
    ],
    shipping_address: {
      street: "Av. Paulista, 1000",
      city: "São Paulo",
      state: "SP",
      zip: "01310-200"
    },
    created_at: new Date("2024-01-16T11:00:00Z"),
    updated_at: new Date("2024-01-16T11:00:00Z")
  },
  {
    _id: ObjectId(),
    order_id: "ORD-003",
    customer_id: "CUST-103",
    customer_name: "Carlos Santos",
    customer_email: "carlos.santos@example.com",
    status: "cancelled",
    total_amount: 89.90,
    currency: "BRL",
    items: [
      { product_id: "PROD-05", name: "Cabo USB-C", qty: 3, price: 29.97 }
    ],
    shipping_address: {
      street: "Rua Consolação, 500",
      city: "São Paulo",
      state: "SP",
      zip: "01302-000"
    },
    created_at: new Date("2024-01-17T08:15:00Z"),
    updated_at: new Date("2024-01-17T10:30:00Z")
  },
  {
    _id: ObjectId(),
    order_id: "ORD-004",
    customer_id: "CUST-104",
    customer_name: "Ana Lima",
    customer_email: "ana.lima@example.com",
    status: "completed",
    total_amount: 3490.00,
    currency: "BRL",
    items: [
      { product_id: "PROD-06", name: "Monitor 27\"", qty: 1, price: 2500.00 },
      { product_id: "PROD-07", name: "Suporte Monitor", qty: 1, price: 990.00 }
    ],
    shipping_address: {
      street: "Rua Oscar Freire, 200",
      city: "São Paulo",
      state: "SP",
      zip: "01426-001"
    },
    created_at: new Date("2024-01-18T14:00:00Z"),
    updated_at: new Date("2024-01-19T09:45:00Z")
  },
  {
    _id: ObjectId(),
    order_id: "ORD-005",
    customer_id: "CUST-101",
    customer_name: "João Silva",
    customer_email: "joao.silva@example.com",
    status: "completed",
    total_amount: 450.00,
    currency: "BRL",
    items: [
      { product_id: "PROD-08", name: "Headset Gamer", qty: 1, price: 450.00 }
    ],
    shipping_address: {
      street: "Rua das Flores, 123",
      city: "São Paulo",
      state: "SP",
      zip: "01310-100"
    },
    created_at: new Date("2024-01-20T16:20:00Z"),
    updated_at: new Date("2024-01-21T08:00:00Z")
  }
]);

// ----------------------------------------------------------
// Coleção: customers (Clientes)
// ----------------------------------------------------------
db.createCollection('customers');

db.customers.insertMany([
  {
    _id: ObjectId(),
    customer_id: "CUST-101",
    name: "João Silva",
    email: "joao.silva@example.com",
    phone: "+55 11 99999-1111",
    segment: "premium",
    created_at: new Date("2023-06-01T00:00:00Z")
  },
  {
    _id: ObjectId(),
    customer_id: "CUST-102",
    name: "Maria Oliveira",
    email: "maria.oliveira@example.com",
    phone: "+55 11 99999-2222",
    segment: "standard",
    created_at: new Date("2023-08-15T00:00:00Z")
  },
  {
    _id: ObjectId(),
    customer_id: "CUST-103",
    name: "Carlos Santos",
    email: "carlos.santos@example.com",
    phone: "+55 11 99999-3333",
    segment: "standard",
    created_at: new Date("2023-10-20T00:00:00Z")
  },
  {
    _id: ObjectId(),
    customer_id: "CUST-104",
    name: "Ana Lima",
    email: "ana.lima@example.com",
    phone: "+55 11 99999-4444",
    segment: "premium",
    created_at: new Date("2023-11-05T00:00:00Z")
  }
]);

print("✅ MongoDB seed concluído: " + db.orders.countDocuments() + " pedidos e " + db.customers.countDocuments() + " clientes inseridos.");
