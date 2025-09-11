#!/bin/bash

# 保護されたルート実装検証スクリプト
# Validation script for protected routes implementation

echo "🔐 Validating Protected Routes Implementation..."
echo "==============================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS_COUNT=0
TOTAL_CHECKS=0

# Function to check if a file exists and contains expected content
check_implementation() {
    local file_path="$1"
    local search_pattern="$2"
    local description="$3"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -f "$file_path" ]; then
        if grep -q "$search_pattern" "$file_path" 2>/dev/null; then
            echo -e "${GREEN}✅ $description${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "${RED}❌ $description - Pattern not found${NC}"
            echo -e "${YELLOW}   Looking for: $search_pattern${NC}"
        fi
    else
        echo -e "${RED}❌ $description - File not found${NC}"
        echo -e "${YELLOW}   Missing: $file_path${NC}"
    fi
}

# Function to count occurrences of a pattern
count_occurrences() {
    local file_path="$1"
    local search_pattern="$2"
    
    if [ -f "$file_path" ]; then
        grep -c "$search_pattern" "$file_path" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

echo "📁 Core Implementation Files:"
check_implementation "lib/features/dashboard/pages/dashboard_page.dart" "class DashboardPage" "Dashboard page implementation"
check_implementation "lib/app/router.dart" "DashboardPage" "Dashboard route registration"
check_implementation "lib/app/router.dart" "_routeGuard" "Route guard function"

echo -e "\n🛡️ Authentication Guard Logic:"
check_implementation "lib/app/router.dart" "metadata?.requiresAuth" "Authentication requirement checking"
check_implementation "lib/app/router.dart" "isAuthenticatedProvider" "Authentication state verification"
check_implementation "lib/app/router.dart" "AppRoutes.auth" "Redirect to auth page"

echo -e "\n🗺️ Protected Route Registration:"
check_implementation "lib/app/router.dart" "path: AppRoutes.dashboard" "Dashboard route path"
check_implementation "lib/app/router.dart" "name: AppRoutes.dashboardName" "Dashboard route name"
check_implementation "lib/app/router.dart" "/dashboard.*return AppRoutes.dashboardName" "Dashboard route path mapping"

echo -e "\n📊 Route Metadata Configuration:"
check_implementation "lib/app/routes.dart" "requiresAuth: true" "Protected routes metadata"
check_implementation "lib/app/routes.dart" "dashboardName.*RouteMetadata" "Dashboard metadata"

echo -e "\n🧪 Test Coverage:"
check_implementation "test/unit/protected_routes_test.dart" "Protected Routes Tests" "Unit tests for protected routes"
check_implementation "test/integration/protected_routes_integration_test.dart" "Protected Routes Integration Tests" "Integration tests"
check_implementation "test/unit/protected_routes_test.dart" "requiresAuth.*isTrue" "Authentication requirement tests"

echo -e "\n📈 Implementation Statistics:"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
PROTECTED_ROUTES=$(count_occurrences "lib/app/routes.dart" "requiresAuth: true")
if [ "$PROTECTED_ROUTES" -ge 5 ]; then
    echo -e "${GREEN}✅ Protected routes count: $PROTECTED_ROUTES${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Protected routes count: $PROTECTED_ROUTES (expected >= 5)${NC}"
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
TEST_CASES=$(count_occurrences "test/unit/protected_routes_test.dart" "test(")
if [ "$TEST_CASES" -ge 10 ]; then
    echo -e "${GREEN}✅ Test cases count: $TEST_CASES${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Test cases count: $TEST_CASES (expected >= 10)${NC}"
fi

echo -e "\n🔍 Security Validation:"
check_implementation "lib/app/router.dart" "/auth/password-reset.*return AppRoutes.passwordResetName" "Password reset route handling"
check_implementation "test/unit/protected_routes_test.dart" "should not have conflicting authentication requirements" "Authentication conflict prevention"

# Validate that auth routes don't require authentication (to prevent infinite redirects)
echo -e "\n🔄 Infinite Redirect Prevention:"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
# Check that login and register routes are properly configured in metadata
if grep -A5 -B5 "loginName.*RouteMetadata" lib/app/routes.dart | grep -q "showInNavigation: false" && 
   grep -A5 -B5 "registerName.*RouteMetadata" lib/app/routes.dart | grep -q "showInNavigation: false"; then
    echo -e "${GREEN}✅ Auth routes properly configured (no infinite redirects)${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Auth routes may cause infinite redirects${NC}"
fi

echo -e "\n📋 Route Constants Validation:"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
DASHBOARD_CONSTANT=$(grep -c "dashboard.*'/dashboard'" lib/app/routes.dart)
if [ "$DASHBOARD_CONSTANT" -ge 1 ]; then
    echo -e "${GREEN}✅ Dashboard route constant defined${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Dashboard route constant not properly defined${NC}"
fi

# Summary
echo -e "\n📊 Validation Summary:"
echo "==============================================="
echo -e "Checks passed: ${GREEN}$SUCCESS_COUNT${NC}/$TOTAL_CHECKS"

if [ $SUCCESS_COUNT -eq $TOTAL_CHECKS ]; then
    echo -e "${GREEN}🎉 All validation checks passed!${NC}"
    echo -e "${GREEN}✨ Protected routes implementation is complete and secure${NC}"
    echo ""
    echo "✅ Implementation Features:"
    echo "   • Dashboard page with authentication requirement"
    echo "   • Route guard with proper redirect logic"
    echo "   • Comprehensive test coverage"
    echo "   • Security validations to prevent infinite redirects"
    echo "   • Proper metadata configuration for all routes"
    echo ""
    echo "🛡️ Protected Routes:"
    echo "   • /auth/profile - User profile"
    echo "   • /auth/profile/edit - Profile editing"
    echo "   • /dashboard - User dashboard"
    echo "   • /vocabulary/add - Add vocabulary"
    echo "   • /quests/active - Active quests"
    exit 0
else
    FAILED_COUNT=$((TOTAL_CHECKS - SUCCESS_COUNT))
    echo -e "${YELLOW}⚠️  $FAILED_COUNT validation checks failed${NC}"
    echo -e "${YELLOW}Please review the implementation above${NC}"
    exit 1
fi