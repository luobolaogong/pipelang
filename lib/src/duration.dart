import 'package:petitparser/petitparser.dart';
import '../pipelang.dart';

class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
  static final DefaultFirstNumber = 4;
  static final DefaultSecondNumber = 1;
  int firstNumber;
  int secondNumber;

  NoteDuration() {
    // No I don't think we should set default values because may have parsed a note without duration
    // and want to fill it in later with the previous note's value.  So it should be null in order to detect this.
    // And this is different from how it's done in pipesLang.
    //
    // firstNumber = DefaultFirstNumber;
    // secondNumber = DefaultSecondNumber;
  }

  String toString() {
    return 'NoteDuration: $firstNumber:$secondNumber';
  }
}
