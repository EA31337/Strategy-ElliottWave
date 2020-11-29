//+------------------------------------------------------------------+
//|                                     Elliott_Wave_Oscillator2.mq4 |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_separate_window
#property indicator_color1 LawnGreen
#property indicator_color2 Red
//---- input parameters
extern int EWOPeriod1 = 5;
extern int EWOPeriod2 = 35;
//---- buffers
double Buffer1[];
double Buffer2[];
double alertBar;
double prev;
double prev1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators
  SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(0, Buffer1);
  SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(1, Buffer2);
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

    if (Buffer2[i] > 0) {
      Buffer1[i] = MA1 - MA2;
      Buffer2[i] = 0;
    }
    if (Buffer1[i] < 0) {
      Buffer2[i] = MA1 - MA2;
      Buffer1[i] = 0;
    }

    if (prev != 2 && Buffer2[i] < Buffer1[i] && Bars > alertBar) {
      Alert("Elliot Wave new Up wave starting on ", Symbol(), " Period ", Period(), "buf1= ", Buffer1[i],
            "buf2= ", Buffer2[i], " prev = ", prev);
      alertBar = Bars;
      prev = 2;
    }
    if (prev != 1 && Buffer2[i] > Buffer1[i] && Buffer2[i] != 0 && Bars > alertBar) {
      Alert("Elliot Wave new Down wave starting on ", Symbol(), " Period ", Period(), "buf1= ", Buffer1[i],
            "buf2= ", Buffer2[i], " prev = ", prev);
      alertBar = Bars;
      prev = 1;
    }
    if (Buffer1[i] >= 0.0005 && Buffer2[i] != 0 && Bars > alertBar) {
      Alert("Up wave Hit 0.0005 on ", Symbol(), " Period ", Period(), " buf1= ", Buffer1[i], " buf2= ", Buffer2[i]);
      alertBar = Bars;
      prev = Buffer1[i];
    }
    if (Buffer2[i] <= -0.0003 && Buffer1[i] != 0 && Bars > alertBar) {
      Alert("Down wave Hit -0.0003 on ", Symbol(), " Period ", Period(), " buf1= ", Buffer1[i], " buf2= ", Buffer2[i]);
      alertBar = Bars;
      prev1 = Buffer2[i];
    }
  }
  //----
  return (0);
}
//+------------------------------------------------------------------+
