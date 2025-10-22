#!/bin/bash

# ============================================================================
# Backend Environment Validation Script
# ============================================================================
#
# Purpose: Validate that all required environment variables are set
#          and have appropriate values for the current environment
#
# Usage:
#   chmod +x backend/scripts/validate-env.sh
#   ./backend/scripts/validate-env.sh [development|production]
#
# Exit codes:
#   0 = All validations passed
#   1 = One or more validations failed
#
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for validation results
PASSED=0
FAILED=0
WARNINGS=0

# Get environment from argument or default to development
ENVIRONMENT="${1:-development}"

# Determine which .env file to validate
if [ -f "backend/.env.${ENVIRONMENT}" ]; then
    ENV_FILE="backend/.env.${ENVIRONMENT}"
elif [ -f ".env.${ENVIRONMENT}" ]; then
    ENV_FILE=".env.${ENVIRONMENT}"
elif [ -f "backend/.env" ]; then
    ENV_FILE="backend/.env"
else
    echo -e "${RED}✗ Error: No .env file found for environment: $ENVIRONMENT${NC}"
    echo "  Looked for: backend/.env.${ENVIRONMENT} or .env.${ENVIRONMENT}"
    exit 1
fi

echo "=========================================="
echo "Backend Environment Validation"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Config file: $ENV_FILE"
echo ""

# Load environment variables from file
set -a
source "$ENV_FILE" 2>/dev/null || {
    echo -e "${RED}✗ Error: Cannot read $ENV_FILE${NC}"
    exit 1
}
set +a

# ============================================================================
# Validation Functions
# ============================================================================

# Check if variable exists and is not empty
check_required() {
    local var_name=$1
    local var_value=${!var_name:-}

    if [ -z "$var_value" ]; then
        echo -e "${RED}✗ REQUIRED: $var_name is not set${NC}"
        ((FAILED++))
        return 1
    else
        echo -e "${GREEN}✓ REQUIRED: $var_name is set${NC}"
        ((PASSED++))
        return 0
    fi
}

# Check if variable exists and is not empty
check_optional() {
    local var_name=$1
    local var_value=${!var_name:-}

    if [ -z "$var_value" ]; then
        echo -e "${YELLOW}⚠ OPTIONAL: $var_name is not set (using default)${NC}"
        ((WARNINGS++))
        return 0
    else
        echo -e "${GREEN}✓ OPTIONAL: $var_name is set${NC}"
        ((PASSED++))
        return 0
    fi
}

# Check if variable is a valid boolean
check_boolean() {
    local var_name=$1
    local var_value=${!var_name:-}

    if [[ ! "$var_value" =~ ^(true|false|True|False|TRUE|FALSE|0|1)$ ]]; then
        echo -e "${RED}✗ BOOLEAN: $var_name has invalid value '$var_value' (must be true/false)${NC}"
        ((FAILED++))
        return 1
    else
        echo -e "${GREEN}✓ BOOLEAN: $var_name = $var_value${NC}"
        ((PASSED++))
        return 0
    fi
}

# Check if variable is a valid port number
check_port() {
    local var_name=$1
    local var_value=${!var_name:-}

    if [[ ! "$var_value" =~ ^[0-9]+$ ]] || [ "$var_value" -lt 1 ] || [ "$var_value" -gt 65535 ]; then
        echo -e "${RED}✗ PORT: $var_name has invalid port '$var_value' (must be 1-65535)${NC}"
        ((FAILED++))
        return 1
    else
        echo -e "${GREEN}✓ PORT: $var_name = $var_value${NC}"
        ((PASSED++))
        return 0
    fi
}

# Check if variable matches a pattern
check_pattern() {
    local var_name=$1
    local pattern=$2
    local var_value=${!var_name:-}

    if [[ ! "$var_value" =~ $pattern ]]; then
        echo -e "${RED}✗ PATTERN: $var_name '$var_value' doesn't match pattern '$pattern'${NC}"
        ((FAILED++))
        return 1
    else
        echo -e "${GREEN}✓ PATTERN: $var_name is valid${NC}"
        ((PASSED++))
        return 0
    fi
}

# Check if variable has minimum length
check_min_length() {
    local var_name=$1
    local min_length=$2
    local var_value=${!var_name:-}

    if [ ${#var_value} -lt "$min_length" ]; then
        echo -e "${RED}✗ LENGTH: $var_name is too short (minimum $min_length characters, got ${#var_value})${NC}"
        ((FAILED++))
        return 1
    else
        echo -e "${GREEN}✓ LENGTH: $var_name is sufficient (${#var_value} chars)${NC}"
        ((PASSED++))
        return 0
    fi
}

# ============================================================================
# Application Configuration Validation
# ============================================================================

echo "== Application Configuration =="

check_required "APP_NAME"
check_required "ENVIRONMENT"
check_boolean "DEBUG"
check_required "LOG_LEVEL"

if [ "$ENVIRONMENT" = "production" ]; then
    if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "True" ]; then
        echo -e "${YELLOW}⚠ WARNING: DEBUG is enabled in production!${NC}"
        ((WARNINGS++))
    fi
fi

echo ""

# ============================================================================
# Database Configuration Validation
# ============================================================================

echo "== Database Configuration =="

check_required "DB_HOST"
check_required "DB_DATABASE"
check_required "DB_USER"
check_required "DB_PASSWORD"
check_port "DB_PORT"

# Check password strength in production
if [ "$ENVIRONMENT" = "production" ]; then
    check_min_length "DB_PASSWORD" 12
fi

echo ""

# ============================================================================
# Redis Configuration Validation
# ============================================================================

echo "== Redis Configuration =="

check_required "REDIS_HOST"
check_port "REDIS_PORT"
check_optional "REDIS_PASSWORD"

echo ""

# ============================================================================
# Server Configuration Validation
# ============================================================================

echo "== Server Configuration =="

check_port "BACKEND_PORT"
check_required "API_VERSION"

echo ""

# ============================================================================
# Security Configuration Validation
# ============================================================================

echo "== Security Configuration =="

check_required "JWT_SECRET"
check_min_length "JWT_SECRET" 32
check_required "JWT_EXPIRE_HOURS"
check_required "BCRYPT_COST"
check_optional "CORS_ALLOWED_ORIGINS"

# Warn if JWT_SECRET looks like default
if [ "$JWT_SECRET" = "your-super-secret-jwt-key-min-32-characters-change-this" ]; then
    echo -e "${RED}✗ SECURITY: JWT_SECRET is still the default value!${NC}"
    ((FAILED++))
fi

echo ""

# ============================================================================
# File Upload Configuration Validation
# ============================================================================

echo "== File Upload Configuration =="

check_required "UPLOAD_DIR"
check_optional "MAX_UPLOAD_SIZE"

# Check if UPLOAD_DIR is readable/writable
if [ -d "$UPLOAD_DIR" ]; then
    if [ -w "$UPLOAD_DIR" ]; then
        echo -e "${GREEN}✓ WRITABLE: $UPLOAD_DIR is writable${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ WRITABLE: $UPLOAD_DIR is not writable${NC}"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠ INFO: UPLOAD_DIR '$UPLOAD_DIR' does not exist (will be created)${NC}"
    ((WARNINGS++))
fi

echo ""

# ============================================================================
# External Services Configuration Validation
# ============================================================================

echo "== External Services Configuration =="

check_required "SMS_PROVIDER"
check_required "PAYMENT_PROVIDER"
check_optional "EMAIL_PROVIDER"

# If provider is not "local", require credentials
if [ "$SMS_PROVIDER" != "local" ]; then
    echo -e "${YELLOW}⚠ INFO: SMS_PROVIDER set to '$SMS_PROVIDER' - verify credentials are configured${NC}"
    ((WARNINGS++))
fi

if [ "$PAYMENT_PROVIDER" != "local" ]; then
    echo -e "${YELLOW}⚠ INFO: PAYMENT_PROVIDER set to '$PAYMENT_PROVIDER' - verify credentials are configured${NC}"
    ((WARNINGS++))
fi

echo ""

# ============================================================================
# Feature Flags Validation
# ============================================================================

echo "== Feature Flags =="

check_boolean "FEATURE_SMS_NOTIFICATIONS"
check_boolean "FEATURE_REPORTS_EXPORT"

echo ""

# ============================================================================
# Database Connectivity Test (Optional)
# ============================================================================

echo "== Database Connectivity Test =="

if command -v mysql &> /dev/null; then
    echo "Testing database connection..."
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" &>/dev/null; then
        echo -e "${GREEN}✓ CONNECTIVITY: Database connection successful${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ CONNECTIVITY: Cannot connect to database at $DB_HOST:$DB_PORT${NC}"
        echo "  Command: mysql -h $DB_HOST -u $DB_USER -p*** -e 'SELECT 1;'"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED: mysql-client not installed (skip connectivity test)${NC}"
fi

echo ""

# ============================================================================
# Redis Connectivity Test (Optional)
# ============================================================================

if command -v redis-cli &> /dev/null; then
    echo "Testing Redis connection..."
    if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" PING &>/dev/null; then
        echo -e "${GREEN}✓ CONNECTIVITY: Redis connection successful${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ CONNECTIVITY: Cannot connect to Redis at $REDIS_HOST:$REDIS_PORT${NC}"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED: redis-cli not installed (skip connectivity test)${NC}"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed:  $PASSED${NC}"
echo -e "${RED}Failed:  $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

# Exit with error if any checks failed
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Validation FAILED - Please fix the issues above${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Validation PASSED - Environment is correctly configured${NC}"
    exit 0
fi
