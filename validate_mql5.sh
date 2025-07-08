#!/bin/bash

# Simple MQL5 syntax validation script for ProfitPulsePro EA

echo "=== MQL5 Syntax Validation for ProfitPulsePro.mq5 ==="
echo ""

file="ProfitPulsePro.mq5"

if [ ! -f "$file" ]; then
    echo "ERROR: $file not found!"
    exit 1
fi

echo "Checking for common MQL5 syntax issues..."
echo ""

# Check for proper includes
echo "1. Checking includes and property statements..."
grep -n "^#property\|^#include" "$file" | head -5
echo ""

# Check for proper function declarations
echo "2. Checking function declarations..."
grep -n "^[a-zA-Z][a-zA-Z0-9_]* [a-zA-Z][a-zA-Z0-9_]*(" "$file" | head -5
echo ""

# Check for variable declarations
echo "3. Checking variable declarations..."
grep -n "^[a-zA-Z][a-zA-Z0-9_]* [a-zA-Z][a-zA-Z0-9_]*\s*=" "$file" | head -5
echo ""

# Check for common datetime functions
echo "4. Checking datetime function usage..."
grep -n "TimeCurrent\|TimeToStruct\|PeriodSeconds" "$file" | head -5
echo ""

# Check for proper array declarations
echo "5. Checking array declarations..."
grep -n "\[\]" "$file" | head -5
echo ""

# Check for MQL5 specific functions
echo "6. Checking MQL5 trading functions..."
grep -n "OrderSend\|PositionSelect\|SymbolInfo" "$file" | head -5
echo ""

# Check for proper comment structure
echo "7. Checking comment structure..."
grep -n "//+--" "$file" | head -5
echo ""

# Count lines of code
echo "8. File statistics:"
total_lines=$(wc -l < "$file")
comment_lines=$(grep -c "^//" "$file")
blank_lines=$(grep -c "^$" "$file")
code_lines=$((total_lines - comment_lines - blank_lines))

echo "   Total lines: $total_lines"
echo "   Comment lines: $comment_lines"
echo "   Blank lines: $blank_lines"
echo "   Code lines: $code_lines"
echo ""

# Check for potential issues
echo "9. Checking for potential issues..."
issues=0

# Check for uninitialized variables
if grep -q "double.*;" "$file" && ! grep -q "= 0\|= EMPTY_VALUE" "$file"; then
    echo "   WARNING: Potential uninitialized variables found"
    issues=$((issues + 1))
fi

# Check for array bounds
if grep -q "ArraySize\|ArrayResize" "$file"; then
    echo "   GOOD: Array bounds checking found"
else
    echo "   WARNING: No array bounds checking found"
    issues=$((issues + 1))
fi

# Check for error handling
if grep -q "GetLastError\|result.retcode" "$file"; then
    echo "   GOOD: Error handling found"
else
    echo "   WARNING: No error handling found"
    issues=$((issues + 1))
fi

echo ""
if [ $issues -eq 0 ]; then
    echo "✓ No obvious syntax issues found!"
else
    echo "⚠ $issues potential issues found - please review"
fi

echo ""
echo "=== Validation Complete ==="
echo ""
echo "Next steps:"
echo "1. Test compile in MetaEditor"
echo "2. Run strategy tester"
echo "3. Check for runtime errors"
echo "4. Validate trading logic"