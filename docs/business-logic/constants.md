# Business Constants

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** Catalog of all business constants, hardcoded values, and configuration parameters

---

## Overview

This document catalogs all business constants found in the Kharisma Abadi system, including hardcoded values, configuration parameters, and magic numbers that should potentially be made configurable.

---

## 1. Income Split Constants (HARDCODED - HIGH PRIORITY)

### Laundry Service Income Split

**Constant:** `LAUNDRY_BUSINESS_PERCENTAGE`
- **Value:** 60% (0.6)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:66`
- **Usage:** Business income = final_price × 0.6
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** LA-INC-001

**Constant:** `LAUNDRY_EMPLOYEE_PERCENTAGE`
- **Value:** 40% (0.4)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:66`
- **Usage:** Employee income = final_price × 0.4
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** LA-INC-001

---

### Carpet Service Income Split

**Constant:** `CARPET_BUSINESS_PERCENTAGE`
- **Value:** 60% (0.6)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:72`
- **Usage:** Business income = final_price × 0.6
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** CA-INC-001

**Constant:** `CARPET_EMPLOYEE_PERCENTAGE`
- **Value:** 40% (0.4)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:72`
- **Usage:** Employee income = final_price × 0.4
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** CA-INC-001

---

### Water Delivery Service Income Split

**Constant:** `WATER_BUSINESS_PERCENTAGE`
- **Value:** 60% (0.6)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:89`
- **Usage:** Business income = final_price × 0.6
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** WA-INC-001

**Constant:** `WATER_EMPLOYEE_PERCENTAGE`
- **Value:** 40% (0.4)
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:89`
- **Usage:** Employee income = final_price × 0.4
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** HIGH
- **Rule ID:** WA-INC-001

---

## 2. Pagination Constants

### Maximum Page Size

**Constant:** `MAX_PER_PAGE`
- **Value:** 100
- **Location:** Multiple controllers (carwash, laundry, water, employee)
- **Usage:** `per_page = min(100, ...)`
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** MEDIUM
- **Rule ID:** SY-CONST-001

**Example Locations:**
- `be-kharisma-abadi/controller/carwash_transaction_controller.py:25`
- `be-kharisma-abadi/controller/laundry_transaction_controller.py:25`
- `be-kharisma-abadi/controller/drinking_water_transaction_controller.py:25`
- `be-kharisma-abadi/controller/employee_controller.py:25`

---

### Default Page Size

**Constant:** `DEFAULT_PER_PAGE`
- **Value:** 20
- **Location:** Multiple controllers
- **Usage:** `per_page = int(request.args.get('per_page', 20))`
- **Status:** ⚠️ HARDCODED - Should be configurable
- **Priority:** LOW
- **Rule ID:** SY-CONST-001

---

### Minimum Page Number

**Constant:** `MIN_PAGE`
- **Value:** 1
- **Location:** Multiple controllers
- **Usage:** `page = max(1, ...)`
- **Status:** ✅ Reasonable default
- **Priority:** LOW

---

## 3. Car Wash Cut Type Constants

### Cut Type: Fixed Amount

**Constant:** `CUT_TYPE_FIXED`
- **Value:** 1
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:24-27`
- **Usage:** Identifies fixed amount employee cut
- **Status:** ✅ Stored in database (carwash_types.cut_type)
- **Priority:** LOW (already configurable)
- **Rule ID:** CW-INC-001

---

### Cut Type: Percentage

**Constant:** `CUT_TYPE_PERCENTAGE`
- **Value:** 2
- **Location:** `be-kharisma-abadi/controller/dashboard_controller.py:24-27`
- **Usage:** Identifies percentage-based employee cut
- **Status:** ✅ Stored in database (carwash_types.cut_type)
- **Priority:** LOW (already configurable)
- **Rule ID:** CW-INC-001

---

## 4. Service Type Unit Constants

### Carpet Unit Types

**Constant:** `CARPET_UNIT_METER`
- **Value:** 'm'
- **Location:** `be-kharisma-abadi/controller/laundry_transaction_controller.py:138`
- **Usage:** Classify service as carpet if any item has this unit
- **Status:** ⚠️ HARDCODED - Should be in enum or config
- **Priority:** MEDIUM
- **Rule ID:** LA-WF-001

**Constant:** `CARPET_UNIT_METER_SQUARED`
- **Value:** 'm2'
- **Location:** `be-kharisma-abadi/controller/laundry_transaction_controller.py:138`
- **Usage:** Classify service as carpet if any item has this unit
- **Status:** ⚠️ HARDCODED - Should be in enum or config
- **Priority:** MEDIUM
- **Rule ID:** LA-WF-001

---

### Laundry Unit Types (Implicit)

**Constant:** `LAUNDRY_UNIT_KILOGRAM`
- **Value:** 'kg' (assumed, not explicitly in code)
- **Usage:** Common laundry unit
- **Status:** Not enforced in code
- **Priority:** LOW

**Constant:** `LAUNDRY_UNIT_PIECES`
- **Value:** 'pcs' (assumed, not explicitly in code)
- **Usage:** Piece-based laundry pricing
- **Status:** Not enforced in code
- **Priority:** LOW

---

## 5. Database Constants

### Table Names

**Constant:** `TABLE_EMPLOYEES`
- **Value:** 'employees'
- **Usage:** Employee table name

**Constant:** `TABLE_CARWASH_TYPES`
- **Value:** 'carwash_types'
- **Usage:** Car wash service types table

**Constant:** `TABLE_CARWASH_TRANSACTIONS`
- **Value:** 'carwash_transactions'
- **Usage:** Car wash transactions table

**Constant:** `TABLE_CARWASH_EMPLOYEES`
- **Value:** 'carwash_employees'
- **Usage:** Car wash employee assignments table

**Constant:** `TABLE_LAUNDRY_TYPES`
- **Value:** 'laundry_types'
- **Usage:** Laundry/carpet types table

**Constant:** `TABLE_LAUNDRY_TRANSACTIONS`
- **Value:** 'laundry_transactions'
- **Usage:** Laundry/carpet transactions table

**Constant:** `TABLE_LAUNDRY_ITEMS`
- **Value:** 'laundry_items'
- **Usage:** Laundry items table

**Constant:** `TABLE_DRINKING_WATER_CUSTOMERS`
- **Value:** 'drinking_water_customers'
- **Usage:** Water delivery customers table

**Constant:** `TABLE_DRINKING_WATER_TYPES`
- **Value:** 'drinking_water_types'
- **Usage:** Water product types table

**Constant:** `TABLE_DRINKING_WATER_TRANSACTIONS`
- **Value:** 'drinking_water_transactions'
- **Usage:** Water delivery transactions table

**Status:** ✅ Standard database naming
**Priority:** LOW (no change needed)

---

## 6. HTTP Status Code Constants

### Success Codes

**Constant:** `HTTP_OK`
- **Value:** 200
- **Usage:** Successful GET/PUT requests

**Constant:** `HTTP_CREATED`
- **Value:** 201
- **Usage:** Successful POST requests

---

### Client Error Codes

**Constant:** `HTTP_BAD_REQUEST`
- **Value:** 400
- **Usage:** Validation errors

**Constant:** `HTTP_NOT_FOUND`
- **Value:** 404
- **Usage:** Resource not found

---

### Server Error Codes

**Constant:** `HTTP_INTERNAL_SERVER_ERROR`
- **Value:** 500
- **Usage:** Server errors

**Status:** ✅ Standard HTTP codes
**Priority:** LOW (no change needed)

---

## 7. Date/Time Format Constants

### Database Date Format

**Constant:** `DATE_FORMAT`
- **Value:** 'YYYY-MM-DD' (MySQL DATE)
- **Usage:** Car wash and water delivery end_date
- **Example:** '2025-10-22'

**Constant:** `DATETIME_FORMAT`
- **Value:** 'YYYY-MM-DD HH:MM:SS' (MySQL DATETIME)
- **Usage:** Laundry/carpet end_date, created_at, updated_at
- **Example:** '2025-10-22 14:30:00'

**Status:** ✅ Standard MySQL formats
**Priority:** LOW (no change needed)

---

## 8. Currency Constants

### Currency Unit

**Constant:** `CURRENCY`
- **Value:** 'Rupiah' (IDR)
- **Usage:** All prices stored as integers (minor units)
- **Note:** No decimal places (prices in whole Rupiah)

**Status:** ✅ Implicit (Indonesian currency)
**Priority:** LOW

---

### Price Precision

**Constant:** `PRICE_PRECISION`
- **Value:** 0 decimal places
- **Usage:** All prices stored as BIGINT
- **Note:** No fractional Rupiah

**Status:** ✅ Reasonable for Rupiah
**Priority:** LOW

---

## 9. Minimum Value Constants

### Minimum Page Number

**Constant:** `MIN_PAGE`
- **Value:** 1
- **Usage:** Pagination validation

---

### Minimum Per-Page

**Constant:** `MIN_PER_PAGE`
- **Value:** 1
- **Usage:** Pagination validation

---

### Minimum Quantity

**Constant:** `MIN_QUANTITY`
- **Value:** 1 (implicit, validation: quantity > 0)
- **Usage:** Laundry items, water delivery
- **Rule ID:** LA-VAL-004, WA-VAL-004

**Status:** ⚠️ Not enforced consistently
**Priority:** MEDIUM

---

### Minimum Price

**Constant:** `MIN_PRICE`
- **Value:** 0
- **Usage:** Prices can be 0 (free service allowed)
- **Rule ID:** LA-VAL-005

**Status:** ✅ Allows free services
**Priority:** LOW

---

## 10. Magic Numbers in Code

### Floor Division (Employee Income)

**Location:** `be-kharisma-abadi/controller/carwash_transaction_controller.py:88-91`

**Magic Operation:** `total_cut // num_employees`
- **Issue:** Uses floor division, loses remainder
- **Impact:** Micro-losses in employee income
- **Rule ID:** CW-INC-002

**Example:**
```python
# 50,000 Rupiah total cut, 3 employees
per_employee = 50000 // 3  # = 16,666
total_distributed = 16666 * 3  # = 49,998
loss = 2  # Rupiah lost
```

**Status:** ⚠️ ISSUE - Should use remainder distribution
**Priority:** MEDIUM

---

### Income Percentage Calculations

**Location:** Dashboard controller (multiple lines)

**Magic Numbers:**
- `0.6` (60% business income)
- `0.4` (40% employee income)

**Issue:** Direct float multiplication
**Impact:** Potential precision loss for very large amounts

**Status:** ⚠️ HARDCODED - Should be configurable
**Priority:** HIGH

---

## 11. Configurable vs Hardcoded Summary

### ✅ Already Configurable (Database-Driven)

| Constant | Stored In | Status |
|----------|-----------|--------|
| Car wash service prices | carwash_types.price | ✅ Configurable |
| Car wash employee cut | carwash_types.cut_type, cut_amount | ✅ Configurable |
| Laundry/carpet item prices | laundry_types.price | ✅ Configurable |
| Water delivery prices | drinking_water_types.price | ✅ Configurable |

---

### ⚠️ HARDCODED (Should Be Configurable)

| Constant | Value | Location | Priority |
|----------|-------|----------|----------|
| Laundry business% | 60% | dashboard_controller.py:66 | **HIGH** |
| Laundry employee% | 40% | dashboard_controller.py:66 | **HIGH** |
| Carpet business% | 60% | dashboard_controller.py:72 | **HIGH** |
| Carpet employee% | 40% | dashboard_controller.py:72 | **HIGH** |
| Water business% | 60% | dashboard_controller.py:89 | **HIGH** |
| Water employee% | 40% | dashboard_controller.py:89 | **HIGH** |
| Max per_page | 100 | Multiple controllers | MEDIUM |
| Default per_page | 20 | Multiple controllers | LOW |
| Carpet units | 'm', 'm2' | laundry_transaction_controller.py:138 | MEDIUM |

---

## 12. Recommended Configuration Table

### Proposed: income_configuration Table

**Schema:**
```sql
CREATE TABLE income_configuration (
  income_config_id INT AUTO_INCREMENT PRIMARY KEY,
  service_type ENUM('car_wash', 'laundry', 'carpet', 'water_delivery') NOT NULL UNIQUE,
  business_percentage DECIMAL(5,2) NOT NULL,  -- e.g., 60.00
  employee_percentage DECIMAL(5,2) NOT NULL,  -- e.g., 40.00
  effective_date DATE NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Example Data:**
```sql
INSERT INTO income_configuration (service_type, business_percentage, employee_percentage, effective_date) VALUES
('laundry', 60.00, 40.00, '2022-01-01'),
('carpet', 60.00, 40.00, '2022-01-01'),
('water_delivery', 60.00, 40.00, '2022-01-01');
```

**Benefits:**
- Make income splits configurable without code deployment
- Track historical changes (effective_date)
- Consistent with car wash service pattern

---

### Proposed: system_configuration Table

**Schema:**
```sql
CREATE TABLE system_configuration (
  config_key VARCHAR(50) PRIMARY KEY,
  config_value VARCHAR(255) NOT NULL,
  data_type ENUM('int', 'float', 'string', 'boolean') NOT NULL,
  description TEXT,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Example Data:**
```sql
INSERT INTO system_configuration (config_key, config_value, data_type, description) VALUES
('pagination_max_per_page', '100', 'int', 'Maximum items per page'),
('pagination_default_per_page', '20', 'int', 'Default items per page'),
('carpet_unit_types', 'm,m2', 'string', 'Units that classify as carpet (comma-separated)');
```

**Benefits:**
- Single source of truth for system constants
- Easy to modify via admin interface
- Type-safe configuration

---

## 13. Constants by Priority

### Critical (HIGH Priority - Hardcoded Income Splits)

1. **Laundry business%** = 60% (HARDCODED)
2. **Laundry employee%** = 40% (HARDCODED)
3. **Carpet business%** = 60% (HARDCODED)
4. **Carpet employee%** = 40% (HARDCODED)
5. **Water business%** = 60% (HARDCODED)
6. **Water employee%** = 40% (HARDCODED)

**Impact:** Cannot change business rules without code deployment
**Recommendation:** Create `income_configuration` table

---

### Important (MEDIUM Priority - Should Be Configurable)

7. **Max per_page** = 100
8. **Carpet unit types** = 'm', 'm2'
9. **Minimum quantity** = 1 (not consistently enforced)
10. **Floor division** (employee income) - loses remainder

**Impact:** Limited flexibility, potential data quality issues
**Recommendation:** Add to `system_configuration` table

---

### Nice to Have (LOW Priority - Acceptable Defaults)

11. **Default per_page** = 20
12. **Min page** = 1
13. **Cut type fixed** = 1
14. **Cut type percentage** = 2

**Impact:** Minimal
**Recommendation:** Leave as defaults or add to config for completeness

---

## Conclusion

**Total Constants Identified:** 50+
- **Critical (hardcoded):** 6 (income splits)
- **Important (should configure):** 4
- **Acceptable defaults:** 40+

**For Rebuild:**
- ✅ Create `income_configuration` table for service-specific income splits
- ✅ Create `system_configuration` table for global constants
- ✅ Move all hardcoded percentages to database
- ✅ Use enums for unit types
- ⚠️ Fix floor division issue (remainder distribution)

---

**Last Updated:** October 22, 2025
