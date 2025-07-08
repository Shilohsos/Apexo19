//+------------------------------------------------------------------+
//|                                                ProfitPulsePro.mq5 |
//|                                     Copyright 2025, Shilohsos    |
//|                                   SMC Smart Money Concepts v6 EA |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Shilohsos"
#property link      ""
#property version   "1.00"
#property description "ProfitPulsePro EA - Smart Money Concepts with FVG and BoS detection"

// Required includes
#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Object.mqh>

// Trading object
CTrade trade;

// Input parameters
input ENUM_TIMEFRAMES InpTradeTF = PERIOD_M15;         // Trade Timeframe
input ENUM_TIMEFRAMES InpStructureTF = PERIOD_H1;      // Structure Timeframe
input int InpFVGLen = 3;                               // FVG Lookback
input int InpMaxRetestBars = 12;                       // Max Retest Bars
input int InpImpulseBars = 3;                          // Impulse Bars
input bool InpShowFVG = true;                          // Show FVG Zones
input bool InpShowBoS = true;                          // Show Break of Structure
input double InpLotSize = 0.01;                        // Lot Size
input int InpMagicNumber = 123456;                     // Magic Number
input int InpSlippage = 3;                             // Slippage
input double InpStopLoss = 100.0;                      // Stop Loss (points)
input double InpTakeProfit = 200.0;                    // Take Profit (points)

// Global variables
double lastPH = 0.0;
double lastPL = 0.0;
datetime lastPHTime = 0;
datetime lastPLTime = 0;

// FVG structure
struct FVGBox {
    datetime startTime;
    double topPrice;
    double bottomPrice;
    int barsAge;
    bool isValid;
};

// Dynamic array for FVG boxes
FVGBox fvgBoxes[];
int fvgBoxCount = 0;

// Arrays for higher timeframe data
double hiHTF[];
double loHTF[];
double clHTF[];
datetime timeHTF[];

// Handles for indicators (if needed)
int handleHTF = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Print account information
    Print("=== ProfitPulsePro EA Initialization ===");
    Print(GetAccountInfo());
    
    // Initialize trade object
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(Symbol());
    trade.SetDeviationInPoints(InpSlippage);
    
    // Initialize arrays
    ArrayResize(fvgBoxes, 100);
    ArrayResize(hiHTF, 1000);
    ArrayResize(loHTF, 1000);
    ArrayResize(clHTF, 1000);
    ArrayResize(timeHTF, 1000);
    
    // Set array as series
    ArraySetAsSeries(hiHTF, true);
    ArraySetAsSeries(loHTF, true);
    ArraySetAsSeries(clHTF, true);
    ArraySetAsSeries(timeHTF, true);
    
    // Print parameters
    Print("Trade Timeframe: ", EnumToString(InpTradeTF));
    Print("Structure Timeframe: ", EnumToString(InpStructureTF));
    Print("FVG Lookback: ", InpFVGLen);
    Print("Max Retest Bars: ", InpMaxRetestBars);
    Print("Impulse Bars: ", InpImpulseBars);
    Print("Lot Size: ", InpLotSize);
    Print("Magic Number: ", InpMagicNumber);
    Print("Stop Loss: ", InpStopLoss, " points");
    Print("Take Profit: ", InpTakeProfit, " points");
    
    Print("ProfitPulsePro EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up
    if(handleHTF != INVALID_HANDLE)
        IndicatorRelease(handleHTF);
    
    Print("ProfitPulsePro EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if trading is allowed at current time
    if(!IsTradingTime())
        return;
    
    // Check if new bar on trade timeframe
    if(!IsNewBar(InpTradeTF))
        return;
    
    // Get higher timeframe data
    if(!GetHigherTimeframeData())
        return;
    
    // Update market structure
    UpdateMarketStructure();
    
    // Update FVG boxes
    UpdateFVGBoxes();
    
    // Check for entry signals
    CheckEntrySignals();
}

//+------------------------------------------------------------------+
//| Get higher timeframe data                                        |
//+------------------------------------------------------------------+
bool GetHigherTimeframeData()
{
    int copied = 0;
    
    // Copy high prices
    copied = CopyHigh(Symbol(), InpStructureTF, 0, 100, hiHTF);
    if(copied <= 0) return false;
    
    // Copy low prices
    copied = CopyLow(Symbol(), InpStructureTF, 0, 100, loHTF);
    if(copied <= 0) return false;
    
    // Copy close prices
    copied = CopyClose(Symbol(), InpStructureTF, 0, 100, clHTF);
    if(copied <= 0) return false;
    
    // Copy time
    copied = CopyTime(Symbol(), InpStructureTF, 0, 100, timeHTF);
    if(copied <= 0) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Update market structure (BoS detection)                         |
//+------------------------------------------------------------------+
void UpdateMarketStructure()
{
    if(ArraySize(hiHTF) < InpImpulseBars * 2 + 1)
        return;
    
    // Find pivot high
    double ph = FindPivotHigh(hiHTF, InpImpulseBars);
    if(ph > 0 && ph != lastPH)
    {
        lastPH = ph;
        lastPHTime = timeHTF[InpImpulseBars];
    }
    
    // Find pivot low
    double pl = FindPivotLow(loHTF, InpImpulseBars);
    if(pl > 0 && pl != lastPL)
    {
        lastPL = pl;
        lastPLTime = timeHTF[InpImpulseBars];
    }
    
    // Check for BoS
    if(InpShowBoS && ArraySize(clHTF) > 0)
    {
        double currentClose = clHTF[0];
        
        // Bullish BoS
        if(lastPH > 0 && currentClose > lastPH)
        {
            Print("Bullish BoS detected at price: ", currentClose);
        }
        
        // Bearish BoS
        if(lastPL > 0 && currentClose < lastPL)
        {
            Print("Bearish BoS detected at price: ", currentClose);
        }
    }
}

//+------------------------------------------------------------------+
//| Find pivot high                                                  |
//+------------------------------------------------------------------+
double FindPivotHigh(double& priceArray[], int lookback)
{
    int arraySize = ArraySize(priceArray);
    if(arraySize < lookback * 2 + 1)
        return 0.0;
    
    int centerIndex = lookback;
    double centerValue = priceArray[centerIndex];
    
    // Check if center is highest
    for(int i = centerIndex - lookback; i <= centerIndex + lookback; i++)
    {
        if(i == centerIndex) continue;
        if(i < 0 || i >= arraySize) continue; // Bounds check
        if(priceArray[i] >= centerValue)
            return 0.0;
    }
    
    return centerValue;
}

//+------------------------------------------------------------------+
//| Find pivot low                                                   |
//+------------------------------------------------------------------+
double FindPivotLow(double& priceArray[], int lookback)
{
    int arraySize = ArraySize(priceArray);
    if(arraySize < lookback * 2 + 1)
        return 0.0;
    
    int centerIndex = lookback;
    double centerValue = priceArray[centerIndex];
    
    // Check if center is lowest
    for(int i = centerIndex - lookback; i <= centerIndex + lookback; i++)
    {
        if(i == centerIndex) continue;
        if(i < 0 || i >= arraySize) continue; // Bounds check
        if(priceArray[i] <= centerValue)
            return 0.0;
    }
    
    return centerValue;
}

//+------------------------------------------------------------------+
//| Update FVG boxes                                                 |
//+------------------------------------------------------------------+
void UpdateFVGBoxes()
{
    if(!InpShowFVG)
        return;
    
    // Get current timeframe data
    double high[], low[], close[];
    int dataSize = InpFVGLen + 2;
    ArrayResize(high, dataSize);
    ArrayResize(low, dataSize);
    ArrayResize(close, dataSize);
    
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    
    int copiedHigh = CopyHigh(Symbol(), InpTradeTF, 0, dataSize, high);
    int copiedLow = CopyLow(Symbol(), InpTradeTF, 0, dataSize, low);
    int copiedClose = CopyClose(Symbol(), InpTradeTF, 0, dataSize, close);
    
    if(copiedHigh <= InpFVGLen + 1 || copiedLow <= InpFVGLen + 1 || copiedClose <= InpFVGLen + 1)
        return;
    
    // Check for FVG pattern
    if(high[InpFVGLen] < low[InpFVGLen - 1])
    {
        // Bullish FVG
        AddFVGBox(low[InpFVGLen - 1], high[InpFVGLen]);
        Print("Bullish FVG detected: Top=", low[InpFVGLen - 1], " Bottom=", high[InpFVGLen]);
    }
    else if(low[InpFVGLen] > high[InpFVGLen - 1])
    {
        // Bearish FVG
        AddFVGBox(low[InpFVGLen], high[InpFVGLen - 1]);
        Print("Bearish FVG detected: Top=", low[InpFVGLen], " Bottom=", high[InpFVGLen - 1]);
    }
    
    // Age and remove old FVG boxes
    PruneFVGBoxes();
}

//+------------------------------------------------------------------+
//| Add FVG box                                                      |
//+------------------------------------------------------------------+
void AddFVGBox(double topPrice, double bottomPrice)
{
    // Find empty slot or expand array
    int index = -1;
    for(int i = 0; i < fvgBoxCount; i++)
    {
        if(!fvgBoxes[i].isValid)
        {
            index = i;
            break;
        }
    }
    
    if(index == -1)
    {
        index = fvgBoxCount;
        int currentSize = ArraySize(fvgBoxes);
        if(fvgBoxCount >= currentSize)
        {
            ArrayResize(fvgBoxes, currentSize + 50);
        }
        fvgBoxCount++;
    }
    
    // Add new FVG box
    fvgBoxes[index].startTime = TimeCurrent();
    fvgBoxes[index].topPrice = topPrice;
    fvgBoxes[index].bottomPrice = bottomPrice;
    fvgBoxes[index].barsAge = 0;
    fvgBoxes[index].isValid = true;
}

//+------------------------------------------------------------------+
//| Prune old FVG boxes                                             |
//+------------------------------------------------------------------+
void PruneFVGBoxes()
{
    for(int i = 0; i < fvgBoxCount; i++)
    {
        if(!fvgBoxes[i].isValid)
            continue;
        
        fvgBoxes[i].barsAge++;
        
        // Remove if too old
        if(fvgBoxes[i].barsAge > InpMaxRetestBars)
        {
            fvgBoxes[i].isValid = false;
        }
    }
}

//+------------------------------------------------------------------+
//| Check for entry signals                                          |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
    if(!InpShowFVG || fvgBoxCount == 0)
        return;
    
    double currentHigh = iHigh(Symbol(), InpTradeTF, 0);
    double currentLow = iLow(Symbol(), InpTradeTF, 0);
    double currentClose = iClose(Symbol(), InpTradeTF, 0);
    
    bool enterLong = false;
    bool enterShort = false;
    
    // Check FVG retests
    for(int i = 0; i < fvgBoxCount; i++)
    {
        if(!fvgBoxes[i].isValid)
            continue;
        
        double topPrice = fvgBoxes[i].topPrice;
        double bottomPrice = fvgBoxes[i].bottomPrice;
        
        // Bullish gap retest
        if(currentLow <= bottomPrice && currentClose > bottomPrice)
        {
            enterLong = true;
            Print("FVG Long signal detected at price: ", currentClose);
        }
        
        // Bearish gap retest
        if(currentHigh >= topPrice && currentClose < topPrice)
        {
            enterShort = true;
            Print("FVG Short signal detected at price: ", currentClose);
        }
    }
    
    // Execute trades
    if(enterLong && !HasOpenPosition(ORDER_TYPE_BUY))
    {
        OpenTrade(ORDER_TYPE_BUY);
    }
    
    if(enterShort && !HasOpenPosition(ORDER_TYPE_SELL))
    {
        OpenTrade(ORDER_TYPE_SELL);
    }
}

//+------------------------------------------------------------------+
//| Check if has open position                                       |
//+------------------------------------------------------------------+
bool HasOpenPosition(ENUM_ORDER_TYPE orderType)
{
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionGetTicket(i) <= 0)
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != Symbol())
            continue;
        
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
            continue;
        
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        if((orderType == ORDER_TYPE_BUY && posType == POSITION_TYPE_BUY) ||
           (orderType == ORDER_TYPE_SELL && posType == POSITION_TYPE_SELL))
        {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate lot size based on account balance and risk            |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopLossPoints)
{
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double accountFreeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
    
    // Use the lesser of balance and equity for safety
    double baseAmount = MathMin(accountBalance, accountEquity);
    
    // Risk management: Use a percentage of account
    double riskPercent = 0.02; // 2% risk per trade
    double riskAmount = baseAmount * riskPercent;
    
    // Calculate lot size based on stop loss
    double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
    double lotSize = 0.01; // Default minimum lot size
    
    if(stopLossPoints > 0 && tickValue > 0)
    {
        double riskPerLot = stopLossPoints * tickValue;
        if(riskPerLot > 0)
        {
            lotSize = riskAmount / riskPerLot;
        }
    }
    
    // Normalize lot size to symbol specifications
    double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    
    // Round to lot step
    lotSize = MathRound(lotSize / lotStep) * lotStep;
    
    // Ensure within limits
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    
    // Final safety check - ensure we have enough free margin
    double marginRequired = OrderCalcMargin(ORDER_TYPE_BUY, Symbol(), lotSize, 
                                           SymbolInfoDouble(Symbol(), SYMBOL_ASK));
    
    if(marginRequired > accountFreeMargin * 0.5) // Use only 50% of free margin
    {
        lotSize = minLot;
    }
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Get account information                                          |
//+------------------------------------------------------------------+
string GetAccountInfo()
{
    string info = "";
    info += "Account Number: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n";
    info += "Account Name: " + AccountInfoString(ACCOUNT_NAME) + "\n";
    info += "Account Server: " + AccountInfoString(ACCOUNT_SERVER) + "\n";
    info += "Account Currency: " + AccountInfoString(ACCOUNT_CURRENCY) + "\n";
    info += "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n";
    info += "Account Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n";
    info += "Account Free Margin: " + DoubleToString(AccountInfoDouble(ACCOUNT_FREEMARGIN), 2) + "\n";
    info += "Account Leverage: 1:" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\n";
    
    return info;
}

//+------------------------------------------------------------------+
//| Time and session management functions                           |
//+------------------------------------------------------------------+
bool IsNewBar(ENUM_TIMEFRAMES timeframe)
{
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(Symbol(), timeframe, 0);
    
    if(currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check if current time is within trading hours                   |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
    datetime currentTime = TimeCurrent();
    MqlDateTime dtStruct;
    TimeToStruct(currentTime, dtStruct);
    
    // Trading hours: 8:00 - 22:00 (can be adjusted)
    int startHour = 8;
    int endHour = 22;
    
    if(dtStruct.hour >= startHour && dtStruct.hour < endHour)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Get time string for logging                                     |
//+------------------------------------------------------------------+
string GetTimeString()
{
    datetime currentTime = TimeCurrent();
    return TimeToString(currentTime, TIME_DATE | TIME_SECONDS);
}
//+------------------------------------------------------------------+
//| Open trade                                                       |
//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE orderType)
{
    double price = 0.0;
    double sl = 0.0;
    double tp = 0.0;
    
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    
    if(orderType == ORDER_TYPE_BUY)
    {
        price = ask;
        sl = (InpStopLoss > 0) ? price - InpStopLoss * point : 0.0;
        tp = (InpTakeProfit > 0) ? price + InpTakeProfit * point : 0.0;
    }
    else if(orderType == ORDER_TYPE_SELL)
    {
        price = bid;
        sl = (InpStopLoss > 0) ? price + InpStopLoss * point : 0.0;
        tp = (InpTakeProfit > 0) ? price - InpTakeProfit * point : 0.0;
    }
    
    // Normalize prices
    int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
    price = NormalizeDouble(price, digits);
    sl = NormalizeDouble(sl, digits);
    tp = NormalizeDouble(tp, digits);
    
    // Calculate lot size based on risk management
    double lotSize = CalculateLotSize(InpStopLoss);
    
    // Use input lot size if risk calculation fails
    if(lotSize <= 0)
        lotSize = InpLotSize;
    
    // Verify trade is allowed
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
    {
        Print("Trading is not allowed by terminal");
        return;
    }
    
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
    {
        Print("Trading is not allowed by MQL");
        return;
    }
    
    // Check market status
    if(!SymbolInfoInteger(Symbol(), SYMBOL_TRADE_MODE))
    {
        Print("Trading is not allowed for symbol: ", Symbol());
        return;
    }
    
    // Open position
    bool result = false;
    string comment = "ProfitPulsePro " + EnumToString(orderType);
    
    if(orderType == ORDER_TYPE_BUY)
    {
        result = trade.Buy(lotSize, Symbol(), price, sl, tp, comment);
    }
    else if(orderType == ORDER_TYPE_SELL)
    {
        result = trade.Sell(lotSize, Symbol(), price, sl, tp, comment);
    }
    
    if(result)
    {
        string tradeInfo = "Trade opened successfully: " + EnumToString(orderType) + 
                          " Lot: " + DoubleToString(lotSize, 2) + " Price: " + DoubleToString(price, _Digits) + 
                          " SL: " + DoubleToString(sl, _Digits) + " TP: " + DoubleToString(tp, _Digits);
        Print(tradeInfo);
    }
    else
    {
        Print("Failed to open trade: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
        Print("Last error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+