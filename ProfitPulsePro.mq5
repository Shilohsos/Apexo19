//+------------------------------------------------------------------+
//|                                                ProfitPulsePro.mq5 |
//|                                  Copyright 2025, Shilohsos Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Shilohsos Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;           // Lot size
input int StopLoss = 100;              // Stop loss in points
input int TakeProfit = 200;            // Take profit in points
input int MagicNumber = 12345;         // Magic number
input bool UseTimeFilter = true;       // Use time filter
input int StartHour = 8;               // Start trading hour
input int EndHour = 18;                // End trading hour

//--- Global variables
datetime lastBarTime = 0;
MqlDateTime currentTime;
MqlDateTime sessionStart;
MqlDateTime sessionEnd;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Initialize datetime structures
    ZeroMemory(currentTime);
    ZeroMemory(sessionStart);
    ZeroMemory(sessionEnd);
    
    //--- Set up session times
    sessionStart.hour = StartHour;
    sessionStart.min = 0;
    sessionStart.sec = 0;
    
    sessionEnd.hour = EndHour;
    sessionEnd.min = 0;
    sessionEnd.sec = 0;
    
    Print("ProfitPulsePro EA initialized successfully");
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
    //--- Check if new bar formed
    if(!IsNewBar())
        return;
    
    //--- Update current time structure
    datetime currentTimestamp = TimeCurrent();
    if(!TimeToStruct(currentTimestamp, currentTime))
    {
        Print("Error: Failed to convert time to struct");
        return;
    }
    
    //--- Check time filter
    if(UseTimeFilter && !IsWithinTradingHours())
        return;
    
    //--- Check for trading signals
    CheckTradingSignals();
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
//| Check if current time is within trading hours                    |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
    //--- Get current time components
    int currentHour = currentTime.hour;
    int currentMinute = currentTime.min;
    
    //--- Check if within trading session
    if(currentHour >= StartHour && currentHour < EndHour)
        return true;
    
    //--- Special case for end hour
    if(currentHour == EndHour && currentMinute == 0)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for trading signals                                        |
//+------------------------------------------------------------------+
void CheckTradingSignals()
{
    //--- Get current prices
    double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    //--- Simple moving average signal
    double ma_fast = iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
    double ma_slow = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    //--- Check for buy signal
    if(ma_fast > ma_slow && currentBid > ma_fast)
    {
        if(CountPositions(ORDER_TYPE_BUY) == 0)
        {
            OpenPosition(ORDER_TYPE_BUY, currentAsk);
        }
    }
    
    //--- Check for sell signal
    if(ma_fast < ma_slow && currentBid < ma_fast)
    {
        if(CountPositions(ORDER_TYPE_SELL) == 0)
        {
            OpenPosition(ORDER_TYPE_SELL, currentBid);
        }
    }
}

//+------------------------------------------------------------------+
//| Open position function                                           |
//+------------------------------------------------------------------+
void OpenPosition(ENUM_ORDER_TYPE orderType, double price)
{
    MqlTradeRequest request;
    MqlTradeResult result;
    
    //--- Initialize structures
    ZeroMemory(request);
    ZeroMemory(result);
    
    //--- Set up trade request
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = LotSize;
    request.type = orderType;
    request.price = price;
    request.magic = MagicNumber;
    request.deviation = 3;
    
    //--- Calculate stop loss and take profit
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    
    if(orderType == ORDER_TYPE_BUY)
    {
        request.sl = NormalizeDouble(price - StopLoss * point, digits);
        request.tp = NormalizeDouble(price + TakeProfit * point, digits);
    }
    else
    {
        request.sl = NormalizeDouble(price + StopLoss * point, digits);
        request.tp = NormalizeDouble(price - TakeProfit * point, digits);
    }
    
    //--- Send order
    if(OrderSend(request, result))
    {
        Print("Order opened successfully. Ticket: ", result.order);
        LogTradeDetails(result, orderType);
    }
    else
    {
        Print("Order failed. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Count positions of specific type                                 |
//+------------------------------------------------------------------+
int CountPositions(ENUM_ORDER_TYPE orderType)
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByIndex(i))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
               PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
                ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                if((orderType == ORDER_TYPE_BUY && posType == POSITION_TYPE_BUY) ||
                   (orderType == ORDER_TYPE_SELL && posType == POSITION_TYPE_SELL))
                {
                    count++;
                }
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Log trade details with proper datetime formatting               |
//+------------------------------------------------------------------+
void LogTradeDetails(MqlTradeResult &result, ENUM_ORDER_TYPE orderType)
{
    MqlDateTime tradeTime;
    datetime timestamp = TimeCurrent();
    
    //--- Convert timestamp to struct
    if(TimeToStruct(timestamp, tradeTime))
    {
        Print("Trade Details:");
        Print("- Time: ", StringFormat("%04d.%02d.%02d %02d:%02d:%02d", 
              tradeTime.year, tradeTime.mon, tradeTime.day,
              tradeTime.hour, tradeTime.min, tradeTime.sec));
        Print("- Type: ", orderType == ORDER_TYPE_BUY ? "BUY" : "SELL");
        Print("- Volume: ", LotSize);
        Print("- Price: ", result.price);
        Print("- Ticket: ", result.order);
    }
    else
    {
        Print("Error: Failed to format trade time");
    }
}

//+------------------------------------------------------------------+
//| Get formatted time string                                        |
//+------------------------------------------------------------------+
string GetFormattedTime(datetime timestamp)
{
    MqlDateTime dt;
    if(TimeToStruct(timestamp, dt))
    {
        return StringFormat("%04d.%02d.%02d %02d:%02d:%02d", 
                          dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
    }
    return "Invalid Time";
}

//+------------------------------------------------------------------+
//| Check if market is open                                          |
//+------------------------------------------------------------------+
bool IsMarketOpen()
{
    //--- Get current time
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    
    if(!TimeToStruct(currentTime, dt))
        return false;
    
    //--- Check if it's weekend
    if(dt.day_of_week == 0 || dt.day_of_week == 6)
        return false;
    
    //--- Market is open on weekdays
    return true;
}

//+------------------------------------------------------------------+
//| Get time until market close                                      |
//+------------------------------------------------------------------+
int GetTimeUntilMarketClose()
{
    MqlDateTime dt;
    datetime currentTime = TimeCurrent();
    
    if(!TimeToStruct(currentTime, dt))
        return -1;
    
    //--- Calculate seconds until end of trading day
    int currentSeconds = dt.hour * 3600 + dt.min * 60 + dt.sec;
    int marketCloseSeconds = EndHour * 3600;
    
    if(currentSeconds < marketCloseSeconds)
        return marketCloseSeconds - currentSeconds;
    
    return 0;
}