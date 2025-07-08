//+------------------------------------------------------------------+
//|                                               ProfitPulsePro.mq5 |
//|                                  Copyright 2024, ProfitPulsePro |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, ProfitPulsePro"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Indicators\Indicators.mqh>

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== GENERAL SETTINGS ==="
input bool InpTradeEnabled = true;                    // Enable Trading
input int InpMagicNumber = 888888;                    // Magic Number
input string InpComment = "ProfitPulsePro";           // Comment
input int InpSlippage = 3;                            // Slippage in Points

input group "=== TIMEFRAME SETTINGS ==="
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M15;     // Signal Timeframe
input ENUM_TIMEFRAMES InpTrendTimeframe = PERIOD_H1;       // Trend Timeframe
input ENUM_TIMEFRAMES InpStructureTimeframe = PERIOD_H4;   // Structure Timeframe

input group "=== RISK MANAGEMENT ==="
input double InpRiskPercent = 2.0;                    // Risk Percentage per Trade
input double InpMaxRiskPercent = 10.0;                // Maximum Risk Percentage
input double InpMaxDrawdownPercent = 20.0;            // Maximum Drawdown Percentage
input double InpMinLotSize = 0.01;                    // Minimum Lot Size
input double InpMaxLotSize = 10.0;                    // Maximum Lot Size
input bool InpUseFixedLots = false;                   // Use Fixed Lot Size
input double InpFixedLotSize = 0.1;                   // Fixed Lot Size
input bool InpUseDynamicPositionSizing = true;        // Dynamic Position Sizing
input double InpAccountRiskMultiplier = 1.0;          // Account Risk Multiplier

input group "=== TAKE PROFIT LEVELS ==="
input bool InpUseMultipleTP = true;                   // Use Multiple Take Profit
input double InpTP1_Ratio = 1.0;                      // TP1 Risk:Reward Ratio
input double InpTP2_Ratio = 2.0;                      // TP2 Risk:Reward Ratio
input double InpTP3_Ratio = 3.0;                      // TP3 Risk:Reward Ratio
input double InpTP1_Percent = 30.0;                   // TP1 Position Percent
input double InpTP2_Percent = 40.0;                   // TP2 Position Percent
input double InpTP3_Percent = 30.0;                   // TP3 Position Percent

input group "=== STOP LOSS SETTINGS ==="
input double InpStopLossPoints = 100;                 // Stop Loss Points
input bool InpUseTrailingStop = true;                 // Use Trailing Stop
input double InpTrailingStopPoints = 50;              // Trailing Stop Points
input double InpTrailingStepPoints = 10;              // Trailing Step Points
input bool InpUseBreakEven = true;                    // Use Break Even
input double InpBreakEvenPoints = 30;                 // Break Even Points
input double InpBreakEvenProfit = 10;                 // Break Even Profit Points

input group "=== VOLUME ANALYSIS ==="
input bool InpUseVolumeFilter = true;                 // Use Volume Filter
input int InpVolumePeriod = 20;                       // Volume Period
input double InpVolumeMultiplier = 1.5;               // Volume Multiplier
input bool InpUseTickVolumeFilter = true;             // Use Tick Volume Filter
input int InpTickVolumePeriod = 14;                   // Tick Volume Period

input group "=== MARKET REGIME DETECTION ==="
input bool InpUseMarketRegimeFilter = true;           // Use Market Regime Filter
input int InpADXPeriod = 14;                          // ADX Period
input double InpADXTrendingLevel = 25.0;              // ADX Trending Level
input int InpATRPeriod = 14;                          // ATR Period
input double InpATRMultiplier = 2.0;                  // ATR Multiplier
input int InpVolatilityPeriod = 20;                   // Volatility Period

input group "=== ENHANCED FILTERS ==="
input bool InpUseTrendFilter = true;                  // Use Trend Filter
input int InpTrendMAPeriod = 200;                     // Trend MA Period
input ENUM_MA_METHOD InpTrendMAMethod = MODE_EMA;     // Trend MA Method
input bool InpUseVolatilityFilter = true;            // Use Volatility Filter
input double InpMaxVolatilityLevel = 3.0;             // Maximum Volatility Level
input bool InpUseSpreadFilter = true;                 // Use Spread Filter
input double InpMaxSpreadPoints = 5.0;                // Maximum Spread Points
input bool InpUseTimeFilter = true;                   // Use Time Filter
input int InpStartHour = 8;                           // Start Hour
input int InpEndHour = 18;                            // End Hour

input group "=== INDICATOR SETTINGS ==="
input int InpRSIPeriod = 14;                          // RSI Period
input int InpBBPeriod = 20;                           // Bollinger Bands Period
input double InpBBDeviation = 2.0;                    // BB Deviation
input int InpMACDFastEMA = 12;                        // MACD Fast EMA
input int InpMACDSlowEMA = 26;                        // MACD Slow EMA
input int InpMACDSignalSMA = 9;                       // MACD Signal SMA
input int InpStochKPeriod = 14;                       // Stochastic %K Period
input int InpStochDPeriod = 3;                        // Stochastic %D Period
input int InpStochSlowing = 3;                        // Stochastic Slowing

input group "=== SMART MONEY CONCEPTS ==="
input bool InpUseSMC = true;                          // Use Smart Money Concepts
input int InpFVGLookback = 3;                         // FVG Lookback
input int InpMaxRetestBars = 12;                      // Max Retest Bars
input int InpImpulseBars = 3;                         // Impulse Bars
input bool InpShowFVG = true;                         // Show FVG Zones
input bool InpShowBoS = true;                         // Show Break of Structure
input bool InpUseLiquidity = true;                    // Use Liquidity Levels
input bool InpUseOrderBlocks = true;                  // Use Order Blocks

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
CTrade trade;
CPositionInfo positionInfo;
CAccountInfo accountInfo;
CSymbolInfo symbolInfo;
COrderInfo orderInfo;

// Indicators
CiRSI *rsi;
CiBands *bb;
CiMACD *macd;
CiStochastic *stoch;
CiMA *trendMA;
CiADX *adx;
CiATR *atr;

// Arrays for multi-timeframe data
double signalHigh[], signalLow[], signalClose[], signalOpen[], signalVolume[];
double trendHigh[], trendLow[], trendClose[], trendVolume[];
double structureHigh[], structureLow[], structureClose[], structureVolume[];

// Position management
struct PositionData {
    ulong ticket;
    double openPrice;
    double lotSize;
    double stopLoss;
    double takeProfit;
    datetime openTime;
    bool tp1Hit;
    bool tp2Hit;
    bool tp3Hit;
    bool breakEvenSet;
    bool trailingActive;
    double lastTrailingPrice;
};

PositionData positions[];

// Market regime variables
enum ENUM_MARKET_REGIME {
    REGIME_TRENDING_UP,
    REGIME_TRENDING_DOWN,
    REGIME_RANGING,
    REGIME_VOLATILE
};

ENUM_MARKET_REGIME currentMarketRegime;

// Smart Money Concepts variables
struct FVGZone {
    double top;
    double bottom;
    datetime time;
    bool isRetested;
    color zoneColor;
};

struct LiquidityLevel {
    double price;
    datetime time;
    bool isSwept;
    ENUM_OBJECT_PROPERTY_INTEGER levelType;
};

struct OrderBlock {
    double high;
    double low;
    datetime time;
    bool isValid;
    ENUM_POSITION_TYPE blockType;
};

FVGZone fvgZones[];
LiquidityLevel liquidityLevels[];
OrderBlock orderBlocks[];

// Statistics
double totalProfit = 0.0;
double totalLoss = 0.0;
int totalTrades = 0;
int winningTrades = 0;
int losingTrades = 0;
double maxDrawdown = 0.0;
double currentDrawdown = 0.0;
double peakBalance = 0.0;

// Error handling
int lastError = 0;
datetime lastErrorTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize trading objects
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetDeviationInPoints(InpSlippage);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(Symbol());
    
    // Initialize symbol info
    if (!symbolInfo.Name(Symbol())) {
        Print("Failed to initialize symbol info");
        return INIT_FAILED;
    }
    
    // Initialize indicators
    if (!InitializeIndicators()) {
        Print("Failed to initialize indicators");
        return INIT_FAILED;
    }
    
    // Initialize arrays
    ArrayResize(positions, 0);
    ArrayResize(fvgZones, 0);
    ArrayResize(liquidityLevels, 0);
    ArrayResize(orderBlocks, 0);
    
    // Initialize statistics
    peakBalance = accountInfo.Balance();
    
    // Print initialization message
    Print("ProfitPulsePro EA initialized successfully");
    Print("Account Balance: ", accountInfo.Balance());
    Print("Account Equity: ", accountInfo.Equity());
    Print("Free Margin: ", accountInfo.FreeMargin());
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Clean up indicators
    if (rsi != NULL) delete rsi;
    if (bb != NULL) delete bb;
    if (macd != NULL) delete macd;
    if (stoch != NULL) delete stoch;
    if (trendMA != NULL) delete trendMA;
    if (adx != NULL) delete adx;
    if (atr != NULL) delete atr;
    
    // Clean up chart objects
    CleanupChartObjects();
    
    // Print final statistics
    PrintFinalStatistics();
    
    Print("ProfitPulsePro EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    // Error handling
    if (!CheckForErrors()) return;
    
    // Check if trading is enabled
    if (!InpTradeEnabled) return;
    
    // Update market data
    if (!UpdateMarketData()) return;
    
    // Update indicators
    if (!UpdateIndicators()) return;
    
    // Detect market regime
    DetectMarketRegime();
    
    // Update Smart Money Concepts
    if (InpUseSMC) {
        UpdateSmartMoneyConcepts();
    }
    
    // Position management
    ManagePositions();
    
    // Check for new signals
    CheckForSignals();
    
    // Update statistics
    UpdateStatistics();
}

//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool InitializeIndicators() {
    // RSI
    rsi = new CiRSI();
    if (!rsi.Create(Symbol(), InpSignalTimeframe, InpRSIPeriod, PRICE_CLOSE)) {
        Print("Failed to create RSI indicator");
        return false;
    }
    
    // Bollinger Bands
    bb = new CiBands();
    if (!bb.Create(Symbol(), InpSignalTimeframe, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE)) {
        Print("Failed to create Bollinger Bands indicator");
        return false;
    }
    
    // MACD
    macd = new CiMACD();
    if (!macd.Create(Symbol(), InpSignalTimeframe, InpMACDFastEMA, InpMACDSlowEMA, InpMACDSignalSMA, PRICE_CLOSE)) {
        Print("Failed to create MACD indicator");
        return false;
    }
    
    // Stochastic
    stoch = new CiStochastic();
    if (!stoch.Create(Symbol(), InpSignalTimeframe, InpStochKPeriod, InpStochDPeriod, InpStochSlowing, MODE_SMA, STO_LOWHIGH)) {
        Print("Failed to create Stochastic indicator");
        return false;
    }
    
    // Trend MA
    trendMA = new CiMA();
    if (!trendMA.Create(Symbol(), InpTrendTimeframe, InpTrendMAPeriod, 0, InpTrendMAMethod, PRICE_CLOSE)) {
        Print("Failed to create Trend MA indicator");
        return false;
    }
    
    // ADX
    adx = new CiADX();
    if (!adx.Create(Symbol(), InpSignalTimeframe, InpADXPeriod)) {
        Print("Failed to create ADX indicator");
        return false;
    }
    
    // ATR
    atr = new CiATR();
    if (!atr.Create(Symbol(), InpSignalTimeframe, InpATRPeriod)) {
        Print("Failed to create ATR indicator");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update market data                                               |
//+------------------------------------------------------------------+
bool UpdateMarketData() {
    // Copy signal timeframe data
    if (CopyHigh(Symbol(), InpSignalTimeframe, 0, 100, signalHigh) <= 0) return false;
    if (CopyLow(Symbol(), InpSignalTimeframe, 0, 100, signalLow) <= 0) return false;
    if (CopyClose(Symbol(), InpSignalTimeframe, 0, 100, signalClose) <= 0) return false;
    if (CopyOpen(Symbol(), InpSignalTimeframe, 0, 100, signalOpen) <= 0) return false;
    if (CopyTickVolume(Symbol(), InpSignalTimeframe, 0, 100, signalVolume) <= 0) return false;
    
    // Copy trend timeframe data
    if (CopyHigh(Symbol(), InpTrendTimeframe, 0, 100, trendHigh) <= 0) return false;
    if (CopyLow(Symbol(), InpTrendTimeframe, 0, 100, trendLow) <= 0) return false;
    if (CopyClose(Symbol(), InpTrendTimeframe, 0, 100, trendClose) <= 0) return false;
    if (CopyTickVolume(Symbol(), InpTrendTimeframe, 0, 100, trendVolume) <= 0) return false;
    
    // Copy structure timeframe data
    if (CopyHigh(Symbol(), InpStructureTimeframe, 0, 100, structureHigh) <= 0) return false;
    if (CopyLow(Symbol(), InpStructureTimeframe, 0, 100, structureLow) <= 0) return false;
    if (CopyClose(Symbol(), InpStructureTimeframe, 0, 100, structureClose) <= 0) return false;
    if (CopyTickVolume(Symbol(), InpStructureTimeframe, 0, 100, structureVolume) <= 0) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Update indicators                                                |
//+------------------------------------------------------------------+
bool UpdateIndicators() {
    if (!rsi.Refresh()) return false;
    if (!bb.Refresh()) return false;
    if (!macd.Refresh()) return false;
    if (!stoch.Refresh()) return false;
    if (!trendMA.Refresh()) return false;
    if (!adx.Refresh()) return false;
    if (!atr.Refresh()) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Detect market regime                                             |
//+------------------------------------------------------------------+
void DetectMarketRegime() {
    if (!InpUseMarketRegimeFilter) return;
    
    double adxValue = adx.Main(0);
    double adxPlus = adx.Plus(0);
    double adxMinus = adx.Minus(0);
    double atrValue = atr.Main(0);
    double avgATR = 0.0;
    
    // Calculate average ATR
    for (int i = 0; i < InpVolatilityPeriod && i < ArraySize(signalClose); i++) {
        avgATR += atr.Main(i);
    }
    avgATR /= InpVolatilityPeriod;
    
    // Determine market regime
    if (adxValue > InpADXTrendingLevel) {
        if (adxPlus > adxMinus) {
            currentMarketRegime = REGIME_TRENDING_UP;
        } else {
            currentMarketRegime = REGIME_TRENDING_DOWN;
        }
    } else if (atrValue > avgATR * InpATRMultiplier) {
        currentMarketRegime = REGIME_VOLATILE;
    } else {
        currentMarketRegime = REGIME_RANGING;
    }
}

//+------------------------------------------------------------------+
//| Update Smart Money Concepts                                      |
//+------------------------------------------------------------------+
void UpdateSmartMoneyConcepts() {
    UpdateFVGZones();
    UpdateLiquidityLevels();
    UpdateOrderBlocks();
}

//+------------------------------------------------------------------+
//| Update FVG zones                                                 |
//+------------------------------------------------------------------+
void UpdateFVGZones() {
    if (!InpShowFVG || ArraySize(signalHigh) < InpFVGLookback + 1) return;
    
    // Check for bullish FVG
    if (signalHigh[InpFVGLookback] < signalLow[InpFVGLookback - 1]) {
        FVGZone newZone;
        newZone.top = signalLow[InpFVGLookback - 1];
        newZone.bottom = signalHigh[InpFVGLookback];
        newZone.time = TimeCurrent();
        newZone.isRetested = false;
        newZone.zoneColor = clrLime;
        
        AddFVGZone(newZone);
    }
    
    // Check for bearish FVG
    if (signalLow[InpFVGLookback] > signalHigh[InpFVGLookback - 1]) {
        FVGZone newZone;
        newZone.top = signalLow[InpFVGLookback];
        newZone.bottom = signalHigh[InpFVGLookback - 1];
        newZone.time = TimeCurrent();
        newZone.isRetested = false;
        newZone.zoneColor = clrRed;
        
        AddFVGZone(newZone);
    }
    
    // Check for retests and cleanup old zones
    CleanupFVGZones();
}

//+------------------------------------------------------------------+
//| Add FVG zone                                                     |
//+------------------------------------------------------------------+
void AddFVGZone(FVGZone &zone) {
    int size = ArraySize(fvgZones);
    ArrayResize(fvgZones, size + 1);
    fvgZones[size] = zone;
    
    // Draw zone on chart
    string objName = "FVG_" + IntegerToString(size) + "_" + IntegerToString(GetTickCount());
    if (ObjectCreate(0, objName, OBJ_RECTANGLE, 0, zone.time, zone.top, TimeCurrent() + PeriodSeconds(InpSignalTimeframe) * 50, zone.bottom)) {
        ObjectSetInteger(0, objName, OBJPROP_COLOR, zone.zoneColor);
        ObjectSetInteger(0, objName, OBJPROP_FILL, true);
        ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
    }
}

//+------------------------------------------------------------------+
//| Cleanup FVG zones                                                |
//+------------------------------------------------------------------+
void CleanupFVGZones() {
    datetime currentTime = TimeCurrent();
    
    for (int i = ArraySize(fvgZones) - 1; i >= 0; i--) {
        // Check if zone is too old
        if (currentTime - fvgZones[i].time > PeriodSeconds(InpSignalTimeframe) * InpMaxRetestBars) {
            ArrayRemove(fvgZones, i, 1);
            continue;
        }
        
        // Check for retest
        if (!fvgZones[i].isRetested) {
            double currentPrice = symbolInfo.Bid();
            if (fvgZones[i].zoneColor == clrLime && currentPrice <= fvgZones[i].bottom && signalClose[0] > fvgZones[i].bottom) {
                fvgZones[i].isRetested = true;
            } else if (fvgZones[i].zoneColor == clrRed && currentPrice >= fvgZones[i].top && signalClose[0] < fvgZones[i].top) {
                fvgZones[i].isRetested = true;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update liquidity levels                                          |
//+------------------------------------------------------------------+
void UpdateLiquidityLevels() {
    if (!InpUseLiquidity) return;
    
    // Find pivot highs and lows
    for (int i = InpImpulseBars; i < ArraySize(signalHigh) - InpImpulseBars; i++) {
        // Check for pivot high
        bool isPivotHigh = true;
        for (int j = i - InpImpulseBars; j <= i + InpImpulseBars; j++) {
            if (j != i && signalHigh[j] >= signalHigh[i]) {
                isPivotHigh = false;
                break;
            }
        }
        
        if (isPivotHigh) {
            LiquidityLevel newLevel;
            newLevel.price = signalHigh[i];
            newLevel.time = TimeCurrent();
            newLevel.isSwept = false;
            newLevel.levelType = OBJPROP_COLOR;
            
            AddLiquidityLevel(newLevel);
        }
        
        // Check for pivot low
        bool isPivotLow = true;
        for (int j = i - InpImpulseBars; j <= i + InpImpulseBars; j++) {
            if (j != i && signalLow[j] <= signalLow[i]) {
                isPivotLow = false;
                break;
            }
        }
        
        if (isPivotLow) {
            LiquidityLevel newLevel;
            newLevel.price = signalLow[i];
            newLevel.time = TimeCurrent();
            newLevel.isSwept = false;
            newLevel.levelType = OBJPROP_COLOR;
            
            AddLiquidityLevel(newLevel);
        }
    }
}

//+------------------------------------------------------------------+
//| Add liquidity level                                              |
//+------------------------------------------------------------------+
void AddLiquidityLevel(LiquidityLevel &level) {
    int size = ArraySize(liquidityLevels);
    ArrayResize(liquidityLevels, size + 1);
    liquidityLevels[size] = level;
    
    // Draw level on chart
    string objName = "LIQ_" + IntegerToString(size) + "_" + IntegerToString(GetTickCount());
    if (ObjectCreate(0, objName, OBJ_HLINE, 0, level.time, level.price)) {
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASH);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    }
}

//+------------------------------------------------------------------+
//| Update order blocks                                              |
//+------------------------------------------------------------------+
void UpdateOrderBlocks() {
    if (!InpUseOrderBlocks) return;
    
    // Implementation for order block detection
    // This is a simplified version - you can enhance it based on your specific criteria
    
    for (int i = 1; i < ArraySize(signalClose) - 1; i++) {
        // Bullish order block
        if (signalClose[i] > signalOpen[i] && signalClose[i] - signalOpen[i] > atr.Main(i) * 0.5) {
            OrderBlock newBlock;
            newBlock.high = signalHigh[i];
            newBlock.low = signalLow[i];
            newBlock.time = TimeCurrent();
            newBlock.isValid = true;
            newBlock.blockType = POSITION_TYPE_BUY;
            
            AddOrderBlock(newBlock);
        }
        
        // Bearish order block
        if (signalClose[i] < signalOpen[i] && signalOpen[i] - signalClose[i] > atr.Main(i) * 0.5) {
            OrderBlock newBlock;
            newBlock.high = signalHigh[i];
            newBlock.low = signalLow[i];
            newBlock.time = TimeCurrent();
            newBlock.isValid = true;
            newBlock.blockType = POSITION_TYPE_SELL;
            
            AddOrderBlock(newBlock);
        }
    }
}

//+------------------------------------------------------------------+
//| Add order block                                                  |
//+------------------------------------------------------------------+
void AddOrderBlock(OrderBlock &block) {
    int size = ArraySize(orderBlocks);
    ArrayResize(orderBlocks, size + 1);
    orderBlocks[size] = block;
    
    // Draw block on chart
    string objName = "OB_" + IntegerToString(size) + "_" + IntegerToString(GetTickCount());
    color blockColor = (block.blockType == POSITION_TYPE_BUY) ? clrBlue : clrMagenta;
    
    if (ObjectCreate(0, objName, OBJ_RECTANGLE, 0, block.time, block.high, TimeCurrent() + PeriodSeconds(InpSignalTimeframe) * 20, block.low)) {
        ObjectSetInteger(0, objName, OBJPROP_COLOR, blockColor);
        ObjectSetInteger(0, objName, OBJPROP_FILL, true);
        ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    }
}

//+------------------------------------------------------------------+
//| Check for trading signals                                        |
//+------------------------------------------------------------------+
void CheckForSignals() {
    if (!CanTrade()) return;
    
    // Check for buy signal
    if (GetBuySignal()) {
        ExecuteBuyOrder();
    }
    
    // Check for sell signal
    if (GetSellSignal()) {
        ExecuteSellOrder();
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool CanTrade() {
    // Check if already have maximum positions
    if (PositionsTotal() >= 10) return false;
    
    // Check time filter
    if (InpUseTimeFilter) {
        MqlDateTime dt;
        TimeCurrent(dt);
        if (dt.hour < InpStartHour || dt.hour > InpEndHour) return false;
    }
    
    // Check spread filter
    if (InpUseSpreadFilter) {
        double spread = symbolInfo.Spread();
        if (spread > InpMaxSpreadPoints) return false;
    }
    
    // Check drawdown limit
    if (currentDrawdown > InpMaxDrawdownPercent) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get buy signal                                                   |
//+------------------------------------------------------------------+
bool GetBuySignal() {
    // Basic trend filter
    if (InpUseTrendFilter && signalClose[0] < trendMA.Main(0)) return false;
    
    // Market regime filter
    if (InpUseMarketRegimeFilter && currentMarketRegime == REGIME_TRENDING_DOWN) return false;
    
    // Volume filter
    if (InpUseVolumeFilter && !CheckVolumeFilter()) return false;
    
    // Volatility filter
    if (InpUseVolatilityFilter && !CheckVolatilityFilter()) return false;
    
    // Technical indicators
    bool rsiOversold = rsi.Main(0) < 30;
    bool bbLowerTouch = signalClose[0] <= bb.Lower(0);
    bool macdBullish = macd.Main(0) > macd.Signal(0);
    bool stochOversold = stoch.Main(0) < 20;
    
    // Smart Money Concepts
    bool fvgRetest = false;
    if (InpUseSMC) {
        fvgRetest = CheckFVGRetest(POSITION_TYPE_BUY);
    }
    
    // Combine signals
    int signalCount = 0;
    if (rsiOversold) signalCount++;
    if (bbLowerTouch) signalCount++;
    if (macdBullish) signalCount++;
    if (stochOversold) signalCount++;
    if (fvgRetest) signalCount++;
    
    return signalCount >= 2;
}

//+------------------------------------------------------------------+
//| Get sell signal                                                  |
//+------------------------------------------------------------------+
bool GetSellSignal() {
    // Basic trend filter
    if (InpUseTrendFilter && signalClose[0] > trendMA.Main(0)) return false;
    
    // Market regime filter
    if (InpUseMarketRegimeFilter && currentMarketRegime == REGIME_TRENDING_UP) return false;
    
    // Volume filter
    if (InpUseVolumeFilter && !CheckVolumeFilter()) return false;
    
    // Volatility filter
    if (InpUseVolatilityFilter && !CheckVolatilityFilter()) return false;
    
    // Technical indicators
    bool rsiOverbought = rsi.Main(0) > 70;
    bool bbUpperTouch = signalClose[0] >= bb.Upper(0);
    bool macdBearish = macd.Main(0) < macd.Signal(0);
    bool stochOverbought = stoch.Main(0) > 80;
    
    // Smart Money Concepts
    bool fvgRetest = false;
    if (InpUseSMC) {
        fvgRetest = CheckFVGRetest(POSITION_TYPE_SELL);
    }
    
    // Combine signals
    int signalCount = 0;
    if (rsiOverbought) signalCount++;
    if (bbUpperTouch) signalCount++;
    if (macdBearish) signalCount++;
    if (stochOverbought) signalCount++;
    if (fvgRetest) signalCount++;
    
    return signalCount >= 2;
}

//+------------------------------------------------------------------+
//| Check FVG retest                                                 |
//+------------------------------------------------------------------+
bool CheckFVGRetest(ENUM_POSITION_TYPE direction) {
    double currentPrice = symbolInfo.Bid();
    
    for (int i = 0; i < ArraySize(fvgZones); i++) {
        if (fvgZones[i].isRetested) continue;
        
        if (direction == POSITION_TYPE_BUY && fvgZones[i].zoneColor == clrLime) {
            if (currentPrice <= fvgZones[i].bottom && signalClose[0] > fvgZones[i].bottom) {
                return true;
            }
        } else if (direction == POSITION_TYPE_SELL && fvgZones[i].zoneColor == clrRed) {
            if (currentPrice >= fvgZones[i].top && signalClose[0] < fvgZones[i].top) {
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check volume filter                                              |
//+------------------------------------------------------------------+
bool CheckVolumeFilter() {
    if (!InpUseVolumeFilter) return true;
    
    double avgVolume = 0.0;
    int count = MathMin(InpVolumePeriod, ArraySize(signalVolume));
    
    for (int i = 1; i < count; i++) {
        avgVolume += signalVolume[i];
    }
    avgVolume /= (count - 1);
    
    return signalVolume[0] > avgVolume * InpVolumeMultiplier;
}

//+------------------------------------------------------------------+
//| Check volatility filter                                          |
//+------------------------------------------------------------------+
bool CheckVolatilityFilter() {
    if (!InpUseVolatilityFilter) return true;
    
    double currentATR = atr.Main(0);
    double avgATR = 0.0;
    int count = MathMin(InpVolatilityPeriod, ArraySize(signalClose));
    
    for (int i = 0; i < count; i++) {
        avgATR += atr.Main(i);
    }
    avgATR /= count;
    
    return currentATR <= avgATR * InpMaxVolatilityLevel;
}

//+------------------------------------------------------------------+
//| Execute buy order                                                |
//+------------------------------------------------------------------+
void ExecuteBuyOrder() {
    double lotSize = CalculateLotSize();
    double stopLoss = CalculateStopLoss(POSITION_TYPE_BUY);
    double takeProfit = CalculateTakeProfit(POSITION_TYPE_BUY, stopLoss);
    
    if (lotSize == 0 || stopLoss == 0) return;
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = Symbol();
    request.volume = lotSize;
    request.type = ORDER_TYPE_BUY;
    request.price = symbolInfo.Ask();
    request.sl = stopLoss;
    request.tp = takeProfit;
    request.deviation = InpSlippage;
    request.magic = InpMagicNumber;
    request.comment = InpComment;
    
    if (trade.OrderSend(request, result)) {
        Print("Buy order executed successfully. Ticket: ", result.order);
        
        // Add position to management array
        if (InpUseMultipleTP) {
            AddPositionToManagement(result.order, request.volume, request.price, stopLoss, takeProfit);
        }
    } else {
        Print("Failed to execute buy order. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Execute sell order                                               |
//+------------------------------------------------------------------+
void ExecuteSellOrder() {
    double lotSize = CalculateLotSize();
    double stopLoss = CalculateStopLoss(POSITION_TYPE_SELL);
    double takeProfit = CalculateTakeProfit(POSITION_TYPE_SELL, stopLoss);
    
    if (lotSize == 0 || stopLoss == 0) return;
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = Symbol();
    request.volume = lotSize;
    request.type = ORDER_TYPE_SELL;
    request.price = symbolInfo.Bid();
    request.sl = stopLoss;
    request.tp = takeProfit;
    request.deviation = InpSlippage;
    request.magic = InpMagicNumber;
    request.comment = InpComment;
    
    if (trade.OrderSend(request, result)) {
        Print("Sell order executed successfully. Ticket: ", result.order);
        
        // Add position to management array
        if (InpUseMultipleTP) {
            AddPositionToManagement(result.order, request.volume, request.price, stopLoss, takeProfit);
        }
    } else {
        Print("Failed to execute sell order. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize() {
    if (InpUseFixedLots) {
        return NormalizeDouble(MathMax(InpMinLotSize, MathMin(InpMaxLotSize, InpFixedLotSize)), 2);
    }
    
    if (!InpUseDynamicPositionSizing) {
        return InpMinLotSize;
    }
    
    double balance = accountInfo.Balance();
    double riskAmount = balance * InpRiskPercent / 100.0;
    double stopLossPoints = InpStopLossPoints;
    double tickValue = symbolInfo.TickValue();
    double tickSize = symbolInfo.TickSize();
    
    if (tickValue == 0 || tickSize == 0) return InpMinLotSize;
    
    double lotSize = riskAmount / (stopLossPoints * tickValue / tickSize);
    lotSize = NormalizeDouble(lotSize, 2);
    
    // Apply risk multiplier
    lotSize *= InpAccountRiskMultiplier;
    
    // Apply limits
    lotSize = MathMax(InpMinLotSize, MathMin(InpMaxLotSize, lotSize));
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Calculate stop loss                                              |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_POSITION_TYPE direction) {
    double atrValue = atr.Main(0);
    double stopLossDistance = MathMax(InpStopLossPoints * symbolInfo.Point(), atrValue * 2);
    
    if (direction == POSITION_TYPE_BUY) {
        return NormalizeDouble(symbolInfo.Ask() - stopLossDistance, symbolInfo.Digits());
    } else {
        return NormalizeDouble(symbolInfo.Bid() + stopLossDistance, symbolInfo.Digits());
    }
}

//+------------------------------------------------------------------+
//| Calculate take profit                                            |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_POSITION_TYPE direction, double stopLoss) {
    double entryPrice = (direction == POSITION_TYPE_BUY) ? symbolInfo.Ask() : symbolInfo.Bid();
    double stopLossDistance = MathAbs(entryPrice - stopLoss);
    double takeProfitDistance = stopLossDistance * InpTP1_Ratio;
    
    if (direction == POSITION_TYPE_BUY) {
        return NormalizeDouble(entryPrice + takeProfitDistance, symbolInfo.Digits());
    } else {
        return NormalizeDouble(entryPrice - takeProfitDistance, symbolInfo.Digits());
    }
}

//+------------------------------------------------------------------+
//| Add position to management                                       |
//+------------------------------------------------------------------+
void AddPositionToManagement(ulong ticket, double lotSize, double openPrice, double stopLoss, double takeProfit) {
    int size = ArraySize(positions);
    ArrayResize(positions, size + 1);
    
    positions[size].ticket = ticket;
    positions[size].openPrice = openPrice;
    positions[size].lotSize = lotSize;
    positions[size].stopLoss = stopLoss;
    positions[size].takeProfit = takeProfit;
    positions[size].openTime = TimeCurrent();
    positions[size].tp1Hit = false;
    positions[size].tp2Hit = false;
    positions[size].tp3Hit = false;
    positions[size].breakEvenSet = false;
    positions[size].trailingActive = false;
    positions[size].lastTrailingPrice = openPrice;
}

//+------------------------------------------------------------------+
//| Manage positions                                                 |
//+------------------------------------------------------------------+
void ManagePositions() {
    for (int i = ArraySize(positions) - 1; i >= 0; i--) {
        if (!positionInfo.SelectByTicket(positions[i].ticket)) {
            // Position closed - remove from array
            ArrayRemove(positions, i, 1);
            continue;
        }
        
        // Break even management
        if (InpUseBreakEven && !positions[i].breakEvenSet) {
            ManageBreakEven(i);
        }
        
        // Trailing stop management
        if (InpUseTrailingStop) {
            ManageTrailingStop(i);
        }
        
        // Multiple take profit management
        if (InpUseMultipleTP) {
            ManageMultipleTP(i);
        }
    }
}

//+------------------------------------------------------------------+
//| Manage break even                                                |
//+------------------------------------------------------------------+
void ManageBreakEven(int index) {
    double currentPrice = positionInfo.PriceCurrent();
    double openPrice = positions[index].openPrice;
    double breakEvenDistance = InpBreakEvenPoints * symbolInfo.Point();
    double breakEvenProfit = InpBreakEvenProfit * symbolInfo.Point();
    
    if (positionInfo.PositionType() == POSITION_TYPE_BUY) {
        if (currentPrice >= openPrice + breakEvenDistance) {
            double newStopLoss = openPrice + breakEvenProfit;
            if (trade.PositionModify(positions[index].ticket, newStopLoss, positionInfo.TakeProfit())) {
                positions[index].breakEvenSet = true;
                positions[index].stopLoss = newStopLoss;
                Print("Break even set for position ", positions[index].ticket);
            }
        }
    } else {
        if (currentPrice <= openPrice - breakEvenDistance) {
            double newStopLoss = openPrice - breakEvenProfit;
            if (trade.PositionModify(positions[index].ticket, newStopLoss, positionInfo.TakeProfit())) {
                positions[index].breakEvenSet = true;
                positions[index].stopLoss = newStopLoss;
                Print("Break even set for position ", positions[index].ticket);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage trailing stop                                             |
//+------------------------------------------------------------------+
void ManageTrailingStop(int index) {
    double currentPrice = positionInfo.PriceCurrent();
    double currentStopLoss = positionInfo.StopLoss();
    double trailingDistance = InpTrailingStopPoints * symbolInfo.Point();
    double trailingStep = InpTrailingStepPoints * symbolInfo.Point();
    
    if (positionInfo.PositionType() == POSITION_TYPE_BUY) {
        double newStopLoss = currentPrice - trailingDistance;
        if (newStopLoss > currentStopLoss + trailingStep) {
            if (trade.PositionModify(positions[index].ticket, newStopLoss, positionInfo.TakeProfit())) {
                positions[index].stopLoss = newStopLoss;
                positions[index].trailingActive = true;
                Print("Trailing stop updated for position ", positions[index].ticket);
            }
        }
    } else {
        double newStopLoss = currentPrice + trailingDistance;
        if (newStopLoss < currentStopLoss - trailingStep) {
            if (trade.PositionModify(positions[index].ticket, newStopLoss, positionInfo.TakeProfit())) {
                positions[index].stopLoss = newStopLoss;
                positions[index].trailingActive = true;
                Print("Trailing stop updated for position ", positions[index].ticket);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage multiple take profit                                      |
//+------------------------------------------------------------------+
void ManageMultipleTP(int index) {
    double currentPrice = positionInfo.PriceCurrent();
    double openPrice = positions[index].openPrice;
    double stopLoss = positions[index].stopLoss;
    double riskDistance = MathAbs(openPrice - stopLoss);
    
    // Calculate TP levels
    double tp1Level, tp2Level, tp3Level;
    
    if (positionInfo.PositionType() == POSITION_TYPE_BUY) {
        tp1Level = openPrice + riskDistance * InpTP1_Ratio;
        tp2Level = openPrice + riskDistance * InpTP2_Ratio;
        tp3Level = openPrice + riskDistance * InpTP3_Ratio;
    } else {
        tp1Level = openPrice - riskDistance * InpTP1_Ratio;
        tp2Level = openPrice - riskDistance * InpTP2_Ratio;
        tp3Level = openPrice - riskDistance * InpTP3_Ratio;
    }
    
    // Check TP1
    if (!positions[index].tp1Hit) {
        if ((positionInfo.PositionType() == POSITION_TYPE_BUY && currentPrice >= tp1Level) ||
            (positionInfo.PositionType() == POSITION_TYPE_SELL && currentPrice <= tp1Level)) {
            
            double closeLots = positions[index].lotSize * InpTP1_Percent / 100.0;
            if (trade.PositionClosePartial(positions[index].ticket, closeLots)) {
                positions[index].tp1Hit = true;
                Print("TP1 hit for position ", positions[index].ticket);
            }
        }
    }
    
    // Check TP2
    if (!positions[index].tp2Hit && positions[index].tp1Hit) {
        if ((positionInfo.PositionType() == POSITION_TYPE_BUY && currentPrice >= tp2Level) ||
            (positionInfo.PositionType() == POSITION_TYPE_SELL && currentPrice <= tp2Level)) {
            
            double closeLots = positions[index].lotSize * InpTP2_Percent / 100.0;
            if (trade.PositionClosePartial(positions[index].ticket, closeLots)) {
                positions[index].tp2Hit = true;
                Print("TP2 hit for position ", positions[index].ticket);
            }
        }
    }
    
    // Check TP3
    if (!positions[index].tp3Hit && positions[index].tp2Hit) {
        if ((positionInfo.PositionType() == POSITION_TYPE_BUY && currentPrice >= tp3Level) ||
            (positionInfo.PositionType() == POSITION_TYPE_SELL && currentPrice <= tp3Level)) {
            
            if (trade.PositionClose(positions[index].ticket)) {
                positions[index].tp3Hit = true;
                Print("TP3 hit for position ", positions[index].ticket);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update statistics                                                |
//+------------------------------------------------------------------+
void UpdateStatistics() {
    double currentBalance = accountInfo.Balance();
    double currentEquity = accountInfo.Equity();
    
    // Update peak balance
    if (currentBalance > peakBalance) {
        peakBalance = currentBalance;
    }
    
    // Calculate drawdown
    currentDrawdown = (peakBalance - currentEquity) / peakBalance * 100.0;
    if (currentDrawdown > maxDrawdown) {
        maxDrawdown = currentDrawdown;
    }
    
    // Update trade statistics
    static double lastBalance = 0;
    if (lastBalance == 0) lastBalance = currentBalance;
    
    if (currentBalance != lastBalance) {
        double profit = currentBalance - lastBalance;
        totalTrades++;
        
        if (profit > 0) {
            totalProfit += profit;
            winningTrades++;
        } else {
            totalLoss += MathAbs(profit);
            losingTrades++;
        }
        
        lastBalance = currentBalance;
    }
}

//+------------------------------------------------------------------+
//| Check for errors                                                 |
//+------------------------------------------------------------------+
bool CheckForErrors() {
    int error = GetLastError();
    if (error != 0) {
        datetime currentTime = TimeCurrent();
        
        // Don't spam error messages
        if (error != lastError || currentTime - lastErrorTime > 60) {
            Print("Error detected: ", error, " - ", ErrorDescription(error));
            lastError = error;
            lastErrorTime = currentTime;
        }
        
        // Handle specific errors
        switch (error) {
            case 4109: // Trade not allowed
            case 4110: // Long positions not allowed
            case 4111: // Short positions not allowed
                return false;
            case 4051: // Invalid function parameter value
            case 4052: // String function internal error
            case 4053: // Some array error
                ResetLastError();
                return false;
            default:
                ResetLastError();
                break;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Error description                                                |
//+------------------------------------------------------------------+
string ErrorDescription(int error) {
    switch (error) {
        case 4109: return "Trade not allowed";
        case 4110: return "Long positions not allowed";
        case 4111: return "Short positions not allowed";
        case 4051: return "Invalid function parameter value";
        case 4052: return "String function internal error";
        case 4053: return "Some array error";
        case 4054: return "Incorrect size of the array";
        case 4055: return "Array declaration error";
        case 4056: return "Too long string";
        case 4057: return "Error in formatted output";
        case 4058: return "Access violation";
        case 4059: return "Invalid pointer";
        case 4060: return "Invalid pointer type";
        case 4061: return "Function not allowed in testing mode";
        case 4062: return "Function not allowed for the object";
        case 4063: return "Invalid array type";
        case 4064: return "Invalid array size";
        case 4065: return "Invalid array";
        case 4066: return "Invalid array index";
        case 4067: return "Invalid array size";
        case 4068: return "Invalid array type";
        case 4069: return "Invalid array";
        case 4070: return "Invalid array index";
        default: return "Unknown error";
    }
}

//+------------------------------------------------------------------+
//| Clean up chart objects                                           |
//+------------------------------------------------------------------+
void CleanupChartObjects() {
    int total = ObjectsTotal(0);
    for (int i = total - 1; i >= 0; i--) {
        string objName = ObjectName(0, i);
        if (StringFind(objName, "FVG_") == 0 || 
            StringFind(objName, "LIQ_") == 0 || 
            StringFind(objName, "OB_") == 0) {
            ObjectDelete(0, objName);
        }
    }
}

//+------------------------------------------------------------------+
//| Print final statistics                                           |
//+------------------------------------------------------------------+
void PrintFinalStatistics() {
    Print("=== FINAL STATISTICS ===");
    Print("Total Trades: ", totalTrades);
    Print("Winning Trades: ", winningTrades);
    Print("Losing Trades: ", losingTrades);
    Print("Win Rate: ", (totalTrades > 0) ? DoubleToString(winningTrades * 100.0 / totalTrades, 2) : "0.00", "%");
    Print("Total Profit: ", DoubleToString(totalProfit, 2));
    Print("Total Loss: ", DoubleToString(totalLoss, 2));
    Print("Net Profit: ", DoubleToString(totalProfit - totalLoss, 2));
    Print("Max Drawdown: ", DoubleToString(maxDrawdown, 2), "%");
    Print("Current Drawdown: ", DoubleToString(currentDrawdown, 2), "%");
    Print("Final Balance: ", DoubleToString(accountInfo.Balance(), 2));
    Print("Final Equity: ", DoubleToString(accountInfo.Equity(), 2));
    Print("========================");
}



//+------------------------------------------------------------------+
//| OnTrade event handler                                            |
//+------------------------------------------------------------------+
void OnTrade() {
    // Update statistics when trades are executed
    UpdateStatistics();
}

//+------------------------------------------------------------------+
//| OnTradeTransaction event handler                                 |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
    // Handle trade transactions for detailed tracking
    if (trans.type == TRADE_TRANSACTION_DEAL_ADD) {
        Print("Deal executed: ", trans.deal, " Type: ", trans.deal_type, " Volume: ", trans.volume);
    }
}

//+------------------------------------------------------------------+
//| OnTimer event handler                                            |
//+------------------------------------------------------------------+
void OnTimer() {
    // Periodic tasks can be handled here
    // For example, cleanup old objects, update statistics, etc.
    static datetime lastCleanup = 0;
    
    if (TimeCurrent() - lastCleanup > 3600) { // Clean up every hour
        CleanupChartObjects();
        lastCleanup = TimeCurrent();
    }
}