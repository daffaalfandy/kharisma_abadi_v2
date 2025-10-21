# Validation Rules

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** Comprehensive catalog of all validation rules in the Kharisma Abadi system

---

## Overview

This document catalogs all validation rules extracted from the codebase, organized by domain and validation type.

---

## 1. Car Wash Service Validation Rules

### CW-VAL-001: Prevent Duplicate Employee Assignments

**Rule:** Cannot assign the same employee to the same car wash transaction twice

**Type:** Business constraint validation

**Implementation:**
- Database constraint: `UNIQUE KEY unique_transaction_employee (carwash_transaction_id, employee_id)`
- Location: Production database schema (added in production)

**Validation Logic:**
```sql
-- Database enforces this automatically
UNIQUE (carwash_transaction_id, employee_id)
```

**Error Handling:**
- Database returns duplicate key error
- Should be caught and returned as user-friendly message

**Test Cases:**

| Input | Expected Result |
|-------|----------------|
| Assign employee #1 to transaction #100 (first time) | ✅ Success |
| Assign employee #1 to transaction #100 (second time) | ❌ Error: "Employee already assigned" |
| Assign employee #2 to transaction #100 | ✅ Success |

**Edge Cases:**
- Same employee can be assigned to different transactions
- Different employees can be assigned to same transaction

---

### CW-VAL-002: Required Fields

**Rule:** Car wash transaction must have required fields

**Required Fields:**
- `date` (datetime) - Transaction date
- `carwash_type_id` (int) - Service type (FK to carwash_types)
- `final_price` (bigint) - Final price amount

**Optional Fields:**
- `phone_number` (varchar) - Customer phone
- `license_plate` (varchar) - Vehicle license plate
- `end_date` (date) - Completion date (NULL = pending)

**Implementation:**
- Database: `NOT NULL` constraints
- Application: Input validation in controllers

**Validation Logic:**
```python
# Required field validation
if not data.get('date'):
    return error('Date is required')
if not data.get('carwash_type_id'):
    return error('Service type is required')
if not data.get('final_price'):
    return error('Price is required')
```

**Error Messages:**
- "Date is required"
- "Service type is required"
- "Price is required"

---

### CW-VAL-003: Service Type Existence

**Rule:** carwash_type_id must reference existing service type

**Type:** Referential integrity

**Implementation:**
- Database: `FOREIGN KEY (carwash_type_id) REFERENCES carwash_types(carwash_type_id)`

**Validation:**
- Database enforces automatically
- Application should validate before insert

**Test Cases:**

| carwash_type_id | Expected Result |
|-----------------|----------------|
| 1 (exists) | ✅ Success |
| 999 (doesn't exist) | ❌ Error: Foreign key constraint |

---

### CW-VAL-004: Employee Existence

**Rule:** employee_id in carwash_employees must reference existing employee

**Type:** Referential integrity

**Implementation:**
- Database: `FOREIGN KEY (employee_id) REFERENCES employees(employee_id)`

**Validation:**
- Database enforces automatically
- Application should validate before insert

---

## 2. Laundry/Carpet Service Validation Rules

### LA-VAL-001: Required Transaction Fields

**Rule:** Laundry/carpet transaction must have required fields

**Required Fields:**
- `date` (datetime) - Transaction date
- `final_price` (bigint) - Final price

**Optional Fields:**
- `customer_name` (varchar)
- `phone_number` (varchar)
- `end_date` (datetime) - Completion date (NULL = pending)

**Implementation:**
- Database: `NOT NULL` constraints
- Application: Input validation

---

### LA-VAL-002: Required Item Fields

**Rule:** Each laundry item must have complete information

**Required Fields:**
- `laundry_transaction_id` (int) - Parent transaction
- `laundry_type_id` (int) - Item type
- `quantity` (int) - Item quantity
- `item_price` (bigint) - Calculated item price

**Implementation:**
```python
# Item validation
for item in items:
    if not item.get('laundry_type_id'):
        return error('Item type is required')
    if not item.get('quantity') or item['quantity'] <= 0:
        return error('Quantity must be greater than 0')
```

---

### LA-VAL-003: Laundry Type Existence

**Rule:** laundry_type_id must reference existing laundry type

**Type:** Referential integrity

**Implementation:**
- Database: `FOREIGN KEY (laundry_type_id) REFERENCES laundry_types(laundry_type_id)`

---

### LA-VAL-004: Positive Quantity

**Rule:** Item quantity must be greater than 0

**Type:** Business constraint

**Implementation:**
```python
if quantity <= 0:
    return error('Quantity must be greater than 0')
```

**Test Cases:**

| Quantity | Expected Result |
|----------|----------------|
| 0 | ❌ Error: "Quantity must be greater than 0" |
| -1 | ❌ Error: "Quantity must be greater than 0" |
| 1 | ✅ Success |
| 10 | ✅ Success |

---

### LA-VAL-005: Positive Price

**Rule:** final_price and item_price must be non-negative

**Type:** Business constraint

**Implementation:**
```python
if final_price < 0:
    return error('Price cannot be negative')
```

**Test Cases:**

| Price | Expected Result |
|-------|----------------|
| -1000 | ❌ Error: "Price cannot be negative" |
| 0 | ✅ Success (free service) |
| 50000 | ✅ Success |

---

## 3. Water Delivery Service Validation Rules

### WA-VAL-001: Optional Customer Association

**Rule:** drinking_water_customer_id is optional (can be NULL)

**Type:** Business rule

**Logic:**
- If customer is registered: Set `drinking_water_customer_id`
- If customer is walk-in: Set `drinking_water_customer_id = NULL` and fill `customer_name`, `phone_number` manually

**Implementation:**
```python
# Option 1: Registered customer
transaction = {
    'drinking_water_customer_id': 5,
    'customer_name': None,  # Fetched from customer record
    'phone_number': None,   # Fetched from customer record
}

# Option 2: Walk-in customer
transaction = {
    'drinking_water_customer_id': None,
    'customer_name': 'John Doe',
    'phone_number': '08123456789',
}
```

**Validation:**
- Either `drinking_water_customer_id` OR (`customer_name` AND `phone_number`) must be provided
- Cannot have both NULL

**Test Cases:**

| customer_id | customer_name | phone_number | Result |
|-------------|---------------|--------------|--------|
| 5 | NULL | NULL | ✅ Success (registered) |
| NULL | "John" | "08123" | ✅ Success (walk-in) |
| NULL | NULL | NULL | ❌ Error: "Customer info required" |
| 5 | "John" | "08123" | ✅ Success (manual override) |

---

### WA-VAL-002: Required Transaction Fields

**Rule:** Water delivery transaction must have required fields

**Required Fields:**
- `date` (datetime) - Order date
- `drinking_water_type_id` (int) - Product type
- `quantity` (int) - Number of gallons
- `final_price` (bigint) - Total price

**Optional Fields:**
- `drinking_water_customer_id` (int)
- `customer_name` (varchar)
- `phone_number` (varchar)
- `end_date` (date) - Delivery date (NULL = pending)

---

### WA-VAL-003: Water Type Existence

**Rule:** drinking_water_type_id must reference existing water type

**Type:** Referential integrity

**Implementation:**
- Database: `FOREIGN KEY (drinking_water_type_id) REFERENCES drinking_water_types(drinking_water_type_id)`

---

### WA-VAL-004: Positive Quantity

**Rule:** Quantity of water gallons must be greater than 0

**Type:** Business constraint

**Implementation:**
```python
if quantity <= 0:
    return error('Quantity must be at least 1')
```

---

## 4. Employee Management Validation Rules

### EM-VAL-001: Employee Name and Phone Validation

**Rule:** Employee name must be unique, phone number must be valid format

**Type:** Business constraint + format validation

**Name Validation:**
- Database: `UNIQUE KEY name (name)`
- Must be unique across all employees
- Cannot be empty

**Phone Validation:**
- Format: Indonesian phone number (08xxx or +62xxx)
- Length: Typically 10-15 characters
- Optional field (can be NULL)

**Implementation:**
```python
# Name uniqueness check
existing = db.query('SELECT * FROM employees WHERE name = ?', [name])
if existing:
    return error('Employee name already exists')

# Phone format validation (if provided)
if phone_number:
    if not re.match(r'^(\+62|08)\d{8,13}$', phone_number):
        return error('Invalid phone number format')
```

**Test Cases:**

| Name | Phone | Result |
|------|-------|--------|
| "Ahmad" (new) | "081234567890" | ✅ Success |
| "Ahmad" (duplicate) | "081234567890" | ❌ Error: "Name already exists" |
| "Budi" | NULL | ✅ Success |
| "Cici" | "12345" | ❌ Error: "Invalid phone format" |
| "Dedi" | "+6281234567890" | ✅ Success |

---

### EM-VAL-002: Required Employee Fields

**Rule:** Employee must have name (phone is optional)

**Required Fields:**
- `name` (varchar) - Employee name (unique)

**Optional Fields:**
- `phone_number` (varchar)

---

## 5. Transaction Management Validation Rules

### TX-VAL-001: Date Range Validation

**Rule:** When filtering transactions by date range, start_date must be before or equal to end_date

**Type:** Business logic validation

**Implementation:**
```python
if start_date > end_date:
    return error('Start date must be before or equal to end date')
```

**Test Cases:**

| start_date | end_date | Result |
|------------|----------|--------|
| 2025-01-01 | 2025-01-31 | ✅ Success |
| 2025-01-01 | 2025-01-01 | ✅ Success (same day) |
| 2025-01-31 | 2025-01-01 | ❌ Error: "Start date must be before end date" |

---

### TX-VAL-002: End Date Optional

**Rule:** end_date is optional (NULL = transaction pending/not completed)

**Type:** Business workflow rule

**Logic:**
- `end_date = NULL` → Transaction is pending (not counted in income)
- `end_date IS NOT NULL` → Transaction is completed (counted in income)

**No validation needed** - NULL is valid and expected for pending transactions

---

## 6. System-Wide Validation Rules

### SY-VAL-001: Pagination Validation

**Rule:** Pagination parameters must be within allowed bounds

**Constraints:**
- `page` >= 1
- `per_page` between 1 and 100 (max 100)
- Default: `per_page = 20`

**Implementation:**
```python
page = max(1, int(request.args.get('page', 1)))
per_page = min(100, max(1, int(request.args.get('per_page', 20))))
```

**Test Cases:**

| page | per_page | Result |
|------|----------|--------|
| 1 | 20 | ✅ page=1, per_page=20 (default) |
| 0 | 20 | ✅ page=1 (clamped) |
| -5 | 20 | ✅ page=1 (clamped) |
| 1 | 0 | ✅ per_page=1 (clamped) |
| 1 | 200 | ✅ per_page=100 (clamped) |
| 1 | 50 | ✅ page=1, per_page=50 |

**Error Handling:**
- Invalid values are **clamped** to valid range (no error returned)
- This is a **silent correction** approach

---

### SY-VAL-002: Required Field Validation Pattern

**Rule:** All POST/PUT endpoints validate required fields

**Pattern:**
```python
required_fields = ['field1', 'field2', 'field3']
for field in required_fields:
    if field not in data or data[field] is None:
        return jsonify({'error': f'{field} is required'}), 400
```

**Common Required Fields by Service:**

**Car Wash:**
- `date`, `carwash_type_id`, `final_price`

**Laundry/Carpet:**
- `date`, `final_price`, `items` (array)

**Water Delivery:**
- `date`, `drinking_water_type_id`, `quantity`, `final_price`

**Employee:**
- `name`

---

### SY-VAL-003: Name Uniqueness (Cross-Service)

**Rule:** Certain entities enforce unique names

**Entities with Unique Names:**
- `employees.name` - UNIQUE
- `carwash_types.name` - UNIQUE (assumed)
- `laundry_types.name` - UNIQUE (assumed)
- `drinking_water_types.name` - UNIQUE (assumed)

**Implementation:**
- Database: `UNIQUE KEY name (name)`
- Application: Pre-check before insert

---

## 7. Database Constraint Validations

### DB-VAL-001: Foreign Key Constraints

**All Foreign Keys:**

| Child Table | Child Column | Parent Table | Parent Column |
|-------------|--------------|--------------|---------------|
| carwash_transactions | carwash_type_id | carwash_types | carwash_type_id |
| carwash_employees | carwash_transaction_id | carwash_transactions | carwash_transaction_id |
| carwash_employees | employee_id | employees | employee_id |
| laundry_items | laundry_transaction_id | laundry_transactions | laundry_transaction_id |
| laundry_items | laundry_type_id | laundry_types | laundry_type_id |
| drinking_water_transactions | drinking_water_customer_id | drinking_water_customers | drinking_water_customer_id |
| drinking_water_transactions | drinking_water_type_id | drinking_water_types | drinking_water_type_id |

**Validation:**
- Database enforces automatically
- Returns foreign key constraint error if violated

---

### DB-VAL-002: NOT NULL Constraints

**Critical NOT NULL Fields:**

**All Transactions:**
- `date` - Transaction date
- `final_price` - Transaction price
- `created_at` - Record creation timestamp
- `updated_at` - Record update timestamp

**Service Type Tables:**
- Service type ID
- Service type name

---

### DB-VAL-003: AUTO_INCREMENT Primary Keys

**All Primary Keys:**
- `employee_id` (employees)
- `carwash_type_id` (carwash_types)
- `carwash_transaction_id` (carwash_transactions)
- `carwash_employee_id` (carwash_employees) - Added in production
- `laundry_type_id` (laundry_types)
- `laundry_transaction_id` (laundry_transactions)
- `laundry_item_id` (laundry_items)
- `drinking_water_customer_id` (drinking_water_customers)
- `drinking_water_type_id` (drinking_water_types)
- `drinking_water_transaction_id` (drinking_water_transactions)

**Validation:**
- Auto-generated by database
- No user input required

---

## 8. Missing Validations (Recommendations)

### MV-001: No Email Validation

**Current State:** No email fields in database
**Recommendation:** If adding email fields, validate format:
```python
if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
    return error('Invalid email format')
```

---

### MV-002: No Price Range Validation

**Current State:** No upper limit on prices
**Recommendation:** Add reasonable upper limits:
```python
MAX_PRICE = 100_000_000  # 100 million Rupiah
if final_price > MAX_PRICE:
    return error('Price exceeds maximum allowed')
```

---

### MV-003: No Quantity Limits

**Current State:** No upper limit on quantities
**Recommendation:** Add reasonable limits:
```python
MAX_LAUNDRY_ITEMS = 100
MAX_WATER_GALLONS = 1000
if len(items) > MAX_LAUNDRY_ITEMS:
    return error('Too many items')
```

---

### MV-004: No Date Range Validation

**Current State:** Can create transactions with future dates or very old dates
**Recommendation:** Add date range validation:
```python
if transaction_date > datetime.now() + timedelta(days=1):
    return error('Cannot create future transactions')
if transaction_date < datetime.now() - timedelta(days=365):
    return warning('Transaction date is more than 1 year old')
```

---

### MV-005: No Phone Number Format Enforcement

**Current State:** Phone numbers stored as varchar without format validation
**Recommendation:** Enforce Indonesian phone number format:
```python
# Allow: 08xxx, +62xxx, 62xxx
if phone_number and not re.match(r'^(\+?62|0)8\d{8,13}$', phone_number):
    return error('Invalid Indonesian phone number')
```

---

## 9. Validation Rule Summary

### By Priority

**Critical (Database-Enforced):**
- Foreign key constraints (7 rules)
- NOT NULL constraints (10+ rules)
- UNIQUE constraints (5+ rules)

**High (Business Logic):**
- Required field validation (SY-VAL-002)
- Pagination bounds (SY-VAL-001)
- Employee name uniqueness (EM-VAL-001)
- Duplicate assignment prevention (CW-VAL-001)

**Medium (Data Quality):**
- Positive quantity validation (LA-VAL-004, WA-VAL-004)
- Positive price validation (LA-VAL-005)
- Date range validation (TX-VAL-001)

**Low (Optional):**
- Phone format validation (EM-VAL-001)
- Optional customer association (WA-VAL-001)

---

## 10. Validation Implementation Patterns

### Pattern 1: Required Fields

```python
def validate_required_fields(data, required_fields):
    for field in required_fields:
        if field not in data or data[field] is None or data[field] == '':
            return {'error': f'{field} is required'}, 400
    return None, 200
```

### Pattern 2: Positive Number

```python
def validate_positive(value, field_name):
    if value <= 0:
        return {'error': f'{field_name} must be greater than 0'}, 400
    return None, 200
```

### Pattern 3: Foreign Key Existence

```python
def validate_fk_exists(table, id_field, id_value):
    result = db.query(f'SELECT {id_field} FROM {table} WHERE {id_field} = ?', [id_value])
    if not result:
        return {'error': f'{table} with {id_field}={id_value} does not exist'}, 404
    return None, 200
```

### Pattern 4: Uniqueness Check

```python
def validate_unique(table, field, value, exclude_id=None):
    query = f'SELECT * FROM {table} WHERE {field} = ?'
    params = [value]
    if exclude_id:
        query += f' AND id != ?'
        params.append(exclude_id)
    result = db.query(query, params)
    if result:
        return {'error': f'{field} already exists'}, 400
    return None, 200
```

---

## Conclusion

**Total Validation Rules:** 25+
- Database constraints: 12+
- Application validation: 13+
- Recommended additions: 5

**Validation Coverage:**
- ✅ All foreign keys validated
- ✅ All required fields validated
- ✅ Business constraints enforced
- ⚠️ Format validation limited (phone numbers)
- ⚠️ Range validation missing (prices, dates)

**For Rebuild:**
- Preserve all existing validations
- Add missing format validations
- Implement range checks for prices and quantities
- Add comprehensive error messages

---

**Last Updated:** October 22, 2025
