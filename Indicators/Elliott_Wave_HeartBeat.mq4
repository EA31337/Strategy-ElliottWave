//+------------------------------------------------------------------+
//|                                       Elliott_Wave_HeartBeat.mq4 |
//+------------------------------------------------------------------+
#property indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 LightBlue

//---- buffers
double Buffer1[];
double forcey = 0;
double upper = 0.04;
double lower = -0.04;
double multiplicant = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3);
  SetIndexBuffer(0, Buffer1);
  //---- name for DataWindow and indicator subwindow label
  IndicatorShortName("EWO");
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
#property indicator_maximum 0.07
#property indicator_minimum - 0.07
int start()

{
  int counted_bars = IndicatorCounted();
  if (Period() == 30) {
    upper = 0.2;
    lower = -0.2;
  }
  if (Period() == 60) {
    upper = 0.3;
    lower = -0.3;
  }
  if (Period() == 5) {
    upper = 0.0100;
    lower = -0.0100;
    multiplicant = 5;
  }
  if (Period() == 1)

  {
    upper = 0.0005;
    lower = -0.0005;
  }
  //---- TODO: add your code here
  for (int i = 300; i >= 0; i--)

  {
    forcey = iForce(NULL, 0, 7, 0, PRICE_CLOSE, i) - iForce(NULL, 0, 7, 0, PRICE_CLOSE, i + 1);
    if (forcey > 0 && forcey < upper) forcey = 0;
    if (forcey < 0 && forcey > lower) forcey = 0;

    Buffer1[i] = forcey * multiplicant;
    if (i == 0 && forcey != 0) {
      Alert(Symbol(), " ", Period(), "M  LIFE!");
    }
  }
  //----
  return (0);
}
//+------------------------------------------------------------------+
