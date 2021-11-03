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
INPUT int ElliottWave_SignalOpenMethod = 0;         // Signal open method (-127-127)
INPUT float ElliottWave_SignalOpenLevel = 0.001f;   // Signal open level
INPUT int ElliottWave_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int ElliottWave_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT int ElliottWave_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int ElliottWave_SignalCloseMethod = 0;        // Signal close method
INPUT int ElliottWave_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float ElliottWave_SignalCloseLevel = 0.001f;  // Signal close level
INPUT int ElliottWave_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float ElliottWave_PriceStopLevel = 2;         // Price stop level
INPUT int ElliottWave_TickFilterMethod = 32;        // Tick filter method
INPUT float ElliottWave_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short ElliottWave_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT float ElliottWave_OrderCloseLoss = 80;        // Order close loss
INPUT float ElliottWave_OrderCloseProfit = 80;      // Order close profit
INPUT int ElliottWave_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("ElliottWave strategy: Elliott Wave oscillator params");
INPUT int ElliottWave_Indi_EWO_Period1 = 5;                                   // EWO Period 1
INPUT int ElliottWave_Indi_EWO_Period2 = 45;                                  // EWO Period 2
INPUT ENUM_MA_METHOD ElliottWave_Indi_EWO_MA_Method1 = MODE_SMA;              // EWO MA Method 1
INPUT ENUM_MA_METHOD ElliottWave_Indi_EWO_MA_Method2 = MODE_SMA;              // EWO MA Method 2
INPUT ENUM_APPLIED_PRICE ElliottWave_Indi_EWO_Applied_Price1 = PRICE_MEDIAN;  // EWO Applied Price 1
INPUT ENUM_APPLIED_PRICE ElliottWave_Indi_EWO_Applied_Price2 = PRICE_MEDIAN;  // EWO Applied Price 2
INPUT int ElliottWave_Indi_EWO_Shift = 0;                                     // EWO Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_ElliottWave_Params_Defaults : StgParams {
  Stg_ElliottWave_Params_Defaults()
      : StgParams(::ElliottWave_SignalOpenMethod, ::ElliottWave_SignalOpenFilterMethod, ::ElliottWave_SignalOpenLevel,
                  ::ElliottWave_SignalOpenBoostMethod, ::ElliottWave_SignalCloseMethod, ::ElliottWave_SignalCloseFilter,
                  ::ElliottWave_SignalCloseLevel, ::ElliottWave_PriceStopMethod, ::ElliottWave_PriceStopLevel,
                  ::ElliottWave_TickFilterMethod, ::ElliottWave_MaxSpread, ::ElliottWave_Shift) {
    Set(STRAT_PARAM_LS, ElliottWave_LotSize);
    Set(STRAT_PARAM_OCL, ElliottWave_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ElliottWave_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ElliottWave_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ElliottWave_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_ElliottWave : public Strategy {
 public:
  Stg_ElliottWave(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_ElliottWave *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_ElliottWave_Params_Defaults stg_ewo_defaults;
    StgParams _stg_params(stg_ewo_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ewo_m1, stg_ewo_m5, stg_ewo_m15, stg_ewo_m30, stg_ewo_h1, stg_ewo_h4,
                             stg_ewo_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_ElliottWave(_stg_params, _tparams, _cparams, "Elliott Wave");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiElliottWaveParams _indi_params(::ElliottWave_Indi_EWO_Period1, ::ElliottWave_Indi_EWO_Period2,
                                       ::ElliottWave_Indi_EWO_MA_Method1, ::ElliottWave_Indi_EWO_MA_Method2,
                                       ::ElliottWave_Indi_EWO_Applied_Price1, ::ElliottWave_Indi_EWO_Applied_Price2,
                                       ::ElliottWave_Indi_EWO_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_ElliottWave(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_ElliottWave *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    // IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][1] < -_level;
        _result &= _indi.IsIncreasing(1, 1);
        _result &= _indi.IsDecreasing(1, 1, _shift + 1);
        _result &= _indi.IsIncByPct(_level, 1, _shift, 3);
        //_result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] > _level;
        _result &= _indi.IsDecreasing(1, 0);
        _result &= _indi.IsIncreasing(1, 1, _shift + 1);
        _result &= _indi.IsDecByPct(-_level, 0, _shift, 3);
        //_result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
