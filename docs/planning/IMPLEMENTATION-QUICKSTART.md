# Implementation Quick-Start Guide

**For:** Go Backend + Vue 3 Frontend Stack  
**Target:** Kharisma Abadi Application Rebuild  
**Time to First Working System:** ~30 minutes

---

## Table of Contents

1. [Prerequisites & Installation](#prerequisites--installation)
2. [Backend Setup (Go + Fiber)](#backend-setup-go--fiber)
3. [Frontend Setup (Vue 3)](#frontend-setup-vue-3)
4. [Running the Stack](#running-the-stack)
5. [Creating Your First Endpoint](#creating-your-first-endpoint)
6. [Testing](#testing)

---

## Prerequisites & Installation

### System Requirements

```bash
# Check Go installation
go version
# Expected: go version go1.21 or higher

# Check Node.js installation  
node --version
npm --version
# Expected: node v18+ and npm 9+

# Check Docker
docker --version
docker-compose --version
# Expected: Docker 24+, Docker Compose v2+
```

### Installation Steps

**If not installed:**

**macOS (Homebrew):**
```bash
brew install go
brew install node
brew install docker
```

**Windows (Chocolatey):**
```powershell
choco install golang
choco install nodejs
choco install docker-desktop
```

**Linux (Ubuntu/Debian):**
```bash
curl -L https://golang.org/dl/go1.21.0.linux-amd64.tar.gz -o go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
sudo apt install nodejs npm docker.io
```

---

## Backend Setup (Go + Fiber)

### Step 1: Create Project Structure

```bash
mkdir -p kharisma-abadi-backend
cd kharisma-abadi-backend

# Create directories
mkdir -p cmd/server
mkdir -p internal/{domain,repository,usecase,handler,middleware,infrastructure}
mkdir -p migrations

# Initialize Go module
go mod init github.com/kharisma/api
```

### Step 2: Install Dependencies

```bash
# Fiber web framework
go get github.com/gofiber/fiber/v2

# GORM (ORM)
go get github.com/gorm.io/gorm
go get github.com/gorm.io/driver/mysql

# Database utilities
go get github.com/golang-migrate/migrate/v4/cmd/migrate

# JWT authentication
go get github.com/golang-jwt/jwt/v5

# Environment variables
go get github.com/joho/godotenv

# Validation
go get github.com/go-playground/validator/v10

# Decimal for prices
go get github.com/shopspring/decimal

# Database connection
go get github.com/mysql/mysql-connector-go/v8
```

### Step 3: Create Main.go

**cmd/server/main.go:**

```go
package main

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/compress"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {
	// Create Fiber app
	app := fiber.New(fiber.Config{
		Prefork:       false,
		CaseSensitive: true,
		StrictRoute:   true,
	})

	// Middleware
	app.Use(logger.New())
	app.Use(compress.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "http://localhost:5173, http://localhost:3000",
		AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders: "Content-Type,Authorization",
	}))

	// Routes
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "healthy",
		})
	})

	app.Get("/api/v1/orders", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"orders": []interface{}{},
		})
	})

	// Start server
	if err := app.Listen(":3000"); err != nil {
		panic(err)
	}
}
```

### Step 4: Create .env File

**.env:**

```bash
DB_HOST=localhost
DB_PORT=3306
DB_USER=kharisma
DB_PASSWORD=kharisma_password
DB_NAME=kharisma_db
JWT_SECRET=your_jwt_secret_key_min_32_chars_long_secure
API_PORT=3000
ENV=development
```

### Step 5: Test Backend

```bash
# Run the server
go run ./cmd/server/main.go

# In another terminal, test the endpoint
curl http://localhost:3000/health
# Expected: {"status":"healthy"}

curl http://localhost:3000/api/v1/orders
# Expected: {"orders":[]}
```

---

## Frontend Setup (Vue 3)

### Step 1: Create Vue 3 Project with Vite

```bash
# Create Vue 3 project
npm create vite@latest kharisma-abadi-frontend -- --template vue-ts

cd kharisma-abadi-frontend

# Install dependencies
npm install

# Install additional packages
npm install -D tailwindcss postcss autoprefixer
npm install pinia vue-router axios
npm install @vee-validate/vue @vee-validate/rules yup
npm install -D typescript @types/node
```

### Step 2: Configure Tailwind CSS

**tailwind.config.js:**

```javascript
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

**postcss.config.js:**

```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

**src/style.css:**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Step 3: Create Pinia Store

**src/stores/useOrderStore.ts:**

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '@/services/api'

export const useOrderStore = defineStore('order', () => {
  const orders = ref([])
  const loading = ref(false)
  const error = ref(null)

  const pendingOrders = computed(() =>
    orders.value.filter((o: any) => o.status === 'PENDING')
  )

  async function fetchOrders() {
    loading.value = true
    try {
      const response = await api.get('/orders')
      orders.value = response.data.orders
      error.value = null
    } catch (err: any) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  return {
    orders,
    loading,
    error,
    pendingOrders,
    fetchOrders,
  }
})
```

### Step 4: Create API Service

**src/services/api.ts:**

```typescript
import axios from 'axios'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1',
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})
```

### Step 5: Create Simple Home Page

**src/App.vue:**

```vue
<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
    <!-- Header -->
    <header class="bg-white shadow">
      <div class="max-w-6xl mx-auto px-4 py-6">
        <h1 class="text-3xl font-bold text-gray-900">Kharisma Abadi</h1>
        <p class="text-gray-600">Multi-Service Cashier System</p>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-6xl mx-auto px-4 py-8">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <!-- Quick Actions -->
        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition">
          <div class="text-4xl mb-2">🚗</div>
          <h3 class="text-lg font-semibold">Car Wash</h3>
          <p class="text-gray-600 text-sm">Create new order</p>
        </div>

        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition">
          <div class="text-4xl mb-2">👕</div>
          <h3 class="text-lg font-semibold">Laundry</h3>
          <p class="text-gray-600 text-sm">Create new order</p>
        </div>

        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition">
          <div class="text-4xl mb-2">🟤</div>
          <h3 class="text-lg font-semibold">Carpet</h3>
          <p class="text-gray-600 text-sm">Create new order</p>
        </div>

        <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition">
          <div class="text-4xl mb-2">💧</div>
          <h3 class="text-lg font-semibold">Water</h3>
          <p class="text-gray-600 text-sm">Create new order</p>
        </div>
      </div>

      <!-- Orders Section -->
      <div class="mt-8 bg-white rounded-lg shadow p-6">
        <h2 class="text-2xl font-bold mb-4">Recent Orders</h2>
        <div class="text-center text-gray-500">
          <p>Loading orders from API...</p>
          <p class="text-sm mt-2">Endpoint: {{ apiUrl }}/orders</p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const apiUrl = computed(() => 
  import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1'
)
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
</style>
```

### Step 6: Test Frontend

```bash
# Run development server
npm run dev

# Visit http://localhost:5173 in your browser
```

---

## Running the Stack

### Option 1: Running Locally (Development)

**Terminal 1 - Backend:**
```bash
cd kharisma-abadi-backend
go run ./cmd/server/main.go
# Output: [Fiber] Listening on http://0.0.0.0:3000
```

**Terminal 2 - Frontend:**
```bash
cd kharisma-abadi-frontend
npm run dev
# Output: ➜  Local:   http://localhost:5173/
```

**Terminal 3 - Database (Docker):**
```bash
docker run -d \
  --name kharisma-db \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -e MYSQL_DATABASE=kharisma_db \
  -e MYSQL_USER=kharisma \
  -e MYSQL_PASSWORD=kharisma_password \
  -p 3306:3306 \
  mariadb:11
```

### Option 2: Running with Docker Compose

**docker-compose.yml (in project root):**

```yaml
version: '3.8'

services:
  mariadb:
    image: mariadb:11
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: kharisma_db
      MYSQL_USER: kharisma
      MYSQL_PASSWORD: kharisma_password
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10

  api:
    build:
      context: ./kharisma-abadi-backend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    depends_on:
      mariadb:
        condition: service_healthy
    environment:
      DB_HOST: mariadb
      DB_USER: kharisma
      DB_PASSWORD: kharisma_password
      DB_NAME: kharisma_db

  frontend:
    build:
      context: ./kharisma-abadi-frontend
      dockerfile: Dockerfile.dev
    ports:
      - "5173:5173"
    depends_on:
      - api
    environment:
      VITE_API_URL: http://localhost:3000/api/v1

volumes:
  db_data:
```

**Run:**
```bash
docker-compose up -d
# Wait for services to start
docker-compose logs -f

# Stop
docker-compose down
```

---

## Creating Your First Endpoint

### Backend: Create an Order Endpoint

**internal/domain/order.go:**

```go
package domain

import (
	"time"
	"github.com/shopspring/decimal"
)

type Order struct {
	ID           uint
	OrderNo      string
	CustomerID   uint
	ServiceType  string // CAR_WASH, LAUNDRY, CARPET, WATER
	TotalPrice   decimal.Decimal
	Status       string // PENDING, IN_PROGRESS, COMPLETED, PAID, CLOSED
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type CreateOrderRequest struct {
	CustomerID  uint            `json:"customer_id" validate:"required"`
	ServiceType string          `json:"service_type" validate:"required"`
	TotalPrice  decimal.Decimal `json:"total_price" validate:"required"`
}
```

**internal/handler/order.go:**

```go
package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/kharisma/api/internal/domain"
	"github.com/shopspring/decimal"
)

func CreateOrder(c *fiber.Ctx) error {
	req := new(domain.CreateOrderRequest)
	
	if err := c.BindJSON(req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request",
		})
	}

	// Validation would go here
	if req.CustomerID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Customer ID is required",
		})
	}

	// Create order (simplified)
	order := domain.Order{
		ID:          1,
		OrderNo:     "ORD-001",
		CustomerID:  req.CustomerID,
		ServiceType: req.ServiceType,
		TotalPrice:  req.TotalPrice,
		Status:      "PENDING",
	}

	return c.Status(fiber.StatusCreated).JSON(order)
}

func GetOrders(c *fiber.Ctx) error {
	// Simplified - would query database in real app
	orders := []domain.Order{
		{
			ID:          1,
			OrderNo:     "ORD-001",
			CustomerID:  1,
			ServiceType: "CAR_WASH",
			TotalPrice:  decimal.NewFromFloat(50.00),
			Status:      "PENDING",
		},
	}
	
	return c.JSON(fiber.Map{
		"orders": orders,
	})
}
```

**Update cmd/server/main.go to use handlers:**

```go
import (
	"github.com/kharisma/api/internal/handler"
)

// In main() function, replace the hardcoded routes with:
api := app.Group("/api/v1")
api.Get("/orders", handler.GetOrders)
api.Post("/orders", handler.CreateOrder)
```

### Frontend: Consume the Endpoint

**src/components/OrderList.vue:**

```vue
<template>
  <div class="bg-white rounded-lg shadow">
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-4">Orders</h2>

      <button
        @click="fetchOrders"
        class="mb-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Refresh Orders
      </button>

      <div v-if="orderStore.loading" class="text-gray-500">
        Loading...
      </div>

      <div v-else-if="orderStore.error" class="text-red-600">
        {{ orderStore.error }}
      </div>

      <div v-else class="overflow-x-auto">
        <table class="min-w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-sm font-semibold">Order ID</th>
              <th class="px-6 py-3 text-left text-sm font-semibold">Service</th>
              <th class="px-6 py-3 text-left text-sm font-semibold">Price</th>
              <th class="px-6 py-3 text-left text-sm font-semibold">Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in orderStore.orders" :key="order.id" class="border-t">
              <td class="px-6 py-3">{{ order.id }}</td>
              <td class="px-6 py-3">{{ order.service_type }}</td>
              <td class="px-6 py-3">${{ order.total_price }}</td>
              <td class="px-6 py-3">
                <span :class="statusClass(order.status)">
                  {{ order.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useOrderStore } from '@/stores/useOrderStore'

const orderStore = useOrderStore()

onMounted(() => {
  fetchOrders()
})

function fetchOrders() {
  orderStore.fetchOrders()
}

function statusClass(status: string) {
  const classes: Record<string, string> = {
    'PENDING': 'px-3 py-1 bg-yellow-100 text-yellow-800 rounded',
    'COMPLETED': 'px-3 py-1 bg-blue-100 text-blue-800 rounded',
    'PAID': 'px-3 py-1 bg-green-100 text-green-800 rounded',
    'CLOSED': 'px-3 py-1 bg-gray-100 text-gray-800 rounded',
  }
  return classes[status] || 'px-3 py-1 bg-gray-100 text-gray-800 rounded'
}
</script>
```

**Update src/App.vue to include OrderList:**

```vue
<script setup lang="ts">
import OrderList from '@/components/OrderList.vue'
</script>

<template>
  <!-- ... existing header ... -->
  
  <!-- Replace Orders Section with: -->
  <OrderList />
</template>
```

---

## Testing

### Backend Testing

**Create test file: internal/handler/order_test.go**

```go
package handler

import (
	"testing"
	"bytes"
	"encoding/json"
	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
)

func TestCreateOrder(t *testing.T) {
	app := fiber.New()
	app.Post("/orders", CreateOrder)

	// Test data
	orderJSON := `{
		"customer_id": 1,
		"service_type": "CAR_WASH",
		"total_price": "50.00"
	}`

	req := app.Test(&http.Request{
		Method:           "POST",
		URL:              "http://localhost:3000/orders",
		Header:           http.Header{"Content-Type": []string{"application/json"}},
		Body:             bytes.NewBufferString(orderJSON),
	})

	assert.Equal(t, fiber.StatusCreated, req.StatusCode)
}
```

**Run tests:**
```bash
go test ./... -v
```

### Frontend Testing

**Create test file: tests/OrderList.spec.ts**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import OrderList from '@/components/OrderList.vue'

describe('OrderList.vue', () => {
  let wrapper: any

  beforeEach(() => {
    wrapper = mount(OrderList)
  })

  it('renders component', () => {
    expect(wrapper.find('h2').text()).toContain('Orders')
  })

  it('has refresh button', () => {
    expect(wrapper.find('button').exists()).toBe(true)
  })
})
```

**Run tests:**
```bash
npm run test
```

---

## Troubleshooting

### Common Issues

**Backend fails to start**
```bash
# Check port is not in use
lsof -i :3000

# Kill process on port 3000 (macOS/Linux)
kill -9 $(lsof -t -i :3000)
```

**Database connection fails**
```bash
# Check MariaDB is running
docker ps | grep mariadb

# Check credentials
mysql -h 127.0.0.1 -u kharisma -p
```

**Frontend can't connect to API**
```bash
# Check VITE_API_URL is set correctly
echo $VITE_API_URL

# Check backend is running
curl http://localhost:3000/health
```

**CORS errors**
```go
// Make sure CORS middleware is configured correctly in main.go
app.Use(cors.New(cors.Config{
    AllowOrigins: "http://localhost:5173, http://localhost:3000",
    AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
    AllowHeaders: "Content-Type,Authorization",
}))
```

---

## Next Steps

1. **Connect to Database**
   - Implement database models with GORM
   - Create migration scripts
   - Set up repository pattern

2. **Implement Authentication**
   - User login/register endpoints
   - JWT token generation
   - Protected routes

3. **Build Core APIs**
   - Order management (CRUD)
   - Payment processing
   - Customer management

4. **Enhance Frontend**
   - Create form components
   - Implement routing
   - Add state management

5. **Testing & Deployment**
   - Write integration tests
   - Set up CI/CD pipeline
   - Deploy to production

---

## Quick Command Reference

```bash
# Backend
go run ./cmd/server/main.go        # Run server
go test ./... -v                   # Run tests
go build                           # Build binary
go fmt ./...                       # Format code

# Frontend
npm run dev                         # Start dev server
npm run build                       # Build for production
npm run test                        # Run tests
npm run lint                        # Lint code

# Docker
docker-compose up -d               # Start all services
docker-compose down                # Stop all services
docker-compose logs -f             # View logs
docker ps                           # List running containers

# Database
docker exec -it kharisma-db mysql  # Access MariaDB shell
```

This quick-start guide gets you to a working system in ~30 minutes. From there, you can progressively build out the full application following the architecture in the technical documentation.
