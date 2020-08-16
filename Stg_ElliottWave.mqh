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
INPUT float ElliottWave_LotSize = 0;                 // Lot size
INPUT int ElliottWave_SignalOpenMethod = 0;          // Signal open method (0-1)
INPUT float ElliottWave_SignalOpenLevel = 0.0004f;   // Signal open level (>0.0001)
INPUT int ElliottWave_SignalOpenFilterMethod = 0;    // Signal open filter method
INPUT int ElliottWave_SignalOpenBoostMethod = 0;     // Signal open boost method
INPUT int ElliottWave_SignalCloseMethod = 0;         // Signal close method
INPUT float ElliottWave_SignalCloseLevel = 0.0004f;  // Signal close level (>0.0001)
INPUT int ElliottWave_PriceLimitMethod = 0;          // Price limit method
INPUT float ElliottWave_PriceLimitLevel = 0;         // Price limit level
INPUT int ElliottWave_TickFilterMethod = 0;          // Tick filter method
INPUT float ElliottWave_MaxSpread = 6.0;             // Max spread to trade (pips)
INPUT int ElliottWave_Shift = 0;                     // Shift (relative to the current bar, 0 - default)
INPUT string __ElliottWave_Indi_ElliottWave_Parameters__ =
    "-- ElliottWave strategy: ElliottWave indicator params --";  // >>> ElliottWave strategy: ElliottWave indicator <<<
INPUT int Indi_ElliottWave_Period = 14;                          // Averaging period
INPUT ENUM_APPLIED_PRICE Indi_ElliottWave_Applied_Price = PRICE_HIGH;  // Applied price.

// Structs.

// Defines struct with default user indicator values.
struct Indi_ElliottWave_Params_Defaults : ElliottWaveParams {
  Indi_ElliottWave_Params_Defaults() : ElliottWaveParams(::Indi_ElliottWave_Period, ::Indi_ElliottWave_Applied_Price) {}
} indi_ew_defaults;

// Defines struct to store indicator parameter values.
struct Indi_ElliottWave_Params : public ElliottWaveParams {
  // Struct constructors.
  void Indi_ElliottWave_Params(ElliottWaveParams &_params, ENUM_TIMEFRAMES _tf) : ElliottWaveParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_ElliottWave_Params_Defaults : StgParams {
  Stg_ElliottWave_Params_Defaults()
      : StgParams(::ElliottWave_SignalOpenMethod, ::ElliottWave_SignalOpenFilterMethod, ::ElliottWave_SignalOpenLevel,
                  ::ElliottWave_SignalOpenBoostMethod, ::ElliottWave_SignalCloseMethod, ::ElliottWave_SignalCloseLevel,
                  ::ElliottWave_PriceLimitMethod, ::ElliottWave_PriceLimitLevel, ::ElliottWave_TickFilterMethod,
                  ::ElliottWave_MaxSpread, ::ElliottWave_Shift) {}
} stg_ew_defaults;

// Struct to define strategy parameters to override.
struct Stg_ElliottWave_Params : StgParams {
  Indi_ElliottWave_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_ElliottWave_Params(Indi_ElliottWave_Params &_iparams, StgParams &_sparams)
      : iparams(indi_ew_defaults, _iparams.tf), sparams(stg_ew_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_ElliottWave : public Strategy {
 public:
  Stg_ElliottWave(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_ElliottWave *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_ElliottWave_Params _indi_params(indi_elli_defaults, _tf);
    StgParams _stg_params(stg_elli_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_ElliottWave_Params>(_indi_params, _tf, indi_elli_m1, indi_elli_m5, indi_elli_m15,
                                             indi_elli_m30, indi_elli_h1, indi_elli_h4, indi_elli_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_elli_m1, stg_elli_m5, stg_elli_m15, stg_elli_m30, stg_elli_h1,
                               stg_elli_h4, stg_elli_h8);
    }
    // Initialize indicator.
    ElliottWaveParams elli_params(_indi_params);
    _stg_params.SetIndicator(new Indi_ElliottWave(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ElliottWave(_stg_params, "ElliottWave");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Update indicator values.
   */
  /*
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
  */

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    bool _result = false;
    /*
    // @todo
    //  counted_bars=Bars;
    string TimeFrameStr;
    int tframe = TfToIndex(tf);

    if ((fasterEMA[0][tframe] > slowerEMA[0][tframe]) && (fasterEMA[1][tframe] < slowerEMA[1][tframe]) &&
        (fasterEMA[2][tframe] > slowerEMA[2][tframe]) && (_cmd == OP_BUY)) {
      return True;
    } else if ((fasterEMA[0][tframe] < slowerEMA[0][tframe]) && (fasterEMA[1][tframe] > slowerEMA[1][tframe]) &&
               (fasterEMA[2][tframe] < slowerEMA[2][tframe]) && (_cmd == OP_SELL)) {
      return True;
    }
    */

    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        // @todo
      }
    }
    return (float)_result;
  }
};
