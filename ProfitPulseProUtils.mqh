//+------------------------------------------------------------------+
//|                                          ProfitPulseProUtils.mqh |
//|                                 Copyright 2024, Shilohsos       |
//|                                             https://github.com/Shilohsos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Shilohsos"
#property link      "https://github.com/Shilohsos"

//+------------------------------------------------------------------+
//| News Filter Structure                                            |
//+------------------------------------------------------------------+
struct NewsEvent
{
    datetime eventTime;
    string currency;
    int impact; // 1=Low, 2=Medium, 3=High
    string eventName;
};

//+------------------------------------------------------------------+
//| Fair Value Gap Structure                                         |
//+------------------------------------------------------------------+
struct FairValueGap
{
    datetime startTime;
    double topPrice;
    double bottomPrice;
    bool isActive;
    int retestCount;
};

//+------------------------------------------------------------------+
//| Market Structure Levels                                          |
//+------------------------------------------------------------------+
struct MarketStructure
{
    double swingHigh;
    double swingLow;
    datetime highTime;
    datetime lowTime;
    bool isValid;
};

//+------------------------------------------------------------------+
//| Position Management Structure                                    |
//+------------------------------------------------------------------+
struct PositionInfo
{
    ulong ticket;
    double openPrice;
    double currentPrice;
    double volume;
    double profit;
    double profitPips;
    bool isLong;
    datetime openTime;
    bool tp1Hit;
    bool tp2Hit;
    bool breakEvenSet;
};

//+------------------------------------------------------------------+
//| Risk Metrics Structure                                           |
//+------------------------------------------------------------------+
struct RiskMetrics
{
    double dailyPnL;
    double dailyPnLPercent;
    double maxDrawdown;
    double maxDrawdownPercent;
    double winRate;
    double profitFactor;
    int totalTrades;
    int winningTrades;
    int losingTrades;
};

//+------------------------------------------------------------------+
//| Utility Functions                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Convert pips to points                                           |
//+------------------------------------------------------------------+
double PipsToPoints(double pips)
{
    return pips * Point * 10;
}

//+------------------------------------------------------------------+
//| Convert points to pips                                           |
//+------------------------------------------------------------------+
double PointsToPips(double points)
{
    return points / (Point * 10);
}

//+------------------------------------------------------------------+
//| Check if current time is within news filter window              |
//+------------------------------------------------------------------+
bool IsNewsFilterActive(int newsFilterMinutes)
{
    // This is a simplified implementation
    // In a real implementation, you would parse economic calendar data
    // For now, we'll use a basic high-impact news time filter
    
    MqlDateTime currentTime;
    TimeToStruct(TimeCurrent(), currentTime);
    
    // Common high-impact news times (simplified)
    int highImpactHours[] = {8, 10, 12, 14, 16}; // GMT hours
    
    for(int i = 0; i < ArraySize(highImpactHours); i++)
    {
        if(currentTime.hour == highImpactHours[i])
        {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate position size based on account currency               |
//+------------------------------------------------------------------+
double CalculatePositionSize(double riskAmount, double stopLossPoints, string symbol)
{
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    if(tickValue <= 0 || tickSize <= 0 || stopLossPoints <= 0)
        return 0;
    
    double lotSize = riskAmount / (stopLossPoints / tickSize * tickValue);
    
    // Round to lot step
    lotSize = MathRound(lotSize / lotStep) * lotStep;
    
    // Apply limits
    lotSize = MathMax(lotSize, minLot);
    lotSize = MathMin(lotSize, maxLot);
    
    return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Calculate Average True Range                                     |
//+------------------------------------------------------------------+
double CalculateATR(string symbol, ENUM_TIMEFRAMES timeframe, int period)
{
    int handle = iATR(symbol, timeframe, period);
    if(handle == INVALID_HANDLE) return 0;
    
    double atr[];
    ArraySetAsSeries(atr, true);
    
    if(CopyBuffer(handle, 0, 0, 1, atr) != 1)
        return 0;
    
    return atr[0];
}

//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double CalculateStdDev(string symbol, ENUM_TIMEFRAMES timeframe, int period)
{
    int handle = iStdDev(symbol, timeframe, period, 0, MODE_SMA, PRICE_CLOSE);
    if(handle == INVALID_HANDLE) return 0;
    
    double stddev[];
    ArraySetAsSeries(stddev, true);
    
    if(CopyBuffer(handle, 0, 0, 1, stddev) != 1)
        return 0;
    
    return stddev[0];
}

//+------------------------------------------------------------------+
//| Calculate Bollinger Bands                                        |
//+------------------------------------------------------------------+
bool CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, int period, double deviation, 
                            double &upperBand, double &middleBand, double &lowerBand)
{
    int handle = iBands(symbol, timeframe, period, 0, deviation, PRICE_CLOSE);
    if(handle == INVALID_HANDLE) return false;
    
    double upper[], middle[], lower[];
    ArraySetAsSeries(upper, true);
    ArraySetAsSeries(middle, true);
    ArraySetAsSeries(lower, true);
    
    if(CopyBuffer(handle, 0, 0, 1, upper) != 1 ||
       CopyBuffer(handle, 1, 0, 1, middle) != 1 ||
       CopyBuffer(handle, 2, 0, 1, lower) != 1)
        return false;
    
    upperBand = upper[0];
    middleBand = middle[0];
    lowerBand = lower[0];
    
    return true;
}

//+------------------------------------------------------------------+
//| Find pivot highs and lows                                        |
//+------------------------------------------------------------------+
bool FindPivotLevels(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars,
                     double &pivotHigh, double &pivotLow, int &highIndex, int &lowIndex)
{
    double high[], low[];
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    
    int barsNeeded = leftBars + rightBars + 1;
    
    if(CopyHigh(symbol, timeframe, 0, barsNeeded, high) != barsNeeded ||
       CopyLow(symbol, timeframe, 0, barsNeeded, low) != barsNeeded)
        return false;
    
    // Find pivot high
    pivotHigh = 0;
    highIndex = -1;
    for(int i = leftBars; i < ArraySize(high) - rightBars; i++)
    {
        bool isPivotHigh = true;
        
        // Check left side
        for(int j = i - leftBars; j < i; j++)
        {
            if(high[j] >= high[i])
            {
                isPivotHigh = false;
                break;
            }
        }
        
        // Check right side
        if(isPivotHigh)
        {
            for(int j = i + 1; j <= i + rightBars; j++)
            {
                if(high[j] >= high[i])
                {
                    isPivotHigh = false;
                    break;
                }
            }
        }
        
        if(isPivotHigh && high[i] > pivotHigh)
        {
            pivotHigh = high[i];
            highIndex = i;
        }
    }
    
    // Find pivot low
    pivotLow = DBL_MAX;
    lowIndex = -1;
    for(int i = leftBars; i < ArraySize(low) - rightBars; i++)
    {
        bool isPivotLow = true;
        
        // Check left side
        for(int j = i - leftBars; j < i; j++)
        {
            if(low[j] <= low[i])
            {
                isPivotLow = false;
                break;
            }
        }
        
        // Check right side
        if(isPivotLow)
        {
            for(int j = i + 1; j <= i + rightBars; j++)
            {
                if(low[j] <= low[i])
                {
                    isPivotLow = false;
                    break;
                }
            }
        }
        
        if(isPivotLow && low[i] < pivotLow)
        {
            pivotLow = low[i];
            lowIndex = i;
        }
    }
    
    return (highIndex != -1 && lowIndex != -1);
}

//+------------------------------------------------------------------+
//| Calculate position profit in pips                                |
//+------------------------------------------------------------------+
double CalculatePositionProfitPips(ulong ticket)
{
    if(!PositionSelectByTicket(ticket)) return 0;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    bool isLong = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
    
    double profitPips = (isLong ? currentPrice - openPrice : openPrice - currentPrice) / (Point * 10);
    
    return profitPips;
}

//+------------------------------------------------------------------+
//| Check if symbol is tradeable                                     |
//+------------------------------------------------------------------+
bool IsSymbolTradeable(string symbol)
{
    return (SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL);
}

//+------------------------------------------------------------------+
//| Get market hours for symbol                                      |
//+------------------------------------------------------------------+
bool GetMarketHours(string symbol, int &startHour, int &endHour)
{
    // Simplified market hours - should be enhanced for each symbol
    startHour = 0;
    endHour = 24;
    
    // Major forex pairs are traded 24/5
    if(StringFind(symbol, "USD") >= 0 || StringFind(symbol, "EUR") >= 0 || 
       StringFind(symbol, "GBP") >= 0 || StringFind(symbol, "JPY") >= 0)
    {
        startHour = 0;
        endHour = 24;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate correlation between two symbols                        |
//+------------------------------------------------------------------+
double CalculateCorrelation(string symbol1, string symbol2, ENUM_TIMEFRAMES timeframe, int period)
{
    double prices1[], prices2[];
    ArraySetAsSeries(prices1, true);
    ArraySetAsSeries(prices2, true);
    
    if(CopyClose(symbol1, timeframe, 0, period, prices1) != period ||
       CopyClose(symbol2, timeframe, 0, period, prices2) != period)
        return 0;
    
    double sum1 = 0, sum2 = 0, sum1Sq = 0, sum2Sq = 0, sum12 = 0;
    
    for(int i = 0; i < period; i++)
    {
        sum1 += prices1[i];
        sum2 += prices2[i];
        sum1Sq += prices1[i] * prices1[i];
        sum2Sq += prices2[i] * prices2[i];
        sum12 += prices1[i] * prices2[i];
    }
    
    double numerator = period * sum12 - sum1 * sum2;
    double denominator = MathSqrt((period * sum1Sq - sum1 * sum1) * (period * sum2Sq - sum2 * sum2));
    
    if(denominator == 0) return 0;
    
    return numerator / denominator;
}

//+------------------------------------------------------------------+
//| Log trade statistics                                             |
//+------------------------------------------------------------------+
void LogTradeStats(string action, double lotSize, double price, double sl, double tp, string signal)
{
    string logMessage = StringFormat("%s: %s | Lot: %.2f | Price: %.5f | SL: %.5f | TP: %.5f | Signal: %s",
                                   TimeToString(TimeCurrent()),
                                   action,
                                   lotSize,
                                   price,
                                   sl,
                                   tp,
                                   signal);
    
    Print(logMessage);
    
    // Optionally write to file
    int fileHandle = FileOpen("ProfitPulsePro_Log.txt", FILE_WRITE | FILE_READ | FILE_TXT);
    if(fileHandle != INVALID_HANDLE)
    {
        FileSeek(fileHandle, 0, SEEK_END);
        FileWrite(fileHandle, logMessage);
        FileClose(fileHandle);
    }
}