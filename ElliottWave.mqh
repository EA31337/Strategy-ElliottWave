//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                                                           kenorb |
//+------------------------------------------------------------------+

#include  <Convert.mqh>

 
extern int FasterEMA = 5;
extern int SlowerEMA = 6;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Elliott
  {

public:

   double            fasterEMA[3][9],slowerEMA[3][9];

   int Update(int tf=PERIOD_M1)
     {

      int               limit,i,counter;

      int tframe=Convert::TfToIndex(tf);

      i=1;
      fasterEMA[0][tframe]=iMA(NULL,tf,FasterEMA,0,MODE_LWMA,PRICE_CLOSE,i); //now
      fasterEMA[1][tframe]=iMA(NULL,tf,FasterEMA,0,MODE_LWMA,PRICE_CLOSE,i+1); //previous
      fasterEMA[2][tframe]=iMA(NULL,tf,FasterEMA,0,MODE_LWMA,PRICE_CLOSE,i-1);  //after

      slowerEMA[0][tframe]=iMA(NULL,tf,SlowerEMA,0,MODE_LWMA,PRICE_CLOSE,i);
      slowerEMA[1][tframe]=iMA(NULL,tf,SlowerEMA,0,MODE_LWMA,PRICE_CLOSE,i+1);
      slowerEMA[2][tframe]=iMA(NULL,tf,SlowerEMA,0,MODE_LWMA,PRICE_CLOSE,i-1);

      return            true;

     }

   bool Signal(int cmd=EMPTY,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      //  counted_bars=Bars;
      string TimeFrameStr;
      int tframe=Convert::TfToIndex(tf);

      switch(tf)
        {
         case 1 : TimeFrameStr="tframe_M1"; break;
         case 5 : TimeFrameStr="tframe_M5"; break;
         case 15 : TimeFrameStr="tframe_M15"; break;
         case 30 : TimeFrameStr="tframe_M30"; break;
         case 60 : TimeFrameStr="tframe_H1"; break;
         case 240 : TimeFrameStr="tframe_H4"; break;
         case 1440 : TimeFrameStr="tframe_D1"; break;
         case 10080 : TimeFrameStr="tframe_W1"; break;
         case 43200 : TimeFrameStr="tframe_MN1"; break;
         default : TimeFrameStr="Current Timeframe";
        }
      // IndicatorShortName("FX_Elliot ("+TimeFrameStr+")");


      if((fasterEMA[0][tframe]>slowerEMA[0][tframe]) && 
         (fasterEMA[1][tframe]<slowerEMA[1][tframe]) && 
         (fasterEMA[2][tframe]>slowerEMA[2][tframe])
         && (cmd==OP_BUY)
         )
        {
         return true;
        }
      else if((fasterEMA[0][tframe]<slowerEMA[0][tframe]) && 
         (fasterEMA[1][tframe]>slowerEMA[1][tframe]) && 
         (fasterEMA[2][tframe]<slowerEMA[2][tframe])
         && (cmd==OP_SELL)
         )
           {
            return true;
           }

         return false;
     }

  };
//+------------------------------------------------------------------+
