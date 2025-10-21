# User Stories - Kharisma Abadi Rebuild

**Document Version:** 1.0  
**Date:** October 2025  
**Framework:** Go/Fiber Backend + Vue 3 Frontend  
**Methodology:** Agile (2-week sprints)

---

## Table of Contents

1. [Overview](#overview)
2. [Epic 1: Authentication & Authorization](#epic-1-authentication--authorization)
3. [Epic 2: Car Wash Service](#epic-2-car-wash-service)
4. [Epic 3: Laundry Service](#epic-3-laundry-service)
5. [Epic 4: Carpet Washing Service](#epic-4-carpet-washing-service)
6. [Epic 5: Water Delivery Service](#epic-5-water-delivery-service)
7. [Epic 6: Payment Processing](#epic-6-payment-processing)
8. [Epic 7: Customer Management](#epic-7-customer-management)
9. [Epic 8: Reporting & Analytics](#epic-8-reporting--analytics)
10. [Epic 9: System Administration](#epic-9-system-administration)

---

## Overview

### Story Structure

Each user story includes:
- **Story ID:** Unique identifier (US-XXX)
- **Title:** Clear, action-oriented title
- **Description:** "As a [role], I want [action], so that [benefit]"
- **Priority:** P0 (Must), P1 (Should), P2 (Nice)
- **Story Points:** 1, 2, 3, 5, 8, 13
- **Acceptance Criteria:** Testable conditions
- **Technical Notes:** Implementation details
- **Test Scenarios:** Happy path, edge cases
- **Dependencies:** Related stories

### User Roles

- **Admin:** Full system access, configuration
- **Manager:** Reporting, orders, limited admin
- **Cashier:** Order creation, payment processing
- **Service Staff:** Service execution, queue management
- **Viewer:** Read-only access

---

## EPIC 1: Authentication & Authorization

### US-001: User Login

**As a** system user  
**I want to** authenticate with username and password  
**So that** I can securely access the POS system

**Priority:** P0 | **Points:** 3 | **Sprint:** 1

#### Acceptance Criteria

- [ ] Given valid credentials, when I submit login form, then I receive JWT access token
- [ ] Given invalid password, when I submit, then I see "Invalid credentials" error
- [ ] Given non-existent username, when I submit, then I see "Invalid credentials" error
- [ ] Given correct credentials, when I login, then I'm redirected to dashboard
- [ ] Given successful login, when I check localStorage, then access_token is stored
- [ ] Given successful login, when I check localStorage, then refresh_token is stored
- [ ] Given failed login (5 attempts), when I try again, then account is locked for 15 minutes
- [ ] Given session expired, when I make API call, then I receive 401 Unauthorized
- [ ] Given expired access token, when I use refresh token, then I receive new access token

#### Technical Notes

**Endpoint:** `POST /api/v1/auth/login`

**Request:**
```json
{
  "username": "john.doe",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "token_type": "Bearer",
    "expires_in": 1800,
    "user": {
      "id": 1,
      "username": "john.doe",
      "role": "cashier"
    }
  }
}
```

**Security:**
- Password hashed with bcrypt (12 rounds)
- JWT HS256 signature
- Rate limiting: 5 attempts/15 minutes per IP
- Token expiry: 30 minutes (access), 7 days (refresh)

**Database:**
- Query: `SELECT * FROM users WHERE username = ? AND is_active = TRUE`
- Update: Set `last_login = NOW()` on successful login
- Create: Insert into `login_attempts` table

#### Test Scenarios

**Happy Path:**
1. Navigate to login page
2. Enter username: "john.doe"
3. Enter password: "SecurePass123!"
4. Click "Login"
5. Redirected to dashboard
6. Token visible in localStorage

**Error Cases:**
- Wrong password → "Invalid credentials"
- User doesn't exist → "Invalid credentials"
- Account inactive → "Account deactivated"
- Too many attempts → "Account locked, try again in 15 minutes"

**Edge Cases:**
- SQL injection attempt → Blocked by ORM
- XSS in username field → Escaped by frontend validation
- Very long password → Validated server-side

---

### US-002: User Logout

**As a** logged-in user  
**I want to** end my session  
**So that** my account is secure when I leave the workstation

**Priority:** P0 | **Points:** 1 | **Sprint:** 1

#### Acceptance Criteria

- [ ] Given logged-in user, when I click logout, then I'm redirected to login page
- [ ] Given logout successful, when I check localStorage, then tokens are cleared
- [ ] Given logout, when I try to access protected page, then I'm redirected to login
- [ ] Given logout, when I check server, then refresh token is blacklisted
- [ ] Given multiple tabs open, when I logout in one, then other tabs show login on next action

#### Technical Notes

**Endpoint:** `POST /api/v1/auth/logout`

**Request:**
```json
{
  "refresh_token": "eyJhbGc..."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Implementation:**
- Clear access_token from localStorage
- Clear refresh_token from localStorage
- Add refresh_token to blacklist table
- Redirect to login page

---

### US-003: User Management (CRUD)

**As an** admin  
**I want to** create, read, update, and delete user accounts  
**So that** I can manage staff access and permissions

**Priority:** P0 | **Points:** 8 | **Sprint:** 2

#### Acceptance Criteria

- [ ] Given admin role, when I access user list, then I see all users with roles
- [ ] Given user list, when I click "Add User", then I see user creation form
- [ ] Given user form, when I fill all required fields, then "Save" button is enabled
- [ ] Given valid user data, when I submit form, then new user is created
- [ ] Given new user, when I check database, then password is hashed with bcrypt
- [ ] Given existing user, when I update role, then permissions change immediately
- [ ] Given active user, when I deactivate, then user cannot login
- [ ] Given deleted user, when I check audit log, then deletion is recorded
- [ ] Given user creation, when I check audit log, then creator is recorded

#### User Roles & Permissions

| Role | Create Orders | Process Payments | View Reports | Manage Users | System Config |
|------|---------------|-----------------|--------------|--------------|---------------|
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ |
| Manager | ✅ | ✅ | ✅ | ⚠️ (limited) | ❌ |
| Cashier | ✅ | ✅ | ⚠️ (own) | ❌ | ❌ |
| Service Staff | ❌ | ❌ | ❌ | ❌ | ❌ |
| Viewer | ❌ | ❌ | ✅ (read) | ❌ | ❌ |

#### Technical Notes

**Endpoints:**
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- `GET /api/v1/users/{id}` - Get user detail
- `PATCH /api/v1/users/{id}` - Update user
- `DELETE /api/v1/users/{id}` - Delete user

**User Creation Validation:**
```
- username: 5-50 chars, alphanumeric + underscore, unique
- email: Valid email format, unique
- full_name: 2-100 chars
- password: 8+ chars, uppercase, lowercase, number, special char
- role: admin, manager, cashier, service_staff, viewer
```

**Database Tables:**
- `users` - User accounts
- `user_roles` - Role assignments
- `audit_logs` - User management history

---

### US-004: User Profile Management

**As a** user  
**I want to** update my profile information and change my password  
**So that** my information stays current and my account is secure

**Priority:** P1 | **Points:** 3 | **Sprint:** 2

#### Acceptance Criteria

- [ ] Given logged-in user, when I access profile, then I see my information
- [ ] Given profile page, when I update full_name, then change is saved
- [ ] Given profile page, when I update email, then I receive verification email
- [ ] Given verification email, when I click link, then email is verified
- [ ] Given change password form, when I enter current password, then it's validated
- [ ] Given new password, when it doesn't meet requirements, then error message shown
- [ ] Given valid new password, when I submit, then password is updated
- [ ] Given password changed, when I login next time, then new password works

#### Technical Notes

**Endpoints:**
- `GET /api/v1/users/me` - Get current user profile
- `PATCH /api/v1/users/me` - Update profile
- `POST /api/v1/users/me/change-password` - Change password

---

## EPIC 2: Car Wash Service

### US-005: Create Car Wash Order

**As a** cashier  
**I want to** create a car wash order with vehicle and service details  
**So that** I can process customer requests and generate pricing

**Priority:** P0 | **Points:** 8 | **Sprint:** 3

#### Acceptance Criteria

- [ ] Given service dashboard, when I click "New Car Wash Order", then order form appears
- [ ] Given order form, when I search customer by phone, then matching customers shown
- [ ] Given customer selected, when I proceed, then form displays vehicle type options
- [ ] Given vehicle types available, when I select "Sedan", then base price 50,000 displayed
- [ ] Given vehicle type selected, when I select package, then subtotal calculated
- [ ] Given package selected, when I view add-ons, then all add-ons displayed with prices
- [ ] Given add-ons selected, when I view total, then total = (base × multiplier) + addons - discount
- [ ] Given completed form, when I submit, then order created with status "PENDING"
- [ ] Given order created, when I check database, then order_number generated uniquely

#### Pricing Formula

```
Vehicle Types:
- Motorcycle: 1.0x multiplier
- Sedan: 1.5x multiplier
- SUV: 2.0x multiplier
- Truck: 2.5x multiplier
- Bus: 3.0x multiplier

Packages:
- Basic: 50,000 (wash + dry)
- Premium: 80,000 (basic + wax)
- Deluxe: 120,000 (premium + interior + protect)

Add-ons:
- Engine Cleaning: 30,000
- Interior Detailing: 25,000
- Undercoating: 35,000
- Ceramic Coating: 150,000

Calculation:
1. subtotal = package_price × vehicle_multiplier
2. with_addons = subtotal + sum(addon_prices)
3. with_discount = with_addons × (1 - discount_percentage)
4. total = with_discount + tax
```

#### Test Scenarios

**Simple Order:**
- Vehicle: Sedan (1.5x)
- Package: Basic (50,000)
- No add-ons, no discount
- **Expected Total: 75,000**

**Complex Order:**
- Vehicle: SUV (2.0x)
- Package: Premium (80,000) = 160,000
- Add-ons: Engine Cleaning (30,000) + Interior (25,000) = 55,000
- Subtotal: 215,000
- Discount: 10% = -21,500
- Tax: 10% = 19,350
- **Expected Total: 213,350**

**VIP Member Order:**
- Customer: VIP member (15% discount)
- Vehicle: Truck (2.5x)
- Package: Deluxe (120,000) = 300,000
- Discount: 15% = -45,000
- **Expected Total: 255,000**

---

### US-006: View Car Wash Queue

**As a** service staff  
**I want to** view the current car wash service queue  
**So that** I know which vehicles to service next

**Priority:** P0 | **Points:** 3 | **Sprint:** 3

#### Acceptance Criteria

- [ ] Given service dashboard, when I open queue view, then pending orders displayed in FIFO order
- [ ] Given each order in queue, when I view, then I see vehicle type, package, customer name
- [ ] Given order details, when I click order, then full details shown in modal
- [ ] Given pending order, when I click "Start Service", then status changes to "IN_PROGRESS"
- [ ] Given in-progress order, when other staff views, then status shows as "IN_PROGRESS"
- [ ] Given queue changes, when another cashier adds order, then my view auto-refreshes
- [ ] Given completed order, when I mark complete, then status changes to "COMPLETED"

#### Technical Notes

**Endpoint:** `GET /api/v1/car-wash/queue`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "ORD-20251022-001",
      "customer": {
        "name": "John Doe",
        "phone": "+628123456789"
      },
      "vehicle_type": "sedan",
      "package": "premium",
      "total_amount": 120000,
      "status": "pending",
      "created_at": "2025-10-22T10:30:00Z"
    }
  ]
}
```

**Implementation:**
- Real-time updates via WebSocket or polling
- Queue sorted by created_at ASC
- Filter by status = "PENDING"
- Display vehicle type and package details

---

### US-007: Complete Car Wash Service

**As a** service staff  
**I want to** mark a car wash service as complete  
**So that** the order proceeds to invoicing and payment

**Priority:** P0 | **Points:** 5 | **Sprint:** 3

#### Acceptance Criteria

- [ ] Given in-progress order, when I complete service, then quality check form appears
- [ ] Given quality form, when service is satisfactory, then I select "Pass"
- [ ] Given quality passed, when I submit, then status changes to "COMPLETED"
- [ ] Given quality failed, when I select "Fail", then status returns to "IN_PROGRESS"
- [ ] Given service completed, when I check order, then completion_time recorded
- [ ] Given completed order, when I navigate away, then order removed from queue
- [ ] Given service duration, when order completed, then duration = completion_time - started_time

#### Quality Checklist

- [ ] Vehicle thoroughly washed
- [ ] No water spots visible
- [ ] Interior cleaned and vacuumed
- [ ] All add-ons completed as ordered
- [ ] Vehicle dried completely
- [ ] Customer satisfied with service

#### Technical Notes

**Endpoint:** `POST /api/v1/orders/{id}/complete`

**Request:**
```json
{
  "quality_check": "pass",
  "notes": "Service completed successfully",
  "completion_time": "2025-10-22T11:15:00Z"
}
```

---

## EPIC 3: Laundry Service

### US-008: Create Laundry Order

**As a** cashier  
**I want to** create a laundry order with item details and service type  
**So that** I can process laundry service requests

**Priority:** P0 | **Points:** 8 | **Sprint:** 4

#### Acceptance Criteria

- [ ] Given new laundry order, when I start form, then item category options displayed
- [ ] Given item categories available, when I select category, then available services shown
- [ ] Given service type selected, when I enter weight, then price calculated per kg
- [ ] Given multiple items, when I add items, then each item added separately
- [ ] Given items added, when I view total, then total = sum(weight × rate) per service
- [ ] Given laundry items, when I apply urgent service, then price increases by 20%
- [ ] Given order completed, when I submit, then order created with status "PENDING"

#### Laundry Service Details

**Item Categories:**
- Regular Clothes
- Heavy Fabrics (blankets, curtains)
- Delicate Items (silk, wool)
- Uniforms

**Service Types:**
- Standard (3 days): 5,000/kg
- Express (1 day): 7,500/kg
- Urgent (same day): 10,000/kg

**Add-ons:**
- Ironing: 2,000/kg
- Stain Removal: 5,000/item
- Fabric Protection: 10,000/order

#### Pricing Example

**Order:**
- 3 kg regular clothes (standard): 3 × 5,000 = 15,000
- 2 kg delicate (express): 2 × 7,500 = 15,000
- Subtotal: 30,000
- Ironing (3kg): 3 × 2,000 = 6,000
- **Total: 36,000**

---

### US-009: Track Laundry Order Status

**As a** customer or cashier  
**I want to** track the status of laundry orders  
**So that** I know when items are ready for pickup

**Priority:** P1 | **Points:** 3 | **Sprint:** 4

#### Acceptance Criteria

- [ ] Given order reference, when I search, then order status displayed
- [ ] Given order in process, when status updates, then customer notified via SMS
- [ ] Given laundry ready, when cashier marks ready, then status shows "READY_FOR_PICKUP"
- [ ] Given order ready, when customer calls, then cashier can mark as picked up

---

## EPIC 4: Carpet Washing Service

### US-010: Create Carpet Washing Order

**As a** cashier  
**I want to** create a carpet washing order with room and carpet details  
**So that** I can process carpet cleaning requests

**Priority:** P0 | **Points:** 8 | **Sprint:** 5

#### Acceptance Criteria

- [ ] Given carpet order form, when I view, then room type options displayed
- [ ] Given room type selected, when I specify size, then estimated price shown
- [ ] Given carpet details, when I select cleaning type, then price adjusts
- [ ] Given location selected, when I check, then delivery fee added if applicable
- [ ] Given order completed, when I submit, then order created with status "PENDING"

#### Carpet Service Pricing

**Room Types & Base Prices:**
- Small bedroom (10 m²): 200,000
- Large bedroom (15 m²): 300,000
- Living room (20 m²): 400,000
- Office (30 m²): 500,000

**Cleaning Types:**
- Standard: Base price
- Deep Clean: +50%
- Stain Removal: +30%
- Deodorize: +15,000

**Delivery:**
- Within 5km: Free
- 5-10km: 25,000
- >10km: 50,000

---

## EPIC 5: Water Delivery Service

### US-011: Create Water Delivery Order

**As a** cashier  
**I want to** create a water delivery order  
**So that** I can process customer water delivery requests

**Priority:** P0 | **Points:** 5 | **Sprint:** 5

#### Acceptance Criteria

- [ ] Given water delivery form, when I view, then water types shown (gallon, bottle, refill)
- [ ] Given water type selected, when I choose quantity, then price calculated
- [ ] Given delivery address, when I enter, then delivery fee calculated based on distance
- [ ] Given order details, when complete, then order created with status "PENDING"

#### Water Products

**Products:**
- Gallon (19L): 25,000 per gallon
- Bottle (500mL): 5,000 per bottle
- Refill (return gallon): 20,000

**Delivery Fees:**
- 0-5 km: Free
- 5-10 km: 10,000
- >10 km: 20,000

---

## EPIC 6: Payment Processing

### US-012: Process Payment (Cash)

**As a** cashier  
**I want to** process cash payment for completed orders  
**So that** customers can complete their transaction

**Priority:** P0 | **Points:** 5 | **Sprint:** 6

#### Acceptance Criteria

- [ ] Given completed order, when I click pay, then payment form shows
- [ ] Given payment form, when total shown, then order amount displayed clearly
- [ ] Given cash payment, when I enter amount received, then change calculated: change = amount - total
- [ ] Given insufficient amount, when I check, then error message "Insufficient amount" shown
- [ ] Given payment completed, when I confirm, then order status changes to "PAID"
- [ ] Given payment confirmed, when I check, then cash drawer balance updated
- [ ] Given cash payment, when complete, then receipt generated automatically

#### Technical Notes

**Endpoint:** `POST /api/v1/payments`

**Request:**
```json
{
  "order_id": 1,
  "payment_method": "cash",
  "amount_received": 100000,
  "amount_paid": 75000
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "payment_id": 1,
    "order_id": 1,
    "payment_method": "cash",
    "amount": 75000,
    "change": 25000,
    "status": "completed"
  }
}
```

---

### US-013: Process Payment (Bank Transfer)

**As a** cashier  
**I want to** record bank transfer payments  
**So that** customer payment is documented

**Priority:** P0 | **Points:** 3 | **Sprint:** 6

#### Acceptance Criteria

- [ ] Given bank transfer option, when I select, then bank details form shown
- [ ] Given transfer details, when I enter reference number, then format validated
- [ ] Given valid reference, when I submit, then payment recorded with status "completed"
- [ ] Given payment recorded, when I check audit log, then transaction is logged

---

### US-014: Process Split Payment

**As a** cashier  
**I want to** process payments using multiple payment methods  
**So that** customers can pay with different methods

**Priority:** P1 | **Points:** 5 | **Sprint:** 6

#### Acceptance Criteria

- [ ] Given order total 100,000, when I select split payment, then multiple payment form shown
- [ ] Given split payment, when I add cash (60,000) + bank transfer (40,000), then sum validates to total
- [ ] Given payment methods added, when sum is less than total, then "Insufficient amount" error
- [ ] Given sum equals total, when I confirm, then multiple payment records created
- [ ] Given multiple payments, when I check receipt, then all methods shown

---

### US-015: Generate Receipt

**As a** system  
**I want to** automatically generate receipts after payment  
**So that** customers have proof of transaction

**Priority:** P0 | **Points:** 3 | **Sprint:** 6

#### Acceptance Criteria

- [ ] Given payment completed, when receipt generated, then receipt number created
- [ ] Given receipt, when I view, then customer name, items, total, payment method shown
- [ ] Given receipt, when I check, then date/time of transaction shown
- [ ] Given receipt, when printed, then formatting is clear and readable
- [ ] Given receipt, when customer requests, then receipt can be reprinted

#### Receipt Format

```
═══════════════════════════════════════
        KHARISMA ABADI
        Service Receipt
═══════════════════════════════════════

Receipt #: RCP-20251022-001
Date: 2025-10-22 11:30:00
Service: Car Wash

CUSTOMER
Name: John Doe
Phone: 08123456789

SERVICE DETAILS
Package: Premium Car Wash
Vehicle: Sedan
Subtotal: 120,000
Tax (10%): 12,000
TOTAL: 132,000

PAYMENT
Method: Cash
Amount Paid: 150,000
Change: 18,000

Thank you for your service!
Please visit again.

═══════════════════════════════════════
```

---

## EPIC 7: Customer Management

### US-016: Create Customer Profile

**As a** cashier  
**I want to** create a customer profile  
**So that** I can track customer information and history

**Priority:** P0 | **Points:** 3 | **Sprint:** 7

#### Acceptance Criteria

- [ ] Given new customer, when I click "Add Customer", then customer form appears
- [ ] Given customer form, when I enter name and phone, then fields are required
- [ ] Given phone number, when I check database, then system checks for duplicates
- [ ] Given valid customer data, when I submit, then customer created and assigned ID
- [ ] Given customer type options, when I select, then discount percentage set accordingly

#### Customer Types & Discounts

| Type | Discount | Loyalty Benefits |
|------|----------|-----------------|
| Regular | 5% | Every 5th order: +10% discount |
| VIP | 15% | Every order: +15% discount |
| Corporate | 10-20% | Bulk discounts, monthly billing |

---

### US-017: View Customer History

**As a** cashier or manager  
**I want to** view customer order history  
**So that** I can understand customer preferences and spending

**Priority:** P1 | **Points:** 3 | **Sprint:** 7

#### Acceptance Criteria

- [ ] Given customer selected, when I click history, then all orders displayed
- [ ] Given order history, when I view, then services, dates, amounts shown
- [ ] Given order history, when I check, then total spending calculated
- [ ] Given customer history, when filtered by date, then relevant orders shown

---

### US-018: Update Customer Information

**As a** cashier  
**I want to** update customer information  
**So that** records stay current

**Priority:** P1 | **Points:** 2 | **Sprint:** 7

#### Acceptance Criteria

- [ ] Given existing customer, when I open profile, then current info displayed
- [ ] Given customer info, when I update address, then change saved
- [ ] Given customer type, when I upgrade to VIP, then discount updated
- [ ] Given customer update, when checked, then audit log recorded

---

## EPIC 8: Reporting & Analytics

### US-019: Generate Daily Sales Report

**As a** manager  
**I want to** generate daily sales reports  
**So that** I can track business performance

**Priority:** P1 | **Points:** 5 | **Sprint:** 8

#### Acceptance Criteria

- [ ] Given report page, when I select date, then daily sales displayed
- [ ] Given sales data, when I view, then total revenue shown
- [ ] Given revenue breakdown, when I check, then breakdown by service type shown
- [ ] Given service breakdown, when I view, then count and revenue per service shown
- [ ] Given payment methods, when I view, then breakdown of payment methods shown
- [ ] Given report, when I export, then PDF or Excel file generated

#### Report Contents

**Daily Sales Report should include:**
1. **Summary:**
   - Date
   - Total Orders: 25
   - Total Revenue: 1,375,000
   - Total Discount: 50,000
   - Tax Collected: 137,500

2. **By Service Type:**
   - Car Wash: 10 orders, 550,000
   - Laundry: 8 orders, 480,000
   - Carpet: 5 orders, 250,000
   - Water: 2 orders, 95,000

3. **By Payment Method:**
   - Cash: 20 orders, 1,100,000
   - Bank Transfer: 5 orders, 275,000

4. **Top Services:**
   - Most popular service
   - Highest revenue service
   - Average order value

---

### US-020: Generate Revenue Report

**As a** manager  
**I want to** view revenue trends over time  
**So that** I can analyze business growth

**Priority:** P1 | **Points:** 5 | **Sprint:** 8

#### Acceptance Criteria

- [ ] Given date range, when I generate report, then revenue for period shown
- [ ] Given revenue data, when I view, then daily/weekly breakdown available
- [ ] Given revenue trend, when I compare periods, then growth percentage shown
- [ ] Given report, when I view chart, then revenue visualization displayed

---

### US-021: Generate Service Performance Report

**As a** manager  
**I want to** analyze service performance metrics  
**So that** I can optimize operations

**Priority:** P2 | **Points:** 5 | **Sprint:** 9

#### Acceptance Criteria

- [ ] Given service report, when I view, then completion rate shown per service
- [ ] Given completion time, when I check, then average time calculated
- [ ] Given quality checks, when I view, then pass/fail rates shown
- [ ] Given performance data, when I export, then report saved as PDF

---

## EPIC 9: System Administration

### US-022: Configure Service Pricing

**As an** admin  
**I want to** configure pricing for all services  
**So that** I can adjust prices as needed

**Priority:** P1 | **Points:** 5 | **Sprint:** 9

#### Acceptance Criteria

- [ ] Given service pricing page, when I access, then all prices displayed
- [ ] Given price field, when I update, then change is validated (positive number)
- [ ] Given multiplier for vehicle type, when I adjust, then future orders use new multiplier
- [ ] Given price change, when saved, then change logged in audit trail
- [ ] Given old price, when I check history, then previous prices visible

---

### US-023: Manage Cash Drawer

**As a** cashier  
**I want to** open, close, and reconcile cash drawer  
**So that** cash transactions are tracked and balanced

**Priority:** P0 | **Points:** 5 | **Sprint:** 10

#### Acceptance Criteria

- [ ] Given shift start, when I open drawer, then opening balance entered
- [ ] Given cash transactions, when day ends, then closing balance entered
- [ ] Given closing balance, when compared to expected, then discrepancy flagged
- [ ] Given cash drawer, when closed, then transactions locked for that drawer
- [ ] Given discrepancy, when noted, then admin notified and logged

#### Cash Drawer Flow

```
┌────────────────┐
│  Shift Start   │
│ Open Drawer    │
│ Enter Balance: │
│ 500,000        │
└────────────────┘
         ↓
┌─────────────────────┐
│ Throughout Shift    │
│ • Cash payments     │
│ • Cash change given │
│ • Transactions logs │
└─────────────────────┘
         ↓
┌────────────────────┐
│   Shift End        │
│ Close Drawer       │
│ Count Cash         │
│ Enter Balance:     │
│ 650,000            │
└────────────────────┘
         ↓
┌────────────────────────────┐
│ Reconciliation             │
│ Expected: 650,000          │
│ Actual: 650,000            │
│ Variance: 0                │
│ Status: ✅ BALANCED        │
└────────────────────────────┘
```

---

### US-024: View Audit Logs

**As an** admin  
**I want to** view system audit logs  
**So that** I can track user actions and system changes

**Priority:** P1 | **Points:** 3 | **Sprint:** 10

#### Acceptance Criteria

- [ ] Given audit log page, when I access, then list of actions shown
- [ ] Given action logs, when I filter by user, then only that user's actions shown
- [ ] Given logs, when I filter by action type, then filtered results shown
- [ ] Given log entry, when I click, then full details displayed (who, what, when, where)
- [ ] Given logs, when exported, then report includes all details

#### Auditible Events

- User login/logout
- Order creation/modification/deletion
- Payment processing
- Price changes
- User management actions
- System configuration changes
- Cash drawer open/close
- Report generation

---

### US-025: System Health & Monitoring

**As an** admin  
**I want to** monitor system health and performance  
**So that** I can ensure system reliability

**Priority:** P2 | **Points:** 5 | **Sprint:** 10

#### Acceptance Criteria

- [ ] Given monitoring dashboard, when I view, then API response times shown
- [ ] Given system metrics, when I check, then CPU and memory usage visible
- [ ] Given database performance, when I monitor, then query times displayed
- [ ] Given alerts configured, when threshold exceeded, then notification sent
- [ ] Given system health, when degraded, then admin alerted immediately

---

## Summary Statistics

### Total User Stories: 25

| Epic | Count | Priority | Story Points |
|------|-------|----------|--------------|
| Authentication | 4 | P0:3, P1:1 | 15 |
| Car Wash | 3 | P0:3 | 16 |
| Laundry | 2 | P0:1, P1:1 | 11 |
| Carpet | 1 | P0:1 | 8 |
| Water | 1 | P0:1 | 5 |
| Payment | 4 | P0:3, P1:1 | 16 |
| Customers | 3 | P0:1, P1:2 | 8 |
| Reporting | 3 | P1:2, P2:1 | 15 |
| Administration | 4 | P0:1, P1:2, P2:1 | 16 |

**Total Story Points:** 110
**Average Points per Story:** 4.4

---

## Acceptance Criteria Checklist

### All Stories Must Include

- [ ] Clear user role identified
- [ ] Specific action/feature described
- [ ] Business value articulated
- [ ] 3-5 acceptance criteria with Given/When/Then format
- [ ] Technical implementation notes
- [ ] Test scenarios (happy path + edge cases)
- [ ] Dependencies identified
- [ ] Story points estimated using Fibonacci sequence

---

## Definition of Done

For each user story, confirm:

- [ ] Code implemented following architecture patterns
- [ ] Unit tests written (>85% coverage)
- [ ] Integration tests passing
- [ ] API documentation updated
- [ ] Frontend/backend properly integrated
- [ ] Manual testing completed
- [ ] Code reviewed and approved
- [ ] Deployed to staging environment
- [ ] Acceptance criteria verified
- [ ] Ready for production release

---

This comprehensive user story set provides the roadmap for the entire Kharisma Abadi rebuild project, ensuring all features are properly specified and ready for agile sprint planning.
