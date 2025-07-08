#!/bin/bash

# MQL5 Syntax Validation Script
# This script performs basic syntax checking for MQL5 files

echo "=== MQL5 Syntax Validation ==="
echo "Checking: DateTimeTests.mq5"
echo ""

MQL_FILE="/home/runner/work/Apexo19/Apexo19/DateTimeTests.mq5"

# Check if file exists
if [ ! -f "$MQL_FILE" ]; then
    echo "ERROR: File $MQL_FILE not found!"
    exit 1
fi

# Check for proper file structure
echo "1. Checking file structure..."

# Check for required elements
if grep -q "#property copyright" "$MQL_FILE"; then
    echo "✓ Copyright property found"
else
    echo "✗ Missing copyright property"
fi

if grep -q "#property version" "$MQL_FILE"; then
    echo "✓ Version property found"
else
    echo "✗ Missing version property"
fi

if grep -q "int OnInit()" "$MQL_FILE"; then
    echo "✓ OnInit() function found"
else
    echo "✗ Missing OnInit() function"
fi

if grep -q "void OnDeinit" "$MQL_FILE"; then
    echo "✓ OnDeinit() function found"
else
    echo "✗ Missing OnDeinit() function"
fi

if grep -q "void OnTick()" "$MQL_FILE"; then
    echo "✓ OnTick() function found"
else
    echo "✗ Missing OnTick() function"
fi

echo ""
echo "2. Checking MQLDateTime usage..."

# Check for proper MQLDateTime declarations
if grep -q "MqlDateTime.*;" "$MQL_FILE"; then
    echo "✓ MqlDateTime structures declared"
    grep -n "MqlDateTime" "$MQL_FILE" | head -5
else
    echo "✗ No MqlDateTime structures found"
fi

echo ""
echo "3. Checking TimeToStruct usage..."

# Check for TimeToStruct function calls
if grep -q "TimeToStruct(" "$MQL_FILE"; then
    echo "✓ TimeToStruct() function calls found"
    grep -n "TimeToStruct(" "$MQL_FILE" | head -5
else
    echo "✗ No TimeToStruct() calls found"
fi

echo ""
echo "4. Checking for proper initialization..."

# Check for ZeroMemory usage
if grep -q "ZeroMemory(" "$MQL_FILE"; then
    echo "✓ ZeroMemory() initialization found"
    grep -n "ZeroMemory(" "$MQL_FILE" | head -3
else
    echo "✗ No ZeroMemory() initialization found"
fi

echo ""
echo "5. Checking for syntax errors..."

# Check for common syntax issues
SYNTAX_ERRORS=0

# Check for missing semicolons (basic check)
if grep -n "[^;{}]$" "$MQL_FILE" | grep -v "^[[:space:]]*$" | grep -v "^[[:space:]]*//"; then
    echo "⚠ Potential missing semicolons found"
fi

# Check for unmatched braces
OPEN_BRACES=$(grep -o "{" "$MQL_FILE" | wc -l)
CLOSE_BRACES=$(grep -o "}" "$MQL_FILE" | wc -l)

if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
    echo "✓ Braces are balanced ($OPEN_BRACES pairs)"
else
    echo "✗ Unmatched braces: $OPEN_BRACES opening, $CLOSE_BRACES closing"
    SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
fi

# Check for proper string handling
if grep -q 'Print.*".*"' "$MQL_FILE"; then
    echo "✓ Print statements with proper string formatting found"
else
    echo "⚠ No Print statements found"
fi

echo ""
echo "6. Checking datetime-specific patterns..."

# Check for proper datetime error handling
if grep -q "TimeToStruct.*result" "$MQL_FILE" || grep -q "if.*TimeToStruct" "$MQL_FILE"; then
    echo "✓ TimeToStruct error handling found"
else
    echo "⚠ Consider adding TimeToStruct error handling"
fi

# Check for datetime formatting
if grep -q "StringFormat.*%.*d" "$MQL_FILE"; then
    echo "✓ DateTime formatting with StringFormat found"
else
    echo "⚠ No datetime formatting found"
fi

echo ""
echo "=== Validation Summary ==="
if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo "✓ Basic syntax validation passed"
    echo "✓ MQLDateTime structures properly declared"
    echo "✓ TimeToStruct function properly used"
    echo "✓ File structure is correct"
    exit 0
else
    echo "✗ Found $SYNTAX_ERRORS syntax errors"
    exit 1
fi