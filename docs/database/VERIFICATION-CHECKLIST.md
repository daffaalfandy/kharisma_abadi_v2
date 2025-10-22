# Database Migration Verification Checklist

**Project:** Kharisma Abadi v2
**Migration Date:** [Date]
**Migration Lead:** [Name]
**Verification Status:** [Pending]

---

## Pre-Migration Verification

### 1. Environment Readiness

**Database Connectivity**
- [ ] Can connect to production database
- [ ] Can connect to staging database
- [ ] Database user has required privileges
- [ ] Network connectivity verified

Verification Command:
```bash
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SELECT VERSION();"
```
Expected Result: MariaDB 10.3+

**Disk Space**
- [ ] At least 5GB free on database partition
- [ ] At least 10GB free for backups
- [ ] Verified with: `df -h`
- Current Status: [Space available]

**Backup Infrastructure**
- [ ] Backup directory exists and is writable
- [ ] Previous backups accessible
- [ ] Backup verification script tested
- Path: [Backup location]

### 2. Database Schema Validation

**Current Schema Documented**
- [ ] Ran schema analysis
- [ ] Created schema dump
- [ ] Documented all tables: 10+ tables present
- [ ] Foreign keys identified and documented
- [ ] Indexes documented

**Data Integrity Pre-Migration**
- [ ] No orphaned records found
- [ ] All foreign key constraints valid
- [ ] No duplicate phone numbers (for customers)
- [ ] All prices are positive
- [ ] All dates are reasonable (not in future)

### 3. Full Backup Verification

**Pre-Migration Backup Created**
- [ ] Backup file exists
- [ ] File size: [Size]
- [ ] File is not empty (>10MB expected)
- [ ] Backup is readable
- [ ] Created at: [Timestamp]

**Backup Integrity Verified**
- [ ] Compressed backup valid: `gzip -t <backup.sql.gz>`
- [ ] Can restore test in new database
- [ ] All tables present in backup
- [ ] Backup timestamp recorded
- Backup Location: [Path]
- Backup Size: [Size]

**Backup Accessibility**
- [ ] Backup stored in safe location
- [ ] Backup stored on separate disk
- [ ] Backup access permissions correct
- [ ] Backup ownership correct

### 4. Application Readiness

**Go Backend Code**
- [ ] GORM models match new schema
- [ ] ORM mappings reviewed
- [ ] Database connection strings tested
- [ ] Migration code tested on staging
- [ ] All dependencies compiled
- [ ] Compiled binary created: [Path]

**Frontend Code**
- [ ] TypeScript interfaces match new schema
- [ ] API service calls tested
- [ ] Response mappers updated
- [ ] Frontend compiled
- [ ] Build artifacts generated

---

## Migration Execution Verification

### Phase 1: Pre-Migration (30 minutes)

**Backup Execution**
- [ ] Backup script executed without errors
- [ ] Backup file created: [File]
- [ ] Backup size reasonable: [Size]
- [ ] Backup timestamp: [Time]
- [ ] Backup verified (gzip -t)
- Status: ✓ Complete
- Duration: [Time]
- Issues: [None or description]

**Schema Validation Executed**
- [ ] Validation script ran successfully
- [ ] All expected tables found
- [ ] No data integrity issues
- [ ] Baseline metrics captured
- Status: ✓ Complete
- Duration: [Time]

### Phase 2: Schema Creation (30 minutes)

**New Database Created**
- [ ] kharisma_db_new database created
- [ ] Charset set to utf8mb4
- [ ] Collation set to utf8mb4_unicode_ci
- Status: ✓ Complete

**All Tables Created**
- [ ] users table created with proper schema
- [ ] customers table created
- [ ] orders table created
- [ ] order_items table created
- [ ] payments table created
- [ ] audit_logs table created
- [ ] system_config table created
- Total Tables Created: 7
- Status: ✓ Complete
- Duration: [Time]

**Indexes Created**
- [ ] All performance indexes created
- [ ] Foreign key indexes created
- [ ] Status/date composite indexes created
- Total Indexes: [Count]
- Status: ✓ Complete

### Phase 3: Data Migration (1-2 hours)

**User Data Migrated**
- [ ] Employee records migrated to users
- [ ] Admin user created
- [ ] Passwords hashed properly
- [ ] Roles assigned correctly
- Records Migrated: [Count]/[Expected]
- Status: ✓ Complete
- Duration: [Time]
- Issues: [None or description]

**Customer Data Migrated**
- [ ] All customer service records consolidated
- [ ] Deduplication completed
- [ ] No customer records lost
- [ ] Phone numbers preserved
- [ ] Addresses preserved
- Records Migrated: [Count]/[Expected]
- Duplicates Removed: [Count]
- Status: ✓ Complete
- Duration: [Time]

**Order Data Migrated**
- [ ] Car wash transactions migrated
- [ ] Laundry items migrated
- [ ] Water delivery transactions migrated
- [ ] Order numbers generated uniquely
- [ ] Service types mapped correctly
- [ ] Prices converted correctly (BIGINT → DECIMAL)
- Records Migrated: [Count]/[Expected]
- Status: ✓ Complete
- Duration: [Time]

**Payment Data Migrated**
- [ ] Payment records created from orders
- [ ] Payment methods set correctly
- [ ] Amounts preserved
- [ ] Status set appropriately
- Records Migrated: [Count]/[Expected]
- Status: ✓ Complete
- Duration: [Time]

### Phase 4: Verification (30 minutes)

#### Row Count Verification

**Users Table**
- [ ] Expected: [Count]
- [ ] Actual: [Count]
- [ ] Match: ✓ Yes / ✗ No
- [ ] Difference: [0 or value]

**Customers Table**
- [ ] Expected: [Count] (after dedup)
- [ ] Actual: [Count]
- [ ] Match: ✓ Yes / ✗ No
- [ ] Difference: [0 or value]

**Orders Table**
- [ ] Expected: [Count]
- [ ] Actual: [Count]
- [ ] Match: ✓ Yes / ✗ No
- [ ] Difference: [0 or value]

**Payments Table**
- [ ] Expected: [Count]
- [ ] Actual: [Count]
- [ ] Match: ✓ Yes / ✗ No
- [ ] Difference: [0 or value]

#### Data Integrity Verification

**Referential Integrity**
- [ ] No orphaned orders (all have valid customer)
- [ ] No orphaned payments (all have valid order)
- [ ] No null foreign keys where not allowed
- [ ] All FK constraints valid
- Status: ✓ All checks passed
- Orphaned Records Found: 0

**Unique Constraints**
- [ ] All order numbers are unique
- [ ] All customer phones are unique
- [ ] All user usernames are unique
- [ ] All user emails are unique
- Status: ✓ All constraints satisfied
- Duplicates Found: 0

**Data Type Validation**
- [ ] No negative prices
- [ ] No prices exceeding maximum
- [ ] All dates are reasonable (not future dates)
- [ ] Timestamp formats correct
- [ ] All enums are valid values
- Status: ✓ All data types valid
- Invalid Records Found: 0

#### Business Logic Verification

**Order Data**
- [ ] All service_types are valid (car_wash, laundry, carpet, water_delivery)
- [ ] All statuses are valid
- [ ] Subtotal ≤ Total (with discounts/tax)
- [ ] No orders with zero total
- [ ] All orders have customer_id
- [ ] All orders have created_by
- Status: ✓ All rules satisfied

**Payment Data**
- [ ] All payment methods are valid (cash, bank_transfer, ewallet, card)
- [ ] All payment statuses are valid (pending, completed, failed, refunded)
- [ ] Payment amounts positive
- [ ] Payment amounts ≤ order total
- [ ] All payments have order_id
- Status: ✓ All rules satisfied

**Customer Data**
- [ ] All customer types are valid (regular, vip, corporate)
- [ ] All customer phones are not null
- [ ] Discount percentages 0-100
- [ ] No duplicate phones (after dedup)
- [ ] No duplicate emails (if populated)
- Status: ✓ All rules satisfied

### Phase 5: Post-Migration (30 minutes)

**Database Optimization**
- [ ] Tables analyzed with ANALYZE TABLE
- [ ] Tables optimized with OPTIMIZE TABLE
- [ ] Statistics updated
- [ ] Query performance tested
- Status: ✓ Complete
- Duration: [Time]

**Final Backup Created**
- [ ] Post-migration backup created
- [ ] Backup file: [File]
- [ ] Backup size: [Size]
- [ ] Backup verified
- Status: ✓ Complete
- Timestamp: [Time]

---

## Application Testing Verification

### 1. API Functionality Testing

**Authentication Endpoints**
- [ ] POST /auth/login works
- [ ] POST /auth/logout works
- [ ] Token generation works
- [ ] Token validation works
- Status: ✓ All working

**Order Endpoints**
- [ ] GET /orders returns all orders
- [ ] POST /orders creates new order
- [ ] GET /orders/{id} returns specific order
- [ ] PATCH /orders/{id} updates order
- [ ] Order data matches database
- Status: ✓ All working
- Test Orders Count: [Count]

**Payment Endpoints**
- [ ] GET /payments returns all payments
- [ ] POST /payments creates new payment
- [ ] GET /payments/{id} returns specific payment
- [ ] Payment data matches database
- Status: ✓ All working

**Customer Endpoints**
- [ ] GET /customers returns all customers
- [ ] GET /customers/{id} returns specific customer
- [ ] Customer data matches database
- Status: ✓ All working
- Test Customers Count: [Count]

### 2. Data Retrieval Testing

**Pagination**
- [ ] Offset/limit works correctly
- [ ] Page numbering correct
- [ ] Total count accurate
- Status: ✓ All working

**Filtering**
- [ ] Filter by status works
- [ ] Filter by service type works
- [ ] Filter by date range works
- [ ] Filter by customer works
- Status: ✓ All working

**Sorting**
- [ ] Sort by date works
- [ ] Sort by amount works
- [ ] Sort by status works
- [ ] Sort by name works
- Status: ✓ All working

**Search**
- [ ] Search customers by name works
- [ ] Search customers by phone works
- [ ] Search orders by order number works
- Status: ✓ All working

### 3. Reporting Functionality

**Daily Sales Report**
- [ ] Report generates without errors
- [ ] Totals are correct
- [ ] Data sample verified
- Status: ✓ Working

**Service Type Reports**
- [ ] Car wash sales report correct
- [ ] Laundry sales report correct
- [ ] Water delivery report correct
- Status: ✓ All working

**Customer Reports**
- [ ] Customer order history correct
- [ ] Customer spending totals correct
- [ ] VIP customer list correct
- Status: ✓ All working

### 4. Performance Validation

**Query Performance**
- [ ] List 1000 orders: [Time]ms (Target: <500ms)
- [ ] Get single order: [Time]ms (Target: <100ms)
- [ ] Filter orders by status: [Time]ms (Target: <200ms)
- [ ] Search customers: [Time]ms (Target: <300ms)
- Status: ✓ All within targets / ✗ Some slow

**Database Connections**
- [ ] Connection pool working
- [ ] No connection leaks
- [ ] Connection timeout appropriate
- Status: ✓ Healthy

**Response Times**
- [ ] API response time p50: [Time]ms
- [ ] API response time p95: [Time]ms
- [ ] API response time p99: [Time]ms
- Status: ✓ Acceptable / ✗ Needs optimization

---

## Final Approval Checklist

**All Verification Tests Passed**
- [ ] Data integrity: ✓ Passed
- [ ] Referential integrity: ✓ Passed
- [ ] Business logic: ✓ Passed
- [ ] API functionality: ✓ Passed
- [ ] Performance: ✓ Acceptable

**Stakeholders Approved**
- [ ] Database Administrator: ✓ Approved
- [ ] Technical Lead: ✓ Approved
- [ ] Application Owner: ✓ Approved
- [ ] Operations Team: ✓ Approved

**Documentation Complete**
- [ ] Migration plan documented
- [ ] Issues/resolutions documented
- [ ] Verification results documented
- [ ] Rollback procedure tested

**Ready for Production Deployment**
- [ ] All checks passed: ✓ Yes / ✗ No
- [ ] Go/No-Go Decision: **GO** / **NO-GO**
- [ ] Migration Lead Sign-off: _________________ Date: _______
- [ ] Technical Lead Sign-off: _________________ Date: _______

---

## Sign-Off

**Migration Successfully Verified:** [Date] [Time]

**Verified By:** [Name] [Title]

**Signature:** _________________ **Date:** _______

**Approved By:** [Name] [Title]

**Signature:** _________________ **Date:** _______

---

**This checklist confirms that all data has been successfully migrated, verified, and is ready for production use.**
