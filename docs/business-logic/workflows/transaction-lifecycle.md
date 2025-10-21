# Transaction Lifecycle Workflows

**Document Version:** 1.0
**Analysis Date:** October 22, 2025

---

## Overview

This document visualizes the transaction lifecycle workflows for all services in the Kharisma Abadi system.

---

## 1. Car Wash Transaction Workflow

```mermaid
stateDiagram-v2
    [*] --> Created: Customer arrives
    Created --> Pending: Assign employees\nSet service type\nRecord license plate
    Pending --> InProgress: Start washing
    InProgress --> Completed: Set end_date\nCalculate income
    Completed --> [*]

    note right of Pending
        Status: end_date = NULL
        Not counted in income
    end note

    note right of Completed
        Status: end_date IS NOT NULL
        Included in income reports
        Employee income calculated
    end note
```

### State Details

| State | end_date | Included in Income? | Actions |
|-------|----------|---------------------|---------|
| **Created** | NULL | ❌ No | Record basic info |
| **Pending** | NULL | ❌ No | Assign employees, set price |
| **In Progress** | NULL | ❌ No | Service being performed |
| **Completed** | Set (DATE) | ✅ Yes | Calculate & distribute income |

### Business Rules Applied

1. **CW-INC-001**: Employee cut calculated (fixed or percentage)
2. **CW-INC-002**: Cut divided among all assigned employees
3. **TX-WF-001**: Only completed (end_date set) counted in income

---

## 2. Laundry/Carpet Transaction Workflow

```mermaid
stateDiagram-v2
    [*] --> Created: Customer drops off items
    Created --> ItemsCataloged: Record each item\nService type\nQuantity
    ItemsCataloged --> Pending: Calculate price\nSet final_price
    Pending --> InProgress: Processing
    InProgress --> Ready: Set end_date\nCustomer notified
    Ready --> PickedUp: Customer picks up
    PickedUp --> [*]

    note right of ItemsCataloged
        Item price distribution
        applied if final_price
        differs from sum
    end note

    note right of Ready
        Status: end_date IS NOT NULL
        Counted in income
        60% business, 40% employees
    end note
```

### State Details

| State | end_date | Included in Income? | Actions |
|-------|----------|---------------------|---------|
| **Created** | NULL | ❌ No | Customer info recorded |
| **Items Cataloged** | NULL | ❌ No | List items, types, quantities |
| **Pending** | NULL | ❌ No | Price calculated |
| **In Progress** | NULL | ❌ No | Washing/ironing |
| **Ready** | Set (DATETIME) | ✅ Yes | Items ready for pickup |
| **Picked Up** | Set (DATETIME) | ✅ Yes | Customer retrieved items |

### Service Type Differentiation

```mermaid
flowchart TD
    Start[Transaction Created] --> CheckItems[Check Item Units]
    CheckItems --> HasCarpetUnit{Any item with\nunit = 'm' or 'm2'?}
    HasCarpetUnit -->|Yes| Carpet[Classify as Carpet]
    HasCarpetUnit -->|No| Laundry[Classify as Laundry]
    Carpet --> Apply60_40[Apply 60/40 split]
    Laundry --> Apply60_40
    Apply60_40 --> End[Income Calculated]
```

### Business Rules Applied

1. **LA-WF-001 / CA-WF-001**: Service differentiation by unit
2. **LA-INC-001 / CA-INC-001**: 60% business, 40% employees (hardcoded)
3. **LA-CAL-001**: Item price distribution if final_price ≠ sum
4. **TX-WF-001**: Only completed (end_date set) counted

---

## 3. Water Delivery Transaction Workflow

```mermaid
stateDiagram-v2
    [*] --> CustomerSelect: Customer orders
    CustomerSelect --> RegisteredCustomer: Existing customer
    CustomerSelect --> WalkInCustomer: New/walk-in
    RegisteredCustomer --> OrderCreated: Link to customer record
    WalkInCustomer --> OrderCreated: Manual name/phone
    OrderCreated --> Pending: Set type, quantity\nCalculate price
    Pending --> Delivered: Set end_date\nDelivery confirmed
    Delivered --> [*]

    note right of Delivered
        Status: end_date IS NOT NULL
        Counted in income
        60% business, 40% employees
    end note
```

### State Details

| State | end_date | Included in Income? | Actions |
|-------|----------|---------------------|---------|
| **Customer Select** | N/A | ❌ No | Choose customer or walk-in |
| **Order Created** | NULL | ❌ No | Record type, quantity |
| **Pending** | NULL | ❌ No | Awaiting delivery |
| **Delivered** | Set (DATE) | ✅ Yes | Delivery confirmed |

### Customer Type Decision

```mermaid
flowchart TD
    Start[Water Order] --> CheckCustomer{Customer Type?}
    CheckCustomer -->|Registered| LinkCustomer[Set drinking_water_customer_id]
    CheckCustomer -->|Walk-in| ManualEntry[customer_id = NULL\nManual name/phone]
    LinkCustomer --> CreateOrder[Create Transaction]
    ManualEntry --> CreateOrder
    CreateOrder --> End[Order Created]
```

### Business Rules Applied

1. **WA-VAL-001**: Optional customer association
2. **WA-INC-001**: 60% business, 40% employees (hardcoded)
3. **TX-WF-001**: Only completed (end_date set) counted

---

## 4. Income Calculation Workflow

```mermaid
flowchart TD
    Start[Transaction Completed] --> CheckEndDate{end_date\nIS NOT NULL?}
    CheckEndDate -->|No| Exclude[Exclude from income]
    CheckEndDate -->|Yes| CheckService{Service Type?}
    CheckService -->|Car Wash| CarWashCalc[Calculate employee cut\nusing cut_type/cut_amount]
    CheckService -->|Laundry| LaundryCalc[Apply 60/40 split]
    CheckService -->|Carpet| CarpetCalc[Apply 60/40 split]
    CheckService -->|Water| WaterCalc[Apply 60/40 split]
    CarWashCalc --> CarWashDiv[Divide cut among\nemployees floor division]
    LaundryCalc --> FixedSplit[net_income = price * 0.6]
    CarpetCalc --> FixedSplit
    WaterCalc --> FixedSplit
    CarWashDiv --> AddToIncome[Add to income reports]
    FixedSplit --> AddToIncome
    Exclude --> End[Not in reports]
    AddToIncome --> End
```

### Income Aggregation

```mermaid
flowchart LR
    CW[Car Wash\nTransactions] --> CWIncome[Calculate CW Income]
    LA[Laundry\nTransactions] --> LAIncome[Calculate LA Income]
    CA[Carpet\nTransactions] --> CAIncome[Calculate CA Income]
    WA[Water\nTransactions] --> WAIncome[Calculate WA Income]
    CWIncome --> TotalGross[Total Gross Income]
    LAIncome --> TotalGross
    CAIncome --> TotalGross
    WAIncome --> TotalGross
    CWIncome --> TotalNet[Total Net Income]
    LAIncome --> TotalNet
    CAIncome --> TotalNet
    WAIncome --> TotalNet
    TotalGross --> Dashboard[Dashboard Display]
    TotalNet --> Dashboard
```

---

## 5. Item Price Distribution Workflow (Laundry/Carpet)

```mermaid
flowchart TD
    Start[Transaction Created] --> CalcTotal[Calculate total_price\nsum of item price * quantity]
    CalcTotal --> Compare{final_price vs\ntotal_price?}
    Compare -->|Equal| NoAdjust[No adjustment needed\nitem_price = price * qty]
    Compare -->|final > total| ExtraCharge[extra = final - total\nAdd to FIRST item]
    Compare -->|total > final| Discount[cut = total - final\nSubtract sequentially]
    ExtraCharge --> AdjustFirst[item[0].item_price =\nprice * qty + extra]
    ExtraCharge --> RestNormal[Other items:\nitem_price = price * qty]
    Discount --> Sequential[For each item:\nif item_price > cut:\n  subtract cut\nelse:\n  zero out item,\n  carry cut forward]
    NoAdjust --> End[Save transaction]
    AdjustFirst --> End
    RestNormal --> End
    Sequential --> End
```

### Example Scenarios

**Scenario 1: Extra Charge (+5,000)**
```
Items:        [10,000, 20,000]
Total Price:  30,000
Final Price:  35,000
Extra:        +5,000

Result:       [15,000, 20,000]
              ↑ First item gets all extra
```

**Scenario 2: Large Discount (-15,000)**
```
Items:        [10,000, 20,000]
Total Price:  30,000
Final Price:  15,000
Discount:     -15,000

Step 1: Item[0] = 10,000 - 10,000 = 0 (zeroed)
        Remaining cut = -5,000

Step 2: Item[1] = 20,000 - 5,000 = 15,000

Result:       [0, 15,000]
```

---

## 6. Employee Income Workflow (Car Wash Only)

```mermaid
flowchart TD
    Start[Employee Works] --> AssignJob[Assigned to car wash job\nvia carwash_employees]
    AssignJob --> JobComplete{Job completed?\nend_date set?}
    JobComplete -->|No| Wait[Wait for completion]
    JobComplete -->|Yes| CalcCut[Calculate total employee cut\nusing cut_type/cut_amount]
    CalcCut --> CountEmployees[Count employees\non this job]
    CountEmployees --> Divide[per_employee =\ntotal_cut // num_employees]
    Divide --> AddToIncome[Add to employee's\nday/month/year income]
    AddToIncome --> End[Display in\nemployee income report]
    Wait --> End2[Not counted yet]
```

### Income Aggregation Period Filters

```mermaid
flowchart LR
    AllJobs[All Completed\nCar Wash Jobs] --> FilterPeriod{Period?}
    FilterPeriod -->|Today| FilterToday[WHERE date = CURDATE]
    FilterPeriod -->|This Month| FilterMonth[WHERE date >= this month start]
    FilterPeriod -->|This Year| FilterYear[WHERE date >= this year start]
    FilterPeriod -->|All Time| NoFilter[No date filter]
    FilterPeriod -->|Custom Range| FilterRange[WHERE date BETWEEN\nstart_date AND end_date]
    FilterToday --> CalcIncome[Sum per-job income]
    FilterMonth --> CalcIncome
    FilterYear --> CalcIncome
    NoFilter --> CalcIncome
    FilterRange --> CalcIncome
    CalcIncome --> Display[Show employee income]
```

---

## 7. Common Transaction Operations

### Create Transaction

```mermaid
sequenceDiagram
    participant UI as Frontend UI
    participant API as Backend API
    participant DB as Database
    UI->>API: POST /api/{service}-transaction/
    API->>API: Validate input
    API->>DB: INSERT INTO {service}_transactions
    DB-->>API: transaction_id
    alt Has related items (laundry/carpet)
        API->>DB: INSERT INTO laundry_items
    end
    alt Has employees (car wash)
        API->>DB: INSERT INTO carwash_employees
    end
    API-->>UI: 201 Created {transaction_id}
```

### Update Transaction

```mermaid
sequenceDiagram
    participant UI as Frontend UI
    participant API as Backend API
    participant DB as Database
    UI->>API: PUT /api/{service}-transaction/{id}/
    API->>DB: SELECT transaction WHERE id = {id}
    DB-->>API: existing_data
    alt Transaction not found
        API-->>UI: 404 Not Found
    else Transaction exists
        alt Has items (laundry/carpet)
            API->>DB: DELETE FROM laundry_items WHERE tx_id = {id}
            API->>DB: INSERT new items
        end
        alt Has employees (car wash)
            API->>DB: DELETE FROM carwash_employees WHERE tx_id = {id}
            API->>DB: INSERT new employees
        end
        API->>DB: UPDATE {service}_transactions SET ... WHERE id = {id}
        DB-->>API: Success
        API-->>UI: 200 OK
    end
```

### Complete Transaction

```mermaid
sequenceDiagram
    participant UI as Frontend UI
    participant API as Backend API
    participant DB as Database
    UI->>API: PUT /api/{service}-transaction/end-date/{id}/
    API->>DB: UPDATE {service}_transactions\nSET end_date = NOW()\nWHERE id = {id}
    DB-->>API: Success
    Note over DB: Transaction now included\nin income calculations
    API-->>UI: 200 OK
```

---

## 8. Dashboard Income Calculation Flow

```mermaid
flowchart TD
    Start[Dashboard Load] --> FetchAll[Fetch all completed transactions\nwhere end_date IS NOT NULL]
    FetchAll --> GroupByService[Group by service type]
    GroupByService --> CalcCW[Car Wash:\nApply variable cut logic]
    GroupByService --> CalcLA[Laundry:\nApply 60/40 split]
    GroupByService --> CalcCA[Carpet:\nApply 60/40 split]
    GroupByService --> CalcWA[Water:\nApply 60/40 split]
    CalcCW --> AggCW[Sum gross_income\nSum net_income]
    CalcLA --> AggLA[Sum gross_income\nSum net_income]
    CalcCA --> AggCA[Sum gross_income\nSum net_income]
    CalcWA --> AggWA[Sum gross_income\nSum net_income]
    AggCW --> TotalGross[total_gross =\nCW + LA + CA + WA]
    AggLA --> TotalGross
    AggCA --> TotalGross
    AggWA --> TotalGross
    AggCW --> TotalNet[total_net =\nCW_net + LA_net + CA_net + WA_net]
    AggLA --> TotalNet
    AggCA --> TotalNet
    AggWA --> TotalNet
    TotalGross --> Display[Display on dashboard]
    TotalNet --> Display
```

---

## 9. Key Transition Triggers

### What Triggers State Transitions

| Transition | Trigger | API Endpoint | Sets |
|------------|---------|--------------|------|
| **Created → Pending** | Transaction saved | POST /{service}-transaction/ | Basic fields |
| **Pending → In Progress** | (Manual, no API) | N/A | N/A |
| **In Progress → Completed** | Mark as complete | PUT /{service}-transaction/end-date/{id}/ | end_date |

### Critical Status Field

**All Services:**
- `end_date IS NULL` → **Pending** (not counted)
- `end_date IS NOT NULL` → **Completed** (counted in income)

**No intermediate statuses tracked** (in-progress, ready, etc.)

---

## 10. Business Rules Summary by Workflow

| Workflow | Key Business Rules |
|----------|-------------------|
| **Car Wash** | Variable cut (CW-INC-001), Multi-employee division (CW-INC-002) |
| **Laundry/Carpet** | 60/40 split (LA-INC-001), Service differentiation (LA-WF-001), Item price distribution (LA-CAL-001) |
| **Water Delivery** | 60/40 split (WA-INC-001), Optional customer (WA-VAL-001) |
| **Employee Income** | Aggregation (EM-INC-001), Car wash only |
| **Transaction Status** | Completion via end_date (TX-WF-001) |

---

## Conclusion

All services follow a similar **Created → Pending → Completed** lifecycle, with completion triggered by setting `end_date`. The key difference is in **income calculation**:

- **Car Wash:** Configurable, per-employee distribution
- **Laundry/Carpet/Water:** Hardcoded 60/40 split, no employee tracking

**For rebuild:**
- ✅ Preserve the `end_date IS NOT NULL` completion logic
- ✅ Implement the 60/40 split (currently hardcoded)
- ✅ Maintain item price distribution logic
- ⚠️ Consider explicit status enum instead of NULL checks

---

**Last Updated:** October 22, 2025
