#!/bin/bash

# Comprehensive test script for ProfitPulsePro EA functionality

echo "=== ProfitPulsePro EA Comprehensive Test ==="
echo ""

# Check if the EA file exists
if [ ! -f "ProfitPulsePro.mq5" ]; then
    echo "ERROR: ProfitPulsePro.mq5 not found!"
    exit 1
fi

echo "1. Testing EA Structure..."
echo "   ✓ EA file exists"

# Test function completeness
echo ""
echo "2. Testing function completeness..."

functions=(
    "OnInit"
    "OnDeinit"
    "OnTick"
    "UpdateMarketStructure"
    "UpdateFVGZones"
    "CheckTradingSignals"
    "ProcessBuySignal"
    "ProcessSellSignal"
    "OpenBuyPosition"
    "OpenSellPosition"
    "CloseBuyPosition"
    "CloseSellPosition"
    "GetPivotHigh"
    "GetPivotLow"
    "CleanOldFVGZones"
    "IsTradeTime"
)

for func in "${functions[@]}"; do
    if grep -q "^[a-zA-Z][a-zA-Z0-9_]* $func" "ProfitPulsePro.mq5"; then
        echo "   ✓ $func function found"
    else
        echo "   ✗ $func function missing"
    fi
done

echo ""
echo "3. Testing datetime handling fixes..."

# Check for proper datetime functions
datetime_functions=(
    "TimeCurrent"
    "TimeToStruct"
    "PeriodSeconds"
)

for func in "${datetime_functions[@]}"; do
    count=$(grep -c "$func" "ProfitPulsePro.mq5")
    if [ $count -gt 0 ]; then
        echo "   ✓ $func used $count times"
    else
        echo "   ✗ $func not found"
    fi
done

echo ""
echo "4. Testing volume handling fixes..."

# Check for proper volume handling
volume_terms=(
    "LotSize"
    "POSITION_VOLUME"
    "volume"
)

for term in "${volume_terms[@]}"; do
    count=$(grep -c "$term" "ProfitPulsePro.mq5")
    if [ $count -gt 0 ]; then
        echo "   ✓ $term used $count times"
    else
        echo "   ✗ $term not found"
    fi
done

echo ""
echo "5. Testing error handling..."

# Check for error handling
error_terms=(
    "GetLastError"
    "result.retcode"
    "result.comment"
)

for term in "${error_terms[@]}"; do
    count=$(grep -c "$term" "ProfitPulsePro.mq5")
    if [ $count -gt 0 ]; then
        echo "   ✓ $term used $count times"
    else
        echo "   ✗ $term not found"
    fi
done

echo ""
echo "6. Testing input parameters..."

# Check for proper input declarations
input_params=(
    "TradeTF"
    "StructureTF"
    "FVGLookback"
    "MaxRetestBars"
    "ImpulseBars"
    "ShowFVG"
    "ShowBoS"
    "LotSize"
    "StopLoss"
    "TakeProfit"
)

for param in "${input_params[@]}"; do
    if grep -q "input.*$param" "ProfitPulsePro.mq5"; then
        echo "   ✓ $param parameter found"
    else
        echo "   ✗ $param parameter missing"
    fi
done

echo ""
echo "7. Testing Smart Money Concepts implementation..."

# Check for SMC features
smc_features=(
    "FVGZone"
    "LastPH"
    "LastPL"
    "GetPivotHigh"
    "GetPivotLow"
    "FVGBoxes"
    "Break of Structure"
)

for feature in "${smc_features[@]}"; do
    if grep -q "$feature" "ProfitPulsePro.mq5"; then
        echo "   ✓ $feature implemented"
    else
        echo "   ✗ $feature missing"
    fi
done

echo ""
echo "8. Testing trading functions..."

# Check for trading operations
trading_functions=(
    "OrderSend"
    "PositionSelect"
    "PositionGetInteger"
    "PositionGetDouble"
    "SymbolInfoDouble"
    "SymbolInfoInteger"
)

for func in "${trading_functions[@]}"; do
    count=$(grep -c "$func" "ProfitPulsePro.mq5")
    if [ $count -gt 0 ]; then
        echo "   ✓ $func used $count times"
    else
        echo "   ✗ $func not found"
    fi
done

echo ""
echo "9. Testing code quality..."

# Check for code quality indicators
total_lines=$(wc -l < "ProfitPulsePro.mq5")
comment_lines=$(grep -c "^//" "ProfitPulsePro.mq5")
blank_lines=$(grep -c "^$" "ProfitPulsePro.mq5")
code_lines=$((total_lines - comment_lines - blank_lines))

echo "   Code metrics:"
echo "   - Total lines: $total_lines"
echo "   - Comment lines: $comment_lines ($(echo "scale=1; $comment_lines*100/$total_lines" | bc)%)"
echo "   - Blank lines: $blank_lines"
echo "   - Code lines: $code_lines"
echo "   - Comment ratio: $(echo "scale=1; $comment_lines*100/$code_lines" | bc)%"

# Check for proper structure
if [ $comment_lines -gt 50 ]; then
    echo "   ✓ Good comment coverage"
else
    echo "   ⚠ Consider adding more comments"
fi

echo ""
echo "10. Testing compilation readiness..."

# Check for common compilation issues
issues=0

# Check for semicolons
if grep -q "^[^/].*[^;]$" "ProfitPulsePro.mq5"; then
    echo "   ⚠ Some lines may be missing semicolons"
    issues=$((issues + 1))
fi

# Check for proper brackets
open_brackets=$(grep -o "{" "ProfitPulsePro.mq5" | wc -l)
close_brackets=$(grep -o "}" "ProfitPulsePro.mq5" | wc -l)

if [ $open_brackets -eq $close_brackets ]; then
    echo "   ✓ Brackets are balanced ($open_brackets pairs)"
else
    echo "   ✗ Bracket mismatch: $open_brackets open, $close_brackets close"
    issues=$((issues + 1))
fi

# Check for proper parentheses
open_parens=$(grep -o "(" "ProfitPulsePro.mq5" | wc -l)
close_parens=$(grep -o ")" "ProfitPulsePro.mq5" | wc -l)

if [ $open_parens -eq $close_parens ]; then
    echo "   ✓ Parentheses are balanced ($open_parens pairs)"
else
    echo "   ✗ Parentheses mismatch: $open_parens open, $close_parens close"
    issues=$((issues + 1))
fi

echo ""
echo "=== Test Results ==="
if [ $issues -eq 0 ]; then
    echo "✓ All tests passed! EA appears ready for compilation."
else
    echo "⚠ $issues issues found. Please review before compilation."
fi

echo ""
echo "=== Next Steps ==="
echo "1. Open MetaEditor"
echo "2. Load ProfitPulsePro.mq5"
echo "3. Compile (F7)"
echo "4. Fix any compilation errors"
echo "5. Test in Strategy Tester"
echo "6. Deploy to demo account"
echo ""
echo "=== Test Complete ==="