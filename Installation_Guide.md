# ProfitPulsePro EA - Installation Guide

## Step-by-Step Installation

### 1. Download and Extract
- Download the ProfitPulsePro EA files
- Extract all files to a temporary folder

### 2. Copy Files to MetaTrader 5
1. Open MetaTrader 5
2. Go to **File → Open Data Folder**
3. Navigate to **MQL5 → Experts** folder
4. Copy `ProfitPulsePro.mq5` to this folder

### 3. Compile the EA
1. Open MetaEditor (press F4 in MetaTrader 5)
2. Open `ProfitPulsePro.mq5` from the Experts folder
3. Click **Compile** (F7) or go to **Compile → Compile**
4. Check for any compilation errors in the "Errors" tab
5. If successful, you'll see "0 errors, 0 warnings"

### 4. Attach EA to Chart
1. In MetaTrader 5, open the chart you want to trade on
2. In the Navigator panel, expand **Expert Advisors**
3. Find **ProfitPulsePro** and double-click or drag it to the chart
4. The EA settings dialog will appear

### 5. Configure EA Settings
In the EA settings dialog:

#### Common Tab
- Check **Allow live trading** ✅
- Check **Allow DLL imports** ✅
- Check **Allow external expert imports** ✅

#### Inputs Tab
Configure the parameters according to your preferences:

**Recommended Beginner Settings:**
```
=== GENERAL SETTINGS ===
Enable Trading: true
Magic Number: 888888
Comment: ProfitPulsePro
Slippage: 3

=== RISK MANAGEMENT ===
Risk Percentage per Trade: 1.0 (for beginners)
Maximum Risk Percentage: 5.0
Maximum Drawdown Percentage: 10.0
Use Dynamic Position Sizing: true

=== TAKE PROFIT LEVELS ===
Use Multiple Take Profit: true
TP1 Risk:Reward Ratio: 1.0
TP2 Risk:Reward Ratio: 2.0
TP3 Risk:Reward Ratio: 3.0

=== ENHANCED FILTERS ===
Use Trend Filter: true
Use Volume Filter: true
Use Volatility Filter: true
Use Spread Filter: true
Use Time Filter: true
```

#### Auto Trading Tab
- Set **Stop Loss**: 0 (EA manages this)
- Set **Take Profit**: 0 (EA manages this)
- Set **Lot Size**: 0 (EA calculates this)

### 6. Enable Auto Trading
1. In MetaTrader 5, click the **Auto Trading** button in the toolbar
2. The button should be green and active
3. You should see a smiley face (😊) in the top-right corner of the chart

### 7. Verify Installation
Check that:
- The EA name appears in the top-left corner of the chart
- There's a smiley face (😊) indicating the EA is running
- The Expert tab shows initialization messages
- No error messages appear in the Journal tab

## Configuration for Different Account Types

### Micro Account (Balance < $1,000)
```
Risk Percentage per Trade: 0.5%
Maximum Risk Percentage: 3.0%
Fixed Lot Size: 0.01
Maximum Drawdown: 5.0%
```

### Standard Account (Balance $1,000 - $10,000)
```
Risk Percentage per Trade: 1.0%
Maximum Risk Percentage: 5.0%
Use Dynamic Position Sizing: true
Maximum Drawdown: 10.0%
```

### Large Account (Balance > $10,000)
```
Risk Percentage per Trade: 2.0%
Maximum Risk Percentage: 10.0%
Use Dynamic Position Sizing: true
Maximum Drawdown: 15.0%
```

## Timeframe Recommendations

### Conservative Approach
- Signal Timeframe: M15
- Trend Timeframe: H1
- Structure Timeframe: H4

### Aggressive Approach
- Signal Timeframe: M5
- Trend Timeframe: M15
- Structure Timeframe: H1

### Long-term Approach
- Signal Timeframe: H1
- Trend Timeframe: H4
- Structure Timeframe: D1

## Troubleshooting

### Common Issues and Solutions

**1. EA Not Compiling**
- Check if all required files are in the correct folders
- Verify MetaTrader 5 version (build 3085 or later required)
- Try restarting MetaTrader 5

**2. EA Not Trading**
- Verify **Auto Trading** is enabled (green button)
- Check if **Allow live trading** is enabled in EA settings
- Verify account has sufficient balance
- Check if time filter is blocking trades

**3. "Trade Not Allowed" Error**
- Enable **Allow live trading** in EA settings
- Check if trading is allowed for your account type
- Verify market is open for the symbol

**4. High Spread Warnings**
- Increase **Maximum Spread Points** in settings
- Trade during major market sessions
- Consider using ECN/STP brokers

**5. Position Size Too Small**
- Increase **Risk Percentage per Trade**
- Check minimum lot size for your broker
- Verify account balance is sufficient

## Testing Before Live Trading

### 1. Strategy Tester
1. Go to **View → Strategy Tester**
2. Select **ProfitPulsePro** EA
3. Choose symbol and timeframe
4. Set date range for testing
5. Click **Start** to run backtest

### 2. Demo Account
1. Open demo account with your broker
2. Install EA on demo account
3. Test for at least 1-2 weeks
4. Monitor performance and adjust settings

### 3. Visual Mode
1. In Strategy Tester, enable **Visual mode**
2. Watch how EA identifies and trades signals
3. Observe Smart Money Concepts visualization
4. Verify EA behavior matches expectations

## Performance Monitoring

### Key Metrics to Watch
- **Win Rate**: Should be above 50%
- **Profit Factor**: Should be above 1.5
- **Maximum Drawdown**: Should stay below your limit
- **Risk-Reward Ratio**: Average should be positive
- **Monthly Return**: Should be consistent

### EA Statistics
The EA provides real-time statistics in the Expert tab:
- Total trades executed
- Winning/losing trades
- Current drawdown
- Account balance progression

## Support and Updates

### Getting Help
1. Check **ProfitPulsePro_Documentation.md** for detailed information
2. Review error messages in Journal tab
3. Test on demo account first
4. Keep detailed trading logs

### Best Practices
1. **Never risk more than you can afford to lose**
2. **Always test on demo account first**
3. **Start with small risk percentages**
4. **Monitor performance regularly**
5. **Keep MetaTrader 5 updated**
6. **Use VPS for 24/7 operation**

## Legal Disclaimer

This EA is provided for educational purposes only. Past performance does not guarantee future results. Trading involves substantial risk and may result in loss of capital. Always trade responsibly and within your means.

---

**Installation Complete!** 🎉

Your ProfitPulsePro EA is now ready to trade. Remember to start with demo trading and gradually move to live trading once you're comfortable with the EA's performance.