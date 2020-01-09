//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of Elliott Wave strategy based on the Elliott Wave indicator.
 *
 * @docs
 * - https://en.wikipedia.org/wiki/Elliott_wave_principle
 */

// Includes.
#include <EA31337-classes\Strategies.mqh>
#include <EA31337-classes\Strategy.mqh>

// User inputs.
#ifdef __input__ input #endif string __ElliottWave_Parameters__ = \
    "-- Settings for the Elliott Wave indicator --";                  // >>> ELLIOTT WAVE <<<
#ifdef __input__ input #endif int ElliottWave_SignalMethod = 0;       // Signal method
#ifdef __input__ input #endif string ElliottWave_SignalMethods = "";  // Signal method

class ElliottWave : public Strategy {
 protected:
  int open_method = EMPTY;  // Open method.
  double open_level = 0.0;  // Open level.
  int FasterEMA = 5;
  int SlowerEMA = 6;
  double fasterEMA[3][9], slowerEMA[3][9];

 public:
  /**
   * Update indicator values.
   */
  int Update(int tf = PERIOD_M1) {
    int limit, i, counter;
    int tframe = TfToIndex(tf);
    i = 1;
    fasterEMA[0][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i);      // now
    fasterEMA[1][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i + 1);  // previous
    fasterEMA[2][tframe] = iMA(NULL, tf, FasterEMA, 0, MODE_LWMA, PRICE_CLOSE, i - 1);  // after

    slowerEMA[0][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i);
    slowerEMA[1][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i + 1);
    slowerEMA[2][tframe] = iMA(NULL, tf, SlowerEMA, 0, MODE_LWMA, PRICE_CLOSE, i - 1);

    return True;
  }

  /**
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int _cmd = EMPTY, int tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    //  counted_bars=Bars;
    string TimeFrameStr;
    int tframe = TfToIndex(tf);

    if ((fasterEMA[0][tframe] > slowerEMA[0][tframe]) && (fasterEMA[1][tframe] < slowerEMA[1][tframe]) &&
        (fasterEMA[2][tframe] > slowerEMA[2][tframe]) && (_cmd == OP_BUY)) {
      return True;
    } else if ((fasterEMA[0][tframe] < slowerEMA[0][tframe]) && (fasterEMA[1][tframe] > slowerEMA[1][tframe]) &&
               (fasterEMA[2][tframe] < slowerEMA[2][tframe]) && (_cmd == OP_SELL)) {
      return True;
    }

    return false;
  }
};
