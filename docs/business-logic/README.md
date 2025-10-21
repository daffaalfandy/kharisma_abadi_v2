# Business Logic Documentation

**Document Version:** 1.0
**Analysis Date:** October 22, 2025
**Purpose:** Comprehensive catalog of business rules, calculations, and workflows extracted from the Kharisma Abadi system

---

## Overview

This directory contains the complete business logic documentation for the Kharisma Abadi cashier system. These documents were extracted from the production codebase and are critical for:

- Understanding how the system works
- Preserving business rules during rebuild/modernization
- Training new developers
- Validating system behavior
- Identifying areas for improvement

---

## Documents

### 1. [Calculation Formulas](./calculation-formulas.md)
**Complete catalog of all financial and business calculations**

**Contents:**
- Car wash income calculations (variable employee cuts)
- Laundry/carpet income (60%/40% splits)
- Water delivery income (60%/40% splits)
- Employee income distribution and aggregation
- Laundry item price distribution logic
- Transaction aggregations
- Calculation accuracy issues

**Use when:**
- Implementing income calculation logic
- Verifying financial calculations are correct
- Understanding employee pay distribution
- Debugging income discrepancies

**Key sections:**
- Section 1-3: Service-specific income formulas
- Section 4: Employee income calculations
- Section 5: Item price distribution (complex logic)
- Section 7: Known calculation issues

---

### 2. [Business Rules Catalog](./business-rules-catalog.md)
**Comprehensive catalog of 19 business rules with test cases**

**Contents:**
- 6 Car wash rules (CW-INC-001 through CW-VAL-001)
- 4 Laundry/Carpet rules (LA-INC-001 through LA-CAL-001)
- 2 Water delivery rules (WA-INC-001, WA-VAL-001)
- 2 Employee rules (EM-INC-001, EM-VAL-001)
- 2 Transaction rules (TX-WF-001, TX-VAL-001)
- 4 System rules (SY-VAL-001 through SY-CONST-001)

**Use when:**
- Writing test cases for the system
- Validating business logic implementation
- Understanding constraints and validation rules
- Onboarding new team members

**Format:**
Each rule includes:
- Rule ID and name
- Category and priority
- Detailed description
- Implementation location (file:line)
- Test cases with input/expected output
- Edge cases and notes

---

### 3. [Transaction Lifecycle Workflows](./workflows/transaction-lifecycle.md)
**Visual workflow documentation with Mermaid diagrams**

**Contents:**
- Car wash transaction workflow (Created → Pending → Completed)
- Laundry/carpet transaction workflow (6 states)
- Water delivery transaction workflow (4 states)
- Income calculation workflow
- Item price distribution workflow
- Employee income aggregation workflow
- Common transaction operations (create, update, complete)
- Dashboard income calculation flow
- State transition triggers

**Use when:**
- Understanding transaction states
- Implementing transaction lifecycle
- Debugging workflow issues
- Explaining system flow to stakeholders

**Diagrams:**
- 9 Mermaid diagrams (state machines, flowcharts, sequence diagrams)
- State details tables
- Transition triggers documentation

---

## Quick Start Guide

### For Developers

1. **Understanding Income Calculations:**
   - Start: [Calculation Formulas - Income Overview](./calculation-formulas.md#1-car-wash-income-calculation)
   - Learn: How car wash, laundry, and water income is calculated
   - Implement: Use formulas directly in new system

2. **Implementing Transaction Workflows:**
   - Start: [Transaction Lifecycle - Overview](./workflows/transaction-lifecycle.md#overview)
   - Learn: How transactions move through states
   - Implement: Follow state machine diagrams

3. **Writing Tests:**
   - Start: [Business Rules Catalog - Test Cases](./business-rules-catalog.md#test-cases)
   - Learn: All business rules with expected behavior
   - Implement: Use test cases as unit test specifications

### For Business Analysts

1. **Understanding Business Rules:**
   - Start: [Business Rules Catalog](./business-rules-catalog.md)
   - Review: All 19 rules categorized by service type
   - Validate: Confirm rules match business requirements

2. **Understanding Workflows:**
   - Start: [Transaction Lifecycle Workflows](./workflows/transaction-lifecycle.md)
   - Review: Visual diagrams of all workflows
   - Validate: Confirm states and transitions

### For Architects

1. **System Design:**
   - Review: [Calculation Formulas - Hardcoded Values](./calculation-formulas.md#8-hardcoded-values-needing-refactoring)
   - Identify: Areas requiring refactoring
   - Plan: Configuration-driven architecture

2. **Data Flow:**
   - Review: [Workflows - Income Calculation](./workflows/transaction-lifecycle.md#4-income-calculation-workflow)
   - Understand: How data flows through system
   - Design: Improved architecture

---

## Critical Findings

### Hardcoded Business Logic

**Problem:** Income splits are hardcoded in controller logic, not database-driven

| Service | Split | Status | Priority |
|---------|-------|--------|----------|
| Car Wash | Variable (DB-driven) | ✅ Configurable | Good |
| Laundry | 60% business / 40% employees | ❌ Hardcoded | HIGH |
| Carpet | 60% business / 40% employees | ❌ Hardcoded | HIGH |
| Water | 60% business / 40% employees | ❌ Hardcoded | HIGH |

**Impact:**
- Cannot change income splits without code modification
- Inconsistent with car wash service (which is configurable)
- Requires redeployment to adjust business rules

**Recommendation:**
- Refactor to database-driven configuration (like car wash)
- Create `income_configuration` table
- Store service-specific income rules

**Files affected:**
- `be-kharisma-abadi/controller/dashboard_controller.py:66,72,89`

---

### Calculation Accuracy Issues

**Problem:** Floor division causes micro-losses in employee income

**Example:**
```
Total employee cut: 50,000 Rupiah
Number of employees: 3

Current (floor division):
  per_employee = 50000 // 3 = 16,666
  total_distributed = 16,666 * 3 = 49,998
  loss = 2 Rupiah (not distributed)

Recommended:
  Remainder distribution (sequential)
  OR track fractional amounts
```

**Impact:**
- Small losses accumulate over many transactions
- Employee income reports may not match transaction totals
- Accounting discrepancies

**Recommendation:**
- Implement remainder distribution (give extra to first N employees)
- OR track fractional amounts with proper rounding
- Document the chosen approach

**Files affected:**
- `be-kharisma-abadi/controller/carwash_transaction_controller.py:88-91`

---

### Service Differentiation Ambiguity

**Problem:** Laundry and carpet share same table, differentiated by item unit type

**Logic:**
```python
# If ANY item has unit='m' or unit='m2', classify as CARPET
# Otherwise, classify as LAUNDRY
```

**Edge cases:**
- Mixed transaction (items with "kg" AND "m2") → classified as carpet
- No distinction at transaction level
- Cannot query "all carpet transactions" directly

**Impact:**
- Reports require item-level analysis
- Mixed service transactions possible
- May confuse accounting

**Recommendation:**
- Add explicit `service_type` field at transaction level
- OR enforce single service type per transaction
- OR accept current behavior and document clearly

**Files affected:**
- `be-kharisma-abadi/controller/laundry_transaction_controller.py:138-140`

---

## Business Rules Priority Matrix

### Critical (Must Preserve)

| Rule ID | Description | Impact |
|---------|-------------|--------|
| **CW-INC-001** | Variable employee cut (fixed/percentage) | Core car wash income |
| **CW-INC-002** | Multi-employee division | Employee pay accuracy |
| **LA-INC-001** | Laundry 60/40 split | Core laundry income |
| **CA-INC-001** | Carpet 60/40 split | Core carpet income |
| **WA-INC-001** | Water 60/40 split | Core water income |
| **LA-CAL-001** | Item price distribution | Price accuracy |
| **TX-WF-001** | Completion via end_date | Transaction status |

### High (Important to Preserve)

| Rule ID | Description | Impact |
|---------|-------------|--------|
| **LA-WF-001** | Carpet vs laundry differentiation | Service classification |
| **EM-INC-001** | Employee income aggregation | Employee reports |
| **SY-VAL-001** | Pagination validation | API stability |

### Medium (Good to Have)

| Rule ID | Description | Impact |
|---------|-------------|--------|
| **WA-VAL-001** | Optional customer association | Water delivery flexibility |
| **SY-VAL-002** | Required field validation | Data quality |
| **SY-VAL-003** | Name uniqueness | Data integrity |

### Low (Edge Cases)

| Rule ID | Description | Impact |
|---------|-------------|--------|
| **CW-VAL-001** | Prevent duplicate employee assignments | Data quality |
| **EM-VAL-001** | Name/phone validation | User experience |
| **TX-VAL-001** | Date range validation | Report accuracy |

---

## Implementation Checklist

### For System Rebuild

- [ ] **Income Calculations**
  - [ ] Implement car wash variable cut logic (CW-INC-001)
  - [ ] Implement 60/40 splits for LA/CA/WA (LA-INC-001, CA-INC-001, WA-INC-001)
  - [ ] Implement item price distribution (LA-CAL-001)
  - [ ] Implement employee income division (CW-INC-002)
  - [ ] Implement income aggregation (EM-INC-001)

- [ ] **Transaction Workflows**
  - [ ] Implement transaction states (Created → Pending → Completed)
  - [ ] Implement completion via end_date (TX-WF-001)
  - [ ] Implement service differentiation (LA-WF-001)
  - [ ] Implement create/update/complete operations

- [ ] **Validation Rules**
  - [ ] Pagination bounds (SY-VAL-001)
  - [ ] Required field validation (SY-VAL-002)
  - [ ] Name uniqueness (SY-VAL-003)
  - [ ] Prevent duplicate assignments (CW-VAL-001)
  - [ ] Date range validation (TX-VAL-001)

- [ ] **Configuration**
  - [ ] Make income splits configurable (HIGH PRIORITY)
  - [ ] Store cut types in database
  - [ ] Add service-specific configuration tables

- [ ] **Testing**
  - [ ] Write unit tests for all 19 business rules
  - [ ] Use test cases from business-rules-catalog.md
  - [ ] Test edge cases documented
  - [ ] Verify calculation accuracy

---

## Maintenance

### Updating Business Logic Documents

**When to update:**
- After changing income calculation logic
- After adding new service types
- After modifying transaction workflows
- After changing validation rules

**What to update:**
1. **Calculation Formulas** - If any financial logic changes
2. **Business Rules Catalog** - If any rule changes, add new rule entry
3. **Workflows** - If transaction states or transitions change

**How to update:**
1. Update the relevant section
2. Update "Last Updated" date
3. Add note about what changed
4. Verify cross-references still accurate

---

## Related Documentation

### Analysis Documents
- [Current Application Analysis](../analysis/current-app-analysis.md) - Complete technical analysis
- [Production Schema Findings](../analysis/production-schema-findings.md) - Database schema differences

### Source Code References
- Backend controllers: `be-kharisma-abadi/controller/`
- Database schema: `db-backup-scripts/backups/kharisma_db.sql` (production)
- API documentation: See [Current Application Analysis - Section 4](../analysis/current-app-analysis.md#4-api-endpoints-inventory)

---

## Statistics

**Total Business Rules Documented:** 19
**Total Test Cases:** 38+
**Total Formulas:** 15+
**Total Workflows:** 9 (with diagrams)
**Lines of Documentation:** 1,300+
**Critical Issues Identified:** 3 (hardcoded values, calculation accuracy, service differentiation)

---

## Glossary

**Cut Type 1:** Fixed amount employee cut (e.g., 5,000 Rupiah per employee)
**Cut Type 2:** Percentage employee cut (e.g., 30% of total price)
**Gross Income:** Total transaction price (before any deductions)
**Net Income:** Business profit after employee cuts
**Employee Cut:** Amount distributed to employees
**Floor Division:** Integer division that discards remainder (e.g., 50000 // 3 = 16666)
**Item Price Distribution:** Logic for adjusting item prices when final_price differs from sum
**Transaction Completion:** Setting end_date to mark transaction as finished and counted in income

---

## Contact

For questions about business logic:
1. Review the specific document (formulas, rules, or workflows)
2. Check the implementation location in source code
3. Verify test cases match expected behavior
4. Consult with business stakeholders for clarification

---

**Last Updated:** October 22, 2025
**Status:** ✅ Complete
**Next Review:** Before starting rebuild implementation
