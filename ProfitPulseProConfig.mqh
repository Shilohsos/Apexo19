//+------------------------------------------------------------------+
//|                                       ProfitPulseProConfig.mqh |
//|                                 Copyright 2024, Shilohsos       |
//|                                             https://github.com/Shilohsos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Shilohsos"
#property link      "https://github.com/Shilohsos"

//+------------------------------------------------------------------+
//| Configuration Presets                                            |
//+------------------------------------------------------------------+

// Preset configurations for different trading styles
enum ENUM_TRADING_STYLE
{
    STYLE_CONSERVATIVE,
    STYLE_BALANCED,
    STYLE_AGGRESSIVE,
    STYLE_SCALPING,
    STYLE_SWING,
    STYLE_CUSTOM
};

//+------------------------------------------------------------------+
//| Conservative Trading Configuration                               |
//+------------------------------------------------------------------+
void LoadConservativeConfig()
{
    // Risk Management
    // RiskPercentage = 1.0;
    // MaxLotSize = 0.5;
    // MaxDailyLoss = 3.0;
    // MaxDrawdown = 5.0;
    // MaxConcurrentTrades = 1;
    
    // Market Regime
    // RegimePeriod = 50;
    // TrendThreshold = 0.8;
    // VolatilityMultiplier = 1.2;
    
    // Smart Filters
    // RSI_Oversold = 25;
    // RSI_Overbought = 75;
    // MA_Period = 100;
    // VolumeMultiplier = 1.5;
    
    // Take Profit
    // TP_Level1 = 30;
    // TP_Level2 = 60;
    // TP_Level3 = 90;
    // TrailingStart = 25;
    // TrailingStep = 5;
    
    Print("Conservative trading configuration loaded");
}

//+------------------------------------------------------------------+
//| Balanced Trading Configuration                                   |
//+------------------------------------------------------------------+
void LoadBalancedConfig()
{
    // Risk Management
    // RiskPercentage = 2.0;
    // MaxLotSize = 1.0;
    // MaxDailyLoss = 5.0;
    // MaxDrawdown = 8.0;
    // MaxConcurrentTrades = 2;
    
    // Market Regime
    // RegimePeriod = 30;
    // TrendThreshold = 0.6;
    // VolatilityMultiplier = 1.5;
    
    // Smart Filters
    // RSI_Oversold = 30;
    // RSI_Overbought = 70;
    // MA_Period = 50;
    // VolumeMultiplier = 1.2;
    
    // Take Profit
    // TP_Level1 = 50;
    // TP_Level2 = 100;
    // TP_Level3 = 150;
    // TrailingStart = 30;
    // TrailingStep = 10;
    
    Print("Balanced trading configuration loaded");
}

//+------------------------------------------------------------------+
//| Aggressive Trading Configuration                                 |
//+------------------------------------------------------------------+
void LoadAggressiveConfig()
{
    // Risk Management
    // RiskPercentage = 3.0;
    // MaxLotSize = 2.0;
    // MaxDailyLoss = 8.0;
    // MaxDrawdown = 12.0;
    // MaxConcurrentTrades = 5;
    
    // Market Regime
    // RegimePeriod = 20;
    // TrendThreshold = 0.4;
    // VolatilityMultiplier = 2.0;
    
    // Smart Filters
    // RSI_Oversold = 35;
    // RSI_Overbought = 65;
    // MA_Period = 20;
    // VolumeMultiplier = 1.0;
    
    // Take Profit
    // TP_Level1 = 70;
    // TP_Level2 = 140;
    // TP_Level3 = 210;
    // TrailingStart = 40;
    // TrailingStep = 15;
    
    Print("Aggressive trading configuration loaded");
}

//+------------------------------------------------------------------+
//| Scalping Trading Configuration                                   |
//+------------------------------------------------------------------+
void LoadScalpingConfig()
{
    // Risk Management
    // RiskPercentage = 1.5;
    // MaxLotSize = 0.5;
    // MaxDailyLoss = 4.0;
    // MaxDrawdown = 6.0;
    // MaxConcurrentTrades = 3;
    
    // Market Regime
    // RegimePeriod = 10;
    // TrendThreshold = 0.3;
    // VolatilityMultiplier = 1.8;
    
    // Smart Filters
    // RSI_Oversold = 40;
    // RSI_Overbought = 60;
    // MA_Period = 10;
    // VolumeMultiplier = 1.3;
    
    // Take Profit
    // TP_Level1 = 10;
    // TP_Level2 = 20;
    // TP_Level3 = 30;
    // TrailingStart = 8;
    // TrailingStep = 3;
    
    Print("Scalping trading configuration loaded");
}

//+------------------------------------------------------------------+
//| Swing Trading Configuration                                      |
//+------------------------------------------------------------------+
void LoadSwingConfig()
{
    // Risk Management
    // RiskPercentage = 2.5;
    // MaxLotSize = 1.5;
    // MaxDailyLoss = 6.0;
    // MaxDrawdown = 10.0;
    // MaxConcurrentTrades = 2;
    
    // Market Regime
    // RegimePeriod = 100;
    // TrendThreshold = 0.7;
    // VolatilityMultiplier = 1.3;
    
    // Smart Filters
    // RSI_Oversold = 20;
    // RSI_Overbought = 80;
    // MA_Period = 200;
    // VolumeMultiplier = 1.4;
    
    // Take Profit
    // TP_Level1 = 100;
    // TP_Level2 = 200;
    // TP_Level3 = 300;
    // TrailingStart = 80;
    // TrailingStep = 20;
    
    Print("Swing trading configuration loaded");
}

//+------------------------------------------------------------------+
//| Symbol-specific configurations                                   |
//+------------------------------------------------------------------+

struct SymbolConfig
{
    string symbol;
    double spreadMultiplier;
    double volatilityAdjustment;
    int optimalTimeframe;
    double maxLotSize;
    double minLotSize;
    bool isActive;
};

//+------------------------------------------------------------------+
//| Initialize Symbol Configurations                                 |
//+------------------------------------------------------------------+
void InitSymbolConfigs(SymbolConfig &configs[])
{
    ArrayResize(configs, 8);
    
    // EURUSD
    configs[0].symbol = "EURUSD";
    configs[0].spreadMultiplier = 1.0;
    configs[0].volatilityAdjustment = 1.0;
    configs[0].optimalTimeframe = PERIOD_M15;
    configs[0].maxLotSize = 2.0;
    configs[0].minLotSize = 0.01;
    configs[0].isActive = true;
    
    // GBPUSD
    configs[1].symbol = "GBPUSD";
    configs[1].spreadMultiplier = 1.2;
    configs[1].volatilityAdjustment = 1.3;
    configs[1].optimalTimeframe = PERIOD_M15;
    configs[1].maxLotSize = 1.5;
    configs[1].minLotSize = 0.01;
    configs[1].isActive = true;
    
    // USDJPY
    configs[2].symbol = "USDJPY";
    configs[2].spreadMultiplier = 1.1;
    configs[2].volatilityAdjustment = 1.1;
    configs[2].optimalTimeframe = PERIOD_M15;
    configs[2].maxLotSize = 2.0;
    configs[2].minLotSize = 0.01;
    configs[2].isActive = true;
    
    // USDCHF
    configs[3].symbol = "USDCHF";
    configs[3].spreadMultiplier = 1.3;
    configs[3].volatilityAdjustment = 1.2;
    configs[3].optimalTimeframe = PERIOD_M15;
    configs[3].maxLotSize = 1.5;
    configs[3].minLotSize = 0.01;
    configs[3].isActive = true;
    
    // AUDUSD
    configs[4].symbol = "AUDUSD";
    configs[4].spreadMultiplier = 1.4;
    configs[4].volatilityAdjustment = 1.4;
    configs[4].optimalTimeframe = PERIOD_M15;
    configs[4].maxLotSize = 1.0;
    configs[4].minLotSize = 0.01;
    configs[4].isActive = true;
    
    // USDCAD
    configs[5].symbol = "USDCAD";
    configs[5].spreadMultiplier = 1.2;
    configs[5].volatilityAdjustment = 1.3;
    configs[5].optimalTimeframe = PERIOD_M15;
    configs[5].maxLotSize = 1.5;
    configs[5].minLotSize = 0.01;
    configs[5].isActive = true;
    
    // NZDUSD
    configs[6].symbol = "NZDUSD";
    configs[6].spreadMultiplier = 1.5;
    configs[6].volatilityAdjustment = 1.5;
    configs[6].optimalTimeframe = PERIOD_M15;
    configs[6].maxLotSize = 1.0;
    configs[6].minLotSize = 0.01;
    configs[6].isActive = true;
    
    // EURJPY
    configs[7].symbol = "EURJPY";
    configs[7].spreadMultiplier = 1.3;
    configs[7].volatilityAdjustment = 1.6;
    configs[7].optimalTimeframe = PERIOD_M15;
    configs[7].maxLotSize = 1.0;
    configs[7].minLotSize = 0.01;
    configs[7].isActive = true;
}

//+------------------------------------------------------------------+
//| Get Symbol Configuration                                         |
//+------------------------------------------------------------------+
SymbolConfig GetSymbolConfig(string symbol, SymbolConfig &configs[])
{
    SymbolConfig defaultConfig;
    defaultConfig.symbol = symbol;
    defaultConfig.spreadMultiplier = 1.0;
    defaultConfig.volatilityAdjustment = 1.0;
    defaultConfig.optimalTimeframe = PERIOD_M15;
    defaultConfig.maxLotSize = 1.0;
    defaultConfig.minLotSize = 0.01;
    defaultConfig.isActive = true;
    
    for(int i = 0; i < ArraySize(configs); i++)
    {
        if(configs[i].symbol == symbol)
        {
            return configs[i];
        }
    }
    
    return defaultConfig;
}

//+------------------------------------------------------------------+
//| Market Session Configuration                                     |
//+------------------------------------------------------------------+
struct MarketSession
{
    string sessionName;
    int startHour;
    int endHour;
    bool isActive;
    double volatilityMultiplier;
    double spreadMultiplier;
};

//+------------------------------------------------------------------+
//| Initialize Market Sessions                                       |
//+------------------------------------------------------------------+
void InitMarketSessions(MarketSession &sessions[])
{
    ArrayResize(sessions, 4);
    
    // Asian Session
    sessions[0].sessionName = "Asian";
    sessions[0].startHour = 22;  // GMT
    sessions[0].endHour = 8;     // GMT
    sessions[0].isActive = true;
    sessions[0].volatilityMultiplier = 0.8;
    sessions[0].spreadMultiplier = 1.2;
    
    // European Session
    sessions[1].sessionName = "European";
    sessions[1].startHour = 7;   // GMT
    sessions[1].endHour = 16;    // GMT
    sessions[1].isActive = true;
    sessions[1].volatilityMultiplier = 1.2;
    sessions[1].spreadMultiplier = 1.0;
    
    // US Session
    sessions[2].sessionName = "US";
    sessions[2].startHour = 13;  // GMT
    sessions[2].endHour = 22;    // GMT
    sessions[2].isActive = true;
    sessions[2].volatilityMultiplier = 1.3;
    sessions[2].spreadMultiplier = 1.0;
    
    // Overlap Session (EU-US)
    sessions[3].sessionName = "Overlap";
    sessions[3].startHour = 13;  // GMT
    sessions[3].endHour = 16;    // GMT
    sessions[3].isActive = true;
    sessions[3].volatilityMultiplier = 1.5;
    sessions[3].spreadMultiplier = 0.9;
}

//+------------------------------------------------------------------+
//| Get Current Market Session                                       |
//+------------------------------------------------------------------+
MarketSession GetCurrentSession(MarketSession &sessions[])
{
    MqlDateTime currentTime;
    TimeToStruct(TimeCurrent(), currentTime);
    
    MarketSession defaultSession;
    defaultSession.sessionName = "Default";
    defaultSession.startHour = 0;
    defaultSession.endHour = 24;
    defaultSession.isActive = true;
    defaultSession.volatilityMultiplier = 1.0;
    defaultSession.spreadMultiplier = 1.0;
    
    for(int i = 0; i < ArraySize(sessions); i++)
    {
        if(sessions[i].startHour <= sessions[i].endHour)
        {
            // Normal session (doesn't cross midnight)
            if(currentTime.hour >= sessions[i].startHour && currentTime.hour < sessions[i].endHour)
            {
                return sessions[i];
            }
        }
        else
        {
            // Session crosses midnight
            if(currentTime.hour >= sessions[i].startHour || currentTime.hour < sessions[i].endHour)
            {
                return sessions[i];
            }
        }
    }
    
    return defaultSession;
}

//+------------------------------------------------------------------+
//| Risk Profile Configuration                                       |
//+------------------------------------------------------------------+
struct RiskProfile
{
    string profileName;
    double riskPercentage;
    double maxDailyLoss;
    double maxDrawdown;
    int maxConcurrentTrades;
    double stopLossMultiplier;
    double takeProfitMultiplier;
    bool useCorrelationFilter;
    double maxCorrelation;
};

//+------------------------------------------------------------------+
//| Initialize Risk Profiles                                         |
//+------------------------------------------------------------------+
void InitRiskProfiles(RiskProfile &profiles[])
{
    ArrayResize(profiles, 5);
    
    // Conservative
    profiles[0].profileName = "Conservative";
    profiles[0].riskPercentage = 1.0;
    profiles[0].maxDailyLoss = 3.0;
    profiles[0].maxDrawdown = 5.0;
    profiles[0].maxConcurrentTrades = 1;
    profiles[0].stopLossMultiplier = 1.0;
    profiles[0].takeProfitMultiplier = 1.0;
    profiles[0].useCorrelationFilter = true;
    profiles[0].maxCorrelation = 0.7;
    
    // Moderate
    profiles[1].profileName = "Moderate";
    profiles[1].riskPercentage = 2.0;
    profiles[1].maxDailyLoss = 5.0;
    profiles[1].maxDrawdown = 8.0;
    profiles[1].maxConcurrentTrades = 2;
    profiles[1].stopLossMultiplier = 1.0;
    profiles[1].takeProfitMultiplier = 1.0;
    profiles[1].useCorrelationFilter = true;
    profiles[1].maxCorrelation = 0.8;
    
    // Balanced
    profiles[2].profileName = "Balanced";
    profiles[2].riskPercentage = 2.5;
    profiles[2].maxDailyLoss = 6.0;
    profiles[2].maxDrawdown = 10.0;
    profiles[2].maxConcurrentTrades = 3;
    profiles[2].stopLossMultiplier = 1.0;
    profiles[2].takeProfitMultiplier = 1.0;
    profiles[2].useCorrelationFilter = false;
    profiles[2].maxCorrelation = 0.9;
    
    // Aggressive
    profiles[3].profileName = "Aggressive";
    profiles[3].riskPercentage = 3.0;
    profiles[3].maxDailyLoss = 8.0;
    profiles[3].maxDrawdown = 12.0;
    profiles[3].maxConcurrentTrades = 5;
    profiles[3].stopLossMultiplier = 0.8;
    profiles[3].takeProfitMultiplier = 1.2;
    profiles[3].useCorrelationFilter = false;
    profiles[3].maxCorrelation = 1.0;
    
    // Maximum
    profiles[4].profileName = "Maximum";
    profiles[4].riskPercentage = 5.0;
    profiles[4].maxDailyLoss = 15.0;
    profiles[4].maxDrawdown = 20.0;
    profiles[4].maxConcurrentTrades = 10;
    profiles[4].stopLossMultiplier = 0.7;
    profiles[4].takeProfitMultiplier = 1.5;
    profiles[4].useCorrelationFilter = false;
    profiles[4].maxCorrelation = 1.0;
}

//+------------------------------------------------------------------+
//| Validation Functions                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Validate Risk Parameters                                         |
//+------------------------------------------------------------------+
bool ValidateRiskParameters(double riskPercent, double maxDailyLoss, double maxDrawdown, 
                           int maxTrades, double stopLoss, double takeProfit)
{
    if(riskPercent <= 0 || riskPercent > 10)
    {
        Print("Invalid risk percentage: ", riskPercent, "%. Must be between 0 and 10.");
        return false;
    }
    
    if(maxDailyLoss <= 0 || maxDailyLoss > 50)
    {
        Print("Invalid max daily loss: ", maxDailyLoss, "%. Must be between 0 and 50.");
        return false;
    }
    
    if(maxDrawdown <= 0 || maxDrawdown > 50)
    {
        Print("Invalid max drawdown: ", maxDrawdown, "%. Must be between 0 and 50.");
        return false;
    }
    
    if(maxTrades <= 0 || maxTrades > 20)
    {
        Print("Invalid max concurrent trades: ", maxTrades, ". Must be between 1 and 20.");
        return false;
    }
    
    if(stopLoss <= 0 || stopLoss > 1000)
    {
        Print("Invalid stop loss: ", stopLoss, " pips. Must be between 0 and 1000.");
        return false;
    }
    
    if(takeProfit <= 0 || takeProfit > 2000)
    {
        Print("Invalid take profit: ", takeProfit, " pips. Must be between 0 and 2000.");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate Market Regime Parameters                                |
//+------------------------------------------------------------------+
bool ValidateMarketRegimeParameters(int period, double threshold, double volatilityMult)
{
    if(period <= 0 || period > 200)
    {
        Print("Invalid regime period: ", period, ". Must be between 1 and 200.");
        return false;
    }
    
    if(threshold < 0 || threshold > 1)
    {
        Print("Invalid trend threshold: ", threshold, ". Must be between 0 and 1.");
        return false;
    }
    
    if(volatilityMult <= 0 || volatilityMult > 10)
    {
        Print("Invalid volatility multiplier: ", volatilityMult, ". Must be between 0 and 10.");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Log Configuration                                                |
//+------------------------------------------------------------------+
void LogConfiguration(string configName)
{
    Print("=== Configuration Loaded: ", configName, " ===");
    Print("Timestamp: ", TimeToString(TimeCurrent()));
    Print("Symbol: ", _Symbol);
    Print("Timeframe: ", EnumToString(_Period));
    Print("==========================================");
}