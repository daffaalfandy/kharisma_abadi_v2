# Technical Specification - Go Backend & Vue 3 Frontend

**Document Version:** 2.0  
**Date:** October 2025  
**Technology Stack:** Go 1.21+ (Fiber) + Vue 3 + MariaDB  
**Architecture:** Clean Architecture / Hexagonal Architecture  
**Target Deployment:** Windows Docker

---

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Technology Stack](#2-technology-stack)
3. [Backend Architecture (Go)](#3-backend-architecture-go)
4. [Frontend Architecture (Vue 3)](#4-frontend-architecture-vue-3)
5. [Database Design](#5-database-design)
6. [API Specification](#6-api-specification)
7. [Security Specification](#7-security-specification)
8. [Testing Strategy](#8-testing-strategy)
9. [Deployment Architecture](#9-deployment-architecture)

---

## 1. System Architecture

### 1.1 High-Level System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Clients                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Web Browser  │  │ Mobile Tablet│  │  Windows POS │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────┐
│           Frontend Application (Vue 3)                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ • Components (Order, Payment, Reporting)         │  │
│  │ • Vue Router (Client-side Routing)               │  │
│  │ • Pinia Store (State Management)                 │  │
│  │ • Axios HTTP Client                              │  │
│  │ • Tailwind CSS Styling                           │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ REST API
┌─────────────────────────────────────────────────────────┐
│           Backend API Server (Go + Fiber)               │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Presentation Layer (HTTP Handlers)               │  │
│  │ • Authentication Handlers                         │  │
│  │ • Order Handlers                                  │  │
│  │ • Payment Handlers                                │  │
│  │ • Reporting Handlers                              │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Middleware Layer                                  │  │
│  │ • JWT Authentication                              │  │
│  │ • CORS & Security Headers                         │  │
│  │ • Request Validation                              │  │
│  │ • Error Handling                                  │  │
│  │ • Logging                                         │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Application Layer (Use Cases / Services)          │  │
│  │ • Order Management Service                        │  │
│  │ • Payment Processing Service                      │  │
│  │ • User Management Service                         │  │
│  │ • Reporting Service                               │  │
│  │ • Authentication Service                          │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Domain Layer (Business Logic)                     │  │
│  │ • Order Entity                                    │  │
│  │ • Payment Entity                                  │  │
│  │ • Customer Entity                                 │  │
│  │ • Repository Interfaces                           │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Infrastructure Layer (Data Access & External)    │  │
│  │ • GORM Database Access                            │  │
│  │ • Repository Implementations                      │  │
│  │ • External Service Integration                    │  │
│  │ • Configuration Management                        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
        ↓                        ↓                    ↓
┌──────────────┐  ┌──────────────────┐  ┌──────────────┐
│  MariaDB     │  │  SMS Gateway     │  │  File Storage│
│  Database    │  │  (Notifications) │  │  (Receipts)  │
└──────────────┘  └──────────────────┘  └──────────────┘
```

### 1.2 Architecture Layers

#### 1.2.1 Presentation Layer (Handlers)

**Responsibility:** Handle HTTP requests/responses, input validation, response formatting

**Location:** `internal/handler/`

**Key Components:**
- AuthHandler - Login, register, token refresh
- OrderHandler - Create, list, update orders
- PaymentHandler - Process payments, refunds
- ReportHandler - Generate reports
- CustomerHandler - Customer management

**Pattern:** Each handler receives domain objects and returns responses

```go
// Example handler signature
func CreateOrder(c *fiber.Ctx) error {
    // 1. Parse request
    // 2. Validate input
    // 3. Call service
    // 4. Return response
}
```

#### 1.2.2 Middleware Layer

**Responsibility:** Cross-cutting concerns (auth, logging, error handling)

**Key Middleware:**
- JWT Authentication - Verify and validate tokens
- CORS - Handle cross-origin requests
- Logging - Request/response logging
- Error Handler - Standardized error responses
- Compression - Gzip response compression
- Rate Limiting - Prevent abuse

```go
// Middleware registration
app.Use(middleware.Logger())
app.Use(middleware.Compress())
app.Use(AuthMiddleware)
app.Use(ErrorHandlerMiddleware)
```

#### 1.2.3 Application Layer (Services)

**Responsibility:** Orchestrate business workflows, coordinate between domain and infrastructure

**Location:** `internal/usecase/`

**Key Services:**
- CreateOrderUseCase - Orchestrate order creation
- ProcessPaymentUseCase - Handle payment workflows
- GenerateReportUseCase - Report generation logic
- AuthenticationUseCase - User authentication flow

**Pattern:** Each service implements specific use case with clear input/output contracts

```go
type CreateOrderUseCase struct {
    orderRepo     domain.OrderRepository
    customerRepo  domain.CustomerRepository
    pricingRepo   domain.PricingRepository
}

func (uc *CreateOrderUseCase) Execute(ctx context.Context, req CreateOrderRequest) (*Order, error) {
    // 1. Validate input
    // 2. Fetch dependencies
    // 3. Apply business logic
    // 4. Persist changes
    // 5. Return result
}
```

#### 1.2.4 Domain Layer (Core Business Logic)

**Responsibility:** Pure business logic, domain entities, business rules

**Location:** `internal/domain/`

**Key Concepts:**
- Entities - Order, Customer, Payment, User
- Value Objects - Money, OrderStatus, VehicleType
- Repository Interfaces - Define data access contracts
- Domain Services - Pure business operations

**Pattern:** Domain is completely independent of frameworks and infrastructure

```go
// Domain entity - no database annotations
type Order struct {
    ID           uint
    OrderNo      string
    CustomerID   uint
    ServiceType  ServiceType
    TotalPrice   Money
    Status       OrderStatus
}

// Domain logic
func (o *Order) ApplyDiscount(discount decimal.Decimal) error {
    if discount.IsNegative() {
        return errors.New("discount cannot be negative")
    }
    o.TotalPrice = o.TotalPrice.Subtract(discount)
    return nil
}
```

#### 1.2.5 Infrastructure Layer (Data Access)

**Responsibility:** External system integration, data persistence, configuration

**Location:** `internal/infrastructure/` and `internal/repository/`

**Key Components:**
- Database Connection - MariaDB via GORM
- Repositories - GORM-based implementations
- External Services - SMS gateway, payment gateway
- Configuration - Environment variables, settings

```go
// Repository implementation with GORM
type OrderRepository struct {
    db *gorm.DB
}

func (r *OrderRepository) Save(ctx context.Context, order *Order) error {
    return r.db.WithContext(ctx).Save(order).Error
}
```

### 1.3 Request/Response Flow

**Example: Create Car Wash Order**

```
1. Frontend (Vue 3)
   ├─ Form submission
   └─ POST /api/v1/orders with JSON

2. Middleware
   ├─ Parse request body
   ├─ Validate JWT token
   └─ Check user authorization

3. Handler (OrderHandler)
   ├─ Parse request into struct
   ├─ Validate input data
   └─ Call CreateOrderUseCase

4. Use Case (CreateOrderUseCase)
   ├─ Fetch customer record
   ├─ Fetch pricing rules
   ├─ Apply business logic
   └─ Call repository to save

5. Domain
   ├─ Create Order entity
   ├─ Apply business rules
   └─ Validate state

6. Repository (OrderRepository)
   ├─ Map domain to database model
   ├─ Execute SQL INSERT
   └─ Handle database errors

7. Handler (Response)
   ├─ Format response
   ├─ Set HTTP status (201)
   └─ Return JSON

8. Frontend
   ├─ Receive response
   ├─ Update state (Pinia)
   └─ Display success/error
```

---

## 2. Technology Stack

### 2.1 Backend Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Language** | Go | 1.21+ | Compiled, type-safe backend |
| **Framework** | Fiber | v2.50+ | Express-like HTTP framework |
| **Database Driver** | GORM | 1.25+ | Type-safe ORM |
| **DB Connector** | MySQL Driver | v8+ | MariaDB connectivity |
| **Authentication** | golang-jwt | v5+ | JWT token handling |
| **Validation** | Validator | v10+ | Struct validation |
| **Decimal** | shopspring/decimal | 1.3+ | Precise currency handling |
| **Environment** | godotenv | 1.5+ | .env file loading |
| **Migration** | golang-migrate | v4.16+ | Database schema management |
| **Logging** | Structured logs | Go built-in | Request/error logging |
| **Testing** | Testify | v1.8+ | Test assertions and mocking |

### 2.2 Frontend Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Framework** | Vue | 3.3+ | Progressive JS framework |
| **Build Tool** | Vite | 5.0+ | Fast frontend bundler |
| **Language** | TypeScript | 5.2+ | Type-safe JavaScript |
| **Routing** | Vue Router | 4.2+ | Client-side routing |
| **State** | Pinia | 2.1+ | Vue state management |
| **HTTP Client** | Axios | 1.6+ | Promise-based HTTP |
| **Forms** | VeeValidate | 4.11+ | Form validation |
| **Schema Validation** | Yup | 1.3+ | Data validation schemas |
| **Styling** | Tailwind CSS | 3.3+ | Utility-first CSS |
| **UI Components** | Headless UI | 1.7+ | Unstyled components |
| **Testing** | Vitest | 1.0+ | Lightning-fast unit tests |
| **Component Tests** | Vue Test Utils | 2.4+ | Vue component testing |

### 2.3 Database

| Component | Technology | Version |
|-----------|-----------|---------|
| **Database** | MariaDB | 11 LTS |
| **Port** | 3306 | Standard MySQL |
| **Charset** | utf8mb4 | Unicode support |
| **Collation** | utf8mb4_unicode_ci | Case-insensitive |

### 2.4 DevOps & Deployment

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Containerization** | Docker | Lightweight, portable deployment |
| **Orchestration** | Docker Compose | Multi-container management |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **Monitoring** | Structured logging | Request and error logging |
| **Database Backup** | Automated scripts | Daily backups |

---

## 3. Backend Architecture (Go)

### 3.1 Project Structure

```
kharisma-abadi-backend/
├── cmd/
│   └── server/
│       └── main.go                    # Application entry point
│
├── internal/                          # Private application code
│   ├── domain/                        # Core business logic
│   │   ├── order.go                   # Order entity
│   │   ├── customer.go                # Customer entity
│   │   ├── user.go                    # User entity
│   │   ├── payment.go                 # Payment entity
│   │   ├── repository.go              # Repository interfaces
│   │   ├── errors.go                  # Domain errors
│   │   └── value_objects.go           # Money, Status enums
│   │
│   ├── usecase/                       # Application layer (use cases)
│   │   ├── create_order.go            # Create order workflow
│   │   ├── process_payment.go         # Payment processing
│   │   ├── authenticate_user.go       # User authentication
│   │   ├── generate_report.go         # Report generation
│   │   └── service.go                 # Service interfaces
│   │
│   ├── handler/                       # HTTP handlers (Fiber)
│   │   ├── auth.go                    # Auth endpoints
│   │   ├── order.go                   # Order endpoints
│   │   ├── payment.go                 # Payment endpoints
│   │   ├── customer.go                # Customer endpoints
│   │   ├── report.go                  # Report endpoints
│   │   └── health.go                  # Health check
│   │
│   ├── middleware/                    # HTTP middleware
│   │   ├── auth.go                    # JWT validation
│   │   ├── cors.go                    # CORS configuration
│   │   ├── error_handler.go           # Error handling
│   │   ├── logging.go                 # Request logging
│   │   └── compression.go             # Response compression
│   │
│   ├── repository/                    # Data access (GORM)
│   │   ├── order.go                   # Order repository
│   │   ├── customer.go                # Customer repository
│   │   ├── user.go                    # User repository
│   │   ├── payment.go                 # Payment repository
│   │   └── base.go                    # Base repository logic
│   │
│   ├── infrastructure/                # External integrations
│   │   ├── database/
│   │   │   ├── connection.go          # DB connection
│   │   │   ├── migration.go           # Migration runner
│   │   │   └── seeder.go              # Test data seeding
│   │   ├── external/
│   │   │   ├── sms_gateway.go         # SMS integration
│   │   │   └── payment_gateway.go     # Payment integration
│   │   └── config/
│   │       └── config.go              # App configuration
│   │
│   └── types/                         # Shared types
│       ├── request.go                 # API request types
│       ├── response.go                # API response types
│       └── errors.go                  # Error definitions
│
├── migrations/                        # Database migrations
│   ├── 001_create_users.up.sql
│   ├── 001_create_users.down.sql
│   ├── 002_create_customers.up.sql
│   ├── 002_create_customers.down.sql
│   ├── 003_create_orders.up.sql
│   ├── 003_create_orders.down.sql
│   └── ...
│
├── tests/                             # Test files
│   ├── unit/
│   │   ├── domain/
│   │   ├── usecase/
│   │   └── repository/
│   ├── integration/
│   │   ├── handlers/
│   │   └── services/
│   └── fixtures/
│       └── test_data.go
│
├── docker/
│   ├── Dockerfile                     # Go application image
│   ├── Dockerfile.prod                # Production optimized
│   └── .dockerignore
│
├── .env.example                       # Example environment variables
├── .gitignore
├── docker-compose.yml                 # Development compose
├── docker-compose.prod.yml            # Production compose
├── go.mod                             # Go module definition
├── go.sum                             # Dependency versions
├── Makefile                           # Build automation
└── README.md                          # Documentation
```

### 3.2 Core Domain Entities

**Order Entity:**

```go
package domain

import (
    "time"
    "github.com/shopspring/decimal"
)

type OrderStatus string

const (
    OrderPending         OrderStatus = "PENDING"
    OrderInProgress      OrderStatus = "IN_PROGRESS"
    OrderQualityCheck    OrderStatus = "QUALITY_CHECK"
    OrderCompleted       OrderStatus = "COMPLETED"
    OrderAwaitingPayment OrderStatus = "AWAITING_PAYMENT"
    OrderPaid            OrderStatus = "PAID"
    OrderClosed          OrderStatus = "CLOSED"
    OrderCancelled       OrderStatus = "CANCELLED"
)

type ServiceType string

const (
    ServiceCarWash       ServiceType = "CAR_WASH"
    ServiceLaundry       ServiceType = "LAUNDRY"
    ServiceCarpet        ServiceType = "CARPET"
    ServiceWaterDelivery ServiceType = "WATER"
)

type Order struct {
    ID            uint
    OrderNo       string
    CustomerID    uint
    Customer      *Customer
    ServiceType   ServiceType
    Status        OrderStatus
    SubtotalPrice decimal.Decimal
    DiscountAmount decimal.Decimal
    TaxAmount      decimal.Decimal
    TotalPrice    decimal.Decimal
    Notes         string
    CreatedBy     uint
    CreatedAt     time.Time
    UpdatedAt     time.Time
    CompletedAt   *time.Time
}

// Domain logic
func (o *Order) CanTransitionTo(newStatus OrderStatus) bool {
    validTransitions := map[OrderStatus][]OrderStatus{
        OrderPending: {OrderInProgress, OrderCancelled},
        OrderInProgress: {OrderQualityCheck, OrderCancelled},
        OrderQualityCheck: {OrderCompleted, OrderInProgress},
        OrderCompleted: {OrderAwaitingPayment},
        OrderAwaitingPayment: {OrderPaid, OrderCancelled},
        OrderPaid: {OrderClosed},
    }
    
    transitions := validTransitions[o.Status]
    for _, valid := range transitions {
        if valid == newStatus {
            return true
        }
    }
    return false
}

func (o *Order) ApplyDiscount(amount decimal.Decimal) error {
    if amount.IsNegative() {
        return ErrNegativeDiscount
    }
    if amount.GreaterThan(o.SubtotalPrice) {
        return ErrDiscountExceedsTotal
    }
    o.DiscountAmount = amount
    o.TotalPrice = o.SubtotalPrice.Sub(amount)
    return nil
}
```

**User Entity:**

```go
type UserRole string

const (
    RoleAdmin        UserRole = "ADMIN"
    RoleManager      UserRole = "MANAGER"
    RoleCashier      UserRole = "CASHIER"
    RoleServiceStaff UserRole = "SERVICE_STAFF"
    RoleViewer       UserRole = "VIEWER"
)

type User struct {
    ID        uint
    Username  string
    Email     string
    FullName  string
    PasswordHash string
    Role      UserRole
    IsActive  bool
    CreatedAt time.Time
    UpdatedAt time.Time
    LastLogin *time.Time
}
```

### 3.3 Repository Pattern

**Repository Interface (Domain):**

```go
package domain

import "context"

type OrderRepository interface {
    Save(ctx context.Context, order *Order) error
    FindByID(ctx context.Context, id uint) (*Order, error)
    FindByOrderNo(ctx context.Context, orderNo string) (*Order, error)
    FindByCustomer(ctx context.Context, customerID uint, limit int, offset int) ([]*Order, error)
    FindByStatus(ctx context.Context, status OrderStatus) ([]*Order, error)
    Update(ctx context.Context, order *Order) error
    Delete(ctx context.Context, id uint) error
}
```

**Repository Implementation (Infrastructure):**

```go
package repository

import (
    "context"
    "github.com/gorm.io/gorm"
    "github.com/kharisma/api/internal/domain"
)

type orderRepository struct {
    db *gorm.DB
}

func NewOrderRepository(db *gorm.DB) domain.OrderRepository {
    return &orderRepository{db: db}
}

func (r *orderRepository) Save(ctx context.Context, order *domain.Order) error {
    return r.db.WithContext(ctx).Create(order).Error
}

func (r *orderRepository) FindByID(ctx context.Context, id uint) (*domain.Order, error) {
    var order domain.Order
    err := r.db.WithContext(ctx).
        Preload("Customer").
        First(&order, id).
        Error
    return &order, err
}
```

### 3.4 Use Case Pattern

**Use Case Interface:**

```go
package usecase

import "context"

type CreateOrderInput struct {
    CustomerID   uint
    ServiceType  string
    VehicleType  string
    PackageType  string
    TotalPrice   decimal.Decimal
}

type CreateOrderOutput struct {
    OrderID   uint
    OrderNo   string
    TotalPrice decimal.Decimal
    Status    string
}

type CreateOrderUseCase interface {
    Execute(ctx context.Context, input CreateOrderInput) (*CreateOrderOutput, error)
}
```

**Use Case Implementation:**

```go
package usecase

import (
    "context"
    "fmt"
    "github.com/kharisma/api/internal/domain"
)

type createOrderImpl struct {
    orderRepo    domain.OrderRepository
    customerRepo domain.CustomerRepository
    pricingRepo  domain.PricingRepository
}

func NewCreateOrderUseCase(
    orderRepo domain.OrderRepository,
    customerRepo domain.CustomerRepository,
    pricingRepo domain.PricingRepository,
) CreateOrderUseCase {
    return &createOrderImpl{
        orderRepo:    orderRepo,
        customerRepo: customerRepo,
        pricingRepo:  pricingRepo,
    }
}

func (u *createOrderImpl) Execute(ctx context.Context, input CreateOrderInput) (*CreateOrderOutput, error) {
    // 1. Validate customer exists
    customer, err := u.customerRepo.FindByID(ctx, input.CustomerID)
    if err != nil {
        return nil, fmt.Errorf("customer not found: %w", err)
    }

    // 2. Calculate pricing
    pricing, err := u.pricingRepo.CalculatePrice(ctx, domain.ServiceType(input.ServiceType))
    if err != nil {
        return nil, fmt.Errorf("pricing calculation failed: %w", err)
    }

    // 3. Create order
    order := &domain.Order{
        OrderNo:       u.generateOrderNo(),
        CustomerID:    customer.ID,
        ServiceType:   domain.ServiceType(input.ServiceType),
        SubtotalPrice: pricing.BasePrice,
        TotalPrice:    pricing.TotalPrice,
        Status:        domain.OrderPending,
    }

    // 4. Validate order
    if err := u.validateOrder(order); err != nil {
        return nil, fmt.Errorf("order validation failed: %w", err)
    }

    // 5. Persist
    if err := u.orderRepo.Save(ctx, order); err != nil {
        return nil, fmt.Errorf("failed to save order: %w", err)
    }

    return &CreateOrderOutput{
        OrderID:    order.ID,
        OrderNo:    order.OrderNo,
        TotalPrice: order.TotalPrice,
        Status:     string(order.Status),
    }, nil
}
```

---

## 4. Frontend Architecture (Vue 3)

### 4.1 Project Structure

```
kharisma-abadi-frontend/
├── src/
│   ├── views/                         # Page-level components
│   │   ├── HomeView.vue               # Home dashboard
│   │   ├── OrdersView.vue             # Orders list/management
│   │   ├── PaymentsView.vue           # Payments page
│   │   ├── ReportsView.vue            # Reports & analytics
│   │   ├── SettingsView.vue           # Admin settings
│   │   ├── LoginView.vue              # Authentication
│   │   └── 404View.vue                # Not found
│   │
│   ├── components/                    # Reusable UI components
│   │   ├── common/
│   │   │   ├── Header.vue             # Top navigation
│   │   │   ├── Sidebar.vue            # Left navigation
│   │   │   ├── Footer.vue             # Bottom footer
│   │   │   └── LoadingSpinner.vue     # Loading indicator
│   │   │
│   │   ├── forms/
│   │   │   ├── CarWashOrderForm.vue   # Car wash form
│   │   │   ├── LaundryOrderForm.vue   # Laundry form
│   │   │   ├── PaymentForm.vue        # Payment form
│   │   │   └── LoginForm.vue          # Login form
│   │   │
│   │   ├── orders/
│   │   │   ├── OrderList.vue          # Orders table
│   │   │   ├── OrderDetail.vue        # Order details modal
│   │   │   └── OrderStatusBadge.vue   # Status display
│   │   │
│   │   ├── payments/
│   │   │   ├── PaymentList.vue        # Payments table
│   │   │   ├── PaymentMethod.vue      # Payment type selector
│   │   │   └── Receipt.vue            # Receipt display
│   │   │
│   │   └── reports/
│   │       ├── DailySalesReport.vue   # Daily sales chart
│   │       ├── ServiceReport.vue      # Service analytics
│   │       └── RevenueChart.vue       # Revenue visualization
│   │
│   ├── stores/                        # Pinia state management
│   │   ├── useAuthStore.ts            # Authentication state
│   │   ├── useOrderStore.ts           # Orders state
│   │   ├── usePaymentStore.ts         # Payments state
│   │   ├── useUiStore.ts              # UI state (modals, notifications)
│   │   └── useReportStore.ts          # Reports state
│   │
│   ├── services/                      # API communication
│   │   ├── api.ts                     # Axios instance
│   │   ├── authService.ts             # Auth API calls
│   │   ├── orderService.ts            # Order API calls
│   │   ├── paymentService.ts          # Payment API calls
│   │   └── reportService.ts           # Report API calls
│   │
│   ├── router/                        # Vue Router configuration
│   │   ├── index.ts                   # Router setup
│   │   ├── routes.ts                  # Route definitions
│   │   └── guards.ts                  # Route guards
│   │
│   ├── types/                         # TypeScript interfaces
│   │   ├── auth.ts                    # Auth types
│   │   ├── order.ts                   # Order types
│   │   ├── payment.ts                 # Payment types
│   │   ├── customer.ts                # Customer types
│   │   ├── api.ts                     # API response types
│   │   └── index.ts                   # Export all types
│   │
│   ├── utils/                         # Utility functions
│   │   ├── formatters.ts              # Number, date formatting
│   │   ├── validators.ts              # Form validation
│   │   ├── constants.ts               # App constants
│   │   └── helpers.ts                 # Helper functions
│   │
│   ├── composables/                   # Vue composition functions
│   │   ├── useOrders.ts               # Orders logic
│   │   ├── usePayments.ts             # Payments logic
│   │   └── useNotification.ts         # Toast notifications
│   │
│   ├── assets/                        # Static assets
│   │   ├── styles/
│   │   │   ├── globals.css            # Global styles
│   │   │   └── tailwind.css           # Tailwind config
│   │   ├── images/
│   │   └── icons/
│   │
│   ├── App.vue                        # Root component
│   └── main.ts                        # Application entry point
│
├── tests/                             # Test files
│   ├── unit/
│   │   ├── components/
│   │   ├── stores/
│   │   └── utils/
│   ├── integration/
│   └── e2e/
│
├── public/                            # Public static files
├── .env.example                       # Example env vars
├── .eslintrc.cjs                      # ESLint config
├── .prettierrc                        # Prettier config
├── vite.config.ts                     # Vite config
├── tsconfig.json                      # TypeScript config
├── tailwind.config.js                 # Tailwind config
├── package.json
└── README.md
```

### 4.2 State Management (Pinia)

**Authentication Store:**

```typescript
// stores/useAuthStore.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types/auth'
import { authService } from '@/services/authService'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!user.value && !!token.value)

  const userRole = computed(() => user.value?.role)

  const hasPermission = (role: string) => userRole.value === role

  async function login(username: string, password: string) {
    isLoading.value = true
    error.value = null
    try {
      const response = await authService.login(username, password)
      token.value = response.accessToken
      user.value = response.user
      localStorage.setItem('token', response.accessToken)
    } catch (err: any) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  return {
    user,
    token,
    isLoading,
    error,
    isAuthenticated,
    userRole,
    hasPermission,
    login,
    logout,
  }
})
```

### 4.3 API Integration

**API Service Setup:**

```typescript
// services/api.ts
import axios, { AxiosInstance } from 'axios'
import { useAuthStore } from '@/stores/useAuthStore'

const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1'

export const api: AxiosInstance = axios.create({
  baseURL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use((config) => {
  const authStore = useAuthStore()
  if (authStore.token) {
    config.headers.Authorization = `Bearer ${authStore.token}`
  }
  return config
})

// Response interceptor
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired, redirect to login
      const authStore = useAuthStore()
      authStore.logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)
```

**Order Service:**

```typescript
// services/orderService.ts
import { api } from './api'
import type { Order, CreateOrderRequest } from '@/types/order'

export const orderService = {
  async getOrders(status?: string): Promise<Order[]> {
    const response = await api.get('/orders', {
      params: { status },
    })
    return response.data
  },

  async createOrder(data: CreateOrderRequest): Promise<Order> {
    const response = await api.post('/orders', data)
    return response.data
  },

  async updateOrder(id: number, data: Partial<CreateOrderRequest>): Promise<Order> {
    const response = await api.patch(`/orders/${id}`, data)
    return response.data
  },

  async completeOrder(id: number): Promise<Order> {
    const response = await api.post(`/orders/${id}/complete`)
    return response.data
  },
}
```

---

## 5. Database Design

### 5.1 Core Tables

**Users Table:**

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'manager', 'cashier', 'service_staff', 'viewer') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Customers Table:**

```sql
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    customer_type ENUM('regular', 'vip', 'corporate') DEFAULT 'regular',
    membership_number VARCHAR(50),
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_phone (phone),
    INDEX idx_customer_type (customer_type),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Orders Table:**

```sql
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    service_type ENUM('car_wash', 'laundry', 'carpet', 'water_delivery') NOT NULL,
    status ENUM('pending', 'in_progress', 'quality_check', 'completed', 
                'awaiting_payment', 'paid', 'cancelled', 'closed') DEFAULT 'pending',
    subtotal_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_order_number (order_number),
    INDEX idx_customer_id (customer_id),
    INDEX idx_service_type (service_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at DESC),
    INDEX idx_customer_date (customer_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Payments Table:**

```sql
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method ENUM('cash', 'bank_transfer', 'ewallet', 'card') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',
    transaction_id VARCHAR(100),
    notes TEXT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_order_id (order_id),
    INDEX idx_payment_method (payment_method),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 5.2 Indexing Strategy

**Performance Indexes:**

```sql
-- Common queries
CREATE INDEX idx_orders_pending ON orders(status, created_at DESC) WHERE status IN ('pending', 'in_progress');
CREATE INDEX idx_payments_by_date ON payments(created_at DESC, status);
CREATE INDEX idx_customers_active ON customers(is_active, created_at DESC);

-- Search indexes
CREATE FULLTEXT INDEX ft_customers_name ON customers(name);
CREATE FULLTEXT INDEX ft_customers_phone ON customers(phone);
```

### 5.3 Data Integrity

**Foreign Key Constraints:**

```sql
ALTER TABLE orders ADD CONSTRAINT fk_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT;
ALTER TABLE orders ADD CONSTRAINT fk_orders_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT;
ALTER TABLE payments ADD CONSTRAINT fk_payments_order 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
```

**Check Constraints:**

```sql
ALTER TABLE orders ADD CONSTRAINT chk_amounts_positive 
    CHECK (total_amount >= 0 AND subtotal_price >= 0 AND tax_amount >= 0);
ALTER TABLE payments ADD CONSTRAINT chk_payment_amount 
    CHECK (amount > 0);
ALTER TABLE customers ADD CONSTRAINT chk_discount_range 
    CHECK (discount_percentage >= 0 AND discount_percentage <= 100);
```

---

## 6. API Specification

### 6.1 API Overview

**Base URL:** `/api/v1`  
**Authentication:** Bearer Token (JWT)  
**Response Format:** JSON  
**Status Codes:** Standard HTTP (200, 201, 400, 401, 403, 404, 500)

### 6.2 Authentication Endpoints

**POST /auth/login**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 1800,
    "user": {
      "id": 1,
      "username": "user@example.com",
      "full_name": "John Doe",
      "role": "cashier",
      "email": "user@example.com"
    }
  }
}
```

**POST /auth/logout**

```http
POST /api/v1/auth/logout
Authorization: Bearer {access_token}

Response (200 OK):
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 6.3 Order Endpoints

**POST /orders**

```http
POST /api/v1/orders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "customer_id": 1,
  "service_type": "car_wash",
  "subtotal_price": 50000,
  "discount_amount": 0,
  "tax_amount": 5000,
  "total_amount": 55000,
  "notes": "Special request: extra wax"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "customer_id": 1,
    "service_type": "car_wash",
    "status": "pending",
    "subtotal_price": 50000,
    "discount_amount": 0,
    "tax_amount": 5000,
    "total_amount": 55000,
    "created_at": "2025-10-22T10:30:00Z",
    "created_by": 1
  }
}
```

**GET /orders**

```http
GET /api/v1/orders?status=pending&limit=10&offset=0
Authorization: Bearer {access_token}

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "ORD-20251022-001",
      "customer_id": 1,
      "service_type": "car_wash",
      "status": "pending",
      "total_amount": 55000,
      "created_at": "2025-10-22T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "total_pages": 3
  }
}
```

**GET /orders/{id}**

```http
GET /api/v1/orders/1
Authorization: Bearer {access_token}

Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "customer_id": 1,
    "customer": {
      "id": 1,
      "name": "John Doe",
      "phone": "+62812345678"
    },
    "service_type": "car_wash",
    "status": "pending",
    "subtotal_price": 50000,
    "discount_amount": 0,
    "tax_amount": 5000,
    "total_amount": 55000,
    "notes": "Special request: extra wax",
    "created_at": "2025-10-22T10:30:00Z",
    "created_by": 1
  }
}
```

**PATCH /orders/{id}**

```http
PATCH /api/v1/orders/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "status": "in_progress",
  "notes": "Service started"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "status": "in_progress",
    "updated_at": "2025-10-22T10:45:00Z"
  }
}
```

### 6.4 Payment Endpoints

**POST /payments**

```http
POST /api/v1/payments
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "order_id": 1,
  "payment_method": "cash",
  "amount": 55000,
  "notes": "Full payment"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "payment_method": "cash",
    "amount": 55000,
    "status": "completed",
    "created_at": "2025-10-22T11:00:00Z"
  }
}
```

### 6.5 Error Responses

**400 Bad Request:**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "total_amount",
        "message": "total_amount must be greater than 0"
      }
    ]
  }
}
```

**401 Unauthorized:**

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Missing or invalid token"
  }
}
```

**403 Forbidden:**

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions for this action"
  }
}
```

**404 Not Found:**

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Resource not found"
  }
}
```

---

## 7. Security Specification

### 7.1 Authentication & Authorization

**JWT Implementation:**

- Token Type: HS256
- Access Token Expiry: 30 minutes
- Refresh Token Expiry: 7 days
- Storage: localStorage (frontend), Bearer header (API)

**Role-Based Access Control:**

```go
type UserRole string

const (
    RoleAdmin        UserRole = "ADMIN"        // Full system access
    RoleManager      UserRole = "MANAGER"      // Management operations
    RoleCashier      UserRole = "CASHIER"      // Order creation & payment
    RoleServiceStaff UserRole = "SERVICE_STAFF" // Service execution
    RoleViewer       UserRole = "VIEWER"       // Read-only access
)

// Example: Only cashier or manager can create orders
@Router /orders [post]
@Security Bearer
@RequireRole("cashier", "manager", "admin")
func CreateOrder(c *fiber.Ctx) error {
    // Implementation
}
```

### 7.2 Data Security

**Password Security:**
- Algorithm: bcrypt with 12 rounds
- Minimum: 8 characters
- Requirements: Mix of uppercase, lowercase, numbers, special chars

**Sensitive Data:**
- Payment info: Encrypted at rest
- Personal info: Access controlled by role
- Audit logs: Immutable records

**SQL Injection Prevention:**
- GORM ORM prevents SQL injection
- Parameterized queries
- Input validation before persistence

**XSS Protection:**
- Input sanitization
- Output encoding
- Content Security Policy headers

### 7.3 API Security

**HTTPS:**
- Enforced in production
- Certificate: Let's Encrypt
- HSTS header enabled

**CORS:**
- Whitelist trusted origins
- Allow only necessary methods
- Restrict headers

**Rate Limiting:**
- 100 requests/minute per IP
- 1000 requests/hour per user
- Graduated backoff

### 7.4 Audit Trail

**Logged Events:**
- User authentication (login/logout)
- Order creation/modification
- Payment processing
- User role changes
- System configuration changes

```sql
CREATE TABLE audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_type VARCHAR(50) NOT NULL,
    user_id INT,
    resource_type VARCHAR(50),
    resource_id INT,
    action VARCHAR(10),
    old_value JSON,
    new_value JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_resource (resource_type, resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 8. Testing Strategy

### 8.1 Test Pyramid

**Unit Tests (70%):**
- Domain logic
- Use cases
- Utility functions
- Target: >85% coverage

**Integration Tests (20%):**
- API endpoints
- Database operations
- Service interactions
- Mocked external services

**E2E Tests (10%):**
- Critical user flows
- Order → Payment → Receipt
- Auth flows

### 8.2 Backend Testing (Go)

**Unit Test Example:**

```go
// tests/unit/domain/order_test.go
package domain_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/kharisma/api/internal/domain"
    "github.com/shopspring/decimal"
)

func TestOrderApplyDiscount(t *testing.T) {
    order := &domain.Order{
        SubtotalPrice: decimal.NewFromFloat(100.00),
        TotalPrice:    decimal.NewFromFloat(100.00),
    }

    discount := decimal.NewFromFloat(10.00)
    err := order.ApplyDiscount(discount)

    assert.NoError(t, err)
    assert.Equal(t, decimal.NewFromFloat(90.00), order.TotalPrice)
    assert.Equal(t, discount, order.DiscountAmount)
}

func TestOrderCannotTransitionInvalidState(t *testing.T) {
    order := &domain.Order{
        Status: domain.OrderPending,
    }

    can := order.CanTransitionTo(domain.OrderPaid)
    assert.False(t, can)
}
```

**Integration Test Example:**

```go
// tests/integration/handler/order_handler_test.go
package handler_test

import (
    "testing"
    "bytes"
    "encoding/json"
    "github.com/gofiber/fiber/v2"
    "github.com/stretchr/testify/assert"
)

func TestCreateOrderHandler(t *testing.T) {
    app := fiber.New()
    // Setup routes and database
    
    orderPayload := map[string]interface{}{
        "customer_id":    1,
        "service_type":   "car_wash",
        "total_amount":   50000,
    }

    body, _ := json.Marshal(orderPayload)
    req := app.Test(&http.Request{
        Method:  "POST",
        URL:     "http://localhost:3000/api/v1/orders",
        Header:  http.Header{"Authorization": []string{"Bearer " + token}},
        Body:    bytes.NewBuffer(body),
    })

    assert.Equal(t, fiber.StatusCreated, req.StatusCode)
}
```

### 8.3 Frontend Testing (Vue 3)

**Component Test Example:**

```typescript
// tests/unit/components/OrderList.spec.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import OrderList from '@/components/orders/OrderList.vue'
import { createPinia } from 'pinia'

describe('OrderList.vue', () => {
  let wrapper: any

  beforeEach(() => {
    const pinia = createPinia()
    wrapper = mount(OrderList, {
      global: {
        plugins: [pinia],
      },
    })
  })

  it('renders order list', () => {
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('displays loading state', async () => {
    await wrapper.vm.fetchOrders()
    expect(wrapper.find('.loading').exists()).toBe(false)
  })

  it('displays error on fetch failure', async () => {
    const store = useOrderStore()
    store.error = 'Failed to load orders'
    await wrapper.vm.$nextTick()
    expect(wrapper.text()).toContain('Failed to load orders')
  })
})
```

---

## 9. Deployment Architecture

### 9.1 Docker Containers

**Backend Container (Go):**

```dockerfile
# Multi-stage build for minimal size
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o kharisma-api ./cmd/server/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/kharisma-api /app/
EXPOSE 3000
CMD ["/app/kharisma-api"]
```

**Image Size:** ~50-80MB

**Frontend Container (Vue 3):**

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Image Size:** ~40-60MB

### 9.2 Docker Compose (Production)

```yaml
version: '3.8'

services:
  mariadb:
    image: mariadb:11
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
      - ./backups:/backups
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10

  api:
    image: kharisma/api:latest
    restart: always
    ports:
      - "3000:3000"
    depends_on:
      mariadb:
        condition: service_healthy
    environment:
      DB_HOST: mariadb
      DB_PORT: 3306
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      API_PORT: 3000
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  frontend:
    image: kharisma/frontend:latest
    restart: always
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - api
    environment:
      VITE_API_URL: http://api:3000/api/v1
    volumes:
      - ./ssl:/etc/nginx/ssl

volumes:
  db_data:
```

### 9.3 Deployment Checklist

- [ ] Environment variables configured (.env)
- [ ] SSL certificates obtained (Let's Encrypt)
- [ ] Database backups configured
- [ ] Monitoring setup (logs, health checks)
- [ ] Load testing completed
- [ ] Security audit passed
- [ ] Staff training completed
- [ ] Rollback plan documented

---

## Summary

This technical specification provides a complete blueprint for implementing the Kharisma Abadi application with:

✅ **Go + Fiber** backend for maximum performance (10x faster)  
✅ **Vue 3** frontend for small-team productivity  
✅ **Clean Architecture** for maintainability  
✅ **GORM** ORM for type-safe data access  
✅ **Docker** containerization for easy deployment  
✅ **Comprehensive security** with JWT, RBAC, audit logging  
✅ **Extensive testing** strategy with unit, integration, E2E tests  

All developers should use this specification as the source of truth during implementation.
