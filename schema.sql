-- PortoJus — Schema SQL para implantação
-- Gerado em 2026-05-04
-- Execute este script no seu banco PostgreSQL antes de subir a aplicação

CREATE TABLE IF NOT EXISTS "users" (
  "id"                 SERIAL PRIMARY KEY,
  "name"               TEXT NOT NULL,
  "email"              TEXT NOT NULL UNIQUE,
  "phone"              TEXT,
  "password_hash"      TEXT NOT NULL,
  "role"               TEXT NOT NULL DEFAULT 'viewer',
  "can_view_movements" BOOLEAN NOT NULL DEFAULT TRUE,
  "can_edit_movements" BOOLEAN NOT NULL DEFAULT FALSE,
  "created_at"         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "categories" (
  "id"         SERIAL PRIMARY KEY,
  "name"       TEXT NOT NULL,
  "type"       TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "partners" (
  "id"          SERIAL PRIMARY KEY,
  "name"        TEXT NOT NULL,
  "type"        TEXT NOT NULL,
  "document"    TEXT,
  "contact"     TEXT,
  "category_id" INTEGER REFERENCES "categories"("id"),
  "created_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "movements" (
  "id"          SERIAL PRIMARY KEY,
  "description" TEXT NOT NULL,
  "amount"      NUMERIC(15,2) NOT NULL,
  "type"        TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  "date"        DATE NOT NULL,
  "category_id" INTEGER REFERENCES "categories"("id"),
  "partner_id"  INTEGER REFERENCES "partners"("id"),
  "created_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Usuário administrador padrão
-- Senha: admin123  (hash SHA-256 com salt "portojus_salt")
INSERT INTO "users" ("name", "email", "password_hash", "role", "can_view_movements", "can_edit_movements")
VALUES (
  'Admin PortoJus',
  'admin@portojus.com.br',
  '04f406fc12548fcc66e60ee712c25ffd8f9da1919ca30318692ba6c19543e33c',
  'admin',
  TRUE,
  TRUE
)
ON CONFLICT ("email") DO NOTHING;

-- Hash gerado via: crypto.createHash('sha256').update('admin123portojus_salt').digest('hex')
-- Senha padrão: admin123  — troque imediatamente após a primeira entrada.
