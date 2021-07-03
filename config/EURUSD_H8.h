/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ElliottWave_Params_H8 : Indi_ElliottWave_Params {
  Indi_ElliottWave_Params_H8() : Indi_ElliottWave_Params(indi_ewo_defaults, PERIOD_H8) {
    shift = 0;
    ewo_ap1 = (ENUM_APPLIED_PRICE)0;
    ewo_ap2 = (ENUM_APPLIED_PRICE)0;
    ewo_mm1 = (ENUM_MA_METHOD)0;
    ewo_mm2 = (ENUM_MA_METHOD)0;
    ewo_period1 = 5;
    ewo_period2 = 35;
  }
} indi_ewo_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ElliottWave_Params_H8 : StgParams {
  // Struct constructor.
  Stg_ElliottWave_Params_H8() : StgParams(stg_ewo_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_filter = 32;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ewo_h8;
