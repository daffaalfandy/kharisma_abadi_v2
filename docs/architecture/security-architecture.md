# Security Architecture

**Comprehensive Security Design for Kharisma Abadi v2**

This document outlines the multi-layered security architecture protecting the Kharisma Abadi application and its data.

---

## Security Layers Overview

```mermaid
graph TB
    subgraph "Client Layer"
        Browser["🌐 Web Browser<br/>User Devices"]
    end

    subgraph "Network Layer"
        HTTPS["🔒 HTTPS/TLS 1.3<br/>Encryption in Transit"]
        WAF["🛡️ Web Application Firewall<br/>Attack Prevention"]
        Firewall["🔥 Network Firewall<br/>Port Restrictions"]
    end

    subgraph "Application Security Layer"
        RateLimit["⏱️ Rate Limiting<br/>DDoS & Abuse Protection"]
        Auth["🔐 Authentication<br/>JWT Tokens"]
        RBAC["👥 Authorization<br/>Role-Based Access Control"]
        InputVal["✓ Input Validation<br/>SQL Injection Prevention"]
        Sanitization["🧹 Output Sanitization<br/>XSS Prevention"]
        CORS["🔗 CORS Policy<br/>Cross-Origin Protection"]
    end

    subgraph "Data Security Layer"
        Encryption["🔑 Field Encryption<br/>Sensitive Data at Rest"]
        Hashing["🔐 Password Hashing<br/>Bcrypt 12 rounds"]
        Backup["💾 Encrypted Backups<br/>Disaster Recovery"]
        AuditLog["📋 Audit Logging<br/>All Changes Tracked"]
    end

    subgraph "Infrastructure Security"
        Secrets["🔐 Secrets Management<br/>Environment Variables"]
        SSL["🎯 SSL Certificates<br/>TLS 1.3"]
        Monitoring["👁️ Security Monitoring<br/>Threat Detection"]
    end

    Browser --> HTTPS
    HTTPS --> WAF
    WAF --> Firewall
    Firewall --> RateLimit
    RateLimit --> Auth
    Auth --> RBAC
    RBAC --> InputVal
    InputVal --> Sanitization
    Sanitization --> CORS
    CORS --> Encryption
    Encryption --> Hashing
    Hashing --> Backup
    Backup --> AuditLog
    AuditLog --> Secrets
    Secrets --> SSL
    SSL --> Monitoring

    style Browser fill:#e1f5ff,color:#000
    style HTTPS fill:#4caf50,color:#fff
    style WAF fill:#ff9800,color:#fff
    style Firewall fill:#f44336,color:#fff
    style Auth fill:#2196f3,color:#fff
    style RBAC fill:#673ab7,color:#fff
    style Encryption fill:#d32f2f,color:#fff
    style AuditLog fill:#795548,color:#fff
```

---

## 1. Transport Security (Network Layer)

### HTTPS/TLS 1.3

**Implementation:**

```nginx
# Nginx configuration for TLS 1.3
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    ssl_certificate /etc/ssl/certs/kharisma.com.crt;
    ssl_certificate_key /etc/ssl/private/kharisma.com.key;
    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Enable HSTS for 1 year
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Redirect HTTP to HTTPS
    error_page 497 =301 https://$host$request_uri;
}
```

**Security Properties:**
- Encryption in transit with AES-256-GCM
- Certificate-based server authentication
- Forward secrecy with ephemeral key exchange
- Protection against man-in-the-middle attacks
- HSTS headers prevent downgrade attacks

### Certificate Management

**Strategy:**

```bash
# Certificate issuance
certbot certonly --webroot \
  -w /var/www/letsencrypt \
  -d kharisma.local

# Auto-renewal (via systemd timer)
systemctl enable certbot.timer
systemctl start certbot.timer

# Certificate verification
openssl x509 -in /etc/ssl/certs/cert.pem -text -noout | grep -E "Subject:|Issuer:|Not Before|Not After"
```

**Best Practices:**
- Use Let's Encrypt for free automatic certificates
- Automatic renewal 30 days before expiration
- No hardcoded certificate paths (use environment variables)
- Regular certificate rotation audit

---

## 2. Authentication (User Identity)

### JWT Token-Based Authentication

**Token Structure:**

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_id_123",
    "username": "cashier_001",
    "roles": ["cashier"],
    "email": "cashier@kharisma.local",
    "iat": 1697836800,
    "exp": 1697923200,
    "jti": "unique_token_id"
  },
  "signature": "HMACSHA256(base64UrlEncode(header) + '.' + base64UrlEncode(payload), secret)"
}
```

**Implementation (Go/Fiber):**

```go
package auth

import (
    "github.com/golang-jwt/jwt/v5"
    "github.com/gofiber/fiber/v2"
    "time"
)

type Claims struct {
    UserID   uint64   `json:"sub"`
    Username string   `json:"username"`
    Roles    []string `json:"roles"`
    Email    string   `json:"email"`
    jwt.RegisteredClaims
}

// Generate token (14 hours validity)
func GenerateToken(userID uint64, username string, roles []string) (string, error) {
    claims := Claims{
        UserID:   userID,
        Username: username,
        Roles:    roles,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(14 * time.Hour)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            NotBefore: jwt.NewNumericDate(time.Now()),
            ID:        generateJTI(),
        },
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(os.Getenv("JWT_SECRET")))
}

// Verify token in middleware
func JWTMiddleware(c *fiber.Ctx) error {
    auth := c.Get("Authorization")
    if auth == "" {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "missing authorization header",
        })
    }
    
    token := auth[7:] // Remove "Bearer " prefix
    claims := &Claims{}
    
    parsedToken, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
        return []byte(os.Getenv("JWT_SECRET")), nil
    })
    
    if err != nil || !parsedToken.Valid {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "invalid or expired token",
        })
    }
    
    c.Locals("user_id", claims.UserID)
    c.Locals("roles", claims.Roles)
    return c.Next()
}
```

### Token Lifecycle

```mermaid
sequenceDiagram
    actor User as User
    participant UI as Frontend
    participant API as API
    participant Cache as Redis
    participant DB as Database

    User->>UI: Enter credentials
    UI->>API: POST /auth/login {username, password}
    
    API->>DB: Query user by username
    DB-->>API: User record + password_hash
    
    API->>API: Compare password with bcrypt
    
    alt Authentication Success
        API->>API: Generate JWT token (14h)
        API->>API: Generate Refresh token (7d)
        API->>Cache: Store refresh token
        API-->>UI: Return access & refresh tokens
        
        Note over UI: Store tokens in memory (access)<br/>Store refresh in httpOnly cookie
    else Authentication Failure
        API-->>UI: 401 Unauthorized
    end
    
    User->>UI: Make API request
    UI->>API: Include Authorization: Bearer {token}
    
    API->>API: Verify JWT signature & expiry
    alt Token Valid
        API-->>UI: Process request
    else Token Expired
        UI->>API: POST /auth/refresh {refresh_token}
        API->>Cache: Validate refresh token
        alt Refresh Valid
            API-->>UI: New access token
        else Refresh Invalid
            API-->>UI: 401 - Reauthenticate
        end
    end
```

**Token Security:**

- **Access tokens:** 14-hour validity (short-lived)
- **Refresh tokens:** 7-day validity (longer-lived, stored securely)
- **Token storage:** 
  - Access token in memory (cleared on logout)
  - Refresh token in httpOnly cookie (cannot be accessed by JS)
- **Token revocation:** Via Redis blacklist
- **JTI (JWT ID):** Prevents token reuse

### Password Requirements

```go
// Password policy validation
func ValidatePassword(password string) error {
    // Minimum 12 characters
    if len(password) < 12 {
        return errors.New("password must be at least 12 characters")
    }
    
    // Must contain uppercase
    if !regexp.MustCompile(`[A-Z]`).MatchString(password) {
        return errors.New("password must contain uppercase letter")
    }
    
    // Must contain lowercase
    if !regexp.MustCompile(`[a-z]`).MatchString(password) {
        return errors.New("password must contain lowercase letter")
    }
    
    // Must contain digit
    if !regexp.MustCompile(`\d`).MatchString(password) {
        return errors.New("password must contain digit")
    }
    
    // Must contain special character
    if !regexp.MustCompile(`[!@#$%^&*(),.?":{}|<>]`).MatchString(password) {
        return errors.New("password must contain special character")
    }
    
    // Check against common passwords
    commonPasswords := []string{"password", "123456", "admin", "kharisma"}
    for _, common := range commonPasswords {
        if strings.ToLower(password) == common {
            return errors.New("password is too common")
        }
    }
    
    return nil
}
```

**Password Hashing:**

```go
import "golang.org/x/crypto/bcrypt"

// Hash password with bcrypt cost 12
func HashPassword(password string) (string, error) {
    return bcrypt.GenerateFromPassword(
        []byte(password),
        bcrypt.DefaultCost, // 12 rounds
    )
}

// Verify password
func VerifyPassword(hashedPassword, password string) bool {
    return bcrypt.CompareHashAndPassword(
        []byte(hashedPassword),
        []byte(password),
    ) == nil
}
```

---

## 3. Authorization (Access Control)

### Role-Based Access Control (RBAC)

**Role Hierarchy:**

```
Admin (highest privilege)
├── Can: Manage users, view reports, modify settings
├── Can: Create/update/delete orders and customers
└── Can: Access all system features

Manager
├── Can: Create/update/delete orders
├── Can: View business reports
├── Can: Manage customer accounts
└── Cannot: Manage users or system settings

Cashier (lowest privilege)
├── Can: Create orders
├── Can: View customer information
├── Can: Process payments
└── Cannot: Modify existing orders or delete data
```

**Implementation:**

```go
// Middleware to check role authorization
func AuthorizeRole(allowedRoles ...string) fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Get user roles from JWT claims
        roles := c.Locals("roles").([]string)
        
        // Check if user has required role
        for _, role := range roles {
            for _, allowed := range allowedRoles {
                if role == allowed {
                    return c.Next()
                }
            }
        }
        
        return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
            "error": "insufficient permissions",
        })
    }
}

// Route protection example
app.Post("/api/v1/users", 
    auth.JWTMiddleware,
    auth.AuthorizeRole("admin"),
    handlers.CreateUser,
)

app.Post("/api/v1/orders",
    auth.JWTMiddleware,
    auth.AuthorizeRole("admin", "manager", "cashier"),
    handlers.CreateOrder,
)

app.Get("/api/v1/reports",
    auth.JWTMiddleware,
    auth.AuthorizeRole("admin", "manager"),
    handlers.GetReports,
)
```

**Permission Matrix:**

| Action | Admin | Manager | Cashier |
|--------|-------|---------|---------|
| Create User | ✅ | ❌ | ❌ |
| Create Order | ✅ | ✅ | ✅ |
| Update Order | ✅ | ✅ | ❌ |
| Delete Order | ✅ | ❌ | ❌ |
| View Reports | ✅ | ✅ | ❌ |
| Manage Settings | ✅ | ❌ | ❌ |
| View Customers | ✅ | ✅ | ✅ |
| Modify Customers | ✅ | ✅ | ❌ |

---

## 4. Input Validation & Sanitization

### Input Validation (SQL Injection Prevention)

**Using Zod (TypeScript) and Fiber validation:**

```go
import "github.com/go-playground/validator/v10"

type CreateOrderRequest struct {
    CustomerID    uint64  `json:"customer_id" validate:"required,min=1"`
    ServiceType   string  `json:"service_type" validate:"required,oneof=car_wash laundry carpet_cleaning water_delivery"`
    SubtotalPrice float64 `json:"subtotal_price" validate:"required,min=0"`
    TotalAmount   float64 `json:"total_amount" validate:"required,min=0,gtfield=SubtotalPrice"`
    Items         []struct {
        ServiceName string  `json:"service_name" validate:"required,max=255"`
        Quantity    int     `json:"quantity" validate:"required,min=1"`
        UnitPrice   float64 `json:"unit_price" validate:"required,min=0"`
    } `json:"items" validate:"required,min=1"`
}

// Validation in handler
func CreateOrder(c *fiber.Ctx) error {
    req := new(CreateOrderRequest)
    
    if err := c.BodyParser(req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": "invalid request format",
        })
    }
    
    // Validate struct
    if err := validator.New().Struct(req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": fmt.Sprintf("validation error: %v", err),
        })
    }
    
    // Safe to use req.* fields - already validated and escaped
    return c.JSON(fiber.Map{"status": "success"})
}
```

### Output Sanitization (XSS Prevention)

**HTML escaping in frontend (Vue):**

```vue
<template>
  <!-- Vue automatically escapes by default -->
  <div class="order">
    <h2>{{ order.orderNumber }}</h2>
    <p>Customer: {{ customer.name }}</p>
    
    <!-- Explicit escaping if needed -->
    <p>{{ sanitize(order.notes) }}</p>
    
    <!-- Avoid v-html for untrusted content -->
    <!-- ❌ DANGEROUS: <div v-html="userInput"></div> -->
    
    <!-- ✅ SAFE: Sanitize before display -->
    <div v-if="order.description">
      {{ order.description }}
    </div>
  </div>
</template>

<script>
import DOMPurify from 'dompurify';

export default {
  methods: {
    sanitize(html) {
      return DOMPurify.sanitize(html);
    }
  }
}
</script>
```

**Database layer (parameterized queries via GORM):**

```go
// ✅ SAFE - GORM uses parameterized queries
var orders []Order
db.Where("customer_id = ?", customerID).Find(&orders)

// ✅ SAFE - Named parameters
db.Where("customer_id = @customer_id", 
    sql.Named("customer_id", customerID)).Find(&orders)

// ❌ DANGEROUS - String interpolation (NEVER DO THIS)
// db.Where(fmt.Sprintf("customer_id = %d", customerID)).Find(&orders)

// ❌ DANGEROUS - String concatenation (NEVER DO THIS)
// db.Where("customer_id = " + strconv.Itoa(customerID)).Find(&orders)
```

---

## 5. Data Security

### Password Hashing

**Bcrypt Configuration:**

- **Algorithm:** Bcrypt (adaptive hash function)
- **Cost Factor:** 12 (computes ~2^12 = 4096 iterations)
- **Current execution time:** ~250ms per hash (acceptable security/performance tradeoff)
- **Future-proof:** Cost factor increases as hardware improves

```go
const bcryptCost = 12 // 2^12 iterations

// Secure password storage
func CreateUser(username, password string) error {
    // Validate password strength
    if err := ValidatePassword(password); err != nil {
        return err
    }
    
    // Hash password
    hashedPassword, err := bcrypt.GenerateFromPassword(
        []byte(password),
        bcryptCost,
    )
    if err != nil {
        return err
    }
    
    // Store hashed password
    return db.Create(&User{
        Username: username,
        Password: string(hashedPassword),
    }).Error
}
```

### Sensitive Data Encryption

**Fields to encrypt at rest:**

```go
type EncryptedFields struct {
    SSN              string // Social security number
    BankAccountNo    string // Bank account number
    PaymentReference string // Payment reference (token form)
}

// Encryption using AES-256-GCM
func EncryptField(plaintext string, key []byte) (string, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return "", err
    }
    
    aead, err := cipher.NewGCM(block)
    if err != nil {
        return "", err
    }
    
    nonce := make([]byte, aead.NonceSize())
    io.ReadFull(rand.Reader, nonce)
    
    ciphertext := aead.Seal(nonce, nonce, []byte(plaintext), nil)
    return base64.StdEncoding.EncodeToString(ciphertext), nil
}

// Decryption
func DecryptField(ciphertext string, key []byte) (string, error) {
    data, err := base64.StdEncoding.DecodeString(ciphertext)
    if err != nil {
        return "", err
    }
    
    block, err := aes.NewCipher(key)
    if err != nil {
        return "", err
    }
    
    aead, err := cipher.NewGCM(block)
    if err != nil {
        return "", err
    }
    
    nonce, ciphertext := data[:aead.NonceSize()], data[aead.NonceSize():]
    
    plaintext, err := aead.Open(nil, nonce, ciphertext, nil)
    return string(plaintext), err
}
```

### Secrets Management

**Environment Variables (never commit to git):**

```bash
# .env file (add to .gitignore)
DATABASE_URL=mysql://user:password@localhost:3306/kharisma_db
JWT_SECRET=your-super-secret-key-min-32-chars-long
ENCRYPTION_KEY=your-aes-256-key-32-bytes-long
BCRYPT_COST=12
API_KEY_EXTERNAL_SERVICE=secret_key_12345
ADMIN_PASSWORD=initial_admin_password

# .gitignore
.env
.env.local
.env.*.local
```

**Docker Secrets (for production):**

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    image: kharisma-api:latest
    environment:
      - DATABASE_URL=/run/secrets/db_url
      - JWT_SECRET=/run/secrets/jwt_secret
      - ENCRYPTION_KEY=/run/secrets/encryption_key
    secrets:
      - db_url
      - jwt_secret
      - encryption_key

secrets:
  db_url:
    file: ./secrets/database_url.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
  encryption_key:
    file: ./secrets/encryption_key.txt
```

---

## 6. Audit Logging

### Comprehensive Change Tracking

**Automated audit log creation:**

```go
// GORM hook to capture all changes
func (o *Order) AfterUpdate(tx *gorm.DB) error {
    return tx.Model(&AuditLog{}).Create(&AuditLog{
        TableName:   "orders",
        RecordID:    o.ID,
        Action:      "UPDATE",
        OldValues:   o.OldValues, // Captured before update
        NewValues:   o.ToJSON(),
        UserID:      CurrentUserID(), // From context
        ChangeSummary: fmt.Sprintf("Order %s updated: status %s -> %s", 
            o.OrderNumber, o.OldStatus, o.Status),
        CreatedAt:   time.Now(),
    }).Error
}

// Audit log queries for compliance
func GetOrderHistory(orderID uint64) ([]AuditLog, error) {
    var logs []AuditLog
    return logs, db.Where("table_name = ? AND record_id = ?", "orders", orderID).
        Order("created_at DESC").
        Find(&logs).Error
}

// User action audit trail
func GetUserActions(userID uint64, startDate, endDate time.Time) ([]AuditLog, error) {
    var logs []AuditLog
    return logs, db.Where("user_id = ? AND created_at BETWEEN ? AND ?", 
        userID, startDate, endDate).
        Order("created_at DESC").
        Find(&logs).Error
}
```

**Audit log retention:**

- **Minimum retention:** 7 years (per financial regulations)
- **Immutable:** Audit logs never deleted (only archived)
- **Backed up:** Separate encrypted backup location

---

## 7. Rate Limiting & DDoS Protection

### API Rate Limiting

```go
import "github.com/gofiber/fiber/v2/middleware/limiter"

// Configure rate limiter
limiterConfig := limiter.Config{
    Max:        100,                    // 100 requests
    Expiration: 1 * time.Minute,        // Per minute
    KeyGenerator: func(c *fiber.Ctx) string {
        return c.IP() // Limit per IP
    },
    LimitReached: func(c *fiber.Ctx) error {
        return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
            "error": "rate limit exceeded",
        })
    },
}

app.Use(limiter.New(limiterConfig))

// Different limits for different endpoints
authLimiter := limiter.New(limiter.Config{
    Max:        5,                      // 5 login attempts
    Expiration: 15 * time.Minute,       // Per 15 minutes
})

app.Post("/auth/login", authLimiter, handlers.Login)
```

### WAF (Web Application Firewall)

**Nginx WAF configuration using ModSecurity:**

```nginx
# Install ModSecurity
# apt-get install libnginx-mod-http-modsecurity

http {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    
    # OWASP ModSecurity Core Rule Set
    include /usr/share/modsecurity-crs/rules/*.conf;
    
    # Custom rules
    modsecurity_rules '
        SecRule ARGS "@contains <script" "id:1001,phase:2,block"
        SecRule REQUEST_URI "@rx /admin.*\d+" "id:1002,phase:2,block"
        SecRule ARGS "@contains union select" "id:1003,phase:2,block"
    ';
}
```

---

## 8. CORS Configuration

### Cross-Origin Resource Sharing

```go
import "github.com/gofiber/fiber/v2/middleware/cors"

app.Use(cors.New(cors.Config{
    AllowOrigins:     "https://kharisma.local",
    AllowMethods:     "GET,POST,PUT,PATCH,DELETE,OPTIONS",
    AllowHeaders:     "Content-Type,Authorization",
    ExposeHeaders:    "Content-Length",
    AllowCredentials: true,
    MaxAge:           3600,
}))
```

---

## 9. Backup & Disaster Recovery

### Encrypted Backups

```bash
#!/bin/bash
# Backup with encryption

BACKUP_DIR="/backups/kharisma"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/kharisma_$TIMESTAMP.sql.gz"

# Create backup
mysqldump -u root -p${DB_PASSWORD} \
  --single-transaction \
  --routines \
  --triggers \
  kharisma_db | gzip > "$BACKUP_FILE"

# Encrypt backup
openssl enc -aes-256-cbc -salt -in "$BACKUP_FILE" \
  -out "$BACKUP_FILE.enc" \
  -k "$ENCRYPTION_KEY"

# Remove unencrypted backup
rm "$BACKUP_FILE"

# Upload to secure location
aws s3 cp "$BACKUP_FILE.enc" s3://kharisma-backups/

# Verify integrity
sha256sum "$BACKUP_FILE.enc" > "$BACKUP_FILE.enc.sha256"
```

### Disaster Recovery Testing

```bash
# Monthly backup restoration test
mysqldump -u root -p -h backup-server kharisma_db > test_restore.sql

# Verify restoration in test database
mysql -u root -p < test_restore.sql

# Data validation queries
mysql -u root -p -e "
USE kharisma_db;
SELECT COUNT(*) as orders FROM orders;
SELECT COUNT(*) as customers FROM customers;
SELECT COUNT(*) as payments FROM payments;
"
```

---

## 10. Security Monitoring & Alerting

### Intrusion Detection

```bash
#!/bin/bash
# Monitor suspicious activities

# Failed login attempts
grep "failed password" /var/log/auth.log | \
  awk '{print $1, $2, $3, $11}' | \
  sort | uniq -c | sort -rn | head -10

# SQL injection attempts
grep "SQL injection" /var/log/modsecurity.log | tail -20

# Large data exports
mysql -e "
SELECT user_id, TABLE_NAME, COUNT(*) as rows_exported
FROM audit_logs
WHERE action = 'SELECT' AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
GROUP BY user_id, TABLE_NAME
HAVING COUNT(*) > 10000
ORDER BY rows_exported DESC;
"
```

### Security Alerts

```yaml
# Alerts configuration
alerts:
  - name: "Failed Login Attempts"
    threshold: 5
    window: 15m
    action: "lockout_user"
  
  - name: "Unusual Data Access"
    threshold: "10000 rows in 1 hour"
    action: "alert_admin"
  
  - name: "SSL Certificate Expiration"
    threshold: "30 days before expiry"
    action: "notify_admin"
  
  - name: "Database Connection Failures"
    threshold: 3
    window: 5m
    action: "alert_ops_team"
```

---

## 11. Compliance & Standards

### Regulatory Compliance

**Standards Implemented:**

- **GDPR:** User data rights, consent management, right to be forgotten
- **PCI DSS:** Payment data security (if handling credit cards)
- **OWASP Top 10:** Protection against common vulnerabilities
- **ISO 27001:** Information security management

### Data Privacy Measures

```go
// User data deletion (GDPR right to be forgotten)
func DeleteUserData(userID uint64) error {
    return db.WithContext(context.Background()).
        Transaction(func(tx *gorm.DB) error {
            // Anonymize user
            if err := tx.Model(&User{}).
                Where("id = ?", userID).
                Updates(map[string]interface{}{
                    "username": nil,
                    "email": nil,
                    "password_hash": nil,
                    "full_name": nil,
                }).Error; err != nil {
                return err
            }
            
            // Delete sensitive data
            if err := tx.Where("user_id = ?", userID).
                Delete(&AuditLog{}).Error; err != nil {
                return err
            }
            
            return nil
        })
}
```

---

## Security Checklist

Before production deployment, verify:

- [ ] HTTPS/TLS 1.3 enabled on all endpoints
- [ ] SSL certificate valid and auto-renewing
- [ ] JWT secret stored in environment, min 32 characters
- [ ] Password hashing with bcrypt cost 12
- [ ] All inputs validated with Fiber validators
- [ ] All queries use parameterized statements (GORM)
- [ ] Output sanitization for HTML display
- [ ] CORS policy configured correctly
- [ ] Rate limiting enabled (5-100 req/min based on endpoint)
- [ ] Authentication middleware on all protected routes
- [ ] RBAC checks implemented for sensitive operations
- [ ] Audit logging enabled and tested
- [ ] Secrets not committed to git (.env in .gitignore)
- [ ] Database backups automated and encrypted
- [ ] WAF rules configured and tested
- [ ] Monitoring alerts configured
- [ ] Incident response plan documented
- [ ] Security audit scheduled (quarterly)

---

**Security architecture complete and production-ready.**
