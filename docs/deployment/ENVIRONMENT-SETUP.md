# Environment Configuration Setup Guide

**For:** Development and DevOps Teams  
**Purpose:** Managing environment variables across development, staging, and production  
**Last Updated:** October 22, 2025

---

## Quick Start

```bash
# 1. Copy example files
cp .env.example .env
cp backend/.env.example backend/.env.development
cp frontend/.env.local.example frontend/.env.local

# 2. Edit files with your values
vi .env
vi backend/.env.development
vi frontend/.env.local

# 3. Start development
make dev
```

---

## Directory Structure

```
kharisma-abadi-v2/
├── .env.example                      # Root Docker environment template
├── .env                              # (created by user) - NOT COMMITTED
│
├── backend/
│   ├── .env.example                  # Backend example with 70+ variables
│   ├── .env.development              # Development overrides
│   ├── .env.production               # Production template
│   └── .env                          # (created by user) - NOT COMMITTED
│
├── frontend/
│   ├── .env.local.example            # Next.js example template
│   ├── .env.development              # Development overrides
│   ├── .env.production               # Production template
│   ├── .env.local                    # (created by user) - NOT COMMITTED
│   ├── .env.development.local        # (optional) - NOT COMMITTED
│   └── .env.production.local         # (optional) - NOT COMMITTED
│
└── docs/deployment/
    └── ENVIRONMENT-SETUP.md          # This file
```

---

## Environment Files Overview

### 1. Root Environment File (`.env`)

**Purpose:** Docker Compose service configuration  
**Used by:** docker-compose.yml and all services  
**Visibility:** All services can access

**Created from:**
```bash
cp .env.example .env
```

**Key Variables:**

| Variable | Used By | Default | Notes |
|----------|---------|---------|-------|
| `DB_ROOT_PASSWORD` | MariaDB | `rootpassword` | ⚠️ Change for production |
| `DB_PASSWORD` | Backend | `password` | ⚠️ Change for production |
| `JWT_SECRET` | Backend | `your-secret-key` | ⚠️ Generate strong value |
| `REDIS_HOST` | Backend | `redis` | Docker service name |
| `BACKEND_PORT` | Nginx | `8000` | Backend service port |
| `FRONTEND_PORT` | Nginx | `3000` | Frontend service port |
| `ENVIRONMENT` | All | `development` | Set to `production` in prod |

**Security Checklist:**

- [ ] Never commit .env to git (already in .gitignore)
- [ ] Use strong random passwords
- [ ] Generate JWT_SECRET: `openssl rand -base64 32`
- [ ] For production: `ENVIRONMENT=production` and `DEBUG=false`
- [ ] For HTTPS: `ENABLE_HTTPS=true` and set certificate paths

---

### 2. Backend Environment Files

#### `backend/.env.example`

**Purpose:** Template with all backend configuration options (70+ variables)  
**Copy To:** `backend/.env.development` or `backend/.env.production`

**Sections:**
- Application (APP_NAME, ENVIRONMENT, DEBUG, LOG_LEVEL)
- Database (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD, DB_PORT, DB_POOL_SIZE)
- Redis (REDIS_HOST, REDIS_PORT, CACHE_DEFAULT_TTL)
- Security (JWT_SECRET, JWT_EXPIRE_HOURS, BCRYPT_COST, CORS_ALLOWED_ORIGINS)
- File Upload (UPLOAD_DIR, MAX_UPLOAD_SIZE, ALLOWED_EXTENSIONS)
- External Services (SMS_PROVIDER, PAYMENT_PROVIDER, EMAIL_PROVIDER)
- Feature Flags (FEATURE_SMS_NOTIFICATIONS, FEATURE_REPORTS_EXPORT)
- Observability (LOG_LEVEL, SENTRY_DSN)

#### `backend/.env.development`

**Purpose:** Development-specific configuration  
**Used:** When running `./scripts/docker-dev.sh` or `make dev`

**Key Settings:**
```bash
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug
DB_HOST=localhost          # Local or Docker service
REDIS_HOST=localhost
JWT_SECRET=dev-secret-key
RATE_LIMIT_ENABLED=false   # Relaxed for testing
LOG_QUERIES=true           # Debug database queries
```

**Features:**
- All debug logging enabled
- Relaxed rate limiting
- Direct localhost connections (for local development)
- Query logging for debugging
- Test feature flags enabled

#### `backend/.env.production`

**Purpose:** Production deployment configuration template  
**Used:** When running `./scripts/docker-prod.sh` or `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

**Key Settings:**
```bash
ENVIRONMENT=production
DEBUG=false               # No debug info
LOG_LEVEL=info           # Only important logs
DB_HOST=database          # Docker service name
REDIS_HOST=redis          # Docker service name
JWT_SECRET=<CHANGE_ME>    # ⚠️ Requires manual change
RATE_LIMIT_ENABLED=true   # Strict rate limiting (30/min)
```

**Features:**
- Debug logging disabled
- Strict rate limiting
- Docker service names (not localhost)
- Real credentials required
- Production-grade error handling
- Minimal logging overhead

**Setup Instructions:**
```bash
# 1. Copy from example
cp backend/.env.example backend/.env.production

# 2. Generate strong JWT secret
openssl rand -base64 32

# 3. Edit production file
vi backend/.env.production

# 4. Change these values:
# - JWT_SECRET (generated above)
# - Database passwords
# - CORS_ALLOWED_ORIGINS (your domain)
# - External API keys (if using Stripe, Twilio, etc.)
```

---

### 3. Frontend Environment Files

#### `frontend/.env.local.example`

**Purpose:** Template with all frontend configuration options (public + server-side)  
**Copy To:** `frontend/.env.local` or environment-specific files

**Sections:**
- API Configuration (NEXT_PUBLIC_API_URL, NEXT_PUBLIC_API_TIMEOUT)
- Application (NEXT_PUBLIC_APP_NAME, NEXT_PUBLIC_ENVIRONMENT, NEXT_PUBLIC_DEBUG)
- Feature Flags (NEXT_PUBLIC_FEATURE_*, all enabled by default)
- UI Configuration (NEXT_PUBLIC_ITEMS_PER_PAGE, NEXT_PUBLIC_EXPERIMENTAL_FEATURES)
- Analytics (NEXT_PUBLIC_GA_ID, NEXT_PUBLIC_SENTRY_DSN)
- Server-Side Only (API_SECRET_URL, TOKEN_STORAGE, CORS_ENABLED)
- Security (CSP_REPORT_ONLY, SECURITY_HEADERS_TEST)

**Important Notes:**
- `NEXT_PUBLIC_*` variables are included in browser bundle (visible to clients)
- Never put secrets in `NEXT_PUBLIC_*` variables
- Server-side variables (without NEXT_PUBLIC_) are hidden from browsers

#### `frontend/.env.development`

**Purpose:** Development configuration for `npm run dev`  
**Used:** Development environment with hot reload

**Key Settings:**
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_ENVIRONMENT=development
NEXT_PUBLIC_DEBUG=true
NEXT_PUBLIC_EXPERIMENTAL_FEATURES=true
ENABLE_REQUEST_LOGGING=true
MOCK_API=false
CSP_REPORT_ONLY=true
```

**Features:**
- Direct localhost API (no CORS issues)
- All features enabled
- Experimental features enabled
- Debug logging enabled
- All analytics disabled
- Request/response logging
- CSP violations logged but not enforced

#### `frontend/.env.production`

**Purpose:** Production configuration for `npm run build && npm start`  
**Used:** Production deployment

**Key Settings:**
```bash
NEXT_PUBLIC_API_URL=/api/v1                    # Relative URL
NEXT_PUBLIC_ENVIRONMENT=production
NEXT_PUBLIC_DEBUG=false                        # No debug
NEXT_PUBLIC_EXPERIMENTAL_FEATURES=false        # Stable features only
TOKEN_STORAGE=sessionStorage                   # More secure
CSP_REPORT_ONLY=false                          # Enforce CSP
REQUIRE_HTTPS=true                             # HTTPS only
```

**Features:**
- Relative API URL (works behind reverse proxy)
- Debug disabled
- Experimental features disabled
- Session storage for tokens (cleared on browser close)
- CSP enforced (blocks unsafe content)
- HTTPS required
- Analytics enabled

**Setup Instructions:**
```bash
# 1. Copy from example
cp frontend/.env.local.example frontend/.env.local

# 2. For development (already set)
# OR for production:
cp frontend/.env.production.example frontend/.env.production

# 3. Edit file
vi frontend/.env.local

# 4. For production:
# - Set NEXT_PUBLIC_GA_ID to your Google Analytics ID
# - Set NEXT_PUBLIC_SENTRY_DSN to your Sentry project
# - Verify API_SECRET_URL points to backend service
# - Test authentication before deploying
```

---

## Environment Variables Reference

### Public Variables (Frontend Only)

These are prefixed with `NEXT_PUBLIC_` and are visible in browser:

```javascript
// In browser console, you can see:
console.log(process.env.NEXT_PUBLIC_API_URL)      // "http://localhost:8000/api/v1"
console.log(process.env.NEXT_PUBLIC_APP_NAME)     // "Kharisma Abadi"
console.log(process.env.NEXT_PUBLIC_DEBUG)        // "true"
```

**Use for:** UI configuration, feature flags, analytics IDs  
**Never use for:** API keys, secrets, credentials

### Server-Side Variables (Frontend)

These are only available in `getServerSideProps` and API routes:

```javascript
// backend/pages/api/example.ts
export default function handler(req, res) {
  const apiUrl = process.env.API_SECRET_URL  // Hidden from browser
  const tokenStorage = process.env.TOKEN_STORAGE
  // ...
}
```

**Use for:** Secret credentials, internal API URLs, sensitive configs  
**Never expose to:** Frontend components, client-side code

### Backend Variables

All backend variables are server-side only (no NEXT_PUBLIC_ prefix):

```go
// backend/main.go
dbPassword := os.Getenv("DB_PASSWORD")     // From .env
jwtSecret := os.Getenv("JWT_SECRET")
corsOrigins := os.Getenv("CORS_ALLOWED_ORIGINS")
```

**Use for:** Database credentials, API keys, internal configuration  
**Never expose to:** Client browsers, public endpoints

---

## Development Workflow

### Step 1: Initial Setup

```bash
# Clone repository
git clone <repo>
cd kharisma-abadi-v2

# Copy environment files
cp .env.example .env
cp backend/.env.example backend/.env.development
cp frontend/.env.local.example frontend/.env.local

# Edit if needed (usually defaults work for local dev)
vi .env
vi backend/.env.development
vi frontend/.env.local
```

### Step 2: Start Development

```bash
# Using Makefile
make dev

# OR using docker-compose directly
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Verify services are running
docker-compose ps
```

### Step 3: Verify Connectivity

```bash
# Test backend health
curl http://localhost:8000/api/v1/health

# Test frontend
open http://localhost:3000

# Test database
mysql -h localhost -u kharisma -p -e "USE kharisma_db; SELECT COUNT(*) FROM users;"

# Test Redis
redis-cli -h localhost PING
```

### Step 4: Make Changes

Backend changes:
- Edit `backend/` files
- Air will auto-reload on save
- Check `make dev` logs for errors

Frontend changes:
- Edit `frontend/` files
- Next.js will auto-reload on save
- Check browser console for errors

### Step 5: Test

```bash
# Run backend tests
make test-backend

# Run frontend tests
make test-frontend

# Run all tests
make test
```

---

## Production Deployment

### Prerequisites

1. **Create production environment files:**
   ```bash
   cp backend/.env.example backend/.env.production
   cp frontend/.env.local.example frontend/.env.production
   ```

2. **Generate strong secrets:**
   ```bash
   # JWT Secret
   openssl rand -base64 32
   
   # Database passwords
   openssl rand -base64 16
   ```

3. **Update production files:**
   ```bash
   vi backend/.env.production    # Set DB_PASSWORD, JWT_SECRET, etc.
   vi frontend/.env.production   # Set GA_ID, SENTRY_DSN, API_URL
   vi .env.example -> .env       # Root Docker config
   ```

### Deployment Steps

```bash
# 1. Validate environment
./scripts/validate-env.sh

# 2. Start production services
./scripts/docker-prod.sh

# 3. Verify services
docker-compose ps

# 4. Check logs
docker-compose logs -f backend

# 5. Test endpoints
curl https://yourdomain.com/api/v1/health
```

---

## Environment Variable Types

### String Variables

```bash
APP_NAME=Kharisma Abadi
JWT_SECRET=abc123xyz789
```

### Boolean Variables

```bash
DEBUG=true
DEBUG=false
ENABLE_HTTPS=true
```

### Numeric Variables

```bash
BACKEND_PORT=8000
DB_PORT=3306
MAX_UPLOAD_SIZE=10485760
JWT_EXPIRE_HOURS=24
```

### List Variables (Comma-Separated)

```bash
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8000
ALLOWED_EXTENSIONS=jpg,jpeg,png,pdf,doc,docx
```

### JSON Variables (For Complex Config)

```bash
# In .env (escape quotes)
DATABASE_CONFIG="{\"pool_size\":25,\"timeout\":5000}"

# In code
config := json.Unmarshal([]byte(os.Getenv("DATABASE_CONFIG")))
```

---

## Common Issues and Solutions

### Issue: "Cannot connect to database"

**Cause:** DB_HOST or DB_PASSWORD incorrect

**Solution:**
```bash
# Check .env file
cat .env | grep DB_

# Check Docker container
docker-compose exec database mysql -u root -p -e "SELECT VERSION();"

# Verify service running
docker-compose ps database
```

### Issue: "API URL not accessible"

**Cause:** NEXT_PUBLIC_API_URL pointing to wrong address

**Solution:**
```bash
# Development: Use localhost
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1

# Production: Use relative path
NEXT_PUBLIC_API_URL=/api/v1

# Verify backend is running
curl http://localhost:8000/api/v1/health
```

### Issue: "Frontend environment variables not loading"

**Cause:** File named `.env.local` (not `.env.development`)

**Solution:**
```bash
# Next.js uses these file names:
# .env              (always loaded)
# .env.development  (loaded in dev mode)
# .env.production   (loaded in production)
# .env.local        (local overrides, NOT COMMITTED)

# For development, use:
cp frontend/.env.local.example frontend/.env.local

# Restart development server
npm run dev
```

### Issue: "Backend not reading environment variables"

**Cause:** Wrong .env file location or backend not restarted

**Solution:**
```bash
# Backend .env must be in backend/ directory
ls -la backend/.env.development

# If using Docker, .env is in root directory
ls -la .env

# Restart service
docker-compose restart backend
# OR
make dev
```

### Issue: "JWT tokens expiring too quickly"

**Cause:** JWT_EXPIRE_HOURS set too low

**Solution:**
```bash
# Check current setting
grep JWT_EXPIRE_HOURS backend/.env

# Increase to 24 hours
echo "JWT_EXPIRE_HOURS=24" >> backend/.env

# Restart backend
docker-compose restart backend
```

---

## Security Best Practices

### 1. Secrets Management

✅ **DO:**
```bash
# Generate strong secrets
JWT_SECRET=$(openssl rand -base64 32)
DB_PASSWORD=$(openssl rand -base64 16)

# Use environment variables
export JWT_SECRET
export DB_PASSWORD
```

❌ **DON'T:**
```bash
# Hardcode secrets
JWT_SECRET=hardcodedvalue123

# Commit .env files
git add .env  # BAD! Already in .gitignore

# Share secrets in chat/email
JWT_SECRET shared in Slack
```

### 2. Environment Separation

✅ **DO:**
```bash
# Separate files for each environment
backend/.env.development    # Local passwords
backend/.env.production     # Real passwords

# Different settings
# Development: DEBUG=true, LOG_LEVEL=debug
# Production: DEBUG=false, LOG_LEVEL=info
```

❌ **DON'T:**
```bash
# Same file for all environments
.env with production secrets in version control

# Same settings everywhere
DEBUG=true in production
```

### 3. Credentials Rotation

✅ **DO:**
```bash
# Rotate JWT secret regularly (monthly)
OLD_JWT_SECRET=$JWT_SECRET
JWT_SECRET=$(openssl rand -base64 32)

# Update in environment
# Allow old tokens to expire naturally
# Update new secret in deployment

# Change database passwords quarterly
DB_PASSWORD=$(openssl rand -base64 16)
```

❌ **DON'T:**
```bash
# Use same JWT secret for years
# Share passwords with team members
# Store secrets in code comments
```

### 4. Public vs Private Variables

✅ **DO:**
```javascript
// Frontend public (visible to all users)
const API_URL = process.env.NEXT_PUBLIC_API_URL  // "http://localhost:8000/api/v1"
const APP_NAME = process.env.NEXT_PUBLIC_APP_NAME  // "Kharisma Abadi"

// Backend server-side only (hidden from users)
const DB_PASSWORD = process.env.DB_PASSWORD  // "secure-password-xyz"
const JWT_SECRET = process.env.JWT_SECRET    // "secret-key-xyz"
```

❌ **DON'T:**
```javascript
// Never in NEXT_PUBLIC_
NEXT_PUBLIC_DB_PASSWORD=secure-password-xyz  // BAD!
NEXT_PUBLIC_JWT_SECRET=secret-key-xyz        // BAD!
NEXT_PUBLIC_API_KEY=stripe-key-xyz           // BAD!
```

---

## Validation Scripts

### Validate Environment Files

```bash
# Check all required variables are present
./scripts/validate-env.sh

# Output:
# ✓ DB_PASSWORD is set
# ✓ JWT_SECRET is set
# ✗ STRIPE_API_KEY is missing (optional)
# ✓ All required variables validated
```

### Validate Connectivity

```bash
# Check database connectivity
docker-compose exec backend mysql -u $DB_USER -p$DB_PASSWORD -h database -e "SELECT 1;"

# Check Redis connectivity
docker-compose exec backend redis-cli -h redis PING

# Check backend API
curl http://localhost:8000/api/v1/health

# Check frontend
curl http://localhost:3000
```

---

## Quick Reference

| Scenario | Command |
|----------|---------|
| Setup dev environment | `cp .env.example .env && make dev` |
| Change JWT secret | Edit backend/.env, restart backend |
| Enable feature flag | Edit backend/.env, set FEATURE_FLAG=true, restart |
| Test with different API | Edit frontend/.env.local, set NEXT_PUBLIC_API_URL |
| Deploy to production | Create .env.production with real credentials, run docker-prod.sh |
| Check current settings | `docker-compose config \| grep -i <var>` |
| Update database password | Edit .env, run migration, restart backend |
| View all environment variables | `docker-compose exec backend env \| sort` |

---

## Additional Resources

- **Security Architecture:** docs/architecture/security-architecture.md
- **Docker Guide:** docs/deployment/DOCKER-GUIDE.md
- **Technical Specifications:** docs/technical/TECHNICAL-SPEC.md
- **Contributing Guide:** CONTRIBUTING.md

---

**Environment setup completed. Ready for development!**
