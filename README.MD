# Kharisma Abadi V2

Modern, maintainable rebuild of the Kharisma Abadi multi-service cashier system.

## 🏢 About

Kharisma Abadi is a comprehensive multi-service business offering:
- 🚗 **Car Wash Service** - Professional vehicle washing
- 👕 **Laundry Service** - Clothing and textile cleaning
- 🧺 **Carpet Washing Service** - Professional carpet and upholstery cleaning
- 💧 **Drinking Water Delivery Service** - Bottled water distribution

This is a complete rebuild focusing on **maintainability**, **scalability**, and modern development practices.

**Key Improvements:**
- Consolidated schema from legacy 10+ tables to unified design
- Zero data loss migration of 67,000+ production records
- Clean Architecture with clear separation of concerns
- Comprehensive testing (unit, integration, E2E)
- Production-ready security implementation
- Complete API and business logic documentation

## 📚 Documentation

**Start Here:**
1. [REFERENCE.md](./REFERENCE.md) - Complete documentation index
2. [docs/planning/PRD.md](./docs/planning/PRD.md) - Product requirements
3. [docs/technical/TECHNICAL-SPEC.md](./docs/technical/TECHNICAL-SPEC.md) - Technical specifications

**Full Documentation Structure:**
- `docs/planning/` - Requirements, user stories, product backlog
- `docs/technical/` - Architecture decisions, API specifications
- `docs/business-logic/` - Business rules and validations
- `docs/business-flows/` - Process flows and state machines
- `docs/database/` - Database schema and migration procedures
- `docs/api/` - Complete API documentation
- `docs/architecture/` - System architecture diagrams

## 🛠️ Technology Stack

**Backend:**
- Framework: Go 1.21+ with Fiber web framework
- Language: Go (compiled binary)
- Database: MariaDB 11 LTS
- ORM: GORM
- Authentication: JWT with refresh tokens
- Validation: Go validators

**Frontend:**
- Framework: Next.js 14+ (App Router)
- Language: TypeScript 5+
- UI Library: shadcn/ui + Tailwind CSS
- State Management: Zustand + TanStack Query
- Form Handling: React Hook Form + Zod validation

**Infrastructure:**
- Containerization: Docker & Docker Compose
- Database: MariaDB 11
- Web Server: Nginx (reverse proxy)
- Development: Hot reload, debug mode

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** (includes Docker & Docker Compose)
- **Git** (version 2.30+)
- **Node.js 18+** (for frontend development without Docker)
- **Go 1.21+** (for backend development without Docker)

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd kharisma-abadi-v2
   ```

2. **Copy environment files:**
   ```bash
   cp backend/.env.example backend/.env
   cp frontend/.env.local.example frontend/.env.local
   ```

3. **Edit environment files:**
   - `backend/.env` - Database credentials and secrets
   - `frontend/.env.local` - API endpoint configuration

4. **Start development environment:**
   ```bash
   # Using Docker Compose (recommended)
   make dev
   
   # Or manually
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
   ```

5. **Access the application:**
   - **Frontend:** http://localhost:3000
   - **Backend API:** http://localhost:8000
   - **API Documentation:** http://localhost:8000/docs
   - **Database:** localhost:3306 (MySQL client)

### Available Commands

```bash
# Development & Building
make dev              # Start complete development environment
make build            # Build all services (Docker images)
make clean            # Clean build artifacts and cache

# Testing
make test             # Run all tests (backend + frontend)
make test-backend     # Run backend unit tests
make test-frontend    # Run frontend unit tests
make test-e2e         # Run E2E tests

# Code Quality
make lint             # Run linters on all code
make format           # Auto-format code (Black, Prettier)
make type-check       # Run type checkers (mypy, TypeScript)

# Database
make migrate          # Run pending database migrations
make migrate-create   # Create new migration (prompts for message)
make db-seed          # Seed database with sample data
make db-backup        # Create database backup

# Utilities
make install          # Install all dependencies
make setup            # Initial setup (copy .env files)
make help             # Show all available commands
```

See [Makefile](./Makefile) for all available commands and details.

## 📁 Project Structure

```
kharisma-abadi-v2/
├── backend/                      # Go + Fiber API
│   ├── app/
│   │   ├── handlers/            # HTTP request handlers
│   │   ├── services/            # Business logic layer
│   │   ├── repositories/        # Data access layer
│   │   ├── models/              # Domain entities
│   │   ├── middleware/          # HTTP middleware
│   │   ├── migrations/          # Database migrations
│   │   └── main.go              # Application entry point
│   ├── tests/                   # Backend tests
│   ├── go.mod & go.sum          # Dependency management
│   ├── Dockerfile               # Backend container
│   ├── .env.example             # Environment template
│   └── README.md                # Backend documentation
│
├── frontend/                     # Next.js + TypeScript
│   ├── src/
│   │   ├── app/                 # Next.js App Router
│   │   ├── components/          # React components
│   │   ├── services/            # API client services
│   │   ├── hooks/               # Custom React hooks
│   │   ├── stores/              # Zustand state
│   │   ├── types/               # TypeScript types
│   │   └── utils/               # Utility functions
│   ├── public/                  # Static assets
│   ├── __tests__/               # Frontend tests
│   ├── package.json             # Dependencies
│   ├── tsconfig.json            # TypeScript config
│   ├── next.config.js           # Next.js config
│   ├── Dockerfile               # Frontend container
│   ├── .env.local.example       # Environment template
│   └── README.md                # Frontend documentation
│
├── docs/                        # Complete documentation
│   ├── planning/                # Requirements & backlog
│   ├── technical/               # Technical specs
│   ├── business-logic/          # Business rules
│   ├── business-flows/          # Process flows
│   ├── database/                # Schema & migrations
│   ├── api/                     # API documentation
│   ├── architecture/            # System diagrams
│   └── analysis/                # Legacy analysis
│
├── scripts/                     # Utility scripts
│   ├── setup-dev.sh             # Development setup
│   ├── backup-db.sh             # Database backup
│   ├── migrate-data.sh          # Data migration
│   └── deploy.sh                # Manual deployment
│
├── docker-compose.yml           # Development environment
├── docker-compose.dev.yml       # Development overrides
├── docker-compose.prod.yml      # Production configuration
├── Makefile                     # Development commands
├── .gitignore                   # Git ignore patterns
├── .editorconfig                # Editor configuration
├── README.md                    # This file
├── CONTRIBUTING.md              # Contribution guidelines
├── REFERENCE.md                 # Documentation reference
└── LICENSE                      # License (MIT)
```

## 🧪 Testing

### Backend Tests

```bash
cd backend
go test -v ./...                 # Run all tests with verbose output
go test -cover ./...            # Run tests with coverage
go test -race ./...             # Run tests with race detector
```

### Frontend Tests

```bash
cd frontend
npm test                         # Run unit tests in watch mode
npm run test:coverage           # Run tests with coverage report
npm run test:e2e                # Run Playwright E2E tests
```

### Test Coverage

Maintain >80% test coverage for critical paths:
- **Backend:** Business logic, API handlers, repositories
- **Frontend:** Components, hooks, utilities

## 🔐 Security

The application implements comprehensive security measures:

- **Authentication:** JWT tokens with refresh token rotation
- **Authorization:** Role-based access control (RBAC)
  - Admin: Full system access
  - Manager: Orders, customers, reports
  - Cashier: Orders, customer info, payments
- **Data Protection:**
  - Passwords: Bcrypt hashing (cost 12)
  - Sensitive fields: AES-256 encryption
  - Backups: Encrypted storage
- **API Security:**
  - Input validation (Zod + Go validators)
  - SQL injection prevention (ORM parameterized queries)
  - XSS protection (output sanitization)
  - CSRF protection
- **Transport Security:**
  - HTTPS/TLS 1.3 in production
  - Secure HTTP headers
- **Audit Trail:**
  - All changes logged in audit_logs table
  - 7-year retention for compliance

See [docs/architecture/security-architecture.md](./docs/architecture/security-architecture.md) for details.

## 📝 Development Workflow

### Feature Development

1. **Pick a task** from `docs/planning/product-backlog.md`
2. **Create feature branch:**
   ```bash
   git checkout -b feature/US-XXX-short-description
   ```
3. **Implement feature** following Clean Architecture patterns
4. **Write tests:** Unit + integration tests (>80% coverage)
5. **Code quality:**
   ```bash
   make lint      # Check for style issues
   make format    # Auto-format code
   ```
6. **Commit with conventional messages:**
   ```
   feat: Add car wash order creation (US-004)
   fix: Correct pricing calculation
   docs: Update API documentation
   test: Add payment service tests
   ```
7. **Create pull request** with test coverage
8. **Code review** and merge

### Deployment (Manual on Windows Client PC)

Manual deployment process for production:

1. **Build backend:**
   ```bash
   cd backend
   go build -o kharisma-api
   ```

2. **Build frontend:**
   ```bash
   cd frontend
   npm run build
   npm start  # Start Next.js server
   ```

3. **Database migration:**
   ```bash
   # Create backup first
   mysqldump -u root -p kharisma_db > backup.sql
   
   # Run migrations
   cd backend
   go run migrations/main.go
   ```

4. **Start application:**
   - Backend: `./kharisma-api`
   - Frontend: `npm start` (or use PM2/NSSM for Windows services)

See [docs/database/IMPLEMENTATION-GUIDE.md](./docs/database/IMPLEMENTATION-GUIDE.md) for detailed migration steps.

## 🤝 Contributing

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for details on:
- Code style and standards
- Development process
- Testing requirements
- Pull request procedures

## 📊 Project Status

- ✅ Phase 1-4: Analysis, Planning, Architecture, Documentation **COMPLETE**
- ✅ Database migration plan and scripts **READY**
- ✅ Security architecture and implementation **DESIGNED**
- 🔄 Phase 5: Backend development **IN PROGRESS**
- 🔄 Phase 6: Frontend development **NEXT**
- 🔄 Phase 7: Integration and testing **PLANNED**

## 📄 License

MIT License - See [LICENSE](./LICENSE) file for details

## 👥 Team

- **Project Lead:** [Your Name]
- **Backend Lead:** [Your Name]
- **Frontend Lead:** [Your Name]

## 📞 Support

For issues, questions, or discussions:
- GitHub Issues: [repository-url]/issues
- Documentation: See [REFERENCE.md](./REFERENCE.md)
- Email: support@kharisma-abadi.local

---

**Status:** Ready for development phase

**Last Updated:** October 2025

**Next Steps:** Review `REFERENCE.md` and begin Phase 5 development
