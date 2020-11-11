import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';

//final log = Logger('TimeSig');
///
/// LilyPond uses '\time <int>/<int>'
/// e.g.  \time 3/4
/// Midi requires numerator and denominator metronome (18) and thirtyseconds (8)
///

TimeSig latestTimeSig; // used in score.dart

class TimeSig {
  static final DefaultNumerator = 4;
  static final DefaultDenominator = 4;
  int numerator = 4; // new 10/16
  int denominator = 4;
  // int numerator;
  // int denominator;

  String toString() {
    return 'TimeSig: $numerator/$denominator';
  }

}

