# Technical Architecture - Go Backend & Lightweight Frontend

**Document Version:** 1.0  
**Date:** October 2025  
**Technology Stack:** Go Backend + Lightweight Frontend  
**Deployment Target:** Windows Docker, Small Team Environment

---

## Table of Contents

1. [Backend Architecture (Go)](#backend-architecture-go)
2. [Frontend Recommendations](#frontend-recommendations)
3. [Technology Stack Comparison](#technology-stack-comparison)
4. [Development Environment](#development-environment)
5. [Deployment Strategy](#deployment-strategy)
6. [Performance Optimization](#performance-optimization)

---

## Backend Architecture (Go)

### 1.1 Why Go Language?

**Advantages for This Project:**

| Aspect | Benefit |
|--------|---------|
| **Binary Size** | Single executable (~20-50MB vs Python runtime 100MB+) |
| **Performance** | Compiled language, 10-100x faster than Python |
| **Memory Usage** | Efficient garbage collection, lower footprint |
| **Concurrency** | Goroutines enable handling thousands of concurrent connections |
| **Deployment** | Single binary, no runtime dependencies (perfect for Docker) |
| **Cross-Platform** | Easily compile for different OS (Linux, Windows, macOS) |
| **Learning Curve** | Simple, readable syntax - easier team onboarding |
| **Production Ready** | Used in production by Netflix, Uber, Docker, Kubernetes |
| **Windows Docker** | Excellent support for Windows containers |

### 1.2 Go Framework Selection

**Recommended Framework: Fiber**

We recommend **Fiber** over alternatives (Gin, Echo) because:

#### Fiber Advantages:
- **Fastest Go web framework** (benchmarks show 2-3x faster than Echo)
- **Express.js-like API** (familiar syntax for developers)
- **Lightweight** (~4MB binary)
- **Built-in middleware** (compression, CORS, validation)
- **Excellent Windows support** (runs flawlessly on Windows containers)
- **Production-tested** (used by large companies)
- **Active development** (well-maintained, regular updates)

**Framework Comparison:**

```
┌─────────────┬──────────────┬─────────────┬──────────────┐
│ Framework   │ Performance  │ Binary Size │ Ease of Use  │
├─────────────┼──────────────┼─────────────┼──────────────┤
│ Fiber       │ ⭐⭐⭐⭐⭐ │ ~4MB        │ ⭐⭐⭐⭐⭐ │
│ Echo        │ ⭐⭐⭐⭐   │ ~5MB        │ ⭐⭐⭐⭐   │
│ Gin         │ ⭐⭐⭐⭐   │ ~6MB        │ ⭐⭐⭐⭐   │
│ Chi         │ ⭐⭐⭐⭐   │ ~8MB        │ ⭐⭐⭐   │
│ GORM+Mux   │ ⭐⭐⭐     │ ~10MB       │ ⭐⭐⭐   │
└─────────────┴──────────────┴─────────────┴──────────────┘
```

#### Fiber Code Example:
```go
package main

import "github.com/gofiber/fiber/v2"

func main() {
    app := fiber.New(fiber.Config{
        Prefork:       false,
        CaseSensitive: true,
        StrictRoute:   true,
    })

    // Middleware
    app.Use(middleware.Logger())
    app.Use(middleware.Compress())

    // Routes
    app.Get("/api/v1/orders", handlers.GetOrders)
    app.Post("/api/v1/orders", handlers.CreateOrder)
    app.Put("/api/v1/orders/:id", handlers.UpdateOrder)
    app.Delete("/api/v1/orders/:id", handlers.DeleteOrder)

    app.Listen(":3000")
}
```

### 1.3 Database & ORM

**Database:** MariaDB/MySQL (existing, preserved from current system)

**ORM Selection: GORM**

GORM is the de facto standard for Go database operations:

**GORM Advantages:**
- **Full-featured ORM** - Migrations, associations, hooks
- **Type-safe queries** - Compile-time type checking
- **Query builder** - Chainable, readable query syntax
- **Performance** - Minimal overhead, excellent query optimization
- **Database support** - Works perfectly with MariaDB
- **Excellent documentation** - Clear examples and patterns

**GORM Code Example:**
```go
type Order struct {
    ID        uint      `gorm:"primaryKey"`
    OrderNo   string    `gorm:"uniqueIndex"`
    CustomerID uint     `gorm:"index"`
    Customer  *Customer `gorm:"foreignKey:CustomerID"`
    TotalPrice decimal.Decimal
    Status    string
    CreatedAt time.Time
}

// Query example
var orders []Order
db.Where("status = ?", "PENDING").
   Preload("Customer").
   Order("created_at DESC").
   Limit(10).
   Find(&orders)
```

### 1.4 Schema Migrations

**Tool: golang-migrate**

```go
// Installation
go get -u github.com/golang-migrate/migrate/v4/cmd/migrate

// Usage
// migrate -path ./migrations -database "mysql://user:pass@tcp(localhost:3306)/db" up
```

**Migration File Structure:**
```
migrations/
├── 001_create_orders_table.up.sql
├── 001_create_orders_table.down.sql
├── 002_create_payments_table.up.sql
├── 002_create_payments_table.down.sql
└── 003_add_indexes.up.sql
```

### 1.5 API Specification & Documentation

**OpenAPI/Swagger Integration**

Use **swaggo** for automatic API documentation generation:

```go
import "github.com/swaggo/swag"
import "github.com/swaggo/gin-swagger"

// Installation
go get -u github.com/swaggo/swag/cmd/swag

// Generate docs
swag init

// Then access at http://localhost:3000/swagger/index.html
```

**Endpoint Documentation Example:**
```go
// @BasePath /api/v1
// @Schemes http https

// CreateOrder creates a new service order
// @Summary Create order
// @Description Creates a new car wash, laundry, carpet, or water delivery order
// @Tags orders
// @Accept json
// @Produce json
// @Param order body OrderRequest true "Order details"
// @Success 201 {object} OrderResponse
// @Failure 400 {object} ErrorResponse
// @Router /orders [post]
func CreateOrder(c *fiber.Ctx) error {
    // Implementation
}
```

### 1.6 Authentication & Authorization

**JWT Implementation**

```go
import "github.com/golang-jwt/jwt/v5"

type Claims struct {
    UserID   uint
    Username string
    Role     string
    jwt.RegisteredClaims
}

// Middleware for authentication
func AuthMiddleware(c *fiber.Ctx) error {
    token := c.Get("Authorization")
    // Validate token
    claims, err := ValidateToken(token)
    if err != nil {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "Invalid token",
        })
    }
    c.Locals("user", claims)
    return c.Next()
}

// Middleware for authorization
func RequireRole(role string) fiber.Handler {
    return func(c *fiber.Ctx) error {
        claims := c.Locals("user").(Claims)
        if claims.Role != role {
            return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
                "error": "Insufficient permissions",
            })
        }
        return c.Next()
    }
}
```

### 1.7 Input Validation

**Library: Validator**

```go
import "github.com/go-playground/validator/v10"

type CreateOrderRequest struct {
    CustomerID uint   `json:"customer_id" validate:"required"`
    ServiceType string `json:"service_type" validate:"required,oneof=CAR_WASH LAUNDRY CARPET WATER"`
    TotalPrice  decimal.Decimal `json:"total_price" validate:"required,gt=0"`
}

// Validation middleware
func ValidateRequest(data interface{}) error {
    validate := validator.New()
    return validate.Struct(data)
}
```

### 1.8 Error Handling

**Standardized Error Response:**

```go
type ErrorResponse struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Details map[string]interface{} `json:"details,omitempty"`
}

func ErrorHandler(c *fiber.Ctx, err error) error {
    if err == nil {
        return nil
    }

    code := fiber.StatusInternalServerError
    message := "Internal Server Error"

    // Handle specific error types
    if validationErr, ok := err.(validator.ValidationErrors); ok {
        code = fiber.StatusBadRequest
        message = "Validation failed"
        details := make(map[string]interface{})
        for _, fieldErr := range validationErr {
            details[fieldErr.Field()] = fieldErr.Error()
        }
        return c.Status(code).JSON(ErrorResponse{
            Code:    "VALIDATION_ERROR",
            Message: message,
            Details: details,
        })
    }

    return c.Status(code).JSON(ErrorResponse{
        Code:    "INTERNAL_ERROR",
        Message: message,
    })
}

app.ErrorHandler = ErrorHandler
```

### 1.9 Testing Strategy

**Go Standard Testing + Testify**

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestCreateOrder(t *testing.T) {
    // Setup
    db := setupTestDB()
    defer db.Cleanup()

    // Test data
    orderReq := CreateOrderRequest{
        CustomerID: 1,
        ServiceType: "CAR_WASH",
        TotalPrice: decimal.NewFromFloat(50.00),
    }

    // Execute
    order, err := CreateOrder(db, orderReq)

    // Assert
    require.NoError(t, err)
    assert.Equal(t, "PENDING", order.Status)
    assert.NotZero(t, order.ID)
}

// Run tests
// go test ./... -v
// go test ./... -cover  # With coverage
// go test -race ./...   # Race condition detection
```

### 1.10 Project Structure

**Recommended Directory Layout:**

```
kharisma-abadi-go/
├── cmd/
│   └── server/
│       └── main.go                 # Application entry point
├── internal/
│   ├── domain/                     # Business logic (entities, interfaces)
│   │   ├── order.go
│   │   ├── customer.go
│   │   ├── payment.go
│   │   └── repositories.go         # Repository interfaces
│   ├── repository/                 # Data access layer (GORM)
│   │   ├── order_repository.go
│   │   ├── customer_repository.go
│   │   └── payment_repository.go
│   ├── usecase/                    # Business logic (use cases)
│   │   ├── create_order.go
│   │   ├── process_payment.go
│   │   └── generate_report.go
│   ├── handler/                    # HTTP handlers (API endpoints)
│   │   ├── order_handler.go
│   │   ├── payment_handler.go
│   │   ├── customer_handler.go
│   │   └── auth_handler.go
│   ├── middleware/                 # HTTP middleware
│   │   ├── auth.go
│   │   ├── error_handler.go
│   │   └── logger.go
│   ├── config/                     # Configuration management
│   │   └── config.go
│   └── infrastructure/             # External services
│       ├── database.go
│       ├── sms_gateway.go
│       └── payment_gateway.go
├── migrations/                     # Database migrations
│   ├── 001_create_orders.up.sql
│   └── 001_create_orders.down.sql
├── tests/                          # Integration tests
│   ├── order_test.go
│   └── payment_test.go
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── go.mod                          # Go module definition
├── go.sum                          # Go dependencies lock file
├── Makefile                        # Build automation
└── README.md                       # Documentation
```

**Architecture Layers (Clean Architecture):**

```
┌─────────────────────────────────────────┐
│           HTTP Handlers (API)           │  ← External Interface
├─────────────────────────────────────────┤
│          Middleware & Routing           │
├─────────────────────────────────────────┤
│   Use Cases (Business Logic)            │  ← Application Layer
├─────────────────────────────────────────┤
│   Domain (Entities, Interfaces)         │  ← Core Domain
├─────────────────────────────────────────┤
│   Repository (Data Access)              │  ← Infrastructure
├─────────────────────────────────────────┤
│   Database, External APIs               │
└─────────────────────────────────────────┘
```

### 1.11 Dependency Management

**go.mod Example:**

```
module github.com/kharisma/kharisma-abadi-go

go 1.21

require (
    github.com/gofiber/fiber/v2 v2.50.0
    github.com/gorm.io/gorm v1.25.5
    github.com/gorm.io/driver/mysql v1.5.2
    github.com/golang-jwt/jwt/v5 v5.0.0
    github.com/golang-migrate/migrate/v4 v4.16.2
    github.com/shopspring/decimal v1.3.1
    github.com/joho/godotenv v1.5.1
    github.com/go-playground/validator/v10 v10.16.0
)
```

---

## Frontend Recommendations

### 2.1 Frontend Framework Selection

**Our Recommendation: Vue 3 (Composition API)**

We recommend **Vue 3** over React/Next.js for this project because:

| Criteria | Vue 3 | React | Svelte | HTMX |
|----------|-------|-------|--------|------|
| **Bundle Size** | 33KB | 42KB | 12KB | 10KB |
| **Learning Curve** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Performance** | Excellent | Good | Excellent | Excellent |
| **Small Team** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Windows Support** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Type Safety** | TypeScript | TypeScript | TypeScript | No |
| **Production Ready** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

**Why Vue 3?**

1. **Smaller bundle** (33KB vs React 42KB)
2. **Easier to learn** - Cleaner syntax, shorter learning curve
3. **Better for small teams** - Less boilerplate, faster development
4. **Excellent Windows Docker support**
5. **Progressive enhancement** - Works with minimal setup
6. **Single File Components** - Everything in one .vue file
7. **Built-in animation support**
8. **Outstanding documentation** - Arguably best in ecosystem
9. **No build step required** for simple projects (can use CDN)

### 2.2 Alternative Options

**Option 1: Svelte (Ultra-Lightweight)**
- **Use if:** You want absolute smallest bundle (<15KB)
- **Trade-off:** Less mature ecosystem, smaller community
- **Best for:** Very lightweight deployments
- Bundle: 12KB
- Example: `svelte-add` for rapid scaffolding

**Option 2: HTMX + Go Templates (Simplest)**
- **Use if:** You want absolute minimal complexity
- **Approach:** Render HTML server-side with Go, enhance with HTMX
- **Trade-off:** Less SPA feel, more traditional MPA architecture
- **Best for:** Small team, maximum simplicity
- Bundle: 10KB (HTMX only)

**Recommendation: Start with Vue 3, consider HTMX for future simplification**

We recommend Vue 3 as the optimal balance. If you find complexity becoming an issue, Svelte or HTMX+Go templates are natural fallbacks.

### 2.3 Complete Vue 3 Stack

**Frontend Technology Stack:**

```
┌────────────────────────────────────────────┐
│           Vue 3 (Composition API)          │
├────────────────────────────────────────────┤
│         TypeScript + Vite Build            │
├────────────────────────────────────────────┤
│  State Management: Pinia (Vue 3 store)     │
├────────────────────────────────────────────┤
│   Routing: Vue Router v4                   │
├────────────────────────────────────────────┤
│   Styling: Tailwind CSS + PostCSS          │
├────────────────────────────────────────────┤
│   Form Handling: VeeValidate v4            │
├────────────────────────────────────────────┤
│   HTTP Client: Axios or Fetch API          │
├────────────────────────────────────────────┤
│   UI Components: Headless UI               │
└────────────────────────────────────────────┘
```

### 2.4 Vue 3 Project Setup

**Installation & Setup:**

```bash
# Create new Vue 3 project with Vite
npm create vite@latest kharisma-abadi-frontend -- --template vue

# Or with TypeScript
npm create vite@latest kharisma-abadi-frontend -- --template vue-ts

# Navigate to project
cd kharisma-abadi-frontend

# Install dependencies
npm install

# Install additional packages
npm install -D tailwindcss postcss autoprefixer
npm install pinia vue-router axios
npm install @vee-validate/vue @vee-validate/rules yup

# Start development server
npm run dev
```

### 2.5 Project Structure (Vue 3)

```
kharisma-abadi-frontend/
├── public/
│   └── favicon.ico
├── src/
│   ├── assets/                    # Images, fonts, static files
│   │   └── styles/
│   │       └── tailwind.css
│   ├── components/                # Reusable Vue components
│   │   ├── common/
│   │   │   ├── Header.vue
│   │   │   ├── Navigation.vue
│   │   │   └── Footer.vue
│   │   ├── orders/
│   │   │   ├── OrderForm.vue
│   │   │   ├── OrderList.vue
│   │   │   └── OrderDetail.vue
│   │   ├── payments/
│   │   │   ├── PaymentForm.vue
│   │   │   └── PaymentStatus.vue
│   │   └── reports/
│   │       ├── DailySalesReport.vue
│   │       └── ServiceReport.vue
│   ├── views/                     # Page-level components
│   │   ├── HomeView.vue
│   │   ├── OrdersView.vue
│   │   ├── PaymentsView.vue
│   │   ├── ReportsView.vue
│   │   └── SettingsView.vue
│   ├── stores/                    # Pinia state management
│   │   ├── useAuthStore.ts
│   │   ├── useOrderStore.ts
│   │   └── usePaymentStore.ts
│   ├── services/                  # API client services
│   │   ├── api.ts                 # Axios configuration
│   │   ├── authService.ts
│   │   ├── orderService.ts
│   │   └── paymentService.ts
│   ├── router/                    # Vue Router configuration
│   │   └── index.ts
│   ├── types/                     # TypeScript interfaces
│   │   ├── order.ts
│   │   ├── customer.ts
│   │   ├── payment.ts
│   │   └── api.ts
│   ├── utils/                     # Utility functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── helpers.ts
│   ├── App.vue                    # Root component
│   └── main.ts                    # Application entry point
├── .env.example                   # Environment variables template
├── .eslintrc.cjs                  # ESLint configuration
├── .prettierrc                    # Prettier configuration
├── tailwind.config.js             # Tailwind CSS configuration
├── vite.config.ts                 # Vite build configuration
├── tsconfig.json                  # TypeScript configuration
├── package.json
└── README.md
```

### 2.6 Vue 3 Code Examples

**API Service (services/orderService.ts):**

```typescript
import axios from 'axios'
import type { Order, CreateOrderRequest, OrderResponse } from '@/types/order'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1',
})

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export const orderService = {
  getOrders(status?: string): Promise<Order[]> {
    return api.get('/orders', { params: { status } }).then(res => res.data)
  },

  getOrder(id: number): Promise<Order> {
    return api.get(`/orders/${id}`).then(res => res.data)
  },

  createOrder(data: CreateOrderRequest): Promise<OrderResponse> {
    return api.post('/orders', data).then(res => res.data)
  },

  updateOrder(id: number, data: Partial<CreateOrderRequest>): Promise<Order> {
    return api.put(`/orders/${id}`, data).then(res => res.data)
  },

  deleteOrder(id: number): Promise<void> {
    return api.delete(`/orders/${id}`)
  },
}
```

**Pinia Store (stores/useOrderStore.ts):**

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { orderService } from '@/services/orderService'
import type { Order } from '@/types/order'

export const useOrderStore = defineStore('order', () => {
  const orders = ref<Order[]>([])
  const selectedOrder = ref<Order | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const pendingOrders = computed(() =>
    orders.value.filter(o => o.status === 'PENDING')
  )

  const completedOrders = computed(() =>
    orders.value.filter(o => o.status === 'CLOSED')
  )

  async function fetchOrders(status?: string) {
    loading.value = true
    try {
      orders.value = await orderService.getOrders(status)
      error.value = null
    } catch (err) {
      error.value = 'Failed to fetch orders'
      console.error(err)
    } finally {
      loading.value = false
    }
  }

  async function createOrder(data: any) {
    loading.value = true
    try {
      const newOrder = await orderService.createOrder(data)
      orders.value.push(newOrder as Order)
      return newOrder
    } catch (err) {
      error.value = 'Failed to create order'
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    orders,
    selectedOrder,
    loading,
    error,
    pendingOrders,
    completedOrders,
    fetchOrders,
    createOrder,
  }
})
```

**Vue Component Example (components/orders/OrderForm.vue):**

```vue
<template>
  <form @submit.prevent="submitForm" class="space-y-6">
    <!-- Customer Selection -->
    <div>
      <label class="block text-sm font-medium text-gray-700">Customer</label>
      <select
        v-model="form.customerId"
        class="mt-1 block w-full rounded-md border-gray-300"
        required
      >
        <option value="">Select customer...</option>
        <option v-for="customer in customers" :key="customer.id" :value="customer.id">
          {{ customer.name }}
        </option>
      </select>
      <ErrorMessage name="customerId" />
    </div>

    <!-- Service Type -->
    <div>
      <label class="block text-sm font-medium text-gray-700">Service Type</label>
      <select
        v-model="form.serviceType"
        class="mt-1 block w-full rounded-md border-gray-300"
        required
      >
        <option value="">Select service...</option>
        <option value="CAR_WASH">Car Wash</option>
        <option value="LAUNDRY">Laundry</option>
        <option value="CARPET">Carpet Washing</option>
        <option value="WATER">Water Delivery</option>
      </select>
    </div>

    <!-- Price -->
    <div>
      <label class="block text-sm font-medium text-gray-700">Total Price</label>
      <input
        v-model="form.totalPrice"
        type="number"
        step="0.01"
        class="mt-1 block w-full rounded-md border-gray-300"
        required
      />
      <ErrorMessage name="totalPrice" />
    </div>

    <!-- Submit Button -->
    <button
      type="submit"
      :disabled="loading"
      class="inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50"
    >
      {{ loading ? 'Creating...' : 'Create Order' }}
    </button>
  </form>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useForm, ErrorMessage } from 'vee-validate'
import * as yup from 'yup'
import { useOrderStore } from '@/stores/useOrderStore'

const orderStore = useOrderStore()
const loading = ref(false)
const customers = ref([])

const validationSchema = yup.object({
  customerId: yup.number().required('Customer is required'),
  serviceType: yup.string().required('Service type is required'),
  totalPrice: yup.number().positive().required('Price is required'),
})

const { handleSubmit, resetForm } = useForm({
  validationSchema,
  initialValues: {
    customerId: '',
    serviceType: '',
    totalPrice: '',
  },
})

const form = reactive({
  customerId: '',
  serviceType: '',
  totalPrice: '',
})

const submitForm = handleSubmit(async (values) => {
  loading.value = true
  try {
    await orderStore.createOrder(values)
    resetForm()
    // Show success message
  } catch (error) {
    console.error('Failed to create order:', error)
  } finally {
    loading.value = false
  }
})
</script>
```

### 2.7 Styling Strategy

**Tailwind CSS + PostCSS**

**Configuration (tailwind.config.js):**

```javascript
export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors
        primary: '#3b82f6',
        secondary: '#10b981',
        danger: '#ef4444',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

**Optimization for Small Bundle:**

```javascript
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
      },
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-core': ['vue', 'vue-router', 'pinia'],
        },
      },
    },
  },
})
```

### 2.8 Testing Strategy (Frontend)

**Vitest + Vue Test Utils**

```typescript
// tests/components/OrderForm.spec.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import OrderForm from '@/components/orders/OrderForm.vue'

describe('OrderForm.vue', () => {
  let wrapper: any

  beforeEach(() => {
    wrapper = mount(OrderForm)
  })

  it('renders form with all fields', () => {
    expect(wrapper.find('select[name="customerId"]').exists()).toBe(true)
    expect(wrapper.find('select[name="serviceType"]').exists()).toBe(true)
    expect(wrapper.find('input[type="number"]').exists()).toBe(true)
  })

  it('submits form with valid data', async () => {
    const mockSubmit = vi.fn()
    await wrapper.vm.handleSubmit = mockSubmit

    await wrapper.find('input[type="number"]').setValue('50.00')
    await wrapper.find('form').trigger('submit')

    expect(mockSubmit).toHaveBeenCalled()
  })

  it('shows validation errors for empty fields', async () => {
    await wrapper.find('form').trigger('submit')
    expect(wrapper.text()).toContain('required')
  })
})
```

---

## Technology Stack Comparison

### 3.1 Backend: Go vs Python

```
┌──────────────────┬──────────────┬──────────────┬─────────────┐
│ Metric           │ Go (Fiber)   │ Python (FAP) │ Advantage   │
├──────────────────┼──────────────┼──────────────┼─────────────┤
│ Binary Size      │ ~30MB        │ 150MB+       │ Go (5x)     │
│ Cold Start       │ <50ms        │ 200-500ms    │ Go (10x)    │
│ Memory (idle)    │ ~10MB        │ 50-100MB     │ Go (5x)     │
│ Throughput       │ 50k req/s    │ 5k req/s     │ Go (10x)    │
│ Goroutines       │ Millions     │ Threads      │ Go          │
│ CPU Usage        │ 2-5%         │ 10-20%       │ Go          │
│ Windows Support  │ Native       │ Good         │ Go          │
│ Docker Size      │ 50-80MB      │ 300-500MB    │ Go (5x)     │
└──────────────────┴──────────────┴──────────────┴─────────────┘
```

**For this project: Go is optimal** because:
- Excellent Windows Docker support
- Minimal resource usage (critical for small team deployment)
- High concurrency support (can handle many concurrent orders)
- Single binary deployment (no dependency hell)
- Faster API response times

### 3.2 Frontend: Vue 3 vs React vs Svelte

```
┌──────────────────┬──────────┬─────────┬────────┬───────┐
│ Metric           │ Vue 3    │ React   │ Svelte │ HTMX  │
├──────────────────┼──────────┼─────────┼────────┼───────┤
│ Bundle Size      │ 33KB     │ 42KB    │ 12KB   │ 10KB  │
│ Learning Curve   │ ⭐⭐⭐⭐ │ ⭐⭐⭐  │ ⭐⭐⭐⭐⭐│ ⭐⭐⭐⭐⭐│
│ Performance      │ Excellent│ Good    │ Best   │ Good  │
│ Ecosystem        │ Excellent│ Best    │ Growing│ Simple│
│ Team Size        │ 1-3 good │ 3+ best │ 1-2    │ 1     │
│ Windows          │ ⭐⭐⭐⭐⭐│ ⭐⭐⭐⭐⭐│ ⭐⭐⭐⭐⭐│ ⭐⭐⭐⭐⭐│
│ Maintenance      │ Easy     │ Complex │ Easy   │ Simple│
│ Complexity       │ Medium   │ High    │ Low    │ Very  │
└──────────────────┴──────────┴─────────┴────────┴───────┘
```

**For this project: Vue 3 is optimal** because:
- Small bundle size (good for lightweight requirement)
- Easier for small team to maintain
- Excellent Windows Docker support
- Progressive enhancement capability
- Outstanding documentation
- Balanced between simplicity and features

---

## Development Environment

### 4.1 Development Setup

**Prerequisites:**
- Go 1.21+
- Node.js 18+
- Docker & Docker Compose
- Git

**Environment Variables (.env):**

```bash
# Backend (.env)
DB_HOST=localhost
DB_PORT=3306
DB_USER=kharisma
DB_PASSWORD=secure_password
DB_NAME=kharisma_db
JWT_SECRET=your_jwt_secret_key
API_PORT=3000
ENV=development

# Frontend (.env.local)
VITE_API_URL=http://localhost:3000/api/v1
VITE_APP_NAME=Kharisma Abadi
```

### 4.2 Local Development Workflow

**Terminal 1 - Backend:**
```bash
cd backend
go run ./cmd/server/main.go
# Or with hot reload
go install github.com/cosmtrek/air@latest
air
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
# Runs on http://localhost:5173
```

**Terminal 3 - Database:**
```bash
docker-compose up -d mariadb
# Or full stack
docker-compose up -d
```

### 4.3 Docker Development Environment

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  mariadb:
    image: mariadb:11
    container_name: kharisma-db
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: kharisma_db
      MYSQL_USER: kharisma
      MYSQL_PASSWORD: kharisma_password
    volumes:
      - db_data:/var/lib/mysql
      - ./migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: kharisma-api
    ports:
      - "3000:3000"
    depends_on:
      mariadb:
        condition: service_healthy
    environment:
      DB_HOST: mariadb
      DB_PORT: 3306
      DB_USER: kharisma
      DB_PASSWORD: kharisma_password
      DB_NAME: kharisma_db
      API_PORT: 3000
    volumes:
      - ./backend:/app
    command: go run ./cmd/server/main.go

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: kharisma-ui
    ports:
      - "5173:5173"
    depends_on:
      - api
    environment:
      VITE_API_URL: http://localhost:3000/api/v1
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm run dev

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - mariadb

volumes:
  db_data:
```

**Dockerfile (Backend - Multi-stage for minimal size):**

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o kharisma-api ./cmd/server/main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/kharisma-api .

EXPOSE 3000

CMD ["./kharisma-api"]
```

**Result:** Final Docker image ~50-80MB (vs 300-500MB for Python)

---

## Deployment Strategy

### 5.1 Production Deployment

**Docker Compose (Production):**

```yaml
version: '3.8'

services:
  api:
    image: kharisma/api:v1.0.0
    restart: always
    ports:
      - "3000:3000"
    environment:
      DB_HOST: mariadb
      ENV: production
    depends_on:
      - mariadb

  frontend:
    image: kharisma/frontend:v1.0.0
    restart: always
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - api

  mariadb:
    image: mariadb:11
    restart: always
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
```

### 5.2 Windows Docker Deployment

**Why Windows Docker?**
- Native container support on Windows
- No need for Hyper-V Linux VM
- Direct resource access
- Easier for small team operations

**Windows Setup:**
```powershell
# Install Docker Desktop for Windows
choco install docker-desktop

# Or download from https://www.docker.com/products/docker-desktop

# Enable Windows containers (PowerShell as Admin)
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

# Verify
docker --version
docker-compose --version
```

### 5.3 CI/CD Pipeline

**GitHub Actions (.github/workflows/deploy.yml):**

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: 1.21
      
      - name: Run backend tests
        run: cd backend && go test ./...
      
      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Run frontend tests
        run: cd frontend && npm ci && npm run test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build and push Docker images
        run: |
          docker build -t kharisma/api:${{ github.sha }} ./backend
          docker build -t kharisma/frontend:${{ github.sha }} ./frontend

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          # Your deployment script here
```

---

## Performance Optimization

### 6.1 Backend Optimization

**Go/Fiber Optimization:**

```go
// Connection pooling
type Config struct {
    MaxOpenConns    int = 25
    MaxIdleConns    int = 5
    ConnMaxLifetime time.Duration = 5 * time.Minute
}

// Request compression
app.Use(middleware.Compress())

// Caching headers
app.Use(func(c *fiber.Ctx) error {
    if c.Method() == "GET" {
        c.Set("Cache-Control", "public, max-age=3600")
    }
    return c.Next()
})

// Database query optimization
// - Use indexes on commonly queried fields
// - Lazy loading with Preload()
// - Pagination for large datasets

db.Where("status = ?", "PENDING").
   Limit(10).
   Offset((page - 1) * 10).
   Find(&orders)
```

**Expected Performance:**
- API response time: <100ms (p95)
- Database query: <50ms (p95)
- Throughput: 10k+ orders/sec

### 6.2 Frontend Optimization

**Vue 3 Bundle Optimization:**

```javascript
// vite.config.ts
export default defineConfig({
  build: {
    // Code splitting
    rollupOptions: {
      output: {
        manualChunks: {
          'vue': ['vue', 'vue-router', 'pinia'],
          'ui': ['@headlessui/vue', 'axios'],
        },
      },
    },
    // Asset compression
    assetsInlineLimit: 4096,
    // Minification
    minify: 'terser',
  },
  // Lazy load routes
  lazy: true,
})
```

**Expected Performance:**
- Initial page load: <1.5s (on 4G)
- Interactive: <2s
- Bundle size: 40-60KB (gzipped)

### 6.3 Docker Image Optimization

**Backend (Go):**
- Alpine Linux base: ~5MB
- Go binary: ~20-30MB
- Total: ~50-80MB

**Frontend (Vue 3):**
- Nginx base: ~20MB
- Built Vue app: ~500KB-1MB
- Total: ~30-50MB

**Combined Stack:** ~100-150MB (vs 500MB+ for Python/Next.js)

---

## Summary & Next Steps

### Key Advantages of This Stack

| Aspect | Advantage |
|--------|-----------|
| **Performance** | Go backend is 10x faster than Python |
| **Size** | 1/5th the Docker image size |
| **Concurrency** | Goroutines handle thousands of concurrent users |
| **Learning** | Vue 3 is easier to learn than React |
| **Team Fit** | Optimal for small team of 2-3 developers |
| **Maintainability** | Clean architecture, type-safe |
| **Deployment** | Single binary + lightweight frontend |
| **Windows Support** | Excellent Docker support on Windows |

### Implementation Roadmap

**Week 1-2: Setup**
- Initialize Go project with Fiber
- Initialize Vue 3 project with Vite
- Set up Docker Compose development environment
- Configure database migrations

**Week 3-4: Authentication & Core APIs**
- Implement JWT authentication
- Build user management APIs
- Create API for order management
- Frontend authentication flow

**Week 5-6: Order Processing**
- Implement order creation/update APIs
- Payment processing system
- Queue management system
- Frontend order management UI

**Week 7-8: Frontend Development**
- Build POS interface
- Order management dashboard
- Payment interface
- Reporting views

**Week 9-10: Integration & Testing**
- Integration testing
- Performance testing & optimization
- Data migration testing
- UAT preparation

---

This technical architecture provides the optimal balance of **performance, maintainability, and team efficiency** for the Kharisma Abadi rebuild project.
