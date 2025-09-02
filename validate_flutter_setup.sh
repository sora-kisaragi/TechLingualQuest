#!/bin/bash

# Flutter Project Validation Script
# このスクリプトはFlutterプロジェクトの基本構造を検証します

echo "🔍 Validating Flutter project structure..."
echo "==============================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for validation results
SUCCESS_COUNT=0
TOTAL_CHECKS=0

# Function to check if a file exists
check_file() {
    local file_path="$1"
    local description="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✅ $description${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}❌ $description${NC}"
        echo -e "${YELLOW}   Missing: $file_path${NC}"
    fi
}

# Function to check if a file exists (with fallback for .kts files)
check_file_with_fallback() {
    local file_path="$1"
    local fallback_path="$2"
    local description="$3"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file_path" ] || [ -f "$fallback_path" ]; then
        echo -e "${GREEN}✅ $description${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}❌ $description${NC}"
        echo -e "${YELLOW}   Missing: $file_path (or $fallback_path)${NC}"
    fi
}

# Function to check if a directory exists
check_dir() {
    local dir_path="$1"
    local description="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -d "$dir_path" ]; then
        echo -e "${GREEN}✅ $description${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}❌ $description${NC}"
        echo -e "${YELLOW}   Missing: $dir_path${NC}"
    fi
}

# Check core Flutter files
echo "📁 Core Flutter Files:"
check_file "pubspec.yaml" "Project configuration (pubspec.yaml)"
check_file "analysis_options.yaml" "Analyzer configuration"
check_file "lib/main.dart" "Main application file"
check_file "README_FLUTTER.md" "Flutter setup documentation"

# Check directory structure
echo -e "\n📁 Directory Structure:"
check_dir "lib" "Library directory"
check_dir "test" "Test directory"
check_dir "android" "Android platform"
check_dir "ios" "iOS platform"
check_dir "web" "Web platform"

# Check Android files
echo -e "\n🤖 Android Platform Files:"
check_file_with_fallback "android/app/build.gradle" "android/app/build.gradle.kts" "Android app build configuration"
check_file_with_fallback "android/build.gradle" "android/build.gradle.kts" "Android project build configuration"
check_file_with_fallback "android/settings.gradle" "android/settings.gradle.kts" "Android settings"
check_file "android/gradle.properties" "Android gradle properties"
check_file "android/app/src/main/AndroidManifest.xml" "Android manifest"
check_file "android/app/src/main/kotlin/com/example/tech_lingual_quest/MainActivity.kt" "Android main activity"

# Check iOS files
echo -e "\n🍎 iOS Platform Files:"
check_file "ios/Runner/Info.plist" "iOS app configuration"

# Check Web files
echo -e "\n🌐 Web Platform Files:"
check_file "web/index.html" "Web app entry point"
check_file "web/manifest.json" "Web app manifest"

# Check test files
echo -e "\n🧪 Test Files:"
check_file "test/widget_test.dart" "Widget tests"

# Validate pubspec.yaml content
echo -e "\n📋 Configuration Validation:"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if grep -q "name: tech_lingual_quest" pubspec.yaml 2>/dev/null; then
    echo -e "${GREEN}✅ Project name configured correctly${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Project name not configured correctly${NC}"
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if grep -q "flutter:" pubspec.yaml 2>/dev/null; then
    echo -e "${GREEN}✅ Flutter dependencies configured${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Flutter dependencies not configured${NC}"
fi

# Check if main.dart has basic content
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if grep -q "TechLingualQuestApp" lib/main.dart 2>/dev/null; then
    echo -e "${GREEN}✅ Main app class implemented${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    echo -e "${RED}❌ Main app class not implemented${NC}"
fi

# Summary
echo -e "\n📊 Validation Summary:"
echo "==============================================="
echo -e "Checks passed: ${GREEN}$SUCCESS_COUNT${NC}/$TOTAL_CHECKS"

if [ $SUCCESS_COUNT -eq $TOTAL_CHECKS ]; then
    echo -e "${GREEN}🎉 All validation checks passed!${NC}"
    echo -e "${GREEN}✨ Flutter project is ready for development${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Install Flutter SDK if not already installed"
    echo "2. Run 'flutter pub get' to install dependencies"
    echo "3. Run 'flutter run' to start the application"
    exit 0
else
    FAILED_COUNT=$((TOTAL_CHECKS - SUCCESS_COUNT))
    echo -e "${YELLOW}⚠️  $FAILED_COUNT validation checks failed${NC}"
    echo -e "${YELLOW}Please review the missing files/configurations above${NC}"
    exit 1
fi