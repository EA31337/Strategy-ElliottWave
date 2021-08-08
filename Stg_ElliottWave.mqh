/**
 * @file
 * Implements ElliottWave strategy. Based on the Elliott Wave indicator.
 *
 * @docs
 * - https://en.wikipedia.org/wiki/Elliott_wave_principle
 */

// Includes indicator class.
#include "Indi_ElliottWave.mqh"

// User inputs.
INPUT_GROUP("ElliotWave strategy: strategy params");
INPUT float ElliottWave_LotSize = 0;                // Lot size
INPUT int ElliottWave_SignalOpenMethod = 2;         // Signal open method (-127-127)
INPUT float ElliottWave_SignalOpenLevel = 0.0f;     // Signal open level (>0.0001)
INPUT int ElliottWave_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int ElliottWave_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int ElliottWave_SignalCloseMethod = 2;        // Signal close method
INPUT float ElliottWave_SignalCloseLevel = 0.0f;    // Signal close level (>0.0001)
INPUT int ElliottWave_PriceStopMethod = 1;          // Price stop method
INPUT float ElliottWave_PriceStopLevel = 0;         // Price stop level
INPUT int ElliottWave_TickFilterMethod = 1;         // Tick filter method
INPUT float ElliottWave_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short ElliottWave_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int ElliottWave_OrderCloseTime = -20;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("ElliottWave strategy: Elliott Wave oscillator params");
INPUT int ElliottWave_Indi_EWO_Period1 = 5;                                   // EWO Period 1
INPUT int ElliottWave_Indi_EWO_Period2 = 35;                                  // EWO Period 2
INPUT ENUM_MA_METHOD ElliottWave_Indi_EWO_MA_Method1 = MODE_SMA;              // EWO MA Method 1
INPUT ENUM_MA_METHOD ElliottWave_Indi_EWO_MA_Method2 = MODE_SMA;              // EWO MA Method 2
INPUT ENUM_APPLIED_PRICE ElliottWave_Indi_EWO_Applied_Price1 = PRICE_MEDIAN;  // EWO Applied Price 1
INPUT ENUM_APPLIED_PRICE ElliottWave_Indi_EWO_Applied_Price2 = PRICE_MEDIAN;  // EWO Applied Price 2
INPUT int ElliottWave_Indi_EWO_Shift = 0;                                     // EWO Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_ElliottWave_Params_Defaults : Indi_ElliottWave_Params {
  Indi_ElliottWave_Params_Defaults()
      : Indi_ElliottWave_Params(::ElliottWave_Indi_EWO_Period1, ::ElliottWave_Indi_EWO_Period2,
                                ::ElliottWave_Indi_EWO_MA_Method1, ::ElliottWave_Indi_EWO_MA_Method2,
                                ::ElliottWave_Indi_EWO_Applied_Price1, ::ElliottWave_Indi_EWO_Applied_Price2,
                                ::ElliottWave_Indi_EWO_Shift) {}
} indi_ewo_defaults;

// Defines struct with default user strategy values.
struct Stg_ElliottWave_Params_Defaults : StgParams {
  Stg_ElliottWave_Params_Defaults()
      : StgParams(::ElliottWave_SignalOpenMethod, ::ElliottWave_SignalOpenFilterMethod, ::ElliottWave_SignalOpenLevel,
                  ::ElliottWave_SignalOpenBoostMethod, ::ElliottWave_SignalCloseMethod, ::ElliottWave_SignalCloseLevel,
                  ::ElliottWave_PriceStopMethod, ::ElliottWave_PriceStopLevel, ::ElliottWave_TickFilterMethod,
                  ::ElliottWave_MaxSpread, ::ElliottWave_Shift, ::ElliottWave_OrderCloseTime) {}
} stg_ewo_defaults;

// Struct to define strategy parameters to override.
struct Stg_ElliottWave_Params : StgParams {
  Indi_ElliottWave_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_ElliottWave_Params(Indi_ElliottWave_Params &_iparams, StgParams &_sparams)
      : iparams(indi_ewo_defaults, _iparams.tf.GetTf()), sparams(stg_ewo_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"

class Stg_ElliottWave : public Strategy {
 public:
  Stg_ElliottWave(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_ElliottWave *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_ElliottWave_Params _indi_params(indi_ewo_defaults, _tf);
    StgParams _stg_params(stg_ewo_defaults);
#ifdef __config__
    SetParamsByTf<Indi_ElliottWave_Params>(_indi_params, _tf, indi_ewo_m1, indi_ewo_m5, indi_ewo_m15, indi_ewo_m30,
                                           indi_ewo_h1, indi_ewo_h4, indi_ewo_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ewo_m1, stg_ewo_m5, stg_ewo_m15, stg_ewo_m30, stg_ewo_h1, stg_ewo_h4,
                             stg_ewo_h8);
#endif
    // Initialize indicator.
    Indi_ElliottWave_Params _ewo_params(_indi_params, _tf);
    _stg_params.SetIndicator(new Indi_ElliottWave(_ewo_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_ElliottWave(_stg_params, _tparams, _cparams, "Elliott Wave");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_ElliottWave *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        //_result &= _indi[_shift][1] < 0;
        _result &= _indi.IsIncreasing(3);
        _result &= _indi.IsIncByPct(_level, 0, 0, 3);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        //_result &= _indi[_shift][0] > 0;
        _result &= _indi.IsDecreasing(3);
        _result &= _indi.IsDecByPct(-_level, 0, 0, 3);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
