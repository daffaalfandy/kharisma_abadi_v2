# Architecture Documentation

**Project:** Kharisma Abadi v2
**Date:** October 2025
**Architecture Pattern:** Clean Architecture with Layered Design

---

## Quick Navigation

### 📐 Architecture Diagrams

1. **[System Architecture](./system-architecture.md)** ⭐ START HERE
   - High-level system overview
   - All major components and their interactions
   - Request/response flow
   - Technology stack summary

2. **[Component Architecture](./component-architecture.md)**
   - Detailed backend components
   - API layer breakdown
   - Service layer organization
   - Repository pattern implementation

3. **[Deployment Architecture](./deployment-architecture.md)**
   - Infrastructure setup
   - Docker composition
   - Network topology
   - Production deployment view

4. **[Data Flow Diagrams](./data-flow-diagrams.md)**
   - Create Order workflow
   - Payment processing flow
   - Data movement through system
   - Sequence diagrams for key operations

5. **[Database ERD](./database-erd.md)**
   - Entity Relationship Diagram
   - Table structure
   - Key relationships
   - Migration from old schema

6. **[Security Architecture](./security-architecture.md)**
   - Security layers
   - Authentication & Authorization
   - Data protection mechanisms
   - Compliance considerations

7. **[Frontend State Management](./frontend-state-management.md)**
   - Pinia store organization
   - Vue composables
   - State flow
   - Caching strategies

---

## Architecture Principles

### Clean Architecture
The codebase follows Clean Architecture principles:
- **Independence of Frameworks:** Core logic doesn't depend on frameworks
- **Testability:** Business logic easily unit tested
- **Independence of UI:** Logic works with different UIs
- **Independence of Database:** ORM abstracts database details
- **Independence of External Agencies:** Easy to swap external services

### Dependency Rule
Dependencies always flow inward:
- **Presentation Layer** depends on Application Layer
- **Application Layer** depends on Domain Layer
- **Infrastructure** implements Domain interfaces
- **Domain Layer** depends on nothing

### Clear Separation of Concerns
```
Presentation (Handlers) → Application (Services) → Domain (Entities) ← Infrastructure (Repositories)
```

---

## Core Concepts

### Layers

#### 1. Presentation Layer
- HTTP request/response handling
- Input validation (DTOs)
- Error formatting
- Status code selection

**Files:** `internal/handler/*.go`

#### 2. Application Layer
- Use cases and orchestration
- Service coordination
- Transaction management
- Logging and error handling

**Files:** `internal/usecase/*.go`, `internal/service/*.go`

#### 3. Domain Layer
- Business logic
- Domain entities
- Value objects
- Business rules

**Files:** `internal/domain/*.go`

#### 4. Infrastructure Layer
- Database access (GORM)
- Repository implementations
- External service integration
- Configuration

**Files:** `internal/repository/*.go`, `internal/infrastructure/*.go`

---

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Backend Language | Go | 1.21+ |
| HTTP Framework | Fiber | 2.50+ |
| ORM | GORM | 1.25+ |
| Database | MariaDB | 11 LTS |
| Frontend Framework | Vue | 3.3+ |
| Build Tool | Vite | 5.0+ |
| Language (Frontend) | TypeScript | 5.2+ |
| State Management | Pinia | 2.1+ |
| HTTP Client | Axios | 1.6+ |
| Forms | VeeValidate | 4.11+ |
| Styling | Tailwind CSS | 3.3+ |
| Containerization | Docker | Latest |
| Orchestration | Docker Compose | Latest |

---

## Development Structure

```
kharisma-abadi-backend/
├── cmd/server/main.go              # Entry point
├── internal/
│   ├── domain/                      # Core business logic
│   ├── usecase/                     # Application workflows
│   ├── handler/                     # HTTP handlers
│   ├── middleware/                  # HTTP middleware
│   ├── repository/                  # Data access
│   ├── infrastructure/              # External integrations
│   └── types/                       # Shared types
├── migrations/                      # Database migrations
└── tests/                           # Test files

kharisma-abadi-frontend/
├── src/
│   ├── views/                       # Page components
│   ├── components/                  # Reusable components
│   ├── stores/                      # Pinia stores
│   ├── services/                    # API services
│   ├── types/                       # TypeScript interfaces
│   ├── router/                      # Vue Router config
│   └── composables/                 # Reusable logic
└── tests/                           # Test files
```

---

## Key Diagrams

### System Flow
```
Client → Frontend → Backend API → Database
  ↑                   ↓
  └─── Response ──────┘
```

### Dependency Flow
```
Presentation
    ↓
Application
    ↓
Domain ← Infrastructure
```

### Request Processing
```
Request → Middleware → Handler → Service → Entity → Repository → Database
Response ← Handler ← Service ← Entity ← Repository ← Database
```

---

## When to Reference Each Document

| Need | Reference |
|------|-----------|
| **Understand overall system** | [System Architecture](./system-architecture.md) |
| **Implement a handler** | [Component Architecture](./component-architecture.md) |
| **Deploy to production** | [Deployment Architecture](./deployment-architecture.md) |
| **Trace data flow** | [Data Flow Diagrams](./data-flow-diagrams.md) |
| **Understand data model** | [Database ERD](./database-erd.md) |
| **Implement security** | [Security Architecture](./security-architecture.md) |
| **Manage state** | [Frontend State Management](./frontend-state-management.md) |

---

## Common Development Tasks

### Adding a New Endpoint

1. **Define Handler** in `internal/handler/{feature}.go`
2. **Create UseCase** in `internal/usecase/{action}.go`
3. **Create Service** in `internal/service/{feature}.go`
4. **Add Repository Method** in `internal/repository/{entity}.go`
5. **Define Domain Entity** in `internal/domain/{entity}.go`
6. **Register Route** in `cmd/server/main.go`
7. **Create Frontend Service** in `src/services/{feature}.ts`
8. **Create Frontend Component** in `src/components/{feature}.vue`

### Adding Database Migration

1. Create migration file in `migrations/`
2. Define UP migration (schema changes)
3. Define DOWN migration (rollback)
4. Run migrations
5. Update GORM models
6. Update frontend TypeScript interfaces

### Implementing Business Logic

1. Start in **Domain Layer** (business rules)
2. Create **UseCase** to orchestrate
3. Add **Service** layer if complex
4. Create **Repository** for persistence
5. Add **Handler** for HTTP exposure
6. Test extensively

---

## Architecture Decision Records

### Go + Fiber
- **Decision:** Use Go with Fiber framework for backend
- **Rationale:** Performance (5-10x faster), type safety, compiled binary
- **Alternative Considered:** Python FastAPI, Node.js Express
- **Impact:** Faster API, easier deployment, better resource utilization

### GORM for ORM
- **Decision:** Use GORM for database access
- **Rationale:** Type safety, good Go ORM, migration support
- **Alternative Considered:** SQLc, Raw SQL
- **Impact:** Less boilerplate, automatic relationship handling

### Vue 3 + Pinia
- **Decision:** Use Vue 3 with Pinia for state management
- **Rationale:** Simplicity, productivity, small bundle size
- **Alternative Considered:** React with Redux, Svelte
- **Impact:** Faster development, easier to maintain

### Clean Architecture
- **Decision:** Organize code by layers (not features)
- **Rationale:** Clear separation of concerns, testability
- **Alternative Considered:** Feature-based structure
- **Impact:** Better code organization, easier to maintain

---

## Performance Characteristics

| Metric | Target | Method |
|--------|--------|--------|
| API Response (p50) | < 100ms | Fiber + GORM optimization |
| API Response (p95) | < 500ms | Caching + indexing |
| Throughput | 10,000+ req/sec | Connection pooling |
| Concurrent Users | 10,000+ | Docker container scaling |
| Database Size | 50-100MB | Optimized schema |
| Frontend Bundle | ~60KB | Tree-shaking + minification |

---

## Scaling Strategy

### Vertical Scaling
- Increase container resources
- Optimize queries
- Add caching layer

### Horizontal Scaling
- Multiple backend instances
- Load balancer (Nginx)
- Database read replicas
- Message queue for async tasks

---

## Security Posture

✅ **Implemented:**
- HTTPS/TLS encryption
- JWT authentication
- Role-based authorization
- Input validation
- SQL injection prevention
- XSS protection
- Password hashing (bcrypt)
- Audit logging
- Rate limiting

⚠️ **To Consider:**
- Web Application Firewall (WAF)
- DDoS protection
- Intrusion detection
- Database encryption at rest
- Key rotation policies

---

## References

- [Go by Example](https://gobyexample.com/)
- [Fiber Framework Docs](https://docs.gofiber.io/)
- [GORM Documentation](https://gorm.io/)
- [Vue 3 Guide](https://vuejs.org/)
- [Clean Architecture Book](https://www.oreilly.com/library/view/clean-architecture/9780134494166/)
- [Technical Specification](../technical/TECHNICAL-SPEC.md)
- [Database Migration Plan](../database/MIGRATION-PLAN.md)

---

**This architecture provides a maintainable, scalable, and secure foundation for the Kharisma Abadi application.**
