# Business Logic Summary

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** High-level summary of all business logic in the Kharisma Abadi system
**Note:** This document is referenced by other skills and tools for comprehensive system understanding

---

## Executive Summary

The Kharisma Abadi system manages 4 business services with distinct but related business logic:
- **Car Wash:** Configurable employee cuts (variable based on service type)
- **Laundry:** Fixed 60/40 income split (hardcoded)
- **Carpet Cleaning:** Fixed 60/40 income split (hardcoded)
- **Water Delivery:** Fixed 60/40 income split (hardcoded)

**Key Finding:** Income calculation logic is **inconsistent** - car wash uses database-driven configuration while other services have hardcoded percentages.

---

## Business Logic Statistics

### Total Rules Documented

| Category | Count | Documentation |
|----------|-------|---------------|
| **Business Rules** | 19 | business-rules-catalog.md |
| **Validation Rules** | 25+ | validation-rules.md |
| **Decision Tables** | 12 tables (52+ rules) | decision-tables.md |
| **State Machines** | 7 diagrams | state-diagrams.md |
| **Workflow Diagrams** | 9 diagrams | workflows/transaction-lifecycle.md |
| **Calculation Formulas** | 15+ | calculation-formulas.md |
| **Constants** | 50+ | constants.md |
| **Code Mappings** | 19 rules → 50+ locations | code-mapping.md |

---

## Business Domains

### 1. Car Wash Service

**Complexity:** Medium (configurable logic)

**Key Business Logic:**
- Variable employee cut: Fixed amount OR percentage (CW-INC-001)
- Multi-employee income distribution with floor division (CW-INC-002)
- Unique employee assignments per transaction (CW-VAL-001)

**Configuration:**
- Employee cuts stored in `carwash_types` table (cut_type, cut_amount)
- Fully configurable without code changes ✅

**State Flow:** Created → Pending → In Progress → Completed

**Income Calculation:**
```
gross_income = final_price
if cut_type == 1:
    employee_cut = cut_amount (fixed)
elif cut_type == 2:
    employee_cut = final_price × (cut_amount / 100)
net_income = gross_income - employee_cut
per_employee = employee_cut // num_employees (floor division)
```

**Issues:**
- Floor division loses remainder (micro-losses)
- Example: 50,000 ÷ 3 = 16,666 each (total 49,998, loss 2 Rupiah)

---

### 2. Laundry Service

**Complexity:** High (item-based pricing with adjustment logic)

**Key Business Logic:**
- Fixed 60% business / 40% employee split (**HARDCODED**) (LA-INC-001)
- Service classified as "Laundry" if no area-based units (LA-WF-001)
- Item price distribution when final_price ≠ sum(item prices) (LA-CAL-001)

**Configuration:**
- Item prices stored in `laundry_types` table ✅
- Income split **HARDCODED** in dashboard_controller.py:66 ❌

**State Flow:** Created → Items Cataloged → Pending → In Progress → Ready → Picked Up

**Income Calculation:**
```
gross_income = final_price
business_income = final_price × 0.6 (HARDCODED)
employee_income = final_price × 0.4 (HARDCODED)
```

**Item Price Distribution:**
- If final_price > total → Add extra to first item
- If final_price < total → Subtract sequentially from items (can zero out items)
- If final_price == total → No adjustment

**Issues:**
- Income split hardcoded (cannot change without deployment)
- Inconsistent with car wash (which is configurable)

---

### 3. Carpet Cleaning Service

**Complexity:** High (shares table with laundry, differentiated by unit type)

**Key Business Logic:**
- Fixed 60% business / 40% employee split (**HARDCODED**) (CA-INC-001)
- Service classified as "Carpet" if ANY item has unit='m' or 'm2' (LA-WF-001)
- Shares all other logic with laundry (item price distribution, etc.)

**Configuration:**
- Item prices stored in `laundry_types` table ✅
- Income split **HARDCODED** in dashboard_controller.py:72 ❌

**State Flow:** Same as laundry

**Income Calculation:** Same as laundry (60/40 split)

**Issues:**
- Income split hardcoded
- Mixed transactions (kg + m2) classified as carpet
- No explicit service_type field at transaction level

---

### 4. Water Delivery Service

**Complexity:** Low (simple quantity-based pricing)

**Key Business Logic:**
- Fixed 60% business / 40% employee split (**HARDCODED**) (WA-INC-001)
- Optional customer association (can be walk-in or registered) (WA-VAL-001)

**Configuration:**
- Product prices stored in `drinking_water_types` table ✅
- Income split **HARDCODED** in dashboard_controller.py:89 ❌

**State Flow:** Customer Select → Order Created → Pending → Delivered

**Income Calculation:**
```
gross_income = final_price
business_income = final_price × 0.6 (HARDCODED)
employee_income = final_price × 0.4 (HARDCODED)
```

**Customer Association:**
- Registered: `drinking_water_customer_id IS NOT NULL`
- Walk-in: `drinking_water_customer_id = NULL` with manual name/phone

**Issues:**
- Income split hardcoded
- Inconsistent with car wash

---

### 5. Employee Management

**Complexity:** Low (car wash only, aggregation logic)

**Key Business Logic:**
- Income aggregation by time period (day, month, year, all-time) (EM-INC-001)
- Name must be unique (EM-VAL-001)
- **Only car wash income is tracked per employee**

**Configuration:**
- No configuration (aggregates from transactions)

**Income Calculation:**
- Sum all completed car wash transactions where employee was assigned
- Filter by date range for period-specific income

**Issues:**
- No employee tracking for laundry/carpet/water services
- 40% employee income goes to business (not distributed to individuals)

---

### 6. Transaction Management (Cross-Service)

**Complexity:** Low (universal pattern)

**Key Business Logic:**
- Transaction completion tracked via `end_date` field (TX-WF-001)
- `end_date = NULL` → Pending (not counted in income)
- `end_date IS NOT NULL` → Completed (counted in income)

**Universal Pattern:** Applies to ALL services

**Issues:**
- No explicit status field (state inferred from NULL check)
- Cannot distinguish "in progress" from "pending" without explicit field

---

## Critical Business Logic

### Highest Priority (Must Preserve)

| Rule | Description | Impact | Status |
|------|-------------|--------|--------|
| **TX-WF-001** | Transaction completion via end_date | Determines income inclusion | ✅ Universal |
| **CW-INC-001** | Variable employee cut | Car wash income calculation | ✅ Configurable |
| **LA-INC-001** | Laundry 60/40 split | Laundry income calculation | ❌ Hardcoded |
| **CA-INC-001** | Carpet 60/40 split | Carpet income calculation | ❌ Hardcoded |
| **WA-INC-001** | Water 60/40 split | Water income calculation | ❌ Hardcoded |
| **LA-CAL-001** | Item price distribution | Laundry pricing accuracy | ✅ Implemented |

---

## Complexity Analysis

### By Business Domain

| Domain | Complexity Rating | Reason |
|--------|-------------------|--------|
| **Car Wash** | ⭐⭐⭐ Medium | Variable cuts, multi-employee division |
| **Laundry** | ⭐⭐⭐⭐ High | Item-based, price distribution, service differentiation |
| **Carpet** | ⭐⭐⭐⭐ High | Same as laundry + unit-based classification |
| **Water Delivery** | ⭐⭐ Low | Simple quantity-based pricing |
| **Employee** | ⭐⭐ Low | Aggregation logic only |
| **Transactions** | ⭐⭐ Low | Universal completion pattern |

---

### By Logic Type

| Logic Type | Complexity | Examples |
|------------|------------|----------|
| **Income Calculation** | High | Variable cuts, 60/40 splits, floor division |
| **Item Price Distribution** | Very High | Sequential discount application, first-item extra charge |
| **Service Differentiation** | Medium | Unit-based classification (m, m2 vs kg, pcs) |
| **State Management** | Low | end_date NULL check |
| **Validation** | Low | Required fields, foreign keys |
| **Aggregation** | Medium | Employee income by period, dashboard totals |

---

## Dependencies Between Rules

### Rule Dependency Graph

```
TX-WF-001 (Transaction Completion)
    ├─→ CW-INC-001 (Car Wash Income) → Only if end_date IS NOT NULL
    ├─→ CW-INC-002 (Employee Division) → Only if end_date IS NOT NULL
    ├─→ LA-INC-001 (Laundry Income) → Only if end_date IS NOT NULL
    ├─→ CA-INC-001 (Carpet Income) → Only if end_date IS NOT NULL
    ├─→ WA-INC-001 (Water Income) → Only if end_date IS NOT NULL
    └─→ EM-INC-001 (Employee Aggregation) → Only if end_date IS NOT NULL

LA-WF-001 (Service Differentiation)
    ├─→ LA-INC-001 (Laundry Income) → If classified as Laundry
    └─→ CA-INC-001 (Carpet Income) → If classified as Carpet

LA-CAL-001 (Item Price Distribution)
    └─→ LA-INC-001 / CA-INC-001 → Affects final_price used for income

CW-INC-001 (Variable Cut)
    └─→ CW-INC-002 (Employee Division) → total_cut from CW-INC-001

WA-VAL-001 (Customer Association)
    └─→ WA-INC-001 (Water Income) → Customer info doesn't affect income
```

**Key Dependency:** Almost all income rules depend on TX-WF-001 (end_date IS NOT NULL)

---

## Configuration Requirements

### Currently Configurable (Database-Driven)

✅ **Car Wash:**
- Service types (name, price, cut_type, cut_amount)

✅ **Laundry/Carpet:**
- Item types (name, price, unit)

✅ **Water Delivery:**
- Product types (name, price)

---

### Should Be Configurable (Currently Hardcoded)

❌ **Laundry Income Split:**
- Business: 60% → Should be in `income_configuration` table
- Employee: 40% → Should be in `income_configuration` table

❌ **Carpet Income Split:**
- Business: 60% → Should be in `income_configuration` table
- Employee: 40% → Should be in `income_configuration` table

❌ **Water Income Split:**
- Business: 60% → Should be in `income_configuration` table
- Employee: 40% → Should be in `income_configuration` table

❌ **Pagination Limits:**
- Max per_page: 100 → Should be in `system_configuration` table
- Default per_page: 20 → Should be in `system_configuration` table

❌ **Service Classification:**
- Carpet units: 'm', 'm2' → Should be in enum or configuration

---

## Integration Points

### Internal Integrations

**Dashboard ↔ All Services:**
- Aggregates income from all transaction types
- Applies service-specific income rules

**Employee ↔ Car Wash:**
- Employee income tracking (one-way)
- Only car wash transactions tracked

**Laundry ↔ Carpet:**
- Share same transaction table
- Differentiated by item units

---

### External Integrations

**None Found:**
- No payment gateway integration
- No SMS/email notification logic
- No third-party API calls
- No inventory management integration

---

## Business Logic Anti-Patterns

### 1. Hardcoded Business Rules

**Problem:** Income splits hardcoded in controller logic

**Location:** `dashboard_controller.py` lines 66, 72, 89

**Impact:** Cannot change business rules without code deployment

**Recommendation:** Move to database configuration

---

### 2. Inconsistent Configuration Approach

**Problem:** Car wash is configurable, but laundry/carpet/water are hardcoded

**Impact:** Confusing architecture, inconsistent UX

**Recommendation:** Standardize all services to use database configuration

---

### 3. Floor Division Loses Micro-Amounts

**Problem:** Using `//` operator for employee income distribution

**Location:** `carwash_transaction_controller.py:88-91`

**Impact:** Small losses accumulate (2-6 Rupiah per transaction with multiple employees)

**Recommendation:** Distribute remainder to first N employees

---

### 4. No Explicit Status Field

**Problem:** State inferred from `end_date IS NULL` check

**Impact:** Cannot distinguish "pending" vs "in progress" vs "ready"

**Recommendation:** Add explicit `status` ENUM field

---

### 5. Service Type Ambiguity

**Problem:** Laundry and carpet share table, differentiated by item units

**Impact:** Mixed transactions possible, no transaction-level service type

**Recommendation:** Add explicit `service_type` field to laundry_transactions table

---

## Business Logic Best Practices (Found)

### ✅ 1. Transaction Completion Pattern

**Good:** Universal `end_date IS NOT NULL` check across all services

**Benefit:** Consistent, simple, reliable

---

### ✅ 2. Database-Driven Car Wash Configuration

**Good:** Service types with configurable cut_type and cut_amount

**Benefit:** Business can change employee cuts without deployment

---

### ✅ 3. Junction Table for Many-to-Many

**Good:** `carwash_employees` table with unique constraint

**Benefit:** Proper normalization, prevents duplicate assignments

---

### ✅ 4. Item-Based Pricing

**Good:** Separate `laundry_items` table for flexible multi-item transactions

**Benefit:** Can track individual items with different types/quantities

---

## Recommendations for Rebuild

### Critical (Must Do)

1. **Make income splits configurable** (HIGH PRIORITY)
   - Create `income_configuration` table
   - Move hardcoded 60/40 splits to database
   - Apply same pattern as car wash

2. **Fix floor division issue** (MEDIUM PRIORITY)
   - Implement remainder distribution
   - OR track fractional amounts
   - Document chosen approach

3. **Add explicit status field** (MEDIUM PRIORITY)
   - Create status ENUM (pending, in_progress, ready, completed, cancelled)
   - Migrate existing data (NULL → pending, NOT NULL → completed)
   - Update all queries

---

### Important (Should Do)

4. **Standardize service configuration**
   - All services should use same configuration pattern
   - Database-driven, not hardcoded

5. **Add service_type field to laundry_transactions**
   - Explicit 'laundry' or 'carpet' classification
   - Don't rely solely on item units

6. **Implement employee tracking for all services**
   - Currently only car wash tracks employee income
   - Laundry/carpet/water employee income goes to business

---

### Nice to Have (Consider)

7. **Add price range validation**
   - Max price limits
   - Min quantity limits

8. **Improve pagination configuration**
   - Move to system_configuration table
   - Allow runtime changes

9. **Add audit logging**
   - Track who changed what and when
   - Especially for income configuration changes

---

## Testing Considerations

### Test Coverage Requirements

**Business Rules:** 19 rules × average 2 test cases = **38+ unit tests**

**Decision Tables:** 52+ decision rules = **52+ test cases**

**Validation Rules:** 25+ validation rules × average 3 test cases = **75+ test cases**

**Total Estimated Test Cases:** **165+ tests minimum**

---

### Critical Test Scenarios

1. **Income Calculation Tests:**
   - All service types (car wash, laundry, carpet, water)
   - With/without end_date
   - Edge cases (0 price, very large price)

2. **Employee Division Tests:**
   - 1 employee, multiple employees
   - Floor division edge cases (50,000 ÷ 3 = 16,666 × 3 = 49,998)

3. **Item Price Distribution Tests:**
   - Extra charge scenario
   - Small discount scenario
   - Large discount (zeroing out items)

4. **Service Classification Tests:**
   - Pure laundry (kg, pcs units)
   - Pure carpet (m, m2 units)
   - Mixed transaction (kg + m2)

5. **State Transition Tests:**
   - Pending → Completed (set end_date)
   - Cannot reverse (completed → pending)

---

## Conclusion

**Business Logic Maturity:** Medium

**Strengths:**
- ✅ Well-defined workflows
- ✅ Clear transaction lifecycle
- ✅ Car wash service is properly configurable
- ✅ Item-based pricing for laundry/carpet
- ✅ Production-proven (3+ years)

**Weaknesses:**
- ❌ Inconsistent configuration (hardcoded vs database-driven)
- ❌ Floor division loses micro-amounts
- ❌ No explicit status field
- ❌ Service type ambiguity (laundry vs carpet)
- ❌ Employee tracking only for car wash

**Overall Assessment:** System has solid business logic foundation but needs refactoring to make all business rules configurable and fix calculation precision issues.

---

## Cross-Reference

This summary references:
- **business-rules-catalog.md** - Full rule definitions with test cases
- **calculation-formulas.md** - Detailed income calculation formulas
- **validation-rules.md** - Complete validation rule catalog
- **state-diagrams.md** - State machine diagrams
- **decision-tables.md** - Decision logic tables
- **constants.md** - All hardcoded constants
- **code-mapping.md** - Rule-to-code location mapping
- **workflows/transaction-lifecycle.md** - Visual workflow diagrams

---

**Last Updated:** October 22, 2025
**Total Rules Documented:** 19 business rules, 25+ validation rules, 52+ decision rules
**Total Documentation:** 8 comprehensive documents, 2,500+ lines
