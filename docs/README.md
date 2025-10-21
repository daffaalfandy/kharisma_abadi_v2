# Kharisma Abadi System Documentation

**Last Updated:** October 22, 2025
**Project Status:** Production (3+ years) - Planning Rebuild/Modernization

---

## Overview

This directory contains comprehensive documentation for the Kharisma Abadi cashier system, covering technical analysis, business logic, workflows, and architecture insights extracted from the production codebase.

---

## Documentation Structure

### 📊 [Analysis Documentation](./analysis/)
**Technical analysis of the current system**

- [**Current Application Analysis**](./analysis/current-app-analysis.md) (100+ pages)
  - Backend architecture (Flask/Python)
  - Frontend architecture (Next.js/TypeScript)
  - Database schema (9 core tables)
  - Complete API documentation (57+ endpoints)
  - Dependencies analysis
  - Security assessment
  - Performance analysis
  - Modernization recommendations

- [**Production Schema Findings**](./analysis/production-schema-findings.md)
  - Production vs base schema differences
  - Critical finding: `carwash_employees` table evolution
  - Database health assessment
  - Action items

- [**Analysis README**](./analysis/README.md)
  - Navigation guide
  - Key findings summary
  - Quick start for different roles

**Use when:** Understanding the technical architecture, planning modernization, security review

---

### 💼 [Business Logic Documentation](./business-logic/)
**Comprehensive catalog of business rules, calculations, and workflows**

- [**Calculation Formulas**](./business-logic/calculation-formulas.md) (285+ lines)
  - All income calculation formulas
  - Employee pay distribution
  - Item price distribution logic
  - Calculation accuracy issues

- [**Business Rules Catalog**](./business-logic/business-rules-catalog.md) (600+ lines)
  - 19 business rules with test cases
  - Categorized by service type
  - Priority matrix
  - Edge cases documented

- [**Transaction Lifecycle Workflows**](./business-logic/workflows/transaction-lifecycle.md) (400+ lines)
  - 9 Mermaid diagrams
  - Transaction state machines
  - Income calculation flows
  - Operation sequences

- [**Business Logic README**](./business-logic/README.md)
  - Navigation guide
  - Critical findings
  - Implementation checklist

**Use when:** Implementing business logic, writing tests, validating behavior, training developers

---

## Quick Start

### For New Developers

1. **Start here:** [Analysis - Executive Summary](./analysis/current-app-analysis.md#executive-summary)
2. **Understand business:** [Business Logic README](./business-logic/README.md)
3. **Learn workflows:** [Transaction Lifecycle](./business-logic/workflows/transaction-lifecycle.md)
4. **Study architecture:** [Current App Analysis - Architecture Overview](./analysis/current-app-analysis.md#11-architecture-overview)

### For Business Analysts

1. **Business rules:** [Business Rules Catalog](./business-logic/business-rules-catalog.md)
2. **Workflows:** [Transaction Lifecycle Workflows](./business-logic/workflows/transaction-lifecycle.md)
3. **Income calculations:** [Calculation Formulas](./business-logic/calculation-formulas.md)

### For Architects

1. **Technical analysis:** [Current Application Analysis](./analysis/current-app-analysis.md)
2. **Schema findings:** [Production Schema Findings](./analysis/production-schema-findings.md)
3. **Critical issues:** [Business Logic - Critical Findings](./business-logic/README.md#critical-findings)
4. **Modernization plan:** [Analysis - Recommendations](./analysis/current-app-analysis.md#10-recommendations)

### For Security Team

1. **Security assessment:** [Current App Analysis - Section 8](./analysis/current-app-analysis.md#8-security-assessment)
2. **Dependencies:** [Current App Analysis - Section 5](./analysis/current-app-analysis.md#5-dependencies-analysis)
3. **Critical issues:** [Analysis README - Critical Issues](./analysis/README.md#critical-issues)

### For Project Managers

1. **Executive summary:** [Analysis - Executive Summary](./analysis/current-app-analysis.md#executive-summary)
2. **Timeline estimates:** [Analysis - Recommended Path Forward](./analysis/README.md#recommended-path-forward)
3. **Key findings:** [Analysis README - Key Findings](./analysis/README.md#key-findings-summary)

---

## Key Findings Summary

### Overall Health Scores

| Aspect | Score | Status |
|--------|-------|--------|
| **Security** | 2/10 | 🔴 Critical (no authentication) |
| **Performance** | 5/10 | 🟡 Needs optimization |
| **Code Quality** | 4/10 | 🟡 Technical debt |
| **Business Logic** | 8/10 | 🟢 Well-defined |
| **Overall** | 4/10 | 🟡 Functional but needs modernization |

### Critical Issues

1. ❌ **No authentication/authorization** - API is completely open
2. ❌ **Hardcoded business logic** - 60/40 income splits not configurable
3. ⚠️ **Schema drift** - Production DB differs from base schema
4. ⚠️ **Calculation accuracy** - Floor division causes micro-losses
5. ❌ **No automated testing** - Zero test coverage
6. ⚠️ **Outdated dependencies** - Security vulnerabilities

### Strengths

- ✅ 3+ years production stability
- ✅ Clear MVC architecture
- ✅ Well-defined business rules
- ✅ Comprehensive workflows documented
- ✅ Recent performance optimizations
- ✅ Good backup strategy

---

## System Overview

### Services Managed

1. **Car Wash** - Vehicle washing with configurable employee cuts
2. **Laundry** - Clothing laundry with fixed 60/40 income split
3. **Carpet Cleaning** - Carpet washing with fixed 60/40 income split
4. **Water Delivery** - Drinking water delivery with fixed 60/40 income split

### Core Entities

- **Employees** - Workers assigned to jobs
- **Transactions** - Service records (car wash, laundry, carpet, water)
- **Customers** - Water delivery customers (optional tracking)
- **Service Types** - Configurable service pricing
- **Income Reports** - Daily/monthly/yearly aggregations

### Key Business Rules

| Rule ID | Description | Priority |
|---------|-------------|----------|
| **CW-INC-001** | Variable employee cut (fixed/percentage) | Critical |
| **LA-INC-001** | Laundry 60/40 split (HARDCODED) | Critical |
| **CA-INC-001** | Carpet 60/40 split (HARDCODED) | Critical |
| **WA-INC-001** | Water 60/40 split (HARDCODED) | Critical |
| **LA-CAL-001** | Item price distribution | Critical |
| **TX-WF-001** | Transaction completion via end_date | Critical |

---

## Technology Stack

### Backend
- **Framework:** Flask 2.3.2 (⚠️ Update to 3.x)
- **Database:** MariaDB 10.3.39
- **Server:** Gunicorn 21.2.0 + gevent
- **Deployment:** Docker

### Frontend
- **Framework:** Next.js 13.2.4 (⚠️ Update to 15.x)
- **Language:** TypeScript 5.0.3
- **UI:** Material-UI v5 + Tailwind CSS v3
- **Deployment:** Docker

### Database Schema

**9 Core Tables:**
1. `employees` - Employee registry
2. `carwash_types` - Car wash service types
3. `carwash_transactions` - Car wash jobs
4. `carwash_employees` - Employee assignments (⚠️ evolved in production)
5. `laundry_types` - Laundry/carpet types
6. `laundry_transactions` - Laundry/carpet jobs
7. `laundry_items` - Laundry items (junction)
8. `drinking_water_customers` - Water customers
9. `drinking_water_types` - Water product types
10. `drinking_water_transactions` - Water deliveries

---

## Recommended Path Forward

### Phase 1: Critical Fixes (Weeks 1-2)
- Fix CORS configuration
- Add database indexes
- Add basic input validation
- Update documentation

### Phase 2: Security & Testing (Months 1-2)
- Implement JWT authentication
- Add user management (roles)
- Set up automated testing (pytest, Jest)
- Update all dependencies

### Phase 3: Architecture Refactoring (Months 3-6)
- **Make income splits configurable** (HIGH PRIORITY)
- Add service layer
- Migrate to ORM (SQLAlchemy)
- Implement database migrations (Alembic)
- Add Redis caching

### Phase 4: Modernization (Months 6-12)
- Migrate Next.js to App Router
- Add API documentation (OpenAPI)
- Advanced analytics
- Mobile app (optional)

**Total Timeline:** 6-12 months
**Recommended Team:** 2-3 developers

---

## Documentation Statistics

**Total Pages:** 1,800+ lines across all documents
**Analysis Documents:** 3 (100+ pages combined)
**Business Logic Documents:** 4 (1,300+ lines)
**Business Rules Cataloged:** 19 with test cases
**API Endpoints Documented:** 57+
**Mermaid Diagrams:** 9
**Critical Issues Identified:** 6
**Recommendations Made:** 50+

---

## Critical Hardcoded Values

**Must be refactored to configuration:**

| Service | Value | Location | Priority |
|---------|-------|----------|----------|
| Laundry | 60% business / 40% employees | `dashboard_controller.py:66` | HIGH |
| Carpet | 60% business / 40% employees | `dashboard_controller.py:72` | HIGH |
| Water | 60% business / 40% employees | `dashboard_controller.py:89` | HIGH |
| Pagination | Max 100 items | Multiple controllers | MEDIUM |
| Default page size | 20 items | Multiple controllers | LOW |

---

## How to Use This Documentation

### For Development

1. **Before implementing a feature:**
   - Check [Business Rules Catalog](./business-logic/business-rules-catalog.md) for related rules
   - Review [Workflows](./business-logic/workflows/transaction-lifecycle.md) for state machines
   - Consult [Calculation Formulas](./business-logic/calculation-formulas.md) for math logic

2. **When writing tests:**
   - Use test cases from [Business Rules Catalog](./business-logic/business-rules-catalog.md)
   - Cover edge cases documented in each rule

3. **When debugging:**
   - Check [Workflows](./business-logic/workflows/transaction-lifecycle.md) for expected flow
   - Verify calculations against [Formulas](./business-logic/calculation-formulas.md)

### For Code Review

1. **Verify business logic:**
   - Does it follow documented business rules?
   - Are hardcoded values avoided?
   - Are edge cases handled?

2. **Check architecture:**
   - Does it match current patterns?
   - Is it compatible with modernization plan?

### For Deployment

1. **Database changes:**
   - Use production schema as reference
   - Test migrations with production-like data
   - Follow [Production Schema Findings](./analysis/production-schema-findings.md)

2. **Security:**
   - Review [Security Assessment](./analysis/current-app-analysis.md#8-security-assessment)
   - Follow security checklist

---

## Maintenance

### Keeping Documentation Updated

**Update frequency:**
- After business logic changes
- After schema changes
- Before starting new development phases
- Quarterly review recommended

**What to update:**
1. Business rules catalog - when rules change
2. Workflows - when states/transitions change
3. Formulas - when calculations change
4. Analysis - when architecture changes

---

## Related Documentation

### In This Repository
- Production deployment: `../be-kharisma-abadi/docs/README_PRODUCTION.md`
- Database backups: `../db-backup-scripts/README.md`
- Onboarding memories: `../.serena/memories/`

### External Resources
- Flask documentation: https://flask.palletsprojects.com/
- Next.js documentation: https://nextjs.org/docs
- MariaDB documentation: https://mariadb.org/documentation/

---

## Questions?

For questions about:
- **Technical architecture** → See [Current Application Analysis](./analysis/current-app-analysis.md)
- **Business logic** → See [Business Logic README](./business-logic/README.md)
- **Database schema** → See [Production Schema Findings](./analysis/production-schema-findings.md)
- **Modernization plan** → See [Analysis - Recommendations](./analysis/current-app-analysis.md#10-recommendations)

---

**Documentation Completed:** October 22, 2025
**Analyzed By:** Claude Code (Sonnet 4.5)
**Project:** Kharisma Abadi Cashier System
**Purpose:** Pre-rebuild documentation and knowledge preservation

**Status:** ✅ Complete and ready for rebuild planning
