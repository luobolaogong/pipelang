import '../pipelang.dart';

/// Change the way I named notes to follow this:
/// https://musescore.org/sites/musescore.org/files/bww_doc.pdf
/// And take a look at this:
/// http://bagpipe.ddg-hansa.com/Bagpipe_Reader.pdf
/// For ABC notation: https://bagpipejourney.com/articles/abc_for_bagpipes.shtml     G and A are low notes.
/// See https://github.com/svenax/bagpipemusic/tree/master/others
///  Polynome app:  https://www.youtube.com/watch?v=Snm_90ols_Y
///
/// A bagpipe "note" is a combination of parts:
///
/// {duration}{embellishment}{NoteLetter}
///
/// (Some kind of shorthand can be employed, but not defined later.)
///
/// The NotesLetter names from low to high are GAbcdefga.  So, G and A are LOW notes
/// and "g" and "a" are high.  Therefore are 9 note letter names.  But for a bagpipe "note",
/// which is a combination of embellishment and note letter name there are tons of
/// possible combinations.  With just a single grace note you've got 72 possibilities:
/// XX GA Gb Gc Gd Ge Gf Gg Ga
/// AG XX Ab Ac Ad Ae Af Ag Aa
/// bG bA XX bc bd be bf bg ba
/// c
/// d
/// e
/// f
/// g
/// aG aA ab ac ad ae af ag XX
///
/// And with two grace notes, you've got maybe 72*72.  And with 3 grace notes it's probably
/// around 72*72*72, etc.  So, a really huge number of possibilities, most of which are
/// never played.
///
/// I do have an approximate ordering of common gracenote combinations, and therefore I
/// may decide to just start with the 20 most common, and then add to them as needed.
/// Here they are:
///
/// gA, ge, gc, gf, gb, gefe (\dble e), dc, ea, dA, gcdc (\dblc c), gd, GdGcd (\thrwd d), aga (\dbla a), gfg (\dblg g), ga, Ga, gbdg (dblb b), gfgf (dblf f)
///
//    2036 \grg a
//    1839 \grg e
//    1760 \grg c
//    1719 \grg f
//    1647 \grg b
//    1547 \dble e
//    1153 \grd c
//    1090 \gre a
//    1087 \grd a
//    1019 \dblc c
//    1004 \grg d
//     970 \thrwd d
//     871 \dblA A
//     603 \gra e
//     564 \grd b
//     530 \dblg g
//     481 \grg A
//     453 \wbirl a
//     437 \grG a
//     430 \dblb b
//     414 \dblf f
///
///
/// The {embellishment} is a sequence of grace notes, in order, that represent some known
/// "movement" like a "thumb doubling on D" which would be the gracenotes "a d e" followed
/// by the melody note "d".  The three gracenotes are an absolute set duration in length,
/// no matter what tempo is used.
///
/// Whether those gracenotes are "on the beat", or "before the beat" is determined by how
/// that "thumb doubling on D" is normally played, and the midi sequence is slid one way or
/// the other and compensated for at the end.
///
/// This method of naming is basically ABC.  I rejected BWW because I don't want to look up
/// embellishments given a pipe score.
///
/// So, an example note is "8aded" which is perhaps known as an "8th note thumb doubling on D"
///
/// If there is no grace note, then we'd have something like "8d"
///
///


class PipeNote extends Note {
  // NoteArticulation articulation;
//  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "PipeLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / PipeLangNoteNameValue
  //NoteName noteName; // this is kinda wasteful, because the embellishment includes the note name letter, but we may want a rest or a "dot"
  //Embellishment embellishment;
//  NoteType noteType;
    //NoteType noteType;
//  int velocity;
//  Dynamic dynamic;
//  int noteNumber;
//  int noteOffDeltaTimeShift;

  //int midiNoteNumber; // experiment 9/20/2020  This would be the midi soundfont number, related to NoteName

  PipeNote() {
    //print('in Note() constructor');
    //duration = NoteDuration();
    //embellishment = null;
    //noteName = NoteName.rest;
    // noteType = NoteType.r; // ???
    //noteType = NoteType.rest; // ???
    // velocity = dynamicToVelocity(Dynamic.dd); // If not set, gets value of null
    //velocity = 0; // no sound
    //noteNumber = 0; // gets null if not set
    // noteOffDeltaTimeShift = 0;
  }

  @override
  String toString() {
    // return 'Note: Articulation: $articulation, Duration: $duration, NoteName: $noteName, Dynamic: $dynamic';
    return 'PipeNoteToString: Note: Duration: $duration, NoteType: $noteType, velocity: $velocity, noteNumber: $noteNumber, shift: $noteOffDeltaTimeShift';
  }


  // this is called on an instance of Note, as in note.setNoteNumber();
  // In Dart, don't have to use "this."
  void setNoteNumber() {
    noteNumber = noteType.index; // very simplistic.  Might be okay.  Of course can never separate out the embellishments when play a tune
    log.finer('Just set the noteNumber to be $noteNumber');
  }
}

// class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
//   static final DefaultFirstNumber = 4;
//   static final DefaultSecondNumber = 1;
//   int firstNumber;
//   int secondNumber;
//
//   NoteDuration() {
//     // No I don't think we should set default values because may have parsed a note without duration
//     // and want to fill it in later with the previous note's value.  So it should be null in order to detect this.
//     // And this is different from how it's done in pipesLang.
//     //
//     // firstNumber = DefaultFirstNumber;
//     // secondNumber = DefaultSecondNumber;
//   }
//
//   String toString() {
//     return 'NoteDuration: $firstNumber:$secondNumber';
//   }
// }

// int beatFractionToTicks(num beatFraction) {
//   var durationInTicks = (Midi.ticksPerBeat * beatFraction).round();
//   return durationInTicks;
// }
// enum NoteType {
//   r,
//   G, A, b, c, d, e, f, g, a,
//   // single gracenotes
//   Ga,
//   gA,
//   ge,
//   gc,
//   gf,
//   gb,
//   dc,
//   ea,
//   dA,
//   gd,
//   ga,
//   // doublings
//   GAGA,
//   gefe,
//   gcdc,
//   aga,
//   gfg,
//   gbdb,
//   gfgf,
//   // Throws
//   GdGcd, // (\thrwd d maybe),
//
//
//
//
//   // tapRight,
//   // tapLeft,
//   // tapUnison,
//   // flamRight,
//   // flamLeft,
//   // flamUnison,
//   // openDragRight, // not a 2-stroke ruff, and not a dead drag.  No recording yet
//   // openDragLeft,
//   // dragRight,
//   // dragLeft,
//   // dragUnison,
//   // buzzRight, // this can be looped
//   // buzzLeft, // this can be looped
//   // tuzzLeft,
//   // tuzzRight,
//   // tuzzUnison,
//   // ruff2Left, // how often do these show up?  Prob almost never.  Instead, an "open drag"
//   // ruff2Right,
//   // ruff2Unison,
//   // ruff3Left,
//   // ruff3Right,
//   // ruff3Unison,
//   // roll, // prob need to add roll recordings for snare and pad.  Currently only have SLOT recording I think
//   // tenorLeft,
//   // tenorRight,
//   // bassLeft,
//   // bassRight,
//
//
//
//
//
//
//   dot, // experiment
//   M
// }


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
// rename this thing to something like pipeNoteNameParser and the file name to pipenote.dart maybe
// Parser pipeNoteNameParser = (
//     string('GdGcd') |
//     string('GAGA') |
//     string('gefe') |
//     string('gcdc') |
//     string('aga') |
//     string('gfg') |
//     string('gbdb') |
//     string('gfgf') |
//     // single gracenotes:
//     string('Ga') |
//     string('gA') |
//     string('ge') |
//     string('gc') |
//     string('gf') |
//     string('gb') |
//     string('dc') |
//     string('ea') |
//     string('dA') |
//     string('gd') |
//     string('ga') |
//     // just notes, no embellishments:
//     string('G') | string('A') | string('b') | string('c') | string('d') | string('e') | string('f') | string('g') | string('a') | string('b') |
//     string('.') |
//     string('r')
// ).trim().map((value) {
//   log.finer('entering pipeNoteNameParser, with string value $value');
//   NoteType pipeNoteName;
//   switch (value) {
//     case 'GdGcd':
//       pipeNoteName = NoteType.GdGcd;
//       break;
//     case 'GAGA':
//       pipeNoteName = NoteType.GAGA;
//       break;
//     case 'gefe':
//       pipeNoteName = NoteType.gefe;
//       break;
//     case 'gcdc':
//       pipeNoteName = NoteType.gcdc;
//       break;
//     case 'aga':
//       pipeNoteName = NoteType.aga;
//       break;
//     case 'gfg':
//       pipeNoteName = NoteType.gfg;
//       break;
//     case 'gbdb':
//       pipeNoteName = NoteType.gbdb;
//       break;
//     case 'gfgf':
//       pipeNoteName = NoteType.gfgf;
//       break;
//     case 'Ga':
//       pipeNoteName = NoteType.Ga;
//       break;
//     case 'gA':
//       pipeNoteName = NoteType.gA;
//       break;
//     case 'ge':
//       pipeNoteName = NoteType.ge;
//       break;
//     case 'gc':
//       pipeNoteName = NoteType.gc;
//       break;
//     case 'gf':
//       pipeNoteName = NoteType.gf;
//       break;
//     case 'gb':
//       pipeNoteName = NoteType.gb;
//       break;
//     case 'dc':
//       pipeNoteName = NoteType.dc;
//       break;
//     case 'ea':
//       pipeNoteName = NoteType.ea;
//       break;
//     case 'dA':
//       pipeNoteName = NoteType.dA;
//       break;
//     case 'gd':
//       pipeNoteName = NoteType.gd;
//       break;
//     case 'ga':
//       pipeNoteName = NoteType.ga;
//       break;
//     case 'G':
//       pipeNoteName = NoteType.G;
//       break;
//     case 'A':
//       pipeNoteName = NoteType.A;
//       break;
//     case 'b':
//       pipeNoteName = NoteType.b;
//       break;
//     case 'c':
//       pipeNoteName = NoteType.c;
//       break;
//     case 'd':
//       pipeNoteName = NoteType.d;
//       break;
//     case 'e':
//       pipeNoteName = NoteType.e;
//       break;
//     case 'f':
//       pipeNoteName = NoteType.f;
//       break;
//     case 'g':
//       pipeNoteName = NoteType.g;
//       break;
//     case 'a':
//       pipeNoteName = NoteType.a;
//       break;
//     case '.':
//       pipeNoteName = NoteType.dot;
//       break;
//     case 'r':
//       pipeNoteName = NoteType.r;
//       break;
//     default:
//       log.severe('What happened what is this embellishmentandnotename?');
//       break;
//   }
//   log.info('pipeNoteNameParser returning pipeNoteName: $pipeNoteName');
//   return pipeNoteName;
// });
//
//
// ///
// /// NoteParser
// /// I keep changing the definition of what a note is.  Technically it has atleast 3parts, but for now it has two main parts:
// /// 1.  Duration
// /// 2.  optional Embellishment (named grace notes), followed by required Melody note name, and the name can be '.'
// ///
// /// The letters that make up the string of grace note letters plus the melody note letter are used
// /// as a group to designate a midi note number.  There could be a mapping of a subset of all possible combination letters to
// /// a note number, or there could be an equation that generates an index into a sound font note number array.
// ///
// /// However, if we're doing "shorthands", then maybe we'd want to parse the letters into their embellishment part and
// /// their melody part.  But I think that's more work than is necessary.  Shorthands are not that useful, but okay.
// ///
// /// So, at least for now, we're sticking to two parts: duration and pitch names for embellishments and melody and
// /// we'll allow for a shorthand pass.
// ///
// /// The following are notes:
// /// 1.  <duration><letters>, for example 8gA and 8A
// /// 2.  <letters>, for example "gA", and "A", where previous note's duration, or default duration is used.  Also "." is okay?
// /// 3.  <duration>, for example "8", where previous note's letters are used.  This is somewhat unlikely
// ///
// ///
// // Parser noteParser = (
// //     (durationParser & pipeNoteNameParser & noteNameParser) |    // all three
// //     (pipeNoteNameParser & noteNameParser) |                     // use previous duration
// //     noteNameParser |                     // use previous duration but not embellishment
// //     durationParser   // use previous embellishment and note
// Parser pipeNoteParser = ( // change to pipeNoteParser ???
//     (durationParser & pipeNoteNameParser) |    // Case "A B"
//     durationParser |                                       // Case A, use previous embellishment and note
//     pipeNoteNameParser                        // Case B, use previous duration
// ).trim().map((valuesOrValue) { // trim?
//   log.finer('\t\tIn NoteParser and valuesOrValue is $valuesOrValue'); // huh?
//   var note = PipeNote();
//
//   if (valuesOrValue == null) {  //
//     log.warning('does this ever happen?  Hope not.  Perhaps if no match?');
//   }
//   // Looks like if we parse duration followed by embellishment, then it's an array/list, and so we have to loop
//   if (valuesOrValue is List) {
//     for (var value in valuesOrValue) { // Case "A B" -- duration followed by letters
//       if (value is NoteDuration) { // B
//         note.duration.firstNumber = value.firstNumber;
//         note.duration.secondNumber = value.secondNumber; // check;
//       }
//       if (value is NoteType) {
//         note.pipeNoteName = value;
//       }
//     }
//   }
//   else if (valuesOrValue is NoteDuration) { // case "A", leaving embellishmentAndNote null
//     note.duration.firstNumber = valuesOrValue.firstNumber;
//     note.duration.secondNumber = valuesOrValue.secondNumber; // check;
//   }
//   else if (valuesOrValue is NoteType) { // case "B", leaving duration null
//     note.pipeNoteName = valuesOrValue;
//   }
//   else {
//     log.severe('got something in note parser that was not a duration or embellishmentNoteName thing: $valuesOrValue');
//   }
//   log.finer('Leaving NoteParser returning note -->$note<--');
//   return note;
// });
