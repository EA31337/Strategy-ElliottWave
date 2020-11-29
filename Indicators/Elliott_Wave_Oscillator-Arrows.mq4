//+------------------------------------------------------------------+
//|                               Elliott_Wave_Oscillator-Arrows.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DarkKhaki
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_level1 0

extern int signal_period = 5;

//---- buffers
double Buffer1[], Buffer2[], b2[], b3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators

  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
  SetIndexBuffer(0, Buffer1);
  SetIndexLabel(0, "EWO");

  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexBuffer(1, Buffer2);
  SetIndexLabel(1, "Signal");

  IndicatorShortName("Elliott Wave Oscillator");

  SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1);
  SetIndexArrow(2, 234);  // down  226 234  242
  SetIndexBuffer(2, b2);

  SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1);
  SetIndexArrow(3, 233);  // UP   225  233 241
  SetIndexBuffer(3, b3);
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
    Buffer2[i] = iMAOnArray(Buffer1, Bars, signal_period, 0, MODE_LWMA, i);

    if (Buffer1[i] > Buffer2[i] && Buffer1[i - 1] < Buffer2[i - 1]) b2[i] = High[i] + 10 * Point;
    if (Buffer1[i] < Buffer2[i] && Buffer1[i - 1] > Buffer2[i - 1]) b3[i] = Low[i] - 10 * Point;
  }
  //----
  return (0);
}
//+------------------------------------------------------------------+
