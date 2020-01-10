//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements ElliottWave strategy. Based on the Elliott Wave indicator.
 *
 * @docs
 * - https://en.wikipedia.org/wiki/Elliott_wave_principle
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Strategy.mqh>

// User inputs.
INPUT string __ElliottWave_Parameters__ = "-- ElliottWave strategy params --";  // >>> ELLIOTT WAVE <<<
INPUT int ElliottWave_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...)
INPUT int ElliottWave_Period = 14;    // Averaging period
INPUT ENUM_APPLIED_PRICE ElliottWave_Applied_Price = PRICE_HIGH;  // Applied price.
INPUT ENUM_TRAIL_TYPE ElliottWave_TrailingStopMethod = 3;         // Trail stop method
INPUT ENUM_TRAIL_TYPE ElliottWave_TrailingProfitMethod = 22;      // Trail profit method
INPUT int ElliottWave_Shift = 0;                                  // Shift (relative to the current bar, 0 - default)
INPUT double ElliottWave_SignalOpenLevel = 0.0004;                // Signal open level (>0.0001)
INPUT int ElliottWave_SignalBaseMethod = 0;                       // Signal base method (0-1)
INPUT int ElliottWave_SignalOpenMethod1 = 0;                      // Open condition 1 (0-1023)
INPUT int ElliottWave_SignalOpenMethod2 = 0;                      // Open condition 2 (0-)
INPUT double ElliottWave_SignalCloseLevel = 0.0004;               // Signal close level (>0.0001)
INPUT ENUM_MARKET_EVENT ElliottWave_SignalCloseMethod1 = 0;       // Signal close method 1
INPUT ENUM_MARKET_EVENT ElliottWave_SignalCloseMethod2 = 0;       // Signal close method 2
INPUT double ElliottWave_MaxSpread = 6.0;                         // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_ElliottWave_Params : Stg_Params {
  unsigned int ElliottWave_Period;
  ENUM_APPLIED_PRICE ElliottWave_Applied_Price;
  int ElliottWave_Shift;
  ENUM_TRAIL_TYPE ElliottWave_TrailingStopMethod;
  ENUM_TRAIL_TYPE ElliottWave_TrailingProfitMethod;
  double ElliottWave_SignalOpenLevel;
  long ElliottWave_SignalBaseMethod;
  long ElliottWave_SignalOpenMethod1;
  long ElliottWave_SignalOpenMethod2;
  double ElliottWave_SignalCloseLevel;
  ENUM_MARKET_EVENT ElliottWave_SignalCloseMethod1;
  ENUM_MARKET_EVENT ElliottWave_SignalCloseMethod2;
  double ElliottWave_MaxSpread;

  // Constructor: Set default param values.
  Stg_ElliottWave_Params()
      : ElliottWave_Period(::ElliottWave_Period),
        ElliottWave_Applied_Price(::ElliottWave_Applied_Price),
        ElliottWave_Shift(::ElliottWave_Shift),
        ElliottWave_TrailingStopMethod(::ElliottWave_TrailingStopMethod),
        ElliottWave_TrailingProfitMethod(::ElliottWave_TrailingProfitMethod),
        ElliottWave_SignalOpenLevel(::ElliottWave_SignalOpenLevel),
        ElliottWave_SignalBaseMethod(::ElliottWave_SignalBaseMethod),
        ElliottWave_SignalOpenMethod1(::ElliottWave_SignalOpenMethod1),
        ElliottWave_SignalOpenMethod2(::ElliottWave_SignalOpenMethod2),
        ElliottWave_SignalCloseLevel(::ElliottWave_SignalCloseLevel),
        ElliottWave_SignalCloseMethod1(::ElliottWave_SignalCloseMethod1),
        ElliottWave_SignalCloseMethod2(::ElliottWave_SignalCloseMethod2),
        ElliottWave_MaxSpread(::ElliottWave_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class ElliottWave : public Strategy {
 protected:
  int open_method = EMPTY;  // Open method.
  double open_level = 0.0;  // Open level.
  int FasterEMA = 5;
  int SlowerEMA = 6;
  double fasterEMA[3][9], slowerEMA[3][9];

 public:
  Stg_ElliottWave(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_ElliottWave *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_ElliottWave_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_ElliottWave_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_ElliottWave_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_ElliottWave_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_ElliottWave_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_ElliottWave_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_ElliottWave_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    ElliottWave_Params ew_params(_params.ElliottWave_Period, _params.ElliottWave_Applied_Price);
    IndicatorParams ew_iparams(10, INDI_ElliottWave);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_ElliottWave(ew_params, ew_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.ElliottWave_SignalBaseMethod, _params.ElliottWave_SignalOpenMethod1,
                       _params.ElliottWave_SignalOpenMethod2, _params.ElliottWave_SignalCloseMethod1,
                       _params.ElliottWave_SignalCloseMethod2, _params.ElliottWave_SignalOpenLevel,
                       _params.ElliottWave_SignalCloseLevel);
    sparams.SetStops(_params.ElliottWave_TrailingProfitMethod, _params.ElliottWave_TrailingStopMethod);
    sparams.SetMaxSpread(_params.ElliottWave_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ElliottWave(sparams, "ElliottWave");
    return _strat;
  }

  /**
   * Update indicator values.
   */
  int Update(int _tf) {
    int limit, i, counter;
    int tframe = TfToIndex(_tf);
    i = 1;
    fasterEMA[0][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i);      // now
    fasterEMA[1][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i + 1);  // previous
    fasterEMA[2][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i - 1);  // after

    slowerEMA[0][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i);
    slowerEMA[1][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i + 1);
    slowerEMA[2][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i - 1);

    return True;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    //  counted_bars=Bars;
    // @todo
    string TimeFrameStr;
    int tframe = TfToIndex(tf);

    if ((fasterEMA[0][tframe] > slowerEMA[0][tframe]) && (fasterEMA[1][tframe] < slowerEMA[1][tframe]) &&
        (fasterEMA[2][tframe] > slowerEMA[2][tframe]) && (_cmd == OP_BUY)) {
      return True;
    } else if ((fasterEMA[0][tframe] < slowerEMA[0][tframe]) && (fasterEMA[1][tframe] > slowerEMA[1][tframe]) &&
               (fasterEMA[2][tframe] < slowerEMA[2][tframe]) && (_cmd == OP_SELL)) {
      return True;
    }

    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
