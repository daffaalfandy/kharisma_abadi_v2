# Technical Documentation - Kharisma Abadi Rebuild

**Project:** Kharisma Abadi Multi-Service POS System Rebuild  
**Technology Stack:** Go 1.21+ (Fiber) | Vue 3 | MariaDB 11 | Docker  
**Architecture:** Clean Architecture / Hexagonal  
**Last Updated:** October 2025

---

## 📚 Documentation Index

This directory contains all technical specifications and implementation guides for the Kharisma Abadi application rebuild.

### Core Documents

1. **[TECHNICAL-SPEC.md](./TECHNICAL-SPEC.md)** (Primary Reference)
   - Complete system architecture overview
   - Backend (Go/Fiber) architecture with code examples
   - Frontend (Vue 3) architecture with component structure
   - Database design and schema
   - Project structure for both backend and frontend
   - Design patterns and best practices
   - **READ THIS FIRST** for overall understanding

2. **[API-SPECIFICATION.md](./API-SPECIFICATION.md)** (Developer Reference)
   - Complete REST API endpoint documentation
   - Authentication and authorization flows
   - Request/response examples for all endpoints
   - Error handling and status codes
   - Rate limiting and pagination
   - User management, customer management, orders, payments, reporting
   - Code examples in Go and JavaScript
   - **USE WHEN:** Implementing API endpoints or building client code

3. **[SECURITY-SPECIFICATION.md](./SECURITY-SPECIFICATION.md)** (Security Reference)
   - Authentication & authorization details
   - Data encryption (in transit and at rest)
   - SQL injection and XSS prevention
   - CSRF protection and rate limiting
   - Infrastructure security (database, containers, network)
   - Audit logging and compliance
   - Incident response procedures
   - **USE WHEN:** Implementing security features or conducting security reviews

---

## 🏗️ Architecture Overview

### System Layers

```
┌────────────────────────────────────┐
│     Frontend (Vue 3)               │
│  • Components                       │
│  • State Management (Pinia)         │
│  • Routing (Vue Router)             │
└────────────────────────────────────┘
              ↓ REST API
┌────────────────────────────────────┐
│   Backend (Go/Fiber)               │
│  • HTTP Handlers                    │
│  • Middleware (Auth, CORS, etc)    │
│  • Business Logic (Use Cases)       │
│  • Domain Models                    │
│  • Data Access (GORM)               │
└────────────────────────────────────┘
              ↓ SQL
┌────────────────────────────────────┐
│    Database (MariaDB)              │
│  • Users, Customers, Orders        │
│  • Payments, Audit Logs            │
└────────────────────────────────────┘
```

### Key Architectural Principles

- **Clean Architecture:** Clear separation between layers
- **Domain-Driven Design:** Business logic at the core
- **Repository Pattern:** Data access abstraction
- **Use Case Pattern:** Business workflows encapsulated
- **Dependency Injection:** Loose coupling between components
- **SOLID Principles:** Maintainability and extensibility

---

## 🔧 Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Backend** | Go | 1.21+ | Type-safe, high-performance API |
| **Web Framework** | Fiber | v2.50+ | Express-like HTTP framework |
| **ORM** | GORM | 1.25+ | Database abstraction |
| **Frontend** | Vue 3 | 3.3+ | Progressive JavaScript framework |
| **Build Tool** | Vite | 5.0+ | Lightning-fast bundler |
| **Language** | TypeScript | 5.2+ | Type-safe JavaScript |
| **State** | Pinia | 2.1+ | Vue state management |
| **Database** | MariaDB | 11 | Open-source MySQL |
| **Containerization** | Docker | Latest | Portable deployment |
| **Orchestration** | Docker Compose | v2+ | Multi-container management |

### Why This Stack?

✅ **Performance:** Go is 10x faster than Python  
✅ **Size:** ~150MB total Docker image vs 500MB+ for alternatives  
✅ **Team Fit:** Easier for small team to maintain  
✅ **Security:** Strong type systems, built-in security practices  
✅ **Scalability:** Goroutines handle massive concurrency  
✅ **Maintainability:** Clean code, excellent documentation  

---

## 📦 Project Structure

### Backend

```
backend/
├── cmd/server/main.go              # Entry point
├── internal/
│   ├── domain/                     # Business logic
│   ├── usecase/                    # Use cases
│   ├── handler/                    # HTTP handlers
│   ├── middleware/                 # Middleware
│   ├── repository/                 # Data access
│   └── infrastructure/             # External services
├── migrations/                     # Database migrations
├── tests/                          # Test files
└── docker/                         # Docker configuration
```

### Frontend

```
frontend/
├── src/
│   ├── views/                      # Page components
│   ├── components/                 # Reusable components
│   ├── stores/                     # Pinia stores
│   ├── services/                   # API services
│   ├── router/                     # Route definitions
│   ├── types/                      # TypeScript types
│   └── utils/                      # Utilities
├── tests/                          # Test files
└── public/                         # Static assets
```

---

## 🚀 Getting Started

### 1. Initial Setup

```bash
# Clone repository
git clone https://github.com/kharisma/kharisma-abadi.git
cd kharisma-abadi

# Backend setup
cd backend
cp .env.example .env
go mod download
go run ./cmd/server/main.go

# Frontend setup (in another terminal)
cd frontend
npm install
npm run dev
```

### 2. Development

**Read First:**
- [TECHNICAL-SPEC.md](./TECHNICAL-SPEC.md) - Understand architecture
- [API-SPECIFICATION.md](./API-SPECIFICATION.md) - API contracts
- [SECURITY-SPECIFICATION.md](./SECURITY-SPECIFICATION.md) - Security requirements

**Then:**
1. Create a feature branch
2. Implement changes following the architecture
3. Write tests (target: >85% coverage)
4. Create pull request
5. Code review
6. Merge to main

### 3. Deployment

```bash
# Build Docker images
docker-compose build

# Run production stack
docker-compose -f docker-compose.prod.yml up -d

# Monitor
docker-compose logs -f api frontend
```

---

## 🔐 Security

### Authentication
- JWT tokens (access + refresh)
- Bcrypt password hashing
- Session management
- Token rotation

### Authorization
- Role-Based Access Control (RBAC)
- 5 roles: Admin, Manager, Cashier, Service Staff, Viewer
- Resource-level authorization

### Data Protection
- HTTPS/TLS encryption
- SQL injection prevention (GORM ORM)
- XSS protection (input validation)
- CSRF protection

**See [SECURITY-SPECIFICATION.md](./SECURITY-SPECIFICATION.md) for complete details**

---

## 📊 Database

### Core Tables
- **users** - System users with roles
- **customers** - Customer information
- **orders** - Service orders (unified for all services)
- **payments** - Payment records
- **audit_logs** - Security audit trail

### Constraints
- Foreign key relationships enforced
- Check constraints for data integrity
- Unique constraints for business rules
- Indexes for query optimization

**See TECHNICAL-SPEC.md Section 5 for complete schema**

---

## 🔌 API

### Base URL
- Development: `http://localhost:3000/api/v1`
- Production: `https://api.example.com/api/v1`

### Authentication
```
Authorization: Bearer {access_token}
```

### Response Format
```json
{
  "success": true,
  "data": {...},
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100
  }
}
```

### Main Endpoints
- `POST /auth/login` - User authentication
- `GET /orders` - List orders
- `POST /orders` - Create order
- `PATCH /orders/{id}` - Update order
- `POST /payments` - Process payment
- `GET /reports/*` - Generate reports

**See [API-SPECIFICATION.md](./API-SPECIFICATION.md) for complete API reference**

---

## 🧪 Testing

### Backend Testing
```bash
# Unit tests
go test ./... -v

# With coverage
go test ./... -cover

# Integration tests
go test -tags integration ./...
```

### Frontend Testing
```bash
# Unit tests
npm run test

# Coverage
npm run test:coverage

# E2E tests
npm run test:e2e
```

### Test Pyramid
- **Unit Tests (70%):** Domain logic, services, utilities
- **Integration Tests (20%):** API endpoints, database
- **E2E Tests (10%):** Critical user flows

**Target:** >85% code coverage

---

## 📈 Performance

### Backend
- API response time: <100ms (p95)
- Database query: <50ms (p95)
- Throughput: 10k+ orders/second
- Memory: ~10MB idle
- Container size: ~50-80MB

### Frontend
- Initial load: <1.5 seconds
- Time to interactive: <2 seconds
- Bundle size: ~60KB (gzipped)
- Lighthouse score: >92

---

## 📝 Implementation Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup (backend & frontend)
- [ ] Database schema created
- [ ] Docker environment configured
- [ ] CI/CD pipeline setup
- [ ] Development guidelines documented

### Phase 2: Authentication (Week 2-3)
- [ ] JWT implementation
- [ ] User registration & login
- [ ] Role-based access control
- [ ] Token refresh mechanism
- [ ] Password reset flow

### Phase 3: Core APIs (Week 3-4)
- [ ] Order management APIs
- [ ] Customer management
- [ ] Payment processing
- [ ] Queue management
- [ ] Input validation

### Phase 4: Frontend (Week 5-6)
- [ ] Authentication UI
- [ ] Order management pages
- [ ] Payment interface
- [ ] Dashboard/reports
- [ ] Error handling

### Phase 5: Testing & Optimization (Week 7-8)
- [ ] Unit tests (>85% coverage)
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Security audit
- [ ] UAT preparation

### Phase 6: Deployment (Week 9-10)
- [ ] Production deployment
- [ ] Performance monitoring
- [ ] Backup strategy
- [ ] Staff training
- [ ] Go-live

---

## 🐛 Troubleshooting

### Common Issues

**Backend won't start:**
```bash
# Check if port 3000 is in use
lsof -i :3000

# Check database connection
mysql -h localhost -u kharisma -p -e "SHOW DATABASES"
```

**Frontend can't connect to API:**
```bash
# Check VITE_API_URL
echo $VITE_API_URL

# Test API endpoint
curl http://localhost:3000/health
```

**Database migration fails:**
```bash
# Check migration status
go run github.com/golang-migrate/migrate/v4/cmd/migrate@latest -path ./migrations -database "mysql://..." up -verbose

# Rollback
go run github.com/golang-migrate/migrate/v4/cmd/migrate@latest -path ./migrations -database "mysql://..." down
```

---

## 📞 Support & Documentation

### Internal Resources
- Technical Specification: [TECHNICAL-SPEC.md](./TECHNICAL-SPEC.md)
- API Reference: [API-SPECIFICATION.md](./API-SPECIFICATION.md)
- Security Guide: [SECURITY-SPECIFICATION.md](./SECURITY-SPECIFICATION.md)
- Business Flows: `../../docs/business-flows/README.md`
- PRD: `../../docs/planning/PRD.md`

### External Resources
- Go Documentation: https://golang.org/doc
- Fiber Framework: https://docs.gofiber.io
- Vue.js: https://vuejs.org
- MariaDB: https://mariadb.com/docs

---

## 📋 Document Maintenance

This documentation should be updated when:
- Architecture changes
- New APIs are added
- Security procedures change
- Technology versions are upgraded
- New best practices are adopted

**Maintain accurate, current documentation as a priority.**

---

## 👥 Contributing

When implementing features:

1. **Read Documentation:** Understand architecture first
2. **Follow Patterns:** Use established patterns consistently
3. **Write Tests:** Aim for >85% coverage
4. **Security First:** Apply security checks and validation
5. **Update Docs:** Keep documentation current
6. **Code Review:** Request review before merging

---

## ✅ Quality Standards

**Code Quality:**
- Type safety (Go + TypeScript)
- >85% test coverage
- ESLint/Prettier compliance
- No security warnings

**Performance:**
- API response <200ms (p95)
- Page load <2 seconds
- No memory leaks
- Query optimization

**Security:**
- JWT authentication
- Input validation
- SQL injection prevention
- XSS protection
- RBAC authorization

---

## 📅 Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | Oct 2025 | Updated for Go/Fiber + Vue 3 stack |
| 1.0 | Sep 2025 | Initial specification (Python/React) |

---

## 📞 Questions?

Refer to the specific document section:
- **Architecture questions:** → TECHNICAL-SPEC.md
- **API questions:** → API-SPECIFICATION.md
- **Security questions:** → SECURITY-SPECIFICATION.md
- **Business logic:** → `../../docs/business-flows/`
- **Project requirements:** → `../../docs/planning/PRD.md`

---

**Last Updated:** October 2025  
**Maintained By:** Development Team  
**Status:** Active & Current

This comprehensive technical documentation is your guide to understanding, implementing, and maintaining the Kharisma Abadi application. Use it as your reference throughout development.
