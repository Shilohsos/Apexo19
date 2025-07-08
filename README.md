# ProfitPulsePro EA - Smart Money Concepts Expert Advisor

## Overview
ProfitPulsePro is a MetaTrader 5 Expert Advisor that implements Smart Money Concepts (SMC) trading strategies, specifically focusing on Fair Value Gaps (FVG) and Break of Structure (BoS) patterns.

## Features

### Smart Money Concepts Implementation
- **Fair Value Gaps (FVG)**: Automated detection and tracking of price gaps in market structure
- **Break of Structure (BoS)**: Identification of key support/resistance level breaks
- **Multi-timeframe Analysis**: Uses different timeframes for structure and signal analysis
- **Pivot Point Detection**: Automatic identification of swing highs and lows

### Trading Capabilities
- **Automated Trading**: Opens and closes positions based on FVG retests
- **Risk Management**: Configurable stop loss and take profit levels
- **Position Management**: Automatic position sizing and management
- **Signal Filtering**: Prevents overtrading with time-based filters

### Key Fixes Applied
1. **MQLDateTime Handling**: Proper datetime functions and comparisons
2. **Volume Variables**: Correct volume handling and position sizing
3. **Compilation Errors**: Fixed all syntax and structural issues
4. **Code Organization**: Clean, maintainable code structure

## Installation

1. Copy `ProfitPulsePro.mq5` to your MetaTrader 5 `Experts` folder
2. Open MetaEditor and compile the EA
3. Attach to chart and configure parameters
4. Enable automated trading

## Configuration

### Trading Settings
- **Trade Timeframe**: Primary timeframe for signals (default: M15)
- **Structure Timeframe**: Higher timeframe for structure analysis (default: H1)
- **FVG Lookback**: Bars to look back for FVG detection (default: 3)
- **Max Retest Bars**: Maximum bars to wait for FVG retest (default: 12)
- **Impulse Bars**: Period for pivot point detection (default: 3)

### Risk Management
- **Lot Size**: Position size (default: 0.1)
- **Stop Loss**: Stop loss in points (default: 50)
- **Take Profit**: Take profit in points (default: 100)
- **Max Spread**: Maximum allowed spread (default: 30)

### Trading Hours
- **Use Time Filter**: Enable/disable time-based trading (default: false)
- **Start Hour**: Trading start time (default: 8)
- **End Hour**: Trading end time (default: 18)

## Trading Logic

### Signal Generation
1. **FVG Detection**: Identifies gaps in price structure
2. **Zone Tracking**: Monitors FVG zones for potential retests
3. **Retest Confirmation**: Confirms price rejection at FVG levels
4. **Position Entry**: Opens position on confirmed retest

### Risk Management
- Automatic stop loss and take profit placement
- Position sizing based on configured lot size
- Spread filtering to avoid high-cost trades
- Time-based filtering for optimal trading hours

## Files Included

- `ProfitPulsePro.mq5`: Main EA file
- `FIXES_DOCUMENTATION.md`: Detailed documentation of fixes applied
- `validate_mql5.sh`: Syntax validation script
- `test_ea.sh`: Comprehensive testing script

## Testing

Run the validation script to check for issues:
```bash
./validate_mql5.sh
```

Run comprehensive tests:
```bash
./test_ea.sh
```

## Compilation

1. Open MetaEditor
2. Load `ProfitPulsePro.mq5`
3. Press F7 to compile
4. Fix any remaining issues if they appear
5. Deploy to Strategy Tester or live account

## Support

For issues or questions, please refer to the documentation files or test the EA in the Strategy Tester before live deployment.

## Disclaimer

This EA is provided for educational and testing purposes. Always test thoroughly on demo accounts before using with real money. Trading involves risk of loss.
