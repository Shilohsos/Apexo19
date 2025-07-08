//+------------------------------------------------------------------+
//|                                              ProfitPulsePro.mq5 |
//|                                 Copyright 2024, Shilohsos       |
//|                                             https://github.com/Shilohsos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Shilohsos"
#property link      "https://github.com/Shilohsos"
#property version   "1.00"
#property description "Advanced MT5 EA with Market Regime Detection, Smart Entry Filters, Dynamic Position Sizing, Advanced TP Management, and Enhanced Risk Management"

//--- Include necessary libraries
#include <Trade\Trade.mqh>
#include <Math\Stat\Math.mqh>
#include "ProfitPulseProUtils.mqh"
#include "ProfitPulseProConfig.mqh"

//--- Global variables
CTrade trade;
datetime lastBarTime = 0;
SymbolConfig symbolConfigs[];
MarketSession marketSessions[];
RiskProfile riskProfiles[];
FairValueGap activeFVGs[];
PositionInfo activePositions[];

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+

//--- General Settings
input group "=== General Settings ==="
input bool     EnableTrading = true;                    // Enable Trading
input ENUM_TRADING_STYLE TradingStyle = STYLE_BALANCED; // Trading Style Preset
input double   LotSize = 0.1;                          // Base Lot Size
input int      MagicNumber = 123456;                   // Magic Number
input string   TradeComment = "ProfitPulsePro";        // Trade Comment

//--- Market Regime Detection
input group "=== Market Regime Detection ==="
input bool     UseMarketRegime = true;                 // Enable Market Regime Detection
input int      RegimePeriod = 20;                      // Regime Detection Period
input double   TrendThreshold = 0.6;                   // Trend Strength Threshold (0-1)
input int      VolatilityPeriod = 14;                  // Volatility Period
input double   VolatilityMultiplier = 1.5;             // Volatility Multiplier

//--- Smart Entry Filters
input group "=== Smart Entry Filters ==="
input bool     UseSmartFilters = true;                 // Enable Smart Entry Filters
input bool     UseRSIFilter = true;                    // Use RSI Filter
input int      RSI_Period = 14;                        // RSI Period
input double   RSI_Oversold = 30;                      // RSI Oversold Level
input double   RSI_Overbought = 70;                    // RSI Overbought Level
input bool     UseMAFilter = true;                     // Use Moving Average Filter
input int      MA_Period = 50;                         // MA Period
input ENUM_MA_METHOD MA_Method = MODE_EMA;             // MA Method
input bool     UseVolumeFilter = true;                 // Use Volume Filter
input double   VolumeMultiplier = 1.2;                 // Volume Multiplier

//--- Dynamic Position Sizing
input group "=== Dynamic Position Sizing ==="
input bool     UseDynamicSizing = true;                // Enable Dynamic Position Sizing
input double   RiskPercentage = 2.0;                   // Risk Percentage per Trade
input double   MaxLotSize = 1.0;                       // Maximum Lot Size
input double   MinLotSize = 0.01;                      // Minimum Lot Size
input bool     UseVolatilityAdjustment = true;         // Use Volatility Adjustment
input bool     UseEquityAdjustment = true;             // Use Equity Adjustment

//--- Advanced Take Profit Management
input group "=== Advanced Take Profit Management ==="
input bool     UseAdvancedTP = true;                   // Enable Advanced Take Profit
input double   TP_Level1 = 50;                         // Take Profit Level 1 (pips)
input double   TP_Level2 = 100;                        // Take Profit Level 2 (pips)
input double   TP_Level3 = 150;                        // Take Profit Level 3 (pips)
input double   TP_Portion1 = 0.3;                      // Portion to close at TP1
input double   TP_Portion2 = 0.4;                      // Portion to close at TP2
input bool     UseTrailingStop = true;                 // Use Trailing Stop
input double   TrailingStart = 30;                     // Trailing Start (pips)
input double   TrailingStep = 10;                      // Trailing Step (pips)
input bool     UseBreakEven = true;                    // Use Break Even
input double   BreakEvenLevel = 20;                    // Break Even Level (pips)

//--- Enhanced Risk Management
input group "=== Enhanced Risk Management ==="
input bool     UseEnhancedRisk = true;                 // Enable Enhanced Risk Management
input double   MaxDailyLoss = 5.0;                     // Max Daily Loss (%)
input double   MaxDrawdown = 10.0;                     // Max Drawdown (%)
input int      MaxConcurrentTrades = 3;                // Max Concurrent Trades
input double   StopLoss = 30;                          // Stop Loss (pips)
input bool     UseNewsFilter = true;                   // Use News Filter
input int      NewsFilterMinutes = 30;                 // News Filter Minutes
input bool     UseTradingHours = true;                 // Use Trading Hours
input int      TradingStartHour = 8;                   // Trading Start Hour
input int      TradingEndHour = 18;                    // Trading End Hour

//+------------------------------------------------------------------+
//| Market Regime Detection Variables                                |
//+------------------------------------------------------------------+
enum ENUM_MARKET_REGIME
{
    REGIME_TRENDING_UP,
    REGIME_TRENDING_DOWN,
    REGIME_RANGING,
    REGIME_HIGH_VOLATILITY,
    REGIME_UNKNOWN
};

ENUM_MARKET_REGIME currentRegime = REGIME_UNKNOWN;
double regimeStrength = 0.0;
double currentVolatility = 0.0;

//+------------------------------------------------------------------+
//| Smart Entry Filter Variables                                     |
//+------------------------------------------------------------------+
struct SmartFilters
{
    bool rsiFilter;
    bool maFilter;
    bool volumeFilter;
    bool allFiltersPass;
};

//+------------------------------------------------------------------+
//| Risk Management Variables                                        |
//+------------------------------------------------------------------+
double dailyStartEquity = 0.0;
double maxEquityToday = 0.0;
datetime lastDayCheck = 0;
int activeTrades = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set magic number for trades
    trade.SetExpertMagicNumber(MagicNumber);
    
    // Initialize configurations
    InitSymbolConfigs(symbolConfigs);
    InitMarketSessions(marketSessions);
    InitRiskProfiles(riskProfiles);
    
    // Load trading style preset
    LoadTradingStylePreset(TradingStyle);
    
    // Initialize arrays
    ArrayResize(activeFVGs, 50);
    ArrayResize(activePositions, 20);
    
    // Initialize daily equity tracking
    dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    maxEquityToday = dailyStartEquity;
    lastDayCheck = TimeCurrent();
    
    // Validate parameters
    if(!ValidateRiskParameters(RiskPercentage, MaxDailyLoss, MaxDrawdown, MaxConcurrentTrades, StopLoss, TP_Level1))
    {
        return(INIT_PARAMETERS_INCORRECT);
    }
    
    if(!ValidateMarketRegimeParameters(RegimePeriod, TrendThreshold, VolatilityMultiplier))
    {
        return(INIT_PARAMETERS_INCORRECT);
    }
    
    Print("ProfitPulsePro EA initialized successfully");
    Print("Trading Style: ", EnumToString(TradingStyle));
    Print("Market Regime Detection: ", UseMarketRegime ? "Enabled" : "Disabled");
    Print("Smart Entry Filters: ", UseSmartFilters ? "Enabled" : "Disabled");
    Print("Dynamic Position Sizing: ", UseDynamicSizing ? "Enabled" : "Disabled");
    Print("Advanced Take Profit: ", UseAdvancedTP ? "Enabled" : "Disabled");
    Print("Enhanced Risk Management: ", UseEnhancedRisk ? "Enabled" : "Disabled");
    
    LogConfiguration("ProfitPulsePro v1.0");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("ProfitPulsePro EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if new bar formed
    if(!IsNewBar()) return;
    
    // Update daily equity tracking
    UpdateDailyEquityTracking();
    
    // Update market regime
    if(UseMarketRegime)
        UpdateMarketRegime();
    
    // Check enhanced risk management
    if(UseEnhancedRisk && !CheckRiskManagement())
        return;
    
    // Check trading hours
    if(UseTradingHours && !IsWithinTradingHours())
        return;
    
    // Update active trades count
    UpdateActiveTradesCount();
    
    // Manage existing positions
    ManageExistingPositions();
    
    // Check for new entry signals
    if(EnableTrading && CanOpenNewTrade())
    {
        // Check news filter
        if(UseNewsFilter && IsNewsFilterActive(NewsFilterMinutes))
        {
            return; // Skip trading during news
        }
        
        CheckEntrySignals();
    }
    
    // Update FVG tracking
    UpdateFVGTracking();
    
    // Update position tracking
    UpdatePositionTracking();
}

//+------------------------------------------------------------------+
//| Check if new bar formed                                          |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    if(currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Update Market Regime Detection                                   |
//+------------------------------------------------------------------+
void UpdateMarketRegime()
{
    if(RegimePeriod <= 0) return;
    
    // Calculate trend strength using linear regression
    double prices[];
    ArraySetAsSeries(prices, true);
    
    if(CopyClose(_Symbol, PERIOD_CURRENT, 0, RegimePeriod, prices) != RegimePeriod)
        return;
    
    // Calculate linear regression slope
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = RegimePeriod;
    
    for(int i = 0; i < n; i++)
    {
        sumX += i;
        sumY += prices[i];
        sumXY += i * prices[i];
        sumX2 += i * i;
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double avgPrice = sumY / n;
    
    // Calculate R-squared for trend strength
    double ssTotal = 0, ssRes = 0;
    for(int i = 0; i < n; i++)
    {
        double predicted = avgPrice + slope * (i - (n-1)/2.0);
        ssTotal += MathPow(prices[i] - avgPrice, 2);
        ssRes += MathPow(prices[i] - predicted, 2);
    }
    
    regimeStrength = 1.0 - (ssRes / ssTotal);
    
    // Calculate volatility
    currentVolatility = CalculateVolatility(VolatilityPeriod);
    
    // Determine market regime
    if(regimeStrength >= TrendThreshold)
    {
        currentRegime = (slope > 0) ? REGIME_TRENDING_UP : REGIME_TRENDING_DOWN;
    }
    else if(currentVolatility > VolatilityMultiplier * CalculateAverageVolatility())
    {
        currentRegime = REGIME_HIGH_VOLATILITY;
    }
    else
    {
        currentRegime = REGIME_RANGING;
    }
}

//+------------------------------------------------------------------+
//| Calculate Volatility                                             |
//+------------------------------------------------------------------+
double CalculateVolatility(int period)
{
    double prices[];
    ArraySetAsSeries(prices, true);
    
    if(CopyClose(_Symbol, PERIOD_CURRENT, 0, period, prices) != period)
        return 0.0;
    
    double sum = 0;
    for(int i = 0; i < period - 1; i++)
    {
        double logReturn = MathLog(prices[i] / prices[i + 1]);
        sum += logReturn * logReturn;
    }
    
    return MathSqrt(sum / (period - 1));
}

//+------------------------------------------------------------------+
//| Calculate Average Volatility                                     |
//+------------------------------------------------------------------+
double CalculateAverageVolatility()
{
    int longPeriod = VolatilityPeriod * 5;
    return CalculateVolatility(longPeriod);
}

//+------------------------------------------------------------------+
//| Update Daily Equity Tracking                                     |
//+------------------------------------------------------------------+
void UpdateDailyEquityTracking()
{
    datetime currentTime = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(currentTime, timeStruct);
    
    MqlDateTime lastStruct;
    TimeToStruct(lastDayCheck, lastStruct);
    
    // Reset daily tracking at start of new day
    if(timeStruct.day != lastStruct.day)
    {
        dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        maxEquityToday = dailyStartEquity;
        lastDayCheck = currentTime;
    }
    
    // Update max equity for the day
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    if(currentEquity > maxEquityToday)
        maxEquityToday = currentEquity;
}

//+------------------------------------------------------------------+
//| Check Risk Management                                            |
//+------------------------------------------------------------------+
bool CheckRiskManagement()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Check daily loss limit
    if(MaxDailyLoss > 0)
    {
        double dailyLoss = (dailyStartEquity - currentEquity) / dailyStartEquity * 100;
        if(dailyLoss >= MaxDailyLoss)
        {
            Print("Daily loss limit reached: ", dailyLoss, "%");
            return false;
        }
    }
    
    // Check maximum drawdown
    if(MaxDrawdown > 0)
    {
        double drawdown = (maxEquityToday - currentEquity) / maxEquityToday * 100;
        if(drawdown >= MaxDrawdown)
        {
            Print("Maximum drawdown reached: ", drawdown, "%");
            return false;
        }
    }
    
    // Check maximum concurrent trades
    if(MaxConcurrentTrades > 0 && activeTrades >= MaxConcurrentTrades)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if within trading hours                                    |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    return (timeStruct.hour >= TradingStartHour && timeStruct.hour < TradingEndHour);
}

//+------------------------------------------------------------------+
//| Update Active Trades Count                                       |
//+------------------------------------------------------------------+
void UpdateActiveTradesCount()
{
    activeTrades = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
                activeTrades++;
        }
    }
}

//+------------------------------------------------------------------+
//| Check if can open new trade                                      |
//+------------------------------------------------------------------+
bool CanOpenNewTrade()
{
    return (MaxConcurrentTrades <= 0 || activeTrades < MaxConcurrentTrades);
}

//+------------------------------------------------------------------+
//| Check Entry Signals                                              |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
    // Get smart filters result
    SmartFilters filters = GetSmartFilters();
    
    // Check if filters pass (if enabled)
    if(UseSmartFilters && !filters.allFiltersPass)
        return;
    
    // Check market regime compatibility
    if(UseMarketRegime && !IsRegimeCompatible())
        return;
    
    // Check for Fair Value Gap signals (adapted from Pine Script)
    CheckFVGSignals();
    
    // Check for Break of Structure signals
    CheckBOSSignals();
}

//+------------------------------------------------------------------+
//| Get Smart Filters Result                                         |
//+------------------------------------------------------------------+
SmartFilters GetSmartFilters()
{
    SmartFilters filters;
    filters.rsiFilter = true;
    filters.maFilter = true;
    filters.volumeFilter = true;
    filters.allFiltersPass = true;
    
    if(!UseSmartFilters)
        return filters;
    
    // RSI Filter
    if(UseRSIFilter)
    {
        double rsiValue = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
        if(rsiValue == EMPTY_VALUE) return filters;
        
        filters.rsiFilter = (rsiValue > RSI_Oversold && rsiValue < RSI_Overbought);
    }
    
    // Moving Average Filter
    if(UseMAFilter)
    {
        double maValue = iMA(_Symbol, PERIOD_CURRENT, MA_Period, 0, MA_Method, PRICE_CLOSE);
        if(maValue == EMPTY_VALUE) return filters;
        
        double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
        filters.maFilter = true; // Simplified - can be enhanced based on specific MA strategy
    }
    
    // Volume Filter
    if(UseVolumeFilter)
    {
        long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
        long averageVolume = 0;
        
        // Calculate average volume
        for(int i = 1; i <= 10; i++)
        {
            averageVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
        }
        averageVolume /= 10;
        
        filters.volumeFilter = (currentVolume >= averageVolume * VolumeMultiplier);
    }
    
    // All filters must pass
    filters.allFiltersPass = filters.rsiFilter && filters.maFilter && filters.volumeFilter;
    
    return filters;
}

//+------------------------------------------------------------------+
//| Check if current regime is compatible for trading               |
//+------------------------------------------------------------------+
bool IsRegimeCompatible()
{
    // Allow trading in trending and ranging markets, avoid high volatility
    return (currentRegime == REGIME_TRENDING_UP || 
            currentRegime == REGIME_TRENDING_DOWN || 
            currentRegime == REGIME_RANGING);
}

//+------------------------------------------------------------------+
//| Check Fair Value Gap Signals                                    |
//+------------------------------------------------------------------+
void CheckFVGSignals()
{
    // Adapted from Pine Script FVG detection
    double high[], low[], close[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    
    int barsNeeded = 10;
    if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, barsNeeded, high) != barsNeeded ||
       CopyLow(_Symbol, PERIOD_CURRENT, 0, barsNeeded, low) != barsNeeded ||
       CopyClose(_Symbol, PERIOD_CURRENT, 0, barsNeeded, close) != barsNeeded)
        return;
    
    // Check for bullish FVG (gap up)
    if(high[3] < low[1]) // Gap between 3 bars ago high and 1 bar ago low
    {
        double gapTop = low[1];
        double gapBottom = high[3];
        
        // Check if current price is retesting the gap
        if(low[0] <= gapBottom && close[0] > gapBottom)
        {
            double lotSize = CalculateLotSize(true);
            if(lotSize > 0)
            {
                OpenTrade(ORDER_TYPE_BUY, lotSize, "FVG Long");
            }
        }
    }
    
    // Check for bearish FVG (gap down)
    if(low[3] > high[1]) // Gap between 3 bars ago low and 1 bar ago high
    {
        double gapTop = low[3];
        double gapBottom = high[1];
        
        // Check if current price is retesting the gap
        if(high[0] >= gapTop && close[0] < gapTop)
        {
            double lotSize = CalculateLotSize(false);
            if(lotSize > 0)
            {
                OpenTrade(ORDER_TYPE_SELL, lotSize, "FVG Short");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check Break of Structure Signals                                |
//+------------------------------------------------------------------+
void CheckBOSSignals()
{
    // Simplified BOS detection - can be enhanced
    double high[], low[], close[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    
    int barsNeeded = 20;
    if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, barsNeeded, high) != barsNeeded ||
       CopyLow(_Symbol, PERIOD_CURRENT, 0, barsNeeded, low) != barsNeeded ||
       CopyClose(_Symbol, PERIOD_CURRENT, 0, barsNeeded, close) != barsNeeded)
        return;
    
    // Find recent swing high and low
    double swingHigh = high[ArrayMaximum(high, 5, 10)];
    double swingLow = low[ArrayMinimum(low, 5, 10)];
    
    // Bullish BOS - close above recent swing high
    if(close[0] > swingHigh && close[1] <= swingHigh)
    {
        double lotSize = CalculateLotSize(true);
        if(lotSize > 0)
        {
            OpenTrade(ORDER_TYPE_BUY, lotSize, "BOS Long");
        }
    }
    
    // Bearish BOS - close below recent swing low
    if(close[0] < swingLow && close[1] >= swingLow)
    {
        double lotSize = CalculateLotSize(false);
        if(lotSize > 0)
        {
            OpenTrade(ORDER_TYPE_SELL, lotSize, "BOS Short");
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate Dynamic Lot Size                                       |
//+------------------------------------------------------------------+
double CalculateLotSize(bool isBuy)
{
    double lotSize = LotSize;
    
    if(!UseDynamicSizing)
        return NormalizeDouble(lotSize, 2);
    
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double stopLossPoints = StopLoss * Point * 10; // Convert pips to points
    
    // Risk-based position sizing
    double riskAmount = equity * RiskPercentage / 100.0;
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    if(tickValue > 0 && tickSize > 0 && stopLossPoints > 0)
    {
        lotSize = riskAmount / (stopLossPoints / tickSize * tickValue);
    }
    
    // Volatility adjustment
    if(UseVolatilityAdjustment)
    {
        double volatilityRatio = currentVolatility / CalculateAverageVolatility();
        if(volatilityRatio > 1.0)
            lotSize /= volatilityRatio;
    }
    
    // Equity adjustment
    if(UseEquityAdjustment)
    {
        double equityRatio = equity / dailyStartEquity;
        lotSize *= equityRatio;
    }
    
    // Apply limits
    lotSize = MathMax(lotSize, MinLotSize);
    lotSize = MathMin(lotSize, MaxLotSize);
    
    return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Open Trade                                                       |
//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE orderType, double lotSize, string signal)
{
    double price = (orderType == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = 0, tp = 0;
    
    // Calculate stop loss
    if(StopLoss > 0)
    {
        double slPoints = StopLoss * Point * 10;
        sl = (orderType == ORDER_TYPE_BUY) ? price - slPoints : price + slPoints;
    }
    
    // Calculate take profit (use first level if advanced TP is enabled)
    if(UseAdvancedTP && TP_Level1 > 0)
    {
        double tpPoints = TP_Level1 * Point * 10;
        tp = (orderType == ORDER_TYPE_BUY) ? price + tpPoints : price - tpPoints;
    }
    
    string comment = TradeComment + " - " + signal;
    
    if(trade.PositionOpen(_Symbol, orderType, lotSize, price, sl, tp, comment))
    {
        Print("Trade opened: ", signal, " | Lot: ", lotSize, " | Price: ", price);
    }
    else
    {
        Print("Failed to open trade: ", signal, " | Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Manage Existing Positions                                        |
//+------------------------------------------------------------------+
void ManageExistingPositions()
{
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
                ManagePosition();
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage Individual Position                                       |
//+------------------------------------------------------------------+
void ManagePosition()
{
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    bool isLong = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
    double lotSize = PositionGetDouble(POSITION_VOLUME);
    
    // Calculate profit in pips
    double profitPips = (isLong ? currentPrice - openPrice : openPrice - currentPrice) / (Point * 10);
    
    // Break even management
    if(UseBreakEven && profitPips >= BreakEvenLevel)
    {
        double currentSL = PositionGetDouble(POSITION_SL);
        double breakEvenPrice = openPrice;
        
        if((isLong && currentSL < breakEvenPrice) || (!isLong && currentSL > breakEvenPrice))
        {
            trade.PositionModify(PositionGetTicket(0), breakEvenPrice, PositionGetDouble(POSITION_TP));
            Print("Break even applied at: ", breakEvenPrice);
        }
    }
    
    // Trailing stop management
    if(UseTrailingStop && profitPips >= TrailingStart)
    {
        double currentSL = PositionGetDouble(POSITION_SL);
        double trailingStopPrice;
        
        if(isLong)
        {
            trailingStopPrice = currentPrice - (TrailingStep * Point * 10);
            if(trailingStopPrice > currentSL)
            {
                trade.PositionModify(PositionGetTicket(0), trailingStopPrice, PositionGetDouble(POSITION_TP));
                Print("Trailing stop updated: ", trailingStopPrice);
            }
        }
        else
        {
            trailingStopPrice = currentPrice + (TrailingStep * Point * 10);
            if(trailingStopPrice < currentSL)
            {
                trade.PositionModify(PositionGetTicket(0), trailingStopPrice, PositionGetDouble(POSITION_TP));
                Print("Trailing stop updated: ", trailingStopPrice);
            }
        }
    }
    
    // Advanced take profit management
    if(UseAdvancedTP)
    {
        ManageAdvancedTakeProfit(profitPips, lotSize, isLong);
    }
}

//+------------------------------------------------------------------+
//| Manage Advanced Take Profit                                      |
//+------------------------------------------------------------------+
void ManageAdvancedTakeProfit(double profitPips, double lotSize, bool isLong)
{
    // Close partial positions at different TP levels
    if(profitPips >= TP_Level1)
    {
        double closeVolume = lotSize * TP_Portion1;
        closeVolume = NormalizeDouble(closeVolume, 2);
        
        if(closeVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
        {
            trade.PositionClosePartial(PositionGetTicket(0), closeVolume);
            Print("Partial close at TP1: ", closeVolume, " lots");
        }
    }
    
    if(profitPips >= TP_Level2)
    {
        double closeVolume = lotSize * TP_Portion2;
        closeVolume = NormalizeDouble(closeVolume, 2);
        
        if(closeVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
        {
            trade.PositionClosePartial(PositionGetTicket(0), closeVolume);
            Print("Partial close at TP2: ", closeVolume, " lots");
        }
    }
    
    if(profitPips >= TP_Level3)
    {
        trade.PositionClose(PositionGetTicket(0));
        Print("Full close at TP3");
    }
}

//+------------------------------------------------------------------+
//| Get RSI value                                                    |
//+------------------------------------------------------------------+
double iRSI(string symbol, ENUM_TIMEFRAMES period, int rsiPeriod, ENUM_APPLIED_PRICE appliedPrice)
{
    int handle = iRSI(symbol, period, rsiPeriod, appliedPrice);
    if(handle == INVALID_HANDLE) return EMPTY_VALUE;
    
    double rsi[];
    ArraySetAsSeries(rsi, true);
    
    if(CopyBuffer(handle, 0, 0, 1, rsi) != 1)
        return EMPTY_VALUE;
    
    return rsi[0];
}

//+------------------------------------------------------------------+
//| Get MA value                                                     |
//+------------------------------------------------------------------+
double iMA(string symbol, ENUM_TIMEFRAMES period, int maPeriod, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
{
    int handle = iMA(symbol, period, maPeriod, shift, method, appliedPrice);
    if(handle == INVALID_HANDLE) return EMPTY_VALUE;
    
    double ma[];
    ArraySetAsSeries(ma, true);
    
    if(CopyBuffer(handle, 0, 0, 1, ma) != 1)
        return EMPTY_VALUE;
    
    return ma[0];
}

//+------------------------------------------------------------------+
//| Load Trading Style Preset                                        |
//+------------------------------------------------------------------+
void LoadTradingStylePreset(ENUM_TRADING_STYLE style)
{
    switch(style)
    {
        case STYLE_CONSERVATIVE:
            LoadConservativeConfig();
            break;
        case STYLE_BALANCED:
            LoadBalancedConfig();
            break;
        case STYLE_AGGRESSIVE:
            LoadAggressiveConfig();
            break;
        case STYLE_SCALPING:
            LoadScalpingConfig();
            break;
        case STYLE_SWING:
            LoadSwingConfig();
            break;
        case STYLE_CUSTOM:
            Print("Using custom configuration");
            break;
        default:
            LoadBalancedConfig();
            break;
    }
}

//+------------------------------------------------------------------+
//| Update FVG Tracking                                              |
//+------------------------------------------------------------------+
void UpdateFVGTracking()
{
    // Clean up old FVGs
    for(int i = ArraySize(activeFVGs) - 1; i >= 0; i--)
    {
        if(activeFVGs[i].isActive)
        {
            // Check if FVG is still valid
            datetime currentTime = TimeCurrent();
            if(currentTime - activeFVGs[i].startTime > 86400) // 24 hours
            {
                activeFVGs[i].isActive = false;
            }
        }
    }
    
    // Detect new FVGs
    DetectNewFVGs();
}

//+------------------------------------------------------------------+
//| Detect New Fair Value Gaps                                       |
//+------------------------------------------------------------------+
void DetectNewFVGs()
{
    double high[], low[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    
    if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, 5, high) != 5 ||
       CopyLow(_Symbol, PERIOD_CURRENT, 0, 5, low) != 5)
        return;
    
    // Check for bullish FVG
    if(high[3] < low[1])
    {
        FairValueGap newFVG;
        newFVG.startTime = iTime(_Symbol, PERIOD_CURRENT, 1);
        newFVG.topPrice = low[1];
        newFVG.bottomPrice = high[3];
        newFVG.isActive = true;
        newFVG.retestCount = 0;
        
        AddFVG(newFVG);
    }
    
    // Check for bearish FVG
    if(low[3] > high[1])
    {
        FairValueGap newFVG;
        newFVG.startTime = iTime(_Symbol, PERIOD_CURRENT, 1);
        newFVG.topPrice = low[3];
        newFVG.bottomPrice = high[1];
        newFVG.isActive = true;
        newFVG.retestCount = 0;
        
        AddFVG(newFVG);
    }
}

//+------------------------------------------------------------------+
//| Add FVG to tracking array                                        |
//+------------------------------------------------------------------+
void AddFVG(FairValueGap &fvg)
{
    // Find empty slot
    for(int i = 0; i < ArraySize(activeFVGs); i++)
    {
        if(!activeFVGs[i].isActive)
        {
            activeFVGs[i] = fvg;
            return;
        }
    }
}

//+------------------------------------------------------------------+
//| Update Position Tracking                                         |
//+------------------------------------------------------------------+
void UpdatePositionTracking()
{
    // Clear array
    for(int i = 0; i < ArraySize(activePositions); i++)
    {
        activePositions[i].ticket = 0;
        activePositions[i].isLong = false;
        activePositions[i].tp1Hit = false;
        activePositions[i].tp2Hit = false;
        activePositions[i].breakEvenSet = false;
    }
    
    // Update with current positions
    int posIndex = 0;
    for(int i = 0; i < PositionsTotal() && posIndex < ArraySize(activePositions); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
                activePositions[posIndex].ticket = PositionGetTicket(i);
                activePositions[posIndex].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                activePositions[posIndex].currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
                activePositions[posIndex].volume = PositionGetDouble(POSITION_VOLUME);
                activePositions[posIndex].profit = PositionGetDouble(POSITION_PROFIT);
                activePositions[posIndex].profitPips = CalculatePositionProfitPips(activePositions[posIndex].ticket);
                activePositions[posIndex].isLong = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
                activePositions[posIndex].openTime = (datetime)PositionGetInteger(POSITION_TIME);
                
                posIndex++;
            }
        }
    }
}