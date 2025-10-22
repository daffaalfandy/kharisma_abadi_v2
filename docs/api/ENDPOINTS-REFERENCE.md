# API Endpoints Quick Reference

**Base URL:** `/api/v1`

---

## Authentication (No Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | User login |
| POST | `/auth/logout` | User logout |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/forgot-password` | Request password reset |
| POST | `/auth/reset-password` | Reset password |
| GET | `/auth/me` | Get current user |

---

## Users (Admin/Manager Only)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users` | List users (paginated) |
| POST | `/users` | Create user |
| GET | `/users/{id}` | Get user details |
| PUT | `/users/{id}` | Update user |
| PATCH | `/users/{id}/password` | Change password |
| PATCH | `/users/{id}/activate` | Activate user |
| DELETE | `/users/{id}` | Deactivate user |

---

## Customers

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/customers` | List customers (paginated) |
| POST | `/customers` | Create customer |
| GET | `/customers/{id}` | Get customer |
| PUT | `/customers/{id}` | Update customer |
| PATCH | `/customers/{id}` | Partial update customer |
| DELETE | `/customers/{id}` | Delete customer (admin only) |
| GET | `/customers/{id}/orders` | Get customer orders |
| GET | `/customers/search` | Search customers |

---

## Car Wash

### Orders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/car-wash/orders` | List car wash orders |
| POST | `/car-wash/orders` | Create car wash order |
| GET | `/car-wash/orders/{id}` | Get car wash order |
| PATCH | `/car-wash/orders/{id}` | Update car wash order |
| PATCH | `/car-wash/orders/{id}/start` | Start service |
| PATCH | `/car-wash/orders/{id}/complete` | Complete service |
| PATCH | `/car-wash/orders/{id}/cancel` | Cancel order |
| DELETE | `/car-wash/orders/{id}` | Delete order (admin/manager) |

### Configuration

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/car-wash/vehicle-types` | List vehicle types |
| POST | `/car-wash/vehicle-types` | Create vehicle type |
| GET | `/car-wash/service-packages` | List service packages |
| POST | `/car-wash/service-packages` | Create service package |
| GET | `/car-wash/add-ons` | List add-on services |
| POST | `/car-wash/add-ons` | Create add-on |

---

## Laundry

### Orders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/laundry/orders` | List laundry orders |
| POST | `/laundry/orders` | Create laundry order |
| GET | `/laundry/orders/{id}` | Get laundry order |
| PATCH | `/laundry/orders/{id}` | Update laundry order |
| PATCH | `/laundry/orders/{id}/start` | Start service |
| PATCH | `/laundry/orders/{id}/complete` | Complete service |
| DELETE | `/laundry/orders/{id}` | Delete order |

### Configuration

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/laundry/item-types` | List item types |
| GET | `/laundry/services` | List services |
| GET | `/laundry/pricing` | Get pricing matrix |

---

## Carpet

### Orders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/carpet/orders` | List carpet orders |
| POST | `/carpet/orders` | Create carpet order |
| GET | `/carpet/orders/{id}` | Get carpet order |
| PATCH | `/carpet/orders/{id}` | Update carpet order |
| PATCH | `/carpet/orders/{id}/start` | Start service |
| PATCH | `/carpet/orders/{id}/complete` | Complete service |
| DELETE | `/carpet/orders/{id}` | Delete order |

### Configuration

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/carpet/materials` | List material types |
| GET | `/carpet/sizes` | List size categories |
| POST | `/carpet/quote` | Calculate price quote |

---

## Water Delivery

### Orders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/water-delivery/orders` | List water delivery orders |
| POST | `/water-delivery/orders` | Create water delivery order |
| GET | `/water-delivery/orders/{id}` | Get water delivery order |
| PATCH | `/water-delivery/orders/{id}` | Update water delivery order |
| DELETE | `/water-delivery/orders/{id}` | Delete order |

### Configuration

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/water-delivery/schedule` | Get delivery schedule |
| POST | `/water-delivery/schedule` | Schedule delivery |
| GET | `/water-delivery/zones` | Get delivery zones |
| GET | `/water-delivery/pricing` | Get pricing by zone |

---

## Queue Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/queue` | Get current queue |
| POST | `/queue/{orderId}` | Add order to queue |
| DELETE | `/queue/{orderId}` | Remove from queue |
| GET | `/queue/next` | Get next in queue |

---

## Payments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/payments` | List payments (paginated) |
| POST | `/payments` | Create payment |
| GET | `/payments/{id}` | Get payment |
| POST | `/payments/{id}/refund` | Process refund (admin/manager) |
| GET | `/payment-methods` | List payment methods |

### Cash Drawer

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/cash-drawer` | Get cash drawer status |
| POST | `/cash-drawer/open` | Open cash drawer |
| POST | `/cash-drawer/close` | Close cash drawer |
| GET | `/cash-drawer/transactions` | Get drawer transactions |
| POST | `/cash-drawer/reconcile` | Reconcile drawer (admin/manager) |

---

## Reports (Admin/Manager Only)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/reports/daily-sales` | Daily sales report |
| GET | `/reports/sales-by-service` | Sales by service type |
| GET | `/reports/sales-by-date-range` | Custom date range |
| GET | `/reports/payment-methods` | Payment methods breakdown |
| GET | `/reports/customer-orders` | Customer order history |
| GET | `/reports/service-performance` | Service performance metrics |
| GET | `/reports/revenue` | Revenue analytics |
| GET | `/reports/{reportId}/export` | Export report |

---

## Common Query Parameters

### Pagination

```
page=1          # Page number (default: 1)
limit=20        # Items per page (default: 20, max: 100)
```

### Sorting

```
sort=-createdAt  # Sort descending by createdAt
sort=name        # Sort ascending by name
```

### Filtering

```
filter[status]=pending      # Filter by status
filter[customerId]=123      # Filter by customer ID
filter[createdAt][gte]=2024-01-01  # Filter by date range
```

### Pagination Response Example

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

## Status Codes Reference

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | GET, PUT, PATCH successful |
| 201 | Created | POST successful |
| 204 | No Content | DELETE successful or empty response |
| 400 | Bad Request | Invalid input, validation error |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict |
| 422 | Unprocessable | Business rule violation |
| 429 | Too Many | Rate limit exceeded |
| 500 | Internal Error | Server error |

---

## Error Code Reference

| Code | Meaning | HTTP Status |
|------|---------|-------------|
| VALIDATION_ERROR | Input validation failed | 400 |
| AUTHENTICATION_FAILED | Login failed | 401 |
| TOKEN_EXPIRED | JWT token expired | 401 |
| UNAUTHORIZED | Missing authentication | 401 |
| INSUFFICIENT_PERMISSIONS | Lack authorization | 403 |
| NOT_FOUND | Resource not found | 404 |
| CONFLICT | Resource conflict | 409 |
| BUSINESS_RULE_VIOLATION | Business logic violation | 422 |
| RATE_LIMIT_EXCEEDED | Rate limit exceeded | 429 |
| INTERNAL_ERROR | Server error | 500 |

---

## Role-Based Access Matrix

| Resource | Admin | Manager | Cashier | Service Staff | Viewer |
|----------|-------|---------|---------|---------------|--------|
| Users (CRUD) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Users (Read) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Customers (CRUD) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Customers (Read) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Orders (CRUD) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Orders (Read) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Orders (Update Status) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Payments (Process) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Payments (Refund) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Queue (Read) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Queue (Update) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Reports | ✅ | ✅ | ❌ | ❌ | ❌ |
| Reports (Export) | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## Example Requests

### Login

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "cashier01",
  "password": "SecurePassword123!"
}
```

### Create Car Wash Order

```bash
POST /api/v1/car-wash/orders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "customerId": 123,
  "vehicleType": "sedan",
  "servicePackage": "premium",
  "addOns": ["waxing"],
  "licensePlate": "B1234XYZ"
}
```

### List Orders

```bash
GET /api/v1/car-wash/orders?page=1&limit=20&sort=-createdAt&filter[status]=PENDING
Authorization: Bearer {access_token}
```

### Get Customer

```bash
GET /api/v1/customers/123
Authorization: Bearer {access_token}
```

### Process Payment

```bash
POST /api/v1/payments
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "orderId": 456,
  "amount": 85000.00,
  "paymentMethod": "CASH",
  "notes": "Payment received in full"
}
```

### Export Report

```bash
GET /api/v1/reports/daily-sales/export?format=pdf&date=2024-01-15
Authorization: Bearer {access_token}
```

---

## Rate Limits

| Category | Limit | Window |
|----------|-------|--------|
| Login | 5 | 15 minutes per IP |
| Read (GET) | 1000 | 1 hour per user |
| Write (POST/PUT/PATCH) | 100 | 1 hour per user |
| Delete | 50 | 1 hour per user |
| Reports/Export | 10 | 1 hour per user |

---

## Documentation Links

- **Full API Design:** [API-DESIGN.md](./API-DESIGN.md)
- **Design Guidelines:** [API-GUIDELINES.md](./API-GUIDELINES.md)
- **OpenAPI Specification:** [openapi.yaml](./openapi.yaml)
- **Postman Collection:** [postman-collection.json](./postman-collection.json)

