//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements ElliottWave strategy.
 */

// Includes the main code.
#include "Stg_ElliottWave.mq5"

// Load external resources.
#ifdef __resource__
// Tester properties.
#property tester_indicator "::" + INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator2" + MQL_EXT
#property tester_indicator "::" + INDI_SVEBB_PATH + "\\SVE_Bollinger_Bands" + MQL_EXT
#property tester_indicator "::" + INDI_TMA_MA_TREND_PATH + "\\ATR_MA_Trend" + MQL_EXT
#property tester_indicator "::" + INDI_TMA_TRUE_PATH + "\\TMA_True" + MQL_EXT
#property tester_indicator "::" + INDI_SUPERTREND_PATH + "\\SuperTrend" + MQL_EXT
// Indicator resources.
#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator2" + MQL_EXT
#resource INDI_SVEBB_PATH + "\\SVE_Bollinger_Bands" + MQL_EXT
#resource INDI_TMA_MA_TREND_PATH + "\\ATR_MA_Trend" + MQL_EXT
#resource INDI_TMA_TRUE_PATH + "\\TMA_True" + MQL_EXT
#resource INDI_SUPERTREND_PATH + "\\SuperTrend" + MQL_EXT
#endif