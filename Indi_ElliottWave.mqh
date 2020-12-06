//+------------------------------------------------------------------+
//|                                      Copyright 2016-2020, kenorb |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// User input params.
INPUT string __ElliottWave_Indi_Params__ = "-- Elliott Wave oscillator params --";  // >>> Elliott Wave oscillator <<<
INPUT int Indi_EWO_Period1 = 5;                                                     // EWO Period 1
INPUT int Indi_EWO_Period2 = 35;                                                    // EWO Period 2
INPUT ENUM_MA_METHOD Indi_EWO_MA_Method1 = MODE_SMA;                                // EWO MA Method 1
INPUT ENUM_MA_METHOD Indi_EWO_MA_Method2 = MODE_SMA;                                // EWO MA Method 2
INPUT ENUM_APPLIED_PRICE Indi_EWO_Applied_Price1 = PRICE_MEDIAN;                    // EWO Applied Price 1
INPUT ENUM_APPLIED_PRICE Indi_EWO_Applied_Price2 = PRICE_MEDIAN;                    // EWO Applied Price 2
INPUT ENUM_APPLIED_PRICE Indi_EWO_Shift = (ENUM_APPLIED_PRICE)0;                    // EWO Shift

// Structs.

// Defines struct to store indicator parameter values.
struct Indi_ElliottWave_Params : public IndicatorParams {
  // Indicator params.
  ENUM_APPLIED_PRICE ewo_ap1, ewo_ap2;
  ENUM_MA_METHOD ewo_mm1, ewo_mm2;
  int ewo_period1, ewo_period2;
  int ewo_shift;
  // Struct constructors.
  void Indi_ElliottWave_Params(int _ewo_period1, int _ewo_period2, ENUM_MA_METHOD _ewo_mm1, ENUM_MA_METHOD _ewo_mm2,
                               ENUM_APPLIED_PRICE _ewo_ap1, ENUM_APPLIED_PRICE _ewo_ap2, int _shift)
      : ewo_period1(_ewo_period1),
        ewo_period2(_ewo_period2),
        ewo_mm1(_ewo_mm1),
        ewo_mm2(_ewo_mm2),
        ewo_ap1(_ewo_ap1),
        ewo_ap2(_ewo_ap2),
        ewo_shift(_shift) {
    max_modes = 2;
    custom_indi_name = "Elliott_Wave_Oscillator2";
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  void Indi_ElliottWave_Params(Indi_ElliottWave_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    _params.tf = _tf;
  }
  // Getters.
  int GetAppliedPrice1() { return ewo_ap1; }
  int GetAppliedPrice2() { return ewo_ap2; }
  int GetEwoShift() { return ewo_shift; }
  int GetMAMethod1() { return ewo_mm1; }
  int GetMAMethod2() { return ewo_mm2; }
  int GetPeriod1() { return ewo_period1; }
  int GetPeriod2() { return ewo_period2; }
  // Setters.
  void SetAppliedPrice1(ENUM_APPLIED_PRICE _value) { ewo_ap1 = _value; }
  void SetAppliedPrice2(ENUM_APPLIED_PRICE _value) { ewo_ap2 = _value; }
  void SetEwoShift(int _value) { ewo_shift = _value; }
  void SetMAMethod1(ENUM_MA_METHOD _value) { ewo_mm1 = _value; }
  void SetMAMethod2(ENUM_MA_METHOD _value) { ewo_mm2 = _value; }
  void SetPeriod1(int _value) { ewo_period1 = _value; }
  void SetPeriod2(int _value) { ewo_period2 = _value; }
};

// Defines struct with default user indicator values.
struct Indi_ElliottWave_Params_Defaults : Indi_ElliottWave_Params {
  Indi_ElliottWave_Params_Defaults()
      : Indi_ElliottWave_Params(::Indi_EWO_Period1, ::Indi_EWO_Period2, ::Indi_EWO_MA_Method1, ::Indi_EWO_MA_Method2,
                                ::Indi_EWO_Applied_Price1, ::Indi_EWO_Applied_Price2, ::Indi_EWO_Shift) {}
} indi_ewo_defaults;

/**
 * Implements indicator class.
 */
class Indi_ElliottWave : public Indicator {
 public:
  // Structs.
  Indi_ElliottWave_Params params;

  /**
   * Class constructor.
   */
  Indi_ElliottWave(Indi_ElliottWave_Params &_p)
      : params(_p.ewo_period1, _p.ewo_period2, _p.ewo_mm1, _p.ewo_mm2, _p.ewo_ap1, _p.ewo_ap2, _p.shift),
        Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_ElliottWave(Indi_ElliottWave_Params &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.ewo_period1, _p.ewo_period2, _p.ewo_mm1, _p.ewo_mm2, _p.ewo_ap1, _p.ewo_ap2, _p.shift),
        Indicator(NULL, _tf) {
    params = _p;
  }

  /**
   * Gets indicator's params.
   */
  // Indi_ElliottWave_Params GetIndiParams() const { return params; }

  /**
   * Returns the indicator's value.
   *
   */
  double GetValue(int _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), params.GetTf(), params.custom_indi_name, params.GetPeriod1(),
                         params.GetPeriod2(), params.GetMAMethod1(), params.GetMAMethod1(), params.GetAppliedPrice1(),
                         params.GetAppliedPrice2(), params.GetEwoShift(), _mode, _shift);
        break;
      default:
        SetUserError(ERR_USER_NOT_SUPPORTED);
        _value = EMPTY_VALUE;
    }
    istate.is_changed = false;
    istate.is_ready = _LastError == ERR_NO_ERROR;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.value.SetValue(params.idvtype, GetValue(_mode, _shift), _mode);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.value.GetMinDbl(params.idvtype) >= 0);
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }
};
