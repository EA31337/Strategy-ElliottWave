/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_buffers 2
#property indicator_separate_window
//#property indicator_plots 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>

// Defines macros.
#define Bars (Chart::iBars(_Symbol, _Period))

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  //if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin);
  //if (begin > 0) PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, begin);
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}

// Includes the main file.
#include "Elliott_Wave_Oscillator2.mq4"
