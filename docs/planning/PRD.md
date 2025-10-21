# Product Requirements Document (PRD)
# Kharisma Abadi - Application Rebuild

**Document Version:** 1.0  
**Date Created:** October 22, 2025  
**Last Updated:** October 22, 2025  
**Status:** READY FOR STAKEHOLDER REVIEW  
**Project Duration:** 5 months (20 weeks)

---

## Table of Contents

1. [BACKGROUND](#background)
   - Executive Summary
   - Current State Analysis
   - Problem Statement
   - Stakeholders
   
2. [MISSION](#mission)
   - Vision Statement
   - Goals & Objectives
   - Success Criteria
   - Non-Goals

3. [APPROACH](#approach)
   - Development Methodology
   - Technology Stack
   - Architecture Approach
   - Migration Strategy

4. [DETAILS](#details)
   - Functional Requirements
   - Non-Functional Requirements
   - User Stories
   - Data Requirements
   - Integration Requirements
   - Constraints & Assumptions
   - Risks & Mitigation

---

# BACKGROUND

## Executive Summary

**Kharisma Abadi** is a mature, multi-service business in Indonesia offering four core services:
- Car Wash (Cuci Mobil)
- Laundry Services (Laundry)
- Carpet Washing (Karpet)
- Drinking Water Delivery (Air Minum)

The current application, built with Flask (Python backend), Next.js 13 (React frontend), and MariaDB, has successfully served the business for **3+ years** with proven production stability. The system manages daily operations, employee tracking, customer data, and financial transactions with a database containing multiple years of critical business history.

### Current Situation

| Aspect | Details |
|--------|---------|
| **Operating Status** | Production (3+ years, actively in use) |
| **Data Volume** | 3+ years of transaction history preserved |
| **Daily Load** | 200-400 transactions/day |
| **Concurrent Users** | 2-4 cashiers per location |
| **Revenue Processed** | Millions of Rupiah monthly |
| **Critical Data** | Employee records, customer info, financial transactions |

### Why Rebuild?

The current system, while stable, has accumulated significant **technical debt** and faces **critical security gaps** that prevent:

1. **Scaling the business** - Current architecture cannot handle growth
2. **Adding features rapidly** - Changes require extensive refactoring
3. **Maintaining code** - New developers face steep learning curve
4. **Securing data** - Zero authentication, no access control
5. **Improving operations** - Limited visibility, automation gaps
6. **Modernizing infrastructure** - Outdated dependencies, security vulnerabilities

### Project Scope

| Element | Scope |
|---------|-------|
| **Timeline** | 5 months (20 weeks) |
| **Rebuild Scope** | Full application (backend + frontend) |
| **Data Scope** | 100% preservation of existing data |
| **Deployment** | Single-location initially, multi-location ready |
| **Downtime** | Minimal (1-2 hours for cutover) |

### Key Constraints

- **Database:** Must use existing MariaDB (data preservation critical)
- **Data:** All production data must be migrated with 100% integrity
- **Operations:** Business must continue during development
- **Team:** Likely small development team (2-3 developers)
- **Budget:** Cost-conscious (open-source stack preferred)

---

## Current State Analysis

### What Works Well ✅

**Proven Business Logic:**
- Car wash service with variable employee compensation (configurable per type)
- Laundry with item-level tracking and flexible pricing
- Water delivery subscription model for recurring revenue
- Employee income tracking and distribution

**Operational Strengths:**
- 3+ years of stable, uninterrupted production operation
- Clear separation of services (car wash, laundry, carpet, water)
- Transaction history preserved (valuable for analytics)
- Customer data tracked (water delivery customers)
- Multiple payment method support (cash, transfer, e-wallet)

**Technical Positives:**
- Clear API structure (57+ endpoints documented)
- Database schema well-designed with proper relationships
- Monorepo structure (backend + frontend together)
- Docker containerization for consistency

### What Needs Improvement ⚠️

**Critical Security Issues:**
- 🔴 **ZERO AUTHENTICATION** - No login system, no user identification
- 🔴 No role-based access control
- 🔴 No audit trail (who did what, when)
- 🔴 Complete data exposure to anyone with network access
- 🔴 Employee fraud risk (no verification)

**Architecture & Code Quality:**
- ⚠️ No service layer (business logic mixed in controllers)
- ⚠️ Direct SQL queries (no ORM, security risk)
- ⚠️ Hardcoded business rules (60/40 income split in code)
- ⚠️ No input validation or request sanitization
- ⚠️ Limited error handling and logging
- ⚠️ No automated testing (0% coverage)

**Performance & Scalability:**
- ⚠️ N+1 query problems (partially addressed)
- ⚠️ No caching layer (Redis, etc.)
- ⚠️ Large response payloads (unnecessary fields)
- ⚠️ No pagination on some endpoints
- ⚠️ Dashboard aggregates all transactions every request

**Feature Gaps:**
- ❌ No payment method tracking (cash vs transfer not recorded)
- ❌ No payment status tracking (paid, partial, unpaid)
- ❌ No refund mechanism
- ❌ No accounts receivable management
- ❌ No water delivery automation (manual creation needed)
- ❌ No customer portal or self-service
- ❌ No SMS/email notifications
- ❌ No inventory management

**Technical Debt:**
- ⚠️ Next.js 13 (2 major versions behind, approaching legacy)
- ⚠️ Flask 2.3.2 (security patches available in 3.x)
- ⚠️ Multiple MySQL connectors (redundant)
- ⚠️ No API documentation (Swagger/OpenAPI)
- ⚠️ No rate limiting
- ⚠️ No CORS restrictions (allows all origins)

### Comparison: Current vs. Desired State

| Dimension | Current ❌ | Desired ✅ |
|-----------|-----------|-----------|
| **Authentication** | None | JWT + Roles + Sessions |
| **Error Handling** | Minimal | Comprehensive with logging |
| **Testing** | 0% coverage | >80% coverage |
| **API Docs** | None | OpenAPI/Swagger (auto) |
| **Security** | Critical gaps | Industry standard |
| **Database** | Direct SQL | ORM (SQLAlchemy/Prisma) |
| **Code Style** | Inconsistent | Enforced (ESLint, Prettier) |
| **Maintainability** | Low | High (clean architecture) |
| **Scalability** | Limited | 5x current capacity |
| **DevOps** | Manual | Automated CI/CD |

---

## Problem Statement

The current Kharisma Abadi application, despite being production-proven and stable, faces several critical challenges that prevent the business from growing and modernizing operations.

### Core Problems

**1. CRITICAL SECURITY VULNERABILITY**
- **Problem:** Zero authentication system; anyone with network access can:
  - View all business data (transactions, customer info, employee records)
  - Modify any transaction (change prices, employee assignments)
  - Delete records
  - Manipulate financial data
- **Impact:** Fraud risk, regulatory non-compliance, data breach liability
- **Current Mitigation:** None (air-gapped network only)

**2. MAINTAINABILITY CRISIS**
- **Problem:** Code organization makes updates difficult:
  - Business logic scattered across controllers
  - No service layer abstraction
  - Direct SQL queries (no ORM)
  - Hardcoded business rules (60/40 split in code)
  - Mix of old patterns and inconsistent styles
- **Impact:** Slow feature delivery, high bug risk, onboarding difficulty
- **Example:** Adding new discount type requires code change + deployment

**3. SCALABILITY LIMITATIONS**
- **Problem:** Architecture cannot efficiently handle growth:
  - N+1 query problems remain in some areas
  - No caching layer
  - Dashboard aggregates all transactions on every request
  - No pagination on legacy endpoints
  - Single-instance deployment
- **Impact:** Performance degrades with data growth, user frustration
- **Projection:** Current system reaches limits at 2-3x current load

**4. MISSING CRITICAL FEATURES**
- **Problem:** Core business functions not tracked:
  - Payment methods not recorded (can't distinguish cash vs transfer)
  - Payment status not tracked (paid, partial, unpaid unknown)
  - No refund mechanism (disputes not manageable)
  - No accounts receivable (invoice tracking manual)
  - Water delivery requires manual ordering (no automation)
- **Impact:** Financial management gaps, operational inefficiency

**5. DEVELOPER EXPERIENCE**
- **Problem:** Difficult for new developers:
  - Inconsistent patterns and styles
  - Limited documentation
  - Complex setup process
  - Slow development cycles
  - No automated testing (manual QA required)
- **Impact:** Expensive onboarding, retention issues

**6. TECHNICAL DEBT ACCUMULATION**
- **Problem:** 3+ years of:
  - Outdated dependencies (security vulnerabilities)
  - Inconsistent architectural patterns
  - Accumulated "quick fixes"
  - Legacy code patterns
  - Missing modernization
- **Impact:** Increasing maintenance costs, higher bug risk

### Business Impact

| Problem | Business Impact | Urgency |
|---------|-----------------|---------|
| Security vulnerability | Fraud risk, data breach liability, compliance issues | CRITICAL |
| Limited scalability | Cannot grow beyond current capacity | HIGH |
| Slow feature delivery | Competitive disadvantage, lost opportunities | HIGH |
| Maintenance costs | Growing expenses, reduced profitability | MEDIUM |
| Staff frustration | Difficult workflows, slower operations | MEDIUM |

### Why Rebuild Instead of Fix?

**Option A: Incremental Improvement**
- ✅ Lower risk, continuous operation
- ✅ Can deliver improvements in weeks
- ❌ Technical debt remains
- ❌ Architecture limitations persist
- ❌ 6-12 months to fully modernize

**Option B: Complete Rebuild (RECOMMENDED)**
- ✅ Modern, clean architecture from start
- ✅ Eliminate all technical debt
- ✅ Future-proof for 5+ years
- ✅ Better long-term maintainability
- ❌ Higher initial risk
- ❌ 5-month development timeline

**Decision:** **Complete Rebuild** is optimal because:
1. Small codebase allows faster rebuild than incremental improvement
2. Provides opportunity to implement modern best practices
3. Better long-term cost and maintainability
4. Enables future growth without rearchitecting

---

## Stakeholders

### Stakeholder Analysis

| Role | Name/Title | Responsibilities | Success Criteria | Concerns |
|------|-----------|------------------|-----------------|----------|
| **Business Owner** | Management | Project approval, budget, final decisions | On-time delivery, cost control, data preservation | Timeline overrun, data loss |
| **Development Lead** | Lead Dev | Architecture, technical decisions, code quality | Clean codebase, maintainability, team productivity | Scope creep, unrealistic timeline |
| **Development Team** | 2-3 Devs | Implementation, testing, deployment | Clear requirements, good tools, reasonable timeline | Poor planning, changing requirements |
| **Operations Staff** | Cashiers, Service Staff | Daily operation, feedback | Easy interface, faster workflows, no learning curve | Unfamiliar workflows, feature loss |
| **Customers** | End Users | Service delivery | Uninterrupted service, improved experience | Service interruption, lost functionality |
| **IT/DevOps** | Infrastructure | Deployment, monitoring, backups | Reliable system, easy deployment, scalability | Downtime during deployment, performance issues |
| **Quality Assurance** | QA Team | Testing, validation, UAT | Clear test cases, feature completeness, quality | Aggressive timeline, unclear requirements |

### Stakeholder Engagement Plan

| Milestone | Stakeholders | Activity | Frequency |
|-----------|--------------|----------|-----------|
| **Week 1-2** | All | Project kickoff, requirements review | Once |
| **Week 2-4** | Dev Team + Lead | Architecture design sessions | Weekly |
| **Week 5-12** | Dev Team | Sprint planning & reviews | Bi-weekly |
| **Week 12-16** | QA + Operations | Testing & user feedback | Weekly |
| **Week 16-18** | Operations | UAT execution | Daily |
| **Week 18-20** | All | Deployment planning, final reviews | Weekly |

---

# MISSION

## Vision Statement

Build a **modern, secure, maintainable, and scalable** multi-service cashier system that:

- ✅ **Streamlines operations** for Kharisma Abadi staff with intuitive workflows
- ✅ **Provides excellent service** experience for customers
- ✅ **Enables rapid feature development** and business growth without rearchitecting
- ✅ **Preserves 100% of data** during migration with full integrity
- ✅ **Reduces long-term maintenance costs** through clean architecture
- ✅ **Follows industry best practices** and modern standards
- ✅ **Scales to support 5x growth** without performance degradation
- ✅ **Implements security by default** with authentication and access control

---

## Goals & Objectives

### Primary Goal 1: MAINTAINABILITY

**Objective:** Build code that is easy to understand, modify, and extend

**Key Requirements:**
- Clean architecture with clear separation of concerns (4 layers)
- Type safety throughout (TypeScript everywhere)
- Comprehensive inline and architecture documentation
- No code duplication (DRY principle)
- SOLID principles applied throughout
- Easy onboarding for new developers

**Success Metrics:**
- Code coverage >80% of critical paths
- Reduce time to implement new features by 50% (vs current)
- New developer productive within 1 week
- All code understandable without extensive comments

**Why:** Maintenance costs compound. Clean code reduces bugs and speeds feature development.

---

### Primary Goal 2: SECURITY

**Objective:** Implement security as a foundational requirement, not an afterthought

**Key Requirements:**
- JWT-based authentication with refresh tokens
- Role-based access control (ADMIN, MANAGER, CASHIER, VIEWER)
- Password hashing with bcrypt
- Input validation on all endpoints
- SQL injection prevention (via ORM)
- XSS protection (templating engine)
- HTTPS required in production
- Audit logging of all changes
- Rate limiting on sensitive endpoints

**Success Metrics:**
- Zero critical security vulnerabilities at launch
- 100% of endpoints require authentication
- All changes logged with user attribution
- Audit trail complete and retrievable

**Why:** Current system has ZERO authentication—an unacceptable security risk that must be addressed immediately.

---

### Primary Goal 3: PERFORMANCE

**Objective:** Deliver fast, responsive user experience with minimal latency

**Key Requirements:**
- API response time <200ms (p95)
- Page load time <2 seconds (p95)
- Database query time <100ms (p95)
- Handle 500+ concurrent users
- Optimized database queries (proper indexing, pagination)
- Efficient frontend rendering
- Asset caching and CDN ready

**Success Metrics:**
- Lighthouse score >80
- API response time measured and tracked
- Database queries profiled and optimized
- No N+1 query problems
- Achieves <2s page load in normal conditions

**Why:** Performance is a feature. Slow systems reduce staff productivity and frustrate users.

---

### Primary Goal 4: RELIABILITY & DATA INTEGRITY

**Objective:** Ensure 100% data integrity and system reliability

**Key Requirements:**
- 99.9% uptime SLA
- Automatic daily backups with verification
- Proper error handling and recovery
- Graceful degradation on failures
- Data validation at multiple layers
- Referential integrity constraints
- Transaction support for critical operations
- Zero data loss during migration

**Success Metrics:**
- No data loss events
- <1 hour downtime per month
- All transactions recorded accurately
- Daily successful backups verified
- Failed migration scenario = full rollback capability

**Why:** Business data is critical. Loss is unacceptable. Uptime ensures continuous operations.

---

### Primary Goal 5: SCALABILITY

**Objective:** Support business growth without rearchitecting

**Key Requirements:**
- Architecture supports 5x current transaction volume
- Horizontal scaling ready (stateless design)
- Database connection pooling
- Multi-location support ready (feature flag configurable)
- Efficient resource utilization
- Caching strategy (Redis ready)
- CDN ready for static assets

**Success Metrics:**
- Can handle 500+ concurrent users
- Can process 1000+ transactions per day
- Database grows to 10M records without degradation
- Response times remain consistent under load
- Can add new location without code changes

**Why:** Business growth should be celebrated, not feared. System must enable expansion.

---

### Primary Goal 6: USER EXPERIENCE

**Objective:** Provide intuitive, efficient workflows for staff and customers

**Key Requirements:**
- Mobile-responsive design (tablet/desktop)
- Consistent UI/UX patterns
- <3 clicks to complete common tasks
- Keyboard shortcuts for frequent operations
- Clear error messages and guidance
- Minimize training required
- Fast feedback on user actions

**Success Metrics:**
- <10% of operations require >3 clicks
- Staff completion time equals or improves current
- Training time reduced by 50%
- User satisfaction survey >4/5

**Why:** Staff frustration reduces productivity. Good UX makes everyone's job easier.

---

### Primary Goal 7: DATA MIGRATION

**Objective:** Preserve 100% of historical data with zero loss

**Key Requirements:**
- All existing data migrated successfully
- Schema mapping (old → new) documented
- Data validation scripts verify integrity
- Referential integrity maintained
- Migration tested on staging before production
- Rollback capability if issues detected
- Zero data loss during cutover

**Success Metrics:**
- 100% of data successfully migrated
- All relationships preserved
- Zero records lost
- Migration validation passes 100%
- Rollback tested and verified

**Why:** 3+ years of production data is valuable. Loss is unacceptable. This data tells business story.

---

## Success Criteria

### Must Have (P0) - Project Cannot Ship Without These

- ✅ All existing features replicated with **feature parity**
  - Every current workflow must work in new system
  - No functionality removed
  - Results match old system exactly
  
- ✅ **100% of data successfully migrated**
  - Zero records lost
  - All relationships maintained
  - Validation passes completely
  
- ✅ **Staff can perform all current operations**
  - All daily workflows supported
  - No missing features blocking operations
  - Performance meets or exceeds current
  
- ✅ **System passes UAT (User Acceptance Testing)**
  - Operations staff validates workflows
  - Staff signs off on functionality
  - No critical blockers identified
  
- ✅ **Performance meets or exceeds current system**
  - Response times <200ms API, <2s page load
  - No performance degradation
  - Metrics tracked and verified
  
- ✅ **Zero critical security vulnerabilities at launch**
  - OWASP top 10 not present
  - Authentication works correctly
  - Authorization enforced on all endpoints
  
- ✅ **No critical bugs at launch**
  - Core functionality tested thoroughly
  - Known issues logged (not blockers)
  - Data integrity verified
  
- ✅ **Clean cutover with minimal downtime**
  - Downtime <2 hours maximum
  - No data loss during migration
  - Rollback procedure tested

### Should Have (P1) - Improves System, Can Deploy Without

- 🎁 **Improved UX/UI** based on user feedback
  - More intuitive layouts
  - Better visual design
  - Improved workflows
  
- 🎁 **Enhanced reporting capabilities**
  - Employee performance metrics
  - Service quality tracking
  - Customer lifetime value
  - Advanced analytics
  
- 🎁 **Mobile-responsive design**
  - Works on tablets
  - Works on mobile screens
  - Touch-friendly interfaces
  
- 🎁 **Automated backup and monitoring**
  - Daily automatic backups
  - Health monitoring
  - Alert system for issues

### Nice to Have (P2) - Future Enhancements

- ⭐ Mobile app for drivers (iOS/Android)
- ⭐ Customer portal (self-service ordering)
- ⭐ Advanced analytics dashboard
- ⭐ Multi-language support
- ⭐ API for third-party integrations
- ⭐ SMS/email notifications
- ⭐ Loyalty program features

---

## Non-Goals

**The following are explicitly OUT OF SCOPE for this project:**

### Phase 1 (Initial Release)

- ❌ **Mobile native applications** (web-based only)
- ❌ **E-commerce/online ordering** (staff-facing system)
- ❌ **CRM features** (customer relationship management)
- ❌ **Loyalty program management** (business decision needed first)
- ❌ **Multi-tenant support** (single business instance)
- ❌ **Franchise management** (not needed for single location)
- ❌ **Complex inventory management** (basic water stock only)
- ❌ **HR/Payroll system** (only tracks employee income)
- ❌ **Accounting module** (financial tracking, not accounting)
- ❌ **Supply chain management** (beyond scope)

### Rationale

These features:
- Would significantly extend timeline (3-4 months → 6-8 months)
- Add complexity without critical business value
- Can be added post-launch based on actual needs
- Would increase project risk substantially

### Post-Launch Roadmap

These features are planned for **Phase 2** (future):
- Mobile apps for drivers and customers
- Customer self-service portal
- Advanced analytics and reporting
- Integration with payment gateways
- SMS/email notification system
- Multi-location support

---

# APPROACH

## Development Methodology

### Philosophy

"**Done Right is Better Than Done Fast**"

We prioritize code quality, maintainability, and data safety over speed. This protects the business long-term.

### Agile Development Framework

**Methodology:** Agile with 2-week sprints

**Why 2-week sprints?**
- Provides regular feedback loops
- Allows quick course correction
- Maintains team momentum
- Enables early issue detection
- Creates predictable delivery schedule

### Project Timeline

**Total Duration:** 5 months (20 weeks) / ~1200 hours

| Phase | Duration | Focus | Deliverables |
|-------|----------|-------|--------------|
| **1. Analysis & Planning** | 2 weeks | Requirements, architecture design | Detailed spec, architecture docs |
| **2. Architecture & Setup** | 2 weeks | Dev environment, infrastructure | Scaffolded project, CI/CD pipeline |
| **3. Backend Dev (Sprint 1-2)** | 4 weeks | Core APIs, database layer | 80% of backend features |
| **4. Frontend Dev (Sprint 3-4)** | 4 weeks | UI/UX, integrations, forms | 80% of frontend features |
| **5. Integration & Testing** | 3 weeks | E2E testing, bug fixes | Integrated system, test coverage |
| **6. Data Migration** | 1 week | Schema mapping, migration scripts | Migrated production data |
| **7. UAT & Refinement** | 2 weeks | User testing, final adjustments | Approved by operations |
| **8. Deployment & Handoff** | 1 week | Production deployment, training | Live system, staff trained |
| **9. Buffer/Contingency** | 1 week | Unexpected issues | Risk mitigation |

### Sprint Structure

**Each 2-week sprint includes:**

**Week 1:**
- Sprint planning (Monday, 2 hours)
- Daily standups (10 min each)
- Development work (32 hours)
- Internal testing

**Week 2:**
- Continued development (16 hours)
- Sprint review/demo (Thursday, 2 hours)
- Sprint retrospective (Friday, 1 hour)
- Stakeholder feedback incorporation

### Team Structure

**Recommended Team:**
- **Development Lead** - Architecture, technical decisions (1 person)
- **Backend Developer** - API, database, business logic (1 person)
- **Frontend Developer** - UI, user experience (1 person)
- **QA/Tester** - Testing, quality assurance (0.5 person)

**Total:** 3.5 FTE (Full-Time Equivalents)

### Communication Plan

**Daily:**
- Morning standup (10 min) - What did you do, what's next, blockers?

**Weekly:**
- Sprint planning (Monday, 2h)
- Sprint review (Thursday, 2h)
- Retrospective (Friday, 1h)
- Stakeholder sync (Friday, 1h) - Business owner, operations lead

**Every 2 weeks:**
- Steering committee meeting - Overall progress, risks, decisions

### Risk Management

**Development Risks:**
- Scope creep → Weekly sprint commitments, change control
- Timeline delay → Buffer week built in, MVP approach
- Technical blockers → Spike investigation, architecture reviews
- Staff turnover → Documentation, pair programming

**Mitigation Strategy:**
- Weekly risk assessment
- Early issue escalation
- Architecture reviews on risky areas
- Backup developers trained on critical paths

---

## Technology Stack
**FOR BACKEND AND FRONTEND, REFER TO `docs/planning/technical-architecture-go.md` FOR LAST UPDATE**
### Backend Stack

**Language & Runtime:**
- **Python 3.11+** (mature, readable, good for business logic)
- OR **Node.js 18+ with TypeScript** (if team prefers JavaScript)
- **Recommendation:** Python with FastAPI (best balance of simplicity and performance)

**Framework:**
- **FastAPI** (Python) - Modern, fast, automatic API docs
- OR **NestJS** (Node.js) - Enterprise-grade, TypeScript-native
- **Recommendation:** FastAPI for simplicity, NestJS for scale

**Database ORM:**
- **SQLAlchemy** (Python) - Mature, flexible, powerful
- OR **Prisma** (Node.js) - Modern, type-safe, migration tools
- **Recommendation:** SQLAlchemy for complex queries, Prisma for developer experience

**API Documentation:**
- **OpenAPI 3.0 / Swagger** (auto-generated from code)
- Provides interactive API explorer for testing

**Input Validation:**
- **Pydantic** (Python) - Declarative validation
- OR **Zod** (Node.js) - Type-safe validation
- **Recommendation:** Pydantic for simplicity

**Authentication & Authorization:**
- **JWT (JSON Web Tokens)** - Industry standard
- **Refresh tokens** - Extended sessions
- **Role-based Access Control (RBAC)** - ADMIN, MANAGER, CASHIER, VIEWER

**Password Security:**
- **bcrypt** - Cryptographic password hashing
- **Python:** `python-multipart`, `passlib`
- **Node.js:** `bcryptjs` or `argon2`

**Testing:**
- **Pytest** (Python) - Comprehensive testing framework
- OR **Jest** (Node.js) - Popular testing library
- **Target:** >80% code coverage

**Code Quality:**
- **Black** (Python) - Code formatter
- **Flake8** (Python) - Linting
- **MyPy** (Python) - Type checking
- **ESLint & Prettier** (if using Node.js)

**Environment & Config:**
- **Python Dotenv** - Environment variable management
- **Pydantic Settings** - Type-safe configuration

---

### Frontend Stack

**Framework:**
- **Next.js 14+** with **App Router** (latest, modern patterns)
- **React 18.2+** (UI library)
- **TypeScript 5+** (type safety)

**Styling:**
- **Tailwind CSS 3+** (utility-first, highly maintainable)
- **shadcn/ui** (pre-built accessible components)
- **Emotion or Styled Components** (CSS-in-JS if needed)

**State Management:**
- **Zustand** (lightweight, simple) OR
- **React Query** (for server state)
- **Context API** (for simple app state)
- **Recommendation:** Zustand + React Query (modern approach)

**Forms & Validation:**
- **React Hook Form** (lightweight, performant)
- **Zod** (type-safe schema validation)
- Pair provides excellent DX

**API Client:**
- **Auto-generated from OpenAPI** (using tools like `openapi-generator`)
- OR **Axios** (simple, reliable HTTP client)
- **Recommendation:** Auto-generated for type safety

**Testing:**
- **Vitest** (modern, fast test runner)
- **Testing Library** (test behavior, not implementation)
- **Playwright** (E2E testing)
- **Target:** >80% code coverage

**Code Quality:**
- **ESLint** (JavaScript linting)
- **Prettier** (code formatting)
- **Pre-commit hooks** (Husky + lint-staged)
- **Commitizen** (structured commit messages)

---

### Database

**Primary Database:**
- **MariaDB 10.4+** or **MySQL 8.0+** (existing, proven)
- **Reason:** Preserve existing production data, no migration to new DB engine

**Migration Tool:**
- **Alembic** (Python) - Version-controlled schema changes
- OR **Prisma Migrate** (Node.js) - Declarative migrations
- **Recommendation:** Alembic (mature, flexible)

**Connection Management:**
- **Connection pooling** - SQLAlchemy connection pool
- **Config:** Min 5, Max 20 connections per instance
- **Timeout:** 30 seconds idle timeout

**Backups:**
- **Daily automated backups** (via database tools or scripts)
- **Backup retention:** 30 days
- **Location:** Cloud storage (GCS, S3, or local)
- **Verification:** Weekly restore testing

---

### DevOps & Infrastructure

**Version Control:**
- **Git** (GitHub, GitLab, or Gitea)
- **Branching:** Git flow (main, develop, feature branches)
- **Commit conventions:** Conventional commits (feat:, fix:, docs:)

**CI/CD Pipeline:**
- **GitHub Actions** (free, integrated)
- **Automated triggers:**
  - Run tests on every PR
  - Build Docker images on merge to main
  - Deploy to staging on develop push
  - Deploy to production on main push (manual approval)

**Containerization:**
- **Docker** (containers for consistency)
- **Docker Compose** (local development, orchestration)
- **Images:**
  - Backend image (~500MB)
  - Frontend image (~200MB)
  - No code in image (environment configured)

**Deployment:**
- **Docker Compose** (for small deployments)
- OR **Kubernetes** (if scaling needed)
- **Recommendation:** Start with Docker Compose, migrate to K8s later

**Monitoring & Logging:**
- **Structured logging** (JSON format, centralized)
- **Log retention:** 90 days
- **Monitoring tools:** 
  - Simple: Server health + disk space checks
  - Advanced: ELK stack or CloudWatch

**Environment Management:**
- **Development** - Local machines
- **Staging** - Production-like for testing
- **Production** - Live system

---

### Development Tools & Environment

**Monorepo Structure:**
```
kharisma-abadi/
├── backend/              # FastAPI or NestJS application
│   ├── app/              # Application code
│   ├── tests/            # Test files
│   ├── migrations/       # Database migrations
│   └── requirements.txt  # Python dependencies
├── frontend/             # Next.js application
│   ├── src/              # Source code
│   ├── tests/            # Test files
│   └── package.json      # NPM dependencies
├── docs/                 # Documentation
└── docker-compose.yml    # Local development setup
```

**Package Management:**
- **Backend:** pip (Python) with virtual environments
- **Frontend:** npm or pnpm (Node.js)
- **Lock files:** Commit lock files (requirements.txt, package-lock.json)

**Local Development Setup:**
```bash
# One-time setup
git clone <repo>
docker-compose up -d    # Start database, cache, etc.
cd backend && pip install -r requirements.txt
cd ../frontend && npm install

# Daily development
docker-compose up -d
npm run dev             # Frontend
python -m uvicorn app.main:app --reload  # Backend
```

**Target:** <10 minutes from clone to working development environment

---

### Recommended Stack Summary

| Component | Choice | Reason |
|-----------|--------|--------|
| **Language (BE)** | Python 3.11 | Readable, mature, good for business logic |
| **Framework (BE)** | FastAPI | Modern, fast, auto-documentation |
| **ORM (BE)** | SQLAlchemy | Powerful, flexible, mature |
| **Language (FE)** | TypeScript | Type safety, better DX |
| **Framework (FE)** | Next.js 14 | Latest, modern, SSR ready |
| **Styling (FE)** | Tailwind + shadcn/ui | Maintainable, accessible, fast |
| **Database** | MariaDB 10.4+ | Existing, proven, minimal migration |
| **CI/CD** | GitHub Actions | Free, integrated, sufficient |
| **Containers** | Docker + Compose | Standard, reproducible |
| **Testing (BE)** | Pytest | Comprehensive, good coverage |
| **Testing (FE)** | Vitest + Testing Library | Modern, fast, behavior-focused |

---

## Architecture Approach

### Architecture Pattern: Clean Architecture (Hexagonal)

**Philosophy:** "Entities must be testable in isolation"

Organize code into layers with clear dependencies flowing inward:

```
┌───────────────────────────────────────────┐
│      Presentation Layer (REST API)        │  Handles HTTP, converts to/from DTOs
├───────────────────────────────────────────┤
│      Application Layer (Use Cases)        │  Orchestrates business logic
├───────────────────────────────────────────┤
│      Domain Layer (Entities & Rules)      │  Pure business logic, frameworks-agnostic
├───────────────────────────────────────────┤
│    Infrastructure Layer (DB, External)    │  Database, external APIs, services
└───────────────────────────────────────────┘

        ↓ Dependency Direction ↓
        (Inner layers independent of outer)
```

### Layer Responsibilities

**Presentation Layer:**
- HTTP request/response handling
- Input validation (basic)
- Response formatting
- Error translation to HTTP codes
- **Must not:** Contain business logic

Example structure:
```
backend/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── carwash.py      # Car wash endpoints
│   │   │   ├── laundry.py      # Laundry endpoints
│   │   │   ├── water.py        # Water delivery endpoints
│   │   │   └── auth.py         # Authentication endpoints
│   │   └── schemas/            # Request/response models (Pydantic)
│   │       ├── carwash.py
│   │       └── common.py
```

**Application Layer:**
- Use cases / business workflows
- Coordinates domain entities and services
- Manages transactions
- Exception handling
- Logging
- **Must not:** Know about frameworks or HTTP

Example:
```
backend/
├── app/
│   ├── usecases/
│   │   ├── carwash/
│   │   │   ├── create_order.py
│   │   │   ├── complete_service.py
│   │   │   └── calculate_income.py
```

**Domain Layer:**
- Core business entities (CarWash, Laundry, Customer)
- Business rules and validations
- Pure business logic (no frameworks)
- Value objects
- **Only:** Depends on itself

Example:
```
backend/
├── app/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── carwash.py
│   │   │   ├── employee.py
│   │   │   └── payment.py
│   │   ├── value_objects/
│   │   │   └── money.py
│   │   └── exceptions.py
```

**Infrastructure Layer:**
- Database access (repositories)
- External service integration
- Frameworks and libraries
- Configuration
- **Purpose:** Abstract all external concerns

Example:
```
backend/
├── app/
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── repositories/
│   │   │   │   ├── carwash_repo.py
│   │   │   │   └── employee_repo.py
│   │   │   └── models.py   # SQLAlchemy models
│   │   ├── external/
│   │   │   └── sms_gateway.py
│   │   └── config.py
```

### Design Principles

**SOLID Principles:**

**S - Single Responsibility**
- Each class/function has one reason to change
- Example: `CarWashService` only handles car wash logic

**O - Open/Closed**
- Classes open for extension, closed for modification
- Use inheritance, composition, and plugins

**L - Liskov Substitution**
- Derived classes replaceable for base classes
- Interface contracts respected

**I - Interface Segregation**
- Many client-specific interfaces better than one general
- Don't force clients to depend on interfaces they don't use

**D - Dependency Inversion**
- High-level modules don't depend on low-level modules
- Both depend on abstractions
- Inject dependencies rather than creating them

**DDD - Domain-Driven Design:**
- Organize code around business domains
- Use ubiquitous language (business terms)
- Separate domain logic from infrastructure
- Services represent business transactions

### Dependency Injection

**Pattern:** Inject dependencies rather than creating them

**Benefits:**
- Testable (inject mocks)
- Loosely coupled
- Configuration centralized
- Easy to replace implementations

**Example (Python with FastAPI):**
```python
from fastapi import Depends

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/carwash/orders")
async def create_carwash_order(
    request: CreateCarWashRequest,
    db: Session = Depends(get_db),
    auth: AuthService = Depends(get_auth_service)
):
    # Dependencies injected, easy to test
    pass
```

### Testing Strategy

**Unit Tests:**
- Test individual functions/classes in isolation
- Use mocks for dependencies
- Fast execution (<100ms per test)
- High coverage target (>85%)

**Integration Tests:**
- Test multiple layers together
- Use test database (SQLite in memory)
- Test API endpoints end-to-end
- Coverage target (>70%)

**E2E Tests:**
- Test complete user workflows
- Use browser automation (Playwright)
- Test against staging environment
- Coverage target (critical paths, >80%)

**Testing Pyramid:**
```
     ╱╲         E2E Tests (5%)
    ╱  ╲        Few, slow, valuable
   ╱────╲
  ╱      ╲      Integration Tests (15%)
 ╱────────╲     Some, medium speed
╱          ╲
╱────────────╲   Unit Tests (80%)
              Lots, fast, focused
```

---

## Migration Strategy

### Data Migration Approach

The existing 3+ years of production data must be migrated with 100% integrity. This is critical to business continuity.

### Phase 1: Schema Analysis & Mapping

**1.1 Analyze Current Schema**
- Document all tables, columns, types
- Identify relationships, constraints
- Find data quirks or inconsistencies
- Estimate data volume

**1.2 Design New Schema**
- Map old tables → new tables
- Identify data transformations needed
- Plan for new features
- Maintain backward compatibility where possible

**1.3 Create Migration Mapping Document**
```
Old Table          → New Table    | Transformation
───────────────────────────────────────────────
carwash_types      → ServiceType  | Direct copy
carwash_transactions → CarWashOrder | Add status field (default: COMPLETED)
carwash_employees  → OrderAssignment | Direct copy
employees          → Employee    | Add is_active=true
drinking_water_customers → Customer | Direct copy
```

### Phase 2: Migration Scripts Development

**2.1 Extract Phase**
```python
# Extract data from old database
def extract_carwash_types():
    with old_db.connection():
        return db.execute("SELECT * FROM carwash_types").fetchall()
```

**2.2 Transform Phase**
```python
# Transform data to new schema
def transform_carwash_types(old_data):
    return [
        ServiceType(
            id=row.carwash_type_id,
            name=row.name,
            price=row.price,
            is_active=True,  # NEW field
            created_at=row.created_at,
            updated_at=row.updated_at
        )
        for row in old_data
    ]
```

**2.3 Load Phase**
```python
# Load data into new database
def load_carwash_types(new_data):
    with new_db.session():
        new_db.add_all(new_data)
        new_db.commit()
```

**2.4 Validation Phase**
```python
# Validate migrated data
def validate_carwash_types():
    old_count = old_db.execute("SELECT COUNT(*) FROM carwash_types").scalar()
    new_count = new_db.execute(
        select(func.count(ServiceType.id))
    ).scalar()
    assert old_count == new_count, "Data mismatch!"
    
    # Compare sample rows
    assert compare_sample_rows(old_db, new_db)
```

### Phase 3: Test Migration

**3.1 Staging Environment**
- Restore production database backup to staging
- Run full migration on staging
- Validate all data
- Test application against migrated data
- Measure performance

**3.2 Rollback Testing**
- Practice full rollback procedure
- Verify backup restore works
- Document exact steps
- Train team on recovery procedure

**3.3 Migration Checklist**
```
□ Source database backed up
□ Target database ready
□ Migration scripts written and tested
□ Validation scripts written
□ Rollback procedure documented
□ Team trained on procedure
□ Maintenance window scheduled
□ Communication sent to stakeholders
```

### Phase 4: Production Migration

**4.1 Pre-Migration**
- Announce maintenance window (24h notice)
- Final backup of production database
- Stop all applications accessing database
- Verify backup integrity

**4.2 Migration Execution**
- Run extract phase
- Run transform phase  
- Run load phase
- Run validation phase

**4.3 Post-Migration**
- Start new application pointing to migrated data
- Monitor for errors (first hour critical)
- Keep old database available for 24h (emergency rollback)
- Run final validation checks
- Communicate success to stakeholders

### Migration Timeline

| Step | Duration | Timing | Notes |
|------|----------|--------|-------|
| 1. Schema analysis | 2 days | Week 16 | Document all mapping |
| 2. Migration scripts | 3 days | Week 16 | Develop and test |
| 3. Staging test | 2 days | Week 17 | Full validation run |
| 4. Rollback test | 1 day | Week 17 | Practice recovery |
| 5. Production prep | 1 day | Week 18 | Final checks |
| 6. Maintenance window | 2-4 hours | Week 18 | Execute migration |
| 7. Monitoring | Ongoing | Week 18+ | Watch for issues |

### Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Data loss during migration** | Low | Critical | Multiple backups, validation at each step, rollback capability |
| **Corrupted data migrated** | Low | Critical | Validation scripts, sample comparison, staging test |
| **Performance degraded** | Medium | High | Index verification, query optimization, load testing |
| **Application incompatibility** | Low | High | Thorough testing, staging validation |
| **Rollback unsuccessful** | Very Low | Critical | Practice rollback, keep old DB available |

### Success Criteria

- ✅ 100% of data successfully migrated
- ✅ All relationships maintained (zero referential integrity violations)
- ✅ Validation scripts pass 100%
- ✅ Application functions correctly with migrated data
- ✅ Performance metrics achieved
- ✅ Zero data loss
- ✅ Rollback procedure verified (practiced)

---

# DETAILS

## Functional Requirements

### FR-001: Authentication & Authorization

**Priority:** P0 (CRITICAL - Project cannot ship without)

**Description:** Users must authenticate before accessing system. Different roles have different permissions.

**Requirements:**
- JWT-based authentication
- Support roles: ADMIN, MANAGER, CASHIER, VIEWER
- Sessions timeout after 1 hour
- Password minimum 12 characters
- Password hashing with bcrypt
- Account lockout after 5 failed attempts
- Session token refresh capability

**Acceptance Criteria:**
- User cannot access any protected endpoint without valid token
- Invalid credentials rejected immediately
- Session expires after 1 hour
- Token refresh extends session
- Passwords hashed before storage
- Account lockout works correctly
- Logout clears token

**API Endpoints:**
```
POST /api/auth/login                 # Login with username/password
POST /api/auth/logout                # Logout (clear token)
POST /api/auth/refresh               # Refresh access token
GET  /api/auth/me                    # Get current user info
```

**Testing:**
- Unit tests for authentication logic
- Integration tests for API endpoints
- E2E tests for login/logout workflow
- Security tests for SQL injection, brute force

---

### FR-002: Role-Based Access Control (RBAC)

**Priority:** P0 (CRITICAL)

**Description:** Different users have different permissions based on roles.

**Roles & Permissions:**

| Endpoint/Action | ADMIN | MANAGER | CASHIER | VIEWER |
|-----------------|-------|---------|---------|--------|
| **Create transaction** | ✅ | ✅ | ✅ | ❌ |
| **View transactions** | ✅ | ✅ | ✅ | ✅ |
| **Edit transaction** | ✅ | ✅ | ✅ | ❌ |
| **Delete transaction** | ✅ | ✅ | ❌ | ❌ |
| **Approve refund >Rp50k** | ✅ | ✅ | ❌ | ❌ |
| **Approve refund >Rp500k** | ✅ | ❌ | ❌ | ❌ |
| **View income reports** | ✅ | ✅ | Limited | Limited |
| **View financial reports** | ✅ | ✅ | ❌ | ❌ |
| **Manage service types** | ✅ | ✅ | ❌ | ❌ |
| **Manage employees** | ✅ | ✅ | ❌ | ❌ |
| **Manage users** | ✅ | ❌ | ❌ | ❌ |
| **View audit log** | ✅ | Limited | ❌ | ❌ |
| **System configuration** | ✅ | ❌ | ❌ | ❌ |

**Acceptance Criteria:**
- Users cannot access endpoints beyond their role
- 403 Forbidden returned for unauthorized access
- Permissions consistent across API
- Audit log records permission denials

---

### FR-003: Car Wash Service Management

**Priority:** P0 (Core business function)

**Description:** Full workflow for car wash orders from creation to completion.

**Requirements:**

**FR-003.1: Service Type Management**
- Create/read/update/delete car wash types
- Each type has: name, base price, vehicle type multiplier, employee cut info
- Admin/Manager can manage types
- Cashier can view types

**FR-003.2: Order Creation**
- Cashier creates order with:
  - Vehicle type (motorcycle, sedan, SUV, truck, bus)
  - Service type selection
  - License plate (optional)
  - Phone number (optional)
  - Employee assignment (1+ employees)
- System calculates price based on vehicle type multiplier
- System divides employee cut equally
- Order created with status=PENDING

**FR-003.3: Queue Management**
- Display current queue
- FIFO ordering by default
- Assign orders to service bays
- Update status to IN_PROGRESS
- Show estimated wait time

**FR-003.4: Service Completion**
- Mark service complete (status=COMPLETED)
- Record completion date/time
- Trigger income calculation
- Generate receipt

**FR-003.5: Income Distribution**
- Calculate employee cuts based on type configuration
- Support fixed amount OR percentage
- Divide equally among assigned employees
- Handle precision (no remainder Rupiah lost)
- Record final distribution

**Acceptance Criteria:**
- All fields validated
- Order created successfully
- Calculations accurate (tested against current system)
- Income distributed correctly
- Status transitions valid
- Audit trail recorded

**API Endpoints:**
```
GET    /api/car-wash/types
POST   /api/car-wash/types
GET    /api/car-wash/types/:id
PUT    /api/car-wash/types/:id
DELETE /api/car-wash/types/:id

POST   /api/car-wash/orders
GET    /api/car-wash/orders
GET    /api/car-wash/orders/:id
PUT    /api/car-wash/orders/:id
DELETE /api/car-wash/orders/:id

PUT    /api/car-wash/orders/:id/complete
GET    /api/car-wash/queue
```

---

### FR-004: Laundry Service Management

**Priority:** P0 (Core business function)

**Description:** Full workflow for laundry orders with item-level tracking.

**Requirements:**

**FR-004.1: Item Type Management**
- Create/read/update/delete item types
- Each type has: name, price, unit (pcs, kg, lusin, m, m2)
- Items with unit "m" or "m2" classified as carpet
- Items with other units classified as laundry

**FR-004.2: Order Creation**
- Cashier creates order with:
  - Customer name (optional)
  - Phone number (optional)
  - Item list (1+ items with quantities)
- System calculates price for each item: item.price × quantity
- System calculates total: sum of all item prices
- Cashier can adjust final_price (optional):
  - If higher: extra charge added to first item
  - If lower: discount subtracted sequentially from items
  
**FR-004.3: Price Adjustment Algorithm**
- Extra charge (final_price > total_price):
  - adjustment = final_price - total_price
  - items[0].price += adjustment
  
- Discount (final_price < total_price):
  - FOR EACH item:
  -   reduction = MIN(ABS(remaining_discount), item.price)
  -   item.price -= reduction
  -   remaining_discount -= reduction
  
- Can zero out items if discount exceeds item price

**FR-004.4: Income Distribution**
- Fixed 60/40 split: 60% business, 40% employee/overhead
- NOT distributed to individual employees (salary-based)
- Recorded as global expense in income tracking

**FR-004.5: Service Completion**
- Mark complete when items ready
- Record completion date
- Trigger income calculation
- Generate receipt

**Acceptance Criteria:**
- Price calculations match current system exactly
- Adjustment algorithm works correctly
- Income split accurate
- Laundry vs carpet classification correct
- Status transitions valid

**API Endpoints:**
```
GET    /api/laundry/types
POST   /api/laundry/types
GET    /api/laundry/orders
POST   /api/laundry/orders
GET    /api/laundry/orders/:id
PUT    /api/laundry/orders/:id
DELETE /api/laundry/orders/:id
PUT    /api/laundry/orders/:id/complete

GET    /api/carpet/types          # Filtered types (unit in m, m2)
GET    /api/carpet/orders         # Filtered orders (has carpet items)
```

---

### FR-005: Water Delivery Service

**Priority:** P0 (Core business function)

**Description:** Customer registration and delivery management.

**Requirements:**

**FR-005.1: Customer Registration**
- Cashier registers new customer:
  - Full name (required)
  - Address (required)
  - Phone number (optional)
- System validates address within service area
- Customer record created and can be reused

**FR-005.2: Delivery Ordering**
- Select customer (registered or walk-in)
- Select water type and quantity
- System calculates price: quantity × type.price
- Specify payment method: PREPAID, COD, INVOICE
- Order created

**FR-005.3: Income Recording**
- 100% of revenue to business (no employee cut)
- Recorded immediately when delivered

**FR-005.4: Delivery Execution**
- Mark delivered with completion date
- Record payment collected (if COD)
- Include in income calculations

**Acceptance Criteria:**
- Customer registration successful
- Delivery orders created correctly
- Income calculated and recorded
- Payment tracking accurate

**API Endpoints:**
```
GET    /api/water/customers
POST   /api/water/customers
GET    /api/water/customers/:id
PUT    /api/water/customers/:id

GET    /api/water/types
POST   /api/water/types

POST   /api/water/orders
GET    /api/water/orders
GET    /api/water/orders/:id
PUT    /api/water/orders/:id/complete
```

---

### FR-006: Payment Processing

**Priority:** P0 (Financial critical)

**Description:** Record and manage payments for all services.

**Requirements:**

**FR-006.1: Payment Method Tracking**
- Record payment method for each transaction:
  - CASH
  - TRANSFER (bank transfer)
  - E_WALLET (OVO, GoPay, Dana)
  - CARD (credit/debit)
  - INVOICE (monthly billing)

**FR-006.2: Payment Status**
- Track status:
  - UNPAID (zero payment received)
  - PARTIAL (part of amount received)
  - PAID (full amount received)
  - REFUNDED (refund issued)
  - OVERDUE (invoice past due)

**FR-006.3: Cash Drawer Management**
- Track cash in/out throughout day
- Opening and closing balance
- Reconciliation: expected vs actual
- Identify variance

**FR-006.4: Refund Processing**
- Create refund for transaction
- Record reason
- Update payment status
- Adjust income calculations

**FR-006.5: Accounts Receivable**
- Track unpaid invoices
- Show aging (current, 30+ days, 60+ days)
- Payment reminders
- Send follow-up notifications

**Acceptance Criteria:**
- Payment methods recorded correctly
- Status tracking accurate
- Cash drawer balances
- Refunds processed successfully
- AR reports accurate

**API Endpoints:**
```
POST   /api/payments
GET    /api/payments
GET    /api/payments/:id
PUT    /api/payments/:id

GET    /api/cash-drawer/balance
POST   /api/cash-drawer/open
POST   /api/cash-drawer/close
POST   /api/cash-drawer/reconcile

GET    /api/reports/accounts-receivable
GET    /api/reports/cash-flow
```

---

### FR-007: Employee Management

**Priority:** P0 (Payroll critical)

**Description:** Manage employees and track earnings.

**Requirements:**

**FR-007.1: Employee CRUD**
- Create/read/update/delete employee records
- Fields: name, phone number, hire date, status

**FR-007.2: Income Tracking**
- Track income per employee per transaction
- Calculated based on service type and employee cut configuration
- Distributed equally among assigned employees

**FR-007.3: Income Reports**
- Daily employee earnings
- Monthly employee earnings
- Date range summaries
- Year-to-date totals

**Acceptance Criteria:**
- Employee records managed correctly
- Income calculated and tracked
- Reports match calculations
- Edits logged for audit

**API Endpoints:**
```
GET    /api/employees
POST   /api/employees
GET    /api/employees/:id
PUT    /api/employees/:id
DELETE /api/employees/:id

GET    /api/reports/employee-income
GET    /api/reports/employee-income/:id
POST   /api/reports/employee-income/date-range
```

---

### FR-008: Reporting & Analytics

**Priority:** P1 (Important for business intelligence)

**Description:** Dashboard and detailed reports for business analysis.

**Requirements:**

**FR-008.1: Income Dashboard**
- Today's income (all services)
- This month's income (all services)
- This year's income (all services)
- All-time total income
- Breakdown by service type

**FR-008.2: Chart Reports**
- Monthly view (12-month trend)
- Daily view (30-day breakdown)
- Service type breakdown (pie chart)
- Year-over-year comparison (future)

**FR-008.3: Custom Reports**
- Date range filtering
- Service type filtering
- Employee filtering
- Export to CSV/PDF

**FR-008.4: Advanced Analytics (Phase 2)**
- Employee performance metrics
- Service quality metrics
- Customer lifetime value
- Forecasting

**Acceptance Criteria:**
- Dashboard loads quickly
- Numbers match calculations
- Reports accurate
- Export working

**API Endpoints:**
```
GET    /api/reports/income-summary
POST   /api/reports/income-by-date
GET    /api/reports/monthly-breakdown
GET    /api/reports/service-breakdown

GET    /api/dashboard
GET    /api/dashboard/today
GET    /api/dashboard/this-month
GET    /api/dashboard/this-year
GET    /api/dashboard/charts
```

---

### FR-009: Audit Logging

**Priority:** P0 (Compliance & security)

**Description:** Record all changes for accountability and security.

**Requirements:**

**FR-009.1: Audit Trail**
- Record every change:
  - Who (user ID, username)
  - What (transaction ID, fields changed)
  - When (timestamp)
  - Old and new values
  - IP address

**FR-009.2: Audit Log Access**
- Admin can view all audit logs
- Manager can view limited logs (their actions)
- 90-day retention

**Acceptance Criteria:**
- All changes logged
- Logs accurate and complete
- Security properly controlled
- Can investigate changes

**API Endpoints:**
```
GET    /api/admin/audit-log
GET    /api/admin/audit-log/:id
POST   /api/admin/audit-log/search
```

---

## Non-Functional Requirements

### NFR-001: Performance

**Requirement:** API responses must be fast and page loads must be responsive

**Specifications:**
- **API response time:** <200ms (p95 - 95th percentile)
  - Measured under normal load
  - Includes database query + processing
  - Excludes network latency
  
- **Page load time:** <2 seconds (p95)
  - Time to interactive
  - From user clicks until UI responsive
  
- **Database query:** <100ms (p95)
  - Query execution time only
  - Measured with proper indexing
  
- **Concurrent users:** Support 500+
  - Simultaneous logged-in users
  - Without performance degradation

**How to Achieve:**
- Proper database indexing
- Query optimization (no N+1)
- API response pagination (large result sets)
- Caching where appropriate
- Frontend optimization (code splitting, lazy loading)
- Load testing and profiling

**Monitoring:**
- Track response time percentiles (p50, p95, p99)
- Alert if p95 > 300ms
- Regular load testing (simulated 500 concurrent users)

**Success Criteria:**
- No response > 500ms under normal load
- Dashboard loads <2s consistently
- Page navigations feel instant
- No user complaints about slowness

---

### NFR-002: Security

**Requirement:** System must be secure by design

**Specifications:**

**Authentication & Authorization:**
- JWT-based with refresh tokens
- Roles: ADMIN, MANAGER, CASHIER, VIEWER
- No unauthenticated access to protected resources
- Session timeout: 1 hour inactive

**Password Security:**
- Minimum 12 characters
- Require complexity (uppercase, lowercase, number, special char)
- Bcrypt hashing (work factor 12+)
- Rate limiting: 5 failed attempts → 30 min lockout

**Data Protection:**
- HTTPS required in production (TLS 1.2+)
- No sensitive data in logs
- Database connection SSL when available
- Encrypted backups

**Input Security:**
- All inputs validated
- SQL injection prevention (via ORM/parameterized)
- XSS prevention (templating engine)
- CSRF tokens for state-changing operations

**API Security:**
- Rate limiting: 100 requests/min per IP
- Request size limits
- API key authentication (future)
- CORS properly configured

**Audit & Monitoring:**
- All changes logged with user attribution
- Failed login attempts logged
- Suspicious activity alerts
- Regular security audits

**Success Criteria:**
- Zero critical security vulnerabilities
- All OWASP Top 10 addressed
- Audit trail complete
- Penetration testing passing

---

### NFR-003: Reliability & Availability

**Requirement:** System must be reliable and available when needed

**Specifications:**

**Uptime:**
- Target: 99.9% availability (8.76 hours downtime/year max)
- Measured monthly
- Excludes planned maintenance

**Data Integrity:**
- Zero data loss under any circumstances
- Transactional consistency
- Foreign key referential integrity
- Backup & recovery tested regularly

**Error Handling:**
- Graceful degradation (system doesn't crash)
- Proper error messages (user-friendly)
- Automatic recovery where possible
- Error logging and alerting

**Backups & Recovery:**
- Daily automated backups
- Backup retention: 30 days minimum
- Recovery time objective (RTO): 2 hours
- Recovery point objective (RPO): 1 hour max
- Regular restore testing (monthly)

**Monitoring & Alerting:**
- System health monitoring
- CPU/memory/disk alerts
- Error rate monitoring
- Database performance monitoring

**Success Criteria:**
- <1 hour downtime per month average
- Zero unplanned data loss
- All alerts actionable
- Backup recovery works consistently

---

### NFR-004: Scalability

**Requirement:** System must scale gracefully with business growth

**Specifications:**

**Capacity:**
- Current: 200-400 transactions/day
- Target: Handle 5x (1000-2000 transactions/day)
- Concurrent users: 500+

**Horizontal Scaling:**
- Stateless backend (can run multiple instances)
- Load balancer ready
- Shared database (Kubernetes ready)

**Database Performance:**
- Connection pooling
- Query optimization
- Indexing strategy
- Monitoring tools

**Data Volume:**
- Support millions of transactions
- Archiving strategy for old data
- Query performance on large datasets

**Success Criteria:**
- Can handle 5x current load
- Response times remain consistent under load
- Can add second location without code changes
- Database supports multi-location queries

---

### NFR-005: Maintainability

**Requirement:** Code must be easy to maintain and extend

**Specifications:**

**Code Quality:**
- Test coverage: >80% of critical paths
- Code organization: Clear structure
- Naming conventions: Consistent and meaningful
- Documentation: Comprehensive

**Technology Choices:**
- Well-known frameworks (FastAPI, Next.js)
- Active communities and support
- Good documentation available
- Not bleeding-edge or experimental

**Refactoring:**
- Can refactor without breaking
- Tests provide safety net
- Clear module boundaries
- Easy to understand changes

**Onboarding:**
- New developer productive within 1 week
- Setup takes <10 minutes
- Documentation exists for:
  - Architecture overview
  - Running locally
  - Common tasks
  - Troubleshooting

**Success Criteria:**
- Code review feedback is minor (style, not logic)
- New features added without major refactors
- Bugs fixed within 1 hour
- New developer productive in 1 week

---

### NFR-006: Usability

**Requirement:** System must be easy to use for staff

**Specifications:**

**Interface Design:**
- Clean, modern interface
- Consistent patterns
- Clear visual hierarchy
- Intuitive navigation

**Task Efficiency:**
- Common tasks: <3 clicks
- Progress indication (loading states)
- Keyboard shortcuts for power users
- Search functionality

**Error Prevention:**
- Validation with clear error messages
- Confirmation for dangerous actions
- Undo capability (future)
- Autocomplete where possible

**Mobile Responsiveness:**
- Works on tablets
- Touch-friendly (larger buttons)
- Responsive design
- Optimized for 7-10 inch screens

**Accessibility (WCAG 2.1 AA):**
- Screen reader support
- Keyboard navigation
- Color contrast ratios
- Labels for form fields

**Success Criteria:**
- Staff performs tasks 20% faster
- Error rate reduces 50%
- User satisfaction >4/5
- <3 hours training needed

---

### NFR-007: Compatibility

**Requirement:** System must work across modern browsers and devices

**Specifications:**

**Browsers:**
- Chrome (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Edge (latest 2 versions)

**Devices:**
- Desktop/laptop
- Tablets (iPad, Android)
- Large-screen mobile (6+ inches)

**Internet Requirements:**
- Works on 4G+ connections
- Can function with <5Mbps
- Degraded mode for poor connectivity
- Offline capability (future)

**Success Criteria:**
- All features work on supported browsers
- Layout responsive and usable
- Performance acceptable on tablets
- No browser-specific bugs

---

## User Stories

### Epic: Car Wash Service Operations

**US-CW-001: Create Car Wash Order**

**As a** cashier  
**I want to** create a car wash order with vehicle details  
**So that** I can process customer requests efficiently

**Acceptance Criteria:**
- Given I'm logged in as a cashier
- When I click "New Car Wash Order"
- Then I see a form with:
  - Vehicle type dropdown (motorcycle, sedan, SUV, truck, bus)
  - Service type dropdown (populated from database)
  - License plate field (optional)
  - Phone number field (optional)
  - Employee multi-select (required, minimum 1)
- When I select vehicle type, service type, and employees
- Then system displays calculated price
- And I can confirm to create order
- Then order is created with status PENDING
- And confirmation message shown

**Definition of Done:**
- Form validation working
- Order created in database
- Price calculation verified against current system
- Audit log entry created
- Error handling for missing fields

---

**US-CW-002: View Car Wash Queue**

**As a** service staff  
**I want to** view the current service queue  
**So that** I know which vehicle to work on next

**Acceptance Criteria:**
- Given I'm logged in as service staff
- When I navigate to Queue page
- Then I see ordered list of car washes in progress
- Showing: queue position, vehicle type, license plate, time in queue
- When order is completed by another staff member
- Then queue refreshes automatically
- And order moves to completed section

---

**US-CW-003: Complete Car Wash Service**

**As a** cashier or service staff  
**I want to** mark a car wash as complete  
**So that** we can proceed to payment and update income

**Acceptance Criteria:**
- Given a pending car wash order
- When I click "Mark Complete"
- Then system asks for confirmation
- When I confirm
- Then status changes to COMPLETED
- And end_date is recorded
- And employee income is calculated
- And order appears in reports
- And receipt can be printed

---

### Epic: Laundry Service Operations

**US-LS-001: Create Laundry Order with Items**

**As a** cashier  
**I want to** create a laundry order and catalog items  
**So that** we track what's being washed and how much to charge

**Acceptance Criteria:**
- Given a new laundry order
- When I add items (1+):
  - Select item type
  - Enter quantity
  - System shows price per item
- Then system calculates total: sum of item prices
- When I review total
- I can optionally adjust final_price
- If adjusted higher: extra charge added to first item
- If adjusted lower: discount subtracted sequentially
- Then I can confirm to create order

---

**US-LS-002: Track Laundry Items Through Service**

**As a** service staff  
**I want to** see what items are being washed  
**So that** I can prioritize and track progress

**Acceptance Criteria:**
- Given in-progress laundry orders
- When I view an order
- Then I see list of items with quantities
- When items are washed
- Then I mark complete
- And completion date recorded

---

### Epic: Water Delivery

**US-WD-001: Register New Water Delivery Customer**

**As a** cashier  
**I want to** register a new water delivery customer  
**So that** we can track their deliveries and contact info

**Acceptance Criteria:**
- Given I need to set up new water customer
- When I click "New Customer"
- Then I enter:
  - Full name (required)
  - Address (required)
  - Phone number (optional)
- When I confirm
- Then customer record created
- And can be selected for future deliveries

---

**US-WD-002: Record Water Delivery**

**As a** driver or cashier  
**I want to** record water delivery  
**So that** customer is charged and revenue tracked

**Acceptance Criteria:**
- Given customer ready for delivery
- When I create delivery:
  - Select customer (or enter walk-in name)
  - Select water type and quantity
  - System calculates price
  - Specify payment method (PREPAID, COD, INVOICE)
- Then order created
- When delivery completed
- Then I mark complete
- And order included in income

---

### Epic: Authentication & Security

**US-AUTH-001: User Login**

**As a** cashier or manager  
**I want to** log in with username and password  
**So that** system knows who I am and enforces permissions

**Acceptance Criteria:**
- Given I'm at login screen
- When I enter username and password
- Then system validates credentials
- If incorrect: error message
- If correct: JWT token issued
- And I'm logged in for 1 hour
- When 1 hour passes without activity
- Then I'm logged out
- And must log in again to continue

---

**US-AUTH-002: Different Roles See Different Options**

**As a** cashier  
**I want to** only see features I'm authorized to use  
**So that** interface is clean and prevents mistakes

**Acceptance Criteria:**
- Given I'm logged in as CASHIER
- When I view the menu
- Then I see only: Orders, Reports (limited)
- When manager logs in
- Then they see: Orders, Reports (full), Settings
- When admin logs in
- Then they see: All options + Admin panel
- When I try to access unauthorized endpoint
- Then 403 Forbidden error shown

---

### Epic: Payment Processing

**US-PAY-001: Record Payment for Order**

**As a** cashier  
**I want to** record payment method and amount  
**So that** we know payment status and can reconcile

**Acceptance Criteria:**
- Given completed order ready for payment
- When customer pays
- Then I record:
  - Payment method (CASH, TRANSFER, E_WALLET, CARD, INVOICE)
  - Amount received
- Then system updates payment status:
  - Full amount = PAID
  - Partial = PARTIAL
  - Zero = UNPAID
- And receipt can be printed

---

**US-PAY-002: Process Refund**

**As a** manager  
**I want to** issue refund for unsatisfactory service  
**So that** customer is satisfied and we maintain goodwill

**Acceptance Criteria:**
- Given completed order with payment
- When customer complains about service
- Then I can create refund:
  - Select reason
  - Confirm refund amount
- Then payment status changes to REFUNDED
- And money returned to customer
- And audit log records refund with reason

---

### Epic: Reporting

**US-REP-001: View Daily Income Summary**

**As a** manager  
**I want to** see today's income across all services  
**So that** I know how business is performing

**Acceptance Criteria:**
- Given manager dashboard
- When I view report
- Then I see:
  - Today's total income
  - Breakdown by service (car wash, laundry, carpet, water)
  - Year-to-date comparison
  - Previous day comparison

---

**US-REP-002: Employee Income Report**

**As a** manager  
**I want to** see how much each employee earned  
**So that** I can track performance and payroll

**Acceptance Criteria:**
- Given employee income report
- When I view it
- Then I see:
  - Each employee name
  - Total earned (today, this month, custom range)
  - Breakdown by service type
  - Can export to CSV/PDF

---

## Data Requirements

### Data Migration

**All existing data must be migrated with 100% integrity:**

**Tables to migrate:**
- employees
- carwash_types, carwash_transactions, carwash_employees
- laundry_types, laundry_items, laundry_transactions
- drinking_water_types, drinking_water_customers, drinking_water_transactions

**Data validation:**
- Count records: old count == new count
- Spot check sample rows
- Verify relationships (foreign keys)
- Check totals (sums match)

**Data retention:**
- Transaction data: Permanent (never delete)
- User sessions: 30 days (auto-clean)
- Logs: 90 days (then archive)
- Backups: 1 year minimum

**Data security:**
- Encrypted backups
- Access restricted to authorized users
- No sensitive data in logs
- PII protected per regulations

---

## Integration Requirements

### INT-001: SMS Notification Gateway

**Requirement:** Send SMS notifications to customers

**Scenarios:**
- Order complete: "Your service is ready for pickup"
- Delivery confirmation: "Water delivered to your address"
- Payment receipt: "Charge of Rp50,000 received"
- Invoice reminder: "Invoice due in 5 days"

**Implementation:**
- Use Twilio or local SMS service
- Queue-based (asynchronous)
- Retry on failure
- Log all messages sent
- Respect quiet hours (no SMS after 8 PM)

---

### INT-002: Email Integration

**Requirement:** Send email notifications and reports

**Scenarios:**
- Daily sales report to manager
- Monthly invoice to customer
- Payment receipt
- System alerts (errors, backups)

**Implementation:**
- SMTP configuration
- Queue-based delivery
- HTML templates
- Retry logic

---

### INT-003: Payment Gateway (Future)

**Requirement:** Process credit cards and e-wallet payments

**Note:** Out of scope for Phase 1, but architecture must support

**Implementation:**
- Abstract payment layer
- Support multiple gateways
- Webhook handling
- PCI compliance

---

## Constraints & Assumptions

### Constraints

**Technical:**
- **Database:** Must use existing MariaDB (no migration to new DB engine)
- **Language:** Python or Node.js (mature, maintainable)
- **Deployment:** Docker-based containerization
- **Timeline:** 5 months maximum

**Business:**
- **Operations:** Business must continue during development
- **Data:** 100% preservation of existing data
- **Downtime:** Minimize (target <2 hours cutover)
- **Team:** Likely 2-3 developers

**Financial:**
- **Budget:** Cost-conscious (open-source stack)
- **Infrastructure:** Affordable hosting
- **No:** Expensive commercial licenses

**Regulatory:**
- **Data:** Comply with Indonesia data protection
- **Financial:** Proper transaction audit trail
- **Employment:** Track employee earnings accurately

### Assumptions

**Team:**
- Developers know Git, have dev environment set up
- Staff will receive training on new system
- Management will be available for decisions

**Infrastructure:**
- Stable internet connectivity available
- Adequate hardware for deployment
- Database backup capabilities available

**Business:**
- Current workflows won't change significantly
- Data quality acceptable (no major cleanup needed)
- Migration window available (after-hours OK)

**Users:**
- Staff willing to learn new system
- No major resistance to changes
- Feedback will be provided constructively

---

## Risks & Mitigation

### Risk Management Process

**Risk Assessment Matrix:**

| Probability | Impact | Priority |
|-------------|--------|----------|
| High + High | Critical | **CRITICAL** |
| High + Medium OR Medium + High | **HIGH** | **HIGH** |
| Medium + Medium OR Low + High | Medium | **MEDIUM** |
| Low + Low OR Low + Medium | Low | **LOW** |

### Identified Risks

#### Risk 1: Data Loss During Migration

**Probability:** Low  
**Impact:** Critical  
**Priority:** CRITICAL

**Description:** Production data corrupted or lost during migration

**Mitigation:**
- Complete database backup before migration
- Test migration on staging environment first
- Validate data at each step (extract, transform, load)
- Keep old database available for 24h (rollback window)
- Documented rollback procedure
- Team trained on recovery

**Owner:** Database Administrator  
**Monitoring:** Pre-migration checklist

---

#### Risk 2: Performance Degradation

**Probability:** Medium  
**Impact:** High  
**Priority:** HIGH

**Description:** New system slower than current system

**Mitigation:**
- Load testing throughout development
- Database query optimization
- Proper indexing strategy
- Caching where appropriate
- Performance profiling
- Staging environment testing

**Owner:** Backend Lead  
**Monitoring:** Performance metrics tracked weekly

---

#### Risk 3: User Adoption Resistance

**Probability:** Medium  
**Impact:** Medium  
**Priority:** HIGH

**Description:** Staff struggles with new system, slow adoption

**Mitigation:**
- Staff involved in requirements
- UAT with actual operations staff
- Comprehensive training provided
- Easy-to-use interface design
- Gradual rollout (train-then-go-live)
- Post-launch support available

**Owner:** Product Manager  
**Monitoring:** User feedback surveys

---

#### Risk 4: Timeline Overrun

**Probability:** Medium  
**Impact:** Medium  
**Priority:** HIGH

**Description:** Project takes longer than 5 months

**Mitigation:**
- Realistic estimates with buffer (1 week built in)
- Clear scope boundaries
- Weekly progress tracking
- Early issue escalation
- MVP approach (phased delivery if needed)
- Agile allows scope adjustment

**Owner:** Project Lead  
**Monitoring:** Burndown charts, sprint velocity

---

#### Risk 5: Technical Issues / Unforeseen Blockers

**Probability:** Low  
**Impact:** High  
**Priority:** MEDIUM

**Description:** Unexpected technical problems surface

**Mitigation:**
- Architectural design phase (2 weeks)
- Spike investigations for unknowns
- Code reviews catch issues early
- Automated testing
- Staging environment for validation
- Expert consultation available

**Owner:** Tech Lead  
**Monitoring:** Architecture review notes, test results

---

#### Risk 6: Feature Scope Creep

**Probability:** Medium  
**Impact:** Medium  
**Priority:** MEDIUM

**Description:** New features requested, scope expands

**Mitigation:**
- Clear Phase 1 scope definition
- Change control process
- Phase 2 planning for future features
- Say "no" to out-of-scope requests
- Document requests for future

**Owner:** Product Manager  
**Monitoring:** Scope change log

---

#### Risk 7: Security Vulnerabilities

**Probability:** Low  
**Impact:** Critical  
**Priority:** HIGH

**Description:** System launched with security issues

**Mitigation:**
- Security architecture review
- OWASP Top 10 checklist
- Code security scanning
- Penetration testing (optional)
- Security testing in QA
- Dependency vulnerability scanning

**Owner:** Security Lead / Tech Lead  
**Monitoring:** Security checklist, scan results

---

#### Risk 8: Communication Breakdowns

**Probability:** Medium  
**Impact:** Medium  
**Priority:** MEDIUM

**Description:** Misunderstandings between team and stakeholders

**Mitigation:**
- Clear requirements document (this PRD)
- Weekly stakeholder meetings
- Regular demos
- Documentation of decisions
- Open communication channel
- Escalation path defined

**Owner:** Project Manager  
**Monitoring:** Meeting notes, decision log

---

### Risk Monitoring

**Weekly Review:**
- Assess probability/impact of known risks
- Identify new risks
- Review mitigation effectiveness
- Update risk register

**Reporting:**
- Monthly steering committee report
- Include risk changes and mitigation updates
- Escalate high-priority risks immediately

**Contingency Planning:**
- Budget: 1-week buffer included in timeline
- Scope: MVP approach for phased delivery
- Team: Cross-training for key person risk

---

# APPENDIX

## Approval & Sign-Off

### Review & Approval Chain

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Product Manager** | [ ] | [ ] | [ ] |
| **Tech Lead** | [ ] | [ ] | [ ] |
| **Operations Lead** | [ ] | [ ] | [ ] |
| **Business Owner** | [ ] | [ ] | [ ] |

### Stakeholder Feedback

Feedback from:
- ☐ Development Team
- ☐ Operations Staff
- ☐ Management
- ☐ Customers (survey/interviews)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Oct 22, 2025 | Product Team | Initial comprehensive PRD |

---

## References

**Related Documents:**
- Business Flows Documentation: `docs/business-flows/README.md`
- Current System Analysis: `docs/analysis/current-app-analysis.md`
- Business Logic Summary: `docs/business-logic/business-logic-summary.md`
- Technical Architecture: `docs/planning/architecture.md` (to be created)

---

## Contact & Questions

**For questions about this PRD:**
- **Product Manager:** [contact]
- **Tech Lead:** [contact]
- **Project Manager:** [contact]

---

**Status:** ✅ **READY FOR STAKEHOLDER REVIEW**

**Next Steps:**
1. Stakeholders review PRD (1 week)
2. Incorporate feedback
3. Obtain sign-off
4. Begin development (Phase 1: Analysis & Planning)

---

*This Product Requirements Document serves as the single source of truth for the Kharisma Abadi application rebuild. All decisions, scope, and requirements are based on this document.*

*Estimated Project Value: Reduced technical debt, improved security, faster feature delivery, scalable architecture*

---

**End of PRD**
