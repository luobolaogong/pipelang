import 'package:petitparser/petitparser.dart';
import '../pipelang.dart';


///
/// WholeNumberParser
///
Parser wholeNumberParser = digit().plus().flatten().trim().map((value) { // not sure need sideeffect true
  log.finest('In WholeNumberparser');
  final theWholeNumber = int.parse(value);
  log.finest('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
  return theWholeNumber;
});

///
/// Duration Parser
///

Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
  log.finer('In DurationParser');
  var duration = NoteDuration();
  duration.firstNumber = value[0];
  if (value[1] != null) { // prob unnec
    duration.secondNumber = value[1][1];
  }
  else {
    duration.secondNumber = 1; // wild guess that this fixes things
  }
  log.finer('Leaving DurationParser returning duration $duration');
  return duration;
});
