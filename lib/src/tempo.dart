import 'package:petitparser/petitparser.dart'; // defines Result
import 'package:logging/logging.dart';
import '../pipelang.dart';

//final log = Logger('Tempo');

class TempoRamp {
  Tempo startTempo; // perhaps should store as velocity?
  Tempo endTempo;
  int totalTicksStartToEnd;
  num slope;

  String toString() {
    return 'TempoRamp: startTempo: $startTempo, endTempo: $endTempo, totalTicksStartToEnd: $totalTicksStartToEnd, Slope: $slope';
  }
}

class Tempo {
  static const DefaultBpm = 84;
  NoteDuration noteDuration;
  // int bpm = Tempo.DefaultBpm; // It's right above
  num bpm; // It's right above

  Tempo() {
    //print('in Tempo() constructor');
    noteDuration = NoteDuration();
    noteDuration.firstNumber = NoteDuration.DefaultFirstNumber; // new 10/30/20
    noteDuration.secondNumber = NoteDuration.DefaultSecondNumber;
    bpm = Tempo.DefaultBpm;
  }


  String toString() {
    return 'Tempo: bpm: $bpm, $noteDuration';
  }


  // Maybe should change this so it doesn't change the Tempo passed in, and returns a new Tempo object
  static Tempo scaleThis(Tempo tempo, num scalar) {
    log.fine('scaleThis(), tempo passed in is $tempo, and scalar is $scalar');
    var newTempo = Tempo();
    newTempo.noteDuration.firstNumber = tempo.noteDuration.firstNumber;
    newTempo.noteDuration.secondNumber = tempo.noteDuration.secondNumber;
    newTempo.bpm = tempo.bpm + (tempo.bpm * scalar / 100).round();
    log.fine('scaleThis(), tempo is now $newTempo');
    return newTempo;
  }
  // // Maybe should change this so it doesn't change the Tempo passed in, and returns a new Tempo object
  // static void scaleThis(Tempo tempo, num scalar) {
  //   //tempo.bpm += (scalar / 100).floor(); // not right, right?
  //   log.fine('tempo was ${tempo.bpm}');
  //   tempo.bpm += (tempo.bpm * scalar / 100).floor();
  //   log.fine('tempo is now ${tempo.bpm}');
  // }
  // static Tempo watchOutDuplicateCode(Tempo overrideTempo, TimeSig overrideTimeSig) {
  static void fillInTempoDuration(Tempo modifyThisTempo, TimeSig timeSig) {
    if (modifyThisTempo.noteDuration.firstNumber == null || modifyThisTempo.noteDuration.secondNumber == null) {
      if (timeSig.denominator == 8 && timeSig.numerator % 3 == 0) { // if timesig is 6/8, or 9/8 or 12/8, or maybe even 3/8, then it should be 8:3
        modifyThisTempo.noteDuration.firstNumber = 8;
        modifyThisTempo.noteDuration.secondNumber = 3;
        print('ever happen?????  maven!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      }
      else {
        modifyThisTempo.noteDuration.firstNumber ??= timeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
        modifyThisTempo.noteDuration.secondNumber ??= 1;
        print('ever maven happens?????????????????????????????????????????????????????????????????????????????????????????????');
      }
    }
    //return modifyThisTempo;
    return;
  }
}

/// I think we're not going to allow for accel or deaccel
/// because I think that means a change to ticks per second or
/// something, for every note, and I don't know how well that would work.
/// So skip for now
//enum TempoScaleRampWhatever {
//  accel, // \accel ?
//  deaccel // \deaccel ?
//}
Parser TempoRampParser = (
    string('/deaccel') |
    string('/accel')
).trim().map((value) {
  log.finest('In TempoRampParser');
  TempoRamp tempoRamp;
  switch (value) {
    case '/accel':
    case '/deaccel':
      tempoRamp =  TempoRamp();
      break;
  }
  log.finest('Leaving TempoRampParser returning value $tempoRamp');
  return tempoRamp;
});

///
/// tempoParser
///
Parser tempoParser = ( // what about whitespace?
    string('/tempo').trim() & (durationParser.trim() & char('=').trim()).optional().trim() & wholeNumberParser
//Parser tempoParser = ( // what about whitespace?
//    string('\\tempo').trim() & durationParser.trim() & char('=').trim() & wholeNumberParser
).trim().map((value) {
  log.finest('In TempoParser and value is -->$value<--');
  var tempo = Tempo();
  if (value[1] != null) {
    NoteDuration noteDuration = value[1][0]; // NoteDurationParser returns an object
    tempo.noteDuration = noteDuration;
  }
  // else {
  //   print('hey, watch out for tempos that do not have noteDuration values for firstNumber etc.'); // this is fixed later as a phase
  // }
  // else { // new.  Probably should not be done here.  Need timesig info to fill this in if NoteDuration is null
  //   tempo.noteDuration.firstNumber = 4; // this is for 1/4, 2/4, 3/4, 4/4, 5/4 ...   Not 6/8, 9/8, 12/8, etc.  Depends on timeSig.
  //   tempo.noteDuration.secondNumber = 1;
  // }
  tempo.bpm = value[2];    // hey, what if we have '/tempo 84', shouldn't we set the duration to be something?
  log.finest('Leaving tempoParser returning value $tempo which may need to be augmented later if Duration.firstNumber and secondNumber are null');
  return tempo; // This goes into the list of elements that make up a score, which we process one by one later.
});


