//+------------------------------------------------------------------+
//|                                                ProfitPulsePro.mq5 |
//|                                           Smart Money Concepts EA |
//|                                                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"
#property description "Smart Money Concepts EA with Fair Value Gaps and Break of Structure"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input group "=== Trading Settings ==="
input ENUM_TIMEFRAMES TradeTF = PERIOD_M15;           // Trade Timeframe
input ENUM_TIMEFRAMES StructureTF = PERIOD_H1;        // Structure Timeframe
input int FVGLookback = 3;                             // FVG Lookback
input int MaxRetestBars = 12;                          // Max Retest Bars
input int ImpulseBars = 3;                             // Impulse Bars
input bool ShowFVG = true;                             // Show FVG Zones
input bool ShowBoS = true;                             // Show Break of Structure

input group "=== Risk Management ==="
input double LotSize = 0.1;                           // Lot Size
input double StopLoss = 50;                            // Stop Loss (points)
input double TakeProfit = 100;                        // Take Profit (points)
input int MaxSpread = 30;                              // Max Spread (points)

input group "=== Trading Hours ==="
input bool UseTimeFiler = false;                      // Use Time Filter
input int StartHour = 8;                               // Start Hour
input int EndHour = 18;                                // End Hour

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double LastPH = EMPTY_VALUE;                          // Last Pivot High
double LastPL = EMPTY_VALUE;                          // Last Pivot Low
datetime LastFVGTime = 0;                             // Last FVG signal time
datetime LastBoSTime = 0;                             // Last BoS signal time

struct FVGZone {
    datetime time;
    double top;
    double bottom;
    bool active;
};

FVGZone FVGBoxes[];                                   // Array to store FVG zones
int FVGCount = 0;                                     // Count of active FVG zones

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize arrays
    ArrayResize(FVGBoxes, 100);
    FVGCount = 0;
    
    // Reset last values
    LastPH = EMPTY_VALUE;
    LastPL = EMPTY_VALUE;
    LastFVGTime = 0;
    LastBoSTime = 0;
    
    Print("ProfitPulsePro EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("ProfitPulsePro EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    // Check if new bar
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(_Symbol, TradeTF, 0);
    
    if (currentBarTime == lastBarTime) return;
    lastBarTime = currentBarTime;
    
    // Check trading time
    if (UseTimeFiler && !IsTradeTime()) return;
    
    // Check spread
    if (SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpread) return;
    
    // Update market structure
    UpdateMarketStructure();
    
    // Update FVG zones
    UpdateFVGZones();
    
    // Check for trading signals
    CheckTradingSignals();
    
    // Clean old FVG zones
    CleanOldFVGZones();
}

//+------------------------------------------------------------------+
//| Update market structure (Break of Structure)                     |
//+------------------------------------------------------------------+
void UpdateMarketStructure() {
    if (!ShowBoS) return;
    
    // Get higher timeframe data
    double high[], low[], close[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    
    if (CopyHigh(_Symbol, StructureTF, 0, ImpulseBars * 2 + 1, high) <= 0) return;
    if (CopyLow(_Symbol, StructureTF, 0, ImpulseBars * 2 + 1, low) <= 0) return;
    if (CopyClose(_Symbol, StructureTF, 0, ImpulseBars * 2 + 1, close) <= 0) return;
    
    // Find pivot high
    double ph = GetPivotHigh(high, ImpulseBars);
    if (ph != EMPTY_VALUE) {
        LastPH = ph;
    }
    
    // Find pivot low
    double pl = GetPivotLow(low, ImpulseBars);
    if (pl != EMPTY_VALUE) {
        LastPL = pl;
    }
    
    // Check for Break of Structure
    if (LastPH != EMPTY_VALUE && close[0] > LastPH && TimeCurrent() - LastBoSTime > PeriodSeconds(TradeTF)) {
        // Bullish BoS
        LastBoSTime = TimeCurrent();
        Print("Bullish Break of Structure detected at: ", DoubleToString(close[0], _Digits));
    }
    
    if (LastPL != EMPTY_VALUE && close[0] < LastPL && TimeCurrent() - LastBoSTime > PeriodSeconds(TradeTF)) {
        // Bearish BoS
        LastBoSTime = TimeCurrent();
        Print("Bearish Break of Structure detected at: ", DoubleToString(close[0], _Digits));
    }
}

//+------------------------------------------------------------------+
//| Update Fair Value Gap zones                                      |
//+------------------------------------------------------------------+
void UpdateFVGZones() {
    if (!ShowFVG) return;
    
    // Get current timeframe data
    double high[], low[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    
    if (CopyHigh(_Symbol, TradeTF, 0, FVGLookback + 1, high) <= 0) return;
    if (CopyLow(_Symbol, TradeTF, 0, FVGLookback + 1, low) <= 0) return;
    
    // Check for bullish FVG (gap up)
    if (high[FVGLookback] < low[FVGLookback - 1]) {
        // Create new FVG zone
        if (FVGCount < ArraySize(FVGBoxes)) {
            FVGBoxes[FVGCount].time = TimeCurrent();
            FVGBoxes[FVGCount].top = low[FVGLookback - 1];
            FVGBoxes[FVGCount].bottom = high[FVGLookback];
            FVGBoxes[FVGCount].active = true;
            FVGCount++;
            
            Print("New Bullish FVG created: Top=", DoubleToString(low[FVGLookback - 1], _Digits), 
                  " Bottom=", DoubleToString(high[FVGLookback], _Digits));
        }
    }
    
    // Check for bearish FVG (gap down)
    if (low[FVGLookback] > high[FVGLookback - 1]) {
        // Create new FVG zone
        if (FVGCount < ArraySize(FVGBoxes)) {
            FVGBoxes[FVGCount].time = TimeCurrent();
            FVGBoxes[FVGCount].top = low[FVGLookback];
            FVGBoxes[FVGCount].bottom = high[FVGLookback - 1];
            FVGBoxes[FVGCount].active = true;
            FVGCount++;
            
            Print("New Bearish FVG created: Top=", DoubleToString(low[FVGLookback], _Digits), 
                  " Bottom=", DoubleToString(high[FVGLookback - 1], _Digits));
        }
    }
}

//+------------------------------------------------------------------+
//| Check for trading signals                                        |
//+------------------------------------------------------------------+
void CheckTradingSignals() {
    if (FVGCount == 0) return;
    
    // Get current price data
    double currentHigh = iHigh(_Symbol, TradeTF, 0);
    double currentLow = iLow(_Symbol, TradeTF, 0);
    double currentClose = iClose(_Symbol, TradeTF, 0);
    
    // Check FVG retests
    for (int i = 0; i < FVGCount; i++) {
        if (!FVGBoxes[i].active) continue;
        
        // Check for bullish FVG retest (price hits bottom of gap and closes above)
        if (currentLow <= FVGBoxes[i].bottom && currentClose > FVGBoxes[i].bottom) {
            if (TimeCurrent() - LastFVGTime > PeriodSeconds(TradeTF)) {
                LastFVGTime = TimeCurrent();
                ProcessBuySignal("FVG Bullish Retest");
                FVGBoxes[i].active = false; // Deactivate after use
            }
        }
        
        // Check for bearish FVG retest (price hits top of gap and closes below)
        if (currentHigh >= FVGBoxes[i].top && currentClose < FVGBoxes[i].top) {
            if (TimeCurrent() - LastFVGTime > PeriodSeconds(TradeTF)) {
                LastFVGTime = TimeCurrent();
                ProcessSellSignal("FVG Bearish Retest");
                FVGBoxes[i].active = false; // Deactivate after use
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Process buy signal                                               |
//+------------------------------------------------------------------+
void ProcessBuySignal(string signal) {
    Print("Buy signal detected: ", signal);
    
    // Check if we already have a buy position
    if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        return;
    }
    
    // Close any existing sell position
    if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
        CloseSellPosition();
    }
    
    // Open buy position
    OpenBuyPosition(signal);
}

//+------------------------------------------------------------------+
//| Process sell signal                                              |
//+------------------------------------------------------------------+
void ProcessSellSignal(string signal) {
    Print("Sell signal detected: ", signal);
    
    // Check if we already have a sell position
    if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
        return;
    }
    
    // Close any existing buy position
    if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        CloseBuyPosition();
    }
    
    // Open sell position
    OpenSellPosition(signal);
}

//+------------------------------------------------------------------+
//| Open buy position                                                |
//+------------------------------------------------------------------+
void OpenBuyPosition(string comment) {
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double sl = StopLoss > 0 ? ask - StopLoss * _Point : 0;
    double tp = TakeProfit > 0 ? ask + TakeProfit * _Point : 0;
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = LotSize;
    request.type = ORDER_TYPE_BUY;
    request.price = ask;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 3;
    request.magic = 123456;
    request.comment = comment;
    
    if (!OrderSend(request, result)) {
        Print("Failed to open buy position: ", result.retcode, " - ", result.comment);
    } else {
        Print("Buy position opened successfully: ", result.comment);
    }
}

//+------------------------------------------------------------------+
//| Open sell position                                               |
//+------------------------------------------------------------------+
void OpenSellPosition(string comment) {
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = StopLoss > 0 ? bid + StopLoss * _Point : 0;
    double tp = TakeProfit > 0 ? bid - TakeProfit * _Point : 0;
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = LotSize;
    request.type = ORDER_TYPE_SELL;
    request.price = bid;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 3;
    request.magic = 123456;
    request.comment = comment;
    
    if (!OrderSend(request, result)) {
        Print("Failed to open sell position: ", result.retcode, " - ", result.comment);
    } else {
        Print("Sell position opened successfully: ", result.comment);
    }
}

//+------------------------------------------------------------------+
//| Close buy position                                               |
//+------------------------------------------------------------------+
void CloseBuyPosition() {
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    
    if (!PositionSelect(_Symbol)) return;
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = PositionGetDouble(POSITION_VOLUME);
    request.type = ORDER_TYPE_SELL;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    request.position = PositionGetInteger(POSITION_TICKET);
    request.deviation = 3;
    request.magic = 123456;
    
    if (!OrderSend(request, result)) {
        Print("Failed to close buy position: ", result.retcode, " - ", result.comment);
    } else {
        Print("Buy position closed successfully");
    }
}

//+------------------------------------------------------------------+
//| Close sell position                                              |
//+------------------------------------------------------------------+
void CloseSellPosition() {
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    
    if (!PositionSelect(_Symbol)) return;
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = PositionGetDouble(POSITION_VOLUME);
    request.type = ORDER_TYPE_BUY;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.position = PositionGetInteger(POSITION_TICKET);
    request.deviation = 3;
    request.magic = 123456;
    
    if (!OrderSend(request, result)) {
        Print("Failed to close sell position: ", result.retcode, " - ", result.comment);
    } else {
        Print("Sell position closed successfully");
    }
}

//+------------------------------------------------------------------+
//| Get pivot high                                                   |
//+------------------------------------------------------------------+
double GetPivotHigh(double &high[], int period) {
    if (ArraySize(high) < period * 2 + 1) return EMPTY_VALUE;
    
    double pivotValue = high[period];
    bool isPivot = true;
    
    // Check left side
    for (int i = 0; i < period; i++) {
        if (high[i] >= pivotValue) {
            isPivot = false;
            break;
        }
    }
    
    // Check right side
    if (isPivot) {
        for (int i = period + 1; i < period * 2 + 1; i++) {
            if (high[i] >= pivotValue) {
                isPivot = false;
                break;
            }
        }
    }
    
    return isPivot ? pivotValue : EMPTY_VALUE;
}

//+------------------------------------------------------------------+
//| Get pivot low                                                    |
//+------------------------------------------------------------------+
double GetPivotLow(double &low[], int period) {
    if (ArraySize(low) < period * 2 + 1) return EMPTY_VALUE;
    
    double pivotValue = low[period];
    bool isPivot = true;
    
    // Check left side
    for (int i = 0; i < period; i++) {
        if (low[i] <= pivotValue) {
            isPivot = false;
            break;
        }
    }
    
    // Check right side
    if (isPivot) {
        for (int i = period + 1; i < period * 2 + 1; i++) {
            if (low[i] <= pivotValue) {
                isPivot = false;
                break;
            }
        }
    }
    
    return isPivot ? pivotValue : EMPTY_VALUE;
}

//+------------------------------------------------------------------+
//| Clean old FVG zones                                              |
//+------------------------------------------------------------------+
void CleanOldFVGZones() {
    datetime currentTime = TimeCurrent();
    
    for (int i = 0; i < FVGCount; i++) {
        if (FVGBoxes[i].active && 
            (currentTime - FVGBoxes[i].time) > MaxRetestBars * PeriodSeconds(TradeTF)) {
            FVGBoxes[i].active = false;
        }
    }
    
    // Compact the array by removing inactive zones
    int writeIndex = 0;
    for (int i = 0; i < FVGCount; i++) {
        if (FVGBoxes[i].active) {
            if (writeIndex != i) {
                FVGBoxes[writeIndex] = FVGBoxes[i];
            }
            writeIndex++;
        }
    }
    FVGCount = writeIndex;
}

//+------------------------------------------------------------------+
//| Check if it's trading time                                       |
//+------------------------------------------------------------------+
bool IsTradeTime() {
    MqlDateTime time;
    TimeToStruct(TimeCurrent(), time);
    
    return (time.hour >= StartHour && time.hour < EndHour);
}

//+------------------------------------------------------------------+