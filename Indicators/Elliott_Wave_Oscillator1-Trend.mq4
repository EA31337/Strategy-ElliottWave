//+------------------------------------------------------------------+
//|                               Elliott_Wave_Oscillator3-Trend.mq4 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_maximum 1.1
#property indicator_minimum - 1.1
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 2

//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
extern int FastMa = 5;
extern int SlowMa = 35;
extern double trigger = 0.25;
extern int back_test = 5;

double ExtHistoBuffer[];

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init() {
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
  SetIndexBuffer(0, ExtHistoBuffer);
  IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
  return (0);
}
int start() {
  //+------------------------------------------------------------------+
  //| Local variables                                                  |
  //+------------------------------------------------------------------+
  int shift = 0;
  int i = 0;
  int limit;
  double llv = 0;
  double hhv = 0;
  double taiv = 0;
  double trend = 0;
  int counted_bars = IndicatorCounted();
  //---- check for possible errors
  if (counted_bars < 0) return (-1);
  //---- last counted bar will be recounted
  if (counted_bars > 0) counted_bars--;
  limit = Bars - counted_bars;

  // loop from last executed bar to current bar (with shift=0)
  for (shift = limit; shift >= 0; shift--) {
    llv =
        iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) - iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift);
    hhv =
        iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) - iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift);
    for (i = shift; i <= shift + back_test; i++) {
      llv = MathMin(
          iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, i) - iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, i), llv);
      hhv = MathMax(
          iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, i) - iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, i), hhv);
    }
    if ((hhv == (iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) -
                 iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift)) &&
         trend == 0))
      trend = 1;
    if ((llv == (iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) -
                 iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift)) &&
         trend == 0))
      trend = -1;
    if ((llv < 0 && trend == -1 &&
         (iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) -
          iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift)) > -trigger * llv))
      trend = 1;
    if ((hhv > 0 && trend == 1 &&
         (iMA(NULL, 0, FastMa, 0, MODE_SMA, PRICE_MEDIAN, shift) -
          iMA(NULL, 0, SlowMa, 0, MODE_SMA, PRICE_MEDIAN, shift)) < -trigger * hhv))
      trend = -1;
    ExtHistoBuffer[shift] = trend;
  }
  return (0);
}
