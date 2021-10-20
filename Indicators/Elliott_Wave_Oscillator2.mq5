/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_separate_window
//#property indicator_plots 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red
// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Includes the main file.
#include "Elliott_Wave_Oscillator2.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, EWO_Period2);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, EWO_Period2);
  if (!ArrayGetAsSeries(Buffer1) || !ArrayGetAsSeries(Buffer2)) {
    ArraySetAsSeries(Buffer1, true);
    ArraySetAsSeries(Buffer2, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
