import 'package:petitparser/petitparser.dart';

import '../pipelang.dart';

/// See https://github.com/svenax/bagpipemusic/tree/master/others
///  Polynome app:  https://www.youtube.com/watch?v=Snm_90ols_Y
///  
/// A snare note has no sustain to it.  A bagpipe is purely sustain, broken by grace notes.
/// A snare note may have grace notes, but it's built into the name of the note, like F (flam)
/// D (drag), ...  A bagpipe note may have grace notes, but they can't be built into
/// a single letter name.  Snare notes may have articulations, which are accents of different
/// kinds.  Babpipe notes have no dynamic articulations, and so grace note names can take
/// that place.
///
/// grg8c means single grace note g followed by a "c" 8th note.
/// grip8b means a grip followed by a "b" 8th note.
/// dble4e means an "e doubling" followed by a quarter note e.
///
/// Or, maybe all I need is a name for the combination, as a single unit, preceded by the duration.
/// 8grgc
/// 8gripb
/// 4dble
///
///
/// should [a-gAG].  S
/// I had to do was record a single tap or flam or drag or ruff or buzz.
///
/// A bagpipe note is fully sustained until the next note plays, which is usually
/// a grace note.  LilyPond has the gracenotes and the principle note as separate
/// entities.  PipeLang has one entity, with parts:
///
/// {graceName}{duration}{NoteLetterName}
///
/// The NoteLetterName is one of these [GabcdefgA]
/// GraceName is one of these (and more) where X is one of the note letter names:
/// grX, dblX thrwX, Xbirl, grip, taor,  grXcad, slurX, drX? dre?, tdblX, hdblX, txtaorcrun, cad, shakeX,  hcad, darodo, txcrun, txtaorcrun, tdblX, Xgrip, trebling, Xcad,
///
/// If possible I'll have recordings of the most common grace notes
/// along with the principle note that follows it, as a single recording, and it will
/// have to be recorded with sustain.  Some of these notes could be long, like half
/// notes at a slow tempo.  If recorded as a single entity (grace notes with principle)
/// then I could treat them like I did snare notes, like ruffs, which I slide/adjust.
///




//final log = Logger('Note');

// enum NoteArticulation {
//   tenuto, // '_' small accent
//   accent, // '>' normal accent
//   marcato // '^' big accent
// }

class NoteDuration { // change this to Duration if possible, which conflicts, I think with something
  static final DefaultFirstNumber = 4;
  static final DefaultSecondNumber = 1;
  // Maybe should change the following to doubles even though I wanted a ratio of two whole numbers?
  int firstNumber; // initialize????  // trying again 10/16/20
  int secondNumber;

  NoteDuration() {
    //print('in NoteDuration() constructor and will set firstNumber and secondNumber');
    firstNumber = DefaultFirstNumber;
    secondNumber = DefaultSecondNumber;
  }
//  num firstNumber; // should be an int?
//  num secondNumber;

//  NoteDuration(); // what?  Specifying an empty constructor?  Why?
//  NoteDuration(this.firstNumber, this.secondNumber);


  String toString() {
    return 'NoteDuration: $firstNumber:$secondNumber';
  }
}

int beatFractionToTicks(num beatFraction) {
  //int ticksPerBeat = 10080
  // var durationInTicks = (Midi.ticksPerBeat * beatFraction).floor(); // why not .round()?
  var durationInTicks = (Midi.ticksPerBeat * beatFraction).round();
//  var durationInTicks = (4 * Midi.ticksPerBeat * secondNumber / firstNumber).floor(); // why not .round()?
  return durationInTicks;
}

// add ensemble (SLOT) notes too, and rolls for loops
enum NoteName {
  // I think I can change this to "Type", because I don't think it's a keyword, but maybe it is
  Gbublyb,
  Gcrune,
  Gdarodoc,
  Gfifteenthcuttinga,
  Gseventeenthcuttinga,
  Gtaora,
  Gthrwdd,
  bgripa,
  bgripd,
  birla,
  btaora,
  bublyb,
  cada,
  cadb,
  cadc,
  catchbb,
  catchcc,
  crunamce,
  crunamcfosge,
  crunamde,
  crunamdfosge,
  crune,
  daref,
  darig,
  darodoa,
  darodob,
  dbirla,
  dblA,
  dblAA,
  dblGG,
  dblaa,
  dblbb,
  dblcc,
  dbldc,
  dbldd,
  dble,
  dblee,
  dblfA,
  dblff,
  dblgg,
  dcrune,
  dree,
  fgripe,
  gbirla,
  grGcada,
  grGcadb,
  grGcadd,
  gracade,
  grecadf,
  grecadg,
  gripA,
  gripa,
  gripb,
  gripc,
  gripe,
  gripf,
  gripg,
  gripthrwdd,
  hcadG,
  hcada,
  hcadc,
  hcadd,
  hdblbb,
  hdblcc,
  hdbldd,
  hdblee,
  hdblff,
  hdblgg,
  hshakedd,
  hshakeff,
  hslurbb,
  hslurcc,
  hslurdd,
  hsluree,
  hslurff,
  partial1,
  partial4,
  pdarodob,
  prall,
  prallA,
  prallG,
  pralla,
  prallc,
  pralld,
  pralle,
  pthrwdd,
  sAG,
  sAa,
  sAb,
  sAc,
  sAd,
  sAe,
  sAf,
  sAg,
  sGa,
  sGb,
  sGc,
  sGd,
  sGe,
  saa,
  sab,
  sac,
  sae,
  sba,
  sca,
  scd,
  sdG,
  sda,
  sdb,
  sdc,
  sdd,
  seG,
  sea,
  seb,
  sec,
  sed,
  sef,
  seg,
  sfa,
  sfe,
  sfg,
  sgA,
  sgG,
  sga,
  sgb,
  sgc,
  sgd,
  sge,
  sgf,
  sgg,
  shakeAA,
  shakeaa,
  shakebb,
  shakecc,
  shakedd,
  shakeee,
  shakeff,
  shakegg,
  skip4,
  slurAA,
  sluraa,
  slurbb,
  slurcc,
  slurdd,
  sluree,
  slurff,
  slurgg,
  smallf,
  taorG,
  taora,
  taorb,
  taorc,
  tcadc,
  tdblGG,
  tdblbb,
  tdbldd,
  tdblee,
  tdblff,
  thcadG,
  thcadd,
  thrwdd,
  thrwee,
  thrwff,
  times3,
  times4,
  trebling,
  treblingd,
  trilla,
  trillc,
  trilld,
  trille,
  trillf,
  tripleAA,
  tslurbb,
  tslurdd,
  tuplet3,
  txcrunG,
  txcruna,
  txcrunama,
  txtaor,
  txtaora,
  txtaorama,
  txtaorcrun,
  txtaorcrunA,
  txtaorcrunG,
  txtaorcruna,
  txtaorcrunamG,
  txtaorcrunama,
  txtaorcrunamb,
  txtaorcrunamf,
  txtaorcrunb,
  txtaorcrunc,
  txtaorcrund,
  txtaorcrune,
  txtaorcrunf,
  txtaord,
  txtaore,
  wbirla,
  wthrwe, // ??
  a, b, c, d, e, f, g, A, G,
  met,
  rest,
  previousNoteDurationOrType
}

class Note {
  // NoteArticulation articulation;
  NoteDuration duration; // prob should have constructor construct one of these.  Of course.  also "PipeLangNoteNameValue".  can be used to calculate ticks, right?  noteTicks = (4 * ticksPerBeat) / PipeLangNoteNameValue
  NoteName noteName;
  int velocity;
  int noteNumber;
  int noteOffDeltaTimeShift;
  //int midiNoteNumber; // experiment 9/20/2020  This would be the midi soundfont number, related to NoteName

  Note() {
    //print('in Note() constructor');
    duration = NoteDuration();
    noteName = NoteName.rest;
    velocity = 0;
    noteNumber = 0;
    noteOffDeltaTimeShift = 0;
  }

  String toString() {
    // return 'Note: Articulation: $articulation, Duration: $duration, NoteName: $noteName, Dynamic: $dynamic';
    return 'Note: Duration: $duration, NoteName: $noteName';
  }

}

// ///
// /// ArticulationParser
// ///
// Parser articulationParser = (
//     char('^') | // maybe change these to pattern('/^>-_')
//     char('>') |
//     char('_') |
//     char('-')    // get rid of this one
// ).trim().map((value) { // trim()?
//   log.finest('In Articulationparser');
//   NoteArticulation articulation;
//   switch (value) {
//     case '_':
//       articulation = NoteArticulation.tenuto;
//       break;
//     case '>':
//       articulation = NoteArticulation.accent;
//       break;
//     case '^':
//       articulation = NoteArticulation.marcato;
//       break;
//     default:
//       log.info('What was that articulation? -->${value}<--');
//   }
//   log.info('Leaving Articulationparser returning articulation $articulation');
//   return articulation;
// });



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
  log.finest('In DurationParser');
  //print('in durationParser.');
  var duration = NoteDuration();
  duration.firstNumber = value[0];
  if (value[1] != null) { // prob unnec
    duration.secondNumber = value[1][1];
  }
  else {
    duration.secondNumber = 1; // wild guess that this fixes things
  }
  log.finest('Leaving DurationParser returning duration $duration');
  return duration;
});

Parser noteNameParser = (string('Gbublyb') |
        string('Gcrune') |
        string('Gdarodoc') |
        string('Gfifteenthcuttinga') |
        string('Gseventeenthcuttinga') |
        string('Gtaora') |
        string('Gthrwdd') |
        string('bgripa') |
        string('bgripd ') |
        string('birla') |
        string('btaora') |
        string('bublyb') |
        string('cada') |
        string('cadb') |
        string('cadc') |
        string('catchbb') |
        string('catchcc') |
        string('crunamce') |
        string('crunamcfosge') |
        string('crunamde') |
        string('crunamdfosge') |
        string('crune') |
        string('daref') |
        string('darig') |
        string('darodoa') |
        string('darodob') |
        string('dbirla') |
        string('dblA') |
        string('dblAA') |
        string('dblGG') |
        string('dblaa') |
        string('dblbb') |
        string('dblcc') |
        string('dbldc') |
        string('dbldd') |
        string('dble') |
        string('dblee') |
        string('dblfA') |
        string('dblff') |
        string('dblgg') |
        string('dcrune') |
        string('dree') |
        string('fgripe') |
        string('gbirla') |
        string('grGcada') |
        string('grGcadb') |
        string('grGcadd') |
        string('gracade') |
        string('grecadf') |
        string('grecadg') |
        string('gripA') |
        string('gripa') |
        string('gripb') |
        string('gripc') |
        string('gripe') |
        string('gripf') |
        string('gripg') |
        string('gripthrwdd') |
        string('hcadG') |
        string('hcada') |
        string('hcadc') |
        string('hcadd') |
        string('hdblbb') |
        string('hdblcc') |
        string('hdbldd') |
        string('hdblee') |
        string('hdblff') |
        string('hdblgg') |
        string('hshakedd') |
        string('hshakeff') |
        string('hslurbb') |
        string('hslurcc') |
        string('hslurdd') |
        string('hsluree') |
        string('hslurff') |
        string('partial1') |
        string('partial4') |
        string('pdarodob') |
        string('prall') |
        string('prallA') |
        string('prallG') |
        string('pralla') |
        string('prallc') |
        string('pralld') |
        string('pralle') |
        string('pthrwdd') |
        string('sAG') |
        string('sAa') |
        string('sAb') |
        string('sAc') |
        string('sAd') |
        string('sAe') |
        string('sAf') |
        string('sAg') |
        string('sGa') |
        string('sGb') |
        string('sGc') |
        string('sGd') |
        string('sGe') |
        string('saa') |
        string('sab') |
        string('sac') |
        string('sae') |
        string('sba') |
        string('sca') |
        string('scd') |
        string('sdG') |
        string('sda') |
        string('sdb') |
        string('sdc') |
        string('sdd') |
        string('seG') |
        string('sea') |
        string('seb') |
        string('sec') |
        string('sed') |
        string('sef') |
        string('seg') |
        string('sfa') |
        string('sfe') |
        string('sfg') |
        string('sgA') |
        string('sgG') |
        string('sga') |
        string('sgb') |
        string('sgc') |
        string('sgd') |
        string('sge') |
        string('sgf') |
        string('sgg') |
        string('shakeAA') |
        string('shakeaa') |
        string('shakebb') |
        string('shakecc') |
        string('shakedd') |
        string('shakeee') |
        string('shakeff') |
        string('shakegg') |
        string('skip4') |
        string('slurAA') |
        string('sluraa') |
        string('slurbb') |
        string('slurcc') |
        string('slurdd') |
        string('sluree') |
        string('slurff') |
        string('slurgg') |
        string('smallf') |
        string('taorG') |
        string('taora') |
        string('taorb') |
        string('taorc') |
        string('tcadc') |
        string('tdblGG') |
        string('tdblbb') |
        string('tdbldd') |
        string('tdblee') |
        string('tdblff') |
        string('thcadG') |
        string('thcadd') |
        string('thrwdd') |
        string('thrwee') |
        string('thrwff') |
        string('times3') |
        string('times4') |
        string('trebling') |
        string('trebling[d') |
        string('treblingd') |
        string('trilla') |
        string('trillc') |
        string('trilld') |
        string('trille') |
        string('trillf') |
        string('tripleAA') |
        string('tslurbb') |
        string('tslurdd') |
        string('tuplet3') |
        string('txcrunG') |
        string('txcruna') |
        string('txcrunama') |
        string('txtaor') |
        string('txtaora') |
        string('txtaorama') |
        string('txtaorcrun') |
        string('txtaorcrunA') |
        string('txtaorcrunG') |
        string('txtaorcruna') |
        string('txtaorcrunamG') |
        string('txtaorcrunama') |
        string('txtaorcrunamb') |
        string('txtaorcrunamf') |
        string('txtaorcrunb') |
        string('txtaorcrunc') |
        string('txtaorcrund') |
        string('txtaorcrune') |
        string('txtaorcrunf') |
        string('txtaord') |
        string('txtaore') |
        string('wbirla') |
        string('wthrwe') |
        string('a') |
        string('b') |
        string('c') |
        string('d') |
        string('e') |
        string('f') |
        string('g') |
        string('A') |
        string('B'))
    .trim()
    .map((value) {
  log.finest('in noteNameParser, will return $value');
  NoteName noteName;
  switch (value) {

    case 'Gbublyb':
      return NoteName.Gbublyb;
    case 'Gcrune':
      return NoteName.Gcrune;
    case 'Gdarodoc':
      return NoteName.Gdarodoc;
    case 'Gfifteenthcuttinga':
      return NoteName.Gfifteenthcuttinga;
    case 'Gseventeenthcuttinga':
      return NoteName.Gseventeenthcuttinga;
    case 'Gtaora':
      return NoteName.Gtaora;
    case 'Gthrwdd':
      return NoteName.Gthrwdd;
    case 'bgripa':
      return NoteName.bgripa;
    case 'bgripd ':
      return NoteName.bgripd ;
    case 'birla':
      return NoteName.birla;
    case 'btaora':
      return NoteName.btaora;
    case 'bublyb':
      return NoteName.bublyb;
    case 'cada':
      return NoteName.cada;
    case 'cadb':
      return NoteName.cadb;
    case 'cadc':
      return NoteName.cadc;
    case 'catchbb':
      return NoteName.catchbb;
    case 'catchcc':
      return NoteName.catchcc;
    case 'crunamce':
      return NoteName.crunamce;
    case 'crunamcfosge':
      return NoteName.crunamcfosge;
    case 'crunamde':
      return NoteName.crunamde;
    case 'crunamdfosge':
      return NoteName.crunamdfosge;
    case 'crune':
      return NoteName.crune;
    case 'daref':
      return NoteName.daref;
    case 'darig':
      return NoteName.darig;
    case 'darodoa':
      return NoteName.darodoa;
    case 'darodob':
      return NoteName.darodob;
    case 'dbirla':
      return NoteName.dbirla;
    case 'dblA':
      return NoteName.dblA;
    case 'dblAA':
      return NoteName.dblAA;
    case 'dblGG':
      return NoteName.dblGG;
    case 'dblaa':
      return NoteName.dblaa;
    case 'dblbb':
      return NoteName.dblbb;
    case 'dblcc':
      return NoteName.dblcc;
    case 'dbldc':
      return NoteName.dbldc;
    case 'dbldd':
      return NoteName.dbldd;
    case 'dble':
      return NoteName.dble;
    case 'dblee':
      return NoteName.dblee;
    case 'dblfA':
      return NoteName.dblfA;
    case 'dblff':
      return NoteName.dblff;
    case 'dblgg':
      return NoteName.dblgg;
    case 'dcrune':
      return NoteName.dcrune;
    case 'dree':
      return NoteName.dree;
    case 'fgripe':
      return NoteName.fgripe;
    case 'gbirla':
      return NoteName.gbirla;
    case 'grGcada':
      return NoteName.grGcada;
    case 'grGcadb':
      return NoteName.grGcadb;
    case 'grGcadd':
      return NoteName.grGcadd;
    case 'gracade':
      return NoteName.gracade;
    case 'grecadf':
      return NoteName.grecadf;
    case 'grecadg':
      return NoteName.grecadg;
    case 'gripA':
      return NoteName.gripA;
    case 'gripa':
      return NoteName.gripa;
    case 'gripb':
      return NoteName.gripb;
    case 'gripc':
      return NoteName.gripc;
    case 'gripe':
      return NoteName.gripe;
    case 'gripf':
      return NoteName.gripf;
    case 'gripg':
      return NoteName.gripg;
    case 'gripthrwdd':
      return NoteName.gripthrwdd;
    case 'hcadG':
      return NoteName.hcadG;
    case 'hcada':
      return NoteName.hcada;
    case 'hcadc':
      return NoteName.hcadc;
    case 'hcadd':
      return NoteName.hcadd;
    case 'hdblbb':
      return NoteName.hdblbb;
    case 'hdblcc':
      return NoteName.hdblcc;
    case 'hdbldd':
      return NoteName.hdbldd;
    case 'hdblee':
      return NoteName.hdblee;
    case 'hdblff':
      return NoteName.hdblff;
    case 'hdblgg':
      return NoteName.hdblgg;
    case 'hshakedd':
      return NoteName.hshakedd;
    case 'hshakeff':
      return NoteName.hshakeff;
    case 'hslurbb':
      return NoteName.hslurbb;
    case 'hslurcc':
      return NoteName.hslurcc;
    case 'hslurdd':
      return NoteName.hslurdd;
    case 'hsluree':
      return NoteName.hsluree;
    case 'hslurff':
      return NoteName.hslurff;
    case 'partial1':
      return NoteName.partial1;
    case 'partial4':
      return NoteName.partial4;
    case 'pdarodob':
      return NoteName.pdarodob;
    case 'prall':
      return NoteName.prall;
    case 'prallA':
      return NoteName.prallA;
    case 'prallG':
      return NoteName.prallG;
    case 'pralla':
      return NoteName.pralla;
    case 'prallc':
      return NoteName.prallc;
    case 'pralld':
      return NoteName.pralld;
    case 'pralle':
      return NoteName.pralle;
    case 'pthrwdd':
      return NoteName.pthrwdd;
    case 'sAG':
      return NoteName.sAG;
    case 'sAa':
      return NoteName.sAa;
    case 'sAb':
      return NoteName.sAb;
    case 'sAc':
      return NoteName.sAc;
    case 'sAd':
      return NoteName.sAd;
    case 'sAe':
      return NoteName.sAe;
    case 'sAf':
      return NoteName.sAf;
    case 'sAg':
      return NoteName.sAg;
    case 'sGa':
      return NoteName.sGa;
    case 'sGb':
      return NoteName.sGb;
    case 'sGc':
      return NoteName.sGc;
    case 'sGd':
      return NoteName.sGd;
    case 'sGe':
      return NoteName.sGe;
    case 'saa':
      return NoteName.saa;
    case 'sab':
      return NoteName.sab;
    case 'sac':
      return NoteName.sac;
    case 'sae':
      return NoteName.sae;
    case 'sba':
      return NoteName.sba;
    case 'sca':
      return NoteName.sca;
    case 'scd':
      return NoteName.scd;
    case 'sdG':
      return NoteName.sdG;
    case 'sda':
      return NoteName.sda;
    case 'sdb':
      return NoteName.sdb;
    case 'sdc':
      return NoteName.sdc;
    case 'sdd':
      return NoteName.sdd;
    case 'seG':
      return NoteName.seG;
    case 'sea':
      return NoteName.sea;
    case 'seb':
      return NoteName.seb;
    case 'sec':
      return NoteName.sec;
    case 'sed':
      return NoteName.sed;
    case 'sef':
      return NoteName.sef;
    case 'seg':
      return NoteName.seg;
    case 'sfa':
      return NoteName.sfa;
    case 'sfe':
      return NoteName.sfe;
    case 'sfg':
      return NoteName.sfg;
    case 'sgA':
      return NoteName.sgA;
    case 'sgG':
      return NoteName.sgG;
    case 'sga':
      return NoteName.sga;
    case 'sgb':
      return NoteName.sgb;
    case 'sgc':
      return NoteName.sgc;
    case 'sgd':
      return NoteName.sgd;
    case 'sge':
      return NoteName.sge;
    case 'sgf':
      return NoteName.sgf;
    case 'sgg':
      return NoteName.sgg;
    case 'shakeAA':
      return NoteName.shakeAA;
    case 'shakeaa':
      return NoteName.shakeaa;
    case 'shakebb':
      return NoteName.shakebb;
    case 'shakecc':
      return NoteName.shakecc;
    case 'shakedd':
      return NoteName.shakedd;
    case 'shakeee':
      return NoteName.shakeee;
    case 'shakeff':
      return NoteName.shakeff;
    case 'shakegg':
      return NoteName.shakegg;
    case 'skip4':
      return NoteName.skip4;
    case 'slurAA':
      return NoteName.slurAA;
    case 'sluraa':
      return NoteName.sluraa;
    case 'slurbb':
      return NoteName.slurbb;
    case 'slurcc':
      return NoteName.slurcc;
    case 'slurdd':
      return NoteName.slurdd;
    case 'sluree':
      return NoteName.sluree;
    case 'slurff':
      return NoteName.slurff;
    case 'slurgg':
      return NoteName.slurgg;
    case 'smallf':
      return NoteName.smallf;
    case 'taorG':
      return NoteName.taorG;
    case 'taora':
      return NoteName.taora;
    case 'taorb':
      return NoteName.taorb;
    case 'taorc':
      return NoteName.taorc;
    case 'tcadc':
      return NoteName.tcadc;
    case 'tdblGG':
      return NoteName.tdblGG;
    case 'tdblbb':
      return NoteName.tdblbb;
    case 'tdbldd':
      return NoteName.tdbldd;
    case 'tdblee':
      return NoteName.tdblee;
    case 'tdblff':
      return NoteName.tdblff;
    case 'thcadG':
      return NoteName.thcadG;
    case 'thcadd':
      return NoteName.thcadd;
    case 'thrwdd':
      return NoteName.thrwdd;
    case 'thrwee':
      return NoteName.thrwee;
    case 'thrwff':
      return NoteName.thrwff;
    case 'times3':
      return NoteName.times3;
    case 'times4':
      return NoteName.times4;
    case 'trebling':
      return NoteName.trebling;
    case 'treblingd':
      return NoteName.treblingd;
    case 'trilla':
      return NoteName.trilla;
    case 'trillc':
      return NoteName.trillc;
    case 'trilld':
      return NoteName.trilld;
    case 'trille':
      return NoteName.trille;
    case 'trillf':
      return NoteName.trillf;
    case 'tripleAA':
      return NoteName.tripleAA;
    case 'tslurbb':
      return NoteName.tslurbb;
    case 'tslurdd':
      return NoteName.tslurdd;
    case 'tuplet3':
      return NoteName.tuplet3;
    case 'txcrunG':
      return NoteName.txcrunG;
    case 'txcruna':
      return NoteName.txcruna;
    case 'txcrunama':
      return NoteName.txcrunama;
    case 'txtaor':
      return NoteName.txtaor;
    case 'txtaora':
      return NoteName.txtaora;
    case 'txtaorama':
      return NoteName.txtaorama;
    case 'txtaorcrun':
      return NoteName.txtaorcrun;
    case 'txtaorcrunA':
      return NoteName.txtaorcrunA;
    case 'txtaorcrunG':
      return NoteName.txtaorcrunG;
    case 'txtaorcruna':
      return NoteName.txtaorcruna;
    case 'txtaorcrunamG':
      return NoteName.txtaorcrunamG;
    case 'txtaorcrunama':
      return NoteName.txtaorcrunama;
    case 'txtaorcrunamb':
      return NoteName.txtaorcrunamb;
    case 'txtaorcrunamf':
      return NoteName.txtaorcrunamf;
    case 'txtaorcrunb':
      return NoteName.txtaorcrunb;
    case 'txtaorcrunc':
      return NoteName.txtaorcrunc;
    case 'txtaorcrund':
      return NoteName.txtaorcrund;
    case 'txtaorcrune':
      return NoteName.txtaorcrune;
    case 'txtaorcrunf':
      return NoteName.txtaorcrunf;
    case 'txtaord':
      return NoteName.txtaord;
    case 'txtaore':
      return NoteName.txtaore;
    case 'wbirla':
      return NoteName.wbirla;
    case 'wthrwe':
      return NoteName.wthrwe;
    case 'a':
      return NoteName.a;
    case 'b':
      return NoteName.b;
    case 'c':
      return NoteName.c;
    case 'd':
      return NoteName.d;
    case 'e':
      return NoteName.e;
    case 'f':
      return NoteName.f;
    case 'g':
      return NoteName.g;
    case 'A':
      return NoteName.A;
    case 'G':
      return NoteName.G;
    default:
      return 'what kind of note was that?';
  }
  //return value;
});

///
/// TypeParser
///
// Parser typeParser = pattern('TtFfDdZzXxYyVvRMNnBbr.').trim().map((value) { // trim?
//   log.finest('In TypeParser');
//   NoteName noteName;
//   switch (value) {
//     case 'T':
//       noteName = NoteName.tapRight;
//       break;
//     case 't':
//       noteName = NoteName.tapLeft;
//       break;
//     case 'F':
//       noteName = NoteName.flamRight;
//       break;
//     case 'f':
//       noteName = NoteName.flamLeft;
//       break;
//     case 'D':
//       noteName = NoteName.dragRight;
//       break;
//     case 'd':
//       noteName = NoteName.dragLeft;
//       break;
//     case 'Z':
//       noteName = NoteName.buzzRight;
//       break;
//     case 'z':
//       noteName = NoteName.buzzLeft;
//       break;
//     case 'X':
//       noteName = NoteName.tuzzRight;
//       break;
//     case 'x':
//       noteName = NoteName.tuzzLeft;
//       break;
//     case 'Y':
//       noteName = NoteName.ruff2Right;
//       break;
//     case 'y':
//       noteName = NoteName.ruff2Left;
//       break;
//     case 'V':
//       noteName = NoteName.ruff3Right;
//       break;
//     case 'v':
//       noteName = NoteName.ruff3Left;
//       break;
//     case 'R':
//       noteName = NoteName.roll;
//       break;
//     case 'M':
//       noteName = NoteName.met;
//       break;
//     case 'B': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteName = NoteName.bassRight;
//       break;
//     case 'b':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteName = NoteName.bassLeft;
//       break;
//     case 'N': // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteName = NoteName.tenorRight;
//       break;
//     case 'n':  // wrong to give an instrument just a note type like this because then you can't specify flams, rolls, and other strokes
//       noteName = NoteName.tenorLeft;
//       break;
//     case 'r':
//       noteName = NoteName.rest;
//       break;
//     case '.':
//       noteName = NoteName.previousNoteDurationOrType;
//       break;
//     default:
//       log.info('Hey, this shoulda been a failure cause got -->${value[0]}<-- and will return null');
//       break;
//   }
//   log.info('Leaving TypeParser returning noteName $noteName');
//   return noteName;
// });

///
/// NoteParser
///
Parser noteParser = (
    (durationParser & noteNameParser) |
    (durationParser) |
    (noteNameParser)
).trim().map((valuesOrValue) { // trim?
  log.finest('\t\tIn NoteParser and valuesOrValue is $valuesOrValue');
  var note = Note();

  if (valuesOrValue == null) {  //
    log.warning('does this ever happen?  Hope not.  Perhaps if no match?');
  }
  // Handle cases ABC, AB, AC, BC
  if (valuesOrValue is List) {
    for (var value in valuesOrValue) {
      if (value is NoteDuration) { // B
        note.duration.firstNumber = value.firstNumber;
        note.duration.secondNumber = value.secondNumber; // check;
      }
      if (value is NoteName) {
        note.noteName = value;
      }
    }
  }
  else { // Handle cases A, B, C
    if (valuesOrValue is NoteDuration) { // B   Happens????????????????????????????????
      note.duration.firstNumber = valuesOrValue.firstNumber;
      note.duration.secondNumber = valuesOrValue.secondNumber; // check;
    }
    else if (valuesOrValue is NoteName) { // C
      note.noteName = valuesOrValue;
    }
  }

  log.finest('Leaving NoteParser returning note -->$note<--');
  return note;
});
