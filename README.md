//@version=6
indicator("SMC Smart Money Concepts v6", overlay=true)

// === Inputs ===
tradeTF       = input.timeframe("15",           "Trade Timeframe")
structureTF   = input.timeframe("60",           "Structure Timeframe")
fvgLen        = input.int(3,                    "FVG Lookback",    minval=1)
maxRetestBars = input.int(12,                   "Max Retest Bars", minval=1)
impulseBars   = input.int(3,                    "Impulse Bars",    minval=1)
showFVG       = input.bool(true,                "Show FVG Zones")
showBoS       = input.bool(true,                "Show Break of Structure")

// === Higher-TF data ===
[hiHTF, loHTF, clHTF] = request.security(syminfo.tickerid, structureTF, [high, low, close])

// === Market Structure (BoS) ===
var float lastPH = na
var float lastPL = na

ph = ta.pivothigh(hiHTF, impulseBars, impulseBars)
pl = ta.pivotlow(loHTF,  impulseBars, impulseBars)

if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

bosBull = showBoS and ta.cross(clHTF, lastPH)
bosBear = showBoS and ta.cross(lastPL, clHTF)

plotshape(
    bosBull and timeframe.isintraday and timeframe.multiplier == int(tradeTF),
    title="Bullish BoS",
    style=shape.triangleup,
    location=location.belowbar,
    color=color.new(color.green, 0),
    size=size.small
)

plotshape(
    bosBear and timeframe.isintraday and timeframe.multiplier == int(tradeTF),
    title="Bearish BoS",
    style=shape.triangledown,
    location=location.abovebar,
    color=color.new(color.red, 0),
    size=size.small
)

// === Fair Value Gaps (FVG) ===
var box[] fvgBoxes = array.new<box>()

// Create and prune FVG boxes on trade TF
if timeframe.multiplier == int(tradeTF)
    if showFVG and high[fvgLen] < low[fvgLen - 1]
        float topP = low[fvgLen - 1]
        float botP = high[fvgLen]
        box fvgBox = box.new(
            left         = bar_index - fvgLen,
            top          = topP,
            right        = bar_index - 1,
            bottom       = botP,
            border_color = color.orange,
            bgcolor      = color.new(color.orange, 80)
        )
        array.push(fvgBoxes, fvgBox)
    // prune old boxes
    if array.size(fvgBoxes) > 0
        for i = array.size(fvgBoxes) - 1 to 0 by -1
            box bx = array.get(fvgBoxes, i)
            if bar_index - box.get_left(bx) > maxRetestBars
                box.delete(bx)
                array.remove(fvgBoxes, i)

// === Entry Signals ===
enterLong  = false
enterShort = false

if timeframe.multiplier == int(tradeTF) and showFVG and array.size(fvgBoxes) > 0
    for i = 0 to array.size(fvgBoxes) - 1
        box bx = array.get(fvgBoxes, i)
        float topP = box.get_top(bx)
        float botP = box.get_bottom(bx)
        // bullish gap retest
        if low <= botP and close > botP
            enterLong := true
        // bearish gap retest
        if high >= topP and close < topP
            enterShort := true

plotshape(
    enterLong,
    title="FVG Long",
    style=shape.labelup,
    location=location.belowbar,
    color=color.aqua,
    text="Long"
)

plotshape(
    enterShort,
    title="FVG Short",
    style=shape.labeldown,
    location=location.abovebar,
    color=color.fuchsia,
    text="Short"
)

// === Alerts ===
if enterLong
    alert("SMC FVG Long Signal",  alert.freq_once_per_bar)
if enterShort
    alert("SMC FVG Short Signal", alert.freq_once_per_bar)
