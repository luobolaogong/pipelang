import '../pipelang.dart';
class Note {
  //NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "SnareLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / SnareLangNoteNameValue
  NoteType noteType;
  int velocity;
  Dynamic dynamic;
  int noteNumber;
  int noteOffDeltaTimeShift;

  Note() {
    duration = NoteDuration();
    noteType = NoteType.rest; // experiment
    dynamic = Dynamic.mf; // right?  Maybe right for snare, but not for pipes?
    noteOffDeltaTimeShift = 0;
  }

  @override
  String toString() {
    return 'NoteToString: Dynamic: $dynamic';
  }
}

enum NoteType {
  rest,
  G, A, b, c, d, e, f, g, a,
  // single gracenotes
  Ga,
  gA,
  ge,
  gc,
  gf,
  gb,
  dc,
  ea,
  dA,
  gd,
  ga,
  // doublings
  GAGA,
  gefe,
  gcdc,
  aga,
  gfg,
  gbdb,
  gfgf,
  // Throws
  GdGcd, // (\thrwd d maybe),




  tapRight,
  tapLeft,
  tapUnison,
  flamRight,
  flamLeft,
  flamUnison,
  openDragRight, // not a 2-stroke ruff, and not a dead drag.  No recording yet
  openDragLeft,
  dragRight,
  dragLeft,
  dragUnison,
  buzzRight, // this can be looped
  buzzLeft, // this can be looped
  tuzzLeft,
  tuzzRight,
  tuzzUnison,
  ruff2Left, // how often do these show up?  Prob almost never.  Instead, an "open drag"
  ruff2Right,
  ruff2Unison,
  ruff3Left,
  ruff3Right,
  ruff3Unison,
  roll, // prob need to add roll recordings for snare and pad.  Currently only have SLOT recording I think
  tenorLeft,
  tenorRight,
  bassLeft,
  bassRight,






  dot, // experiment
  met // was M
}
