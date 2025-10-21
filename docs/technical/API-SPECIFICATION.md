# API Specification - Kharisma Abadi Backend

**API Version:** 1.0  
**Framework:** Go + Fiber  
**Authentication:** JWT Bearer Token  
**Base URL:** `/api/v1`  
**Response Format:** JSON  
**Date:** October 2025

---

## Table of Contents

1. [API Overview](#1-api-overview)
2. [Authentication](#2-authentication)
3. [Standard Responses](#3-standard-responses)
4. [Error Handling](#4-error-handling)
5. [User Management](#5-user-management)
6. [Customer Management](#6-customer-management)
7. [Order Management](#7-order-management)
8. [Payment Processing](#8-payment-processing)
9. [Reporting](#9-reporting)
10. [Rate Limiting](#10-rate-limiting)

---

## 1. API Overview

### 1.1 Base Information

- **Protocol:** HTTPS (production), HTTP (development)
- **Base URL:** `http://localhost:3000/api/v1` (development)
- **Content-Type:** `application/json`
- **Character Encoding:** UTF-8
- **Pagination:** Offset-based (limit, offset parameters)
- **Date Format:** ISO 8601 (2025-10-22T10:30:00Z)

### 1.2 API Versioning

- Current Version: v1
- Future versions will be available at `/api/v2`, etc.
- Old API versions will be deprecated with 6 months notice

### 1.3 HTTP Methods

| Method | Purpose |
|--------|---------|
| GET | Retrieve resources |
| POST | Create new resources |
| PATCH | Partial update of resources |
| PUT | Full replacement (rarely used) |
| DELETE | Delete resources |

### 1.4 HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource created successfully |
| 204 | No Content - Successful request with no return body |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing/invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 422 | Unprocessable Entity - Validation error |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |
| 503 | Service Unavailable - Maintenance |

---

## 2. Authentication

### 2.1 Authentication Flow

1. User provides username/password
2. API validates credentials
3. Server returns access_token (30 min) and refresh_token (7 days)
4. Client stores tokens (localStorage)
5. Client sends access_token in Authorization header
6. When access_token expires, use refresh_token to get new one

### 2.2 Login Endpoint

**POST /auth/login**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "john.doe",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNjk3OTQyNjAwfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNjk4NTQ3NDAwfQ.N3QlR5jI9bM2zT_vP8aK7sL3qX1mN2oP5rS4uV6wX8k",
    "token_type": "Bearer",
    "expires_in": 1800,
    "user": {
      "id": 1,
      "username": "john.doe",
      "full_name": "John Doe",
      "email": "john@example.com",
      "role": "cashier"
    }
  }
}
```

**Error Response (401 Unauthorized):**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid username or password"
  }
}
```

### 2.3 Refresh Token Endpoint

**POST /auth/refresh**

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 1800
  }
}
```

### 2.4 Logout Endpoint

**POST /auth/logout**

```http
POST /api/v1/auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 2.5 Protected Endpoints

All protected endpoints require the `Authorization` header:

```http
GET /api/v1/orders
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Missing Token Response (401):**

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Missing authentication token"
  }
}
```

**Invalid Token Response (401):**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Token is invalid or expired"
  }
}
```

---

## 3. Standard Responses

### 3.1 Success Response Format

**For Single Resource (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-10-22T10:30:00Z"
  }
}
```

**For List Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "offset": 0,
    "total": 25,
    "total_pages": 3
  }
}
```

**For Create Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "customer_id": 1,
    "total_amount": 55000,
    "status": "pending",
    "created_at": "2025-10-22T10:30:00Z"
  }
}
```

### 3.2 Pagination

**Parameters:**

```
GET /api/v1/orders?page=1&limit=10
GET /api/v1/orders?offset=0&limit=10
```

**Metadata:**

```json
{
  "meta": {
    "page": 1,
    "limit": 10,
    "offset": 0,
    "total": 150,
    "total_pages": 15
  }
}
```

### 3.3 Filtering

**Query Parameters:**

```
GET /api/v1/orders?status=pending
GET /api/v1/orders?customer_id=1
GET /api/v1/orders?service_type=car_wash&status=in_progress
GET /api/v1/orders?created_after=2025-10-20&created_before=2025-10-25
```

### 3.4 Sorting

**Query Parameter:**

```
GET /api/v1/orders?sort=created_at:desc
GET /api/v1/orders?sort=total_amount:asc
```

**Multiple Sorts:**

```
GET /api/v1/orders?sort=status:asc&sort=created_at:desc
```

---

## 4. Error Handling

### 4.1 Error Response Structure

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      {
        "field": "email",
        "message": "Email is invalid"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ],
    "timestamp": "2025-10-22T10:30:00Z"
  }
}
```

### 4.2 Validation Errors (422)

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
      },
      {
        "field": "customer_id",
        "message": "customer_id is required"
      }
    ]
  }
}
```

### 4.3 Business Logic Errors

**Insufficient Permissions (403):**

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to perform this action",
    "details": {
      "required_role": "manager",
      "your_role": "cashier"
    }
  }
}
```

**Resource Not Found (404):**

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Order not found",
    "details": {
      "order_id": 999
    }
  }
}
```

**Conflict (409):**

```json
{
  "success": false,
  "error": {
    "code": "DUPLICATE_RESOURCE",
    "message": "Order already exists",
    "details": {
      "order_number": "ORD-20251022-001"
    }
  }
}
```

### 4.4 Server Errors (500)

```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred",
    "request_id": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2025-10-22T10:30:00Z"
  }
}
```

---

## 5. User Management

### 5.1 List Users

**GET /users**

```http
GET /api/v1/users?role=cashier&is_active=true&limit=10
Authorization: Bearer {token}
```

**Required Role:** admin, manager

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| role | string | Filter by role (admin, manager, cashier, service_staff, viewer) |
| is_active | boolean | Filter by active status |
| limit | integer | Items per page (default: 10, max: 100) |
| offset | integer | Pagination offset (default: 0) |

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "john.doe",
      "full_name": "John Doe",
      "email": "john@example.com",
      "role": "cashier",
      "is_active": true,
      "last_login": "2025-10-22T09:45:00Z",
      "created_at": "2025-10-01T08:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 5
  }
}
```

### 5.2 Get User Detail

**GET /users/{id}**

```http
GET /api/v1/users/1
Authorization: Bearer {token}
```

**Required Role:** admin, manager, self

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "john.doe",
    "full_name": "John Doe",
    "email": "john@example.com",
    "role": "cashier",
    "is_active": true,
    "created_at": "2025-10-01T08:00:00Z",
    "updated_at": "2025-10-15T14:20:00Z",
    "last_login": "2025-10-22T09:45:00Z"
  }
}
```

### 5.3 Create User

**POST /users**

```http
POST /api/v1/users
Authorization: Bearer {token}
Content-Type: application/json

{
  "username": "jane.smith",
  "full_name": "Jane Smith",
  "email": "jane@example.com",
  "password": "SecurePass123!",
  "role": "cashier"
}
```

**Required Role:** admin

**Validation Rules:**

- username: 5-50 chars, alphanumeric + underscore
- full_name: 2-100 chars
- email: Valid email format
- password: Min 8 chars, must include uppercase, lowercase, number, special char
- role: One of (admin, manager, cashier, service_staff, viewer)

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "jane.smith",
    "full_name": "Jane Smith",
    "email": "jane@example.com",
    "role": "cashier",
    "is_active": true,
    "created_at": "2025-10-22T10:30:00Z"
  }
}
```

### 5.4 Update User

**PATCH /users/{id}**

```http
PATCH /api/v1/users/1
Authorization: Bearer {token}
Content-Type: application/json

{
  "full_name": "John Doe Updated",
  "email": "john.new@example.com",
  "role": "manager"
}
```

**Required Role:** admin, or self (limited fields)

**Updatable Fields:**
- full_name
- email
- role (admin only)
- is_active (admin only)

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "john.doe",
    "full_name": "John Doe Updated",
    "email": "john.new@example.com",
    "role": "manager",
    "is_active": true,
    "updated_at": "2025-10-22T10:30:00Z"
  }
}
```

### 5.5 Change Password

**POST /users/{id}/change-password**

```http
POST /api/v1/users/1/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "current_password": "OldPass123!",
  "new_password": "NewPass456!",
  "confirm_password": "NewPass456!"
}
```

**Required Role:** self (can only change own password), admin (can change any)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## 6. Customer Management

### 6.1 List Customers

**GET /customers**

```http
GET /api/v1/customers?customer_type=vip&is_active=true&limit=20
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| customer_type | string | regular, vip, corporate |
| is_active | boolean | Active customers only |
| search | string | Search by name or phone |
| limit | integer | Items per page (default: 20) |
| offset | integer | Pagination offset |

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "phone": "+628123456789",
      "email": "john@example.com",
      "customer_type": "vip",
      "membership_number": "MBR-001",
      "discount_percentage": 15,
      "is_active": true,
      "created_at": "2025-10-01T08:00:00Z"
    }
  ],
  "meta": {
    "total": 150,
    "limit": 20,
    "offset": 0
  }
}
```

### 6.2 Create Customer

**POST /customers**

```http
POST /api/v1/customers
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Doe",
  "phone": "+628123456789",
  "email": "john@example.com",
  "address": "Jl. Sudirman No. 123",
  "customer_type": "regular"
}
```

**Required Role:** cashier, manager, admin

**Validation:**

- name: 2-100 chars
- phone: 10-20 chars, numeric
- email: Valid email (optional)
- customer_type: regular, vip, corporate

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "phone": "+628123456789",
    "email": "john@example.com",
    "address": "Jl. Sudirman No. 123",
    "customer_type": "regular",
    "is_active": true,
    "created_at": "2025-10-22T10:30:00Z"
  }
}
```

### 6.3 Get Customer Detail

**GET /customers/{id}**

```http
GET /api/v1/customers/1
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "phone": "+628123456789",
    "email": "john@example.com",
    "address": "Jl. Sudirman No. 123",
    "customer_type": "vip",
    "membership_number": "MBR-001",
    "discount_percentage": 15,
    "is_active": true,
    "total_orders": 25,
    "total_spent": 1250000,
    "created_at": "2025-10-01T08:00:00Z",
    "updated_at": "2025-10-20T14:15:00Z"
  }
}
```

### 6.4 Update Customer

**PATCH /customers/{id}**

```http
PATCH /api/v1/customers/1
Authorization: Bearer {token}
Content-Type: application/json

{
  "customer_type": "vip",
  "discount_percentage": 15,
  "email": "john.new@example.com"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "customer_type": "vip",
    "discount_percentage": 15,
    "updated_at": "2025-10-22T10:30:00Z"
  }
}
```

---

## 7. Order Management

### 7.1 List Orders

**GET /orders**

```http
GET /api/v1/orders?status=pending&service_type=car_wash&limit=10
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| status | string | pending, in_progress, completed, paid, closed |
| service_type | string | car_wash, laundry, carpet, water_delivery |
| customer_id | integer | Filter by customer |
| created_after | date | Filter by date (2025-10-22) |
| created_before | date | Filter by date |
| limit | integer | Items per page (default: 10) |
| offset | integer | Pagination offset |

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "ORD-20251022-001",
      "customer_id": 1,
      "customer": {
        "id": 1,
        "name": "John Doe",
        "phone": "+628123456789"
      },
      "service_type": "car_wash",
      "status": "pending",
      "subtotal_price": 50000,
      "discount_amount": 0,
      "tax_amount": 5000,
      "total_amount": 55000,
      "created_at": "2025-10-22T10:30:00Z",
      "created_by": 1
    }
  ],
  "meta": {
    "total": 45,
    "limit": 10,
    "offset": 0
  }
}
```

### 7.2 Create Order

**POST /orders**

```http
POST /api/v1/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "customer_id": 1,
  "service_type": "car_wash",
  "vehicle_type": "sedan",
  "package_type": "premium",
  "subtotal_price": 50000,
  "discount_amount": 0,
  "tax_amount": 5000,
  "total_amount": 55000,
  "notes": "Extra wax coating"
}
```

**Required Role:** cashier, manager, admin

**Validation:**

- customer_id: Must exist in database
- service_type: car_wash, laundry, carpet, water_delivery
- total_amount: Must be > 0
- tax_amount: Must be >= 0

**Response (201 Created):**

```json
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
    "notes": "Extra wax coating",
    "created_at": "2025-10-22T10:30:00Z",
    "created_by": 1
  }
}
```

### 7.3 Get Order Detail

**GET /orders/{id}**

```http
GET /api/v1/orders/1
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "customer_id": 1,
    "customer": {
      "id": 1,
      "name": "John Doe",
      "phone": "+628123456789",
      "email": "john@example.com"
    },
    "service_type": "car_wash",
    "status": "in_progress",
    "subtotal_price": 50000,
    "discount_amount": 0,
    "tax_amount": 5000,
    "total_amount": 55000,
    "notes": "Extra wax coating",
    "created_at": "2025-10-22T10:30:00Z",
    "updated_at": "2025-10-22T11:00:00Z",
    "completed_at": null,
    "created_by": 1
  }
}
```

### 7.4 Update Order Status

**PATCH /orders/{id}**

```http
PATCH /api/v1/orders/1
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "in_progress",
  "notes": "Service started by staff"
}
```

**Valid Status Transitions:**

```
pending → in_progress, cancelled
in_progress → quality_check, cancelled
quality_check → completed, in_progress
completed → awaiting_payment
awaiting_payment → paid, cancelled
paid → closed
```

**Required Role:** By status:
- in_progress: service_staff
- completed: service_staff
- quality_check: manager
- paid: cashier
- closed: manager

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "status": "in_progress",
    "updated_at": "2025-10-22T11:00:00Z"
  }
}
```

### 7.5 Complete Order

**POST /orders/{id}/complete**

```http
POST /api/v1/orders/1/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "quality_passed": true,
  "notes": "Service completed successfully"
}
```

**Required Role:** service_staff

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-20251022-001",
    "status": "completed",
    "completed_at": "2025-10-22T11:30:00Z"
  }
}
```

---

## 8. Payment Processing

### 8.1 Create Payment

**POST /payments**

```http
POST /api/v1/payments
Authorization: Bearer {token}
Content-Type: application/json

{
  "order_id": 1,
  "payment_method": "cash",
  "amount": 55000,
  "notes": "Full payment"
}
```

**Required Role:** cashier, manager, admin

**Payment Methods:**
- cash
- bank_transfer
- ewallet
- card

**Validation:**

- order_id: Must exist and not already paid
- amount: Must be > 0 and <= order total
- payment_method: Valid method

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "payment_method": "cash",
    "amount": 55000,
    "status": "completed",
    "created_at": "2025-10-22T11:30:00Z",
    "created_by": 1
  }
}
```

### 8.2 List Payments

**GET /payments**

```http
GET /api/v1/payments?order_id=1&status=completed&limit=20
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| order_id | integer | Filter by order |
| payment_method | string | Filter by method |
| status | string | completed, pending, failed, refunded |
| created_after | date | Filter by date |
| limit | integer | Items per page |

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_id": 1,
      "payment_method": "cash",
      "amount": 55000,
      "status": "completed",
      "transaction_id": "TXN-20251022-001",
      "created_at": "2025-10-22T11:30:00Z",
      "created_by": 1
    }
  ],
  "meta": {
    "total": 10,
    "limit": 20,
    "offset": 0
  }
}
```

### 8.3 Get Payment Detail

**GET /payments/{id}**

```http
GET /api/v1/payments/1
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "order": {
      "id": 1,
      "order_number": "ORD-20251022-001",
      "total_amount": 55000
    },
    "payment_method": "cash",
    "amount": 55000,
    "status": "completed",
    "transaction_id": "TXN-20251022-001",
    "notes": "Full payment",
    "created_at": "2025-10-22T11:30:00Z",
    "created_by": 1
  }
}
```

---

## 9. Reporting

### 9.1 Daily Sales Report

**GET /reports/daily-sales**

```http
GET /api/v1/reports/daily-sales?date=2025-10-22
Authorization: Bearer {token}
```

**Required Role:** manager, admin

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| date | date | Report date (2025-10-22) |

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "date": "2025-10-22",
    "total_orders": 25,
    "total_revenue": 1375000,
    "total_discount": 50000,
    "total_tax": 137500,
    "by_service": [
      {
        "service_type": "car_wash",
        "count": 10,
        "revenue": 550000
      },
      {
        "service_type": "laundry",
        "count": 8,
        "revenue": 480000
      },
      {
        "service_type": "carpet",
        "count": 5,
        "revenue": 250000
      },
      {
        "service_type": "water_delivery",
        "count": 2,
        "revenue": 95000
      }
    ],
    "by_payment_method": [
      {
        "method": "cash",
        "count": 20,
        "amount": 1100000
      },
      {
        "method": "bank_transfer",
        "count": 5,
        "amount": 275000
      }
    ]
  }
}
```

### 9.2 Revenue Report

**GET /reports/revenue**

```http
GET /api/v1/reports/revenue?start_date=2025-10-01&end_date=2025-10-31&group_by=day
Authorization: Bearer {token}
```

**Required Role:** manager, admin

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| start_date | date | Start date |
| end_date | date | End date |
| group_by | string | day, week, month |

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "period": {
      "start": "2025-10-01",
      "end": "2025-10-31"
    },
    "total_revenue": 33750000,
    "average_daily": 1091612,
    "details": [
      {
        "period": "2025-10-01",
        "revenue": 1050000,
        "orders": 24,
        "average_order_value": 43750
      }
    ]
  }
}
```

### 9.3 Service Performance Report

**GET /reports/service-performance**

```http
GET /api/v1/reports/service-performance?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "period": {
      "start": "2025-10-01",
      "end": "2025-10-31"
    },
    "services": [
      {
        "service_type": "car_wash",
        "total_orders": 300,
        "completed_orders": 295,
        "average_completion_time": 45,
        "revenue": 15750000,
        "completion_rate": 98.33
      }
    ]
  }
}
```

---

## 10. Rate Limiting

### 10.1 Rate Limit Headers

All responses include rate limit information:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1697942400
```

### 10.2 Rate Limit Rules

| Endpoint | Limit | Window |
|----------|-------|--------|
| Auth endpoints | 5 | 15 min |
| Create order | 100 | 1 hour |
| List endpoints | 100 | 1 minute |
| Update endpoints | 50 | 1 minute |
| Reporting | 20 | 1 hour |

### 10.3 Rate Limit Exceeded (429)

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "retry_after": 60
  }
}
```

---

## 11. Webhooks (Future)

This section reserved for webhook support in v2.

---

## 12. SDK & Code Examples

### Go Example:

```go
client := &http.Client{
    Timeout: time.Second * 30,
}

// Login
loginReq := CreateLoginRequest("user", "pass")
resp, _ := client.Post("http://localhost:3000/api/v1/auth/login", 
    "application/json", buffer)

// Create order
orderReq := CreateOrderRequest{
    CustomerID: 1,
    ServiceType: "car_wash",
    TotalAmount: 55000,
}
req, _ := http.NewRequest("POST", "http://localhost:3000/api/v1/orders", buffer)
req.Header.Set("Authorization", "Bearer " + token)
resp, _ := client.Do(req)
```

### JavaScript/TypeScript Example:

```typescript
const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1'
})

// Login
const response = await api.post('/auth/login', {
  username: 'user',
  password: 'pass'
})
const token = response.data.data.access_token
api.defaults.headers.Authorization = `Bearer ${token}`

// Create order
const order = await api.post('/orders', {
  customer_id: 1,
  service_type: 'car_wash',
  total_amount: 55000
})
```

---

This API specification is the definitive reference for all API interactions.
