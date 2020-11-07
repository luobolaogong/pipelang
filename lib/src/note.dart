import '../pipelang.dart';



class Note {
  //NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
  NoteType noteType;
  int velocity;
  Dynamic dynamic;
  int noteNumber;
  int noteOffDeltaTimeShift;

  // Mapping of note type to note number
  // these should be ordered by the last note played, not the gracenotes.  But use gracenotes as 2ndary sort
  // And sort is by pitch in this order: G A b c d e f g a, and shortest to longest.
  // And single notes, followed by single grace notes, followed by doubles, followed by, whatever
  // When fix the sound font and add in a bunch of notes, then update this list/table/map
  var NoteTypeNoteNumber = {
    NoteType.GdGcd: 5,
    NoteType.AGAGA: 2,
    NoteType.afgf: 7,
    NoteType.gfgf: 7,
    NoteType.gefe: 6,
    NoteType.gded: 5,
    NoteType.gdcd: 5,
    NoteType.gcdc: 4,
    NoteType.gbdb: 3,
    NoteType.gbGb: 3,
    NoteType.GdGe: 6,
    NoteType.Gdcd: 5,
    NoteType.GAGA: 2,
    NoteType.aga: 9,
    NoteType.gfg: 8,
    NoteType.fgf: 7,
    NoteType.ga: 9,
    NoteType.ea: 9,
    NoteType.eg: 8,
    NoteType.gf: 7,
    NoteType.ef: 7,
    NoteType.ge: 6,
    NoteType.Ae: 6,
    NoteType.gd: 5,
    NoteType.ed: 5,
    NoteType.gc: 4,
    NoteType.ec: 4,
    NoteType.dc: 4,
    NoteType.gb: 3,
    NoteType.eb: 3,
    NoteType.db: 3,
    NoteType.gA: 2,
    NoteType.eA: 2,
    NoteType.dA: 2,
    NoteType.GA: 2,
    NoteType.gG: 1, //?
    NoteType.eG: 1,
    NoteType.dG: 1,
    NoteType.a: 9,
    NoteType.g: 8,
    NoteType.f: 7,
    NoteType.e: 6,
    NoteType.d: 5,
    NoteType.c: 4,
    NoteType.b: 3,
    NoteType.A: 2,
    NoteType.G: 1,

    NoteType.rest: 0,
    NoteType.met: 112
  };

  //var noteNumber = NoteTypeNoteNumber[NoteType.A];



  Note() {
    duration = NoteDuration();
    noteType = NoteType.rest; // experiment
    //dynamic = Dynamic.mf; // right?  Maybe right for snare, but not for pipes?     Removing this 11/04/20
    noteOffDeltaTimeShift = 0;
  }

  // Need to get a note number based on note type.  Too many places to update when a new pipe note is needed.
  // Have to put it into the sound font file, wherever it fits, and then that assigned number needs to be
  // used when the text file note is parsed into an object, and that object has to correspond to the number.
  //
  // So the parser will hopefully parse the string note name, like "8gcdc", into the corresponding enumeration
  // NoteType.gcdc and that object can be used to get a note number.  Therefore, I'd like to have a table
  // that maps the enumeration object to the number, and then have something like "noteNumber = map(NoteType.gcdc)"
  // So, I shall look into "Map".



  void setNoteNumber() { // this is specifically for pipe notes, not snare, based on the order of the enumeration of notetype to match sound font.
    //noteNumber = noteType.index; // very simplistic.  Might be okay.  Of course can never separate out the embellishments when play a tune
    noteNumber = NoteTypeNoteNumber[noteType];
    if (noteNumber == null) {
      print('stop here, noteType is $noteType');
    }
    log.finest('Just set the noteNumber to be $noteNumber');
  }

  @override
  String toString() {
    return 'duration: $duration, noteType: $noteType, velocity: $velocity, dynamic: $dynamic, noteNumber: $noteNumber, noteOffDeltaTimeShift: $noteOffDeltaTimeShift';
  }
}

// The order is important, because use indices to get the note number, which correspondes to the sound font numbers.
// And the parsing in NoteParser ... the ordering is important.
// Nope, no longer.  Not doing it that way.
enum NoteType {
  GdGcd,
  AGAGA,
  afgf,
  gfgf,
  gefe,
  gded,
  gdcd,
  gcdc,
  gbdb,
  gbGb,
  GdGe,
  Gdcd,
  GAGA,
  aga,
  gfg,
  fgf,
  ga,
  ea,
  eg,
  gf,
  ef,
  ge,
  Ae,
  gd,
  ed,
  gc,
  ec,
  dc,
  gb,
  eb,
  db,
  gA,
  eA,
  dA,
  GA,
  gG,
  eG, //?
  dG, //?
  a,
  g,
  f,
  e,
  d,
  c,
  b,
  A,
  G,
  rest,
  dot,
  met
}
