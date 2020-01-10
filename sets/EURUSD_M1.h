//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ElliottWave_EURUSD_M1_Params : Stg_ElliottWave_Params {
  Stg_ElliottWave_EURUSD_M1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M1;
    ElliottWave_Period = 32;
    ElliottWave_Applied_Price = 3;
    ElliottWave_Shift = 0;
    ElliottWave_TrailingStopMethod = 6;
    ElliottWave_TrailingProfitMethod = 11;
    ElliottWave_SignalOpenLevel = 36;
    ElliottWave_SignalBaseMethod = 0;
    ElliottWave_SignalOpenMethod1 = 0;
    ElliottWave_SignalOpenMethod2 = 0;
    ElliottWave_SignalCloseLevel = 36;
    ElliottWave_SignalCloseMethod1 = 0;
    ElliottWave_SignalCloseMethod2 = 0;
    ElliottWave_MaxSpread = 2;
  }
};
