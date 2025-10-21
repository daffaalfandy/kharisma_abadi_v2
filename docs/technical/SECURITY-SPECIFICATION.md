# Security Specification

**Document Version:** 1.0  
**Date:** October 2025  
**Classification:** Confidential  
**Applicable To:** Go Backend + Vue 3 Frontend Stack

---

## Table of Contents

1. [Security Overview](#1-security-overview)
2. [Authentication](#2-authentication)
3. [Authorization & Access Control](#3-authorization--access-control)
4. [Data Security](#4-data-security)
5. [API Security](#5-api-security)
6. [Infrastructure Security](#6-infrastructure-security)
7. [Incident Response](#7-incident-response)
8. [Compliance & Auditing](#8-compliance--auditing)

---

## 1. Security Overview

### 1.1 Security Principles

**Defense in Depth:** Multiple layers of security controls

**Principle of Least Privilege:** Users/services have minimal required permissions

**Secure by Default:** Security enabled without manual configuration

**Assume Breach:** Design for detection and containment

**Privacy First:** Minimize data collection and exposure

### 1.2 Security Architecture

```
┌─────────────────────────────────────────┐
│        OWASP Top 10 Protection          │
├─────────────────────────────────────────┤
│  Layer 1: Input Validation              │
├─────────────────────────────────────────┤
│  Layer 2: Authentication (JWT)          │
├─────────────────────────────────────────┤
│  Layer 3: Authorization (RBAC)          │
├─────────────────────────────────────────┤
│  Layer 4: Data Encryption               │
├─────────────────────────────────────────┤
│  Layer 5: Audit Logging                 │
└─────────────────────────────────────────┘
```

---

## 2. Authentication

### 2.1 User Authentication

**Mechanism:** JSON Web Tokens (JWT)

**Token Structure:**

```
Header.Payload.Signature
```

**Header:**
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload (Access Token):**
```json
{
  "sub": "1",
  "username": "john.doe",
  "email": "john@example.com",
  "role": "cashier",
  "iat": 1697942400,
  "exp": 1697944200,
  "iss": "kharisma-abadi"
}
```

**Payload (Refresh Token):**
```json
{
  "sub": "1",
  "type": "refresh",
  "iat": 1697942400,
  "exp": 1698547200
}
```

### 2.2 Token Management

**Access Token:**
- Expiry: 30 minutes
- Storage: Memory + localStorage
- Use: API requests
- Rotation: Auto-refresh on expiry

**Refresh Token:**
- Expiry: 7 days
- Storage: localStorage (httpOnly would be better)
- Use: Get new access token
- Rotation: Issued on login and refresh
- Revocation: On logout

**Token Rotation Flow:**

```
┌─────────────┐
│   Login     │
└──────┬──────┘
       │ username + password
       ↓
┌──────────────────────┐
│ Validate Credentials │
└──────┬───────────────┘
       │
       ├─→ Invalid → Return 401
       │
       ↓ Valid
┌─────────────────────────────────────┐
│ Generate Tokens                     │
│ • Access (30 min)                   │
│ • Refresh (7 days)                  │
└──────┬──────────────────────────────┘
       │
       ↓
┌─────────────────────────────────────┐
│ Return to Client                    │
│ • access_token (in memory)          │
│ • refresh_token (in localStorage)   │
└─────────────────────────────────────┘
```

### 2.3 Password Security

**Password Hashing:**
- Algorithm: bcrypt
- Rounds: 12
- Never stored in plain text
- Never transmitted in logs

**Go Implementation:**

```go
import "golang.org/x/crypto/bcrypt"

// Hash password
hashedPassword, err := bcrypt.GenerateFromPassword(
    []byte(password),
    bcrypt.DefaultCost, // Cost of 10
)

// Verify password
err := bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
```

**Password Requirements:**

```
Minimum Length:  8 characters
Maximum Length:  128 characters (prevent DoS)
Must Include:
  • Uppercase letter (A-Z)
  • Lowercase letter (a-z)
  • Digit (0-9)
  • Special character (!@#$%^&*)
Not Allowed:
  • Username
  • Email (first part)
  • Dictionary words
  • Sequential characters (abc, 123)
  • Repeated characters (aaa, 111)
```

**Password Validation Go Code:**

```go
package security

import "regexp"

func ValidatePassword(password string) error {
    if len(password) < 8 || len(password) > 128 {
        return errors.New("password must be 8-128 characters")
    }
    
    if !regexp.MustCompile(`[A-Z]`).MatchString(password) {
        return errors.New("password must contain uppercase letter")
    }
    
    if !regexp.MustCompile(`[a-z]`).MatchString(password) {
        return errors.New("password must contain lowercase letter")
    }
    
    if !regexp.MustCompile(`[0-9]`).MatchString(password) {
        return errors.New("password must contain digit")
    }
    
    if !regexp.MustCompile(`[!@#$%^&*]`).MatchString(password) {
        return errors.New("password must contain special character")
    }
    
    return nil
}
```

### 2.4 Session Management

**Session Security:**

```go
type SessionToken struct {
    UserID    uint
    ExpiresAt time.Time
    IssuedAt  time.Time
    LastUsed  time.Time
}

// Validate session token
func ValidateSession(token string) (*SessionToken, error) {
    // 1. Parse JWT
    claims, err := jwt.ParseWithClaims(token, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
        return jwtSecret, nil
    })
    
    // 2. Validate signature
    if !claims.Valid {
        return nil, ErrInvalidToken
    }
    
    // 3. Check expiration
    if claims.ExpiresAt.Before(time.Now()) {
        return nil, ErrTokenExpired
    }
    
    // 4. Check blacklist (if logout)
    if isTokenBlacklisted(token) {
        return nil, ErrTokenBlacklisted
    }
    
    return &SessionToken{...}, nil
}
```

**Session Timeout:**
- Inactivity timeout: 30 minutes
- Absolute timeout: 8 hours
- Token refresh: Automatic before expiry
- Logout: Immediate revocation

---

## 3. Authorization & Access Control

### 3.1 Role-Based Access Control (RBAC)

**Roles Definition:**

```go
const (
    RoleAdmin        = "ADMIN"         // Full system access
    RoleManager      = "MANAGER"       // Management & reports
    RoleCashier      = "CASHIER"       // Order & payment creation
    RoleServiceStaff = "SERVICE_STAFF" // Service execution
    RoleViewer       = "VIEWER"        // Read-only access
)
```

**Permissions Matrix:**

| Resource | Admin | Manager | Cashier | Service Staff | Viewer |
|----------|-------|---------|---------|---------------|--------|
| Users | CRUD | R | R | - | - |
| Orders | CRUD | R | CU | CU | R |
| Payments | CRUD | R | CU | - | R |
| Reports | R | R | R | - | - |
| Settings | CRU | - | - | - | - |

**Legend:** C=Create, R=Read, U=Update, D=Delete

### 3.2 Authorization Middleware

**Go Implementation:**

```go
package middleware

import "github.com/gofiber/fiber/v2"

// AuthMiddleware validates JWT token
func AuthMiddleware(c *fiber.Ctx) error {
    token := c.Get("Authorization")
    
    if token == "" {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "missing token",
        })
    }
    
    claims, err := ValidateToken(token)
    if err != nil {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "invalid token",
        })
    }
    
    c.Locals("user", claims)
    return c.Next()
}

// RequireRole middleware checks user role
func RequireRole(roles ...string) fiber.Handler {
    return func(c *fiber.Ctx) error {
        claims := c.Locals("user").(*CustomClaims)
        
        for _, role := range roles {
            if claims.Role == role {
                return c.Next()
            }
        }
        
        return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
            "error": "insufficient permissions",
        })
    }
}
```

**Usage:**

```go
// Protect routes
app.Post("/orders", AuthMiddleware, RequireRole("cashier", "manager", "admin"), CreateOrder)
app.Delete("/users/:id", AuthMiddleware, RequireRole("admin"), DeleteUser)
```

### 3.3 Resource-Level Authorization

**Example: Order Update Authorization**

```go
func UpdateOrder(c *fiber.Ctx) error {
    claims := c.Locals("user").(*CustomClaims)
    orderID := c.Params("id")
    
    order, err := repo.GetOrder(orderID)
    if err != nil {
        return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
            "error": "order not found",
        })
    }
    
    // Authorization logic
    switch order.Status {
    case "pending":
        // Only cashier or creator can update
        if claims.Role != "cashier" && order.CreatedBy != claims.UserID {
            return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
                "error": "not authorized",
            })
        }
    case "in_progress":
        // Only service staff or manager
        if claims.Role != "service_staff" && claims.Role != "manager" {
            return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
                "error": "not authorized",
            })
        }
    }
    
    // Proceed with update
    return UpdateOrderHandler(c)
}
```

---

## 4. Data Security

### 4.1 Data Encryption

**In Transit:**
- Protocol: HTTPS/TLS 1.3+
- Certificate: Let's Encrypt (auto-renewed)
- Cipher suites: Modern, secure ciphers only
- HSTS: Enabled (strict-transport-security)

**At Rest:**
- Sensitive fields encrypted
- Encryption key: Stored securely (env var, secret manager)
- Algorithm: AES-256-GCM

**Go Implementation:**

```go
import "crypto/aes"

func EncryptField(plaintext string, key []byte) (string, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return "", err
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return "", err
    }
    
    nonce := make([]byte, gcm.NonceSize())
    _, err = io.ReadFull(rand.Reader, nonce)
    if err != nil {
        return "", err
    }
    
    ciphertext := gcm.Seal(nonce, nonce, []byte(plaintext), nil)
    return hex.EncodeToString(ciphertext), nil
}
```

### 4.2 SQL Injection Prevention

**Protected by ORM:**
```go
// GOOD - Using GORM (parameterized)
var order Order
db.Where("order_id = ?", orderID).First(&order)

// BAD - String concatenation (vulnerable!)
// db.Where("order_id = " + orderID).First(&order)
```

**Additional Layer:**
```go
// Input validation before ORM
if !isValidOrderID(orderID) {
    return ErrInvalidInput
}
```

### 4.3 XSS Protection

**Frontend (Vue 3):**

```vue
<!-- GOOD - Auto-escapes by default -->
<div>{{ userInput }}</div>

<!-- BAD - Only for trusted HTML -->
<!-- <div v-html="userInput"></div> -->
```

**Backend (Go):**

```go
import "html"

// Escape output
escaped := html.EscapeString(userInput)
```

**Content Security Policy (CSP):**

```go
app.Use(func(c *fiber.Ctx) error {
    c.Set("Content-Security-Policy", 
        "default-src 'self'; " +
        "script-src 'self' 'unsafe-inline'; " +
        "style-src 'self' 'unsafe-inline'; " +
        "img-src 'self' data:; " +
        "font-src 'self'")
    return c.Next()
})
```

### 4.4 CSRF Protection

**Token Generation:**

```go
// Generate CSRF token
func GenerateCSRFToken() string {
    b := make([]byte, 32)
    rand.Read(b)
    return base64.StdEncoding.EncodeToString(b)
}
```

**Validation:**

```go
// Check token in POST requests
func ValidateCSRF(c *fiber.Ctx) error {
    if c.Method() == "POST" {
        token := c.FormValue("csrf_token")
        sessionToken := c.Cookie("csrf_token")
        
        if token != sessionToken {
            return ErrInvalidCSRFToken
        }
    }
    return nil
}
```

### 4.5 Data Privacy

**Personal Information Protection:**

```sql
-- Encrypt sensitive fields
ALTER TABLE users ADD COLUMN email_encrypted VARCHAR(255);

-- Mask in logs
-- Never log: passwords, tokens, payment info

-- Access logging
CREATE TABLE access_logs (
    id INT PRIMARY KEY,
    user_id INT,
    accessed_resource VARCHAR(100),
    accessed_at TIMESTAMP,
    reason VARCHAR(255)
);
```

**GDPR Compliance:**

- Right to access: Users can download their data
- Right to deletion: Implement data deletion
- Data minimization: Collect only necessary data
- Retention: Delete data after retention period

---

## 5. API Security

### 5.1 Input Validation

**Fiber Middleware:**

```go
app.Post("/orders", ValidateRequest, AuthMiddleware, CreateOrder)

func ValidateRequest(c *fiber.Ctx) error {
    var req CreateOrderRequest
    
    if err := c.BodyParser(&req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": "invalid request",
        })
    }
    
    // Validate using validator
    validate := validator.New()
    if err := validate.Struct(req); err != nil {
        return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
            "errors": err.Error(),
        })
    }
    
    c.Locals("request", req)
    return c.Next()
}
```

**Request Struct with Validation Tags:**

```go
type CreateOrderRequest struct {
    CustomerID  uint            `json:"customer_id" validate:"required,gt=0"`
    ServiceType string          `json:"service_type" validate:"required,oneof=car_wash laundry carpet water"`
    TotalAmount decimal.Decimal `json:"total_amount" validate:"required,gt=0"`
    Notes       string          `json:"notes" validate:"max=500"`
}
```

### 5.2 Rate Limiting

**Implementation:**

```go
import "github.com/gofiber/fiber/v2/middleware/limiter"

// Global rate limiter
app.Use(limiter.New(limiter.Config{
    Max:        100,                  // 100 requests
    Expiration: 1 * time.Minute,      // per minute
    KeyGenerator: func(c *fiber.Ctx) string {
        return c.IP()                 // per IP
    },
    LimitReached: func(c *fiber.Ctx) error {
        return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
            "error": "rate limit exceeded",
        })
    },
}))

// Endpoint-specific limits
app.Post("/auth/login", limiter.New(limiter.Config{
    Max:        5,
    Expiration: 15 * time.Minute,
}), LoginHandler)
```

**Rate Limit Rules:**

| Endpoint | Limit | Window |
|----------|-------|--------|
| /auth/login | 5 | 15 min |
| /auth/register | 3 | 1 hour |
| /orders | 100 | 1 hour |
| /payments | 50 | 1 hour |
| /reports | 20 | 1 hour |

### 5.3 CORS Configuration

**Fiber CORS Middleware:**

```go
app.Use(cors.New(cors.Config{
    AllowOrigins:     "http://localhost:5173,https://app.example.com",
    AllowMethods:     "GET,POST,PATCH,DELETE,OPTIONS",
    AllowHeaders:     "Origin,Content-Type,Authorization",
    ExposeHeaders:    "Content-Length,X-RateLimit-Limit",
    AllowCredentials: true,
    MaxAge:           3600,
}))
```

### 5.4 Security Headers

**Implementation:**

```go
func SecurityHeaders(c *fiber.Ctx) error {
    c.Set("X-Content-Type-Options", "nosniff")
    c.Set("X-Frame-Options", "DENY")
    c.Set("X-XSS-Protection", "1; mode=block")
    c.Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
    c.Set("Content-Security-Policy", "default-src 'self'")
    c.Set("Referrer-Policy", "strict-origin-when-cross-origin")
    return c.Next()
}

app.Use(SecurityHeaders)
```

---

## 6. Infrastructure Security

### 6.1 Database Security

**Connection Security:**

```go
type DBConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    Database string
    SSL      bool // Always use SSL in production
}

// Example
dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?tls=true",
    config.User,
    config.Password,
    config.Host,
    config.Port,
    config.Database,
)
```

**Least Privilege:**

```sql
-- Create user with minimal permissions
CREATE USER 'kharisma'@'localhost' IDENTIFIED BY 'strong_password';

-- Grant only necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON kharisma_db.* TO 'kharisma'@'localhost';

-- No admin privileges
-- No CREATE/DROP permissions
```

**Backup Security:**

```bash
#!/bin/bash
# Encrypted daily backup
mysqldump -u user -p database | \
openssl enc -aes-256-cbc -salt -out backup.sql.enc

# Store backup
cp backup.sql.enc /secure/backup/location
```

### 6.2 Environment Variables

**Secure Storage:**

```bash
# .env (NEVER commit to git)
DB_PASSWORD=SecurePassword123
JWT_SECRET=VeryLongSecureJWTSecret
API_KEY=SecureAPIKey

# .env.example (commit to git, without values)
DB_PASSWORD=
JWT_SECRET=
API_KEY=
```

**GO Implementation:**

```go
import "github.com/joho/godotenv"

func init() {
    godotenv.Load()
    
    // Validate required variables
    requiredVars := []string{"DB_PASSWORD", "JWT_SECRET", "API_KEY"}
    for _, v := range requiredVars {
        if os.Getenv(v) == "" {
            log.Fatalf("Missing required env var: %s", v)
        }
    }
}
```

### 6.3 Container Security

**Dockerfile Best Practices:**

```dockerfile
# Use specific versions, not 'latest'
FROM golang:1.21-alpine

# Don't run as root
RUN addgroup -g 1001 -S golang
RUN adduser -u 1001 -S golang -G golang

# Remove unnecessary packages
RUN apk del apk-tools ca-certificates

# Use multi-stage build
FROM alpine:latest
COPY --from=builder /app/kharisma-api /app/

# Run as non-root
USER golang

EXPOSE 3000
CMD ["/app/kharisma-api"]
```

**Image Security:**

```bash
# Scan for vulnerabilities
docker scan kharisma/api:latest

# Use minimal base image
FROM alpine:latest  # ~5MB vs ubuntu:latest ~80MB
```

### 6.4 Network Security

**Firewall Rules:**

```
Port 80:   HTTP → HTTPS redirect
Port 443:  HTTPS (TLS 1.3)
Port 3306: MySQL (internal only, not exposed)
Port 3000: API (internal or load balancer)
```

**Docker Network:**

```yaml
services:
  api:
    networks:
      - internal
  db:
    networks:
      - internal
    expose:
      - "3306"  # Not published externally

networks:
  internal:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.enable_ip_masquerade: "true"
```

---

## 7. Incident Response

### 7.1 Security Incident Categories

**Critical (Immediate Response):**
- Unauthorized data access
- Successful injection attacks
- Service compromise
- Data breach

**High (1-4 hour Response):**
- Failed attack attempts (>10)
- Suspicious user activity
- Configuration errors
- DoS attempts

**Medium (1 day Response):**
- Weak password detection
- Outdated dependencies
- Low-priority vulnerability
- Access anomalies

### 7.2 Incident Response Procedure

**Detection:**
```
1. Monitor logs for anomalies
2. Alert on suspicious patterns
3. Review automated security checks
4. Analyze security warnings
```

**Response:**
```
1. Isolate affected component
2. Preserve logs and evidence
3. Notify security team
4. Assess impact and scope
5. Implement fix
6. Test in staging
7. Deploy to production
8. Monitor for recurrence
```

**Post-Incident:**
```
1. Document incident details
2. Root cause analysis
3. Implement preventive measures
4. Update security policies
5. Team training
6. Public disclosure (if necessary)
```

### 7.3 Logging & Monitoring

**Security Log Format:**

```json
{
  "timestamp": "2025-10-22T10:30:00Z",
  "event_type": "security_event",
  "severity": "high",
  "user_id": 1,
  "ip_address": "192.168.1.100",
  "action": "login_attempt",
  "status": "success",
  "details": {
    "location": "Jakarta",
    "device": "Chrome/Win10"
  }
}
```

**Log Retention:**
- Security logs: 1 year
- Audit logs: 2 years
- Access logs: 90 days
- Application logs: 30 days

---

## 8. Compliance & Auditing

### 8.1 Security Standards

**OWASP Top 10:**
1. ✅ Injection - Parameterized queries, input validation
2. ✅ Broken Authentication - JWT, password hashing
3. ✅ Sensitive Data Exposure - Encryption, HTTPS
4. ✅ XML External Entities - JSON only, validation
5. ✅ Broken Access Control - RBAC, authorization checks
6. ✅ Security Misconfiguration - Security headers, minimal base image
7. ✅ XSS - Input validation, output encoding
8. ✅ Insecure Deserialization - Strict typing, validation
9. ✅ Using Components with Known Vulnerabilities - Dependency scanning
10. ✅ Insufficient Logging & Monitoring - Comprehensive logging

### 8.2 Audit Trail

**Events to Log:**

```sql
CREATE TABLE audit_trail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_type ENUM('login', 'logout', 'create', 'update', 'delete', 'access'),
    user_id INT,
    resource_type VARCHAR(50),
    resource_id INT,
    action VARCHAR(10),
    old_value JSON,
    new_value JSON,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    status ENUM('success', 'failure'),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_event_type (event_type)
) ENGINE=InnoDB;
```

### 8.3 Dependency Management

**Vulnerability Scanning:**

```bash
# Go dependencies
go mod tidy
go mod verify
go list -m all | xargs -I {} go mod why {}

# Security check
go install github.com/securego/gosec/v2/cmd/gosec@latest
gosec ./...
```

**Update Policy:**
- Security patches: Apply immediately
- Minor updates: Apply monthly
- Major updates: Test thoroughly, apply quarterly

### 8.4 Penetration Testing

**Frequency:** Quarterly

**Scope:**
- API endpoints
- Authentication flows
- Authorization checks
- Data validation
- SQL injection
- XSS vulnerabilities
- CSRF protection

**Example Test Cases:**

```gherkin
Scenario: Unauthorized user cannot access protected endpoint
  Given unauthenticated user
  When I call GET /api/v1/orders
  Then response status is 401
  And error code is "UNAUTHORIZED"

Scenario: Invalid JWT token is rejected
  Given invalid JWT token
  When I call GET /api/v1/orders
  Then response status is 401
  And error code is "INVALID_TOKEN"

Scenario: Insufficient role cannot perform action
  Given user with "viewer" role
  When I call POST /api/v1/orders
  Then response status is 403
  And error code is "FORBIDDEN"
```

---

## Checklist: Security Implementation

- [ ] JWT authentication implemented and tested
- [ ] Password hashing with bcrypt configured
- [ ] RBAC roles and permissions defined
- [ ] SQL injection prevention verified
- [ ] XSS protection enabled
- [ ] CSRF tokens implemented
- [ ] Rate limiting configured
- [ ] CORS properly restricted
- [ ] Security headers added
- [ ] HTTPS/TLS configured
- [ ] Database encryption enabled
- [ ] Environment variables secured
- [ ] Audit logging implemented
- [ ] Incident response plan documented
- [ ] Dependency vulnerabilities checked
- [ ] Penetration testing completed
- [ ] Security training conducted

---

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8949)
- [NIST Password Guidelines](https://pages.nist.gov/800-63-3/)
- [Go Security Best Practices](https://golang.org/doc/effective_go)

---

This specification provides comprehensive security guidance for implementation and ongoing maintenance.
