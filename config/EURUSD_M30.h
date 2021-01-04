/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ElliottWave_Params_M30 : Indi_ElliottWave_Params {
  Indi_ElliottWave_Params_M30() : Indi_ElliottWave_Params(indi_ewo_defaults, PERIOD_M30) { shift = 0; }
} indi_ewo_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ElliottWave_Params_M30 : StgParams {
  // Struct constructor.
  Stg_ElliottWave_Params_M30() : StgParams(stg_ewo_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ewo_m30;
