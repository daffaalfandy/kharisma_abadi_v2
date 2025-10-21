# Business Rules Catalog

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Source:** Kharisma Abadi codebase analysis

---

## Overview

This catalog documents all business rules implemented in the Kharisma Abadi cashier system. Each rule is assigned a unique identifier and includes implementation details, test cases, and recommendations.

**Rule Naming Convention:** `[Service]-[Category]-[Number]`
- Service: CW (Car Wash), LA (Laundry), CA (Carpet), WA (Water), EM (Employee), TX (Transaction), SY (System)
- Category: INC (Income), PRC (Pricing), VAL (Validation), WF (Workflow), CAL (Calculation)

---

## Table of Contents

1. [Car Wash Rules](#1-car-wash-rules)
2. [Laundry/Carpet Rules](#2-laundrycarpet-rules)
3. [Water Delivery Rules](#3-water-delivery-rules)
4. [Employee Rules](#4-employee-rules)
5. [Transaction Rules](#5-transaction-rules)
6. [System Rules](#6-system-rules)

---

## 1. Car Wash Rules

### CW-INC-001: Variable Employee Cut Calculation

**Rule:** Car wash employee compensation can be configured as either a fixed amount or percentage of transaction price.

**Logic:**
```python
if carwash_type.cut_type == 1:
    employee_cut = carwash_type.cut_amount  # Fixed Rupiah amount
else:  # cut_type == 2
    employee_cut = transaction.final_price * (carwash_type.cut_amount / 100)  # Percentage
```

**Configuration:**
- Stored in: `carwash_types` table
- Fields: `cut_type` (1=fixed, 2=percentage), `cut_amount` (value)
- Configurable: ✅ Yes (per service type)

**Implementation:**
- File: `controller/dashboard_controller.py`
- Lines: 24-27, 343-346, 486-489

**Test Cases:**
| cut_type | cut_amount | final_price | Expected Cut |
|----------|------------|-------------|--------------|
| 1 | 50000 | 100000 | 50000 |
| 1 | 75000 | 100000 | 75000 |
| 2 | 30 | 100000 | 30000 |
| 2 | 50 | 100000 | 50000 |

**Dependencies:** None

**Validation:**
- cut_type must be 1 or 2
- cut_amount must be >= 0
- If percentage, cut_amount should be 0-100

**Status:** ✅ Implemented, Configurable

---

### CW-INC-002: Multi-Employee Income Distribution

**Rule:** When multiple employees work on one car wash job, the total employee cut is divided equally among them using floor division.

**Logic:**
```python
total_employee_cut = calculate_cut(transaction)  # From CW-INC-001
per_employee_income = total_employee_cut // total_employees  # Floor division
```

**Implementation:**
- File: `controller/carwash_transaction_controller.py`
- Lines: 88-91

**Test Cases:**
| total_cut | employees | per_employee | Lost Amount |
|-----------|-----------|--------------|-------------|
| 50000 | 2 | 25000 | 0 |
| 50000 | 3 | 16666 | 2 |
| 100000 | 7 | 14285 | 5 |

**Issue:**
- 🔴 Floor division loses fractional Rupiah
- Remainder is not distributed
- Example: 50,000 ÷ 3 = 16,666 each, **2 Rupiah lost**

**Recommendation:**
- Use precise division and round
- Or give remainder to first employee
- Document rounding policy

**Status:** ⚠️ Implemented with precision loss

---

### CW-VAL-001: Pagination Limits

**Rule:** Car wash transaction list endpoints have maximum pagination bounds.

**Logic:**
```python
if page < 1:
    page = 1
if per_page < 1 or per_page > 100:
    per_page = 20  # Default
```

**Parameters:**
- Minimum page: 1
- Default per_page: 20
- Maximum per_page: 100

**Implementation:**
- File: `controller/carwash_transaction_controller.py`
- Lines: 23-26

**Test Cases:**
| Input page | Input per_page | Result page | Result per_page |
|------------|----------------|-------------|-----------------|
| 1 | 20 | 1 | 20 |
| 0 | 20 | 1 | 20 |
| -5 | 20 | 1 | 20 |
| 1 | 0 | 1 | 20 |
| 1 | 150 | 1 | 20 |

**Validation:**
- ✅ Prevents negative page numbers
- ✅ Prevents excessive data loading
- ✅ Provides sensible defaults

**Status:** ✅ Implemented correctly

---

## 2. Laundry/Carpet Rules

### LA-INC-001 / CA-INC-001: Fixed 60/40 Income Split

**Rule:** Laundry and carpet services have a **hardcoded** 60% business income, 40% employee/overhead cost.

**Logic:**
```python
gross_income = transaction.final_price
net_income = gross_income * 0.6  # 60% to business
employee_cut = gross_income * 0.4  # 40% to employees/costs
```

**Configuration:**
- Stored in: ❌ HARDCODED in controller
- Configurable: ❌ No

**Implementation:**
- File: `controller/dashboard_controller.py`
- Laundry: Lines 72, 380, 523
- Carpet: Line 66

**Test Cases:**
| final_price | net_income (60%) | employee_cut (40%) |
|-------------|------------------|--------------------|
| 100000 | 60000 | 40000 |
| 250000 | 150000 | 100000 |
| 50000 | 30000 | 20000 |

**Issue:**
- 🔴 **HARDCODED** - cannot be changed without code modification
- ⚠️ Inconsistent with car wash (which is configurable)
- ⚠️ No per-service-type flexibility

**Recommendation:**
- 🔴 **HIGH PRIORITY:** Move to database configuration
- Add `cut_type` and `cut_amount` fields to `laundry_types`
- Align with car wash pattern

**Status:** 🔴 Hardcoded, needs refactoring

---

### LA-WF-001 / CA-WF-001: Service Differentiation by Unit

**Rule:** Laundry and carpet transactions are stored in the same table (`laundry_transactions`) and differentiated by item measurement units.

**Logic:**
```python
is_carpet = False
for item in transaction.items:
    if item.unit.lower() in ['m', 'm2']:
        is_carpet = True
        break

if is_carpet:
    # Treat as carpet transaction
else:
    # Treat as laundry transaction
```

**Units:**
- **Laundry:** "pcs", "kg", "lusin", etc.
- **Carpet:** "m", "m2" (square meters)

**Implementation:**
- File: `controller/dashboard_controller.py`
- Lines: 55-57, 370-372
- File: `controller/laundry_transaction_controller.py`
- Lines: 138-140

**Test Cases:**
| Items | Units | Result |
|-------|-------|--------|
| [Item1] | ["pcs"] | Laundry |
| [Item1] | ["kg"] | Laundry |
| [Item1] | ["m2"] | Carpet |
| [Item1, Item2] | ["pcs", "m"] | Carpet (has 1 carpet item) |

**Issues:**
- ⚠️ Mixed transactions (laundry + carpet items) classified as carpet
- ⚠️ Case-sensitive matching could fail ("M" vs "m")
- ⚠️ No explicit service_category field

**Edge Cases:**
- Transaction with both laundry and carpet items → marked as carpet
- Item with unknown unit → treated as laundry

**Recommendation:**
- 🟡 Consider separate tables or explicit `service_category` field
- ✅ Document that case-insensitive matching is used
- ⚠️ Clarify business policy on mixed transactions

**Status:** ⚠️ Implemented, but ambiguous for mixed transactions

---

### LA-CAL-001: Item Price Distribution Logic

**Rule:** When final transaction price differs from sum of item prices, adjust item prices to match the final price.

**Logic:**
```python
total_price = sum(item.price * item.quantity for item in items)

if final_price == total_price:
    # No adjustment - price each item normally
    for item in items:
        item.item_price = item.price * item.quantity

elif final_price > total_price:
    # Extra charge - add ALL extra to first item
    extra = final_price - total_price
    items[0].item_price = items[0].price * items[0].quantity + extra
    # Other items priced normally

elif total_price > final_price:
    # Discount - subtract from items sequentially
    cut = total_price - final_price
    for item in items:
        item_price = item.price * item.quantity
        if item_price > cut:
            item_price -= cut
            cut = 0
        else:
            cut -= item_price
            item_price = 0
        item.item_price = item_price
```

**Implementation:**
- File: `controller/laundry_transaction_controller.py`
- Lines: 26-56, 91-114, 178-201

**Test Cases:**

**Scenario 1: Exact Match**
- Items: [10000, 20000]
- Final Price: 30000
- Result: [10000, 20000]

**Scenario 2: Extra Charge**
- Items: [10000, 20000]
- Final Price: 35000
- Extra: +5000
- Result: [**15000**, 20000] ← first item gets all extra

**Scenario 3: Small Discount**
- Items: [10000, 20000]
- Final Price: 25000
- Discount: -5000
- Result: [**5000**, 20000] ← first item discounted

**Scenario 4: Large Discount**
- Items: [10000, 20000]
- Final Price: 15000
- Discount: -15000
- Result: [**0**, **15000**] ← first item zeroed, then second item

**Business Justification:**
- Allows cashier flexibility to give discount or add surcharge
- Adjusts for manual pricing without recalculating all items
- First item always gets adjustment (extra or discount first)

**Issues:**
- 🟡 Why first item? No documented business reason
- ⚠️ Could confuse customers if itemized receipt shows first item with strange price
- ⚠️ Sequential discount could zero out early items

**Recommendation:**
- Document business reason for "first item" rule
- Consider proportional distribution instead
- Add UI indicator when price adjustment is applied

**Status:** ✅ Implemented, ⚠️ Needs documentation

---

## 3. Water Delivery Rules

### WA-INC-001: Fixed 60/40 Income Split

**Rule:** Same as LA-INC-001/CA-INC-001 - water delivery uses **hardcoded 60/40 split**.

**Logic:**
```python
gross_income = transaction.final_price
net_income = gross_income * 0.6  # 60% to business
employee_cut = gross_income * 0.4  # 40% to employees/costs
```

**Implementation:**
- File: `controller/dashboard_controller.py`
- Lines: 89, 395, 538

**Test Cases:**
| Gallons | Price/Gallon | final_price | net_income (60%) |
|---------|--------------|-------------|------------------|
| 5 | 10000 | 50000 | 30000 |
| 10 | 8000 | 80000 | 48000 |

**Issue:**
- 🔴 Same hardcoded issue as laundry/carpet

**Recommendation:**
- 🔴 **HIGH PRIORITY:** Make configurable

**Status:** 🔴 Hardcoded, needs refactoring

---

### WA-VAL-001: Optional Customer Association

**Rule:** Water delivery transactions can be associated with a registered customer OR be a walk-in sale.

**Logic:**
```python
# Transaction can have:
drinking_water_customer_id = <customer_id>  # Registered customer
# OR
drinking_water_customer_id = NULL  # Walk-in sale
name = "<customer name>"  # Manual entry
phone_number = "<phone>"  # Manual entry
```

**Database:**
- `drinking_water_transactions.drinking_water_customer_id` (nullable FK)
- `drinking_water_transactions.name` (nullable)
- `drinking_water_transactions.phone_number` (nullable)

**Business Rules:**
- If customer_id is set → use customer record for name/address
- If customer_id is NULL → use manual name/phone from transaction

**Implementation:**
- File: `controller/drinking_water_transaction_controller.py`
- Lines: 37-49

**Test Cases:**
| Scenario | customer_id | name | phone | Result |
|----------|-------------|------|-------|--------|
| Registered | 123 | NULL | NULL | Use customer#123 data |
| Walk-in | NULL | "John Doe" | "08123456" | Use manual data |

**Status:** ✅ Implemented correctly

---

## 4. Employee Rules

### EM-INC-001: Employee Income Aggregation

**Rule:** Employee income is calculated by summing compensation from all car wash jobs they worked on during a period.

**Logic:**
```python
employee_income = 0
for transaction in employee_car_wash_jobs:
    job_cut = calculate_cut(transaction)  # From CW-INC-001
    per_employee = job_cut / transaction.total_employees
    employee_income += per_employee

return employee_income
```

**Implementation:**
- File: `controller/employee_controller.py`
- Day income: Lines 92-103
- Month income: Lines 106-119
- Date range: Lines 145-170

**Test Cases:**
| Jobs | Job Cuts | Employees per Job | Employee Income |
|------|----------|-------------------|-----------------|
| 1 | [50000] | [2] | 25000 |
| 2 | [50000, 30000] | [2, 1] | 55000 (25000 + 30000) |

**Important Notes:**
- ✅ Uses precise division (`/`), not floor division
- ⚠️ **Only car wash jobs** included
- ❌ Laundry/carpet/water employee income **NOT tracked**

**Limitation:**
- 🔴 System only tracks car wash employee income
- Laundry, carpet, and water employees are not tracked individually

**Recommendation:**
- 🟡 Add employee tracking for other services
- Or document that only car wash tracks employees

**Status:** ✅ Implemented for car wash, ❌ Missing for other services

---

### EM-VAL-001: Unique Employee Names

**Rule:** Employee names must be unique across the system.

**Database:**
- `employees.name` has UNIQUE KEY constraint

**Validation:**
- Database enforces uniqueness
- Prevents duplicate employee records

**Implementation:**
- Database schema: `employees` table
- UNIQUE KEY `name` (`name`)

**Test Cases:**
| Action | Name | Result |
|--------|------|--------|
| Insert | "Ahmad" | Success |
| Insert | "ahmad" | Depends on collation (may fail) |
| Insert | "Ahmad" (duplicate) | Error |

**Issue:**
- ⚠️ Case sensitivity depends on MySQL collation
- ⚠️ No application-level validation shown in code

**Recommendation:**
- Add application-level check before database insert
- Return user-friendly error message

**Status:** ✅ Database constraint exists, ⚠️ No app validation

---

## 5. Transaction Rules

### TX-WF-001: Transaction Completion Status

**Rule:** A transaction is considered completed when it has an `end_date`. Pending transactions have `end_date = NULL`.

**Logic:**
```python
if transaction.end_date is not NULL:
    status = "COMPLETED"
    # Include in income calculations
else:
    status = "PENDING"
    # Exclude from income calculations
```

**Implementation:**
- Throughout dashboard controller
- Lines: 21, 51, 83, 340, 377, 392, 483, 520, 535

**Database:**
- `carwash_transactions.end_date` (DATE, nullable)
- `laundry_transactions.end_date` (DATETIME, nullable)
- `drinking_water_transactions.end_date` (DATE, nullable)

**Business Rules:**
- Completed transaction → counted in income
- Pending transaction → NOT counted in income
- No intermediate statuses (in-progress, cancelled, etc.)

**Issues:**
- ⚠️ No explicit `status` field - relies on NULL check
- ⚠️ Cannot distinguish between pending, in-progress, cancelled
- ⚠️ Inconsistent: car wash uses DATE, laundry uses DATETIME

**Test Cases:**
| end_date | Included in Income? |
|----------|---------------------|
| NULL | ❌ No |
| "2025-10-22" | ✅ Yes |
| "2025-10-22 14:30:00" | ✅ Yes |

**Recommendation:**
- 🔴 Add explicit `status` enum field
- Values: PENDING, IN_PROGRESS, COMPLETED, CANCELLED
- More explicit and allows for more statuses

**Status:** ⚠️ Implemented via NULL check, should be explicit status

---

### TX-VAL-001: Income Only From Completed Transactions

**Rule:** Only transactions with `end_date` set are included in income calculations and reports.

**Logic:**
```sql
WHERE end_date IS NOT NULL
```

**Applies To:**
- Dashboard income endpoints
- Chart data endpoints
- Employee income calculations

**Implementation:**
- Model layer (database queries)
- Controller layer (filters results)

**Impact:**
- Pending transactions do not appear in today's income
- Reports only show completed work
- Accurate financial reporting

**Status:** ✅ Implemented correctly

---

## 6. System Rules

### SY-VAL-001: Pagination Maximum Bounds

**Rule:** All paginated endpoints enforce maximum `per_page` limit to prevent excessive data loading.

**Logic:**
```python
if per_page < 1 or per_page > 100:
    per_page = 20  # Default
```

**Applied To:**
- Car wash transactions
- Laundry transactions
- Carpet transactions
- Water transactions
- Employees
- Water customers
- Job types

**Parameters:**
- Default: 20 items per page
- Maximum: 100 items per page
- Minimum page: 1

**Implementation:**
- All list controllers

**Status:** ✅ Implemented across all endpoints

---

### SY-CAL-001: Date-Based Filtering Uses Database Server Time

**Rule:** All date filters (today, this month, this year) use the **database server's current date**, not application server or client timezone.

**Logic:**
```sql
-- Today
WHERE date = CURDATE()

-- This month
WHERE date >= DATE_FORMAT(NOW(), '%Y-%m-01')

-- This year
WHERE date >= DATE_FORMAT(NOW(), '%Y-01-01')
```

**Implementation:**
- Model layer (SQL queries)
- Functions: NOW(), CURDATE(), DATE_FORMAT()

**Important Notes:**
- ⚠️ "Today" depends on database server timezone
- ⚠️ If server is in different timezone than business, "today" may be incorrect
- ⚠️ No client timezone handling

**Recommendation:**
- 🟡 Document database timezone configuration
- 🟡 Consider storing timezone preference
- ⚠️ Ensure database server timezone matches business location

**Status:** ✅ Implemented, ⚠️ Timezone-dependent

---

## 7. Chart Type Constants

### SY-CONST-001: Chart Type Enumeration

**Rule:** Chart data endpoints use numeric constants to specify which service type to display.

**Values:**
```python
type = 1  # Total (all services combined)
type = 2  # Car wash only
type = 3  # Laundry only
type = 4  # Carpet only
type = 5  # Drinking water only
```

**Implementation:**
- `controller/dashboard_controller.py`
- Lines: 328-329, 472

**Usage:**
```json
POST /api/dashboard/chart/year/
{
  "year": 2025,
  "type": 2  // Car wash only
}
```

**Recommendation:**
- ⚠️ Document in API specification
- ⚠️ Consider using string enum instead of magic numbers
- ⚠️ Add validation for valid type values

**Status:** ✅ Implemented, ⚠️ Needs documentation

---

## 8. Summary Statistics

### Total Rules Cataloged

| Category | Count |
|----------|-------|
| Income Calculation | 4 |
| Workflow | 2 |
| Validation | 7 |
| Calculation | 2 |
| System | 4 |
| **Total** | **19** |

### Rules by Service

| Service | Count |
|---------|-------|
| Car Wash | 3 |
| Laundry/Carpet | 4 |
| Water Delivery | 2 |
| Employee | 2 |
| Transaction | 2 |
| System | 6 |

### Critical Rules (Must Preserve in Rebuild)

1. **CW-INC-001**: Variable employee cut (configurable)
2. **LA-INC-001 / CA-INC-001**: 60/40 split (hardcoded - MUST document)
3. **WA-INC-001**: 60/40 split (hardcoded - MUST document)
4. **LA-CAL-001**: Item price distribution (first item gets adjustment)
5. **TX-WF-001**: Transaction completion via end_date
6. **LA-WF-001**: Carpet vs laundry via unit type

### Hardcoded Values That Should Be Configurable

1. 🔴 **Laundry income split: 60% business, 40% employees**
2. 🔴 **Carpet income split: 60% business, 40% employees**
3. 🔴 **Water delivery income split: 60% business, 40% employees**
4. ⚠️ **Chart type constants** (1-5)
5. ⚠️ **Service type constants** (1-3)

---

## Conclusion

The system has a **mix of configurable and hardcoded business rules**. The car wash service is well-designed with database-driven configuration, while laundry, carpet, and water delivery have critical business logic hardcoded in controllers.

**For rebuild success:**
- ✅ **Preserve all calculation formulas** (especially 60/40 splits)
- ✅ **Document hardcoded values** before they're lost
- ✅ **Add configuration system** for currently hardcoded values
- ✅ **Create unit tests** for all business rules
- ✅ **Add explicit status fields** instead of NULL checks

**Next Steps:**
1. Review and validate all rules with business stakeholders
2. Create test suite based on test cases above
3. Design configuration system for hardcoded values
4. Plan refactoring for explicit status fields

---

**Last Updated:** October 22, 2025
**Reviewed By:** Pending stakeholder review
