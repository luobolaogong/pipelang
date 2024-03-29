import 'package:petitparser/petitparser.dart';
import '../pipelang.dart';


/// This is the top level parser, where it all starts.  But it all happens behind the scenes.  It builds the parse tree first
/// and then tries to apply the input to it, working from bottom up, I think, but it doesn't execute ANY of the actions of
/// the parser until the parsing analysis comes to an end of some kind, with an error, or success, and then it starts
/// doing the actions, I think.  So, the actions cannot influence the parse, it seems.
///
/// ScoreParser
Parser scoreParser = ((pipeNoteParser | commentParser | markerParser | textParser | trackParser | channelParser | timeSigParser | tempoParser | dynamicParser | dynamicRampParser).plus()).trim().end().map((values) {    // trim()?
  log.finest('\t\t\t\t\t\tIn Scoreparser, and parsed this many elements: ${values.length}, and will now add values from parse result list to score.elements');
  var score = Score();
  if (values is List) {
    for (var value in values) {
      log.finest('\t\t\t\tIn loop of values after parsing a score, and will add to score.elements value: -->$value<--');
      score.elements.add(value);
      //log.finest('ScoreParser, Now score.elements has this many elements: ${score.elements.length}');
    }
  }
  else { // I don't think this happens when there's only one value.  It's still in a list
    log.info('Did not get a list, got this: -->$values<--');
    score.elements.add(values); // right? new
  }
  log.finest('Leaving Scoreparser returning score in parsed and objectified form.');
  return score;
});


///
/// NoteParser
/// I keep changing the definition of what a note is.  Technically it has atleast 3parts, but for now it has two main parts:
/// 1.  Duration
/// 2.  optional Embellishment (named grace notes), followed by required Melody note name, and the name can be '.'
///
/// The letters that make up the string of grace note letters plus the melody note letter are used
/// as a group to designate a midi note number.  There could be a mapping of a subset of all possible combination letters to
/// a note number, or there could be an equation that generates an index into a sound font note number array.
///
/// However, if we're doing "shorthands", then maybe we'd want to parse the letters into their embellishment part and
/// their melody part.  But I think that's more work than is necessary.  Shorthands are not that useful, but okay.
///
/// So, at least for now, we're sticking to two parts: duration and pitch names for embellishments and melody and
/// we'll allow for a shorthand pass.
///
/// The following are notes:
/// 1.  <duration><letters>, for example 8gA and 8A
/// 2.  <letters>, for example "gA", and "A", where previous note's duration, or default duration is used.  Also "." is okay?
/// 3.  <duration>, for example "8", where previous note's letters are used.  This is somewhat unlikely
///
///
// Parser noteParser = (
//     (durationParser & pipeNoteNameParser & noteNameParser) |    // all three
//     (pipeNoteNameParser & noteNameParser) |                     // use previous duration
//     noteNameParser |                     // use previous duration but not embellishment
//     durationParser   // use previous embellishment and note
Parser pipeNoteParser = ( // change to pipeNoteParser ???
    (durationParser & pipeNoteNameParser) |    // Case "A B"
    durationParser |                                       // Case A, use previous embellishment and note
    pipeNoteNameParser                        // Case B, use previous duration
).trim().map((valuesOrValue) { // trim?
  // print('\t\t\tIN PIPE NOTE PARSER!');
  log.finer('\t\tIn pipeNoteParser and valuesOrValue is $valuesOrValue'); // huh?
  var note = Note();

  if (valuesOrValue == null) {  //
    log.warning('does this ever happen?  Hope not.  Perhaps if no match?');
  }
  // Looks like if we parse duration followed by embellishment, then it's an array/list, and so we have to loop
  if (valuesOrValue is List) {
    for (var value in valuesOrValue) { // Case "A B" -- duration followed by letters
      if (value is NoteDuration) { // B
        note.duration.firstNumber = value.firstNumber;
        note.duration.secondNumber = value.secondNumber; // check;
      }
      if (value is NoteType) {
        note.noteType = value;
      }
    }
  }
  else if (valuesOrValue is NoteDuration) { // case "A", leaving embellishmentAndNote null
    note.duration.firstNumber = valuesOrValue.firstNumber;
    note.duration.secondNumber = valuesOrValue.secondNumber; // check;
  }
  else if (valuesOrValue is NoteType) { // case "B", leaving duration null
    note.noteType = valuesOrValue;
  }
  else {
    log.severe('got something in note parser that was not a duration or embellishmentNoteName thing: $valuesOrValue');
  }
  log.finest('Leaving pipeNoteParser returning note -->$note<--');
  return note;
});

///
/// commentParser
///
Parser commentParser = (
    string('//') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In commentParser');
  var comment = Comment();
  comment.comment = value.trim(); // why trim a second time?  But we need to.
  log.finest('Leaving CommentParser returning -->$comment<--');
  return comment;
});



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

// something's wrong here.  Looks strange.
// Also, put in own file?  Maybe, although it's a kind of dynamic marking.
// But still, it's kinda a pseudo element.
// All of these tokens map down into a single DynamicRamp object, but all its fields are null
Parser dynamicRampParser = (
    string('/>') |
    string('/<') |
    string('/dim') |
    string('/decresc') |
    string('/cresc')
).trim().map((value) {
  log.finest('In dynamicRampParser, and the value was $value');
  DynamicRamp dynamicRamp;
  switch (value) {
    case '/>':
    case '/<':
    case '/cresc':
    case '/dim':
    case '/decresc':
      dynamicRamp =  DynamicRamp();
      break;
  }
  log.finest('Leaving dynamicRampParser returning a DynamicRamp object $dynamicRamp');
  return dynamicRamp;
});

///
/// DynamicParser
///
Parser dynamicParser = (
    string('/mf') |
    string('/mp') |
    string('/ppp') |
    string('/pp') |
    string('/p') |
    string('/fff') |
    string('/ff') |
    string('/f') |
    string('/dd')
).trim().map((value) { // trim?  Yes!  Makes a difference
  log.finest('In Dynamicparser');
  Dynamic dynamic;
  switch (value) {
    case '/ppp':
      dynamic = Dynamic.ppp;
      break;
    case '/pp':
      dynamic =  Dynamic.pp;
      break;
    case '/p':
      dynamic =  Dynamic.p;
      break;
    case '/mp':
      dynamic =  Dynamic.mp;
      break;
    case '/mf':
      dynamic =  Dynamic.mf;
      break;
    case '/f':
      dynamic =  Dynamic.f;
      break;
    case '/ff':
      dynamic =  Dynamic.ff;
      break;
    case '/fff':
      dynamic =  Dynamic.fff;
      break;
    case '/dd':
      dynamic =  Dynamic.dd;
      break;
  }
  log.finest('Leaving DynamicParser returning value $dynamic');
  return dynamic;
});


///
/// markerParser
///
Parser markerParser = (
    string('/marker') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In markerParser');
  var marker = Marker();
  var textPart = value.trim().substring(7);
  marker.text = textPart;
  log.finest('Leaving markerParser returning -->$marker<--');
  return marker;
});

// Of course the order is important here.  Want to parse the longest
// string before a shorter one.

///////////////////////////////// ADD HERE CHECK HERE 1/5 //////////////////////////

Parser pipeNoteNameParser = (
    string('gAGAGA') |
    string('GdGcd') |
    string('GdGeA') | // new
    string('AGAGA') |
    string('GdGa') |
    string('agfg') | // new
    string('afgf') |
    string('gfgf') |
    string('gefe') |
    string('gdee') | // new/weird
    string('GdGe') |
    string('gded') |
    string('Gded') |
    string('gdcd') |
    string('Gdcd') |
    string('gdGd') |
    string('gcdc') |
    string('GdGc') | // new
    string('gbdb') |
    string('Gbdb') |
    string('GdGb') | // new
    string('gbGb') |
    string('gAdA') | // new
    string('GAGA') |
    string('GbGA') | // new
    string('gGdG') | // new
    string('aga') |
    string('dcd') |
    string('cdc') |
    string('gfg') |
    string('fgf') |
    string('efe') |
    string('ae') | // new
    string('ga') |
    string('ag') | // new
    string('fg') |
    string('ea') |
    string('eg') |
    string('af') |
    string('gf') |
    string('ef') |
    string('ge') |
    string('Ae') |
    string('Ge') | // new?
    string('Gc') | // new
    string('gd') |
    string('ed') |
    string('cd') |
    string('gc') |
    string('ec') |
    string('dc') |
    string('ac') | // new
    string('gb') |
    string('eb') |
    string('db') |
    string('Gb') | // new
    string('gA') | // used? yes.
    string('eA') |
    string('dA') |
    string('GA') |
    string('gG') | // ??
    string('eG') |
    string('dG') |
    string('aG') |
    string('a') |
    string('g') |
    string('f') |
    string('e') |
    string('d') |
    string('c') |
    string('b') |
    string('A') |
    string('G') |
    string('M') |
    string('.') |
    string('r')
).trim().map((value) {
  log.finest('entering pipeNoteNameParser, with string value $value');
  NoteType noteType;

  ///////////////////////////////// ADD HERE CHECK HERE 2/5 //////////////////////////

  switch (value) {
    case 'gAGAGA':
      noteType = NoteType.gAGAGA;
      break;//.
    case 'GdGcd':
      noteType = NoteType.GdGcd;
      break;//.
    case 'GdGeA': // new
      noteType = NoteType.GdGeA;
      break;//.
    case 'AGAGA':
      noteType = NoteType.AGAGA;
      break;//.
    case 'GdGa':
      noteType = NoteType.GdGa;
      break;//.
    case 'agfg': // new
      noteType = NoteType.agfg;
      break;//.
    case 'GdGb':
      noteType = NoteType.GdGb;
      break;//.
    case 'GdGc':
      noteType = NoteType.GdGc;
      break;//.
    case 'GbGA':
      noteType = NoteType.GbGA;
      break;//.
    case 'gGdG':
      noteType = NoteType.gGdG;
      break;//.
    case 'afgf':
      noteType = NoteType.afgf;
      break;//.
    case 'gfgf':
      noteType = NoteType.gfgf;
      break;//.
    case 'gefe':
      noteType = NoteType.gefe;
      break;//.
    case 'gded':
      noteType = NoteType.gded;
      break;//.
    case 'gdee': // new/weird
      noteType = NoteType.gdee;
      break;//.
    case 'gdGd':    // new
      noteType = NoteType.gdGd;
      break;//.
    case 'gdcd':
      noteType = NoteType.gdcd;
      break;//.
    case 'gcdc':
      noteType = NoteType.gcdc;
      break;//.
    case 'gbdb':
      noteType = NoteType.gbdb;
      break;//.
    case 'Gbdb':
      noteType = NoteType.Gbdb;
      break;//.
    case 'gbGb':
      noteType = NoteType.gbGb;
      break;//.
    case 'GdGe':
      noteType = NoteType.GdGe;
      break;//.
    case 'Gdcd':
      noteType = NoteType.Gdcd;
      break;//.
    case 'GAGA':
      noteType = NoteType.GAGA;
      break;//.
    case 'gAdA':
      noteType = NoteType.gAdA;
      break;//.
    case 'aga':
      noteType = NoteType.aga;
      break;//.
    case 'cdc':
      noteType = NoteType.cdc;
      break;//.
    case 'dcd':
      noteType = NoteType.dcd;
      break;//.
    case 'gfg':
      noteType = NoteType.gfg;
      break;//.
    case 'fgf':
      noteType = NoteType.fgf;
      break;//.
    case 'efe':
      noteType = NoteType.efe;
      break;//.
    case 'ga':
      noteType = NoteType.ga;
      break;//.
    case 'ea':
      noteType = NoteType.ea;
      break;//.
    case 'eg':
      noteType = NoteType.eg;
      break;//.
    case 'fg':
      noteType = NoteType.fg;
      break;//.
    case 'ag':
      noteType = NoteType.ag;
      break;//.
    case 'gf':
      noteType = NoteType.gf;
      break;//.
    case 'ef':
      noteType = NoteType.ef;
      break;//.
    case 'af':
      noteType = NoteType.af;
      break;//.
    case 'ae': // new
      noteType = NoteType.ae;
      break;//.
    case 'ge':
      noteType = NoteType.ge;
      break;//.
    case 'Ae':
      noteType = NoteType.Ae;
      break;//.
    case 'Ge': // new
      noteType = NoteType.Ge;
      break;//.
    case 'gd':
      noteType = NoteType.gd;
      break;//.
    case 'ed':
      noteType = NoteType.ed;
      break;//.
    case 'cd':
      noteType = NoteType.cd;
      break;//.
    case 'gc':
      noteType = NoteType.gc;
      break;//.
    case 'ec':
      noteType = NoteType.ec;
      break;//.
    case 'dc':
      noteType = NoteType.dc;
      break;//.
    case 'ac': // new
      noteType = NoteType.ac;
      break;//.
    case 'Gc': // new
      noteType = NoteType.Gc; // new
      break;//.
    case 'gb':
      noteType = NoteType.gb;
      break;//.
    case 'eb':
      noteType = NoteType.eb;
      break;//.
    case 'db':
      noteType = NoteType.db;
      break;//.
    case 'Gb': // new
      noteType = NoteType.Gb;
      break;//.
    case 'gA':
      noteType = NoteType.gA;
      break;//.
    case 'eA':
      noteType = NoteType.eA;
      break;//.
    case 'dA':
      noteType = NoteType.dA;
      break;//.
    case 'gA':
      noteType = NoteType.gA;
      break;//.
    case 'GA':
      noteType = NoteType.GA;
      break;//.
    case 'gG': // ??
      noteType = NoteType.gG;
      break;//.
    case 'eG':
      noteType = NoteType.eG;
      break;//.
    case 'dG':
      noteType = NoteType.dG;
      break;//.
    case 'aG':
      noteType = NoteType.aG;
      break;//.
    case 'a':
      noteType = NoteType.a;
      break; //.
    case 'g':
      noteType = NoteType.g;
      break;//.
    case 'f':
      noteType = NoteType.f;
      break;//.
    case 'e':
      noteType = NoteType.e;
      break;//.
    case 'd':
      noteType = NoteType.d;
      break;//.
    case 'c':
      noteType = NoteType.c;
      break;//.
    case 'b':
      noteType = NoteType.b;
      break;//.
    case 'A':
      noteType = NoteType.A;
      break;//.
    case 'G':
      noteType = NoteType.G;
      break;//.
    case 'M':
      noteType = NoteType.met;
      break;
    case '.':
      noteType = NoteType.dot;
      break;
    case 'r':
      noteType = NoteType.rest;
      break;
    default:
      log.severe('What happened what is this embellishmentandnotename?');
      break;
  }
  log.finest('Leaving pipeNoteNameParser returning noteType: $noteType');
  return noteType;
});


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
Parser tempoParser = (
    string('/tempo').trim() & (durationParser.trim() & char('=').trim()).optional().trim() & wholeNumberParser
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

///
/// textParser
///
Parser textParser = (
    string('/text') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In textParser and value is -->$value<--');
  var text = Text();
  text.text = value.trim().substring(6);
  log.finest('Leaving textParser returning -->$text<--');
  return text;
});

///
/// timeSigParser
///
Parser timeSigParser = ( // what about whitespace?
//    string('/time').trim() & wholeNumberParser.trim() & char('/').trim() & wholeNumberParser.trim()
    string('/time').trim() & wholeNumberParser.trim() & char('/').trim() & wholeNumberParser

).trim().map((value) {
  log.finest('In timeSigParser');
  var timeSig = TimeSig();
  timeSig.numerator = value[1];
  timeSig.denominator = value[3];
  log.finest('Leaving TimeSigParser returning value $timeSig');
  return timeSig; // this element eventually goes into a list of other elements that make up a score
});

///
/// trackParser
///
final trackId = (letter() & word().star()).flatten();
Parser trackParser = (
    (string('/track') | string('/staff') | string('/stave')).trim()
    & trackId).trim().map((value) {
  log.finest('In trackParser and value is -->$value<--');
  var track = Track();
  track.id = trackStringToId(value[1]);
  if (track.id == TrackId.pipes || track.id == TrackId.chanter) {
    log.fine('switch to pipes parser, otherwise dont use it');
  }
  log.finest('Leaving trackParser returning value $track');
  return track;
});

///
/// channelParser
///
Parser channelParser = (
    (string('/channel') | string('/chan') | string('/program')).trim()
    & wholeNumberParser.trim()).trim().map((value) {
  log.finest('In channelParser and value is -->$value<--');
  var channel = Channel();
  channel.number = value[1];
  log.finest('Leaving channelParser returning value $channel');
  return channel;
});

