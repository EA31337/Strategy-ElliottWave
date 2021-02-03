//+------------------------------------------------------------------+
//|                                      Copyright 2016-2021, kenorb |
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

// Structs.

// Defines struct to store indicator parameter values.
struct Indi_ElliottWave_Params : public IndicatorParams {
  // Indicator params.
  ENUM_APPLIED_PRICE ewo_ap1, ewo_ap2;
  ENUM_MA_METHOD ewo_mm1, ewo_mm2;
  int ewo_period1, ewo_period2;
  // Struct constructors.
  Indi_ElliottWave_Params(int _ewo_period1, int _ewo_period2, ENUM_MA_METHOD _ewo_mm1, ENUM_MA_METHOD _ewo_mm2,
                               ENUM_APPLIED_PRICE _ewo_ap1, ENUM_APPLIED_PRICE _ewo_ap2, int _shift)
      : ewo_period1(_ewo_period1),
        ewo_period2(_ewo_period2),
        ewo_mm1(_ewo_mm1),
        ewo_mm2(_ewo_mm2),
        ewo_ap1(_ewo_ap1),
        ewo_ap2(_ewo_ap2) {
    max_modes = 2;
    custom_indi_name = "Elliott_Wave_Oscillator2";
    shift = _shift;
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  Indi_ElliottWave_Params(Indi_ElliottWave_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    tf = _tf;
  }
  // Getters.
  int GetAppliedPrice1() { return ewo_ap1; }
  int GetAppliedPrice2() { return ewo_ap2; }
  int GetMAMethod1() { return ewo_mm1; }
  int GetMAMethod2() { return ewo_mm2; }
  int GetPeriod1() { return ewo_period1; }
  int GetPeriod2() { return ewo_period2; }
  // Setters.
  void SetAppliedPrice1(ENUM_APPLIED_PRICE _value) { ewo_ap1 = _value; }
  void SetAppliedPrice2(ENUM_APPLIED_PRICE _value) { ewo_ap2 = _value; }
  void SetMAMethod1(ENUM_MA_METHOD _value) { ewo_mm1 = _value; }
  void SetMAMethod2(ENUM_MA_METHOD _value) { ewo_mm2 = _value; }
  void SetPeriod1(int _value) { ewo_period1 = _value; }
  void SetPeriod2(int _value) { ewo_period2 = _value; }
};

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
                         params.GetPeriod2(), params.GetMAMethod1(), params.GetMAMethod2(), params.GetAppliedPrice1(),
                         params.GetAppliedPrice2(), params.GetShift(), _mode, _shift);
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.GetMin<double>() >= 0);
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }
};
