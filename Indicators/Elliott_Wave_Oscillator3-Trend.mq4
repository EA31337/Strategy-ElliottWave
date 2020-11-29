//+------------------------------------------------------------------+
//|                               Elliott_Wave_Oscillator1-Trend.mq4 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 PaleVioletRed
#property indicator_color3 DimGray
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

extern string TimeFrame = "Current Time Frame";
extern bool Interpolate = true;
extern bool alertsOn = false;
extern bool alertsOnCurrent = false;
extern bool alertsMessage = true;
extern bool alertsSound = false;
extern bool alertsEmail = false;

double Buffer0[];
double Buffer1[];
double Buffer2[];
double trend[];

string indicatorFileName;
bool returnBars;
int timeFrame;

int init() {
  IndicatorBuffers(4);
  SetIndexBuffer(0, Buffer1);
  SetIndexStyle(0, DRAW_HISTOGRAM);
  SetIndexBuffer(1, Buffer2);
  SetIndexStyle(1, DRAW_HISTOGRAM);
  SetIndexBuffer(2, Buffer0);
  SetIndexBuffer(3, trend);

  indicatorFileName = WindowExpertName();
  returnBars = (TimeFrame == "returnBars");
  if (returnBars) return (0);
  timeFrame = stringToTimeFrame(TimeFrame);

  IndicatorShortName(timeFrameToString(timeFrame) + " Elliot oscillator");
  return (0);
}
int deinit() { return (0); }

int start() {
  int limit, counted_bars = IndicatorCounted();

  if (counted_bars < 0) return (-1);
  if (counted_bars > 0) counted_bars--;
  limit = MathMin(Bars - counted_bars, Bars - 1);
  if (returnBars) {
    Buffer1[0] = limit + 1;
    return (0);
  }
  if (timeFrame > Period())
    limit = MathMax(
        limit, MathMin(Bars, iCustom(NULL, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()));

  for (int i = limit; i >= 0; i--) {
    int y = iBarShift(NULL, timeFrame, Time[i]);
    Buffer0[i] =
        iMA(NULL, timeFrame, 5, 0, MODE_SMA, PRICE_MEDIAN, y) - iMA(NULL, timeFrame, 35, 0, MODE_SMA, PRICE_MEDIAN, y);
    trend[i] = trend[i + 1];
    if (Buffer0[i] > 0) trend[i] = 1;
    if (Buffer0[i] < 0) trend[i] = -1;
    if (!Interpolate || timeFrame <= Period() || y == iBarShift(NULL, timeFrame, Time[i - 1])) continue;

    datetime time = iTime(NULL, timeFrame, y);
    for (int n = 1; i + n < Bars && Time[i + n] >= time; n++) continue;
    for (int k = 1; k < n; k++) Buffer0[i + k] = Buffer0[i] + (Buffer0[i + n] - Buffer0[i]) * k / n;
  }
  for (i = limit; i >= 0; i--) {
    Buffer1[i] = EMPTY_VALUE;
    Buffer2[i] = EMPTY_VALUE;
    if (trend[i] == 1) Buffer1[i] = Buffer0[i];
    if (trend[i] == -1) Buffer2[i] = Buffer0[i];
  }

  manageAlerts();
  return (0);
}

void manageAlerts() {
  if (alertsOn) {
    if (alertsOnCurrent)
      int whichBar = 0;
    else
      whichBar = 1;
    whichBar = iBarShift(NULL, 0, iTime(NULL, timeFrame, whichBar));
    if (trend[whichBar] != trend[whichBar + 1]) {
      if (trend[whichBar] == 1) doAlert(whichBar, "up");
      if (trend[whichBar] == -1) doAlert(whichBar, "down");
    }
  }
}

void doAlert(int forBar, string doWhat) {
  static string previousAlert = "nothing";
  static datetime previousTime;
  string message;

  if (previousAlert != doWhat || previousTime != Time[forBar]) {
    previousAlert = doWhat;
    previousTime = Time[forBar];

    message = StringConcatenate(Symbol(), " ", timeFrameToString(timeFrame), " at ",
                                TimeToStr(TimeLocal(), TIME_SECONDS), " Elliot oscillator trend changed to ", doWhat);
    if (alertsMessage) Alert(message);
    if (alertsEmail) SendMail(StringConcatenate(Symbol(), "Elliot oscillator "), message);
    if (alertsSound) PlaySound("alert2.wav");
  }
}

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

int stringToTimeFrame(string tfs) {
  tfs = stringUpperCase(tfs);
  for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
    if (tfs == sTfTable[i] || tfs == "" + iTfTable[i]) return (MathMax(iTfTable[i], Period()));
  return (Period());
}
string timeFrameToString(int tf) {
  for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
    if (tf == iTfTable[i]) return (sTfTable[i]);
  return ("");
}

string stringUpperCase(string str) {
  string s = str;

  for (int length = StringLen(str) - 1; length >= 0; length--) {
    int _char = StringGetChar(s, length);
    if ((_char > 96 && _char < 123) || (_char > 223 && _char < 256))
      s = StringSetChar(s, length, _char - 32);
    else if (_char > -33 && _char < 0)
      s = StringSetChar(s, length, _char + 224);
  }
  return (s);
}
