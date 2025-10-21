# Sprint Planning & Product Backlog

**Project:** Kharisma Abadi Rebuild  
**Total Duration:** 10 sprints (~20 weeks / 5 months)  
**Sprint Length:** 2 weeks  
**Velocity Target:** 12-15 story points per sprint  

---

## Product Backlog (Prioritized)

### P0 - Must Have (Critical Path)

| ID | Story | Points | Sprint |
|----|-------|--------|--------|
| US-001 | User Login | 3 | 1 |
| US-002 | User Logout | 1 | 1 |
| US-003 | User Management (CRUD) | 8 | 2 |
| US-005 | Create Car Wash Order | 8 | 3 |
| US-006 | View Car Wash Queue | 3 | 3 |
| US-007 | Complete Car Wash Service | 5 | 3 |
| US-008 | Create Laundry Order | 8 | 4 |
| US-010 | Create Carpet Washing Order | 8 | 5 |
| US-011 | Create Water Delivery Order | 5 | 5 |
| US-012 | Process Payment (Cash) | 5 | 6 |
| US-013 | Process Payment (Bank Transfer) | 3 | 6 |
| US-015 | Generate Receipt | 3 | 6 |
| US-016 | Create Customer Profile | 3 | 7 |
| US-023 | Manage Cash Drawer | 5 | 10 |

**Total P0 Points: 82**

### P1 - Should Have (Important)

| ID | Story | Points | Sprint |
|----|-------|--------|--------|
| US-004 | User Profile Management | 3 | 2 |
| US-009 | Track Laundry Order Status | 3 | 4 |
| US-014 | Process Split Payment | 5 | 6 |
| US-017 | View Customer History | 3 | 7 |
| US-018 | Update Customer Information | 2 | 7 |
| US-019 | Generate Daily Sales Report | 5 | 8 |
| US-020 | Generate Revenue Report | 5 | 8 |
| US-022 | Configure Service Pricing | 5 | 9 |
| US-024 | View Audit Logs | 3 | 10 |

**Total P1 Points: 34**

### P2 - Nice to Have (Future)

| ID | Story | Points | Sprint |
|----|-------|--------|--------|
| US-021 | Generate Service Performance Report | 5 | 9 |
| US-025 | System Health & Monitoring | 5 | 10 |

**Total P2 Points: 10**

**Grand Total: 126 story points across 25 user stories**

---

## Sprint Breakdown (2-week sprints)

### Sprint 1: Foundation & Authentication (Week 1-2)

**Goal:** Establish development foundation and user authentication

**Stories:**
- US-001: User Login (3 pts)
- US-002: User Logout (1 pt)
- **Infrastructure/Setup:** Project setup, CI/CD pipeline (5 pts)

**Total: 9 points**

**Tasks:**
1. Backend environment setup (Go, Docker)
2. Frontend environment setup (Vue 3, Vite)
3. Database schema creation
4. JWT implementation
5. Login/logout UI components
6. API authentication middleware
7. Token storage and management
8. Unit tests for auth flow

**Deliverables:**
- Working auth system
- Login page functional
- JWT tokens working
- Initial CI/CD pipeline
- Development environment ready

**Definition of Done:**
- [ ] Backend authentication endpoints tested
- [ ] Frontend login/logout pages working
- [ ] JWT tokens properly generated and validated
- [ ] Unit tests passing (>85% coverage)
- [ ] Deployed to staging
- [ ] Manual testing complete

---

### Sprint 2: User Management (Week 3-4)

**Goal:** Implement complete user management system

**Stories:**
- US-003: User Management (CRUD) (8 pts)
- US-004: User Profile Management (3 pts)

**Total: 11 points**

**Tasks:**
1. User CRUD endpoints (GET, POST, PATCH, DELETE)
2. Role-based permission system
3. User list UI with filters
4. User creation form with validation
5. User edit/update form
6. Password change functionality
7. Role assignment UI
8. User deactivation logic
9. Integration tests for user management
10. Audit logging for user actions

**Deliverables:**
- Complete user management system
- Admin can create/edit/delete users
- User roles and permissions functional
- User profile management working
- Audit trails captured

---

### Sprint 3: Car Wash Service (Week 5-6)

**Goal:** Implement complete car wash service workflow

**Stories:**
- US-005: Create Car Wash Order (8 pts)
- US-006: View Car Wash Queue (3 pts)
- US-007: Complete Car Wash Service (5 pts)

**Total: 16 points**

**Tasks:**
1. Car wash order creation API
2. Pricing calculation engine (vehicle × package × addons)
3. Order form UI with real-time price calculation
4. Queue management UI
5. Queue auto-refresh mechanism
6. Order detail view
7. Service completion workflow
8. Quality check form
9. Completion time tracking
10. Order status transitions
11. Comprehensive pricing tests
12. E2E test scenarios

**Deliverables:**
- Car wash orders can be created
- Queue displays correctly
- Pricing calculations accurate
- Service completion workflow functional
- Real-time queue updates

---

### Sprint 4: Laundry Service (Week 7-8)

**Goal:** Implement laundry service

**Stories:**
- US-008: Create Laundry Order (8 pts)
- US-009: Track Laundry Order Status (3 pts)

**Total: 11 points**

**Tasks:**
1. Laundry order creation API
2. Item categorization system
3. Weight-based pricing calculation
4. Service type selection (Standard/Express/Urgent)
5. Add-ons (Ironing, Stain Removal, etc.)
6. Laundry order form UI
7. Order status tracking
8. SMS notifications for order status
9. Laundry-specific pricing tests

**Deliverables:**
- Laundry orders functional
- Pricing calculations working
- Order status tracking
- SMS notifications functional

---

### Sprint 5: Additional Services (Week 9-10)

**Goal:** Implement Carpet and Water Delivery services

**Stories:**
- US-010: Create Carpet Washing Order (8 pts)
- US-011: Create Water Delivery Order (5 pts)

**Total: 13 points**

**Tasks:**
1. Carpet washing order API
2. Room type and sizing system
3. Carpet cleaning type selection
4. Delivery fee calculation
5. Carpet order form UI
6. Water delivery order API
7. Water product selection
8. Delivery distance-based pricing
9. Integration with customer/delivery system

**Deliverables:**
- Carpet washing orders working
- Water delivery orders functional
- All 4 service types operational

---

### Sprint 6: Payment Processing (Week 11-12)

**Goal:** Complete payment system with multiple methods

**Stories:**
- US-012: Process Payment (Cash) (5 pts)
- US-013: Process Payment (Bank Transfer) (3 pts)
- US-014: Process Split Payment (5 pts)
- US-015: Generate Receipt (3 pts)

**Total: 16 points**

**Tasks:**
1. Payment processing API
2. Cash payment handler with change calculation
3. Bank transfer recording system
4. E-wallet integration preparation
5. Split payment logic
6. Payment validation and error handling
7. Receipt generation and formatting
8. Receipt printing functionality
9. Payment history tracking
10. Transaction logging
11. Payment status updates
12. Comprehensive payment tests

**Deliverables:**
- All payment methods working
- Cash drawer integration
- Receipts generating correctly
- Payment history tracked

---

### Sprint 7: Customer Management (Week 13-14)

**Goal:** Implement customer management system

**Stories:**
- US-016: Create Customer Profile (3 pts)
- US-017: View Customer History (3 pts)
- US-018: Update Customer Information (2 pts)

**Total: 8 points**

**Tasks:**
1. Customer CRUD endpoints
2. Customer profile creation form
3. Customer search functionality
4. Customer type/membership system
5. Discount application by customer type
6. Customer history view
7. Order history display
8. Customer statistics (total spent, order count)
9. Customer information update form
10. Customer deactivation

**Deliverables:**
- Customer management functional
- Customer history accessible
- Discount system working
- Customer profiles maintained

---

### Sprint 8: Reporting System (Week 15-16)

**Goal:** Implement comprehensive reporting

**Stories:**
- US-019: Generate Daily Sales Report (5 pts)
- US-020: Generate Revenue Report (5 pts)

**Total: 10 points**

**Tasks:**
1. Daily sales report API
2. Revenue aggregation logic
3. Report filtering and sorting
4. PDF export functionality
5. Excel export functionality
6. Chart visualization
7. Service breakdown reporting
8. Payment method breakdown
9. Report caching for performance
10. Date range flexibility
11. Report scheduling (future)

**Deliverables:**
- Daily sales reports generating
- Revenue reports functional
- Export functionality working
- Charts displaying correctly

---

### Sprint 9: Advanced Features (Week 17-18)

**Goal:** Implement advanced admin features and reporting

**Stories:**
- US-022: Configure Service Pricing (5 pts)
- US-021: Generate Service Performance Report (5 pts)

**Total: 10 points**

**Tasks:**
1. Service pricing configuration UI
2. Vehicle type multiplier management
3. Package price updates
4. Add-on pricing management
5. Pricing history tracking
6. Service performance metrics collection
7. Completion rate calculation
8. Average service time tracking
9. Quality check analytics
10. Performance report generation

**Deliverables:**
- Admin can update pricing
- Service performance metrics tracked
- Performance reports available

---

### Sprint 10: Polish & Finalization (Week 19-20)

**Goal:** Complete remaining features, testing, and deployment preparation

**Stories:**
- US-023: Manage Cash Drawer (5 pts)
- US-024: View Audit Logs (3 pts)
- US-025: System Health & Monitoring (5 pts)

**Total: 13 points**

**Tasks:**
1. Cash drawer opening/closing flow
2. Cash drawer reconciliation
3. Variance tracking and alerts
4. Audit log display UI
5. Audit log filtering and search
6. System health dashboard
7. Performance monitoring
8. Error rate tracking
9. API response time monitoring
10. Database health checks
11. Comprehensive system testing
12. Performance optimization
13. Security audit completion
14. Deployment documentation

**Deliverables:**
- Cash drawer management functional
- Audit logs viewable and searchable
- System monitoring in place
- Ready for production deployment

---

## Velocity Tracking

### Target Velocity: 12-15 points/sprint

| Sprint | Target | Actual | Status |
|--------|--------|--------|--------|
| 1 | 14 | TBD | Planned |
| 2 | 11 | TBD | Planned |
| 3 | 16 | TBD | Planned |
| 4 | 11 | TBD | Planned |
| 5 | 13 | TBD | Planned |
| 6 | 16 | TBD | Planned |
| 7 | 8 | TBD | Planned |
| 8 | 10 | TBD | Planned |
| 9 | 10 | TBD | Planned |
| 10 | 13 | TBD | Planned |

**Total: 122 points**

---

## Sprint Review/Retrospective Structure

### Sprint Review (1 hour)
- Demo completed stories
- Discuss blockers and challenges
- Gather stakeholder feedback
- Update product backlog based on learnings

### Sprint Retrospective (45 minutes)
- What went well?
- What could be improved?
- Action items for next sprint
- Team morale check

---

## Dependency Management

### Critical Path

```
Sprint 1: Auth ──→ Sprint 2: Users ──→ Sprint 3-5: Services ──→ Sprint 6: Payments ──→ Sprint 8-10: Reporting/Admin
```

### High-Risk Dependencies

1. **Authentication** (Sprint 1)
   - Required by: All other stories
   - Risk: If delayed, blocks entire project
   - Mitigation: Prioritize and allocate senior developer

2. **Database Schema** (Sprint 1)
   - Required by: All data operations
   - Risk: Major changes needed later cause delays
   - Mitigation: Complete analysis before sprint starts

3. **Order Management** (Sprint 3)
   - Required by: Payments (Sprint 6)
   - Risk: Payment system dependent on order structure
   - Mitigation: Finalize order schema early

4. **Payment System** (Sprint 6)
   - Required by: Reporting (Sprint 8)
   - Risk: Payment data needed for accurate reports
   - Mitigation: Complete payment implementation thoroughly

---

## Release Plan

### MVP Release (End of Sprint 5)
**Features:**
- User authentication & management
- All 4 service types (order creation only)
- Basic payment processing
- Customer management
- Receipt generation

**Target:** Week 10 (Stakeholder review)

### Full Release (End of Sprint 10)
**Features:**
- Complete order lifecycle for all services
- All payment methods
- Comprehensive reporting
- Admin configuration
- Audit logging
- System monitoring

**Target:** Week 20 (Production ready)

---

## Quality Gates

### Before Each Sprint Release

- [ ] All acceptance criteria met
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] No critical bugs
- [ ] Code review approved
- [ ] Performance benchmarks met
- [ ] Security checks passed
- [ ] Documentation updated

### Before Production Release

- [ ] All P0 stories complete
- [ ] P1 stories 90%+ complete
- [ ] Load testing passed
- [ ] Security audit complete
- [ ] UAT approved
- [ ] Backup/recovery tested
- [ ] Deployment runbook created
- [ ] Staff training completed

---

## Team Allocation

### Recommended Team Composition

**Backend Team (2 developers):**
- Focus: Go/Fiber API development
- Responsibility: All backend user stories
- Sprint 1-3: Foundation, Auth, Services
- Sprint 4-6: Payment system, Laundry/Carpet
- Sprint 7-10: Customers, Reporting, Admin

**Frontend Team (1 developer):**
- Focus: Vue 3 UI development
- Responsibility: All frontend components
- Sprint 1-3: Auth, Dashboard, Service forms
- Sprint 4-6: Queue, Payment, Receipt
- Sprint 7-10: Reporting, Admin pages

**QA/Testing (1 person):**
- Manual testing
- Test case development
- UAT coordination
- Bug triage

**DevOps (Part-time):**
- CI/CD setup (Sprint 1)
- Docker configuration
- Deployment support
- Monitoring setup

---

## Risk Management

### High-Risk Areas

1. **Pricing Calculation Complexity**
   - Risk: Multiple discount/multiplier logic may cause bugs
   - Mitigation: Comprehensive unit tests for all combinations
   - Owner: Backend lead

2. **Real-time Queue Updates**
   - Risk: WebSocket/polling may not scale
   - Mitigation: Load testing and optimization in Sprint 3
   - Owner: Backend lead

3. **Payment Integration**
   - Risk: Multiple payment methods = integration complexity
   - Mitigation: Phased implementation (cash first)
   - Owner: Backend + QA

4. **Data Migration**
   - Risk: 3+ years of existing data must be preserved
   - Mitigation: Migration scripts ready before Sprint 6
   - Owner: DevOps + Backend

### Mitigation Strategies

- Daily standup for blockers
- Pair programming for high-risk features
- Early prototyping/spike work
- Regular stakeholder communication
- Comprehensive testing at each stage

---

## Success Metrics

### Development Metrics
- Velocity consistency (±20% variance acceptable)
- Bug escape rate (<5% of completed stories)
- Code review time (<24 hours)
- Test coverage (>85%)

### Business Metrics
- Feature completion rate (90%+ by Sprint 10)
- Zero data loss in migration
- All legacy features replicated
- Performance meets or exceeds current system
- User acceptance test pass rate >95%

### Team Metrics
- Team velocity stabilizing by Sprint 3
- Sprint goal achievement >90%
- Team morale maintaining high
- No key person bottlenecks

---

## Communication Plan

### Daily
- 10:00 AM: 15-min standup (status, blockers, plan)

### Weekly
- Monday: Sprint planning discussion
- Friday: Weekly review + retro

### Biweekly
- Sprint review with stakeholders
- Sprint retrospective with team

### Monthly
- Progress review with management
- Backlog refinement session

---

This sprint plan provides a detailed roadmap for the entire 20-week project, ensuring systematic progress toward a complete, tested, production-ready system.
