// import 'package:petitparser/petitparser.dart';
// import '../pipelang.dart';
//
// enum NoteArticulation {
//   tenuto, // '_' small accent
//   accent, // '>' normal accent
//   marcato // '^' big accent
// }
// class Note extends Note {
//   NoteArticulation articulation;
//   //NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
//   //NoteType noteType; // kinda like NoteName
//   //int velocity;
//   //Dynamic dynamic;
//   //int noteNumber;
//   //int noteOffDeltaTimeShift;
//   //int midiNoteNumber; // experiment 9/20/2020  This would be the midi soundfont number, related to NoteType
//   Note() {
//     //print('in Note() constructor');
//     //duration = NoteDuration();
//     articulation = null; // just for now
//     //noteType = NoteType.tapRight;  // correct here?  Maybe make this null too?
//     //velocity = 0;
//     //dynamic = Dynamic.mf; // What if we leave this null so that a value can be assigned later according to command line value, or something else?
//     //noteNumber = 0; // for now, new 10/4/2020
//     //noteOffDeltaTimeShift = 0;
//   }
//
//   @override
//   String toString() {
//     return 'NoteToString: Note: Articulation: $articulation, Duration: $duration, NoteType: $noteType';
//   }
//
//   swapHands() {
//     switch (noteType) {
//       case NoteType.tapRight:
//         noteType = NoteType.tapLeft;
//         break;
//       case NoteType.tapLeft:
//         noteType = NoteType.tapRight;
//         break;
//       case NoteType.flamRight:
//         noteType = NoteType.flamLeft;
//         break;
//       case NoteType.flamLeft:
//         noteType = NoteType.flamRight;
//         break;
//       case NoteType.dragRight:
//         noteType = NoteType.dragLeft;
//         break;
//       case NoteType.dragLeft:
//         noteType = NoteType.dragRight;
//         break;
//       case NoteType.buzzRight:
//         noteType = NoteType.buzzLeft;
//         break;
//       case NoteType.buzzLeft:
//         noteType = NoteType.buzzRight;
//         break;
//       case NoteType.tuzzRight:
//         noteType = NoteType.tuzzLeft;
//         break;
//       case NoteType.tuzzLeft:
//         noteType = NoteType.tuzzRight;
//         break;
//       case NoteType.ruff2Right:
//         noteType = NoteType.ruff2Left;
//         break;
//       case NoteType.ruff2Left:
//         noteType = NoteType.ruff2Right;
//         break;
//       case NoteType.ruff3Right:
//         noteType = NoteType.ruff3Left;
//         break;
//       case NoteType.ruff3Left:
//         noteType = NoteType.ruff3Right;
//         break;
//       case NoteType.tenorRight:
//         noteType = NoteType.tenorLeft;
//         break;
//       case NoteType.tenorLeft:
//         noteType = NoteType.tenorRight;
//         break;
//       case NoteType.bassRight:
//         noteType = NoteType.bassLeft;
//         break;
//       case NoteType.bassLeft:
//         noteType = NoteType.bassRight;
//         break;
//       case NoteType.dot:
//         log.info('Do what?????');
//         break;
//       case NoteType.roll:
//         break;
//       case NoteType.met:
//         break;
//       case NoteType.rest:
//         break;
//       default:
//         log.info('What was that note type?  $noteType');
//         break;
//     }
//   }
//
//   void setNoteNumber(Voice voice, bool loopBuzzes, bool usePadSoundFont) {
//   //void setNoteNumber(bool loopBuzzes, bool usePadSoundFont) {
//     // if (noteType == NoteType.rest) {
//     //   velocity = 0; // new, nec?
//     // }
//
//
//     // Maybe this should be put into Note, even though it's a MIDI thing.
//     //var noteNumber;
//     switch (noteType) {
//       case NoteType.tapRight:
//         noteNumber = 60;
//         if (voice == Voice.unison) { // get rid of this voice stuff and just make the unison its own noteType
//           noteNumber = 20;
//         }
//         break;
//     // case NoteType.tapUnison:
//     //   noteNumber = 20;
//     //   break;
//       case NoteType.tapLeft:
//         noteNumber = 70;
//         if (voice == Voice.unison) {
//           noteNumber = 30;
//         }
//         break;
//     // case NoteType.flamUnison:
//     //   noteNumber = 21;
//     //   break;
//       case NoteType.flamRight:
//         noteNumber = 61;
//         if (voice == Voice.unison) {
//           noteNumber = 21;
//         }
//         // test.  A positive number pushes the flam back so it's late.  But a neg number isn't allowed,
//         // so seems that the previous note's duration has to be shortened.  But what if a flam is the first
//         // note of a score?  Nothing before it to shave off.  Can the sound font compensate for this?????
//         // graceOffset = 1234;
//         break;
//       case NoteType.flamLeft:
//         noteNumber = 71;
//         if (voice == Voice.unison) {
//           noteNumber = 31;
//         }
//         // graceOffset = 1234; // test
//         break;
//     // case NoteType.dragUnison:
//     //   noteNumber = 21; // wrong, but don't have a drag recorded yet by SLOT
//     //   break;
//       case NoteType.dragRight:
//         noteNumber = 72; // temp until find out soundfont problem
//         if (voice == Voice.unison) {
//           noteNumber = 21;// wrong, but don't have a drag recorded yet by SLOT
//         }
//         break;
//       case NoteType.dragLeft:
//         noteNumber = 72;
//         if (voice == Voice.unison) {
//           noteNumber = 31;// wrong, but don't have a drag recorded yet by SLOT
//         }
//         break;
//       case NoteType.tenorRight:
//         noteNumber = 16;
//         break;
//       case NoteType.tenorLeft:
//         noteNumber = 16;
//         break;
//       case NoteType.bassRight:
//         noteNumber = 10; // temp until find out soundfont problem
//         break;
//       case NoteType.bassLeft:
//         noteNumber = 10;
//         break;
//     // case NoteType.rollUnison:
//     //   noteNumber = 23; // this one is looped.  This is called RollSlot
//     //   break;
//       case NoteType.buzzRight:
//         noteNumber = 63;
//         if (loopBuzzes) {
//           noteNumber = 67; // this one is looped but not quick enough?
//         }
//         if (voice == Voice.unison) {
//           noteNumber = 23;
//         }
//         break;
//       case NoteType.buzzLeft:
//       // If loop, add 4 to be 77
//         noteNumber = 73;
//         if (loopBuzzes) {
//           noteNumber = 77; // this one is looped, but not quick enough????
//         }
//         if (voice == Voice.unison) {
//           noteNumber = 33;
//         }
//         break;
//     // Later add SLOT Tuzzes, they have lots in the recording
//       case NoteType.tuzzLeft:
//         noteNumber = 74;
//         if (voice == Voice.unison) {
//           noteNumber = 34;// wrong
//         }
//         break;
//       case NoteType.tuzzRight:
//         noteNumber = 64;
//         if (voice == Voice.unison) {
//           noteNumber = 24;// wrong
//         }
//         break;
//       case NoteType.ruff2Left:
//         noteNumber = 75;
//         break;
//       case NoteType.ruff2Right:
//         noteNumber = 65;
//         break;
//       case NoteType.ruff3Left:
//         noteNumber = 76;
//         break;
//       case NoteType.ruff3Right:
//         noteNumber = 66;
//         break;
//       case NoteType.roll:
//         noteNumber = 40;
//         if (voice == Voice.unison) {
//           noteNumber = 37;// wrong
//         }
//         break;
//       case NoteType.met: // new
//         noteNumber = 1;
//         break;
//       case NoteType.rest:
//         noteNumber = 99; // see if this helps stop blowups when writing
//         break;
//       default:
//         log.fine('noteOnNoteOff, What the heck was that note? $noteType');
//     }
//
//     // FIX THIS LATER WHEN SOUND FONT HAS SOFT/MED/LOUD RECORDINGS.
//     if (soundFontHasSoftMediumLoudRecordings) {
//       //
//       // This is new, to take advantage of the 3 different volume levels in the recordings, which were separated by 10 note numbers.
//       //
//       if (velocity < 50) {
//         log.finer('Note velocity is ${velocity}, so switched to quiet recording.');
//         noteNumber -= 10;
//       }
//       else if (velocity > 100) {
//         log.finer('Note velocity is ${velocity}, so switched to loud recording.');
//         noteNumber += 10;
//       }
//       else {
//         log.finer('Note velocity is ${velocity}, so did not switch recording.');
//       }
//     }
//
//     if (usePadSoundFont) {
//       noteNumber -= 20;
//     }
//     return;
//   }
//
// //  int durationToTicks(int ticksPerBeat, Duration snareLangNoteNameValue) {
// //    int ticks = (4 * ticksPerBeat / snareLangNoteNameValue).floor(); // ????
// //    return ticks;
// //  }
// }
//
//
// // class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
// //   static final DefaultFirstNumber = 4;
// //   static final DefaultSecondNumber = 1;
// //   // Maybe should change the following to doubles even though I wanted a ratio of two whole numbers?
// //   int firstNumber; // initialize????  // trying again 10/16/20
// //   int secondNumber;
// //
// //   NoteDuration() {
// //     //print('in NoteDuration() constructor and will set firstNumber and secondNumber');
// //     firstNumber = DefaultFirstNumber;
// //     secondNumber = DefaultSecondNumber;
// //   }
// // //  num firstNumber; // should be an int?
// // //  num secondNumber;
// //
// // //  NoteDuration(); // what?  Specifying an empty constructor?  Why?
// // //  NoteDuration(this.firstNumber, this.secondNumber);
// //
// //
// //   String toString() {
// //     return 'NoteDuration: $firstNumber:$secondNumber';
// //   }
// // }
//
// // int beatFractionToTicks(num beatFraction) {
// //   //int ticksPerBeat = 10080
// //   // var durationInTicks = (Midi.ticksPerBeat * beatFraction).floor(); // why not .round()?
// //   var durationInTicks = (Midi.ticksPerBeat * beatFraction).round();
// // //  var durationInTicks = (4 * Midi.ticksPerBeat * secondNumber / firstNumber).floor(); // why not .round()?
// //   return durationInTicks;
// // }
//
// // // add ensemble (SLOT) notes too, and rolls for loops
// // enum NoteType { // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
// //   tapRight,
// //   tapLeft,
// //   tapUnison,
// //   flamRight,
// //   flamLeft,
// //   flamUnison,
// //   openDragRight, // not a 2-stroke ruff, and not a dead drag.  No recording yet
// //   openDragLeft,
// //   dragRight,
// //   dragLeft,
// //   dragUnison,
// //   buzzRight, // this can be looped
// //   buzzLeft, // this can be looped
// //   tuzzLeft,
// //   tuzzRight,
// //   tuzzUnison,
// //   ruff2Left, // how often do these show up?  Prob almost never.  Instead, an "open drag"
// //   ruff2Right,
// //   ruff2Unison,
// //   ruff3Left,
// //   ruff3Right,
// //   ruff3Unison,
// //   roll, // prob need to add roll recordings for snare and pad.  Currently only have SLOT recording I think
// //   tenorLeft,
// //   tenorRight,
// //   bassLeft,
// //   bassRight,
// //   met,
// //   rest,
// //   previousNoteDurationOrType
// // }
//
//
//
// /// I don't know what to call this yet.  The idea is that sometimes maybe a soloist should play,
// /// and other times all should play (unison), and maybe other times a different instrument should
// /// play the part.  For now, all we want is to handle the "unison" sections, which are sometimes
// /// called "chips", or "forte parts" or something else.  And for now, "unison" will mean use
// /// the sound font recordings made of a group of drummers playing, rather than a single instrument
// /// recording.  I have my snare drum, and I'm adding on recordings from SLOT, as a group.
// /// So I want to be able to play a score where there are sections of solo and sections of unison.
// enum Voice {
//   solo,
//   unison
// }
//
// // ///
// // /// VoiceParser
// // ///
// // Parser voiceParser = (
// //     string('/unison') |
// //     string('/chips') |
// //     string('/tutti') |
// //     string('/solo') |
// //     string('/tip')
// // ).trim().map((value) { // trim?  Yes!  Makes a difference
// //   Voice voice;
// //   switch (value) {
// //     case '/unison':
// //     case '/chips':
// //     case '/tutti':
// //       voice = Voice.unison;
// //       break;
// //     case '/solo':
// //     case '/tip':
// //       voice =  Voice.solo;
// //       break;
// //   }
// //   //log.info('Leaving VoiceParser returning value $voice');
// //   return voice;
// // });
// //
// // ///
// // /// ArticulationParser
// // ///
// // Parser articulationParser = (
// //     char('^') | // maybe change these to pattern('/^>-_')
// //     char('>') |
// //     char('_') |
// //     char('-')    // get rid of this one
// // ).trim().map((value) { // trim()?
// //   log.finest('In Articulationparser');
// //   NoteArticulation articulation;
// //   switch (value) {
// //     case '_':
// //       articulation = NoteArticulation.tenuto;
// //       break;
// //     case '>':
// //       articulation = NoteArticulation.accent;
// //       break;
// //     case '^':
// //       articulation = NoteArticulation.marcato;
// //       break;
// //     default:
// //       log.info('What was that articulation? -->${value}<--');
// //   }
// //   //log.info('Leaving Articulationparser returning articulation $articulation');
// //   return articulation;
// // });
//
//
//
// // ///
// // /// WholeNumberParser
// // ///
// // Parser wholeNumberParser = digit().plus().flatten().trim().map((value) { // not sure need sideeffect true
// //   log.finest('In WholeNumberparser');
// //   final theWholeNumber = int.parse(value);
// //   //log.info('Leaving WholeNumberparser returning theWholeNumber $theWholeNumber');
// //   return theWholeNumber;
// // });
// //
// // ///
// // /// Duration Parser
// // ///
// //
// // Parser durationParser = (wholeNumberParser & (char(':').trim() & wholeNumberParser).optional()).map((value) { // trim?
// //   log.finest('In DurationParser');
// //   //print('in durationParser.');
// //   var duration = NoteDuration();
// //   duration.firstNumber = value[0];
// //   if (value[1] != null) { // prob unnec
// //     duration.secondNumber = value[1][1];
// //   }
// //   else {
// //     duration.secondNumber = 1; // wild guess that this fixes things
// //   }
// //   //log.info('Leaving DurationParser returning duration $duration');
// //   return duration;
// // });
//
// ///
// /// TypeParser
// ///
// Parser typeParser = pattern('TtFfDdZzXxYyVvRMNnBbr.').trim().map((value) { // trim?
//   log.finest('In TypeParser');
//   NoteType noteType;
//   switch (value) {
//     case 'T':
//       noteType = NoteType.tapRight;
//       break;
//     case 't':
//       noteType = NoteType.tapLeft;
//       break;
//     case 'F':
//       noteType = NoteType.flamRight;
//       break;
//     case 'f':
//       noteType = NoteType.flamLeft;
//       break;
//     case 'D':
//       noteType = NoteType.dragRight;
//       break;
//     case 'd':
//       noteType = NoteType.dragLeft;
//       break;
//     case 'Z':
//       noteType = NoteType.buzzRight;
//       break;
//     case 'z':
//       noteType = NoteType.buzzLeft;
//       break;
//     case 'X':
//       noteType = NoteType.tuzzRight;
//       break;
//     case 'x':
//       noteType = NoteType.tuzzLeft;
//       break;
//     case 'Y':
//       noteType = NoteType.ruff2Right;
//       break;
//     case 'y':
//       noteType = NoteType.ruff2Left;
//       break;
//     case 'V':
//       noteType = NoteType.ruff3Right;
//       break;
//     case 'v':
//       noteType = NoteType.ruff3Left;
//       break;
//     case 'R':
//       noteType = NoteType.roll;
//       break;
//     case 'M':
//       noteType = NoteType.met;
//       break;
//     case 'B': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteType = NoteType.bassRight;
//       break;
//     case 'b':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteType = NoteType.bassLeft;
//       break;
//     case 'N': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteType = NoteType.tenorRight;
//       break;
//     case 'n':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteType = NoteType.tenorLeft;
//       break;
//     case 'r':
//       noteType = NoteType.rest;
//       break;
//     case '.':
//       noteType = NoteType.dot;
//       break;
//     default:
//       log.info('Hey, this shoulda been a failure cause got -->${value[0]}<-- and will return null');
//       break;
//   }
//   log.finest('Leaving TypeParser returning noteType $noteType');
//   return noteType;
// });
//
// ///
// /// NoteParser
// ///
// // // A note must consist of A or B or C or AB or AC or BC or ABC
// // // Be careful of order!
// // Parser drumNoteParser = (
// //     (articulationParser & durationParser & typeParser) |
// //     (articulationParser & durationParser) |
// //     (articulationParser & typeParser) |
// //     (durationParser & typeParser) |
// //     (articulationParser) |
// //     (durationParser) |
// //     (typeParser)
// // ).trim().map((valuesOrValue) { // trim?
// //   log.finest('In NoteParser');
// //   var note = Note();
// //
// //   if (valuesOrValue == null) {  //
// //     log.info('does this ever happen?  Hope not.  Perhaps if no match?');
// //   }
// //   // Handle cases ABC, AB, AC, BC
// //   if (valuesOrValue is List) {
// //     for (var value in valuesOrValue) {
// //       if (value is NoteArticulation) { // A
// //         note.articulation = value;
// //       }
// //       else if (value is NoteDuration) { // B
// //         note.duration.firstNumber = value.firstNumber;
// //         note.duration.secondNumber = value.secondNumber; // check;
// //       }
// //       else if (value is NoteType) { // C
// //         note.noteType = value;
// //       }
// //     }
// //   }
// //   else { // Handle cases A, B, C
// //     if (valuesOrValue is NoteArticulation) { // A
// //       note.articulation = valuesOrValue;
// //     }
// //     else if (valuesOrValue is NoteDuration) { // B
// //       note.duration.firstNumber = valuesOrValue.firstNumber;
// //       note.duration.secondNumber = valuesOrValue.secondNumber; // check;
// //     }
// //     else if (valuesOrValue is NoteType) { // C
// //       note.noteType = valuesOrValue;
// //     }
// //   }
// //
// //   //log.info('Leaving NoteParser returning note -->$note<--');
// //   return note;
// // });
