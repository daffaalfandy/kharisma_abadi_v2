# Carpet Washing Service Flow

**Service Type:** Carpet Washing (Karpet)
**Complexity:** High (Item-based pricing, often pickup/delivery)
**Frequency:** 20-30 orders per week (estimated)
**Average Duration:** 48-96 hours (multi-day service)

---

## Overview

### Purpose
Process carpet and large fabric cleaning orders from item specification through washing/treatment to delivery/pickup, with item-level tracking and specialized handling.

### Business Value
- Premium service with higher margins
- Item-based tracking for large items
- Specialized equipment requirements
- Optional pickup/delivery service
- Less frequent but higher-value transactions

### User Roles Involved
- **Cashier/Front Desk Staff** - Records items, collects payment
- **Service Staff** - Handles pickup, cleaning, delivery
- **Logistics** - Coordinates pickup/delivery (if applicable)
- **Customer** - Initiates service, receives items

### System Components
- POS System (Frontend)
- Transaction Management API
- Item Cataloging System (large items)
- Income Calculation Engine (60/40 split, same as laundry)
- Database (laundry_transactions, laundry_items for carpet items with units m/m2)

---

## Process Flow Diagram

```mermaid
flowchart TD
    Start([Customer Contacts for Carpet Service]) --> InitialConsult[Initial Consultation]
    InitialConsult --> HouseVisit{Pickup\\nRequired?}
    
    HouseVisit -->|Yes - Schedule Pickup| SchedulePickup[Schedule pickup date/time]
    HouseVisit -->|No - Customer Brings| CustomerDelivers[Customer brings carpet to facility]
    
    SchedulePickup --> PickupExecution[Service staff visits customer home]
    PickupExecution --> InspectItems[Inspect and catalog carpets]
    CustomerDelivers --> InspectItems
    
    InspectItems --> SelectType[For each carpet:\\nSelect carpet type from service list]\n    SelectType --> EnterDimensions[Enter dimensions\\n- Length (m)\\n- Width (m)\\nOR Area (m2)]\n    \n    EnterDimensions --> CheckType{Carpet Type\\nExists?}\n    CheckType -->|No| CreateType[Create new type in settings]\n    CheckType -->|Yes| CalcArea[Calculate total area]\n    CreateType --> CalcArea\n    \n    CalcArea --> CheckUnit{Unit System?}\n    CheckUnit -->|Length x Width| AreaCalc[area = length × width]\n    CheckUnit -->|Direct Area| AreaDirect[area = m2 entered]\n    \n    AreaCalc --> QuotePrice[Generate quote:\\nprice = area × rate_per_m2]\n    AreaDirect --> QuotePrice\n    \n    QuotePrice --> ReviewQuote[Customer reviews quote]\n    ReviewQuote --> Approve{Customer\\nApproves?}\n    \n    Approve -->|No| Negotiate[Negotiate price/scope]\n    Negotiate --> Approve\n    Approve -->|Yes| FinalPrice[Set final_price]\n    \n    FinalPrice --> CreateTransaction[Create Transaction\\nend_date = NULL]\n    CreateTransaction --> DocumentCondition[Document carpet condition:\\n- Color, material\\n- Stains, damage\\n- Photo/notes]\n    \n    DocumentCondition --> PrintTicket[Print service ticket with\\ncarpet details]\n    PrintTicket --> TransportToFacility[Transport carpet to facility]\n    TransportToFacility --> StorageQueue[Carpet placed in storage queue]\n    \n    StorageQueue --> PreTreatment[Pre-treatment:\\n- Spot cleaning\\n- Stain removal\\n- Moisture prep]\n    \n    PreTreatment --> MainWash[Main washing process\\nusing specialized equipment]\n    MainWash --> Drying[Drying in controlled\\nenvironment]\n    Drying --> FinalTreatment[Final treatment:\\n- Deodorizing\\n- Protection coating\\nOptional]\n    \n    FinalTreatment --> QualityCheck{Quality\\nCheck Pass?}\n    QualityCheck -->|No| Rework[Re-wash/treat problem areas]\n    Rework --> QualityCheck\n    \n    QualityCheck -->|Yes| ReadyForDelivery[Carpet ready for delivery]\n    ReadyForDelivery --> SetEndDate[Mark complete:\\nSet end_date = NOW]\n    \n    SetEndDate --> ScheduleDelivery{Delivery\\nRequired?}\n    \n    ScheduleDelivery -->|Yes| CoordDelivery[Coordinate delivery date/time]\n    ScheduleDelivery -->|No| CustomerPickup[Customer picks up at facility]\n    \n    CoordDelivery --> DeliveryStaff[Service staff delivers to customer]\n    DeliveryStaff --> InstallCarpet[Install carpet in customer's home]\n    CustomerPickup --> FinalInspection[Customer inspects carpet]\n    InstallCarpet --> FinalInspection\n    \n    FinalInspection --> Satisfaction{Customer\\nSatisfied?}\n    Satisfaction -->|No| Dispute[Handle service dispute]\n    Dispute --> Resolution[Resolve issue or refund]\n    \n    Satisfaction -->|Yes| ProcessPayment[Process Payment]\n    Resolution --> ProcessPayment\n    \n    ProcessPayment --> PaymentMethod{Payment\\nMethod?}\n    PaymentMethod -->|Cash| RecordCash[Record Cash]\n    PaymentMethod -->|Transfer| RecordTransfer[Record Transfer]\n    PaymentMethod -->|E-Wallet| RecordEWallet[Record E-Wallet]\n    PaymentMethod -->|Card| RecordCard[Record Card]\n    \n    RecordCash --> CalcIncome[Calculate Income:\\n60% business, 40% employees]\n    RecordTransfer --> CalcIncome\n    RecordEWallet --> CalcIncome\n    RecordCard --> CalcIncome\n    \n    CalcIncome --> PrintReceipt[Print receipt with warranty info]\n    PrintReceipt --> UpdateDashboard[Update dashboard analytics]\n    UpdateDashboard --> End([Service Complete])\n```

---

## Detailed Process Steps

### Step 1: Initial Consultation

**User Action:** Customer contacts business for carpet cleaning

**System Action:** None (phone/in-person consultation)

**Business Rules:**
- Carpets require assessment before quoting
- Different pricing for different carpet types
- Pickup/delivery optional but common
- Larger items than laundry

**Information Gathered:**
- Carpet size/area
- Carpet material (wool, synthetic, oriental)
- Condition (stains, damage)
- Special requirements (delicate, antique)

---

### Step 2: Pickup or Drop-off

**User Action:** Customer brings carpet or schedules pickup

**System Action:** Staff inspects carpet

**Two Scenarios:**

**A. Customer Drop-off:**
- Customer brings carpet to facility
- Staff unloads and inspects
- Check for damage during transport
- Document condition

**B. Pickup Service:**
- Schedule convenient pickup time
- Service staff visits customer home
- Load carpet carefully
- Document condition at pickup location
- Transport to facility

**Business Rules:**
- Document carpet condition BEFORE service
- Take photos if possible
- Note existing stains/damage
- Photo reference for dispute resolution

---

### Step 3: Item Cataloging

**User Action:** Cashier catalogs carpet with dimensions

**System Action:** Display carpet type selection and dimension input

**Fields:**
- **Carpet Type** (required)
  - Examples: Wool, Synthetic, Oriental, Modern, Persian
  - Each type has: name, base price per m²
  - Same as laundry types but with unit = "m" or "m2"

- **Dimensions** (one of two options)
  - Option A: Length (m) × Width (m) → Calculate area
  - Option B: Direct area input (m²)

- **Special Services** (optional)
  - Stain removal: +Rp X,000
  - Deodorizing: +Rp Y,000
  - Protection coating: +Rp Z,000

**API:** `GET /api/laundry-type/` (filtered for unit = "m" or "m2")

**Example Carpet Types:**
| Type | Unit | Base Price |
|------|------|------------|
| Wool | m² | Rp 50,000 |
| Synthetic | m² | Rp 35,000 |
| Oriental | m² | Rp 75,000 |
| Area Rug | m² | Rp 45,000 |

---

### Step 4: Area Calculation

**System Action:** Calculate carpet area and quote price

**Calculation Methods:**

**Method A: Length × Width**
```python
length_m = user_input  # 4.0 m
width_m = user_input   # 3.0 m
area = length_m * width_m  # 12 m²

price_per_m2 = carpet_type.price  # Rp 50,000
quoted_price = area * price_per_m2  # 12 × Rp 50,000 = Rp 600,000
```

**Method B: Direct Area**
```python
area = user_input  # 12 m²
quoted_price = area * price_per_m2  # Rp 600,000
```

**Business Rules Applied:**
- **CP-CAL-001:** Area-based pricing calculation
- Price proportional to carpet size
- Larger carpets = higher cost

---

### Step 5: Price Adjustment & Negotiation

**User Action:** Customer reviews quote, may negotiate

**System Action:** Allow cashier to adjust final price if needed

**Negotiation Scenarios:**
- Quantity discount (multiple carpets)
- Loyalty customer discount
- Seasonal promotion
- Bulk order discount

**Formula:**
```
initial_quote = area × price_per_m² + special_services
final_price = cashier_override or initial_quote
```

**Business Rules Same as Laundry:**
- **LA-CAL-001:** Price adjustment applies to laundry/carpet equally
- Extra charge: Add to first item
- Discount: Subtract sequentially
- Can zero items

---

### Step 6: Transaction Creation

**User Action:** Customer approves quote, agree to service

**System Action:** Create transaction record

**API:** `POST /api/laundry-transaction/` (same endpoint as laundry)

**Request Body:**
```json
{
  "name": "Budi Santoso",
  "phone_number": "08567890123",
  "start_date": "2025-10-22 14:30:00",
  "final_price": 600000,
  "item": [
    {
      "laundry_type_id": 5,  // Wool carpet
      "quantity": 12  // 12 m² (actually stored as area, but quantity field)
    }
  ]
}
```

**Database Operations:**
```sql
-- Same as laundry transaction
INSERT INTO laundry_transactions (...)
VALUES (...)

-- Stored as laundry_items with unit = "m2"
INSERT INTO laundry_items (...)
VALUES (transaction_id, type_id, 12, ...)  // Quantity = 12 m²
```

**State:** PENDING (end_date = NULL)

**Business Rules Applied:**
- **TX-WF-001:** Transaction completion tracking via end_date
- Classification as CARPET (unit = "m" or "m2")

---

### Step 7: Condition Documentation

**User Action:** Staff documents carpet condition with photos

**System Action:** Store in transaction record or notes

**Information Recorded:**
- Color description
- Material type
- Visible stains (location, type)
- Damage or wear (location, severity)
- Photos (if available)
- Special instructions from customer

**Business Rules:**
- Document BEFORE service
- Reference for dispute resolution
- Liability protection
- Quality baseline

**Storage:**
- Currently: Notes field in transaction (if available)
- Recommended: Separate attachments table

---

### Step 8: Pre-treatment & Inspection

**User Action:** Service staff inspects carpet for special handling

**System Action:** None (manual process)

**Process:**
1. Unload carpet carefully
2. Inspect for damage
3. Check for special materials
4. Identify stain types
5. Plan washing approach

**Special Handling Requirements:**
- Delicate/antique carpets: Gentle wash
- Wool: Lower temperature
- Oriental: Specialized treatment
- White/light colors: Careful stain removal

---

### Step 9: Washing & Treatment

**User Action:** Service staff performs carpet cleaning

**System Action:** None (manual service)

**Process:**
1. Pre-treatment of stains
2. Machine wash with appropriate detergent
3. Rinse thoroughly
4. Drying in controlled environment
5. Optional deodorizing
6. Optional protective coating
7. Final brushing/grooming

**Duration:**
- Pre-treatment: 2-4 hours
- Main wash: 1-2 hours
- Drying: 12-24 hours
- Total: 48-72 hours typically

**Quality Control:**
- Visual inspection for stains
- Feel for cleanliness
- Odor check
- Color integrity check

---

### Step 10: Service Completion

**User Action:** Staff marks carpet as complete and ready

**System Action:** Set end_date, transaction counted in income

**API:** `PUT /api/laundry-transaction/end-date/{id}/`

**Request Body:**
```json
{
  "end_date": "2025-10-24 16:00:00"
}
```

**State Transition:** PENDING → COMPLETED

**Business Rules Applied:**
- **TX-WF-001:** Completion via end_date
- NOW counted in income calculations
- 60% business, 40% employees/overhead (same as laundry)

---

### Step 11: Delivery or Pickup

**User Action:** Arrange carpet return to customer

**System Action:** None (manual coordination)

**Two Scenarios:**

**A. Delivery Service:**
- Coordinate delivery date/time
- Pack carpet carefully
- Load onto delivery vehicle
- Transport to customer location
- Service staff unloads
- Install carpet in customer's home
- Adjust and position
- Remove packaging

**B. Customer Pickup:**
- Customer notified carpet is ready
- Comes to facility at agreed time
- Staff loads carpet onto customer's vehicle
- Customer takes home

**Timeline:**
- Completion → Delivery scheduling: 1 day
- Delivery scheduling → Delivery: 1-7 days
- Or customer pickup: Same day to 1 week

---

### Step 12: Final Inspection & Acceptance

**User Action:** Customer inspects carpet after delivery/pickup

**System Action:** None (customer satisfaction check)

**Customer Checks:**
- Stains removed
- Color looks good
- No damage from service
- Carpet installed properly
- Smell is fresh
- Protective coating applied (if ordered)

**Dispute Resolution:**
- Customer unsatisfied with cleaning
- Stain not fully removed
- Color damage
- Damage during service

**Process:**
- Document issue with photos
- Attempt corrective service
- If unsuccessful, negotiate refund or credit
- Record reason for records

---

### Step 13: Payment Processing

**User Action:** Collect final payment from customer

**System Action:** Record payment method

**Payment Methods:**
- Cash
- Bank Transfer
- E-Wallet
- Card

**Business Rules:**
- Full payment before completion
- Or deposit at start, balance at completion
- Current system: No partial tracking

---

### Step 14: Income Calculation

**System Action:** Calculate income distribution

**Business Rules Applied:**
- **CP-INC-001:** Same as laundry - fixed 60/40 split
- **TX-WF-001:** Only counted if end_date IS NOT NULL

**Calculation:**
```python
gross_income = transaction.final_price  # Rp 600,000
business_income = gross_income * 0.6    # Rp 360,000 (60%)
employee_cost = gross_income * 0.4      # Rp 240,000 (40%)
```

**Income Distribution:**
- **Business:** Rp 360,000 (60%)
- **Employee/Overhead:** Rp 240,000 (40%)

**Note:** No individual employee tracking (same as laundry)

---

## State Diagram

```mermaid
stateDiagram-v2
    [*] --> INQUIRY: Customer requests service
    INQUIRY --> CONSULTATION: Initial assessment
    CONSULTATION --> SCHEDULED: Pickup/drop-off scheduled
    
    SCHEDULED --> PICKUP_EXECUTION: Service staff picks up (if applicable)
    PICKUP_EXECUTION --> CATALOGED: Carpet inspected, dimensions taken
    SCHEDULED --> CATALOGED: Or customer brings carpet\n\nPending: end_date = NULL\n\nNote: Pre-service state,\ncarpet in facility queue\n\nNot counted in income\n\nCan be modified/cancelled
    \n    CATALOGED --> PENDING: Transaction created\n    PENDING --> PRETREATED: Pre-treatment starts\n    PRETREATED --> WASHING: Main wash in progress\n    WASHING --> DRYING: Drying/curing\n    DRYING --> READY: Service complete\\nSet end_date\n    \n    READY --> DELIVERY_SCHEDULED: Delivery scheduled\n    READY --> CUSTOMER_PICKUP: Customer picks up\n    \n    DELIVERY_SCHEDULED --> DELIVERY_IN_PROGRESS: Delivery/installation\n    DELIVERY_IN_PROGRESS --> INSPECTED: Customer inspects\n    CUSTOMER_PICKUP --> INSPECTED\n    \n    INSPECTED --> SATISFIED{Customer\\nSatisfied?}\n    SATISFIED -->|No| REWORK: Service correction\n    REWORK --> INSPECTED\n    SATISFIED -->|Yes| PAYMENT: Payment processed\n    \n    PAYMENT --> [*]\n    \n    note right of PENDING\n        Status: end_date = NULL\n        Carpet in queue or being treated\n        Not counted in income\n    end note\n    \n    note right of READY\n        Status: end_date IS NOT NULL\n        Service complete, ready for delivery\n        NOW counted in income (60/40 split)\n        Waiting for customer to receive\n    end note\n```

---

## Integration Points

### Database Tables

Same as laundry (uses laundry_transactions and laundry_items)

**Key Difference:** Unit field distinguishes carpet from laundry
- Laundry items: unit = "pcs", "kg", "lusin", etc.
- Carpet items: unit = "m", "m2"

### API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/carpet-type/` | GET | List carpet types (laundry_types with unit = "m"/m2") |
| `/api/carpet-transaction/` | GET | List carpet transactions |
| `/api/laundry-transaction/` | POST | Create transaction (same endpoint, classified by item units) |
| `/api/laundry-transaction/end-date/{id}/` | PUT | Mark as completed |
| `/api/dashboard/income/` | GET | View income (includes carpet) |

---

## Business Rules Summary

### Pricing Rules

**BR-CP-001:** Area-based pricing
- Price determined by: area (m²) × type_rate
- Larger carpets = proportionally higher cost
- Can be adjusted by cashier

**BR-CP-002:** Special services add to base price
- Stain removal
- Deodorizing
- Protection coating
- Price negotiable

### Service Rules

**BR-CP-003:** Carpet classification
- Any item with unit "m" or "m2" = Carpet
- Mixed laundry + carpet transactions classified as Carpet
- Separate reporting but same income split

**BR-CP-004:** Pickup/Delivery optional
- Walk-in: Customer brings carpet
- Delivery: Business picks up, delivers
- Affects customer experience and logistics
- No separate tracking in current system

**BR-CP-005:** Completion via end_date
- NULL = Pending/In service
- NOT NULL = Complete/Ready
- Only counted in income when set

### Income Rules

**BR-CP-006:** Fixed 60/40 split (HARDCODED, same as laundry)
- 60% to business
- 40% to employees/overhead
- Not configurable without code change

---

## Known Issues & Limitations

### Issue 1: Same as Laundry

**Problem:** Uses laundry_transactions and laundry_items tables

**Impact:** Cannot distinguish carpet from laundry in database
- Both use same income split
- Both use same pricing mechanism
- Query requires unit field check

**Recommendation:** Separate tables or explicit service_type field

### Issue 2: No Pickup/Delivery Tracking

**Problem:** No fields for pickup location, delivery address, or dates

**Impact:** Logistics not tracked in database
- Manual scheduling outside system
- No scheduling visibility
- Cannot track service SLA

**Recommendation:** Add fields:
- customer_address
- pickup_date, delivery_date
- delivery_required flag

### Issue 3: Condition Documentation Not Tracked

**Problem:** Carpet condition photos/notes not stored in database

**Impact:** Cannot reference pre-service photos for disputes
- No baseline for damage claims
- Liability risk

**Recommendation:** Add attachments table with:
- before_photos
- after_photos
- condition_notes

### Issue 4: No Service Level Tracking

**Problem:** No way to track service duration or performance

**Impact:** Cannot measure efficiency
- No visibility into queue
- Cannot optimize turnaround

**Recommendation:** Add fields:
- pickup_date, start_date, end_date, delivery_date
- Calculate service_days for analytics

---

## Future Enhancements

### Priority 1: Critical

1. **Separate Carpet from Laundry**
   - Different pricing models
   - Different workflows
   - Different table or clear differentiation

2. **Add Pickup/Delivery Tracking**
   - Customer address
   - Scheduled dates
   - Delivery confirmation

3. **Add Condition Documentation**
   - Attachment storage
   - Before/after photos
   - Pre-service condition notes

### Priority 2: Important

4. **Add Explicit Service Status**
   - More granular than pending/complete
   - PENDING, PRETREATED, WASHING, DRYING, READY, DELIVERED

5. **Add Service Level Targets**
   - Turnaround time SLA
   - Quality standards
   - Performance metrics

6. **Make Income Split Configurable**
   - Database-driven like car wash
   - Per-carpet-type customization

### Priority 3: Nice to Have

7. **Add Carpet Registration**
   - Customer can register carpets
   - Track cleaning history
   - Warranty information

8. **Add Customer Loyalty**
   - Regular customer discounts
   - Lifetime carpet care program

9. **Add Quality Guarantee**
   - Money-back guarantee
   - Replacement service coverage

---

## Testing Scenarios

### Scenario 1: Single Wool Carpet, No Adjustments

**Input:**
- Type: Wool (Rp 50,000/m²)
- Dimensions: 4m × 3m = 12 m²
- Final Price: 12 × Rp 50,000 = Rp 600,000

**Expected:**
- Gross: Rp 600,000
- Business: Rp 360,000 (60%)
- Employees: Rp 240,000 (40%)

### Scenario 2: Multiple Carpets

**Input:**
- Carpet A: Wool 3m × 4m = 12 m² @ Rp 50,000
- Carpet B: Synthetic 2m × 2.5m = 5 m² @ Rp 35,000
- Total: (12 × Rp 50,000) + (5 × Rp 35,000) = Rp 775,000

**Expected:**
- Gross: Rp 775,000
- Business: Rp 465,000
- Employees: Rp 310,000

### Scenario 3: With Special Services

**Input:**
- Wool 4m × 3m = 12 m² @ Rp 50,000 = Rp 600,000
- Special Services: +Rp 150,000 (stain removal + deodorizing + coating)
- Final Price: Rp 750,000

**Expected:**
- Business: Rp 450,000 (60%)
- Employees: Rp 300,000 (40%)

### Scenario 4: Customer Discount

**Input:**
- Calculated: Rp 600,000
- Final Price: Rp 500,000 (Rp 100,000 discount)
- Adjustment: Subtract Rp 100,000 from first item

**Expected:**
- Gross: Rp 500,000
- Business: Rp 300,000
- Employees: Rp 200,000

---

## Comparison with Laundry Service

| Aspect | Laundry | Carpet |
|--------|---------|--------|
| **Item Size** | Small items (clothes, linens) | Large items (carpets, rugs) |
| **Pricing** | Per-item unit cost | Per-area (m²) cost |
| **Processing Time** | 24-48 hours | 48-96 hours |
| **Storage** | Compact shelving | Large warehouse space |
| **Equipment** | Standard washers/dryers | Specialized carpet equipment |
| **Handling** | Can stack items | Careful individual handling |
| **Logistics** | Customer pickup/drop-off | Pickup/delivery common |
| **Income Split** | 60/40 (hardcoded) | 60/40 (hardcoded) |
| **Database Table** | Same (laundry_transactions) | Same (laundry_transactions) |
| **Unit Differentiator** | unit != "m"/"m2" | unit = "m"/"m2" |

---

## Conclusion

Carpet washing is a **premium service** with unique characteristics:

✅ **Strengths:**
- Higher value transactions than laundry
- Area-based pricing is fair and scalable
- Optional pickup/delivery provides value-add
- Multi-step workflow manageable

⚠️ **Areas for Improvement:**
- Mixed in with laundry data (should be separate)
- No pickup/delivery tracking
- No condition documentation
- No logistics visibility
- Same hardcoded 60/40 split

This service demonstrates need for:
- Better data separation (carpet vs laundry)
- Logistics integration
- Quality assurance documentation
- Service level management

---

**Last Updated:** October 22, 2025
**Related Documents:**
- business-flows/laundry-flow.md (comparison)
- business-logic/business-rules-catalog.md
- docs/analysis/current-app-analysis.md
