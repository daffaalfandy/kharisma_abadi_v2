# Kharisma Abadi V2 - Complete Documentation Reference

**Quick Navigation Guide for All Project Documentation**

---

## 📖 Table of Contents

1. [Getting Started](#-getting-started)
2. [Project Overview](#-project-overview)
3. [Development Guide](#-development-guide)
4. [Architecture & Design](#-architecture--design)
5. [API Documentation](#-api-documentation)
6. [Database Guide](#-database-guide)
7. [Business Logic](#-business-logic)
8. [Troubleshooting](#-troubleshooting)

---

## 🚀 Getting Started

**New to the project? Start here:**

### First Time Setup
1. Read: [README.md](./README.md) - Project overview and quick start
2. Follow: [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
3. Review: [docs/planning/PRD.md](./docs/planning/PRD.md) - What we're building

### 5-Minute Quick Start
```bash
git clone <repo-url>
cd kharisma-abadi-v2
make setup
make dev
```

Access: http://localhost:3000 (Frontend) | http://localhost:8000 (Backend)

### Key Commands
```bash
make dev              # Start development environment
make test             # Run all tests
make lint             # Check code quality
make format           # Format code
make help             # Show all commands
```

---

## 📋 Project Overview

### What Is Kharisma Abadi?

Multi-service business system handling:
- **🚗 Car Wash** - Vehicle cleaning services
- **👕 Laundry** - Clothing cleaning and laundry
- **🧺 Carpet Cleaning** - Carpet and upholstery services
- **💧 Water Delivery** - Bottled drinking water distribution

**This Project:** Complete rebuild with modern architecture and maintainable code

### Project Status

- ✅ **Phase 1-4:** Analysis, Planning, Architecture, Documentation (COMPLETE)
- ✅ **Database:** Migration plan, schema, scripts (READY)
- ✅ **Security:** Architecture and implementation (DESIGNED)
- 🔄 **Phase 5:** Backend development (IN PROGRESS)
- 🔄 **Phase 6:** Frontend development (NEXT)
- 📅 **Phase 7:** Integration & testing (PLANNED)

### Technology Stack

| Component | Technology |
|-----------|-----------|
| **Backend** | Go 1.21+ with Fiber |
| **Frontend** | Next.js 14+ with TypeScript |
| **Database** | MariaDB 11 LTS |
| **ORM** | GORM |
| **UI Components** | shadcn/ui + Tailwind CSS |
| **State** | Zustand + TanStack Query |
| **Authentication** | JWT with refresh tokens |
| **Containerization** | Docker + Docker Compose |

### Deployment Model

- **Development:** Docker Compose (all services locally)
- **Production:** Manual deployment on Windows client PC
  - Backend: Windows Service (NSSM) or direct execution
  - Frontend: Next.js built and served
  - Database: MariaDB/MySQL local installation

---

## 🛠️ Development Guide

### Setting Up Development Environment

1. **Install Prerequisites:**
   - Docker Desktop (includes Docker & Compose)
   - Git
   - Code editor (VS Code recommended)

2. **Clone and Setup:**
   ```bash
   git clone <repository-url>
   cd kharisma-abadi-v2
   make setup
   make dev
   ```

3. **Verify Setup:**
   - Frontend loads at http://localhost:3000
   - API responds at http://localhost:8000/health
   - Database accessible at localhost:3306

### Development Workflow

**Complete guide:** [CONTRIBUTING.md](./CONTRIBUTING.md)

**Quick workflow:**
1. Create feature branch: `git checkout -b feature/US-XXX-description`
2. Implement feature following architecture patterns
3. Write tests (>80% coverage for critical paths)
4. Check code quality: `make lint`, `make format`
5. Commit: `git commit -m "feat(scope): Description (US-XXX)"`
6. Create pull request with tests
7. Code review and merge

### Code Organization

**Backend (Go + Fiber):**
```
backend/app/
├── handlers/       # HTTP request handlers (controllers)
├── services/       # Business logic layer
├── repositories/   # Data access layer (GORM)
├── models/         # Domain entities
├── middleware/     # HTTP middleware (auth, validation)
└── migrations/     # Database migration SQL
```

**Frontend (Next.js + React):**
```
frontend/src/
├── app/            # Next.js App Router pages
├── components/     # React components
├── services/       # API client functions
├── hooks/          # Custom React hooks
├── stores/         # Zustand state management
├── types/          # TypeScript interfaces
└── utils/          # Utility functions
```

### Testing

**Backend:**
```bash
cd backend
go test -v ./...              # Run all tests
go test -cover ./...          # With coverage
go test -race ./...           # Race condition detection
```

**Frontend:**
```bash
cd frontend
npm test                      # Unit tests
npm run test:e2e             # E2E tests with Playwright
npm run test:coverage        # Coverage report
```

**Requirements:**
- Minimum 80% coverage for critical business logic
- All tests passing before merge
- No broken functionality

### Code Style & Standards

**Backend (Go):**
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Format with `go fmt` and `goimports`
- Lint with `golangci-lint`
- Max line length: 100 characters

**Frontend (TypeScript):**
- TypeScript strict mode enabled
- Use Prettier for formatting
- Follow ESLint rules
- Use functional components + hooks
- Max line length: 100 characters

**Commits:**
- Use Conventional Commits format
- Examples:
  - `feat(orders): Add car wash order creation (US-004)`
  - `fix(payments): Correct decimal precision`
  - `test(services): Add pricing service tests`

### Common Development Tasks

**Create new feature:**
```bash
git checkout -b feature/US-XXX-description
# ... implement feature ...
make lint
make format
make test
git commit -m "feat(scope): Description (US-XXX)"
```

**Run database migrations:**
```bash
make migrate        # Run pending migrations
make migrate-create # Create new migration
make db-seed       # Seed with sample data
```

**Debug and troubleshooting:**
```bash
make logs           # View container logs
make logs-backend   # Backend only
make shell-backend  # Interactive shell in container
make clean          # Clean build artifacts
```

---

## 🏗️ Architecture & Design

### System Architecture

**Complete diagram:** [docs/architecture/system-architecture.md](./docs/architecture/system-architecture.md)

**High-level layers:**
1. **Client Layer** - Web browsers, mobile clients
2. **Frontend Layer** - Next.js with React, TypeScript
3. **Backend Layer** - Go/Fiber API with business logic
4. **Data Layer** - MariaDB database with GORM ORM
5. **External Services** - SMS gateway, payments (future)

### Clean Architecture

**Layered approach:**
- **Presentation Layer** - HTTP handlers, DTOs
- **Application Layer** - Use cases, services
- **Domain Layer** - Business rules, entities
- **Infrastructure Layer** - Database, external APIs

**Benefits:**
- Clear separation of concerns
- Easy testing and mocking
- Low coupling between layers
- High cohesion within layers

### Design Patterns Used

- **Repository Pattern** - Data access abstraction
- **Service Pattern** - Business logic encapsulation
- **Middleware Pattern** - Cross-cutting concerns
- **Factory Pattern** - Object creation
- **Dependency Injection** - Loose coupling

### Database Schema

**Complete ERD:** [docs/architecture/database-erd.md](./docs/architecture/database-erd.md)

**7 main tables:**
- `users` - System users (admin, manager, cashier)
- `customers` - Customer information (consolidated)
- `orders` - Business transactions (car wash, laundry, etc)
- `order_items` - Line items in orders
- `payments` - Payment records
- `audit_logs` - Change tracking
- `system_config` - Application settings

**Key features:**
- Soft deletes (preserve history)
- Audit logging (all changes tracked)
- Proper indexes for performance
- Foreign key constraints
- GORM-optimized field names

### Security Architecture

**Complete guide:** [docs/architecture/security-architecture.md](./docs/architecture/security-architecture.md)

**8 security layers:**
1. **Transport** - HTTPS/TLS 1.3
2. **Network** - Firewall, WAF
3. **Authentication** - JWT tokens
4. **Authorization** - RBAC (Role-Based Access Control)
5. **Input Validation** - Prevent SQL injection, XSS
6. **Data Encryption** - Passwords (bcrypt), sensitive fields (AES-256)
7. **Audit Logging** - All changes tracked
8. **Monitoring** - Alert on suspicious activity

**Implementation highlights:**
- Passwords: bcrypt with cost 12
- Tokens: 14-hour access, 7-day refresh
- Validation: GORM + field validators
- XSS Prevention: Output sanitization
- CSRF: Token validation

---

## 📡 API Documentation

### API Overview

**Full documentation:** [docs/api/API-DESIGN.md](./docs/api/API-DESIGN.md)

**API endpoint:**
- Base URL: `http://localhost:8000` (development)
- Base URL: `https://api.kharisma.local` (production)
- API Version: `/api/v1`

### Core Endpoints

**Authentication:**
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `POST /api/v1/auth/refresh` - Refresh token

**Orders:**
- `GET /api/v1/orders` - List all orders (paginated)
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders/{id}` - Get specific order
- `PATCH /api/v1/orders/{id}` - Update order
- `DELETE /api/v1/orders/{id}` - Delete order

**Customers:**
- `GET /api/v1/customers` - List customers
- `POST /api/v1/customers` - Create customer
- `GET /api/v1/customers/{id}` - Get customer details
- `PATCH /api/v1/customers/{id}` - Update customer

**Payments:**
- `GET /api/v1/payments` - List payments
- `POST /api/v1/payments` - Record payment
- `GET /api/v1/payments/{id}` - Get payment

**Reports:**
- `GET /api/v1/reports/sales` - Sales report
- `GET /api/v1/reports/customers` - Customer report
- `GET /api/v1/reports/services` - Service report

### Authentication

All endpoints except login require JWT token in header:
```
Authorization: Bearer <token>
```

Token obtained from login response:
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "expires_in": 50400
}
```

### API Testing

**With cURL:**
```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# Get orders (with token)
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:8000/api/v1/orders
```

**Interactive docs:** http://localhost:8000/docs (Swagger/OpenAPI)

---

## 💾 Database Guide

### Database Migration

**Complete guide:** [docs/database/MIGRATION-PLAN.md](./docs/database/MIGRATION-PLAN.md)

**Overview:**
- Zero-data-loss migration from legacy system
- 67,000+ records consolidated into 7 tables
- Blue-green deployment strategy
- Automated backup and verification
- Rollback capability within 15 minutes

**Migration phases:**
1. **Pre-Migration** - Backup, validation (30 min)
2. **Schema Creation** - Create new tables/indexes (30 min)
3. **Data Migration** - Transform and copy data (1-2 hours)
4. **Verification** - Integrity checks (30 min)
5. **Post-Migration** - Cleanup, final backup (30 min)

**Implementation steps:** [docs/database/IMPLEMENTATION-GUIDE.md](./docs/database/IMPLEMENTATION-GUIDE.md)

### Schema Documentation

**Detailed schema:** [docs/architecture/database-erd.md](./docs/architecture/database-erd.md)

**Key tables:**

| Table | Purpose | Records |
|-------|---------|---------|
| `users` | System users | ~100-200 |
| `customers` | Customer data | ~10,000-15,000 |
| `orders` | Transactions | ~30,000-50,000 |
| `order_items` | Line items | ~60,000+ |
| `payments` | Payment records | ~30,000-50,000 |
| `audit_logs` | Change tracking | Unlimited |
| `system_config` | Settings | ~10-20 |

### Working with Migrations

**Create new migration:**
```bash
make migrate-create
# Enter description: "add customer email field"
```

**Run migrations:**
```bash
make migrate        # Apply all pending
make db-seed       # Seed test data
make db-backup     # Create backup
```

**Rollback (if needed):**
```bash
make migrate-rollback
```

### Database Queries

**Direct database access:**
```bash
make shell-database  # Open MySQL CLI
# Enter root password
mysql> SHOW TABLES;
mysql> SELECT COUNT(*) FROM orders;
```

**GORM in Go:**
```go
// Query orders
var orders []Order
db.Where("status = ?", "completed").Find(&orders)

// Create order
order := Order{CustomerID: 1, Total: 50000}
db.Create(&order)

// Update order
db.Model(&Order{}).Where("id = ?", 1).Update("status", "shipped")
```

### Backup & Recovery

**Create backup:**
```bash
make db-backup  # Creates timestamped backup
```

**Manual backup:**
```bash
mysqldump -u root -p kharisma_db > backup_$(date +%Y%m%d).sql
```

**Restore from backup:**
```bash
mysql -u root -p kharisma_db < backup_20241022.sql
```

---

## 💼 Business Logic

### Business Rules

**Complete guide:** [docs/business-logic/BUSINESS-RULES.md](./docs/business-logic/BUSINESS-RULES.md)

**Key rules:**

**Orders:**
- Must have customer_id
- Service type: car_wash | laundry | carpet_cleaning | water_delivery
- Status: pending → in_progress → completed (or cancelled)
- Total = subtotal - discount + tax (always ≥ 0)
- All prices in Indonesian Rupiah (Rp)

**Customers:**
- Unique phone number
- Discount 0-100% based on type (regular, VIP, corporate)
- Track order history for loyalty/discounts

**Payments:**
- Method: cash | bank_transfer | ewallet | card
- Status: pending → completed (or failed/refunded)
- Amount ≤ order total
- Can have multiple partial payments per order

**Users:**
- Role: admin (full access) | manager (orders/reports) | cashier (orders only)
- Password: min 12 chars, uppercase, lowercase, digit, special char
- Hashed with bcrypt cost 12

### Business Flows

**Complete flows:** [docs/business-flows/](./docs/business-flows/)

**Main flows:**

1. **Create Order:**
   - Customer walks in or calls
   - Cashier enters order details
   - System calculates price
   - Apply discount if applicable
   - Save order

2. **Payment Processing:**
   - Customer makes payment
   - Cashier records payment method
   - System updates payment status
   - Generate receipt (optional)

3. **Service Completion:**
   - Service staff marks as in progress
   - Upon completion, mark as complete
   - Trigger customer notification (SMS)

4. **Reporting:**
   - Generate daily sales report
   - Customer spending analysis
   - Service type performance
   - Payment method breakdown

---

## 🔍 Troubleshooting

### Common Issues

**Problem: Port already in use**
```bash
# Find process on port
lsof -i :3000
lsof -i :8000

# Kill process
kill -9 <PID>
```

**Problem: Database connection error**
```bash
# Check if MySQL is running
docker-compose ps

# Restart database
docker-compose restart database
make migrate  # Re-run migrations
```

**Problem: Tests failing**
```bash
# Clean and rebuild
make clean
make install
make test

# Check logs
docker-compose logs -f backend
```

**Problem: TypeScript errors**
```bash
cd frontend
npm run type-check  # Check for type errors
npm install         # Reinstall dependencies
```

### Performance Issues

**Slow API responses:**
- Check database indexes: `docs/database/SCHEMA-DIFF.md`
- Add query logging in service layer
- Profile with: `pprof` (Go) or DevTools (Frontend)

**High memory usage:**
- Check for memory leaks in goroutines
- Review database connection pool settings
- Clear old logs: `make clean`

**Slow tests:**
- Run only affected tests
- Use race detector: `go test -race`
- Profile with `go test -cpuprofile`

### Debugging

**Backend debugging:**
```bash
# Enable debug logging
export LOG_LEVEL=debug
make dev

# View logs
make logs-backend

# Interactive shell
make shell-backend
```

**Frontend debugging:**
```bash
# Browser DevTools (F12)
# Open http://localhost:3000
# Check Network tab and Console

# View React logs
npm run dev  # Development mode shows more info
```

**Database debugging:**
```bash
# Check table structure
make shell-database
mysql> DESC orders;
mysql> SHOW INDEXES FROM orders;

# Analyze slow queries
SET SESSION sql_mode='TRADITIONAL';
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;
```

### Getting Help

1. **Check documentation:** Search [REFERENCE.md](./REFERENCE.md)
2. **Review code examples:** Check similar implementations
3. **Ask team:** GitHub Discussions or team chat
4. **File issue:** GitHub Issues with detailed description

---

## 📚 Complete Documentation Structure

```
docs/
├── analysis/              # Legacy system analysis
│   └── ... (detailed legacy system notes)
│
├── planning/              # Project planning
│   ├── PRD.md            # Product requirements document
│   ├── product-backlog.md # Feature backlog
│   ├── user-stories.md   # Detailed user stories
│   └── timeline.md       # Project timeline
│
├── technical/            # Technical specifications
│   ├── TECHNICAL-SPEC.md # Complete technical spec
│   ├── tech-stack-decision.md # Tech stack rationale
│   └── API-overview.md   # API design overview
│
├── business-logic/       # Business rules
│   ├── BUSINESS-RULES.md # All business rules
│   ├── pricing-rules.md  # Pricing logic
│   └── discount-rules.md # Discount calculations
│
├── business-flows/       # Process flows
│   ├── order-flow.md     # Order creation process
│   ├── payment-flow.md   # Payment processing
│   └── reporting-flow.md # Report generation
│
├── database/            # Database documentation
│   ├── MIGRATION-PLAN.md # Migration strategy
│   ├── IMPLEMENTATION-GUIDE.md # Migration steps
│   ├── SCHEMA-DIFF.md   # Schema changes
│   ├── VERIFICATION-CHECKLIST.md # Post-migration checks
│   └── README.md        # Database guide
│
├── api/                 # API documentation
│   ├── API-DESIGN.md    # Complete API spec
│   ├── endpoints.md     # Endpoint details
│   └── examples.md      # Usage examples
│
└── architecture/        # System architecture
    ├── README.md        # Architecture index
    ├── system-architecture.md # High-level design
    ├── component-architecture.md # Component details
    ├── deployment-architecture.md # Deployment design
    ├── database-erd.md  # Database diagram
    ├── security-architecture.md # Security design
    ├── data-flow-diagrams.md # Data flow
    └── README.md        # Summary
```

---

## ✨ Quick Links

**Development:**
- [README.md](./README.md) - Project overview
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development guide
- [Makefile](./Makefile) - Available commands

**Documentation:**
- [REFERENCE.md](./REFERENCE.md) - This file
- [docs/planning/PRD.md](./docs/planning/PRD.md) - Requirements
- [docs/technical/TECHNICAL-SPEC.md](./docs/technical/TECHNICAL-SPEC.md) - Technical spec

**Architecture:**
- [docs/architecture/README.md](./docs/architecture/README.md) - Architecture overview
- [docs/architecture/system-architecture.md](./docs/architecture/system-architecture.md) - System design
- [docs/architecture/database-erd.md](./docs/architecture/database-erd.md) - Database schema

**Database:**
- [docs/database/MIGRATION-PLAN.md](./docs/database/MIGRATION-PLAN.md) - Migration guide
- [docs/database/IMPLEMENTATION-GUIDE.md](./docs/database/IMPLEMENTATION-GUIDE.md) - Migration steps
- [docs/architecture/security-architecture.md](./docs/architecture/security-architecture.md) - Security design

---

## 📞 Support & Contact

**Questions or issues?**
1. Search this documentation
2. Check related documentation sections
3. Review existing code examples
4. Ask in team discussions
5. Create GitHub issue

**Key contacts:**
- Project Lead: [Name]
- Backend Lead: [Name]
- Frontend Lead: [Name]

---

**Last Updated:** October 2025  
**Status:** Development Phase Active  
**Next Review:** After completion of Phase 5
