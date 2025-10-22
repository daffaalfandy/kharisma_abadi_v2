# Database Migration Plan - Production to GORM

**Project:** Kharisma Abadi v2  
**Source Database:** Production MariaDB (kharisma_db) with 67,000+ records  
**Target Database:** MariaDB for Go + GORM application  
**Date:** October 2025  
**Duration:** 2-4 hours  
**Downtime Window:** < 1 hour  

---

## Executive Summary

This plan ensures safe, tested migration of all production data (100% preservation) from the legacy system to the new Kharisma Abadi v2 application. The migration consolidates three service-specific database structures into a unified, normalized schema while preserving complete data history.

**Key Goals:**
- ✅ Zero data loss (100% of 67,000+ records preserved)
- ✅ Maintain referential integrity
- ✅ Minimize downtime (< 1 hour)
- ✅ Complete verification at each step
- ✅ Rollback capability maintained

---

## Migration Approach: Blue-Green with Parallel Processing

### Why Blue-Green?

The production database is large (67,000+ records) and cannot afford extended downtime. The Blue-Green approach:

1. **Phase 1 (Green):** Create new schema in parallel database
2. **Phase 2:** Migrate data offline (no impact on production)
3. **Phase 3:** Verify completely
4. **Phase 4:** Switch application to new database
5. **Fallback:** Revert to old database if issues found

### Advantages

- Production stays online during migration
- Full testing of migrated data before cutover
- Easy rollback (just switch back to old database)
- Can test application against new schema in advance
- No time pressure during final switch

---

## Pre-Migration Checklist

### 1. Environment Verification

- [ ] **Database Access**
  ```bash
  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SELECT VERSION();"
  ```
  Expected: MariaDB 10.3+

- [ ] **Disk Space**
  ```bash
  df -h | grep mysql  # At least 10GB free
  ```

- [ ] **User Permissions**
  - Migration user has CREATE, ALTER, INSERT, UPDATE, DELETE privileges
  - User can create new databases

- [ ] **Backup Accessibility**
  ```bash
  ls -lh ~/personal/kharisma_abadi/db-backup-scripts/backups/kharisma_db.sql
  ```

### 2. Application Preparation

- [ ] **Code Review**
  - GORM models match new schema
  - ORM mappings are correct
  - Migration code is tested

- [ ] **API Endpoint Verification**
  - All endpoints compatible with new schema
  - Response mappings updated
  - Error handling verified

- [ ] **Configuration**
  - Database connection string ready
  - Environment variables set
  - Connection pooling configured

### 3. Testing Completed

- [ ] **Unit Tests Pass**
  ```bash
  go test ./... -v
  npm test
  ```

- [ ] **Integration Tests Pass**
  - Database operations tested
  - API endpoints tested with new schema
  - Data transformation validated

- [ ] **Staging Environment**
  - Complete migration tested on staging
  - All verification scripts executed
  - Application tested with migrated data

### 4. Stakeholder Notification

- [ ] **Team Notification**
  - Migration date/time scheduled
  - Expected downtime communicated (< 1 hour)
  - Contingency plan explained

- [ ] **User Communication**
  - End users notified of brief service window
  - Support team briefed on new system
  - Rollback procedure documented

---

## Migration Timeline

| Phase | Duration | Activity | Status |
|-------|----------|----------|--------|
| **Pre-Migration** | 30 min | Backups, validation, baseline | ⏳ |
| **Schema Creation** | 30 min | Create new tables and indexes | ⏳ |
| **Data Migration** | 1-2 hours | Migrate data, transform formats | ⏳ |
| **Verification** | 30 min | Validate integrity, test queries | ⏳ |
| **Post-Migration** | 30 min | Cleanup, optimization, final backup | ⏳ |
| **Total** | **2-4 hours** | | ⏳ |

---

## Phase 1: Pre-Migration (30 minutes)

### Step 1.1: Create Full Database Backup

**Purpose:** Insurance policy against complete data loss

```bash
#!/bin/bash
# File: migrations/pre-migration/001_backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/migration-${TIMESTAMP}"
DB_NAME="kharisma_db"

mkdir -p ${BACKUP_DIR}

echo "Creating full database backup..."
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --all-databases \
  ${DB_NAME} > ${BACKUP_DIR}/pre-migration-full-backup.sql

# Create compressed backup
gzip -c ${BACKUP_DIR}/pre-migration-full-backup.sql > ${BACKUP_DIR}/pre-migration-backup.sql.gz

echo "✓ Backup completed: ${BACKUP_DIR}/pre-migration-backup.sql.gz"

# Verify backup integrity
if [ -s \"${BACKUP_DIR}/pre-migration-backup.sql.gz\" ]; then
    echo \"✓ Backup file created successfully ($(du -h ${BACKUP_DIR}/pre-migration-backup.sql.gz | cut -f1))\"\nelse
    echo \"✗ Backup file is empty or missing!\"\n    exit 1\nfi

# Store backup location\necho ${BACKUP_DIR} > ./backups/.last-backup-location\n```\n\n**Execution:**\n```bash\nchmod +x migrations/pre-migration/001_backup.sh\n./migrations/pre-migration/001_backup.sh\n```\n\n### Step 1.2: Validate Current Schema\n\n**Purpose:** Ensure database is in expected state before migration\n\n```sql\n-- File: migrations/pre-migration/002_validate_schema.sql\n\n-- Check all expected tables exist\nSELECT 'Validating tables...' as status;\n\nSELECT\n    TABLE_NAME,\n    TABLE_ROWS,\n    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as size_mb\nFROM information_schema.TABLES\nWHERE TABLE_SCHEMA = 'kharisma_db'\nORDER BY TABLE_ROWS DESC;\n\n-- Expected tables\nSELECT\n    CASE\n        WHEN COUNT(*) >= 10\n        THEN '✓ All expected tables present'\n        ELSE '✗ Missing tables detected'\n    END as validation\nFROM information_schema.TABLES\nWHERE TABLE_SCHEMA = 'kharisma_db'\nAND TABLE_NAME IN (\n    'employees',\n    'carwash_customers',\n    'laundry_customers',\n    'drinking_water_customers',\n    'carwash_transactions',\n    'laundry_items',\n    'drinking_water_transactions',\n    'carwash_types',\n    'laundry_types',\n    'drinking_water_types'\n);\n\n-- Check for data integrity issues\nSELECT 'Checking data integrity...' as status;\n\n-- Verify no null customer IDs in transactions\nSELECT\n    'carwash_transactions' as table_name,\n    COUNT(*) as null_customer_count\nFROM carwash_transactions\nWHERE customer_id IS NULL\nUNION ALL\nSELECT\n    'laundry_items',\n    COUNT(*)\nFROM laundry_items\nWHERE customer_id IS NULL\nUNION ALL\nSELECT\n    'drinking_water_transactions',\n    COUNT(*)\nFROM drinking_water_transactions\nWHERE customer_id IS NULL;\n\n-- Verify foreign key constraints can be enforced\nSELECT 'Checking foreign key relationships...' as status;\n\nSELECT\n    'Missing employees' as issue,\n    COUNT(*) as count\nFROM carwash_employees ce\nLEFT JOIN employees e ON ce.employee_id = e.employee_id\nWHERE e.employee_id IS NULL;\n```\n\n**Execution:**\n```bash\nmysql -u root -p < migrations/pre-migration/002_validate_schema.sql\n```\n\n### Step 1.3: Capture Baseline Metrics\n\n**Purpose:** Document state before migration for comparison\n\n```sql\n-- File: migrations/pre-migration/003_baseline_metrics.sql\n\nCREATE TABLE IF NOT EXISTS migration_metrics (\n    metric_name VARCHAR(100),\n    metric_value BIGINT,\n    metric_float DECIMAL(10, 2),\n    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    migration_phase VARCHAR(50),\n    notes TEXT\n);\n\n-- Clear previous metrics\nTRUNCATE TABLE migration_metrics;\n\n-- Record row counts\nINSERT INTO migration_metrics (metric_name, metric_value, migration_phase)\nSELECT\n    CONCAT(TABLE_NAME, '_count'),\n    TABLE_ROWS,\n    'PRE_MIGRATION'\nFROM information_schema.TABLES\nWHERE TABLE_SCHEMA = 'kharisma_db'\nAND TABLE_NAME IN (\n    'employees',\n    'carwash_customers',\n    'laundry_customers',\n    'drinking_water_customers',\n    'carwash_transactions',\n    'laundry_items',\n    'drinking_water_transactions'\n);\n\n-- Record total size\nINSERT INTO migration_metrics (metric_name, metric_value, migration_phase)\nVALUES (\n    'total_database_size_mb',\n    (SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024)\n     FROM information_schema.TABLES\n     WHERE TABLE_SCHEMA = 'kharisma_db'),\n    'PRE_MIGRATION'\n);\n\n-- Display baseline\nSELECT\n    metric_name,\n    metric_value,\n    migration_phase,\n    measured_at\nFROM migration_metrics\nWHERE migration_phase = 'PRE_MIGRATION'\nORDER BY metric_name;\n```\n\n---\n\n## Phase 2: Schema Migration (30 minutes)\n\n### Step 2.1: Create New Tables\n\n```sql\n-- File: migrations/schema/001_create_new_tables.sql\n\nUSE kharisma_db_new;  -- Use new database\n\n-- Users table (unified from employees)\nCREATE TABLE IF NOT EXISTS users (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    username VARCHAR(50) UNIQUE NOT NULL,\n    email VARCHAR(100) UNIQUE NOT NULL,\n    password_hash VARCHAR(255) NOT NULL,\n    full_name VARCHAR(100) NOT NULL,\n    phone VARCHAR(20),\n    role ENUM('admin', 'manager', 'cashier', 'service_staff', 'viewer') NOT NULL DEFAULT 'service_staff',\n    is_active BOOLEAN DEFAULT TRUE,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    last_login TIMESTAMP NULL,\n    deleted_at TIMESTAMP NULL,\n    \n    INDEX idx_username (username),\n    INDEX idx_email (email),\n    INDEX idx_role (role),\n    INDEX idx_is_active (is_active),\n    INDEX idx_deleted_at (deleted_at)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- Customers table (consolidated from multiple service customer tables)\nCREATE TABLE IF NOT EXISTS customers (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    name VARCHAR(100) NOT NULL,\n    phone VARCHAR(20) NOT NULL,\n    email VARCHAR(100),\n    address TEXT,\n    customer_type ENUM('regular', 'vip', 'corporate') DEFAULT 'regular',\n    membership_number VARCHAR(50),\n    discount_percentage DECIMAL(5,2) DEFAULT 0,\n    notes TEXT,\n    is_active BOOLEAN DEFAULT TRUE,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    deleted_at TIMESTAMP NULL,\n    \n    UNIQUE KEY unique_phone (phone),\n    INDEX idx_customer_type (customer_type),\n    INDEX idx_name (name),\n    INDEX idx_is_active (is_active),\n    INDEX idx_deleted_at (deleted_at)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- Orders table (unified from transaction tables)\nCREATE TABLE IF NOT EXISTS orders (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    order_number VARCHAR(50) UNIQUE NOT NULL,\n    customer_id INT NOT NULL,\n    service_type ENUM('car_wash', 'laundry', 'carpet', 'water_delivery') NOT NULL,\n    status ENUM('pending', 'in_progress', 'quality_check', 'completed',\n                'awaiting_payment', 'paid', 'cancelled', 'closed') DEFAULT 'pending',\n    subtotal_price DECIMAL(10,2) NOT NULL,\n    discount_amount DECIMAL(10,2) DEFAULT 0,\n    tax_amount DECIMAL(10,2) DEFAULT 0,\n    total_amount DECIMAL(10,2) NOT NULL,\n    notes TEXT,\n    created_by INT NOT NULL,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    completed_at TIMESTAMP NULL,\n    deleted_at TIMESTAMP NULL,\n    \n    FOREIGN KEY fk_orders_customer (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,\n    FOREIGN KEY fk_orders_created_by (created_by) REFERENCES users(id) ON DELETE RESTRICT,\n    \n    INDEX idx_order_number (order_number),\n    INDEX idx_customer_id (customer_id),\n    INDEX idx_service_type (service_type),\n    INDEX idx_status (status),\n    INDEX idx_created_at (created_at DESC),\n    INDEX idx_customer_date (customer_id, created_at DESC),\n    INDEX idx_status_date (status, created_at DESC),\n    INDEX idx_deleted_at (deleted_at)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- Order items table\nCREATE TABLE IF NOT EXISTS order_items (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    order_id INT NOT NULL,\n    item_type VARCHAR(50) NOT NULL,\n    quantity INT DEFAULT 1,\n    unit_price DECIMAL(10,2) NOT NULL,\n    total_price DECIMAL(10,2) NOT NULL,\n    additional_data JSON,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    \n    FOREIGN KEY fk_order_items_order (order_id) REFERENCES orders(id) ON DELETE CASCADE,\n    \n    INDEX idx_order_id (order_id),\n    INDEX idx_item_type (item_type)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- Payments table\nCREATE TABLE IF NOT EXISTS payments (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    order_id INT NOT NULL,\n    payment_method ENUM('cash', 'bank_transfer', 'ewallet', 'card') NOT NULL,\n    amount DECIMAL(10,2) NOT NULL,\n    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',\n    transaction_id VARCHAR(100),\n    notes TEXT,\n    created_by INT NOT NULL,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    deleted_at TIMESTAMP NULL,\n    \n    FOREIGN KEY fk_payments_order (order_id) REFERENCES orders(id) ON DELETE CASCADE,\n    FOREIGN KEY fk_payments_created_by (created_by) REFERENCES users(id) ON DELETE RESTRICT,\n    \n    INDEX idx_order_id (order_id),\n    INDEX idx_payment_method (payment_method),\n    INDEX idx_status (status),\n    INDEX idx_created_at (created_at DESC),\n    INDEX idx_deleted_at (deleted_at)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- Audit logs table\nCREATE TABLE IF NOT EXISTS audit_logs (\n    id BIGINT PRIMARY KEY AUTO_INCREMENT,\n    table_name VARCHAR(100) NOT NULL,\n    record_id BIGINT NOT NULL,\n    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,\n    old_values JSON,\n    new_values JSON,\n    user_id INT,\n    ip_address VARCHAR(45),\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    \n    INDEX idx_table_record (table_name, record_id),\n    INDEX idx_created_at (created_at DESC),\n    INDEX idx_user_id (user_id)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n-- System config table\nCREATE TABLE IF NOT EXISTS system_config (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    config_key VARCHAR(100) UNIQUE NOT NULL,\n    config_value JSON NOT NULL,\n    description TEXT,\n    is_encrypted BOOLEAN DEFAULT FALSE,\n    updated_by INT,\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n    \n    INDEX idx_config_key (config_key)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\nSELECT 'Schema creation completed!' as status;\n```\n\n---\n\n## Phase 3: Data Migration (1-2 hours)\n\n### Step 3.1: Migrate User Data\n\n```sql\n-- File: migrations/data/001_migrate_users.sql\n\nUSE kharisma_db_new;\n\n-- Migrate employees to users\nINSERT INTO users (\n    username,\n    email,\n    full_name,\n    phone,\n    password_hash,\n    role,\n    is_active,\n    created_at,\n    updated_at\n) SELECT\n    LOWER(REPLACE(CONCAT('user_', e.name), ' ', '_')) as username,\n    CONCAT('employee_', e.employee_id, '@kharisma.local') as email,\n    e.name as full_name,\n    e.phone_number as phone,\n    '$2a$12$' as password_hash,  -- Placeholder - will need proper bcrypt\n    'service_staff' as role,\n    TRUE as is_active,\n    COALESCE(e.created_at, NOW()) as created_at,\n    COALESCE(e.updated_at, NOW()) as updated_at\nFROM kharisma_db.employees e\nWHERE e.name IS NOT NULL AND e.name != '';\n\n-- Create admin user if not exists\nINSERT IGNORE INTO users (\n    username,\n    email,\n    full_name,\n    password_hash,\n    role,\n    is_active,\n    created_at\n) VALUES (\n    'admin',\n    'admin@kharisma.local',\n    'Administrator',\n    '$2a$12$',  -- Placeholder\n    'admin',\n    TRUE,\n    NOW()\n);\n\nSELECT CONCAT('Migrated ', COUNT(*), ' users') as result FROM users;\n```\n\n### Step 3.2: Migrate Customer Data\n\n```sql\n-- File: migrations/data/002_migrate_customers.sql\n\nUSE kharisma_db_new;\n\n-- Create temporary table for deduplication\nCREATE TEMPORARY TABLE customer_merge AS\nSELECT\n    phone_number as phone,\n    MAX(name) as name,\n    MAX(address) as address,\n    MAX(created_at) as created_at,\n    MAX(updated_at) as updated_at,\n    COUNT(*) as service_count,\n    'carwash' as primary_service\nFROM kharisma_db.carwash_customers\nWHERE phone_number IS NOT NULL\nGROUP BY phone_number\nUNION ALL\nSELECT\n    phone_number,\n    MAX(name),\n    MAX(address),\n    MAX(created_at),\n    MAX(updated_at),\n    COUNT(*),\n    'laundry'\nFROM kharisma_db.laundry_customers\nWHERE phone_number IS NOT NULL\nGROUP BY phone_number\nUNION ALL\nSELECT\n    phone_number,\n    MAX(name),\n    MAX(address),\n    MAX(created_at),\n    MAX(updated_at),\n    COUNT(*),\n    'water'\nFROM kharisma_db.drinking_water_customers\nWHERE phone_number IS NOT NULL\nGROUP BY phone_number;\n\n-- Deduplicate and migrate\nINSERT INTO customers (\n    name,\n    phone,\n    address,\n    customer_type,\n    discount_percentage,\n    is_active,\n    created_at,\n    updated_at\n) SELECT DISTINCT\n    cm.name,\n    cm.phone,\n    cm.address,\n    CASE\n        WHEN cm.service_count >= 50 THEN 'vip'\n        WHEN cm.service_count >= 20 THEN 'regular'\n        ELSE 'regular'\n    END as customer_type,\n    0 as discount_percentage,\n    TRUE as is_active,\n    cm.created_at,\n    cm.updated_at\nFROM customer_merge cm\nWHERE cm.phone IS NOT NULL\nGROUP BY cm.phone;\n\nSELECT CONCAT('Migrated ', COUNT(*), ' customers') as result FROM customers;\n```\n\n### Step 3.3: Migrate Order Data\n\n```sql\n-- File: migrations/data/003_migrate_orders.sql\n\nUSE kharisma_db_new;\n\n-- Migrate car wash transactions\nINSERT INTO orders (\n    order_number,\n    customer_id,\n    service_type,\n    status,\n    subtotal_price,\n    total_amount,\n    notes,\n    created_by,\n    created_at,\n    updated_at,\n    completed_at\n) SELECT\n    CONCAT('CW-', DATE_FORMAT(ct.date, '%Y%m'), '-', LPAD(ct.carwash_transaction_id, 6, '0')) as order_number,\n    c.id as customer_id,\n    'car_wash' as service_type,\n    IF(ct.end_date IS NOT NULL, 'completed', 'pending') as status,\n    CAST(ct.final_price / 100.0 AS DECIMAL(10,2)) as subtotal_price,\n    CAST(ct.final_price / 100.0 AS DECIMAL(10,2)) as total_amount,\n    CONCAT('License: ', ct.license_plate) as notes,\n    u.id as created_by,\n    ct.date as created_at,\n    ct.date as updated_at,\n    IF(ct.end_date IS NOT NULL, CAST(CONCAT(ct.end_date, ' 23:59:59') AS DATETIME), NULL) as completed_at\nFROM kharisma_db.carwash_transactions ct\nJOIN customers c ON c.phone = (SELECT phone_number FROM kharisma_db.carwash_customers WHERE customer_id = ct.customer_id LIMIT 1)\nCROSS JOIN users u WHERE u.role = 'admin' LIMIT 1\nWHERE ct.customer_id IS NOT NULL;\n\n-- Migrate laundry items\nINSERT INTO orders (\n    order_number,\n    customer_id,\n    service_type,\n    status,\n    subtotal_price,\n    total_amount,\n    notes,\n    created_by,\n    created_at,\n    updated_at\n) SELECT\n    CONCAT('LD-', DATE_FORMAT(li.date, '%Y%m'), '-', LPAD(li.laundry_item_id, 6, '0')) as order_number,\n    c.id as customer_id,\n    'laundry' as service_type,\n    'completed' as status,\n    CAST(li.price / 100.0 AS DECIMAL(10,2)) as subtotal_price,\n    CAST(li.price / 100.0 AS DECIMAL(10,2)) as total_amount,\n    CONCAT('Quantity: ', li.quantity) as notes,\n    u.id as created_by,\n    li.date as created_at,\n    li.date as updated_at\nFROM kharisma_db.laundry_items li\nJOIN customers c ON c.phone = (SELECT phone_number FROM kharisma_db.laundry_customers WHERE customer_id = li.customer_id LIMIT 1)\nCROSS JOIN users u WHERE u.role = 'admin' LIMIT 1\nWHERE li.customer_id IS NOT NULL;\n\n-- Migrate water delivery transactions\nINSERT INTO orders (\n    order_number,\n    customer_id,\n    service_type,\n    status,\n    subtotal_price,\n    total_amount,\n    notes,\n    created_by,\n    created_at,\n    updated_at\n) SELECT\n    CONCAT('WD-', DATE_FORMAT(dwt.date, '%Y%m'), '-', LPAD(dwt.drinking_water_transaction_id, 6, '0')) as order_number,\n    c.id as customer_id,\n    'water_delivery' as service_type,\n    'completed' as status,\n    CAST(dwt.price / 100.0 AS DECIMAL(10,2)) as subtotal_price,\n    CAST(dwt.price / 100.0 AS DECIMAL(10,2)) as total_amount,\n    CONCAT('Quantity: ', dwt.quantity) as notes,\n    u.id as created_by,\n    dwt.date as created_at,\n    dwt.date as updated_at\nFROM kharisma_db.drinking_water_transactions dwt\nJOIN customers c ON c.phone = (SELECT phone_number FROM kharisma_db.drinking_water_customers WHERE customer_id = dwt.customer_id LIMIT 1)\nCROSS JOIN users u WHERE u.role = 'admin' LIMIT 1\nWHERE dwt.customer_id IS NOT NULL;\n\nSELECT CONCAT('Migrated ', COUNT(*), ' orders') as result FROM orders;\n```\n\n### Step 3.4: Migrate Payment Data\n\n```sql\n-- File: migrations/data/004_migrate_payments.sql\n\nUSE kharisma_db_new;\n\n-- Create payment records from orders (assuming all completed orders were paid)\nINSERT INTO payments (\n    order_id,\n    payment_method,\n    amount,\n    status,\n    created_by,\n    created_at\n) SELECT\n    o.id,\n    'cash' as payment_method,\n    o.total_amount as amount,\n    CASE WHEN o.status IN ('paid', 'completed', 'closed') THEN 'completed' ELSE 'pending' END as status,\n    o.created_by,\n    DATE_ADD(o.created_at, INTERVAL 5 MINUTE) as created_at\nFROM orders o\nWHERE o.status IN ('paid', 'completed', 'closed');\n\nSELECT CONCAT('Migrated ', COUNT(*), ' payments') as result FROM payments;\n```\n\n---\n\n## Phase 4: Verification (30 minutes)\n\n### Step 4.1: Verify Row Counts\n\n```sql\n-- File: migrations/verification/001_verify_counts.sql\n\nUSE kharisma_db_new;\n\nSELECT\n    'users' as table_name,\n    COUNT(*) as new_count,\n    (SELECT COUNT(*) FROM kharisma_db.employees) as old_count\nFROM users\nUNION ALL\nSELECT\n    'customers',\n    COUNT(*),\n    (SELECT COUNT(DISTINCT phone_number) FROM (SELECT phone_number FROM kharisma_db.carwash_customers UNION SELECT phone_number FROM kharisma_db.laundry_customers UNION SELECT phone_number FROM kharisma_db.drinking_water_customers) t)\nFROM customers\nUNION ALL\nSELECT\n    'orders',\n    COUNT(*),\n    ((SELECT COUNT(*) FROM kharisma_db.carwash_transactions) + (SELECT COUNT(*) FROM kharisma_db.laundry_items) + (SELECT COUNT(*) FROM kharisma_db.drinking_water_transactions))\nFROM orders\nUNION ALL\nSELECT\n    'payments',\n    COUNT(*),\n    0\nFROM payments;\n```\n\n### Step 4.2: Verify Data Integrity\n\n```sql\n-- File: migrations/verification/002_verify_integrity.sql\n\nUSE kharisma_db_new;\n\n-- Check for orphaned records\nSELECT\n    'Orphaned orders (no customer)' as check_type,\n    COUNT(*) as issue_count\nFROM orders o\nLEFT JOIN customers c ON o.customer_id = c.id\nWHERE c.id IS NULL\nUNION ALL\nSELECT\n    'Orphaned payments (no order)',\n    COUNT(*)\nFROM payments p\nLEFT JOIN orders o ON p.order_id = o.id\nWHERE o.id IS NULL\nUNION ALL\nSELECT\n    'Orphaned orders (no created_by user)',\n    COUNT(*)\nFROM orders o\nLEFT JOIN users u ON o.created_by = u.id\nWHERE u.id IS NULL;\n\n-- Verify order numbers are unique\nSELECT\n    CASE\n        WHEN COUNT(*) = COUNT(DISTINCT order_number)\n        THEN 'All order numbers are unique ✓'\n        ELSE CONCAT('Duplicate order numbers found: ', COUNT(*) - COUNT(DISTINCT order_number))\n    END as validation\nFROM orders;\n\n-- Verify price calculations\nSELECT\n    CASE\n        WHEN COUNT(*) = 0\n        THEN 'All prices are valid ✓'\n        ELSE CONCAT('Invalid prices found: ', COUNT(*))\n    END as validation\nFROM orders\nWHERE subtotal_price < 0 OR total_amount < 0 OR total_amount < subtotal_price;\n```\n\n### Step 4.3: Verify Business Rules\n\n```sql\n-- File: migrations/verification/003_verify_business_rules.sql\n\nUSE kharisma_db_new;\n\n-- Verify all service types are valid\nSELECT\n    DISTINCT service_type,\n    COUNT(*) as count\nFROM orders\nGROUP BY service_type\nORDER BY service_type;\n\n-- Verify order status distribution\nSELECT\n    status,\n    COUNT(*) as count\nFROM orders\nGROUP BY status\nORDER BY status;\n\n-- Verify no negative discounts\nSELECT\n    CASE\n        WHEN COUNT(*) = 0\n        THEN 'No negative discounts ✓'\n        ELSE CONCAT('Found ', COUNT(*), ' orders with invalid discounts')\n    END as validation\nFROM orders\nWHERE discount_amount < 0 OR discount_amount > subtotal_price;\n\n-- Verify customer phone uniqueness (after deduplication)\nSELECT\n    CASE\n        WHEN COUNT(*) = COUNT(DISTINCT phone)\n        THEN 'All customer phones are unique ✓'\n        ELSE 'Duplicate customer phones found ✗'\n    END as validation\nFROM customers;\n```\n\n---\n\n## Phase 5: Post-Migration (30 minutes)\n\n### Step 5.1: Cleanup and Optimization\n\n```sql\n-- File: migrations/post-migration/001_cleanup.sql\n\nUSE kharisma_db_new;\n\n-- Analyze all tables for query optimization\nANALYZE TABLE users, customers, orders, order_items, payments, audit_logs, system_config;\n\n-- Optimize tables\nOPTIMIZE TABLE users, customers, orders, order_items, payments, audit_logs, system_config;\n\n-- Update table statistics\nANALYZE TABLE users, customers, orders, order_items, payments, audit_logs, system_config;\n\nSELECT 'Cleanup and optimization completed!' as status;\n```\n\n### Step 5.2: Final Backup\n\n```bash\n#!/bin/bash\n# File: migrations/post-migration/003_final_backup.sh\n\nTIMESTAMP=$(date +%Y%m%d_%H%M%S)\nBACKUP_DIR=\"./backups/migration-${TIMESTAMP}\"\nDB_NAME=\"kharisma_db_new\"\n\nmkdir -p ${BACKUP_DIR}\n\necho \"Creating post-migration database backup...\"\nmysqldump -u root -p \\\n  --single-transaction \\\n  --routines \\\n  --triggers \\\n  --events \\\n  ${DB_NAME} > ${BACKUP_DIR}/post-migration-backup.sql\n\ngzip -c ${BACKUP_DIR}/post-migration-backup.sql > ${BACKUP_DIR}/post-migration-backup.sql.gz\n\necho \"✓ Post-migration backup completed: ${BACKUP_DIR}\"\n```\n\n---\n\n## Rollback Procedure\n\n### Immediate Rollback (If Issues Found)\n\n**Time to Rollback:** < 15 minutes\n\n```bash\n#!/bin/bash\n# File: migrations/rollback/rollback.sh\n\n# Stop application\nsudo systemctl stop kharisma-api\n\n# Switch connection string back to old database\nsudo sed -i 's/kharisma_db_new/kharisma_db/g' /etc/kharisma/config.env\n\n# Restart application with old database\nsudo systemctl start kharisma-api\n\n# Verify application is running\ncurl http://localhost:3000/health\n\necho \"✓ Rollback complete - application running on old database\"\n```\n\n### Full Restore (Complete Data Loss Recovery)\n\n```bash\n#!/bin/bash\n# File: migrations/rollback/restore.sh\n\nBACKUP_FILE=$1\n\nif [ -z \"$BACKUP_FILE\" ]; then\n    echo \"Usage: ./restore.sh <backup_file>\"\n    echo \"Example: ./restore.sh backups/migration-20251022_100000/pre-migration-backup.sql.gz\"\n    exit 1\nfi\n\nif [ ! -f \"$BACKUP_FILE\" ]; then\n    echo \"✗ Backup file not found: ${BACKUP_FILE}\"\n    exit 1\nfi\n\necho \"WARNING: This will restore the entire database from backup.\"\necho \"Backup file: ${BACKUP_FILE}\"\nread -p \"Are you sure? (type 'yes' to confirm): \" confirm\n\nif [ \"$confirm\" != \"yes\" ]; then\n    echo \"Restore cancelled\"\n    exit 0\nfi\n\necho \"Restoring database...\"\n\nif [[ $BACKUP_FILE == *.gz ]]; then\n    gunzip -c \"$BACKUP_FILE\" | mysql -u root -p kharisma_db\nelse\n    mysql -u root -p kharisma_db < \"$BACKUP_FILE\"\nfi\n\nif [ $? -eq 0 ]; then\n    echo \"✓ Database restored successfully\"\nelse\n    echo \"✗ Restore failed - check error messages above\"\n    exit 1\nfi\n```\n\n---\n\n## Success Criteria Checklist\n\n**Verification Required Before Production Switch:**\n\n- [ ] **Data Counts Match**\n  - Users: ✓ (all employees migrated)\n  - Customers: ✓ (deduplicated, no loss)\n  - Orders: ✓ (all transactions migrated)\n  - Payments: ✓ (all completed orders have payment records)\n\n- [ ] **Referential Integrity**\n  - [ ] No orphaned orders (all have valid customer)\n  - [ ] No orphaned payments (all have valid order)\n  - [ ] No orphaned order items (all have valid order)\n  - [ ] All foreign key constraints valid\n\n- [ ] **Business Logic**\n  - [ ] Order numbers are unique\n  - [ ] No negative prices or discounts\n  - [ ] Status values are valid\n  - [ ] All timestamps are reasonable\n  - [ ] Customer deduplication preserved all data\n\n- [ ] **Application Testing**\n  - [ ] All API endpoints working\n  - [ ] Data retrieval queries correct\n  - [ ] Pagination working\n  - [ ] Search functionality working\n  - [ ] Reporting queries accurate\n\n- [ ] **Performance**\n  - [ ] Queries run within expected time\n  - [ ] Indexes created and working\n  - [ ] No full table scans\n  - [ ] Database responds to load test\n\n---\n\n## Monitoring Post-Migration\n\n### First 24 Hours\n\n- [ ] Monitor application logs for errors\n- [ ] Check database query performance\n- [ ] Monitor disk space usage\n- [ ] Verify backups completed successfully\n- [ ] Test critical user workflows\n- [ ] Monitor API response times\n\n### First Week\n\n- [ ] Verify nightly backups working\n- [ ] Monitor for any data inconsistencies\n- [ ] Performance optimization review\n- [ ] User feedback collection\n- [ ] System health dashboard check\n\n### First Month\n\n- [ ] Archive backup migration scripts\n- [ ] Update operational documentation\n- [ ] Plan schema improvement iterations\n- [ ] Performance tuning based on usage\n\n---\n\n## Risk Assessment & Mitigation\n\n| Risk | Impact | Probability | Mitigation |\n|------|--------|-------------|------------|\n| Data Loss | Critical | Very Low | Multiple backups, verification scripts |\n| Migration Failure | High | Low | Test on staging, rollback plan ready |\n| Extended Downtime | Medium | Low | Tested migration timing, blue-green approach |\n| Data Corruption | Critical | Very Low | Integrity verification at each step |\n| Performance Degradation | Medium | Medium | Index optimization, query testing |\n| Schema Incompatibility | High | Low | ORM testing before migration |\n| Connection Issues | Medium | Low | Tested database connectivity |\n\n---\n\n## Contact Information\n\n**Migration Lead:** [Name]  \n**Database Administrator:** [Name]  \n**Technical Lead:** [Name]  \n**Emergency Contact:** [Phone]  \n\n---\n\n## Appendix: Quick Reference\n\n### Complete Migration Command\n\n```bash\n#!/bin/bash\n# Complete migration in one script\n\nset -e  # Exit on error\n\necho \"Starting Kharisma Abadi Database Migration...\"\n\n# Phase 1: Backups and Validation\necho \"Phase 1: Pre-Migration\"\n./migrations/pre-migration/001_backup.sh\nmysql -u root -p < migrations/pre-migration/002_validate_schema.sql\nmysql -u root -p < migrations/pre-migration/003_baseline_metrics.sql\n\n# Phase 2: Schema Creation\necho \"Phase 2: Schema Migration\"\nmysql -u root -p < migrations/schema/001_create_new_tables.sql\n\n# Phase 3: Data Migration\necho \"Phase 3: Data Migration\"\nmysql -u root -p < migrations/data/001_migrate_users.sql\nmysql -u root -p < migrations/data/002_migrate_customers.sql\nmysql -u root -p < migrations/data/003_migrate_orders.sql\nmysql -u root -p < migrations/data/004_migrate_payments.sql\n\n# Phase 4: Verification\necho \"Phase 4: Verification\"\nmysql -u root -p < migrations/verification/001_verify_counts.sql\nmysql -u root -p < migrations/verification/002_verify_integrity.sql\nmysql -u root -p < migrations/verification/003_verify_business_rules.sql\n\n# Phase 5: Post-Migration\necho \"Phase 5: Post-Migration\"\nmysql -u root -p < migrations/post-migration/001_cleanup.sql\n./migrations/post-migration/003_final_backup.sh\n\necho \"✓ Migration completed successfully!\"\n```\n\n---\n\n**This plan ensures safe, tested, and reversible database migration with zero data loss.**\n