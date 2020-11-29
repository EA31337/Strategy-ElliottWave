//+------------------------------------------------------------------+
//|                                     Elliott_Wave_Oscillator1.mq4 |
//+------------------------------------------------------------------+
#property indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 DimGray
//---- input parameters
extern int EWOPeriod1 = 5;
extern int EWOPeriod2 = 35;
//---- buffers
double Buffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators
  SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(0, Buffer1);
  //---- name for DataWindow and indicator subwindow label
  string short_name;
  short_name = "EWO(" + EWOPeriod1 + ", " + EWOPeriod2 + ")";
  IndicatorShortName(short_name);
  SetIndexLabel(0, "EWO");
  //----
  return (0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() { return (0); }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int counted_bars = IndicatorCounted();
  double MA1, MA2;
  for (int i = Bars; i >= 0; i--) {
    MA1 = iMA(NULL, 0, EWOPeriod1, 0, MODE_SMA, PRICE_MEDIAN, i);
    MA2 = iMA(NULL, 0, EWOPeriod2, 0, MODE_SMA, PRICE_MEDIAN, i);
    Buffer1[i] = MA1 - MA2;
  }
  return (0);
}
//+------------------------------------------------------------------+
