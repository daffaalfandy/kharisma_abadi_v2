# Docker Setup & Deployment Guide

**Complete guide for Docker containerization of Kharisma Abadi V2**

---

## Quick Start

### Development

```bash
# Option 1: Using Makefile
make dev

# Option 2: Using script
./scripts/docker-dev.sh

# Option 3: Direct Docker Compose
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

Access:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Database: localhost:3306

### Production

```bash
# Create production environment file
cp .env.example .env.production
# Edit .env.production with production values

# Start production environment
./scripts/docker-prod.sh

# Or manually
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## Docker Architecture

### Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| database | mariadb:11 | 3306 | Database |
| redis | redis:7-alpine | 6379 | Cache |
| backend | golang:1.21-alpine | 8000 | Go API |
| frontend | node:18-alpine | 3000 | Next.js app |
| nginx | nginx:alpine | 80/443 | Reverse proxy |

### Volumes

- `db-data` - MariaDB database files
- `redis-data` - Redis cache data
- `backend/uploads` - User uploaded files

### Networks

- `kharisma-network` - All services connected

---

## Configuration Files

### `docker-compose.yml`

Base configuration with all services, used with overrides:

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### `docker-compose.dev.yml`

Development overrides:
- Mounts source code for hot reload
- Exposes all ports for direct access
- Enables debug logging
- Uses development Dockerfiles

### `docker-compose.prod.yml`

Production overrides:
- Removes port exposure (behind nginx)
- Disables debug mode
- Implements logging rotation
- Security options enabled
- Always-on restart policy

### Dockerfiles

**Backend (Go/Fiber):**
- `backend/Dockerfile` - Production multi-stage build
- `backend/Dockerfile.dev` - Development with air (hot reload)

**Frontend (Next.js):**
- `frontend/Dockerfile` - Production multi-stage build
- `frontend/Dockerfile.dev` - Development with npm run dev

### Nginx

- `nginx/nginx.conf` - Main configuration
- `nginx/conf.d/default.conf` - Route configuration

---

## Environment Variables

### `.env` (Development)

```bash
# Database
DB_ROOT_PASSWORD=rootpassword
DB_DATABASE=kharisma_db
DB_USER=kharisma
DB_PASSWORD=password
DB_PORT=3306

# Redis
REDIS_PORT=6379

# Backend
JWT_SECRET=your-secret-key-here-min-32-chars
BACKEND_PORT=8000
LOG_LEVEL=debug

# Frontend
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1

# Environment
ENVIRONMENT=development
```

### `.env.production` (Production)

```bash
# Database (use strong passwords!)
DB_ROOT_PASSWORD=${STRONG_PASSWORD}
DB_DATABASE=kharisma_db
DB_USER=kharisma
DB_PASSWORD=${STRONG_PASSWORD}

# Backend
JWT_SECRET=${SECURE_JWT_KEY}
ENVIRONMENT=production
LOG_LEVEL=info

# Frontend
NEXT_PUBLIC_API_URL=https://api.kharisma.local/api/v1
```

---

## Common Commands

### View Status

```bash
# List running containers
docker-compose ps

# View logs from all services
docker-compose logs -f

# View logs from specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f database
```

### Execute Commands

```bash
# Open shell in backend
docker-compose exec backend /bin/sh

# Open shell in frontend
docker-compose exec frontend /bin/sh

# Run command in backend
docker-compose exec backend go test ./...

# Run MySQL CLI
docker-compose exec database mysql -u root -p
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend

# Rebuild and restart
docker-compose up -d --build backend
```

### Database Management

```bash
# Backup database
docker-compose exec database mysqldump -u root -p kharisma_db > backup.sql

# Restore database
docker-compose exec database mysql -u root -p kharisma_db < backup.sql

# Access MySQL CLI
docker-compose exec database mysql -u root -p

# View database logs
docker-compose logs -f database
```

### Cleanup

```bash
# Stop containers (keep volumes)
docker-compose down

# Stop and remove volumes (DELETE DATA!)
docker-compose down -v

# Or use cleanup script
./scripts/docker-clean.sh
```

---

## Development Workflow

### 1. Start Development Environment

```bash
make dev
# Services start with hot reload enabled
```

### 2. Make Code Changes

Backend:
```bash
# Edit Go files in backend/
# Changes automatically recompiled (air watches for changes)
```

Frontend:
```bash
# Edit TypeScript/React files in frontend/
# Changes automatically reloaded in browser
```

### 3. Test Changes

```bash
# Backend tests
docker-compose exec backend go test -v ./...

# Frontend tests
docker-compose exec frontend npm test

# API testing
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/orders
```

### 4. View Logs

```bash
# All logs
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs -f --tail=100 backend
```

---

## Production Deployment

### Prerequisites

1. Linux/Unix server with Docker installed
2. Domain name configured
3. SSL certificates in `nginx/ssl/`
4. `.env.production` file with secure values

### Steps

1. **Clone repository**
   ```bash
   git clone <repo-url>
   cd kharisma-abadi-v2
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env.production
   # Edit with production values
   nano .env.production
   ```

3. **Configure SSL**
   ```bash
   # Copy SSL certificates
   mkdir -p nginx/ssl
   cp /path/to/cert.pem nginx/ssl/
   cp /path/to/key.pem nginx/ssl/
   
   # Uncomment HTTPS in nginx/conf.d/default.conf
   ```

4. **Start services**
   ```bash
   ./scripts/docker-prod.sh
   ```

5. **Verify health**
   ```bash
   docker-compose ps
   curl http://localhost/health
   ```

6. **Set up monitoring**
   ```bash
   # Enable logging in docker-compose.prod.yml
   # View logs: docker-compose logs -f
   ```

---

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs backend

# Common issues:
# - Port already in use: change port in .env
# - Insufficient disk space: run docker system prune -a
# - Memory issues: increase Docker memory limit
```

### Database connection errors

```bash
# Verify database is running
docker-compose ps database

# Check database health
docker-compose exec database mysql -u root -p -e "SELECT 1"

# View database logs
docker-compose logs database

# Restart database
docker-compose restart database
docker-compose up -d backend  # Restart backend to reconnect
```

### Frontend can't reach backend

```bash
# Check backend is running
docker-compose ps backend

# Test backend from frontend container
docker-compose exec frontend wget -O- http://backend:8000/api/v1/health

# Check NEXT_PUBLIC_API_URL environment variable
docker-compose exec frontend env | grep NEXT_PUBLIC_API_URL

# In development, should be: http://localhost:8000/api/v1
# In production, should be: /api/v1 (relative URL for nginx)
```

### High memory usage

```bash
# Check which container is using memory
docker stats

# Reduce container limits (edit docker-compose.yml)
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 512M

# Restart container
docker-compose restart backend
```

### Disk space issues

```bash
# Check docker disk usage
docker system df

# Prune unused images
docker system prune -a -f

# Prune volumes (WARNING: deletes data)
docker volume prune -f

# Clear logs
docker-compose logs -f --timestamps | tail -1000 > logs.txt
```

---

## Health Checks

Each service has health checks configured:

```bash
# Check all health statuses
docker-compose ps

# Expected output:
# NAME              COMMAND           STATUS
# database          "docker-entry…"   Up ... (healthy)
# redis             "redis-server"    Up ... (healthy)
# backend           "./kharisma-api"  Up ... (healthy)
# frontend          "npm run dev"     Up ... (healthy)
# nginx             "nginx -g daem"   Up ... (healthy)
```

### Manual health checks

```bash
# Backend
curl http://localhost:8000/api/v1/health

# Frontend  
curl http://localhost:3000/api/health

# Database
docker-compose exec database mysql -u root -p -e "SELECT 1"

# Redis
docker-compose exec redis redis-cli ping
```

---

## Performance Optimization

### Database

```bash
# Add indexes for common queries
docker-compose exec database mysql -u root -p kharisma_db
mysql> CREATE INDEX idx_customer_phone ON customers(phone);
mysql> CREATE INDEX idx_order_status ON orders(status);
```

### Frontend

```bash
# Enable compression in nginx
# Already configured in nginx.conf (gzip on)

# Browser caching for static files
# Already configured in default.conf (expires 365d)
```

### Backend

```bash
# Use Redis caching for frequently accessed data
# Connection string: redis://redis:6379/0
```

---

## Security

### Network isolation

- All services on `kharisma-network`
- Only exposed ports: 80, 443, 3000, 8000 (dev only)
- Database not exposed in production

### Container security

- No-new-privileges security option
- Non-root user in containers
- Read-only filesystems where possible
- Resource limits configured

### Secrets

```bash
# Never commit .env files
# Use environment variables for secrets
# Rotate JWT_SECRET periodically
# Use strong DB passwords
```

---

## Backup & Recovery

### Backup

```bash
# Backup database
docker-compose exec database mysqldump -u root -p kharisma_db > backup.sql

# Backup with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker-compose exec database mysqldump -u root -p kharisma_db > backup_$TIMESTAMP.sql

# Backup script
./scripts/backup-db.sh
```

### Recovery

```bash
# Stop containers
docker-compose down

# Restore database (creates if doesn't exist)
docker-compose up -d database
sleep 10
docker-compose exec database mysql -u root -p kharisma_db < backup.sql

# Restart all services
docker-compose up -d
```

---

## Monitoring

### View resource usage

```bash
# Real-time stats
docker stats

# Container-specific
docker stats kharisma-backend
```

### View logs with timestamps

```bash
# Last 50 lines with timestamps
docker-compose logs --timestamps --tail=50

# Follow logs from multiple services
docker-compose logs -f backend frontend
```

### Set up log aggregation (Optional)

```yaml
# In docker-compose.yml, configure centralized logging:
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Next Steps

1. **Development:** Use `make dev` for local development
2. **Testing:** Run `make test` to execute all tests
3. **Production:** Use `.env.production` and `docker-compose.prod.yml`
4. **Monitoring:** Set up log aggregation and alerts
5. **Updates:** Pull latest, rebuild, and restart services

---

**Docker setup complete and production-ready!**
