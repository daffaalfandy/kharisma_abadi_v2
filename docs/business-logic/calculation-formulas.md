# Business Calculation Formulas

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Source:** Production codebase analysis

---

## Overview

This document catalogs all financial and business calculations implemented in the Kharisma Abadi system. These formulas are critical business logic that must be preserved and correctly implemented in any rebuild.

---

## Table of Contents

1. [Car Wash Income Calculations](#1-car-wash-income-calculations)
2. [Laundry/Carpet Income Calculations](#2-laundrycarpet-income-calculations)
3. [Water Delivery Income Calculations](#3-water-delivery-income-calculations)
4. [Employee Income Calculations](#4-employee-income-calculations)
5. [Laundry Item Pricing Logic](#5-laundry-item-pricing-logic)
6. [Transaction Aggregations](#6-transaction-aggregations)

---

## 1. Car Wash Income Calculations

### 1.1 Employee Cut Calculation

**Business Rule:** Car wash income is split between the business and employees based on configurable cut rules.

**Formula:**

```python
# Two types of cut calculation:
if cut_type == 1:
    # Type 1: Fixed amount per transaction
    employee_cut = cut_amount
else:
    # Type 2: Percentage of final price
    employee_cut = final_price * (cut_amount / 100)

# Business net income
net_income = gross_income - employee_cut
```

**Parameters:**
- `cut_type`: 1 = Fixed amount, 2 = Percentage
- `cut_amount`: Amount (Rupiah) or percentage value
- `final_price`: Transaction total price
- `gross_income`: Total revenue from transaction

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:24-27`
- `be-kharisma-abadi/controller/dashboard_controller.py:343-346`

**Example:**

| Scenario | cut_type | cut_amount | final_price | employee_cut | net_income |
|----------|----------|------------|-------------|--------------|------------|
| Fixed | 1 | 50,000 | 100,000 | 50,000 | 50,000 |
| Percentage (30%) | 2 | 30 | 100,000 | 30,000 | 70,000 |

**Important Notes:**
- ✅ Cut rules are stored in `carwash_types` table (`cut_type`, `cut_amount`)
- ✅ This is **configurable** per service type
- ⚠️ **Only completed transactions** (where `end_date IS NOT NULL`) are included in income

---

### 1.2 Per-Employee Income Distribution

**Business Rule:** When multiple employees work on one car wash job, the employee cut is divided equally among them.

**Formula:**

```python
# Calculate total employee cut (from 1.1)
if cut_type == 1:
    total_employee_cut = cut_amount
else:
    total_employee_cut = final_price * (cut_amount / 100)

# Divide among employees
per_employee_income = total_employee_cut // total_employees  # Floor division
```

**Code Location:**
- `be-kharisma-abadi/controller/carwash_transaction_controller.py:88-91`
- `be-kharisma-abadi/controller/employee_controller.py:97-102`

**Example:**

| Scenario | final_price | cut_type | cut_amount | total_employees | per_employee_income |
|----------|-------------|----------|------------|-----------------|---------------------|
| Fixed, 2 employees | 100,000 | 1 | 50,000 | 2 | 25,000 |
| Percentage, 3 employees | 100,000 | 2 | 30 | 3 | 10,000 |

**Important Notes:**
- ⚠️ Uses **floor division** (`//`), so remainder is lost
- ⚠️ Example: 50,000 ÷ 3 = 16,666.66... → **16,666** per employee, 2 Rupiah lost
- 🔴 **ISSUE:** Small amounts are lost due to rounding

---

## 2. Laundry/Carpet Income Calculations

### 2.1 Laundry/Carpet Net Income

**Business Rule:** Laundry and carpet services use a **fixed 60% business cut**, with 40% going to employees/overhead.

**Formula:**

```python
# Gross income
gross_income = final_price

# Net income (60% to business, 40% to employees/costs)
net_income = final_price * 0.6

# Employee/overhead cut
employee_cut = final_price * 0.4
```

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:66` (carpet)
- `be-kharisma-abadi/controller/dashboard_controller.py:72` (laundry)
- `be-kharisma-abadi/controller/dashboard_controller.py:380` (chart calculation)

**Example:**

| Service | final_price | net_income (60%) | employee_cut (40%) |
|---------|-------------|------------------|--------------------|
| Laundry | 100,000 | 60,000 | 40,000 |
| Carpet | 250,000 | 150,000 | 100,000 |

**Important Notes:**
- 🔴 **HARDCODED:** The 60%/40% split is hardcoded in controller logic
- ⚠️ **NOT CONFIGURABLE:** Cannot be changed per service type (unlike car wash)
- ⚠️ **INCONSISTENT:** Car wash has configurable cuts, but laundry/carpet do not
- 🔴 **ISSUE:** Should be configurable in database, not hardcoded

---

## 3. Water Delivery Income Calculations

### 3.1 Water Delivery Net Income

**Business Rule:** Water delivery uses the **same 60% business cut** as laundry/carpet.

**Formula:**

```python
# Gross income
gross_income = final_price

# Net income (60% to business)
net_income = final_price * 0.6

# Employee/overhead cut (40%)
employee_cut = final_price * 0.4
```

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:89` (income calculation)
- `be-kharisma-abadi/controller/dashboard_controller.py:395` (chart calculation)

**Example:**

| Quantity (Gallons) | Price per Gallon | final_price | net_income (60%) | employee_cut (40%) |
|--------------------|------------------|-------------|------------------|--------------------|
| 5 | 10,000 | 50,000 | 30,000 | 20,000 |

**Important Notes:**
- 🔴 **HARDCODED:** Same issue as laundry/carpet
- ⚠️ No per-gallon configuration in the formula shown
- ⚠️ Final price calculation is done before this formula (quantity × unit price)

---

## 4. Employee Income Calculations

### 4.1 Employee Daily/Monthly Income

**Business Rule:** Employee income is calculated by summing all car wash jobs they worked on during the period.

**Formula:**

```python
employee_income = 0

for transaction in employee_transactions:
    if transaction['cut_type'] == 1:
        income_from_job = transaction['cut_amount']
    else:
        income_from_job = transaction['final_price'] * (transaction['cut_amount'] / 100)

    # Divide by number of employees on that job
    per_employee = income_from_job / transaction['total_employees']

    employee_income += per_employee

return employee_income
```

**Code Location:**
- `be-kharisma-abadi/controller/employee_controller.py:92-103` (day income)
- `be-kharisma-abadi/controller/employee_controller.py:106-119` (month income)
- `be-kharisma-abadi/controller/employee_controller.py:167-170` (by date range)

**Important Notes:**
- ✅ Uses **precise division** (`/`), not floor division
- ✅ Aggregates income across all transactions
- ⚠️ **Only car wash jobs** are included (no laundry/carpet/water employee income tracked)

---

### 4.2 Employee Income by Date Range

**Business Rule:** Same as daily/monthly, but filtered by custom date range.

**Code Location:**
- `be-kharisma-abadi/controller/employee_controller.py:145-170`

**Filter Applied:**
```sql
WHERE date >= start_date AND date <= end_date
```

---

## 5. Laundry Item Pricing Logic

### 5.1 Item Price Distribution

**Business Rule:** When `final_price` differs from sum of (item price × quantity), apply adjustment to ensure total matches.

**Formula:**

```python
total_price = sum(item['price'] * item['quantity'] for item in items)

if final_price == total_price:
    # No adjustment needed
    for item in items:
        item['item_price'] = item['price'] * item['quantity']

elif final_price > total_price:
    # Extra charge - add to first item
    extra = final_price - total_price
    for j, item in enumerate(items):
        if j == 0:
            item['item_price'] = item['price'] * item['quantity'] + extra
        else:
            item['item_price'] = item['price'] * item['quantity']

elif total_price > final_price:
    # Discount - subtract from items sequentially
    cut = total_price - final_price
    for item in items:
        item_price = item['price'] * item['quantity']
        if item_price > cut:
            item_price -= cut
            cut = 0
        else:
            cut -= item_price
            item_price = 0
        item['item_price'] = item_price
```

**Code Location:**
- `be-kharisma-abadi/controller/laundry_transaction_controller.py:26-56` (helper function)
- `be-kharisma-abadi/controller/laundry_transaction_controller.py:91-114` (list endpoint)
- `be-kharisma-abadi/controller/laundry_transaction_controller.py:178-201` (carpet list)

**Scenarios:**

| Scenario | Item Prices | final_price | Adjustment | Result |
|----------|-------------|-------------|------------|---------|
| **Match** | [10000, 20000] | 30,000 | None | [10000, 20000] |
| **Extra Charge** | [10000, 20000] | 35,000 | +5,000 to item[0] | [15000, 20000] |
| **Discount** | [10000, 20000] | 25,000 | -5,000 from item[0] | [5000, 20000] |
| **Large Discount** | [10000, 20000] | 15,000 | -10,000 (item[0]), -5,000 (item[1]) | [0, 15000] |

**Important Notes:**
- ⚠️ **Extra charge** always added to **first item**
- ⚠️ **Discount** applied sequentially (first item first, then second, etc.)
- 🔴 **ISSUE:** No business justification for why first item gets extra charge
- ⚠️ This allows cashier to adjust final price without changing item prices

---

## 6. Transaction Aggregations

### 6.1 Total Income Calculation

**Business Rule:** Sum gross income and net income across all services.

**Formula:**

```python
total_gross = carwash_gross + laundry_gross + carpet_gross + water_gross
total_net = carwash_net + laundry_net + carpet_net + water_net
```

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:94-101`

**Important Notes:**
- ✅ Aggregates across all service types
- ✅ Provides both gross and net totals
- ⚠️ **Only completed transactions** included (where `end_date IS NOT NULL`)

---

### 6.2 Transaction Count by Period

**Business Rule:** Count transactions by day, month, year, or all-time.

**Filters:**

| Period | SQL Filter |
|--------|------------|
| **Today** | `WHERE date = CURDATE()` |
| **This Month** | `WHERE date >= DATE_FORMAT(NOW(), '%Y-%m-01')` |
| **This Year** | `WHERE date >= DATE_FORMAT(NOW(), '%Y-01-01')` |
| **All Time** | No filter |

**Additional Filter:** Only completed transactions (`end_date IS NOT NULL`)

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:198-202` (comments)
- Database queries in model layer

**Important Notes:**
- ✅ Uses **database server date** (NOW(), CURDATE())
- ⚠️ Depends on database timezone configuration
- ⚠️ "Today" means server date, not user's timezone

---

## 7. Summary of Hardcoded Values

### 7.1 Income Split Percentages

| Service | Business Cut | Employee/Overhead Cut | Configurable? |
|---------|--------------|----------------------|---------------|
| Car Wash | Variable (per type) | Variable (per type) | ✅ Yes (in database) |
| Laundry | **60%** | **40%** | ❌ No (hardcoded) |
| Carpet | **60%** | **40%** | ❌ No (hardcoded) |
| Water Delivery | **60%** | **40%** | ❌ No (hardcoded) |

**Code Locations:**
- Laundry: `dashboard_controller.py:72, 380, 523`
- Carpet: `dashboard_controller.py:66`
- Water: `dashboard_controller.py:89, 395, 538`

**Recommendation:** 🔴 Move to database configuration like car wash

---

### 7.2 Chart Type Constants

```python
# Chart type parameter values
type = 1  # Total (all services)
type = 2  # Car wash only
type = 3  # Laundry only
type = 4  # Carpet only
type = 5  # Drinking water only
```

**Code Location:**
- `be-kharisma-abadi/controller/dashboard_controller.py:328`

**Recommendation:** ⚠️ Document in API, or use enum

---

### 7.3 Service Type Constants

```python
# Service type identifiers (in job-type union query)
type = 1  # Car wash
type = 2  # Laundry
type = 3  # Water delivery
```

**Code Location:**
- `be-kharisma-abadi/controller/type_controller.py:52-59, 76-83`

**Recommendation:** ⚠️ Use enum or constants file

---

## 8. Critical Business Rules

### 8.1 Transaction Completion Rule

**Rule:** A transaction is only included in income calculations if it has been marked as completed.

**Implementation:**
```python
if transaction['end_date'] is not None:
    # Include in income calculation
else:
    # Skip (pending transaction)
```

**Impact:**
- Pending transactions do NOT appear in income reports
- Completion date (`end_date`) acts as a status field
- **No explicit status field** exists

**Code Location:** Throughout dashboard controller (lines 21, 51, 83, 340, 377, 392)

**Recommendation:** 🔴 Consider adding explicit `status` enum field instead of relying on NULL date

---

### 8.2 Service Differentiation Rule (Laundry vs Carpet)

**Rule:** Laundry and carpet transactions are stored in the same table (`laundry_transactions`) and differentiated by item units.

**Implementation:**
```python
is_carpet = False
for item in transaction['items']:
    if item['unit'].lower() in ['m', 'm2']:
        is_carpet = True
        break
```

**Units:**
- **Laundry:** "pcs", "kg", "lusin", etc.
- **Carpet:** "m", "m2" (square meters)

**Code Location:**
- `dashboard_controller.py:55-57, 370-372`
- `laundry_transaction_controller.py:138-140`

**Impact:**
- ⚠️ A transaction can be marked as carpet if **any** item has unit "m" or "m2"
- ⚠️ Mixed transactions (carpet + laundry items) will be classified as carpet
- ⚠️ Case-insensitive matching (lowercase conversion)

**Recommendation:** 🔴 Consider separate tables or explicit `service_category` field

---

### 8.3 Pagination Limits

**Rule:** Pagination has maximum bounds to prevent excessive data loading.

**Limits:**
```python
if per_page < 1 or per_page > 100:
    per_page = 20  # Default to 20 if out of bounds
```

**Default:**
- Default `per_page` = 20
- Maximum `per_page` = 100
- Minimum `page` = 1

**Code Location:**
- `carwash_transaction_controller.py:25-26`
- `employee_controller.py:25-26`
- Similar pattern across all controllers

**Recommendation:** ✅ Good practice, prevents abuse

---

## 9. Calculation Accuracy Issues

### 9.1 Floor Division in Employee Income

**Issue:** Using floor division (`//`) loses fractional Rupiah.

**Example:**
```python
cut_amount = 50,000
total_employees = 3
per_employee = cut_amount // total_employees  # = 16,666
# Lost: 2 Rupiah (50,000 - 16,666 * 3 = 2)
```

**Impact:**
- Small amounts are lost in division
- Accumulates over many transactions
- Business loses micro amounts

**Recommendation:** 🟡 Use precise division and round, or track remainders

---

### 9.2 Float Precision in Income Calculations

**Issue:** Using `float()` conversion may introduce precision errors.

**Example:**
```python
net_income = float(final_price) * 0.6
```

**Impact:**
- Potential rounding errors in large sums
- May cause small discrepancies in reports

**Recommendation:** 🟡 Use `Decimal` type for financial calculations

---

## 10. Recommendations

### High Priority

1. **🔴 Make Laundry/Carpet/Water Income Splits Configurable**
   - Move 60%/40% split to database (like car wash)
   - Allow per-service-type configuration
   - Add UI for changing percentages

2. **🔴 Add Explicit Transaction Status Field**
   - Replace `end_date IS NULL` check with `status` enum
   - Values: PENDING, COMPLETED, CANCELLED
   - More explicit and maintainable

3. **🔴 Separate Laundry and Carpet Tables**
   - Or add `service_category` field
   - Prevents ambiguity with mixed transactions
   - Clearer data model

### Medium Priority

4. **🟡 Use Decimal for Financial Calculations**
   - Replace float with Decimal type
   - Prevents precision errors
   - Standard practice for money

5. **🟡 Fix Floor Division Issue**
   - Use precise division with rounding
   - Or distribute remainder to first employee
   - Document rounding policy

6. **🟡 Document Item Price Adjustment Logic**
   - Why does first item get extra charge?
   - Create business rule document
   - Consider UI to show adjustment

### Low Priority

7. **⚠️ Create Constants/Enums**
   - Chart types (1-5)
   - Service types (1-3)
   - Centralize in config file

8. **⚠️ Add Unit Tests for Calculations**
   - Test all formula variations
   - Test edge cases (division by zero, negative values)
   - Ensure precision

---

## Conclusion

The current system has **well-defined income calculations** for car wash (configurable) but **hardcoded percentages** for laundry, carpet, and water delivery. The biggest risk for rebuild is losing these hardcoded formulas since they're not in database or configuration.

**Critical Preservation:**
- Car wash: `cut_type` and `cut_amount` logic
- Laundry/Carpet/Water: **60% business, 40% employees** (hardcoded)
- Employee distribution: Division by employee count
- Item price adjustment: First item gets extras/discounts
- Completion rule: `end_date IS NOT NULL`

**Must Document in New System:**
- All percentage splits (especially the hardcoded 60%/40%)
- Employee income division algorithm
- Transaction completion logic
- Service differentiation rules

---

**Last Updated:** October 22, 2025
**Next Review:** Before rebuild implementation begins
