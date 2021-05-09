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
    //noteDuration.firstNumber = NoteDuration.DefaultFirstNumber; // new 10/30/20, removed 11/4/20
    //noteDuration.secondNumber = NoteDuration.DefaultSecondNumber;
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
        modifyThisTempo.noteDuration.secondNumber = 3; // the beat for 6/8, 9/8, 12/8, 3/8 is a dotted quarter, which is 8:3
        // yes this happens!!!!!!!!   print('ever happen?????  maven!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      }
      else {
        modifyThisTempo.noteDuration.firstNumber ??= timeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
        modifyThisTempo.noteDuration.secondNumber ??= 1;
      }
    }
    //return modifyThisTempo;
    return;
  }
}
