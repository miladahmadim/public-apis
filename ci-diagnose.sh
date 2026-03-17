#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# CI Diagnostic Script for zaminor Laravel API
# Run from the project root: bash ci-diagnose.sh
# =============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass()  { ((PASS++)); echo -e "  ${GREEN}✔ $1${NC}"; }
fail()  { ((FAIL++)); echo -e "  ${RED}✘ $1${NC}"; }
warn()  { ((WARN++)); echo -e "  ${YELLOW}⚠ $1${NC}"; }

echo ""
echo "======================================"
echo " zaminor CI Diagnostic Check"
echo "======================================"
echo ""

# ----- 1. Missing Migrations -----
echo "▸ Checking migrations..."

grep -rql "conversation_participants" database/migrations/ 2>/dev/null \
  && pass "Migration for conversation_participants exists" \
  || fail "Missing migration: conversation_participants table"

grep -rql "personal_access_tokens" database/migrations/ 2>/dev/null \
  && pass "Migration for personal_access_tokens exists" \
  || fail "Missing migration: personal_access_tokens (Sanctum). Run: php artisan vendor:publish --provider=\"Laravel\Sanctum\SanctumServiceProvider\" --tag=sanctum-migrations"

grep -rql "notifications" database/migrations/ 2>/dev/null \
  && pass "Migration for notifications exists" \
  || fail "Missing migration: notifications table. Run: php artisan notifications:table"

# ----- 2. Column Issues -----
echo ""
echo "▸ Checking column definitions..."

# Check if nationality is nullable
if grep -rq "nationality" database/migrations/; then
  if grep -rqP "nationality.*nullable|nullable.*nationality" database/migrations/; then
    pass "users.nationality is nullable"
  else
    fail "users.nationality is NOT nullable — anonymization will fail. Make it ->nullable()"
  fi
else
  warn "No migration found referencing 'nationality' column"
fi

# Check storage_path on financial_documents
if grep -rql "financial_documents" database/migrations/ 2>/dev/null; then
  if grep -rqP "storage_path" database/migrations/*financial_documents* 2>/dev/null || \
     grep -A50 "financial_documents" database/migrations/*.php 2>/dev/null | grep -q "storage_path"; then
    pass "financial_documents.storage_path column exists in migration"
  else
    fail "Missing column: financial_documents.storage_path"
  fi
else
  warn "No migration found for financial_documents table"
fi

# Check favorites has id
if grep -rql "favorites" database/migrations/ 2>/dev/null; then
  FAVS_FILE=$(grep -rl "favorites" database/migrations/ | head -1)
  if grep -qP '->id\(|->bigIncrements|->uuid\(.*id|->ulid\(' "$FAVS_FILE" 2>/dev/null; then
    pass "favorites table has an id/primary key"
  else
    fail "favorites table may be missing a primary key (id column)"
  fi
else
  warn "No migration found for favorites table"
fi

# ----- 3. Encrypted JSON Cast -----
echo ""
echo "▸ Checking encrypted cast vs column type..."

if [ -f app/Models/KycApplication.php ]; then
  if grep -qP "pep_check_result.*encrypted" app/Models/KycApplication.php; then
    # Check if migration uses json type
    if grep -rqP "pep_check_result.*json" database/migrations/; then
      fail "pep_check_result is cast as 'encrypted' but column is 'json' — PostgreSQL will reject base64 strings. Change column to 'text'"
    else
      pass "pep_check_result column type is compatible with encrypted cast"
    fi
  else
    pass "pep_check_result does not use encrypted cast (no conflict)"
  fi
else
  warn "KycApplication model not found"
fi

# ----- 4. Role Seeder -----
echo ""
echo "▸ Checking role seeder..."

if grep -rql "assignRole.*user" app/Http/Controllers/ 2>/dev/null; then
  # Check if a seeder creates the 'user' role
  if grep -rqP "Role::create|Role::findOrCreate|'user'" database/seeders/ 2>/dev/null; then
    pass "Role seeder exists and likely creates 'user' role"
  else
    fail "Code calls assignRole('user') but no seeder creates this role"
  fi
else
  pass "No assignRole('user') found in controllers"
fi

# Check if CI workflow seeds the database
if [ -d .github/workflows ]; then
  if grep -rqP "db:seed|--seed" .github/workflows/; then
    pass "CI workflow runs database seeding"
  else
    fail "CI workflow does NOT run db:seed — roles won't exist in CI"
  fi
else
  warn "No .github/workflows directory found"
fi

# ----- 5. Missing Routes -----
echo ""
echo "▸ Checking routes..."

ROUTE_FILES=$(find routes/ -name "*.php" 2>/dev/null)

if [ -n "$ROUTE_FILES" ]; then
  if grep -rq "properties/favorites\|properties\.favorites" routes/; then
    pass "Route for properties/favorites exists"
  else
    fail "Missing route: /api/v1/properties/favorites"
  fi

  if grep -rqP "leads.*broker|leads\.broker" routes/; then
    pass "Route for leads/{id}/broker exists"
  else
    fail "Missing route: /api/v1/leads/{id}/broker"
  fi
else
  warn "No route files found"
fi

# ----- 6. Audit Middleware Resilience -----
echo ""
echo "▸ Checking AuditApiRequests middleware..."

if [ -f app/Http/Middleware/AuditApiRequests.php ]; then
  if grep -qP "try\s*\{|catch\s*\(" app/Http/Middleware/AuditApiRequests.php; then
    pass "AuditApiRequests middleware has try-catch (resilient to transaction failures)"
  else
    fail "AuditApiRequests middleware has NO try-catch — will cascade SQLSTATE[25P02] errors"
  fi
else
  warn "AuditApiRequests middleware not found"
fi

# ----- 7. KYC Test Data -----
echo ""
echo "▸ Checking KYC test data..."

if [ -f tests/Feature/KycTest.php ]; then
  if grep -qP "first_name|last_name" tests/Feature/KycTest.php; then
    # Check if controller expects full_name instead
    if grep -rqP "full_name" app/Http/Controllers/Api/V1/KycController.php 2>/dev/null || \
       grep -rqP "full_name" app/Http/Requests/ 2>/dev/null; then
      fail "KYC tests send first_name/last_name but validation expects full_name"
    else
      pass "KYC test fields match validation"
    fi
  else
    pass "KYC tests do not use first_name/last_name"
  fi
else
  warn "KycTest.php not found"
fi

# ----- 8. Full Erasure Mailable -----
echo ""
echo "▸ Checking full erasure mailable..."

if [ -f app/Http/Controllers/Api/V1/DataPrivacyController.php ]; then
  if grep -qP "full_erasure" app/Http/Controllers/Api/V1/DataPrivacyController.php; then
    if grep -qP "Mail::.*send\|Mail::.*to\|Mailable\|dispatch" app/Http/Controllers/Api/V1/DataPrivacyController.php; then
      pass "DataPrivacyController dispatches a mailable for full_erasure"
    else
      fail "DataPrivacyController handles full_erasure but does NOT dispatch a mailable"
    fi
  else
    warn "No full_erasure handling found in DataPrivacyController"
  fi
else
  warn "DataPrivacyController not found"
fi

# ----- Summary -----
echo ""
echo "======================================"
echo " Summary"
echo "======================================"
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"
echo -e "  ${YELLOW}Warnings: $WARN${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Fix the $FAIL issue(s) above before running CI.${NC}"
  exit 1
else
  echo -e "${GREEN}All checks passed!${NC}"
  exit 0
fi
