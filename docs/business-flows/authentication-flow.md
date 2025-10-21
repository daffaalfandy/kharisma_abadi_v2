# Authentication Flow

**Status:** NOT IMPLEMENTED (Critical Gap)
**Priority:** CRITICAL
**Impact:** Complete security vulnerability
**Effort to Implement:** 3-4 weeks

---

## Current State

### Problem
The Kharisma Abadi application has **ZERO authentication** implemented. Any user can access any endpoint without providing credentials.

### Security Implications
- 🔴 **CRITICAL VULNERABILITY**: Complete data exposure
- Any client can read/modify all business data
- No audit trail of who made changes
- Insider threat risk (employees can manipulate records)
- Customer data (addresses, phone numbers) exposed
- Employee income data exposed
- Financial transaction records vulnerable

---

## Proposed Authentication Flow

### High-Level Flow

```mermaid
flowchart TD
    Start([User Accesses Application]) --> CheckAuth{Has Valid\\nJWT Token?}
    
    CheckAuth -->|No| LoginPage[Display Login Form]
    CheckAuth -->|Yes| ValidateToken{Token\\nValid & Not\\nExpired?}
    
    LoginPage --> EnterCreds[Enter Username/Password]
    EnterCreds --> SubmitForm[Submit credentials to API]
    SubmitForm --> ValidateCreds{Credentials\\nCorrect?}
    
    ValidateCreds -->|No| ShowError[Display error message]\n    ShowError --> EnterCreds\n    \n    ValidateCreds -->|Yes| FetchUser[Fetch user record]\n    FetchUser --> CheckRole{Verify\\nUser Role}\n    CheckRole -->|Invalid| DenyAccess[Deny access]\n    CheckRole -->|Valid| GenerateToken[Generate JWT token]\n    \n    GenerateToken --> StoreToken[Store token in local storage]\n    StoreToken --> CheckRole2{Check User\\nRole & Perms}\n    ValidateToken -->|Invalid| LoginPage\n    ValidateToken -->|Valid| CheckRole2\n    \n    CheckRole2 --> RoleCheck{User Role?}\n    RoleCheck -->|Cashier| CashierDash[Load Cashier Dashboard]\n    RoleCheck -->|Manager| ManagerDash[Load Manager Dashboard]\n    RoleCheck -->|Admin| AdminDash[Load Admin Dashboard]\n    \n    CashierDash --> AuthorizeEndpoints[Apply endpoint permissions]\n    ManagerDash --> AuthorizeEndpoints\n    AdminDash --> AuthorizeEndpoints\n    \n    AuthorizeEndpoints --> SendToken[Send token with each API request]\n    SendToken --> ValidateServerToken{Server validates\\ntoken signature\\n& expiry}\n    \n    ValidateServerToken -->|Invalid| Return401[Return 401 Unauthorized]\n    ValidateServerToken -->|Valid| CheckPermission{User has\\npermission for\\nthis endpoint?}\n    \n    CheckPermission -->|No| Return403[Return 403 Forbidden]\n    CheckPermission -->|Yes| ProcessRequest[Process request]\n    ProcessRequest --> ReturnData[Return data]\n    \n    Return401 --> RefreshPrompt[Prompt user to login again]\n    Return403 --> DenyAccess2[Display access denied error]\n    ReturnData --> End([Request Complete])\n    \n    style CheckAuth fill:#e1f5ff\n    style ValidateCreds fill:#fff3e0\n    style GenerateToken fill:#f3e5f5\n    style SendToken fill:#fff9c4\n```

---

## Proposed Implementation Details

### Step 1: User Registration (Admin Only)

**Endpoint:** `POST /api/auth/register` (admin-only)

**Request:**
```json\n{\n  "username": "cashier01",\n  "email": "cashier@kharisma.com",\n  "password": "secure_password_123",\n  "full_name": "Ahmad Suryanto",\n  "role": "CASHIER"\n}\n```

**Roles:**
- ADMIN - Full access, system administration
- MANAGER - View reports, manage staff
- CASHIER - Create transactions, basic operations
- VIEWER - Read-only access

**Database Table:**
```sql\nCREATE TABLE users (\n  user_id INT PRIMARY KEY AUTO_INCREMENT,\n  username VARCHAR(50) UNIQUE NOT NULL,\n  email VARCHAR(128) UNIQUE,\n  password_hash VARCHAR(255) NOT NULL,  -- bcrypt hashed\n  full_name VARCHAR(128),\n  role ENUM('ADMIN', 'MANAGER', 'CASHIER', 'VIEWER') DEFAULT 'CASHIER',\n  is_active BOOLEAN DEFAULT TRUE,\n  last_login DATETIME,\n  created_at DATETIME,\n  updated_at DATETIME\n);\n```

---

### Step 2: Login (Authentication)

**Endpoint:** `POST /api/auth/login`

**Request:**
```json\n{\n  "username": "cashier01",\n  "password": "secure_password_123"\n}\n```

**Validation:**
1. Check username exists
2. Hash provided password
3. Compare with stored password_hash
4. If match: Generate JWT token
5. If no match: Return 401 Unauthorized

**Response (Success):**
```json\n{\n  \"access_token\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\",\n  \"token_type\": \"Bearer\",\n  \"expires_in\": 3600,\n  \"user\": {\n    \"user_id\": 1,\n    \"username\": \"cashier01\",\n    \"full_name\": \"Ahmad Suryanto\",\n    \"role\": \"CASHIER\"\n  }\n}\n```

**Response (Failure):**\n```json\n{\n  \"error\": \"Invalid username or password\",\n  \"code\": 401\n}\n```

---

### Step 3: Token Generation (JWT)

**Token Structure:**

Header:
```json\n{\n  \"alg\": \"HS256\",\n  \"typ\": \"JWT\"\n}\n```

Payload:
```json\n{\n  \"user_id\": 1,\n  \"username\": \"cashier01\",\n  \"role\": \"CASHIER\",\n  \"iat\": 1697900000,  // Issued at\n  \"exp\": 1697903600   // Expiration (1 hour)\n}\n```

**Signing:**
- Algorithm: HS256 (HMAC with SHA256)
- Secret Key: Store in environment variable (SECRET_KEY)
- Duration: 1 hour for access token, 7 days for refresh token

**Example Generation (Python):**
```python\nimport jwt\nfrom datetime import datetime, timedelta\n\nSECRET_KEY = os.getenv('SECRET_KEY')\n\npayload = {\n    'user_id': user.user_id,\n    'username': user.username,\n    'role': user.role,\n    'iat': datetime.utcnow(),\n    'exp': datetime.utcnow() + timedelta(hours=1)\n}\n\ntoken = jwt.encode(payload, SECRET_KEY, algorithm='HS256')\n```

---

### Step 4: Token Validation (Authorization)

**Frontend:**
- Store token in localStorage
- Send token in Authorization header: `Bearer {token}`

**Backend Middleware:**
```python\nfrom functools import wraps\nimport jwt\n\ndef require_auth(f):\n    @wraps(f)\n    def decorated_function(*args, **kwargs):\n        auth_header = request.headers.get('Authorization')\n        if not auth_header:\n            return {'error': 'Missing authorization token'}, 401\n        \n        try:\n            token = auth_header.split(' ')[1]\n            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])\n            request.user = payload\n        except jwt.ExpiredSignatureError:\n            return {'error': 'Token has expired'}, 401\n        except jwt.InvalidTokenError:\n            return {'error': 'Invalid token'}, 401\n        \n        return f(*args, **kwargs)\n    return decorated_function\n```

---

### Step 5: Role-Based Access Control (RBAC)

**Endpoint Permissions:**

```python\nENDPOINT_PERMISSIONS = {\n    'POST /api/carwash-type/': ['ADMIN', 'MANAGER'],\n    'PUT /api/carwash-type/{id}/': ['ADMIN', 'MANAGER'],\n    'DELETE /api/carwash-type/{id}/': ['ADMIN'],\n    'GET /api/carwash-transaction/': ['CASHIER', 'MANAGER', 'ADMIN'],\n    'POST /api/carwash-transaction/': ['CASHIER', 'MANAGER', 'ADMIN'],\n    'PUT /api/carwash-transaction/{id}/': ['CASHIER', 'MANAGER', 'ADMIN'],\n    'DELETE /api/carwash-transaction/{id}/': ['MANAGER', 'ADMIN'],\n    'GET /api/dashboard/income/': ['MANAGER', 'ADMIN'],\n    'GET /api/employee-income/': ['MANAGER', 'ADMIN'],\n    'POST /api/employee/': ['ADMIN', 'MANAGER'],\n    'DELETE /api/employee/{id}/': ['ADMIN'],\n    'GET /api/admin/users/': ['ADMIN'],\n    'POST /api/admin/users/': ['ADMIN'],\n}\n```

**RBAC Decorator:**
```python\ndef require_role(*allowed_roles):\n    def decorator(f):\n        @wraps(f)\n        @require_auth\n        def decorated_function(*args, **kwargs):\n            if request.user['role'] not in allowed_roles:\n                return {'error': 'Insufficient permissions'}, 403\n            return f(*args, **kwargs)\n        return decorated_function\n    return decorator\n\n# Usage:\n@app.route('/api/dashboard/income/')\n@require_role('MANAGER', 'ADMIN')\ndef dashboard_income():\n    # Only manager and admin can access\n    pass\n```

---

### Step 6: Logout

**Endpoint:** `POST /api/auth/logout`

**Frontend:**
- Delete token from localStorage
- Redirect to login page
- Clear all cached user data

**Backend:**
- Optional: Blacklist token (prevent reuse)
- Log logout event for audit trail

---

## Recommended Architecture

### Technology Stack

**Backend (Python/Flask):**
- `PyJWT` - JWT token generation/validation
- `bcrypt` - Password hashing (secure, slow to prevent brute force)
- `Flask-JWT-Extended` - JWT extension for Flask
- Environment variables for secrets

**Frontend (Next.js/React):**
- Store token in localStorage
- Add token to every API request header
- Implement automatic logout on token expiration
- Redirect to login on 401 response
- Show loading spinner while validating token

---

## Migration Strategy (Critical)

### Phase 1: Prepare (Week 1)
- Create users table
- Create role enum
- Implement JWT generation/validation in backend
- Add login endpoint

### Phase 2: Frontend Implementation (Week 2-3)
- Add login page
- Implement token storage
- Add JWT to API requests
- Add logout functionality
- Handle 401/403 errors

### Phase 3: Enforcement (Week 3-4)
- Enable authentication middleware on all endpoints
- Apply RBAC to each endpoint
- Test all role scenarios
- Create admin user account
- User training

### Phase 4: Monitoring (Ongoing)
- Log all authentication events
- Monitor failed login attempts
- Track role usage
- Audit user permissions

---

## Security Best Practices

1. **Password Security**
   - Hash with bcrypt (slow, resistant to GPU attacks)
   - Minimum 12 characters
   - Require complexity (uppercase, numbers, symbols)
   - Never log or transmit in plaintext

2. **Token Security**
   - Use HTTPS only (prevent man-in-the-middle)
   - Short expiration (1 hour)
   - Refresh token rotation
   - Sign with strong secret (32+ characters)

3. **API Security**
   - Require HTTPS for all endpoints
   - Implement rate limiting
   - Log all authentication events
   - Monitor for suspicious activity

4. **Data Protection**
   - Encrypt sensitive data in database
   - Use environment variables for secrets
   - Never expose SECRET_KEY in code

---

## Estimated Implementation

**Effort:**
- Backend: 1 week
- Frontend: 1.5 weeks  
- Testing: 0.5 weeks
- Documentation: 0.5 weeks
- Total: **3.5 weeks**

**Team Size:** 2 developers (1 backend, 1 frontend)

---

## Known Limitations (Current)

- 🔴 No authentication implemented
- 🔴 No user roles
- 🔴 No permission checking
- 🔴 No session management
- 🔴 All data exposed to anyone with network access
- 🔴 No audit trail

---

## Conclusion

Authentication is a **CRITICAL** security requirement that must be implemented immediately. The complete lack of any authentication mechanism represents an unacceptable security risk for production systems handling financial and customer data.

---

**Priority:** CRITICAL - Implement immediately in redesigned application
**Next Steps:** Reserve 3.5 weeks in sprint planning for authentication implementation
