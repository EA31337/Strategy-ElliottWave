//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
#ifdef __MQL5__
//#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_HeartBeat.ex5" + MQL_EXT
//#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator-Arrows.ex5" + MQL_EXT
//#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator1-Trend.ex5" + MQL_EXT
//#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator1.ex5" + MQL_EXT
#resource INDI_EWO_OSC_PATH + "\\Elliott_Wave_Oscillator2" + MQL_EXT
#endif
#endif
