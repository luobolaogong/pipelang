import 'dart:io';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
// import 'package:pipelang/pipelang.dart' as pipelang;
import 'package:pipelang/pipelang.dart';

///
/// PipeLang, a silly name for an app that defines a bagpipe textual language, and
/// converts it into MIDI, to be played in a MIDI players like Midi Voyager.
///
/// The language has similarities with LilyPond (excellent), and ABC and others, such
/// that a tune can be completely described in a computer text file that can be
/// edited with a text editor.
///
/// The conversion of this text file is based on the assumption that bagpipe sounds
/// are captured in a sound font file, and the correct snippet (?) is placed into
/// a MIDI file at the appropriate place.
///
/// Care must be taken to correctly time and place the embellishments or grace notes.
///
/// The goal is to help pipers learn to play a tune (using Midi Voyager's ability to
/// vary the tempo without changing pitch, jump to sections, and loop selections),
/// and learn to play it accurately (curruntly only through listening, no feedback.)
///
/// The sound font should contain recordings of the typical pipes that are used,
/// plus chanter sounds.  The notes in the text input files ('*.ppl' files) will be
/// the same for all pipe instruments.  No transposing will be done.  Notes are the
/// standard ABC or whatever they are.
///
/// The command line will have options to specify one or more input tunes ('*.ppl' files)
/// and an output midi file, and override/default values for tempo, dynamic, time
/// signature, and others (style???).
///
// final log = Logger('ppl');
void main(List<String> arguments) {
  print('Staring ppl ...');
  Logger.root.level = Level.ALL; // get this from the command line, as a secret setting
  Logger.root.onRecord.listen((record) {
    // print('${record.level.name}: ${record.time}: ${record.message}'); // wow!!!  I can change how it prints!
    // print('${record.level.name}: ${record.message}, ,,,, $record'); // wow!!!  I can change how it prints!
    print('$record'); // wow!!!  I can change how it prints!
  });
  var commandLine = CommandLine();
  var argResults = commandLine.parseCommandLineArgs(arguments);

  var score = doThePhases(commandLine.inputFilesList, commandLine); // Maybe use tempoScalar to handle gracenote calculations

  var midi = Midi();
  var midiHeader =  midi.createMidiHeader(); // 840 ticks per beat seems good
  var midiTracks = <List<MidiEvent>>[];
  midi.addMidiEventsToTracks(midiTracks, score.elements, commandLine);

  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();

  var midiFileOutFile = File(commandLine.outputMidiFile);
  midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile); // will crash here
  print('Done writing midifile ${midiFileOutFile.path}');
}


// What are the phases?
// 1.  Parse the score text, creating a List of raw score elements; no note dynamics, velocities, or ticks.
// 2.  Apply shorthands so that each note has full note property values including dynamic, and no "." notes,
//     and notes should have no velocities or ticks.  (or maybe they do have dynamics)
// 3.  Scan the elements list for dynamicRamp markers and set dynamics/velocities,
// 4.  Scan the elements list for tempoRamp markers,
// 5.  Go through the elements and adjust timings due to notes with grace notes.  Keep track of current tempo?  What if other tracks change tempo?
//     Probably should work on trackZero and move all tempos to it somehow and go off of it.

Score doThePhases(List<String> piecesOfMusic, CommandLine commandLine) {
  log.fine('In doThePhases, and tempo coming in from commandLine tempo is ${commandLine.tempo}');
  //
  // Phase 1: load and parse the score, returning the Score, which contains a list of all elements, as PetitParser parses and creates them.
  // There is no processing of the elements put into the list.
  //
  var result = Score.loadAndParse(piecesOfMusic, commandLine);

  if (result.isFailure) {
    log.severe('Failed to parse the scores. Message: ${result.message}');
    var rowCol = result.toPositionString().split(':');
    log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
    log.severe('Should be around this character: ${result.buffer[result.position]}');
    exit(42);
  }
  // Since parsing succeeded, we should have the Score element in the result value
  Score score = result.value;

  //
  // Phase 2:
  // Apply shorthands to the list, meaning fill in the blanks that are in the raw list, including Dynamics.
  // And this would include replacing default dynamics (/dd) with the default dynamic value set on commandline or whatever the default is.
  score.applyShorthands(commandLine);
  for (var element in score.elements) {
    log.finer('In debug loop After shorthand phase: $element');
  }

  // What if there's no /tempo given in a file and no -t value specified on command line?  We still need
  // to put a tempoEvent in the midi output
  log.finer('doThePhases(), adding  a few elements at the start, like timesig and tempo, before adjusting for grace notes.');
  log.finest('doThePhases(), tempo to use for adding a couple events at the start, is ${commandLine.tempo} which WILL NOT be scaled next.');
  score.elements.insert(0, commandLine.tempo); // yes in this order
  score.elements.insert(0, commandLine.timeSig);
  log.finer('Added elements ${commandLine.timeSig}, ${commandLine.tempo} to head of list of elements.');

// Actually should have a separate phase that only adjusts all Tempo elements by the scalar.  Then do the grace notes.
  score.scaleTempos(commandLine);


  // Phase 5:
  // Do grace notes
  score.adjustForGraceNotes(commandLine); // maybe do this similar to how applyShorthands is done

  return score;
}


// expect either '104' (quarter note assumed) or '8:3=104'
// Probably won't use this in the future
Tempo parseTempo(String noteTempoString) {
  var tempo = Tempo();
  // var parts = tempoString.split(r'[:=]');
  var noteTempoParts = noteTempoString.split('=');
  if (noteTempoParts.length == 1) {
    tempo.bpm = int.parse(noteTempoParts[0]);
  }
  else if (noteTempoParts.length == 2) {
    var noteParts = noteTempoParts[0].split(':');
    tempo.noteDuration.firstNumber = int.parse(noteParts[0]);
    tempo.noteDuration.secondNumber = int.parse(noteParts[1]);
    tempo.bpm = int.parse(noteTempoParts[1]); // wrong of course
  }
  else {
    print('Failed to parse tempo correctly: -->$noteTempoString<--');
  }
  print('parseTempo is returning tempo: $tempo');
  return tempo;
}