//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DarkKhaki
#property indicator_color2 Red
#property indicator_level1 0

extern bool Main.Line.Histogram = false;
extern int Signal.period = 5;

//---- buffers
double Buffer1[], Buffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators
  if (Main.Line.Histogram)
    SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  else
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);

  SetIndexBuffer(0, Buffer1);
  SetIndexLabel(0, "EWO");

  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexBuffer(1, Buffer2);
  SetIndexLabel(1, "Signal");

  IndicatorShortName("Elliott Wave Oscillator");
  //----
  return (0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  //---- TODO: add your code here

  //----
  return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int counted_bars = IndicatorCounted();
  double MA5, MA34;
  int limit = Bars - counted_bars;
  if (counted_bars > 0) limit++;
  //---- TODO: add your code here
  for (int i = 0; i < limit; i++) {
    MA5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, i);
    MA34 = iMA(NULL, 0, 34, 0, MODE_SMA, PRICE_MEDIAN, i);

    Buffer1[i] = MA5 - MA34;
  }

  for (i = 0; i < limit; i++) {
    Buffer2[i] = iMAOnArray(Buffer1, Bars, Signal.period, 0, MODE_LWMA, i);
  }

  //----
  return (0);
}
//+------------------------------------------------------------------+
