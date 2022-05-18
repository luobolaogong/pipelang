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
///////////////////////////////// ADD HERE CHECK HERE 5/5 //////////////////////////
  var NoteTypeNoteNumber = { // sort these better
    NoteType.gAGAGA: 112,
    NoteType.GdGcd: 115,
    NoteType.GdGeA: 112, // new
    NoteType.AGAGA: 112,
    NoteType.GdGa: 119,
    NoteType.agfg: 118, // new
    NoteType.afgf: 117,
    NoteType.gfgf: 117,
    NoteType.gefe: 116,
    NoteType.GdGe: 116,
    NoteType.gdee: 116, // new/weird
    NoteType.gded: 115,
    NoteType.gdGd: 115, // new
    NoteType.gdcd: 115,
    NoteType.Gdcd: 115,
    NoteType.gcdc: 114,
    NoteType.GdGc: 114, // new
    NoteType.gbdb: 113,
    NoteType.gbGb: 113, // kinda new?
    NoteType.Gbdb: 113,
    NoteType.GdGb: 113, // new
    //NoteType.gdGb: 113, // I may have screwed something up when editing.  Maybe missing a 4 note combination similar to this
    NoteType.gAdA: 112, // new
    NoteType.GAGA: 112,
    NoteType.GbGA: 112, // new
    NoteType.gGdG: 111, // new
    NoteType.aga: 119,
    NoteType.gfg: 118,
    NoteType.fgf: 117,
    NoteType.efe: 116,
    NoteType.dcd: 115,
    NoteType.cdc: 114,
    NoteType.ga: 119,
    NoteType.ea: 119,
    NoteType.eg: 118,
    NoteType.fg: 118, // new
    NoteType.ag: 118, // new
    NoteType.af: 117,
    NoteType.gf: 117,
    NoteType.ef: 117,
    NoteType.ae: 116, // new
    NoteType.ge: 116,
    NoteType.Ae: 116, // never happens???????
    NoteType.Ge: 116, // new
    NoteType.gd: 115,
    NoteType.ed: 115,
    NoteType.cd: 115,
    NoteType.gc: 114,
    NoteType.ec: 114,
    NoteType.dc: 114,
    NoteType.ac: 114, // new
    NoteType.Gc: 114, // new
    NoteType.gb: 113,
    NoteType.Gb: 113,
    NoteType.eb: 113,
    NoteType.db: 113,
    NoteType.gA: 112,
    NoteType.eA: 112,
    NoteType.dA: 112,
    NoteType.GA: 112,
    NoteType.gG: 111, //?
    NoteType.eG: 111,
    NoteType.dG: 111,
    NoteType.aG: 111,
    NoteType.a: 119,
    NoteType.g: 118,
    NoteType.f: 117,
    NoteType.e: 116,
    NoteType.d: 115,
    NoteType.c: 114,
    NoteType.b: 113,
    NoteType.A: 112,
    NoteType.G: 111,
    // NoteType.gAGAGA: 2,
    // NoteType.GdGcd: 5,
    // NoteType.AGAGA: 2,
    // NoteType.GdGa: 9,
    // NoteType.afgf: 7,
    // NoteType.gfgf: 7,
    // NoteType.gefe: 6,
    // NoteType.GdGe: 6,
    // NoteType.gded: 5,
    // NoteType.gdcd: 5,
    // NoteType.Gdcd: 5,
    // NoteType.gcdc: 4,
    // NoteType.gbdb: 3,
    // NoteType.Gbdb: 3,
    // NoteType.gbGb: 3,
    // NoteType.GAGA: 2,
    // NoteType.aga: 9,
    // NoteType.gfg: 8,
    // NoteType.fgf: 7,
    // NoteType.efe: 6,
    // NoteType.dcd: 5,
    // NoteType.cdc: 4,
    // NoteType.ga: 9,
    // NoteType.ea: 9,
    // NoteType.eg: 8,
    // NoteType.af: 7,
    // NoteType.gf: 7,
    // NoteType.ef: 7,
    // NoteType.ge: 6,
    // NoteType.Ae: 6,
    // NoteType.gd: 5,
    // NoteType.ed: 5,
    // NoteType.cd: 5,
    // NoteType.gc: 4,
    // NoteType.ec: 4,
    // NoteType.dc: 4,
    // NoteType.gb: 3,
    // NoteType.eb: 3,
    // NoteType.db: 3,
    // NoteType.gA: 2,
    // NoteType.eA: 2,
    // NoteType.dA: 2,
    // NoteType.GA: 2,
    // NoteType.gG: 1, //?
    // NoteType.eG: 1,
    // NoteType.dG: 1,
    // NoteType.aG: 1,
    // NoteType.a: 9,
    // NoteType.g: 8,
    // NoteType.f: 7,
    // NoteType.e: 6,
    // NoteType.d: 5,
    // NoteType.c: 4,
    // NoteType.b: 3,
    // NoteType.A: 2,
    // NoteType.G: 1,

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
      print('stop here, noteNumber is null, noteType is $noteType');
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

///////////////////////////////// ADD HERE CHECK HERE 3/5 //////////////////////////

enum NoteType {
  gAGAGA,
  GdGcd,
  GdGeA, // new
  AGAGA,
  GdGa,
  agfg, // new
  afgf,
  gfgf,
  gefe,
  gded,
  gdee, // new weird
  gdcd,
  gcdc,
  gbdb,
  gdGd, // new
  GdGb, // new
  GdGc, // new
  GbGA, // new
  gGdG, // new
  gbGb,
  GdGe,
  Gdcd,
  Gbdb,
  GAGA,
  gAdA,
  aga,
  gfg,
  fgf,
  efe,
  dcd,
  cdc,
  ga,
  ea,
  ag, // new
  fg, // new
  eg,
  af,
  gf,
  ef,
  ge,
  ae, // new
  Ae,
  Ge, // new
  gd,
  ed,
  cd,
  gc,
  ec,
  dc,
  ac, // new
  Gc, // new
  gb,
  eb,
  db,
  Gb, // new
  gA,
  eA,
  dA,
  GA,
  gG,
  eG, //?
  dG, //?
  aG, //?
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
