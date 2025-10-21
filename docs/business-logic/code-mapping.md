# Code-to-Business Mapping

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** Map business rules to exact code locations for traceability

---

## Overview

This document maps every business rule to its implementation location in the codebase, enabling quick navigation and impact analysis.

---

## Business Rules to Code Mapping

| Rule ID | Rule Name | File Location | Function/Method | Line(s) | Category |
|---------|-----------|---------------|-----------------|---------|----------|
| **CW-INC-001** | Variable Employee Cut | dashboard_controller.py | calculate_carwash_income | 24-27 | Car Wash Income |
| **CW-INC-002** | Multi-Employee Division | carwash_transaction_controller.py | list_transactions | 88-91 | Car Wash Income |
| **CW-VAL-001** | Prevent Duplicate Assignments | Production database schema | UNIQUE constraint | - | Car Wash Validation |
| **LA-INC-001** | Laundry 60/40 Split | dashboard_controller.py | calculate_income | 66 | Laundry Income |
| **LA-WF-001** | Service Differentiation | laundry_transaction_controller.py | list_transactions | 138-140 | Laundry Workflow |
| **LA-CAL-001** | Item Price Distribution | laundry_transaction_controller.py | adjust_item_prices (helper) | 26-56 | Laundry Calculation |
| **LA-VAL-001** | Required Transaction Fields | laundry_transaction_controller.py | create_transaction | Multiple | Laundry Validation |
| **CA-INC-001** | Carpet 60/40 Split | dashboard_controller.py | calculate_income | 72 | Carpet Income |
| **WA-INC-001** | Water 60/40 Split | dashboard_controller.py | calculate_income | 89 | Water Income |
| **WA-VAL-001** | Optional Customer Association | drinking_water_transaction_controller.py | create_transaction | Multiple | Water Validation |
| **EM-INC-001** | Employee Income Aggregation | employee_controller.py | get_day_income, get_month_income | 92-170 | Employee Income |
| **EM-VAL-001** | Name/Phone Validation | employee_controller.py | create/update_employee | Multiple | Employee Validation |
| **TX-WF-001** | Transaction Completion | All transaction controllers | set_end_date | Multiple | Transaction Workflow |
| **TX-VAL-001** | Date Range Validation | All dashboard functions | filter by date_range | Multiple | Transaction Validation |
| **SY-VAL-001** | Pagination Validation | All list controllers | list_* functions | ~25 | System Validation |
| **SY-VAL-002** | Required Field Validation | All transaction controllers | create/update functions | Multiple | System Validation |
| **SY-VAL-003** | Name Uniqueness | Database schema | UNIQUE constraints | - | System Validation |
| **SY-CONST-001** | Pagination Limits | All list controllers | list_* functions | ~25-26 | System Constants |

---

## Detailed Code Locations

### Car Wash Service

**CW-INC-001: Variable Employee Cut**
```
File: be-kharisma-abadi/controller/dashboard_controller.py
Function: (dashboard income calculation)
Lines: 24-27

Code snippet:
if carwash_type['cut_type'] == 1:
    employee_cut = carwash_type['cut_amount']
elif carwash_type['cut_type'] == 2:
    employee_cut = price * (carwash_type['cut_amount'] / 100)
```

**CW-INC-002: Multi-Employee Income Division**
```
File: be-kharisma-abadi/controller/carwash_transaction_controller.py
Function: list_carwash_transactions
Lines: 88-91

Code snippet:
num_employees = len(employees)
if num_employees > 0:
    per_employee_income = total_employee_cut // num_employees
```

**CW-VAL-001: Prevent Duplicate Employee Assignments**
```
File: Production database schema
Table: carwash_employees
Constraint: UNIQUE KEY unique_transaction_employee (carwash_transaction_id, employee_id)
```

---

### Laundry/Carpet Service

**LA-INC-001: Laundry 60/40 Split**
```
File: be-kharisma-abadi/controller/dashboard_controller.py
Function: (dashboard income calculation)
Line: 66

Code snippet:
net_income = price * 0.6
```

**CA-INC-001: Carpet 60/40 Split**
```
File: be-kharisma-abadi/controller/dashboard_controller.py
Function: (dashboard income calculation)
Line: 72

Code snippet:
net_income = price * 0.6
```

**LA-WF-001: Service Type Differentiation**
```
File: be-kharisma-abadi/controller/laundry_transaction_controller.py
Function: list_laundry_transactions
Lines: 138-140

Code snippet:
is_carpet = any(item['unit'] == 'm' or item['unit'] == 'm2' for item in items)
service_type = 'Carpet' if is_carpet else 'Laundry'
```

**LA-CAL-001: Item Price Distribution**
```
File: be-kharisma-abadi/controller/laundry_transaction_controller.py
Function: adjust_item_prices (helper function)
Lines: 26-56

Code logic:
1. Calculate total_price = sum(item['price'] * item['quantity'])
2. Compare with final_price
3. If final_price > total_price: Add extra to first item
4. If final_price < total_price: Subtract sequentially from items
```

---

### Water Delivery Service

**WA-INC-001: Water 60/40 Split**
```
File: be-kharisma-abadi/controller/dashboard_controller.py
Function: (dashboard income calculation)
Line: 89

Code snippet:
net_income = price * 0.6
```

**WA-VAL-001: Optional Customer Association**
```
File: be-kharisma-abadi/controller/drinking_water_transaction_controller.py
Function: create_drinking_water_transaction
Lines: Multiple

Logic: drinking_water_customer_id can be NULL (walk-in) or reference customer ID
```

---

### Employee Management

**EM-INC-001: Employee Income Aggregation**
```
File: be-kharisma-abadi/controller/employee_controller.py

Functions:
- get_employee_day_income (lines 92-103)
- get_employee_month_income (lines 106-119)
- get_employee_income_by_date_range (lines 145-170)

All aggregate car wash employee income by time period.
```

**EM-VAL-001: Name/Phone Validation**
```
File: be-kharisma-abadi/controller/employee_controller.py
Functions: create_employee, update_employee

Database: UNIQUE KEY name (name) on employees table
```

---

### Transaction Management

**TX-WF-001: Transaction Completion via end_date**
```
Files: All transaction controllers

Endpoints:
- PUT /api/carwash-transaction/end-date/{id}/
- PUT /api/laundry-transaction/end-date/{id}/
- PUT /api/drinking-water-transaction/end-date/{id}/

Logic: SET end_date = NOW() WHERE id = {id}
```

**TX-VAL-001: Date Range Validation**
```
Files: All dashboard and report functions

Logic: Validate start_date <= end_date for date range filters
```

---

### System-Wide Rules

**SY-VAL-001: Pagination Validation**
```
Files: All list controllers
Lines: ~25-26 in each controller

Code pattern:
page = max(1, int(request.args.get('page', 1)))
per_page = min(100, max(1, int(request.args.get('per_page', 20))))
```

**SY-VAL-002: Required Field Validation**
```
Files: All transaction controllers
Functions: create_* and update_* functions

Pattern:
if not data.get('required_field'):
    return jsonify({'error': 'Field is required'}), 400
```

**SY-VAL-003: Name Uniqueness**
```
File: Database schema

Tables with UNIQUE constraints:
- employees.name
- carwash_types.name (assumed)
- laundry_types.name (assumed)
- drinking_water_types.name (assumed)
```

**SY-CONST-001: Pagination Limits**
```
Files: All list controllers
Lines: ~25-26

Constants:
- MAX_PER_PAGE = 100
- DEFAULT_PER_PAGE = 20
```

---

## Reverse Mapping: Code File to Business Rules

### dashboard_controller.py

**Rules Implemented:**
- CW-INC-001 (lines 24-27): Variable employee cut calculation
- LA-INC-001 (line 66): Laundry 60/40 split
- CA-INC-001 (line 72): Carpet 60/40 split
- WA-INC-001 (line 89): Water 60/40 split

**Functions:**
- Car wash income calculation (chart, total)
- Laundry income calculation (chart, total)
- Carpet income calculation (chart, total)
- Water income calculation (chart, total)

---

### carwash_transaction_controller.py

**Rules Implemented:**
- CW-INC-002 (lines 88-91): Multi-employee income division
- TX-WF-001: Transaction completion (end_date endpoint)
- SY-VAL-001 (line 25-26): Pagination validation

**Functions:**
- list_carwash_transactions (GET /api/carwash-transaction/)
- create_carwash_transaction (POST /api/carwash-transaction/)
- update_carwash_transaction (PUT /api/carwash-transaction/{id}/)
- set_end_date (PUT /api/carwash-transaction/end-date/{id}/)
- delete_carwash_transaction (DELETE /api/carwash-transaction/{id}/)

---

### laundry_transaction_controller.py

**Rules Implemented:**
- LA-INC-001: Laundry income (via dashboard controller)
- LA-WF-001 (lines 138-140): Service type differentiation
- LA-CAL-001 (lines 26-56): Item price distribution
- TX-WF-001: Transaction completion
- SY-VAL-001 (line 25-26): Pagination validation

**Functions:**
- adjust_item_prices (helper, lines 26-56)
- list_laundry_transactions (GET /api/laundry-transaction/)
- create_laundry_transaction (POST /api/laundry-transaction/)
- update_laundry_transaction (PUT /api/laundry-transaction/{id}/)
- set_end_date (PUT /api/laundry-transaction/end-date/{id}/)
- delete_laundry_transaction (DELETE /api/laundry-transaction/{id}/)

---

### drinking_water_transaction_controller.py

**Rules Implemented:**
- WA-INC-001: Water income (via dashboard controller)
- WA-VAL-001: Optional customer association
- TX-WF-001: Transaction completion
- SY-VAL-001 (line 25-26): Pagination validation

**Functions:**
- list_drinking_water_transactions (GET /api/drinking-water-transaction/)
- create_drinking_water_transaction (POST /api/drinking-water-transaction/)
- update_drinking_water_transaction (PUT /api/drinking-water-transaction/{id}/)
- set_end_date (PUT /api/drinking-water-transaction/end-date/{id}/)
- delete_drinking_water_transaction (DELETE /api/drinking-water-transaction/{id}/)

---

### employee_controller.py

**Rules Implemented:**
- EM-INC-001 (lines 92-170): Employee income aggregation
- EM-VAL-001: Name/phone validation
- SY-VAL-001 (line 25): Pagination validation

**Functions:**
- list_employees (GET /api/employee/)
- create_employee (POST /api/employee/)
- update_employee (PUT /api/employee/{id}/)
- delete_employee (DELETE /api/employee/{id}/)
- get_employee_day_income (GET /api/employee/day-income/{id}/)
- get_employee_month_income (GET /api/employee/month-income/{id}/)
- get_employee_year_income (GET /api/employee/year-income/{id}/)
- get_employee_income_all_time (GET /api/employee/all-time-income/{id}/)
- get_employee_income_by_date_range (GET /api/employee/income/{id}/)

---

## API Endpoint to Business Rule Mapping

| Endpoint | Method | Rules Applied | File | Function |
|----------|--------|---------------|------|----------|
| /api/carwash-transaction/ | GET | CW-INC-002, SY-VAL-001 | carwash_transaction_controller.py | list_carwash_transactions |
| /api/carwash-transaction/ | POST | SY-VAL-002 | carwash_transaction_controller.py | create_carwash_transaction |
| /api/carwash-transaction/{id}/ | PUT | SY-VAL-002 | carwash_transaction_controller.py | update_carwash_transaction |
| /api/carwash-transaction/end-date/{id}/ | PUT | TX-WF-001 | carwash_transaction_controller.py | set_end_date |
| /api/laundry-transaction/ | GET | LA-WF-001, LA-CAL-001, SY-VAL-001 | laundry_transaction_controller.py | list_laundry_transactions |
| /api/laundry-transaction/ | POST | LA-CAL-001, SY-VAL-002 | laundry_transaction_controller.py | create_laundry_transaction |
| /api/laundry-transaction/{id}/ | PUT | LA-CAL-001, SY-VAL-002 | laundry_transaction_controller.py | update_laundry_transaction |
| /api/laundry-transaction/end-date/{id}/ | PUT | TX-WF-001 | laundry_transaction_controller.py | set_end_date |
| /api/drinking-water-transaction/ | GET | WA-VAL-001, SY-VAL-001 | drinking_water_transaction_controller.py | list_drinking_water_transactions |
| /api/drinking-water-transaction/ | POST | WA-VAL-001, SY-VAL-002 | drinking_water_transaction_controller.py | create_drinking_water_transaction |
| /api/drinking-water-transaction/{id}/ | PUT | WA-VAL-001, SY-VAL-002 | drinking_water_transaction_controller.py | update_drinking_water_transaction |
| /api/drinking-water-transaction/end-date/{id}/ | PUT | TX-WF-001 | drinking_water_transaction_controller.py | set_end_date |
| /api/employee/ | GET | SY-VAL-001 | employee_controller.py | list_employees |
| /api/employee/ | POST | EM-VAL-001, SY-VAL-002 | employee_controller.py | create_employee |
| /api/employee/{id}/ | PUT | EM-VAL-001, SY-VAL-002 | employee_controller.py | update_employee |
| /api/employee/day-income/{id}/ | GET | EM-INC-001 | employee_controller.py | get_employee_day_income |
| /api/employee/month-income/{id}/ | GET | EM-INC-001 | employee_controller.py | get_employee_month_income |
| /api/employee/income/{id}/ | GET | EM-INC-001, TX-VAL-001 | employee_controller.py | get_employee_income_by_date_range |
| /api/dashboard/income/chart | GET | CW-INC-001, LA-INC-001, CA-INC-001, WA-INC-001 | dashboard_controller.py | get_income_chart |
| /api/dashboard/income/total | GET | CW-INC-001, LA-INC-001, CA-INC-001, WA-INC-001 | dashboard_controller.py | get_total_income |

---

## Database Schema to Business Rule Mapping

| Table | Field/Constraint | Rule ID | Rule Description |
|-------|------------------|---------|------------------|
| carwash_employees | UNIQUE (carwash_transaction_id, employee_id) | CW-VAL-001 | Prevent duplicate assignments |
| carwash_types | cut_type | CW-INC-001 | Variable employee cut |
| carwash_types | cut_amount | CW-INC-001 | Cut value (fixed or percentage) |
| carwash_transactions | end_date | TX-WF-001 | Transaction completion status |
| laundry_transactions | end_date | TX-WF-001 | Transaction completion status |
| laundry_items | unit | LA-WF-001 | Service type differentiation (m/m2 = carpet) |
| drinking_water_transactions | drinking_water_customer_id | WA-VAL-001 | Optional customer association (can be NULL) |
| drinking_water_transactions | end_date | TX-WF-001 | Transaction completion status |
| employees | name (UNIQUE) | EM-VAL-001, SY-VAL-003 | Name uniqueness |

---

## Quick Reference: Find Rule by ID

| Rule ID | Primary File | Primary Line(s) |
|---------|--------------|-----------------|
| CW-INC-001 | dashboard_controller.py | 24-27 |
| CW-INC-002 | carwash_transaction_controller.py | 88-91 |
| CW-VAL-001 | Production DB schema | - |
| LA-INC-001 | dashboard_controller.py | 66 |
| LA-WF-001 | laundry_transaction_controller.py | 138-140 |
| LA-CAL-001 | laundry_transaction_controller.py | 26-56 |
| CA-INC-001 | dashboard_controller.py | 72 |
| WA-INC-001 | dashboard_controller.py | 89 |
| WA-VAL-001 | drinking_water_transaction_controller.py | Multiple |
| EM-INC-001 | employee_controller.py | 92-170 |
| EM-VAL-001 | employee_controller.py | Multiple |
| TX-WF-001 | All transaction controllers | Multiple (set_end_date) |
| SY-VAL-001 | All list controllers | ~25-26 |
| SY-VAL-002 | All create/update controllers | Multiple |
| SY-VAL-003 | Database schema | UNIQUE constraints |
| SY-CONST-001 | All list controllers | ~25-26 |

---

## Conclusion

**Total Mappings:** 19 business rules → 50+ code locations
**Primary Files:** 5 controllers + 1 database schema
**Coverage:** All business rules have traceable implementation

**For Rebuild:**
- Use this mapping to locate all business logic
- Ensure no logic is missed during migration
- Validate that new implementation matches original intent

---

**Last Updated:** October 22, 2025
