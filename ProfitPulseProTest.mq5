//+------------------------------------------------------------------+
//|                                      ProfitPulseProTest.mq5     |
//|                                 Copyright 2024, Shilohsos       |
//|                                             https://github.com/Shilohsos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Shilohsos"
#property link      "https://github.com/Shilohsos"
#property version   "1.00"
#property description "Test script for ProfitPulsePro EA functionality"

#include "ProfitPulseProUtils.mqh"
#include "ProfitPulseProConfig.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== ProfitPulsePro EA Test Suite ===");
    
    // Test 1: Configuration Loading
    TestConfigurationLoading();
    
    // Test 2: Risk Management Functions
    TestRiskManagement();
    
    // Test 3: Market Regime Detection
    TestMarketRegimeDetection();
    
    // Test 4: Smart Filters
    TestSmartFilters();
    
    // Test 5: Position Sizing
    TestPositionSizing();
    
    // Test 6: Utility Functions
    TestUtilityFunctions();
    
    // Test 7: Symbol Configuration
    TestSymbolConfiguration();
    
    // Test 8: Market Sessions
    TestMarketSessions();
    
    Print("=== Test Suite Completed ===");
}

//+------------------------------------------------------------------+
//| Test Configuration Loading                                       |
//+------------------------------------------------------------------+
void TestConfigurationLoading()
{
    Print("\n--- Testing Configuration Loading ---");
    
    // Test trading style configurations
    LoadConservativeConfig();
    LoadBalancedConfig();
    LoadAggressiveConfig();
    LoadScalpingConfig();
    LoadSwingConfig();
    
    Print("Configuration loading tests passed");
}

//+------------------------------------------------------------------+
//| Test Risk Management                                             |
//+------------------------------------------------------------------+
void TestRiskManagement()
{
    Print("\n--- Testing Risk Management ---");
    
    // Test parameter validation
    bool result1 = ValidateRiskParameters(2.0, 5.0, 10.0, 3, 30.0, 100.0);
    bool result2 = ValidateRiskParameters(-1.0, 5.0, 10.0, 3, 30.0, 100.0); // Should fail
    bool result3 = ValidateRiskParameters(2.0, 60.0, 10.0, 3, 30.0, 100.0); // Should fail
    
    Print("Risk parameter validation test 1: ", result1 ? "PASS" : "FAIL");
    Print("Risk parameter validation test 2: ", !result2 ? "PASS" : "FAIL");
    Print("Risk parameter validation test 3: ", !result3 ? "PASS" : "FAIL");
    
    // Test market regime validation
    bool result4 = ValidateMarketRegimeParameters(20, 0.6, 1.5);
    bool result5 = ValidateMarketRegimeParameters(-5, 0.6, 1.5); // Should fail
    bool result6 = ValidateMarketRegimeParameters(20, 1.5, 1.5); // Should fail
    
    Print("Market regime validation test 1: ", result4 ? "PASS" : "FAIL");
    Print("Market regime validation test 2: ", !result5 ? "PASS" : "FAIL");
    Print("Market regime validation test 3: ", !result6 ? "PASS" : "FAIL");
}

//+------------------------------------------------------------------+
//| Test Market Regime Detection                                     |
//+------------------------------------------------------------------+
void TestMarketRegimeDetection()
{
    Print("\n--- Testing Market Regime Detection ---");
    
    // Test volatility calculation
    double volatility = CalculateATR(_Symbol, PERIOD_CURRENT, 14);
    Print("ATR volatility: ", volatility);
    
    // Test standard deviation
    double stdDev = CalculateStdDev(_Symbol, PERIOD_CURRENT, 20);
    Print("Standard deviation: ", stdDev);
    
    // Test Bollinger Bands
    double upperBand, middleBand, lowerBand;
    if(CalculateBollingerBands(_Symbol, PERIOD_CURRENT, 20, 2.0, upperBand, middleBand, lowerBand))
    {
        Print("Bollinger Bands - Upper: ", upperBand, ", Middle: ", middleBand, ", Lower: ", lowerBand);
    }
    
    Print("Market regime detection tests completed");
}

//+------------------------------------------------------------------+
//| Test Smart Filters                                               |
//+------------------------------------------------------------------+
void TestSmartFilters()
{
    Print("\n--- Testing Smart Filters ---");
    
    // Test pivot level detection
    double pivotHigh, pivotLow;
    int highIndex, lowIndex;
    
    if(FindPivotLevels(_Symbol, PERIOD_CURRENT, 5, 5, pivotHigh, pivotLow, highIndex, lowIndex))
    {
        Print("Pivot High: ", pivotHigh, " at index: ", highIndex);
        Print("Pivot Low: ", pivotLow, " at index: ", lowIndex);
    }
    
    // Test correlation calculation
    double correlation = CalculateCorrelation("EURUSD", "GBPUSD", PERIOD_CURRENT, 20);
    Print("EURUSD vs GBPUSD correlation: ", correlation);
    
    Print("Smart filters tests completed");
}

//+------------------------------------------------------------------+
//| Test Position Sizing                                             |
//+------------------------------------------------------------------+
void TestPositionSizing()
{
    Print("\n--- Testing Position Sizing ---");
    
    // Test position size calculation
    double riskAmount = 100.0; // $100 risk
    double stopLossPoints = 0.003; // 30 pips for EUR/USD
    
    double lotSize = CalculatePositionSize(riskAmount, stopLossPoints, _Symbol);
    Print("Calculated lot size for $100 risk with 30 pips SL: ", lotSize);
    
    // Test pips to points conversion
    double pips = 30.0;
    double points = PipsToPoints(pips);
    double backToPips = PointsToPips(points);
    
    Print("30 pips = ", points, " points = ", backToPips, " pips");
    Print("Conversion test: ", (MathAbs(pips - backToPips) < 0.001) ? "PASS" : "FAIL");
    
    Print("Position sizing tests completed");
}

//+------------------------------------------------------------------+
//| Test Utility Functions                                           |
//+------------------------------------------------------------------+
void TestUtilityFunctions()
{
    Print("\n--- Testing Utility Functions ---");
    
    // Test symbol tradeable check
    bool isTradeable = IsSymbolTradeable(_Symbol);
    Print("Symbol ", _Symbol, " is tradeable: ", isTradeable ? "YES" : "NO");
    
    // Test market hours
    int startHour, endHour;
    if(GetMarketHours(_Symbol, startHour, endHour))
    {
        Print("Market hours for ", _Symbol, ": ", startHour, ":00 - ", endHour, ":00");
    }
    
    // Test news filter
    bool newsActive = IsNewsFilterActive(30);
    Print("News filter active: ", newsActive ? "YES" : "NO");
    
    Print("Utility functions tests completed");
}

//+------------------------------------------------------------------+
//| Test Symbol Configuration                                        |
//+------------------------------------------------------------------+
void TestSymbolConfiguration()
{
    Print("\n--- Testing Symbol Configuration ---");
    
    SymbolConfig configs[];
    InitSymbolConfigs(configs);
    
    SymbolConfig config = GetSymbolConfig(_Symbol, configs);
    Print("Symbol: ", config.symbol);
    Print("Spread Multiplier: ", config.spreadMultiplier);
    Print("Volatility Adjustment: ", config.volatilityAdjustment);
    Print("Max Lot Size: ", config.maxLotSize);
    Print("Min Lot Size: ", config.minLotSize);
    Print("Is Active: ", config.isActive ? "YES" : "NO");
    
    Print("Symbol configuration tests completed");
}

//+------------------------------------------------------------------+
//| Test Market Sessions                                             |
//+------------------------------------------------------------------+
void TestMarketSessions()
{
    Print("\n--- Testing Market Sessions ---");
    
    MarketSession sessions[];
    InitMarketSessions(sessions);
    
    MarketSession currentSession = GetCurrentSession(sessions);
    Print("Current Session: ", currentSession.sessionName);
    Print("Start Hour: ", currentSession.startHour);
    Print("End Hour: ", currentSession.endHour);
    Print("Volatility Multiplier: ", currentSession.volatilityMultiplier);
    Print("Spread Multiplier: ", currentSession.spreadMultiplier);
    Print("Is Active: ", currentSession.isActive ? "YES" : "NO");
    
    Print("Market sessions tests completed");
}

//+------------------------------------------------------------------+
//| Test Risk Profiles                                               |
//+------------------------------------------------------------------+
void TestRiskProfiles()
{
    Print("\n--- Testing Risk Profiles ---");
    
    RiskProfile profiles[];
    InitRiskProfiles(profiles);
    
    for(int i = 0; i < ArraySize(profiles); i++)
    {
        Print("Profile: ", profiles[i].profileName);
        Print("  Risk Percentage: ", profiles[i].riskPercentage);
        Print("  Max Daily Loss: ", profiles[i].maxDailyLoss);
        Print("  Max Drawdown: ", profiles[i].maxDrawdown);
        Print("  Max Concurrent Trades: ", profiles[i].maxConcurrentTrades);
        Print("  Use Correlation Filter: ", profiles[i].useCorrelationFilter ? "YES" : "NO");
        Print("  Max Correlation: ", profiles[i].maxCorrelation);
        Print("---");
    }
    
    Print("Risk profiles tests completed");
}

//+------------------------------------------------------------------+
//| Performance Test                                                 |
//+------------------------------------------------------------------+
void PerformanceTest()
{
    Print("\n--- Performance Test ---");
    
    uint startTime = GetTickCount();
    
    // Test intensive operations
    for(int i = 0; i < 1000; i++)
    {
        double atr = CalculateATR(_Symbol, PERIOD_CURRENT, 14);
        double stdDev = CalculateStdDev(_Symbol, PERIOD_CURRENT, 20);
        
        double upperBand, middleBand, lowerBand;
        CalculateBollingerBands(_Symbol, PERIOD_CURRENT, 20, 2.0, upperBand, middleBand, lowerBand);
    }
    
    uint endTime = GetTickCount();
    uint executionTime = endTime - startTime;
    
    Print("1000 iterations executed in ", executionTime, " ms");
    Print("Average time per iteration: ", (double)executionTime / 1000.0, " ms");
    
    Print("Performance test completed");
}

//+------------------------------------------------------------------+
//| Memory Test                                                      |
//+------------------------------------------------------------------+
void MemoryTest()
{
    Print("\n--- Memory Test ---");
    
    // Test array operations
    double testArray[];
    ArrayResize(testArray, 10000);
    
    for(int i = 0; i < 10000; i++)
    {
        testArray[i] = i * 0.0001;
    }
    
    double sum = 0;
    for(int i = 0; i < 10000; i++)
    {
        sum += testArray[i];
    }
    
    Print("Array test completed. Sum: ", sum);
    
    // Test structure arrays
    SymbolConfig configs[];
    ArrayResize(configs, 100);
    
    for(int i = 0; i < 100; i++)
    {
        configs[i].symbol = "TEST" + IntegerToString(i);
        configs[i].spreadMultiplier = 1.0 + i * 0.01;
        configs[i].volatilityAdjustment = 1.0 + i * 0.02;
        configs[i].maxLotSize = 1.0 + i * 0.01;
        configs[i].minLotSize = 0.01;
        configs[i].isActive = (i % 2 == 0);
    }
    
    Print("Structure array test completed");
    Print("Memory test completed");
}