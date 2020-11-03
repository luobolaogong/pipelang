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

// ///
// /// WholeNumberParser
// ///
// Parser wholeNumberParser = digit().plus().flatten().trim().map((value) { // not sure need sideeffect true
//   log.finest('In WholeNumberparser');
//   final theWholeNumber = int.parse(value);
//   log.finest('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
//   return theWholeNumber;
// });
//
// ///
// /// Duration Parser
// ///
//
// Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
//   log.finer('In DurationParser');
//   var duration = NoteDuration();
//   duration.firstNumber = value[0];
//   if (value[1] != null) { // prob unnec
//     duration.secondNumber = value[1][1];
//   }
//   else {
//     duration.secondNumber = 1; // wild guess that this fixes things
//   }
//   log.finer('Leaving DurationParser returning duration $duration');
//   return duration;
// });
