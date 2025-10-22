# Database Migration Implementation Guide

**For:** Development and DevOps Teams
**Purpose:** Step-by-step instructions for executing database migration
**Duration:** 2-4 hours
**Estimated Downtime:** < 1 hour

---

## Quick Start (TL;DR)

```bash
# 1. Set up environment
export DB_HOST="localhost"
export DB_USER="root"
export DB_PASSWORD="password"
export DB_NAME="kharisma_db"

# 2. Create backup
./migrations/pre-migration/001_backup.sh

# 3. Run migration (from project root)
mysql -u $DB_USER -p$DB_PASSWORD < migrations/schema/001_create_new_tables.sql
mysql -u $DB_USER -p$DB_PASSWORD < migrations/data/001_migrate_users.sql
mysql -u $DB_USER -p$DB_PASSWORD < migrations/data/002_migrate_customers.sql
mysql -u $DB_USER -p$DB_PASSWORD < migrations/data/003_migrate_orders.sql
mysql -u $DB_USER -p$DB_PASSWORD < migrations/data/004_migrate_payments.sql

# 4. Verify
mysql -u $DB_USER -p$DB_PASSWORD < migrations/verification/001_verify_counts.sql

# 5. Switch application (update connection string)
# Update your application to point to kharisma_db_new
```

---

## Detailed Step-by-Step Guide

### Step 1: Preparation (30 minutes before migration)

#### 1.1 Verify Environment

Before starting, verify your database environment:

```bash
#!/bin/bash
# File: scripts/pre-migration-check.sh

echo "=== Pre-Migration Environment Check ==="

# Check database connectivity
echo "Testing database connection..."
mysql -h localhost -u root -p -e "SELECT VERSION();" || {
    echo "✗ Cannot connect to database"
    exit 1
}
echo "✓ Database connection successful"

# Check disk space
echo ""
echo "Checking disk space..."
FREE_SPACE=$(df /var/lib/mysql | awk 'NR==2 {print $4}')
REQUIRED_SPACE=$((5*1024*1024))

if [ $FREE_SPACE -lt $REQUIRED_SPACE ]; then
    echo "✗ Insufficient disk space. Need 5GB"
    exit 1
fi
echo "✓ Sufficient disk space available"

echo ""
echo "✓ All pre-migration checks passed!"
```

Run it:
```bash
chmod +x scripts/pre-migration-check.sh
./scripts/pre-migration-check.sh
```

#### 1.2 Create Full Backup

```bash
#!/bin/bash
# File: migrations/pre-migration/001_backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/migration-${TIMESTAMP}"
DB_NAME="kharisma_db"

mkdir -p ${BACKUP_DIR}

echo "[$(date)] Creating full database backup..."
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  ${DB_NAME} > ${BACKUP_DIR}/pre-migration-backup.sql

echo "[$(date)] Compressing backup..."
gzip ${BACKUP_DIR}/pre-migration-backup.sql

echo "[$(date)] ✓ Backup created: ${BACKUP_DIR}/pre-migration-backup.sql.gz"
echo "[$(date)] Backup size: $(du -h ${BACKUP_DIR}/pre-migration-backup.sql.gz | cut -f1)"

# Verify backup
if gzip -t "${BACKUP_DIR}/pre-migration-backup.sql.gz" 2>/dev/null; then
    echo "[$(date)] ✓ Backup integrity verified"
    echo ${BACKUP_DIR} > ./backups/.last-backup-location
else
    echo "[$(date)] ✗ Backup verification failed!"
    exit 1
fi
```

Run it:
```bash
chmod +x migrations/pre-migration/001_backup.sh
./migrations/pre-migration/001_backup.sh
```

---

### Step 2: Create New Database (5 minutes)

Create the new database and tables:

```bash
mysql -u root -p -e "
CREATE DATABASE IF NOT EXISTS kharisma_db_new
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;
"

# Verify
mysql -u root -p -e "SHOW DATABASES LIKE 'kharisma_db%';"
```

Create tables:
```bash
mysql -u root -p < migrations/schema/001_create_new_tables.sql
```

Check results:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SHOW TABLES;
SELECT COUNT(*) as table_count FROM information_schema.TABLES 
WHERE TABLE_SCHEMA='kharisma_db_new';
"
```

Expected: 7 tables created

---

### Step 3: Migrate Data (60-120 minutes)

#### 3.1 Stop Application (Recommended)

For zero-data-loss assurance:

```bash
# If using systemd
sudo systemctl stop kharisma-api
sudo systemctl stop kharisma-frontend

# Verify stopped
sudo systemctl status kharisma-api

echo "Application stopped at $(date)"
```

#### 3.2 Migrate User Data

```bash
echo "[$(date)] Migrating users..."
mysql -u root -p < migrations/data/001_migrate_users.sql
echo "[$(date)] Users migrated!"
```

Verify:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SELECT COUNT(*) as user_count FROM users;
SELECT role, COUNT(*) as count FROM users GROUP BY role;
"
```

#### 3.3 Migrate Customer Data

```bash
echo "[$(date)] Migrating customers..."
mysql -u root -p < migrations/data/002_migrate_customers.sql
echo "[$(date)] Customers migrated!"
```

Verify:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SELECT COUNT(*) as customer_count FROM customers;
SELECT customer_type, COUNT(*) as count FROM customers GROUP BY customer_type;
SELECT COUNT(*) as duplicate_phones FROM (
    SELECT phone, COUNT(*) FROM customers GROUP BY phone HAVING COUNT(*) > 1
) duplicates;
"
```

Expected: No duplicate phones (result: 0)

#### 3.4 Migrate Order Data

```bash
echo "[$(date)] Migrating orders..."
mysql -u root -p < migrations/data/003_migrate_orders.sql
echo "[$(date)] Orders migrated!"
```

Verify:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SELECT COUNT(*) as order_count FROM orders;
SELECT service_type, COUNT(*) as count FROM orders GROUP BY service_type;
"
```

#### 3.5 Migrate Payment Data

```bash
echo "[$(date)] Migrating payments..."
mysql -u root -p < migrations/data/004_migrate_payments.sql
echo "[$(date)] Payments migrated!"
```

Verify:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SELECT COUNT(*) as payment_count FROM payments;
SELECT status, COUNT(*) as count FROM payments GROUP BY status;
"
```

---

### Step 4: Verification (30 minutes)

Run all verification scripts:

```bash
echo "[$(date)] Starting verification phase..."

echo ""
echo "=== Checking row counts ==="
mysql -u root -p < migrations/verification/001_verify_counts.sql

echo ""
echo "=== Checking data integrity ==="
mysql -u root -p < migrations/verification/002_verify_integrity.sql

echo ""
echo "=== Checking business rules ==="
mysql -u root -p < migrations/verification/003_verify_business_rules.sql

echo ""
echo "[$(date)] Verification phase complete!"
```

Manual verification:
```bash
mysql -u root -p -e "
USE kharisma_db_new;

-- Check for orphaned records
SELECT 'Orphaned orders' as check_name, COUNT(*) as issue_count
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.id IS NULL;

-- Check for invalid prices
SELECT 'Negative prices' as check_name, COUNT(*) as issue_count
FROM orders
WHERE subtotal_price < 0 OR total_amount < 0;

-- Check data sample
SELECT 'Orders sample' as info;
SELECT o.id, o.order_number, c.name, o.service_type, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id
LIMIT 5;
"
```

---

### Step 5: Cutover (5-10 minutes)

#### 5.1 Update Connection String

```bash
# Option 1: Environment variable
export DB_NAME="kharisma_db_new"

# Option 2: Application config
sudo vi /etc/kharisma/config.env
# Change: DB_NAME=kharisma_db → DB_NAME=kharisma_db_new

# Option 3: Docker environment
# Update docker-compose.yml and restart
```

#### 5.2 Start Application

```bash
# If using systemd
sudo systemctl start kharisma-api
sudo systemctl start kharisma-frontend

# If using Docker
docker-compose up -d

# Verify application is running
sleep 5
curl http://localhost:3000/health
```

Expected: HTTP 200 with health status

#### 5.3 Test Application

```bash
#!/bin/bash
# File: scripts/test-migration.sh

echo "Testing application after migration..."

# Test authentication
echo "Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}')

echo "Login response: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.access_token')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo "✓ Authentication successful"
else
    echo "✗ Authentication failed"
    exit 1
fi

# Test data retrieval
echo ""
echo "Testing data retrieval..."
ORDERS=$(curl -s -X GET http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer $TOKEN")

ORDER_COUNT=$(echo $ORDERS | jq '.data | length')
echo "Orders retrieved: $ORDER_COUNT"

if [ "$ORDER_COUNT" -gt "0" ]; then
    echo "✓ Data retrieval successful"
else
    echo "✗ No data retrieved"
    exit 1
fi

echo ""
echo "✓ All application tests passed!"
```

Run it:
```bash
chmod +x scripts/test-migration.sh
./scripts/test-migration.sh
```

---

### Step 6: Post-Migration (15 minutes)

#### 6.1 Optimize Database

```bash
mysql -u root -p < migrations/post-migration/001_cleanup.sql
```

#### 6.2 Create Final Backup

```bash
chmod +x migrations/post-migration/003_final_backup.sh
./migrations/post-migration/003_final_backup.sh
```

#### 6.3 Notify Team

```bash
echo "Database migration completed at $(date)" | \
  mail -s "✓ Kharisma Abadi: DB Migration Complete" team@kharisma.local
```

---

## Troubleshooting

### Issue: "Access Denied for user 'root'@'localhost'"

Cause: MySQL password not entered correctly

Solution:
```bash
echo "Enter MySQL root password:"
read -s MYSQL_PASS

mysql -u root -p${MYSQL_PASS} -e "SELECT VERSION();"
```

### Issue: "Disk space full"

Check usage:
```bash
du -sh /var/lib/mysql/*
```

Clean up if needed:
```bash
rm -rf /var/lib/mysql/mysql.log.*  # Old log files
```

### Issue: "Foreign key constraint fails"

Cause: Orphaned records in data

Solution:
```bash
mysql -u root -p -e "
USE kharisma_db_new;
SELECT o.* FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.id IS NULL;
"

# Either fix the data or use SET FOREIGN_KEY_CHECKS=0; before migration
```

---

## Rollback Procedure

### Quick Rollback (< 5 minutes)

If application fails immediately after migration:

```bash
# 1. Stop application
sudo systemctl stop kharisma-api

# 2. Revert connection string
sudo sed -i 's/kharisma_db_new/kharisma_db/g' /etc/kharisma/config.env

# 3. Start application
sudo systemctl start kharisma-api

# 4. Verify
curl http://localhost:3000/health

echo "✓ Rollback complete - running on old database"
```

### Full Restore (if data corruption suspected)

```bash
# Find latest pre-migration backup
BACKUP=$(ls -t ./backups/migration-*/pre-migration-backup.sql.gz | head -1)

echo "Restoring from: $BACKUP"

# Drop new database
mysql -u root -p -e "DROP DATABASE kharisma_db_new;"

# Restore from backup
gzip -dc $BACKUP | mysql -u root -p kharisma_db

# Revert connection string
sudo sed -i 's/kharisma_db_new/kharisma_db/g' /etc/kharisma/config.env

# Restart application
sudo systemctl restart kharisma-api

echo "✓ Full restore complete"
```

---

## Complete Migration Script

```bash
#!/bin/bash
# File: migrations/run-migration.sh
# Complete automated migration script

set -e  # Exit on any error

echo "========================================="
echo "Kharisma Abadi Database Migration"
echo "========================================="
echo "Start time: $(date)"
echo ""

# Phase 1: Pre-Migration
echo "[PHASE 1] Pre-Migration (Backups & Validation)"
echo "Creating backup..."
./migrations/pre-migration/001_backup.sh || exit 1

echo "Validating schema..."
mysql -u root -p < migrations/pre-migration/002_validate_schema.sql || exit 1

echo "Capturing metrics..."
mysql -u root -p < migrations/pre-migration/003_baseline_metrics.sql || exit 1

# Phase 2: Schema Creation
echo ""
echo "[PHASE 2] Schema Creation"
mysql -u root -p < migrations/schema/001_create_new_tables.sql || exit 1

# Phase 3: Data Migration
echo ""
echo "[PHASE 3] Data Migration"
echo "Migrating users..."
mysql -u root -p < migrations/data/001_migrate_users.sql || exit 1

echo "Migrating customers..."
mysql -u root -p < migrations/data/002_migrate_customers.sql || exit 1

echo "Migrating orders..."
mysql -u root -p < migrations/data/003_migrate_orders.sql || exit 1

echo "Migrating payments..."
mysql -u root -p < migrations/data/004_migrate_payments.sql || exit 1

# Phase 4: Verification
echo ""
echo "[PHASE 4] Verification"
echo "Verifying counts..."
mysql -u root -p < migrations/verification/001_verify_counts.sql || exit 1

echo "Verifying integrity..."
mysql -u root -p < migrations/verification/002_verify_integrity.sql || exit 1

echo "Verifying business rules..."
mysql -u root -p < migrations/verification/003_verify_business_rules.sql || exit 1

# Phase 5: Post-Migration
echo ""
echo "[PHASE 5] Post-Migration"
echo "Optimizing database..."
mysql -u root -p < migrations/post-migration/001_cleanup.sql || exit 1

echo "Creating final backup..."
./migrations/post-migration/003_final_backup.sh || exit 1

echo ""
echo "========================================="
echo "✓ MIGRATION SUCCESSFUL!"
echo "========================================="
echo "End time: $(date)"
echo ""
echo "Next steps:"
echo "1. Update database connection string to 'kharisma_db_new'"
echo "2. Restart application"
echo "3. Run post-migration tests"
echo "4. Verify in production"
echo ""
```

Usage:
```bash
chmod +x migrations/run-migration.sh
./migrations/run-migration.sh
```

---

## Validation Checklist

Before declaring migration successful:

- [ ] Pre-migration backup created and verified
- [ ] All data migrated (check row counts)
- [ ] No referential integrity violations
- [ ] No duplicate order numbers or customer phones
- [ ] All prices are positive and reasonable
- [ ] Application starts without errors
- [ ] API endpoints respond correctly
- [ ] Sample data verified manually
- [ ] Performance acceptable (query times < 500ms)
- [ ] Post-migration backup created
- [ ] Team notified of completion

---

**Migration documentation completed. Ready for implementation.**
