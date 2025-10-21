# Water Delivery Service Flow

**Service Type:** Drinking Water Delivery (Air Minum)
**Complexity:** Medium (Subscription-based with regular customers)
**Frequency:** 50-150 deliveries per week (estimated)
**Recurring:** Yes, ongoing subscription model

---

## Overview

### Purpose
Manage water delivery subscriptions and transactions from customer registration through delivery, invoice generation, and payment collection.

### Business Value
- Recurring revenue stream (most predictable income)
- Subscription-based customer relationships
- Route-based delivery optimization
- Regular customer contact opportunities
- Less labor-intensive than other services

### User Roles Involved
- **Cashier/Front Desk Staff** - Customer registration, order management
- **Delivery Driver** - Water delivery, customer communication
- **Customer** - Receives water deliveries, pays bills
- **Manager** - Track subscription revenue, customer management

### System Components
- Customer Registration System
- Delivery Scheduling
- Transaction Management API
- Payment Processing
- Route Optimization (manual, no automation in current system)
- Database (drinking_water_customers, drinking_water_transactions, drinking_water_types)

---

## Process Flow Diagram

```mermaid
flowchart TD
    Start([Customer Needs Drinking Water]) --> NewCustomer{Existing\\nCustomer?}
    
    NewCustomer -->|Yes| ExistingFlow[Retrieve customer info]
    NewCustomer -->|No| RegisterCustomer[Register new customer]\n    RegisterCustomer --> RecordName[Record:\\n- Full Name\\n- Address\\n- Phone Number]
    RecordName --> VerifyAddress[Verify delivery address\\n- Street\\n- Area/District\\n- Delivery feasible?]
    
    VerifyAddress --> AddressOK{Address\\nAcceptable?}\n    AddressOK -->|No| SuggestAlternative[Suggest alternative\\nservice options]\n    AddressOK -->|Yes| SaveCustomer[Save customer record\\nStatus: Active]
    SuggestAlternative --> End1([Service Unavailable])\n    SaveCustomer --> SelectWaterType[Select water type/product]\n    ExistingFlow --> SelectWaterType\n    \n    SelectWaterType --> CheckType{Water Type\\nExists?}\n    CheckType -->|No| CreateWaterType[Create new type in settings]\n    CheckType -->|Yes| EnterQuantity[Enter quantity to deliver]\n    CreateWaterType --> EnterQuantity\n    \n    EnterQuantity --> SpecifyDate[Specify delivery date]\n    SpecifyDate --> RecordPaymentMethod[Record payment method:\\n- Prepay (deposit)\\n- COD (cash on delivery)\\n- Monthly invoice]\n    \n    RecordPaymentMethod --> CreateTransaction[Create delivery transaction\\nstatus: PENDING]\n    CreateTransaction --> AssignDriver[Assign driver/vehicle]\n    AssignDriver --> OptimizeRoute[Add to delivery route]\n    OptimizeRoute --> PrintDeliveryTicket[Print delivery ticket with:\\n- Customer address\\n- Product/quantity\\n- Price\\n- Payment terms]\n    \n    PrintDeliveryTicket --> DeliveryDay[On scheduled delivery day]\n    DeliveryDay --> PickUpWater[Driver picks up water\\nfrom warehouse]\n    PickUpWater --> LoadVehicle[Load vehicle per route]\n    LoadVehicle --> DriveToCustomer[Drive to customer address]\n    \n    DriveToCustomer --> FindCustomer[Locate customer/address]\n    FindCustomer --> CustomerAvailable{Customer\\nHome?}\n    \n    CustomerAvailable -->|No| LeaveNotice[Leave notice to call]\n    CustomerAvailable -->|Yes| GreetCustomer[Greet customer]\n    LeaveNotice --> RescheduleDelivery[Reschedule for next day]\n    RescheduleDelivery --> DriveToCustomer\n    \n    GreetCustomer --> VerifyOrder[Verify order details\\nwith customer]\n    VerifyOrder --> UnloadWater[Unload water gallon/bottles]\n    UnloadWater --> SetupLocation[Place in agreed location\\n- Kitchen\\n- Garage\\n- Storage]\n    \n    SetupLocation --> CollectPayment{Payment\\nMethod?}\n    \n    CollectPayment -->|Prepaid| SkipPayment[Payment already received]\n    CollectPayment -->|COD| CashCollection[Collect payment from customer]\n    CollectPayment -->|Invoice| RecordDebt[Record as outstanding invoice]\n    \n    CashCollection --> PrintReceipt[Print receipt]\n    SkipPayment --> PrintReceipt\n    RecordDebt --> PrintReceipt\n    \n    PrintReceipt --> UpdateQuantity[Update customer gallons/bottles\\ndelivered]\n    UpdateQuantity --> MarkComplete[Mark delivery complete\\nSet end_date = NOW]\n    \n    MarkComplete --> NextDeliverySchedule{Next Delivery\\nScheduled?}\n    NextDeliverySchedule -->|Recurring| ScheduleNext[Schedule next delivery\\nper subscription]\n    NextDeliverySchedule -->|One-time| CheckRegular[Check if customer wants\\nrecurring delivery]\n    \n    ScheduleNext --> ReturnToWarehouse[Return to warehouse]\n    CheckRegular --> OfferSubscription[Offer subscription benefits]\n    OfferSubscription --> ReturnToWarehouse\n    \n    ReturnToWarehouse --> ReportDelivery[Report delivery status]\n    ReportDelivery --> UpdateDashboard[Update dashboard:\\n- Today's deliveries\\n- Revenue\\n- Customer gallons]\n    UpdateDashboard --> End2([Delivery Complete])\n    \n    style NewCustomer fill:#e1f5ff\n    style CollectPayment fill:#fff3e0\n    style UpdateDashboard fill:#f3e5f5
```

---

## Detailed Process Steps

### Step 1: Customer Identification

**User Action:** Customer contacts business for water delivery

**System Action:** Check if customer already registered

**Query:**
```sql
SELECT * FROM drinking_water_customers\nWHERE name LIKE '%{search_term}%'\nOR phone_number = '{phone}'\nORDER BY created_at DESC
```

**Two Paths:**

**Path A: Existing Customer**
- Load customer information
- Skip registration
- Go to Step 5: Order Water

**Path B: New Customer**
- Proceed to registration
- Collect required information

---

### Step 2: New Customer Registration

**User Action:** Cashier collects customer information

**System Action:** Validate and save customer record

**API:** `POST /api/drinking-water-customer/`

**Required Fields:**
- **Name** (required, max 128 chars) - Full legal name
- **Address** (required, text field) - Complete street address
- **Phone Number** (optional, max 18 chars) - Contact number

**Request Body:**
```json
{
  "name": "Budi Hartono",
  "address": "Jl. Merdeka No. 45, Jakarta Pusat 12190",
  "phone_number": "08123456789"
}
```

**Database Operation:**
```sql
INSERT INTO drinking_water_customers (\n    name, address, phone_number,\n    created_at, updated_at\n) VALUES (\n    'Budi Hartono',\n    'Jl. Merdeka No. 45, Jakarta Pusat 12190',\n    '08123456789',\n    NOW(), NOW()\n);
```

**Validation:**
- Name: required, max 128 characters
- Address: required, min 10 characters
- Phone: optional, format validation if provided

**Business Rules Applied:**
- **WD-REG-001:** New customer registration
- Address must be within delivery zone
- Phone number for delivery coordination

**Response:**
```json
{
  "drinking_water_customer_id": 456,
  "name": "Budi Hartono",
  "message": "Customer registered successfully"
}
```

---

### Step 3: Delivery Zone Verification

**System Action:** Verify address is within service area

**Business Rules:**
- Check address location
- Determine delivery feasibility
- Calculate delivery cost (if applicable)
- Estimate delivery frequency options

**Manual Process (Current System):**
- Cashier knows service area
- Verifies address with customer
- Confirms if delivery is possible

**Recommendation:**
- Add delivery zones to database
- Validate address against zones
- Auto-calculate delivery costs

---

### Step 4: Water Type Selection

**User Action:** Customer selects water product

**System Action:** Display available water types and pricing

**API:** `GET /api/drinking-water-type/`

**Example Water Types:**
| Type | Price | Unit |
|------|-------|------|
| Galon 19L | Rp 20,000 | per gallon |
| Botol 600ml | Rp 3,000 | per bottle |
| Botol 1.5L | Rp 5,000 | per bottle |
| Drum 200L | Rp 150,000 | per drum |

**Business Rules Applied:**
- **WD-PRO-001:** Water type pricing
- Price set by water type
- Different package sizes available
- No dynamic pricing

**Selection:**
- Customer specifies quantity
- Daily, weekly, or monthly frequency

---

### Step 5: Order Creation (Delivery Request)

**User Action:** Customer places order for delivery

**System Action:** Create delivery transaction

**API:** `POST /api/drinking-water-transaction/`

**Request Body:**
```json
{
  "date": "2025-10-22 10:00:00",\n  "drinking_water_customer_id": 456,\n  "drinking_water_type_id": 1,\n  "quantity": 2,\n  "final_price": 40000\n}
```

**Alternatively for Walk-in:**
```json
{
  "date": "2025-10-22 10:00:00",\n  "name": "Walk-in Customer",\n  "phone_number": "0812xxxx",\n  "drinking_water_customer_id": null,\n  "drinking_water_type_id": 1,\n  "quantity": 1,\n  "final_price": 20000\n}
```

**Database Operation:**
```sql
INSERT INTO drinking_water_transactions (\n    date, name, phone_number,\n    drinking_water_customer_id,\n    drinking_water_type_id,\n    quantity, final_price,\n    end_date, created_at, updated_at\n) VALUES (\n    '2025-10-22 10:00:00',\n    NULL,  -- Customer name, NULL if registered customer\n    NULL,  -- NULL if customer ID provided\n    456,   -- Registered customer\n    1,     -- Galon 19L\n    2,     -- 2 gallons\n    40000, -- 2 × Rp 20,000\n    NULL,  -- end_date not set yet\n    NOW(), NOW()\n);
```

**State:** PENDING (end_date = NULL, delivery not yet executed)

**Business Rules Applied:**
- **TX-WF-001:** Transaction created, pending delivery
- **WD-ORD-001:** Customer can be registered or walk-in
- Price: quantity × type.price

---

### Step 6: Delivery Scheduling

**User Action:** Specify delivery date/time

**System Action:** Assign to driver's route

**Process:**
1. Customer specifies preferred delivery date
2. System checks driver availability
3. Assign to appropriate route
4. Confirm delivery time window with customer

**Manual Process (Current System):**
- Cashier writes on delivery ticket
- Driver manages route manually
- No automated scheduling

**Recommendation:**
- Add delivery_scheduled_date field
- Implement driver/route management
- Add time window preferences

---

### Step 7: Payment Terms Configuration

**User Action:** Specify payment method

**System Action:** Record payment arrangement

**Payment Options:**

**Option A: Prepayment (Deposit)**
- Customer pays before delivery
- Receipt given
- Delivery guaranteed on scheduled date
- Can prepay for multiple deliveries

**Option B: Cash on Delivery (COD)**
- Customer pays when delivery received
- Driver collects payment
- Receipt printed on-site
- No prepayment required

**Option C: Monthly Invoice**
- Multiple deliveries in month
- Cumulative invoice at month-end
- Payment due within 30 days
- Suitable for corporate/bulk customers
- Creates accounts receivable

**Business Rules:**
- Default payment method per customer
- Can be overridden per transaction
- No split payment in current system

**Database Storage:**
- Currently: Not stored per transaction
- Should add: payment_method field
- Should track: payment_status (UNPAID, PAID, OVERDUE)

---

### Step 8: Driver Assignment & Route Planning

**User Action:** Assign delivery to driver/route

**System Action:** Add to delivery schedule

**Process:**
1. Select available driver
2. Assign to appropriate route
3. Print delivery ticket
4. Prepare water from warehouse
5. Load onto delivery vehicle

**Current System:**
- Manual assignment
- Paper-based routing
- Driver manages multiple stops

**Recommendation:**
- Digital route planning
- GPS tracking
- Delivery time estimates
- Route optimization algorithm

---

### Step 9: Delivery Execution

**User Action:** Driver delivers water to customer

**System Action:** None (manual delivery)

**Process:**
1. Driver arrives at customer location
2. Contacts customer (phone or door knock)
3. Verifies address and order
4. Unloads water product
5. Places in agreed location
6. Collects payment (if COD)
7. Notes delivery status

**Issues:**
- Customer not home: Reschedule
- Wrong address: Find correct location
- Refusal: Document reason
- Damage: Assess and resolve

---

### Step 10: On-Site Payment Collection

**User Action:** Driver collects payment from customer

**System Action:** None (recorded later)

**Payment Methods at Delivery:**
- Cash only (typical)
- Mobile payment (if equipped)

**Receipt:**
- Issued if cash payment
- Or noted for later invoicing

**Business Rules:**
- Customer should verify product before paying
- Quantity check
- Product condition check

---

### Step 11: Delivery Completion

**User Action:** Cashier records delivery completion

**System Action:** Set end_date, mark delivered

**API:** `PUT /api/drinking-water-transaction/end-date/{id}/`

**Request Body:**
```json
{
  "end_date": "2025-10-22"
}
```

**Database Operation:**
```sql
UPDATE drinking_water_transactions\nSET end_date = '2025-10-22',\n    updated_at = NOW()\nWHERE drinking_water_transaction_id = 789;
```

**State Transition:** PENDING → DELIVERED

**Business Rules Applied:**
- **TX-WF-001:** Completion via end_date field
- **WD-DEL-001:** Delivery marked complete
- NOW counted in income calculations

---

### Step 12: Income Calculation

**System Action:** Calculate daily/monthly revenue

**Calculation:**
```python
# Single delivery income
gross_income = transaction.final_price  # Rp 40,000 (2 gallons × Rp 20,000)

# Business keeps all revenue (unlike other services)
business_income = gross_income  # 100% to business

# Employee share: Not tracked per transaction
# Overhead cost: Not itemized
```

**Income Distribution:**
- **Business:** Rp 40,000 (100%)
- **Employee/Overhead:** Built into pricing

**Business Rules Applied:**
- **WD-INC-001:** 100% revenue to business
- No employee commission per transaction
- Driver is employee (salary-based, not transaction-based)

---

### Step 13: Dashboard Update

**System Action:** Transaction appears in analytics

**Updates:**
- Today's water delivery revenue: +Rp 40,000
- Today's total revenue (all services)
- Customer gallon count (Today, This month)
- Driver performance (gallons delivered)
- Recurring revenue tracking

**API Endpoints:**
- `GET /api/dashboard/income/`
- `GET /api/drinking-water-customer-gallon/`
- `GET /api/drinking-water-customer-transaction/{customer_id}/`

---

### Step 14: Recurring Delivery Management

**User Action:** Schedule next delivery

**System Action:** Create next transaction or subscription record

**Subscription Model:**
- Customer specifies frequency
- Daily, weekly, or bi-weekly delivery
- Same product each time
- Price locked per water type

**Current System:**
- No automation for recurring
- Manual creation for each delivery
- Customer must reorder

**Manual Process:**
1. Customer calls or texts for next delivery
2. Cashier creates new transaction
3. Adds to driver's route
4. Repeats process

**Recommendation:**
- Add subscription table
- Auto-create transactions per frequency
- Customer portal for adjustments
- SMS reminder before delivery

---

## State Diagram

```mermaid
stateDiagram-v2\n    [*] --> INQUIRY: Customer requests water\n    \n    INQUIRY --> CUSTOMER_REGISTERED{Registered\\nCustomer?}\n    CUSTOMER_REGISTERED -->|Yes| ORDER_WATER: Load customer\n    CUSTOMER_REGISTERED -->|No| NEW_REGISTRATION: Register new customer\n    NEW_REGISTRATION --> ORDER_WATER\n    \n    ORDER_WATER --> ORDER_CREATED: Select water type\\nSpecify quantity\n    \n    ORDER_CREATED --> PENDING: Transaction created\\nend_date = NULL\n    \n    PENDING --> SCHEDULED: Assign to driver route\n    SCHEDULED --> IN_DELIVERY: Driver departs\n    IN_DELIVERY --> DELIVERING: At customer location\n    DELIVERING --> DELIVERED: Water unloaded\\nPayment collected\\nSet end_date\n    \n    DELIVERED --> PAYMENT_VERIFIED{Payment\\nVerified?}\n    PAYMENT_VERIFIED -->|Prepaid| COMPLETED: Already paid\n    PAYMENT_VERIFIED -->|COD OK| COMPLETED: Cash collected\n    PAYMENT_VERIFIED -->|Invoice| INVOICED: To be paid\n    \n    COMPLETED --> [*]\n    INVOICED --> PAYMENT_RECEIVED: Payment received\n    PAYMENT_RECEIVED --> [*]\n    \n    note right of PENDING\n        Status: end_date = NULL\n        Transaction created\n        Not yet delivered\n        Assigned to route\n    end note\n    \n    note right of DELIVERED\n        Status: end_date IS NOT NULL\n        Delivery completed\n        Now counted in income (100%)\n        Payment status depends on terms\n    end note
```

---

## Integration Points

### Database Tables

**Customer Table:** `drinking_water_customers`
```sql\ndrinking_water_customer_id (PK)\nname (VARCHAR) -- Customer name\naddress (TEXT) -- Delivery address\nphone_number (VARCHAR, nullable)\ncreated_at (DATETIME)\nupdated_at (DATETIME)\n```

**Product Type Table:** `drinking_water_types`
```sql\ndrinking_water_type_id (PK)\nname (VARCHAR) -- Product name\nprice (BIGINT) -- Price per unit\ncreated_at (DATETIME)\nupdated_at (DATETIME)\n```

**Transaction Table:** `drinking_water_transactions`
```sql\ndrinking_water_transaction_id (PK)\ndate (DATETIME) -- Order date\nname (VARCHAR, nullable) -- For walk-in customers\nphone_number (VARCHAR, nullable)\ndrinking_water_customer_id (FK, nullable) -- Registered customer\ndrinking_water_type_id (FK) -- Product type\nquantity (INT) -- Number of units\nfinal_price (BIGINT)\nend_date (DATE, nullable) -- Delivery completion date\ncreated_at (DATETIME)\nupdated_at (DATETIME)\n```

### API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/drinking-water-customer/` | GET | List all customers |
| `/api/drinking-water-customer/` | POST | Register new customer |
| `/api/drinking-water-customer/{id}/` | GET | Get customer details |
| `/api/drinking-water-customer/{id}/` | PUT | Update customer |
| `/api/drinking-water-customer/{id}/` | DELETE | Delete customer |
| `/api/drinking-water-type/` | GET | List water products |
| `/api/drinking-water-type/` | POST | Create new product |
| `/api/drinking-water-transaction/` | GET | List all deliveries |
| `/api/drinking-water-transaction/` | POST | Create new order |
| `/api/drinking-water-transaction/{id}/` | PUT | Update transaction |
| `/api/drinking-water-transaction/end-date/{id}/` | PUT | Mark delivered |
| `/api/drinking-water-customer-transaction/{id}/` | POST | Get customer history by date |
| `/api/drinking-water-customer-gallon/` | GET | Customer gallon tracking |
| `/api/dashboard/income/` | GET | Revenue dashboard |

---

## Business Rules Summary

### Customer Registration Rules

**BR-WD-001:** Customer registration for subscription
- Full name required
- Address required
- Phone number optional but recommended
- Can be looked up for future orders

### Order Rules

**BR-WD-002:** Two customer types
- Registered customers (has record, tracked)
- Walk-in customers (no record, one-time or informal)

**BR-WD-003:** Quantity-based transactions
- Customer specifies quantity
- Price calculated as quantity × type.price
- No discounts for bulk in current system

### Payment Rules

**BR-WD-004:** Multiple payment terms supported
- Prepayment (cash up front)
- COD (cash on delivery)
- Invoice (monthly billing)
- Can vary per customer

**BR-WD-005:** Driver collects payment
- Driver responsible for COD collection
- Driver reports amounts to office
- Reconciliation daily

### Income Rules

**BR-WD-006:** 100% revenue to business
- No employee commission per delivery
- Driver is salary-based employee
- All revenue counted in business income
- Different from other services (car wash 30-50%, laundry 60%)

### Delivery Rules

**BR-WD-007:** Completion via end_date
- NULL = Pending/scheduled
- NOT NULL = Delivered/completed
- Counted in income only when delivered

**BR-WD-008:** Recurring delivery support
- Regular customers on subscription
- Fixed schedule (daily, weekly, etc.)
- Can adjust quantity, skip, or pause

---

## Known Issues & Limitations

### Issue 1: No Automated Recurring Delivery

**Problem:** Each delivery must be manually created

**Impact:**
- Cashier burden for repeat orders
- No guarantee of timely delivery
- Customer satisfaction risk
- Error-prone manual scheduling

**Current Workaround:**
- Customers call/text for each delivery
- Manual entry by cashier

**Recommendation:**
- Add subscription/recurring table
- Auto-create transactions per frequency
- SMS reminders to customer
- Customer portal

---

### Issue 2: No Payment Tracking

**Problem:** Payment method and status not recorded per transaction

**Impact:**
- Cannot distinguish prepaid vs COD vs invoice
- No accounts receivable tracking
- Cannot send payment reminders
- Overdue tracking manual

**Recommendation:**
- Add payment_method field (PREPAID, COD, INVOICE)
- Add payment_status field (UNPAID, PAID, OVERDUE)
- Add payment_date field
- Track invoice aging

---

### Issue 3: No Driver Route Management

**Problem:** No system to optimize delivery routes

**Impact:**
- Manual driver scheduling
- Inefficient routing
- Longer delivery times
- Higher fuel costs

**Recommendation:**
- Add driver table
- Add route planning system
- GPS tracking
- Delivery time estimate

---

### Issue 4: No Delivery Capacity Tracking

**Problem:** Cannot track inventory of water in warehouse

**Impact:**
- Risk of stock-outs
- No inventory planning
- Manual stock counting

**Recommendation:**
- Add inventory table
- Track available units
- Warn on low stock
- Suggest order quantities

---

### Issue 5: No Bulk/Subscription Pricing

**Problem:** All customers pay same unit price

**Impact:**
- Cannot offer volume discounts
- Cannot retain large customers
- No tiered pricing

**Recommendation:**
- Add customer tier (retail, wholesale)
- Add bulk pricing rules
- Consider minimum order quantities

---

## Future Enhancements

### Priority 1: Critical

1. **Add Recurring Delivery Automation**
   - Subscription table
   - Auto-transaction creation
   - Customer notifications

2. **Add Payment Tracking**
   - Payment method per transaction
   - Payment status tracking
   - Invoice management

3. **Add Driver Management**
   - Driver table
   - Route assignments
   - Performance metrics

### Priority 2: Important

4. **Add Inventory Management**
   - Stock levels
   - Low stock warnings
   - Warehouse capacity

5. **Add Customer Portal**
   - Self-service orders
   - Subscription management
   - Payment history
   - Delivery tracking

6. **Add Bulk Pricing**
   - Tiered pricing
   - Volume discounts
   - Wholesale accounts

### Priority 3: Nice to Have

7. **Add GPS Tracking**
   - Real-time driver location
   - Delivery time estimate
   - Customer notifications

8. **Add Customer Loyalty**
   - Rewards program
   - Points per gallon
   - Referral bonuses

9. **Add Seasonal Management**
   - Increase delivery frequency in summer
   - Pause deliveries in low season
   - Promotional pricing

---

## Testing Scenarios

### Scenario 1: New Registered Customer, Single Delivery

**Input:**
- Register: Budi Hartono, Jl. Merdeka
- Order: 2 Galon 19L @ Rp 20,000
- Total: Rp 40,000
- Payment: Prepaid cash

**Expected:**
- Customer registered in system
- Transaction created with customer_id
- end_date set when delivered
- Income: Rp 40,000 to business
- Delivery tracked for repeat ordering

### Scenario 2: Walk-in Customer, One-time Delivery

**Input:**
- No registration (customer_id = NULL)
- Name: "Walk-in Customer"
- Order: 1 Botol 1.5L @ Rp 5,000
- Payment: COD

**Expected:**
- No customer record created
- Transaction recorded with name/phone
- Driver collects Rp 5,000 on delivery
- Income: Rp 5,000 when delivered

### Scenario 3: Recurring Customer, Monthly Invoice

**Input:**
- Registered: PT Maju Jaya (office)
- Weekly delivery: 10 Galon 19L @ Rp 20,000 = Rp 200,000
- Month deliveries: 4 weeks × Rp 200,000 = Rp 800,000
- Payment: Monthly invoice, net 30

**Expected:**
- 4 transactions created for month
- Total Rp 800,000 income each delivery
- Invoice issued at month-end
- Payment due tracking

### Scenario 4: Subscription Pause

**Input:**
- Regular customer on weekly subscription
- Requests pause for 2 weeks (vacation)
- Resumes after 2 weeks

**Expected:**
- Skip 2 weeks of automatic deliveries
- Resume week 3
- Customer contacted to confirm
- No order cancellation

---

## Comparison with Other Services

| Aspect | Car Wash | Laundry | Carpet | Water |
|--------|----------|---------|--------|-------|
| **Customer Type** | Walk-in | Walk-in/drop-off | Appointment | Registered |
| **Service Duration** | Minutes | Hours/Days | Days | Minutes (delivery) |
| **Income Model** | Per transaction | Per transaction | Per transaction | Recurring |
| **Employee Share** | 30-50% | 0% (salary) | 0% (salary) | 0% (salary) |
| **Repeat Rate** | Medium | Low | Low | Very High |
| **Revenue Predictability** | Variable | Variable | Variable | High |
| **Inventory Track** | None | Supplies | Supplies | Water stock |
| **Logistics** | In-shop | Customer pickup | Delivery | Delivery |
| **Payment Terms** | Immediate | At pickup | At pickup | Pre/COD/Invoice |

---

## Conclusion

Water delivery is the most **subscription-based** and **predictable** revenue stream:

✅ **Strengths:**
- Recurring revenue model
- Registered customer relationships
- High repeat rate
- Simple transaction (order → deliver → pay)
- 100% revenue to business
- Less labor-intensive per transaction

⚠️ **Areas for Improvement:**
- No automation for recurring deliveries
- No payment tracking (prepaid vs invoice)
- No driver/route management
- No inventory management
- Manual scheduling prone to errors
- Limited growth without efficiency improvements

This service demonstrates:
- Need for subscription management
- Importance of customer relationships
- Opportunity for automation
- Potential for B2B expansion (offices, businesses)

---

**Last Updated:** October 22, 2025
**Related Documents:**
- business-flows/car-wash-flow.md (comparison)
- business-flows/laundry-flow.md (comparison)
- business-logic/business-rules-catalog.md
- docs/analysis/current-app-analysis.md
