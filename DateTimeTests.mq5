//+------------------------------------------------------------------+
//|                                          DateTimeTests.mq5 |
//|                                  Copyright 2025, Shilohsos Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Shilohsos Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

//--- Input parameters for testing
input bool TestBasicDateTime = true;        // Test basic datetime operations
input bool TestTimeFilter = true;          // Test time filter functionality
input bool TestMarketHours = true;         // Test market hours checking
input bool TestTimeFormatting = true;      // Test time formatting functions

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== ProfitPulsePro DateTime Tests ===");
    
    if(TestBasicDateTime)
        TestBasicDateTimeOperations();
    
    if(TestTimeFilter)
        TestTimeFilterFunctionality();
    
    if(TestMarketHours)
        TestMarketHoursChecking();
    
    if(TestTimeFormatting)
        TestTimeFormattingFunctions();
    
    Print("=== All DateTime Tests Completed ===");
}

//+------------------------------------------------------------------+
//| Test basic datetime operations                                   |
//+------------------------------------------------------------------+
void TestBasicDateTimeOperations()
{
    Print("--- Testing Basic DateTime Operations ---");
    
    //--- Test MqlDateTime structure initialization
    MqlDateTime dt;
    ZeroMemory(dt);
    
    //--- Test TimeToStruct function
    datetime currentTime = TimeCurrent();
    if(TimeToStruct(currentTime, dt))
    {
        Print("✓ TimeToStruct successful");
        Print("  Current time components:");
        Print("    Year: ", dt.year);
        Print("    Month: ", dt.mon);
        Print("    Day: ", dt.day);
        Print("    Hour: ", dt.hour);
        Print("    Minute: ", dt.min);
        Print("    Second: ", dt.sec);
        Print("    Day of week: ", dt.day_of_week);
        Print("    Day of year: ", dt.day_of_year);
    }
    else
    {
        Print("✗ TimeToStruct failed");
    }
    
    //--- Test StructToTime function
    MqlDateTime testTime;
    ZeroMemory(testTime);
    testTime.year = 2025;
    testTime.mon = 1;
    testTime.day = 15;
    testTime.hour = 12;
    testTime.min = 30;
    testTime.sec = 0;
    
    datetime reconstructedTime = StructToTime(testTime);
    if(reconstructedTime > 0)
    {
        Print("✓ StructToTime successful");
        Print("  Reconstructed time: ", TimeToString(reconstructedTime));
    }
    else
    {
        Print("✗ StructToTime failed");
    }
    
    Print("");
}

//+------------------------------------------------------------------+
//| Test time filter functionality                                   |
//+------------------------------------------------------------------+
void TestTimeFilterFunctionality()
{
    Print("--- Testing Time Filter Functionality ---");
    
    //--- Test different time scenarios
    MqlDateTime testScenarios[4];
    
    // Scenario 1: Morning (should be within trading hours)
    ZeroMemory(testScenarios[0]);
    testScenarios[0].year = 2025;
    testScenarios[0].mon = 1;
    testScenarios[0].day = 15;
    testScenarios[0].hour = 10;
    testScenarios[0].min = 0;
    testScenarios[0].sec = 0;
    testScenarios[0].day_of_week = 3; // Wednesday
    
    // Scenario 2: Evening (should be within trading hours)
    ZeroMemory(testScenarios[1]);
    testScenarios[1].year = 2025;
    testScenarios[1].mon = 1;
    testScenarios[1].day = 15;
    testScenarios[1].hour = 16;
    testScenarios[1].min = 0;
    testScenarios[1].sec = 0;
    testScenarios[1].day_of_week = 3; // Wednesday
    
    // Scenario 3: Night (should be outside trading hours)
    ZeroMemory(testScenarios[2]);
    testScenarios[2].year = 2025;
    testScenarios[2].mon = 1;
    testScenarios[2].day = 15;
    testScenarios[2].hour = 22;
    testScenarios[2].min = 0;
    testScenarios[2].sec = 0;
    testScenarios[2].day_of_week = 3; // Wednesday
    
    // Scenario 4: Weekend (should be outside trading hours)
    ZeroMemory(testScenarios[3]);
    testScenarios[3].year = 2025;
    testScenarios[3].mon = 1;
    testScenarios[3].day = 18;
    testScenarios[3].hour = 12;
    testScenarios[3].min = 0;
    testScenarios[3].sec = 0;
    testScenarios[3].day_of_week = 6; // Saturday
    
    string scenarioNames[4] = {"Morning (10:00)", "Evening (16:00)", "Night (22:00)", "Weekend (Saturday 12:00)"};
    bool expectedResults[4] = {true, true, false, false};
    
    for(int i = 0; i < 4; i++)
    {
        bool result = TestTimeFilter(testScenarios[i], 8, 18);
        string status = (result == expectedResults[i]) ? "✓" : "✗";
        Print("  ", status, " ", scenarioNames[i], ": ", result ? "Within hours" : "Outside hours");
    }
    
    Print("");
}

//+------------------------------------------------------------------+
//| Test market hours checking                                       |
//+------------------------------------------------------------------+
void TestMarketHoursChecking()
{
    Print("--- Testing Market Hours Checking ---");
    
    //--- Test current market status
    MqlDateTime currentDT;
    datetime now = TimeCurrent();
    
    if(TimeToStruct(now, currentDT))
    {
        bool isWeekend = (currentDT.day_of_week == 0 || currentDT.day_of_week == 6);
        Print("  Current time: ", GetFormattedTimeString(now));
        Print("  Day of week: ", currentDT.day_of_week, " (", GetDayName(currentDT.day_of_week), ")");
        Print("  Is weekend: ", isWeekend ? "Yes" : "No");
        Print("  Market status: ", isWeekend ? "Closed" : "Open");
    }
    
    //--- Test time until market events
    int secondsUntilClose = GetSecondsUntilMarketClose(currentDT, 17); // 5 PM close
    if(secondsUntilClose >= 0)
    {
        int hours = secondsUntilClose / 3600;
        int minutes = (secondsUntilClose % 3600) / 60;
        Print("  Time until market close: ", hours, "h ", minutes, "m");
    }
    else
    {
        Print("  Market is closed");
    }
    
    Print("");
}

//+------------------------------------------------------------------+
//| Test time formatting functions                                   |
//+------------------------------------------------------------------+
void TestTimeFormattingFunctions()
{
    Print("--- Testing Time Formatting Functions ---");
    
    datetime testTime = TimeCurrent();
    MqlDateTime dt;
    
    if(TimeToStruct(testTime, dt))
    {
        //--- Test various formatting styles
        string format1 = StringFormat("%04d-%02d-%02d %02d:%02d:%02d", 
                                    dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
        string format2 = StringFormat("%02d/%02d/%04d %02d:%02d", 
                                    dt.day, dt.mon, dt.year, dt.hour, dt.min);
        string format3 = StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day);
        
        Print("  ISO format: ", format1);
        Print("  US format: ", format2);
        Print("  Date only: ", format3);
        Print("  MQL TimeToString: ", TimeToString(testTime));
        Print("  MQL TimeToString (date): ", TimeToString(testTime, TIME_DATE));
        Print("  MQL TimeToString (time): ", TimeToString(testTime, TIME_MINUTES));
    }
    
    Print("");
}

//+------------------------------------------------------------------+
//| Test time filter with specific datetime                          |
//+------------------------------------------------------------------+
bool TestTimeFilter(MqlDateTime &dt, int startHour, int endHour)
{
    //--- Check if it's weekend
    if(dt.day_of_week == 0 || dt.day_of_week == 6)
        return false;
    
    //--- Check if within trading hours
    if(dt.hour >= startHour && dt.hour < endHour)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Get formatted time string                                        |
//+------------------------------------------------------------------+
string GetFormattedTimeString(datetime timestamp)
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
//| Get day name from day of week                                    |
//+------------------------------------------------------------------+
string GetDayName(int dayOfWeek)
{
    switch(dayOfWeek)
    {
        case 0: return "Sunday";
        case 1: return "Monday";
        case 2: return "Tuesday";
        case 3: return "Wednesday";
        case 4: return "Thursday";
        case 5: return "Friday";
        case 6: return "Saturday";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get seconds until market close                                   |
//+------------------------------------------------------------------+
int GetSecondsUntilMarketClose(MqlDateTime &dt, int closeHour)
{
    //--- Check if market is closed (weekend)
    if(dt.day_of_week == 0 || dt.day_of_week == 6)
        return -1;
    
    //--- Calculate current time in seconds
    int currentSeconds = dt.hour * 3600 + dt.min * 60 + dt.sec;
    int closeSeconds = closeHour * 3600;
    
    //--- If already past close time, return -1
    if(currentSeconds >= closeSeconds)
        return -1;
    
    return closeSeconds - currentSeconds;
}