# API Design Guidelines - Kharisma Abadi v2

**Version:** 1.0.0  
**Date:** October 2025  
**Audience:** Backend developers, API consumers

---

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [URL Structure](#url-structure)
3. [Request Design](#request-design)
4. [Response Design](#response-design)
5. [Error Handling](#error-handling)
6. [Versioning Strategy](#versioning-strategy)
7. [Breaking Changes](#breaking-changes)
8. [Deprecation Process](#deprecation-process)
9. [Best Practices](#best-practices)
10. [Code Examples](#code-examples)

---

## Naming Conventions

### Resource Names

**Use plural nouns for collections:**

```
✅ GOOD:     /api/v1/customers
❌ BAD:      /api/v1/customer
❌ BAD:      /api/v1/getCustomers
❌ BAD:      /api/v1/Customers
```

**Use lowercase with hyphens for multi-word resources:**

```
✅ GOOD:     /api/v1/car-wash/orders
✅ GOOD:     /api/v1/payment-methods
❌ BAD:      /api/v1/carwash/orders
❌ BAD:      /api/v1/CarWash/Orders
❌ BAD:      /api/v1/car_wash/orders
```

**Avoid verbs in resource names:**

```
✅ GOOD:     POST /api/v1/orders                (Create order)
❌ BAD:      POST /api/v1/createOrder           (Verb in name)
❌ BAD:      POST /api/v1/orders/create         (Verb in action)
```

### Field Names

**Use camelCase in JSON responses:**

```json
✅ GOOD:
{
  "firstName": "John",
  "lastLogin": "2024-01-15T10:30:00Z",
  "phoneNumber": "+62812345678"
}

❌ BAD:
{
  "first_name": "John",
  "last_login": "2024-01-15T10:30:00Z",
  "phone_number": "+62812345678"
}

❌ BAD:
{
  "FirstName": "John",
  "LastLogin": "2024-01-15T10:30:00Z"
}
```

### Enum Values

**Use UPPER_SNAKE_CASE for enum values:**

```
✅ GOOD:     status: "IN_PROGRESS"
✅ GOOD:     role: "SERVICE_STAFF"
✅ GOOD:     paymentMethod: "BANK_TRANSFER"

❌ BAD:      status: "in_progress"
❌ BAD:      role: "service_staff"
❌ BAD:      paymentMethod: "bank_transfer"
```

### Boolean Fields

**Prefix boolean fields with "is" or "has":**

```json
✅ GOOD:
{
  "isActive": true,
  "hasDiscount": false,
  "isPaid": true
}

❌ BAD:
{
  "active": true,
  "discount": false,
  "paid": true
}
```

---

## URL Structure

### Hierarchical Resources

**Use hierarchical URLs for relationships:**

```
# Get orders by customer
GET /api/v1/customers/123/orders

# Get specific order by customer
GET /api/v1/customers/123/orders/456

# Get items in an order
GET /api/v1/orders/456/items

# Get payment for an order
GET /api/v1/orders/456/payment
```

**Limitations:**
- Maximum 3 levels of hierarchy
- Use query parameters for filtering instead of deeper nesting

```
✅ BETTER:    GET /api/v1/orders?customerId=123&status=pending
❌ AVOID:     GET /api/v1/customers/123/orders/pending/cars/sedan
```

### Query Parameters

**Use for filtering, sorting, pagination:**

```
GET /api/v1/orders?page=1&limit=20&sort=-createdAt&filter[status]=pending
```

**Never use query parameters for resource identification:**

```
✅ GOOD:     GET /api/v1/orders/123
❌ BAD:      GET /api/v1/orders?id=123
```

### ID Format

**Use numeric IDs (integers):**

```
✅ GOOD:     GET /api/v1/customers/123
✅ GOOD:     GET /api/v1/orders/456
```

**Can use UUIDs for distributed systems:**

```
✅ ACCEPTABLE:  GET /api/v1/customers/550e8400-e29b-41d4-a716-446655440000
```

**Avoid custom formats:**

```
❌ BAD:      GET /api/v1/customers/CUST-001
❌ BAD:      GET /api/v1/customers/2024-001
```

---

## Request Design

### Content-Type

**Always use application/json:**

```
Content-Type: application/json
Accept: application/json
```

### HTTP Methods

**Use correct HTTP method for intent:**

| Method | Purpose | Request Body | Response |
|--------|---------|--------------|----------|
| GET | Retrieve | No | 200 with data or 404 |
| POST | Create | Yes (required) | 201 with new resource |
| PUT | Replace entire | Yes (required) | 200 with updated resource |
| PATCH | Partial update | Yes | 200 with updated resource |
| DELETE | Remove | No | 204 No Content or 200 OK |

**POST vs PUT vs PATCH:**

```
# POST - Create new order
POST /api/v1/orders
{
  "customerId": 123,
  "items": [...]
}
→ 201 Created with auto-generated ID

# PUT - Replace entire order
PUT /api/v1/orders/456
{
  "customerId": 123,
  "items": [...],
  "status": "COMPLETED"
}
→ 200 OK with updated resource

# PATCH - Update specific fields
PATCH /api/v1/orders/456
{
  "status": "COMPLETED"
}
→ 200 OK with updated resource
```

### Request Body

**Always use JSON:**

```json
✅ GOOD:
POST /api/v1/customers
{
  "name": "John Doe",
  "phone": "08123456789"
}
```

**Include all required fields:**

```json
❌ INCOMPLETE:
{
  "name": "John Doe"
}
→ 400 Bad Request: "phone is required"

✅ COMPLETE:
{
  "name": "John Doe",
  "phone": "08123456789"
}
→ 201 Created
```

### Validation

**Validate on both client and server:**

1. **Client-side:** Immediate user feedback
2. **Server-side:** Security and data integrity

**Return validation errors with field details:**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "phone",
        "message": "Phone must have at least 8 digits",
        "code": "INVALID_LENGTH"
      }
    ]
  }
}
```

---

## Response Design

### Success Response

**Always include success flag:**

```json
✅ GOOD:
{
  "success": true,
  "data": {
    "id": 123,
    "name": "John Doe"
  }
}

❌ BAD:
{
  "id": 123,
  "name": "John Doe"
}
```

**Wrap array responses:**

```json
✅ GOOD:
{
  "success": true,
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" }
  ]
}

❌ BAD:
[
  { "id": 1, "name": "Item 1" },
  { "id": 2, "name": "Item 2" }
]
```

### Field Types

**Be consistent with field types:**

```json
✅ GOOD:
{
  "id": 123,                                    // integer
  "price": 85000.00,                           // number
  "quantity": 5,                               // integer
  "isActive": true,                            // boolean
  "createdAt": "2024-01-15T10:30:00Z",        // ISO 8601 date
  "tags": ["urgent", "vip"],                   // array
  "metadata": { "key": "value" }               // object
}
```

**Never change field types between responses:**

```json
❌ BAD - Inconsistent:
First response:  { "price": 85000.00 }      // number
Second response: { "price": "85000.00" }    // string
Third response:  { "price": 85000 }         // integer
```

### Null vs Missing Fields

**Use null for nullable fields that exist:**

```json
✅ GOOD:
{
  "id": 123,
  "deletedAt": null      // Field exists, but not deleted
}

✅ ALSO GOOD:
{
  "id": 123
}                         // Field omitted entirely (not nullable)
```

**Never omit required fields:**

```json
❌ BAD:
{
  "id": 123
  // Missing required "name" field
}

✅ GOOD:
{
  "id": 123,
  "name": "John Doe"
}
```

### Timestamps

**Always use ISO 8601 format in UTC:**

```json
✅ GOOD:
{
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T14:45:30Z"
}

❌ BAD:
{
  "createdAt": "2024-01-15",
  "createdAt": 1704067200,
  "createdAt": "01/15/2024 10:30 AM"
}
```

### Numeric Precision

**Use appropriate precision:**

```json
✅ GOOD:
{
  "price": 85000.50,           // 2 decimal places for currency
  "percentage": 15.5,          // 1 decimal place for percentage
  "discount": 15000.00         // 2 decimal places
}

❌ BAD:
{
  "price": 85000.5,            // Inconsistent precision
  "price": 85000.123456,       // Too precise
  "price": 85000               // No decimals for currency
}
```

---

## Error Handling

### Error Response Format

**All errors follow same format:**

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-friendly error message",
    "details": [...]  // Optional, for validation errors
  }
}
```

### HTTP Status Codes

**Use appropriate status codes:**

```
2xx: Success
  200 OK              - Successful GET, PUT, PATCH
  201 Created         - Successful POST
  204 No Content      - Successful DELETE

4xx: Client Error
  400 Bad Request     - Invalid input, malformed JSON
  401 Unauthorized    - Missing or invalid authentication
  403 Forbidden       - Authenticated but not authorized
  404 Not Found       - Resource not found
  409 Conflict        - Resource conflict (duplicate, state error)
  422 Unprocessable   - Business rule violation
  429 Too Many        - Rate limit exceeded

5xx: Server Error
  500 Internal Error  - Unexpected server error
  503 Unavailable     - Service temporarily unavailable
```

### Error Messages

**Write user-friendly error messages:**

```json
✅ GOOD:
{
  "success": false,
  "error": {
    "code": "INVALID_STATUS_TRANSITION",
    "message": "Cannot complete order without payment. Please process payment first."
  }
}

❌ BAD:
{
  "error": "Database constraint violated on foreign key"
}

❌ BAD:
{
  "error": "NULL pointer exception at line 123"
}
```

### Validation Errors

**Provide field-level detail:**

```json
✅ GOOD:
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "customerName",
        "message": "Customer name is required",
        "code": "MISSING_FIELD"
      },
      {
        "field": "email",
        "message": "Invalid email format",
        "code": "INVALID_FORMAT"
      }
    ]
  }
}

❌ BAD:
{
  "success": false,
  "error": {
    "message": "Invalid request data"
  }
}
```

---

## Versioning Strategy

### Version Format

**Use URL-based versioning:**

```
✅ GOOD:     /api/v1/orders
✅ GOOD:     /api/v2/orders
```

**Alternative: Accept header (less common):**

```
Accept: application/vnd.kharisma.v1+json
```

### Version Numbers

**Use semantic versioning for documentation:**

- **v1, v2, v3...** for API versions
- **1.0.0, 1.1.0, 2.0.0** for specification versions

### Version Lifecycle

1. **Active:** Current version, all features
2. **Maintenance:** Previous version, bug fixes only, 6 months
3. **Deprecated:** Announced end date, 6 months notice
4. **Sunset:** No longer available

**Example timeline:**

```
v1:  Active from Day 1          → Sunset in Month 12
v2:  Introduced in Month 6      → Becomes Active in Month 12
      Becomes Maintenance in Month 18 → Sunset in Month 24
```

---

## Breaking Changes

### Definition

A breaking change affects how clients interact with the API:

```
❌ BREAKING:
  - Remove endpoint
  - Change HTTP method
  - Rename field
  - Change field type
  - Remove required parameter
  - Change response format
  - Change authentication scheme

✅ NON-BREAKING:
  - Add new endpoint
  - Add optional field to response
  - Add optional query parameter
  - Add new HTTP status code
  - Add new enum value (if backwards compatible)
```

### Process

**When a breaking change is necessary:**

1. **Design:** Plan change with stakeholders
2. **Announce:** 6-month advance notice minimum
3. **Implement:** In new major version
4. **Migration:** Provide migration guide
5. **Support:** Run both versions during transition
6. **Deprecate:** Mark old version deprecated
7. **Sunset:** Remove old version after period

### Example: Renaming Field

**Before (v1):**

```json
{
  "id": 123,
  "price": 85000.00
}
```

**Plan:** Change "price" to "totalPrice"

**Timeline:**

- **Month 1:** Announce change coming in v2 (6 months notice)
- **Month 7:** Release v2 with new field names
- **Month 8:** Mark v1 as deprecated
- **Month 13:** Sunset v1, only v2 available

**During v1 deprecation (months 8-13):**

```json
v1 response (still works but deprecated):
{
  "id": 123,
  "price": 85000.00
}

v2 response:
{
  "id": 123,
  "totalPrice": 85000.00
}
```

---

## Deprecation Process

### Mark Fields as Deprecated

**In API documentation:**

```
DEPRECATED: This field will be removed in v2.
Use "totalPrice" instead.

Removal date: 2025-12-31
Sunset version: v2.0.0
```

### Deprecation Header

**Include in HTTP response:**

```
Deprecation: true
Sunset: Sat, 31 Dec 2025 23:59:59 GMT
Link: <https://docs.api.com/migration-guide>; rel="deprecation"
```

### Migration Guide

**Provide clear migration path:**

```markdown
## Migrating from v1 to v2

### Field Name Changes
- `price` → `totalPrice`
- `custId` → `customerId`
- `ordDate` → `createdAt`

### Removed Endpoints
- `POST /orders/quick` → Use `POST /orders` with `quickCreate: true`

### New Required Parameters
- `paymentMethod` is now required for all payments

### Updated Response Format
- All dates now in ISO 8601 format (previously Unix timestamp)
```

---

## Best Practices

### 1. Design for Simplicity

```
✅ Simple, obvious API:
GET /api/v1/orders
POST /api/v1/orders
GET /api/v1/orders/123
PATCH /api/v1/orders/123

❌ Complex, confusing:
GET /api/v1/orders/search?query=123
POST /api/v1/orders/create
POST /api/v1/orders/123/update
POST /api/v1/orders/123/partial-update
```

### 2. Be Consistent

```
✅ Consistent pagination:
GET /api/v1/orders?page=1&limit=20
GET /api/v1/customers?page=1&limit=20
GET /api/v1/payments?page=1&limit=20

❌ Inconsistent:
GET /api/v1/orders?offset=0&count=20
GET /api/v1/customers?start=0&end=20
GET /api/v1/payments?p=1&s=20
```

### 3. Fail Fast

```json
❌ Fail late (200 + error in response):
{
  "success": false,
  "error": "Invalid token"
}

✅ Fail fast (401 status):
401 Unauthorized
{
  "success": false,
  "error": {
    "code": "AUTHENTICATION_FAILED",
    "message": "Invalid or expired token"
  }
}
```

### 4. Provide Context

```json
❌ Minimal context:
{
  "success": false,
  "error": "Not found"
}

✅ Full context:
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Customer with ID 123 not found"
  }
}
```

### 5. Idempotent Operations

```
For operations that might be retried, use idempotency:

POST /api/v1/payments
Idempotency-Key: unique-key-per-request

If client retries with same key, return cached response
Don't create duplicate payment
```

### 6. Document Everything

```
Every endpoint should document:
- Purpose and use case
- Authentication requirements
- Request format with examples
- Response format with examples
- Possible error codes
- Rate limits
- Business rules
```

---

## Code Examples

### Complete Endpoint Example

**Create Car Wash Order**

**Request:**

```bash
curl -X POST https://api.kharisma-abadi.com/api/v1/car-wash/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGc..." \
  -d '{
    "customerId": 123,
    "vehicleType": "sedan",
    "servicePackage": "premium",
    "addOns": ["waxing", "interior_cleaning"],
    "licensePlate": "B1234XYZ",
    "notes": "Customer requested express service"
  }'
```

**Successful Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "id": 456,
    "orderNumber": "CW-2024-00456",
    "customerId": 123,
    "customer": {
      "id": 123,
      "name": "John Doe",
      "phone": "08123456789"
    },
    "vehicleType": "sedan",
    "servicePackage": "premium",
    "addOns": [
      { "id": 1, "name": "Waxing", "price": 20000.00 },
      { "id": 2, "name": "Interior Cleaning", "price": 30000.00 }
    ],
    "pricing": {
      "subtotal": 100000.00,
      "discount": 15000.00,
      "tax": 0.00,
      "total": 85000.00
    },
    "status": "PENDING",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z",
    "createdBy": {
      "id": 5,
      "username": "cashier01",
      "fullName": "Jane Smith"
    }
  }
}
```

**Validation Error (400 Bad Request):**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "vehicleType",
        "message": "Invalid vehicle type. Must be one of: motorcycle, sedan, suv, truck, bus, truck_large",
        "code": "INVALID_ENUM"
      },
      {
        "field": "customerId",
        "message": "Customer with ID 999 not found",
        "code": "NOT_FOUND"
      }
    ]
  }
}
```

**Business Rule Violation (422 Unprocessable Entity):**

```json
{
  "success": false,
  "error": {
    "code": "BUSINESS_RULE_VIOLATION",
    "message": "Cannot create order for inactive customer",
    "details": [
      {
        "field": "customerId",
        "message": "Customer account is inactive. Please activate before creating orders."
      }
    ]
  }
}
```

---

## Implementation Checklist

- [ ] All endpoints follow RESTful principles
- [ ] Naming conventions consistent throughout
- [ ] HTTP methods used correctly
- [ ] Status codes match intent
- [ ] Error responses include error code and details
- [ ] All fields have consistent types
- [ ] Timestamps in ISO 8601 format
- [ ] Validation errors include field details
- [ ] Pagination implemented for list endpoints
- [ ] Rate limiting headers included
- [ ] Authentication on protected endpoints
- [ ] Authorization checks implemented
- [ ] API documentation complete
- [ ] Examples provided for all endpoints
- [ ] Version strategy documented
- [ ] Deprecation process documented

