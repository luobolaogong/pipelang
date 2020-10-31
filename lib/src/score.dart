import 'dart:io';
import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';


class Score {
  List elements = [];
  TimeSig firstTimeSig;
  Tempo firstTempo;
  num tempoScalar = 1; // new
  Track firstTrack;

  String toString() {
    return 'Score: ${elements.toString()}'; // could do a forEach and collect each element into a string with \n between each
  }

  static Result loadAndParse(List<String> scoresPaths, CommandLine commandLine) {
    var scoresStringBuffer = StringBuffer();
    for (var filePath in scoresPaths) {
      log.info('Loading file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        log.severe('File does not exist at "${inputFile.path}", exiting...');
        exit(42);
        continue;
      }
      var fileContents = inputFile.readAsStringSync(); // per line better?
      if (fileContents.isEmpty) {
        log.info('File ${filePath} appears to be empty.  Skipping it.');
        continue;
      }
      //
      // Do an initial parse for validity, exiting if failure, and throw away result no matter what.
      //
      log.finer('\t\t\t\tGunna do an initial parse just to check if its a legal file.');
      var result = scoreParser.parse(fileContents);
      if (result.isFailure) {
        log.severe('Failed to parse $filePath. Message: ${result.message}');
        var rowCol = result.toPositionString().split(':');
        log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
        log.severe('Should be around this character: ${result.buffer[result.position]}');
        return result; // yeah I know the parent function will report too.  Fix later.
      }
      scoresStringBuffer.write(fileContents); // what the crap?  Why write this?  I thought we were only checking.
    }
    if (scoresStringBuffer.isEmpty) {
      log.severe('There is nothing to parse.  Exiting...');
      exit(42); // 42 is a joke
    }
    //
    // Parse the score's text elements, notes and other stuff.  The intermediate parse results like Tempo and TimeSig
    // are in the list that is result.value, and processed later.
    //
    log.finer('\t\t\t\there comes the real parse now, since we have a legal file.  I dislike this double thing.');
    var result = scoreParser.parse(scoresStringBuffer.toString());
    if (result.isSuccess) {
      Score score = result.value;
      log.finer('parse succeeded.  This many elements: ${score.elements.length}'); // wrong
      for (var element in score.elements) {
        log.finest('\tAfter score raw parse, element list has this: $element');
      }
      log.fine('Done with loadAndParse / first pass -- loaded raw notes, no shorthands yet.\n');
    }
    else {
      log.finer('Score parse failed.  Parse message: ${result.message}');
    }
    // And return the actual Result object, which contains a Score object, which contains elements.
    return result;
  }

  ///
  /// Apply shorthands, meaning that missing properties of duration and type for a text note get filled in from the previous
  /// note.  This would include notes specified by ".", which means use previous note's duration and type.
  /// Also, when the note type is not specified, swap hand order from the previous note.
  /// This also sets the dynamic field, but not velocities.
  /// Also, if there's a /dd (default dynamic), it is replaced by the default dynamic value.
  void applyShorthands(CommandLine commandLine) {
    log.fine('In applyShorthands');
    var previousNote = Note();
    // I don't like the way this is done to account for a first note situation.  Perhaps use a counter and special case for first note
    for (var elementIndex = 0; elementIndex < elements.length; elementIndex++) {
      if (elements[elementIndex] is Note) {
        var note = elements[elementIndex] as Note; // new
        // So this next stuff assumes element is a Note, and it could be a rest
        // This section is risky. This could contain bad logic:
        //
        // Usually to repeat a previous note we just have '.' by itself, but we could have
        // '4.' to mean quarter note, but same note type as before, or
        // '.T' to mean same duration as previous note, but make this one a right tap, or
        // '>.' to mean same note as before, but accented this time.
        //
        // if (note.noteName == NoteName.previousNoteDurationOrType) { // I think this means "." dot.  Why not just call it "dot"?
        if (note.embellishmentAndNoteName == EmbellishmentAndNoteName.dot) { // I think this means "." dot.  Why not just call it "dot"?
          note.duration = previousNote.duration;
          note.embellishmentAndNoteName = previousNote.embellishmentAndNoteName;
          log.finest('In Score.applyShorthands(), and since note was just a dot, just set note to have previousNote props, so note is now ${note}.');
        }
        else {
//        note.duration ??= previousNote.duration;
          note.duration.firstNumber ??= previousNote.duration.firstNumber; // new
          note.duration.secondNumber ??= previousNote.duration.secondNumber;
          note.embellishmentAndNoteName ??= previousNote.embellishmentAndNoteName;
          log.finest('In Score.applyShorthands(), and note was not just a dot, but wanted to make sure did the shorthand fill in, so now note is ${note}.');
        }
        //previousNote = note; // No.  Do a copy, not a reference.       watch for previousNoteDurationOrType
        previousNote.velocity = note.velocity; // unnec?
        //previousNote.articulation = note.articulation;
        previousNote.duration = note.duration;
        previousNote.embellishmentAndNoteName = note.embellishmentAndNoteName;

        log.finest('bottom of loop Score.applyShorthands(), just updated previousNote to point to be this ${previousNote}.');
      }
    }
    log.finest('leaving Score.applyShorthands()\n');
    return;
  }



  // These two are new.  We want to know the first tempo and time signature that is specified in the score.
  // There may not be either value, but if there is we want to set them for the midi file header, I think.
  // Not sure it's required though for the header.  Check on that.  Also, don't need to return it if it's
  // also available as part of the Score object.
  //
  TimeSig scanForFirstTimeSig() {
    for (var element in elements) {
      if (!(element is TimeSig)) {
        continue;
      }
      firstTimeSig = element;
      return firstTimeSig;
    }
    return null;
  }

  Tempo scanForFirstTempo() {
    for (var element in elements) {
      if (!(element is Tempo)) {
        continue;
      }
      firstTempo = element;
      return firstTempo;
    }
    return null;
  }

  Track scanForFirstTrack() {
    for (var element in elements) {
      if (!(element is Track)) {
        continue;
      }
      firstTrack = element;
      return firstTrack;
    }
    return null;
  }

  // check that this does what I think it is supposed to do
  void scaleTempos(CommandLine commandLine) {
    //Tempo newTempo;
    for (var element in elements) { // better check to see that element in elements really changes.
      if (element is Tempo) {
        var tempo = element as Tempo;
        //print('scaleTempos(), element is currently: $tempo and scalar is ${commandLine.tempoScalar}');
        tempo = Tempo.scaleThis(tempo, commandLine.tempoScalar); // WHY CALL  THIS IF scalar is 0?
        element.bpm = tempo.bpm; // this is awkward
        //print('scaleTempos(), now element is $tempo');
      }
    }
  }

  // Some embellishments start on the beat, and some before the beat.  We need a table to decide
  // what to do, and then if we slide them before the beat we need to adjust by lengthening them
  // so that the melody/principle note gets full value.
  void adjustForGraceNotes(CommandLine commandLine) {

    log.fine('In adjustForGraceNotes.');

    var graceNotesDuration = 0; // Actually, the units are wrong.  This should be a percentage thing, I think.  Changes based on tempo.  For slow tempos the number is too high.  For fast tempos, too low.
    var noteOffDeltaTimeShift = 0;

    // just a wild stab to handle first note case in list
    var previousNote = Note();
    previousNote.noteOffDeltaTimeShift = 0;

    // Tempo mostRecentScaledTempo; // assuming here that we'll hit a tempo before we hit a note, because already added a scaled tempo at start of list.
    Tempo mostRecentTempo; // assuming here that we'll hit a tempo before we hit a note, because already added a scaled tempo at start of list.
    for (var element in elements) {
      if (element is Tempo) {
        log.finest('In adjustForGraceNotes(), tempo is $element and looks like we will scale it just to keep track of the most recent tempo, but not changing it in the list');
        mostRecentTempo = element;
        continue;
      }
      else if (element is Note) {
        var note = element as Note; // unnec cast, it says, but I want to
        // Bad logic, I'm sure:
        // Hey, the following is just here for a placeholder and a test.  I've not determined which embellishments need what kind of sliding, if any.
        switch (note.embellishmentAndNoteName) {
          case EmbellishmentAndNoteName.dA:
          case EmbellishmentAndNoteName.dc:
          case EmbellishmentAndNoteName.ea:
          case EmbellishmentAndNoteName.Ga:
          case EmbellishmentAndNoteName.gA:
          case EmbellishmentAndNoteName.ga:
          case EmbellishmentAndNoteName.gb:
          case EmbellishmentAndNoteName.gc:
          case EmbellishmentAndNoteName.gd:
          case EmbellishmentAndNoteName.ge:
          case EmbellishmentAndNoteName.gf:
            graceNotesDuration = (180 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case EmbellishmentAndNoteName.gbdb:
          case EmbellishmentAndNoteName.gcdc:
          case EmbellishmentAndNoteName.gefe:
          case EmbellishmentAndNoteName.GAGA:
          case EmbellishmentAndNoteName.gfgf:
            graceNotesDuration = (250 / (100 / mostRecentTempo.bpm)).round();
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case EmbellishmentAndNoteName.aga:
            graceNotesDuration = (1400 / (100 / mostRecentTempo.bpm)).round();
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case EmbellishmentAndNoteName.GdGcd:
            graceNotesDuration = (1900 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration; // at slow tempos coming in too late
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          default: // a note without gracenotes, or a rest
            graceNotesDuration = 0;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;

        }
        continue;
      }
      else {
        log.finest('Score.adjustForGraceNotes() whatever this element is ($element), it is not important for adjusting durations due to gracenotes.');
        continue;
      }

    }
    log.finest('Leaving adjustForGraceNotes(), and updated notes to have delta time shifts to account for gracenotes.');
    return;

  }

}

///
/// ScoreParser
///
Parser scoreParser = ((commentParser | markerParser | textParser | trackParser | timeSigParser | tempoParser | noteParser).plus()).trim().end().map((values) {    // trim()?
  log.finest('In Scoreparser, will now add values from parse result list to score.elements');
  var score = Score();
  if (values is List) {
    for (var value in values) {
      log.finest('ScoreParser, value: -->$value<--');
      score.elements.add(value);
      log.finer('ScoreParser, Now score.elements has this many elements: ${score.elements.length}');
    }
  }
  else { // I don't think this happens when there's only one value.  It's still in a list
    log.info('Did not get a list, got this: -->$values<--');
    score.elements.add(values); // right? new
  }
  log.finest('Leaving Scoreparser returning score in parsed and objectified form.');
  return score;
});

// Maybe change track to "track"
/// I think the idea here is to be able to insert the keywords '/track snare' or
/// '/track tenor', ... and that track continues on as the only track being written
/// to, until either the end of the score, or there's another /track designation.
/// So, it's 'track <name>'
enum TrackId {
  snare,
  unison, // snareEnsemble
  pad,
  tenor, // possibly pitch based notes rather than having tenor1, tenor2, ...
  bass,
  met,
  pipes
}

class Track {
  // Why not initialize?
  TrackId id; // the default should be snare.  How do you do that?
  // Maybe this will be expanded to include more than just TrackId, otherwise just an enum
  // and not a class will do, right?  I mean, why doesn't Dynamic do it this way?

  String toString() {
    return 'Track: id: $id';
  }
}

///
/// trackParser
///
final trackId = (letter() & word().star()).flatten();
Parser trackParser = ((string('/track')|(string('/staff'))).trim() & trackId).trim().map((value) {
  log.finest('In trackParser and value is -->$value<--');
  var track = Track();
  track.id = trackStringToId(value[1]);
  log.finest('Leaving trackParser returning value $track');
  return track;
});

TrackId trackStringToId(String trackString) {
  TrackId trackId;
  switch (trackString) {
    case 'snare':
      trackId = TrackId.snare;
      break;
    case 'unison':
      trackId = TrackId.unison;
      break;
    case 'pad':
      trackId = TrackId.pad;
      break;
    case 'tenor':
      trackId = TrackId.tenor;
      break;
    case 'bass':
      trackId = TrackId.bass;
      break;
    case 'met':
    case 'metronome':
      trackId = TrackId.met;
      break;
    case 'pipes':
      trackId = TrackId.pipes;
      break;
    default:
      log.severe('Bad track identifier: $trackString');
      trackId = TrackId.snare;
      break;
  }
  return trackId;
}

String trackIdToString(TrackId id) {
  switch (id) {
    case TrackId.snare:
      return 'snare';
    case TrackId.unison:
      return 'unison';
    case TrackId.pad:
      return 'pad';
    case TrackId.tenor:
      return 'tenor';
    case TrackId.bass:
      return 'bass';
    case TrackId.met:
      return 'met';
    case TrackId.pipes:
      return 'pipes';
    default:
      log.severe('Bad track id: $id');
      return null;
  }
}
