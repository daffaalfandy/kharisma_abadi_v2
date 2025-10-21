# Decision Tables

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** Decision logic documentation for complex business rules in the Kharisma Abadi system

---

## Overview

This document contains decision tables for complex business logic where multiple conditions determine outcomes. Decision tables provide a clear, testable format for understanding business rules.

---

## 1. Service Type Classification Decision Table

### LA-WF-001: Laundry vs Carpet Classification

**Decision Logic:** Determine whether a transaction is classified as Laundry or Carpet based on item units

| Rule # | Condition: Has item with unit='m'? | Condition: Has item with unit='m2'? | Condition: All items unit='kg' or 'pcs'? | **Action: Service Type** | **Action: Income Rule** |
|--------|-------------------------------------|--------------------------------------|------------------------------------------|--------------------------|-------------------------|
| 1 | ✅ Yes | - | - | **Carpet** | CA-INC-001 (60/40) |
| 2 | ❌ No | ✅ Yes | - | **Carpet** | CA-INC-001 (60/40) |
| 3 | ❌ No | ❌ No | ✅ Yes | **Laundry** | LA-INC-001 (60/40) |
| 4 | ❌ No | ❌ No | ❌ No | **Laundry** (default) | LA-INC-001 (60/40) |

**Decision Priority:** Rules are evaluated in order. First match determines classification.

**Examples:**

| Items | Rule Applied | Service Type |
|-------|--------------|--------------|
| 1 kg laundry | Rule 3 | Laundry |
| 1 m2 carpet | Rule 2 | Carpet |
| 1 m carpet | Rule 1 | Carpet |
| 2 kg laundry + 1 m2 carpet | Rule 2 | Carpet (mixed → carpet) |
| 1 pcs item | Rule 3 | Laundry |

**Edge Cases:**
- Mixed transaction (kg + m2) → Classified as **Carpet**
- Empty items → Classified as **Laundry** (default)

---

## 2. Income Calculation Decision Table

### Income Distribution by Service Type

**Decision Logic:** Determine income split based on service type

| Rule # | Service Type | Condition: end_date IS NOT NULL? | **Action: Business Income** | **Action: Employee Income** | **Rule ID** |
|--------|--------------|----------------------------------|-----------------------------|-----------------------------|-------------|
| 1 | Car Wash | ✅ Yes | gross - employee_cut | employee_cut (variable) | CW-INC-001 |
| 2 | Car Wash | ❌ No | 0 | 0 | TX-WF-001 |
| 3 | Laundry | ✅ Yes | final_price × 0.6 | final_price × 0.4 | LA-INC-001 |
| 4 | Laundry | ❌ No | 0 | 0 | TX-WF-001 |
| 5 | Carpet | ✅ Yes | final_price × 0.6 | final_price × 0.4 | CA-INC-001 |
| 6 | Carpet | ❌ No | 0 | 0 | TX-WF-001 |
| 7 | Water Delivery | ✅ Yes | final_price × 0.6 | final_price × 0.4 | WA-INC-001 |
| 8 | Water Delivery | ❌ No | 0 | 0 | TX-WF-001 |

**Examples:**

| Service | end_date | final_price | Business Income | Employee Income |
|---------|----------|-------------|-----------------|-----------------|
| Car Wash | 2025-10-22 | 100,000 | 90,000 (if cut=10,000) | 10,000 |
| Car Wash | NULL | 100,000 | 0 | 0 |
| Laundry | 2025-10-22 | 100,000 | 60,000 | 40,000 |
| Laundry | NULL | 100,000 | 0 | 0 |
| Carpet | 2025-10-22 | 200,000 | 120,000 | 80,000 |
| Water | 2025-10-22 | 50,000 | 30,000 | 20,000 |

---

## 3. Car Wash Employee Cut Decision Table

### CW-INC-001: Employee Cut Calculation

**Decision Logic:** Calculate employee cut based on cut_type

| Rule # | cut_type | Condition: cut_amount exists? | **Formula** | **Example (price=100,000, cut_amount=10,000 or 20%)** |
|--------|----------|-------------------------------|-------------|-------------------------------------------------------|
| 1 | 1 (Fixed) | ✅ Yes | employee_cut = cut_amount | 10,000 |
| 2 | 1 (Fixed) | ❌ No | employee_cut = 0 | 0 |
| 3 | 2 (Percentage) | ✅ Yes | employee_cut = price × (cut_amount / 100) | 100,000 × 0.20 = 20,000 |
| 4 | 2 (Percentage) | ❌ No | employee_cut = 0 | 0 |
| 5 | Other | - | employee_cut = 0 (default) | 0 |

**Examples:**

| Service Type | cut_type | cut_amount | Price | Employee Cut |
|--------------|----------|------------|-------|--------------|
| Sedan Wash | 1 | 10,000 | 100,000 | 10,000 |
| SUV Wash | 2 | 30 | 200,000 | 60,000 (30%) |
| Motorcycle Wash | 1 | 5,000 | 50,000 | 5,000 |
| Unknown | NULL | NULL | 100,000 | 0 |

---

## 4. Employee Income Distribution Decision Table

### CW-INC-002: Per-Employee Income Calculation

**Decision Logic:** Distribute employee cut among assigned employees

| Rule # | Number of Employees | Total Employee Cut | **Formula** | **Per-Employee Income** |
|--------|---------------------|--------------------|--------------|-----------------------|
| 1 | 1 | 30,000 | 30,000 // 1 | 30,000 |
| 2 | 2 | 30,000 | 30,000 // 2 | 15,000 each |
| 3 | 3 | 50,000 | 50,000 // 3 | 16,666 each (2 Rp lost) |
| 4 | 0 | 30,000 | N/A | Error (no employees) |

**Floor Division Loss Examples:**

| Total Cut | Employees | Per-Employee (floor division) | Total Distributed | Loss |
|-----------|-----------|-------------------------------|-------------------|------|
| 50,000 | 3 | 16,666 | 49,998 | 2 |
| 100,000 | 3 | 33,333 | 99,999 | 1 |
| 10,000 | 3 | 3,333 | 9,999 | 1 |
| 10,000 | 7 | 1,428 | 9,996 | 4 |

**Recommendation:** Distribute remainder to first N employees to avoid loss

---

## 5. Laundry Item Price Distribution Decision Table

### LA-CAL-001: Item Price Adjustment

**Decision Logic:** Adjust item prices when final_price differs from sum of (item_price × quantity)

| Rule # | final_price vs total_price | Difference | **Action** | **Which Items Adjusted?** |
|--------|----------------------------|------------|------------|---------------------------|
| 1 | final > total | +5,000 | Add extra to first item | item[0] |
| 2 | final < total | -5,000 | Subtract sequentially | item[0], then item[1], etc. |
| 3 | final == total | 0 | No adjustment | None |

**Detailed Decision for Rule 2 (Discount):**

| Sub-Rule | Condition | **Action** |
|----------|-----------|------------|
| 2a | item[i].price >= remaining_cut | item[i].price -= remaining_cut, DONE |
| 2b | item[i].price < remaining_cut | item[i].price = 0, carry forward cut |

**Examples:**

**Example 1: Extra Charge (+5,000)**
```
Items: [10,000, 20,000]
Total: 30,000
Final: 35,000
Extra: +5,000

Result: [15,000, 20,000]  ← First item gets all extra
```

**Example 2: Small Discount (-5,000)**
```
Items: [10,000, 20,000]
Total: 30,000
Final: 25,000
Cut: -5,000

Step 1: item[0] = 10,000 - 5,000 = 5,000
Result: [5,000, 20,000]
```

**Example 3: Large Discount (-15,000)**
```
Items: [10,000, 20,000]
Total: 30,000
Final: 15,000
Cut: -15,000

Step 1: item[0] = 10,000 - 10,000 = 0 (zeroed), remaining = -5,000
Step 2: item[1] = 20,000 - 5,000 = 15,000
Result: [0, 15,000]
```

**Example 4: Massive Discount (-25,000)**
```
Items: [10,000, 20,000]
Total: 30,000
Final: 5,000
Cut: -25,000

Step 1: item[0] = 10,000 - 10,000 = 0 (zeroed), remaining = -15,000
Step 2: item[1] = 20,000 - 15,000 = 5,000
Result: [0, 5,000]
```

---

## 6. Water Delivery Customer Type Decision Table

### WA-VAL-001: Customer Association

**Decision Logic:** Determine customer information source

| Rule # | drinking_water_customer_id | customer_name (manual) | phone_number (manual) | **Action** | **Customer Source** |
|--------|----------------------------|------------------------|------------------------|------------|---------------------|
| 1 | 5 (exists) | NULL | NULL | Fetch from customers table | Registered customer |
| 2 | 5 (exists) | "John" | "08123" | Use manual override | Registered (manual override) |
| 3 | NULL | "John" | "08123" | Use manual values | Walk-in customer |
| 4 | NULL | NULL | NULL | Error | Invalid (missing info) |

**Examples:**

| Input | Output | Customer Type |
|-------|--------|---------------|
| customer_id=5 | Fetch customer #5 info | Registered |
| customer_id=NULL, name="John", phone="08123" | Use "John" / "08123" | Walk-in |
| customer_id=NULL, name=NULL, phone=NULL | ERROR | Invalid |

---

## 7. Pagination Decision Table

### SY-VAL-001: Pagination Bounds Validation

**Decision Logic:** Clamp pagination parameters to valid range

| Rule # | Input page | Input per_page | **Output page** | **Output per_page** | **Action** |
|--------|------------|----------------|-----------------|---------------------|------------|
| 1 | 1 | 20 | 1 | 20 | Use as-is (default) |
| 2 | 0 | 20 | 1 | 20 | Clamp page to 1 |
| 3 | -5 | 20 | 1 | 20 | Clamp page to 1 |
| 4 | 1 | 0 | 1 | 1 | Clamp per_page to 1 |
| 5 | 1 | 200 | 1 | 100 | Clamp per_page to 100 |
| 6 | 2 | 50 | 2 | 50 | Use as-is |
| 7 | NULL | NULL | 1 | 20 | Use defaults |

**Clamping Logic:**

| Parameter | Min | Max | Default |
|-----------|-----|-----|---------|
| page | 1 | ∞ | 1 |
| per_page | 1 | 100 | 20 |

---

## 8. Transaction Completion Decision Table

### TX-WF-001: Transaction Status

**Decision Logic:** Determine transaction status and income inclusion

| Rule # | end_date Value | **Status** | **Income Counted?** | **Can Modify?** |
|--------|----------------|------------|---------------------|-----------------|
| 1 | NULL | Pending | ❌ No | ✅ Yes |
| 2 | '2025-10-22' | Completed | ✅ Yes | ❌ No |
| 3 | '2025-10-22 14:30:00' | Completed | ✅ Yes | ❌ No |

**Universal Rule:** Applies to ALL services (car wash, laundry, carpet, water)

---

## 9. Date Range Validation Decision Table

### TX-VAL-001: Date Range Filter

**Decision Logic:** Validate date range parameters

| Rule # | start_date | end_date | Condition: start <= end | **Action** | **Result** |
|--------|------------|----------|-------------------------|------------|------------|
| 1 | 2025-01-01 | 2025-01-31 | ✅ Yes | Accept | Valid range |
| 2 | 2025-01-01 | 2025-01-01 | ✅ Yes | Accept | Single day (valid) |
| 3 | 2025-01-31 | 2025-01-01 | ❌ No | Reject | Error: "Start must be <= end" |
| 4 | NULL | 2025-01-31 | N/A | Accept | No start date (all time) |
| 5 | 2025-01-01 | NULL | N/A | Accept | No end date (until now) |
| 6 | NULL | NULL | N/A | Accept | No filter (all time) |

---

## 10. Employee Name Uniqueness Decision Table

### EM-VAL-001: Name Validation

**Decision Logic:** Validate employee name uniqueness

| Rule # | Name | Exists in DB? | Operation | **Action** | **Result** |
|--------|------|---------------|-----------|------------|------------|
| 1 | "Ahmad" | ❌ No | CREATE | Insert | Success |
| 2 | "Ahmad" | ✅ Yes | CREATE | Reject | Error: "Name exists" |
| 3 | "Budi" | ❌ No | UPDATE (id=5) | Update | Success |
| 4 | "Ahmad" | ✅ Yes (id=10) | UPDATE (id=5) | Reject | Error: "Name exists" |
| 5 | "Ahmad" | ✅ Yes (id=5) | UPDATE (id=5) | Update | Success (same record) |

**Validation Logic:**
```sql
-- CREATE: Name must not exist
SELECT * FROM employees WHERE name = 'Ahmad'
-- If found → Error

-- UPDATE: Name must not exist OR belong to current record
SELECT * FROM employees WHERE name = 'Ahmad' AND employee_id != 5
-- If found → Error
```

---

## 11. Complex Decision: Item Price Distribution (Detailed)

### LA-CAL-001: Complete Decision Logic

**Input:** `items[]`, `final_price`

**Step 1: Calculate total_price**
```
total_price = SUM(item.price × item.quantity) for all items
```

**Step 2: Compare final_price vs total_price**

| Comparison | Difference | Next Step |
|------------|------------|-----------|
| final > total | +extra | Go to Step 3a (Add Extra) |
| final < total | -cut | Go to Step 3b (Apply Discount) |
| final == total | 0 | Go to Step 3c (No Change) |

**Step 3a: Add Extra to First Item**

| Item Index | **Action** |
|------------|------------|
| 0 | item_price = (price × quantity) + extra |
| 1..N | item_price = price × quantity |

**Step 3b: Apply Discount Sequentially**

| Iteration | Remaining Cut | Item Price | **Action** |
|-----------|---------------|------------|------------|
| i=0 | -15,000 | 10,000 | item_price = 0, remaining = -5,000 |
| i=1 | -5,000 | 20,000 | item_price = 15,000, DONE |

**Step 3c: No Adjustment**

| Item Index | **Action** |
|------------|------------|
| All | item_price = price × quantity |

**Complete Decision Table:**

| final_price | total_price | Difference | Item 0 Action | Item 1+ Action |
|-------------|-------------|------------|---------------|----------------|
| 35,000 | 30,000 | +5,000 | Add 5,000 to item[0] | No change |
| 25,000 | 30,000 | -5,000 | Subtract up to 5,000 | Carry forward if needed |
| 30,000 | 30,000 | 0 | No change | No change |

---

## 12. Decision Table Summary

### Total Decision Tables

1. Service Type Classification (4 rules)
2. Income Calculation by Service (8 rules)
3. Car Wash Employee Cut (5 rules)
4. Employee Income Distribution (4 rules)
5. Laundry Item Price Distribution (3 rules + sub-rules)
6. Water Customer Association (4 rules)
7. Pagination Bounds (7 rules)
8. Transaction Completion (3 rules)
9. Date Range Validation (6 rules)
10. Employee Name Uniqueness (5 rules)
11. Item Price Distribution Detailed (3 main rules + iterations)

**Total Rules Documented:** 52+ decision rules

---

## 13. Testing with Decision Tables

### How to Use for Testing

Each decision table can be converted directly into test cases:

**Example: Service Type Classification**

```python
def test_service_classification():
    # Rule 1: Has item with unit='m'
    items = [{'unit': 'm', 'quantity': 1}]
    assert classify_service(items) == 'Carpet'

    # Rule 2: Has item with unit='m2'
    items = [{'unit': 'm2', 'quantity': 2}]
    assert classify_service(items) == 'Carpet'

    # Rule 3: All items kg or pcs
    items = [{'unit': 'kg', 'quantity': 3}]
    assert classify_service(items) == 'Laundry'

    # Rule 4: Mixed transaction
    items = [{'unit': 'kg', 'quantity': 1}, {'unit': 'm2', 'quantity': 1}]
    assert classify_service(items) == 'Carpet'
```

**Every rule in every decision table should have a corresponding test case.**

---

## Conclusion

**Decision Tables Created:** 12
**Total Decision Rules:** 52+
**Coverage:** All complex business logic documented

**For Rebuild:**
- Use decision tables directly for test case generation
- Implement decision logic exactly as specified
- Consider replacing hardcoded decisions with configuration tables

---

**Last Updated:** October 22, 2025
