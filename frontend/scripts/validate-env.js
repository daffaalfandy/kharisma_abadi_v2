#!/usr/bin/env node

/**
 * Frontend Environment Validation Script
 *
 * Purpose: Validate that all required environment variables are set
 *          and have appropriate values for the current environment
 *
 * Usage:
 *   node frontend/scripts/validate-env.js [development|production]
 *   npm run validate:env -- development
 *
 * Exit codes:
 *   0 = All validations passed
 *   1 = One or more validations failed
 */

const fs = require('fs');
const path = require('path');

// ============================================================================
// Configuration
// ============================================================================

const COLORS = {
  RED: '\x1b[31m',
  GREEN: '\x1b[32m',
  YELLOW: '\x1b[33m',
  RESET: '\x1b[0m',
};

const RESULT = {
  PASSED: 0,
  FAILED: 0,
  WARNINGS: 0,
};

// ============================================================================
// Helper Functions
// ============================================================================

function log(message, color = 'RESET') {
  console.log(`${COLORS[color]}${message}${COLORS.RESET}`);
}

function checkRequired(varName, varValue) {
  if (!varValue || varValue.trim() === '') {
    log(`✗ REQUIRED: ${varName} is not set`, 'RED');
    RESULT.FAILED++;
    return false;
  }
  log(`✓ REQUIRED: ${varName} is set`, 'GREEN');
  RESULT.PASSED++;
  return true;
}

function checkOptional(varName, varValue) {
  if (!varValue || varValue.trim() === '') {
    log(`⚠ OPTIONAL: ${varName} is not set (using default)`, 'YELLOW');
    RESULT.WARNINGS++;
    return true;
  }
  log(`✓ OPTIONAL: ${varName} is set`, 'GREEN');
  RESULT.PASSED++;
  return true;
}

function checkBoolean(varName, varValue) {
  const validValues = ['true', 'false', 'True', 'False', 'TRUE', 'FALSE', '0', '1'];
  if (!validValues.includes(varValue)) {
    log(
      `✗ BOOLEAN: ${varName} has invalid value '${varValue}' (must be true/false)`,
      'RED'
    );
    RESULT.FAILED++;
    return false;
  }
  log(`✓ BOOLEAN: ${varName} = ${varValue}`, 'GREEN');
  RESULT.PASSED++;
  return true;
}

function checkUrl(varName, varValue) {
  try {
    new URL(varValue, 'http://localhost');
    log(`✓ URL: ${varName} is valid`, 'GREEN');
    RESULT.PASSED++;
    return true;
  } catch {
    log(`✗ URL: ${varName} has invalid URL '${varValue}'`, 'RED');
    RESULT.FAILED++;
    return false;
  }
}

function checkPattern(varName, varValue, pattern, description) {
  if (!new RegExp(pattern).test(varValue)) {
    log(`✗ PATTERN: ${varName} doesn't match ${description}`, 'RED');
    RESULT.FAILED++;
    return false;
  }
  log(`✓ PATTERN: ${varName} is valid`, 'GREEN');
  RESULT.PASSED++;
  return true;
}

function checkMinLength(varName, varValue, minLength) {
  if (varValue.length < minLength) {
    log(
      `✗ LENGTH: ${varName} is too short (minimum ${minLength} characters, got ${varValue.length})`,
      'RED'
    );
    RESULT.FAILED++;
    return false;
  }
  log(`✓ LENGTH: ${varName} is sufficient (${varValue.length} chars)`, 'GREEN');
  RESULT.PASSED++;
  return true;
}

// ============================================================================
// Environment Loading
// ============================================================================

function loadEnvFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const env = {};

    content.split('\n').forEach((line) => {
      // Skip comments and empty lines
      if (line.startsWith('#') || !line.trim()) {
        return;
      }

      const [key, ...rest] = line.split('=');
      if (key && rest.length > 0) {
        // Remove quotes if present
        let value = rest.join('=').trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.slice(1, -1);
        }
        env[key.trim()] = value;
      }
    });

    return env;
  } catch (error) {
    log(`✗ Error: Cannot read environment file: ${filePath}`, 'RED');
    process.exit(1);
  }
}

// ============================================================================
// Main Validation
// ============================================================================

function validateEnvironment() {
  const environment = process.argv[2] || process.env.NODE_ENV || 'development';

  // Try different possible locations for env files
  let envFile;
  const possiblePaths = [
    path.join(__dirname, '../.env.local'),
    path.join(__dirname, `../.env.${environment}`),
    path.join(__dirname, '../.env'),
    path.join(process.cwd(), '.env.local'),
    path.join(process.cwd(), `.env.${environment}`),
    path.join(process.cwd(), '.env'),
  ];

  for (const filePath of possiblePaths) {
    if (fs.existsSync(filePath)) {
      envFile = filePath;
      break;
    }
  }

  if (!envFile) {
    log(`✗ Error: No .env file found for environment: ${environment}`, 'RED');
    log(`  Looked for:`, 'RED');
    possiblePaths.forEach((p) => log(`    - ${p}`, 'RED'));
    process.exit(1);
  }

  const env = loadEnvFile(envFile);

  log('==========================================', 'GREEN');
  log('Frontend Environment Validation', 'GREEN');
  log('==========================================', 'GREEN');
  log(`Environment: ${environment}`);
  log(`Config file: ${envFile}`);
  log('');

  // ========================================================================
  // API Configuration
  // ========================================================================

  log('== API Configuration ==', 'GREEN');
  checkRequired('NEXT_PUBLIC_API_URL', env.NEXT_PUBLIC_API_URL);
  checkRequired('NEXT_PUBLIC_API_TIMEOUT', env.NEXT_PUBLIC_API_TIMEOUT);

  // Validate API URL format
  if (env.NEXT_PUBLIC_API_URL) {
    const apiUrl = env.NEXT_PUBLIC_API_URL;
    if (apiUrl.startsWith('http://') || apiUrl.startsWith('https://') || apiUrl.startsWith('/')) {
      log(`✓ URL_FORMAT: API URL is valid`, 'GREEN');
      RESULT.PASSED++;
    } else {
      log(`✗ URL_FORMAT: API URL should start with http://, https://, or /`, 'RED');
      RESULT.FAILED++;
    }
  }

  log('');

  // ========================================================================
  // Application Configuration
  // ========================================================================

  log('== Application Configuration ==', 'GREEN');
  checkRequired('NEXT_PUBLIC_APP_NAME', env.NEXT_PUBLIC_APP_NAME);
  checkRequired('NEXT_PUBLIC_ENVIRONMENT', env.NEXT_PUBLIC_ENVIRONMENT);
  checkBoolean('NEXT_PUBLIC_DEBUG', env.NEXT_PUBLIC_DEBUG);

  // Warn if debug enabled in production
  if (environment === 'production' && env.NEXT_PUBLIC_DEBUG === 'true') {
    log(`⚠ WARNING: DEBUG is enabled in production!`, 'YELLOW');
    RESULT.WARNINGS++;
  }

  log('');

  // ========================================================================
  // Feature Flags
  // ========================================================================

  log('== Feature Flags ==', 'GREEN');
  checkBoolean('NEXT_PUBLIC_FEATURE_SMS', env.NEXT_PUBLIC_FEATURE_SMS);
  checkBoolean('NEXT_PUBLIC_FEATURE_REPORTS', env.NEXT_PUBLIC_FEATURE_REPORTS);
  checkBoolean('NEXT_PUBLIC_FEATURE_ADVANCED_FILTERS', env.NEXT_PUBLIC_FEATURE_ADVANCED_FILTERS);
  checkBoolean('NEXT_PUBLIC_FEATURE_CUSTOMER_MGMT', env.NEXT_PUBLIC_FEATURE_CUSTOMER_MGMT);

  log('');

  // ========================================================================
  // UI Configuration
  // ========================================================================

  log('== UI Configuration ==', 'GREEN');
  checkRequired('NEXT_PUBLIC_ITEMS_PER_PAGE', env.NEXT_PUBLIC_ITEMS_PER_PAGE);
  checkBoolean('NEXT_PUBLIC_EXPERIMENTAL_FEATURES', env.NEXT_PUBLIC_EXPERIMENTAL_FEATURES);

  log('');

  // ========================================================================
  // Analytics Configuration
  // ========================================================================

  log('== Analytics Configuration ==', 'GREEN');
  checkOptional('NEXT_PUBLIC_GA_ID', env.NEXT_PUBLIC_GA_ID);
  checkOptional('NEXT_PUBLIC_SENTRY_DSN', env.NEXT_PUBLIC_SENTRY_DSN);

  if (environment === 'production') {
    if (!env.NEXT_PUBLIC_GA_ID) {
      log(`⚠ WARNING: Google Analytics not configured in production`, 'YELLOW');
      RESULT.WARNINGS++;
    }
    if (!env.NEXT_PUBLIC_SENTRY_DSN) {
      log(`⚠ WARNING: Sentry error tracking not configured in production`, 'YELLOW');
      RESULT.WARNINGS++;
    }
  }

  log('');

  // ========================================================================
  // Server-Side Configuration
  // ========================================================================

  log('== Server-Side Configuration ==', 'GREEN');
  checkRequired('API_SECRET_URL', env.API_SECRET_URL);
  checkOptional('TOKEN_STORAGE', env.TOKEN_STORAGE);

  if (env.TOKEN_STORAGE && !['localStorage', 'sessionStorage'].includes(env.TOKEN_STORAGE)) {
    log(`✗ STORAGE: TOKEN_STORAGE must be 'localStorage' or 'sessionStorage'`, 'RED');
    RESULT.FAILED++;
  } else if (env.TOKEN_STORAGE) {
    log(`✓ STORAGE: TOKEN_STORAGE = ${env.TOKEN_STORAGE}`, 'GREEN');
    RESULT.PASSED++;
  }

  log('');

  // ========================================================================
  // Security Configuration
  // ========================================================================

  log('== Security Configuration ==', 'GREEN');
  checkBoolean('CSP_REPORT_ONLY', env.CSP_REPORT_ONLY);
  checkBoolean('SECURITY_HEADERS_TEST', env.SECURITY_HEADERS_TEST);

  if (environment === 'production' && env.CSP_REPORT_ONLY === 'true') {
    log(`⚠ WARNING: CSP_REPORT_ONLY is enabled in production (CSP not enforced)`, 'YELLOW');
    RESULT.WARNINGS++;
  }

  log('');

  // ========================================================================
  // Development Tools
  // ========================================================================

  if (environment === 'development') {
    log('== Development Tools ==', 'GREEN');
    checkBoolean('ENABLE_REQUEST_LOGGING', env.ENABLE_REQUEST_LOGGING);
    checkBoolean('ENABLE_QUERY_LOGGING', env.ENABLE_QUERY_LOGGING);
    checkBoolean('MOCK_API', env.MOCK_API);
    log('');
  }

  // ========================================================================
  // Security Warnings
  // ========================================================================

  log('== Security Validation ==', 'GREEN');

  // Check for public secrets (should not have secrets in NEXT_PUBLIC_)
  const publicVars = Object.keys(env).filter((k) => k.startsWith('NEXT_PUBLIC_'));
  const secretKeywords = ['secret', 'key', 'password', 'token', 'api_key', 'auth'];
  let foundSecrets = false;

  publicVars.forEach((varName) => {
    const lowerName = varName.toLowerCase();
    if (secretKeywords.some((keyword) => lowerName.includes(keyword))) {
      log(
        `✗ SECURITY: Secret '${varName}' should not be NEXT_PUBLIC_ (visible to users)`,
        'RED'
      );
      RESULT.FAILED++;
      foundSecrets = true;
    }
  });

  if (!foundSecrets) {
    log(`✓ SECURITY: No secrets found in NEXT_PUBLIC_ variables`, 'GREEN');
    RESULT.PASSED++;
  }

  log('');

  // ========================================================================
  // Summary
  // ========================================================================

  log('==========================================', 'GREEN');
  log('Validation Summary', 'GREEN');
  log('==========================================', 'GREEN');
  log(`Passed:  ${RESULT.PASSED}`, 'GREEN');
  log(`Failed:  ${RESULT.FAILED}`, RESULT.FAILED > 0 ? 'RED' : 'GREEN');
  log(`Warnings: ${RESULT.WARNINGS}`, RESULT.WARNINGS > 0 ? 'YELLOW' : 'GREEN');
  log('');

  if (RESULT.FAILED > 0) {
    log(`✗ Validation FAILED - Please fix the issues above`, 'RED');
    process.exit(1);
  } else {
    log(`✓ Validation PASSED - Environment is correctly configured`, 'GREEN');
    process.exit(0);
  }
}

// ============================================================================
// Run Validation
// ============================================================================

validateEnvironment();
