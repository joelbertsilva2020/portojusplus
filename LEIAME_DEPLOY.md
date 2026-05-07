# PortoJus — Guia de Implantação via FTP

## Pré-requisitos
- Node.js 20+ no servidor
- PostgreSQL 14+
- Servidor web (Nginx/Apache) para servir os arquivos estáticos

---

## 1. Banco de Dados

Execute o script SQL no seu banco PostgreSQL:

```bash
psql -U seu_usuario -d seu_banco -f schema.sql
```

Credenciais padrão criadas:
- **Email:** admin@portojus.com.br
- **Senha:** admin123 ⚠️ Troque imediatamente após o primeiro acesso!

---

## 2. API Server (backend)

### Enviar via FTP
Copie a pasta `api-server/` para o servidor.

### Variáveis de ambiente obrigatórias
Crie um arquivo `.env` dentro de `api-server/`:

```env
DATABASE_URL=postgresql://usuario:senha@host:5432/nome_banco
SESSION_SECRET=coloque_uma_string_longa_e_aleatoria_aqui
PORT=3001
BASE_PATH=/api
NODE_ENV=production
```

### Iniciar o servidor
```bash
cd api-server
npm install --omit=dev   # ou: yarn install --production
node dist/index.mjs
```

Recomenda-se usar PM2 para manter o processo ativo:
```bash
npm install -g pm2
pm2 start dist/index.mjs --name portojus-api
pm2 save
```

---

## 3. Frontend (arquivos estáticos)

### Enviar via FTP
Copie o conteúdo de `frontend/` para a pasta pública do seu servidor web (ex: `/var/www/portojus/`).

### Nginx — configuração sugerida
```nginx
server {
    listen 80;
    server_name seu-dominio.com.br;

    root /var/www/portojus;
    index index.html;

    # Rotas da API — proxy para o backend
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }

    # Frontend — SPA (Single Page Application)
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 4. Estrutura do ZIP

```
portojus.zip
├── api-server/          # Backend Node.js (Express)
│   └── dist/            # Código compilado (pronto para produção)
├── frontend/            # Frontend React (arquivos estáticos)
│   ├── index.html
│   └── assets/
├── schema.sql           # Script de criação das tabelas PostgreSQL
└── LEIAME_DEPLOY.md     # Este arquivo
```

---

## 5. Permissões e Roles

O sistema possui dois níveis de acesso:

| Role | Descrição |
|------|-----------|
| **admin** | Acesso total — gere usuários, defina permissões, veja todas as movimentações |
| **viewer** | Acesso configurável — pode visualizar e/ou editar movimentações conforme permissões definidas |

Permissões configuráveis por usuário (independente do role):
- `can_view_movements` — permite ver a lista de movimentações
- `can_edit_movements` — permite criar, editar e excluir movimentações

---

## Suporte
Em caso de dúvidas, verifique os logs do servidor:
```bash
pm2 logs portojus-api
```
