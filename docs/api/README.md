# API Documentation - Kharisma Abadi v2

**Version:** 1.0.0  
**Status:** Final Design Complete  
**Last Updated:** October 2025

---

## Overview

This directory contains comprehensive API documentation for the Kharisma Abadi v2 application. The API is designed using RESTful principles and follows best practices for modern web APIs.

### Quick Links

- **[API-DESIGN.md](./API-DESIGN.md)** - Complete API design guide with detailed specifications
- **[API-GUIDELINES.md](./API-GUIDELINES.md)** - Design guidelines and best practices
- **[ENDPOINTS-REFERENCE.md](./ENDPOINTS-REFERENCE.md)** - Quick reference for all endpoints
- **[openapi.yaml](./openapi.yaml)** - OpenAPI 3.0 specification
- **[postman-collection.json](./postman-collection.json)** - Postman collection for testing

---

## Key Features

### RESTful Design
- Standard HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Resource-based URL structure
- Consistent naming conventions
- Proper HTTP status codes

### Security
- JWT-based authentication
- Role-based access control (RBAC)
- Token refresh mechanism
- Request validation

### Developer Experience
- Comprehensive documentation
- OpenAPI 3.0 specification
- Postman collection for testing
- Clear error messages
- Pagination and filtering
- Rate limiting

### Business Logic
- Multi-service support (Car Wash, Laundry, Carpet, Water Delivery)
- Order management
- Payment processing
- Customer management
- Queue management
- Reporting and analytics

---

## Getting Started

### 1. Authentication

All endpoints (except login) require JWT bearer token:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Obtain token:**

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "cashier01",
    "password": "SecurePassword123!"
  }'
```

**Response:**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "tokenType": "Bearer",
    "expiresIn": 1800,
    "user": {
      "id": 1,
      "username": "cashier01",
      "role": "cashier"
    }
  }
}
```

### 2. Create Order

```bash
curl -X POST http://localhost:3000/api/v1/car-wash/orders \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 123,
    "vehicleType": "sedan",
    "servicePackage": "premium",
    "addOns": ["waxing"],
    "licensePlate": "B1234XYZ"
  }'
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 456,
    "orderNumber": "CW-2024-00456",
    "customerId": 123,
    "vehicleType": "sedan",
    "servicePackage": "premium",
    "status": "PENDING",
    "pricing": {
      "subtotal": 100000.00,
      "discount": 15000.00,
      "tax": 0.00,
      "total": 85000.00
    },
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### 3. List Orders

```bash
curl -X GET "http://localhost:3000/api/v1/car-wash/orders?page=1&limit=20&sort=-createdAt" \
  -H "Authorization: Bearer {access_token}"
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 456,
      "orderNumber": "CW-2024-00456",
      "customerId": 123,
      "status": "PENDING",
      "total": 85000.00,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

## API Structure

### Base URL

```
Development: http://localhost:3000/api/v1
Staging:     https://staging-api.kharisma-abadi.com/api/v1
Production:  https://api.kharisma-abadi.com/api/v1
```

### Endpoint Categories

#### Authentication (Public)
- Login / Logout
- Token Refresh
- Password Reset
- Current User Info

#### Users (Admin/Manager)
- User CRUD operations
- User activation/deactivation
- Password management

#### Customers
- Customer CRUD operations
- Customer search
- Order history

#### Orders (Service-Specific)
- **Car Wash** - `/car-wash/orders`
- **Laundry** - `/laundry/orders`
- **Carpet** - `/carpet/orders`
- **Water Delivery** - `/water-delivery/orders`

#### Queue Management
- Queue viewing
- Add/remove from queue
- Next in queue

#### Payments
- Payment processing
- Payment history
- Refunds
- Cash drawer management

#### Reports (Admin/Manager)
- Daily sales
- Revenue analytics
- Service performance
- Payment breakdown

---

## Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    // Response data structure varies by endpoint
  },
  "meta": {
    // Optional pagination metadata
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-friendly error message",
    "details": [
      {
        "field": "fieldName",
        "message": "Specific error for this field"
      }
    ]
  }
}
```

---

## HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE or empty response |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict |
| 422 | Unprocessable | Business rule violation |
| 429 | Too Many | Rate limit exceeded |
| 500 | Internal Error | Server error |

---

## Pagination

### Request

```
GET /api/v1/orders?page=1&limit=20&sort=-createdAt
```

### Parameters

| Parameter | Type | Default | Max | Description |
|-----------|------|---------|-----|-------------|
| page | integer | 1 | N/A | Page number (1-based) |
| limit | integer | 20 | 100 | Items per page |
| sort | string | -createdAt | N/A | Sort field (- for desc) |

### Response

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

## Authentication & Authorization

### Token-Based (JWT)

**Access Token:**
- Expiry: 30 minutes
- Use in Authorization header: `Bearer {token}`

**Refresh Token:**
- Expiry: 7 days
- Use to obtain new access token

### Role-Based Access Control

| Role | Access Level | Common Tasks |
|------|--------------|--------------|
| **Admin** | Full system | User management, system config |
| **Manager** | High | Orders, payments, reports |
| **Cashier** | Medium | Order creation, payments |
| **Service Staff** | Limited | Queue, order status updates |
| **Viewer** | Read-only | View orders, customers |

### Permissions Example

```json
{
  "resource": "orders",
  "permissions": {
    "admin": ["create", "read", "update", "delete"],
    "manager": ["create", "read", "update"],
    "cashier": ["create", "read", "update"],
    "service_staff": ["read", "update"],
    "viewer": ["read"]
  }
}
```

---

## Rate Limiting

### Limits by Category

| Category | Limit | Window |
|----------|-------|--------|
| Login | 5 | 15 minutes per IP |
| Read (GET) | 1000 | 1 hour per user |
| Write (POST/PUT/PATCH) | 100 | 1 hour per user |
| Delete | 50 | 1 hour per user |
| Reports/Export | 10 | 1 hour per user |

### Response Headers

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1704067260
```

### Rate Limit Exceeded

```
HTTP/1.1 429 Too Many Requests

{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

---

## Error Handling

### Error Codes

| Code | Meaning |
|------|---------|
| VALIDATION_ERROR | Input validation failed |
| AUTHENTICATION_FAILED | Login failed |
| TOKEN_EXPIRED | JWT token expired |
| UNAUTHORIZED | Missing authentication |
| INSUFFICIENT_PERMISSIONS | Lack authorization |
| NOT_FOUND | Resource not found |
| CONFLICT | Resource conflict |
| BUSINESS_RULE_VIOLATION | Business logic violation |
| RATE_LIMIT_EXCEEDED | Rate limit exceeded |
| INTERNAL_ERROR | Server error |

### Example Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "vehicleType",
        "message": "Invalid vehicle type",
        "code": "INVALID_ENUM"
      },
      {
        "field": "customerId",
        "message": "Customer not found",
        "code": "NOT_FOUND"
      }
    ]
  }
}
```

---

## Tools & Resources

### Testing

**Postman Collection:**
- Import [postman-collection.json](./postman-collection.json)
- Set environment variables: `base_url`, `access_token`, `refresh_token`
- Run requests from organized folder structure

**cURL:**
```bash
curl -X GET http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer {token}"
```

### Documentation

**OpenAPI/Swagger:**
- View [openapi.yaml](./openapi.yaml)
- Use tools like Swagger UI for interactive documentation
- Tools: SwaggerHub, Swagger Editor, Postman

**API Documentation:**
- Read [API-DESIGN.md](./API-DESIGN.md) for comprehensive design
- Review [API-GUIDELINES.md](./API-GUIDELINES.md) for best practices
- Check [ENDPOINTS-REFERENCE.md](./ENDPOINTS-REFERENCE.md) for quick lookup

---

## Implementation Timeline

### Phase 1: Setup & Core (Week 1-2)
- [ ] Authentication system (login, tokens, refresh)
- [ ] User management
- [ ] Customer management
- [ ] Base order CRUD for one service

### Phase 2: Services (Week 3-4)
- [ ] Car Wash order management
- [ ] Laundry order management
- [ ] Carpet order management
- [ ] Water Delivery order management

### Phase 3: Advanced Features (Week 5-6)
- [ ] Queue management
- [ ] Payment processing
- [ ] Reporting
- [ ] Cash drawer

### Phase 4: Testing & Optimization (Week 7+)
- [ ] Integration testing
- [ ] Performance testing
- [ ] Security testing
- [ ] Load testing

---

## Deployment Checklist

- [ ] Secure environment variables configured
- [ ] Database migrations applied
- [ ] JWT secrets configured
- [ ] CORS settings configured
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Error tracking enabled
- [ ] API documentation generated
- [ ] Security headers configured
- [ ] HTTPS enabled
- [ ] Database backups configured
- [ ] Monitoring alerts set up

---

## Versioning & Support

**Current Version:** v1.0.0  
**Status:** Final Design  
**Support Period:** TBD

### Version History

| Version | Date | Status |
|---------|------|--------|
| 1.0.0 | Oct 2025 | Final Design |

### Breaking Changes

None yet (v1.0.0 is initial release)

### Deprecation Policy

- 6-month advance notice for breaking changes
- Parallel support for previous version during transition
- Migration guides provided

---

## Support & Contact

### Documentation
- Main: [API-DESIGN.md](./API-DESIGN.md)
- Guidelines: [API-GUIDELINES.md](./API-GUIDELINES.md)
- Reference: [ENDPOINTS-REFERENCE.md](./ENDPOINTS-REFERENCE.md)

### Testing
- Postman: [postman-collection.json](./postman-collection.json)
- OpenAPI: [openapi.yaml](./openapi.yaml)

### Issues & Questions
- Contact: API Support (support@kharisma-abadi.com)
- Report bugs: [GitHub Issues](https://github.com/kharisma/api/issues)

---

## Document Manifest

| File | Purpose | Audience |
|------|---------|----------|
| API-DESIGN.md | Complete API design with all details | Backend developers, API consumers |
| API-GUIDELINES.md | Design guidelines and best practices | Backend developers |
| ENDPOINTS-REFERENCE.md | Quick reference for all endpoints | Everyone |
| openapi.yaml | OpenAPI 3.0 specification | Tools, documentation generators |
| postman-collection.json | Testing collection | QA, developers |
| README.md | This file - Overview and quick start | Everyone |

---

## Next Steps

1. **Review Documentation**
   - Read API-DESIGN.md for complete specification
   - Review API-GUIDELINES.md for implementation guidance
   - Check ENDPOINTS-REFERENCE.md for endpoint details

2. **Set Up Testing**
   - Import postman-collection.json to Postman
   - Configure environment variables
   - Test authentication endpoint

3. **Implement Backend**
   - Follow architecture from TECHNICAL-SPEC.md
   - Use API design as contract
   - Implement endpoints in order of priority

4. **Frontend Integration**
   - Create API client based on endpoints
   - Implement authentication flow
   - Use OpenAPI spec for type generation

5. **Testing & Validation**
   - Run integration tests
   - Validate against OpenAPI spec
   - Performance testing

6. **Deployment**
   - Review deployment checklist
   - Configure environment
   - Deploy to staging first

---

**Generated:** October 2025  
**Last Updated:** October 2025  
**Status:** Complete and Ready for Implementation

