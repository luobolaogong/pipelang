import 'dart:io';

import 'package:petitparser/petitparser.dart';

import '../pipelang.dart';


class Score {
  List elements = [];
  TimeSig firstTimeSig;
  Tempo firstTempo;
  num tempoScalar = 0; // new, shouldn't this be zero?
  Track firstTrack;

  String toString() {
    return 'Score: ${elements.toString()}'; // could do a forEach and collect each element into a string with \n between each
  }

  static Result loadAndParse(List<String> scoresPaths, CommandLine commandLine) {
    var scoresStringBuffer = StringBuffer();

    // Do prep by putting all files into one file, but also doing syntax parse as you go
    for (var filePath in scoresPaths) {
      log.info('Loading file $filePath');
      var inputFile = File(filePath);
      if (!inputFile.existsSync()) {
        print('File does not exist at "${inputFile.path}", exiting...');
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
      // Thw whole reason for doing this is to help identify the file and line in that file where
      // there's a syntax error.  So, the parse is done on a file by file basis, not as concatenated
      // file.
      //
      bool wantSyntaxParsePhase = true;
      if (wantSyntaxParsePhase) {
        log.finer('\t\t\t\tGunna do an initial parse just to check if its a legal file and output a syntax error line.');
        var result = scoreParser.parse(fileContents);
        if (result.isFailure) {
          log.severe('Failed to parse $filePath. Message: ${result.message}');
          var rowCol = result.toPositionString().split(':');
          log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
          log.severe('Should be around this character: ${result.buffer[result.position]}');
          return result; // yeah I know the parent function will report too.  Fix later.
        }
      }
      scoresStringBuffer.write(fileContents); // what the crap?  Why write this?  I thought we were only checking.
    }
    if (scoresStringBuffer.isEmpty) {
      log.severe('There is nothing to parse.  Exiting...');
      exit(42); // 42 is a joke
    }


    //
    // Parse the (concatenated) score's text elements, notes and other stuff.  The intermediate parse results like Tempo and TimeSig
    // are in the list that is result.value, and processed later.
    //
    log.finer('\n\n\n\t\t\t\tHere comes the real parse now, since we have a legal file.  I dislike this double thing.');
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
    //var previousNote = PipeNote(); // hey!!!!!
    var previousNote = Note(); // this has adefault dynamic value, good or bad?  I think bad
    // I don't like the way this is done to account for a first note situation.  Perhaps use a counter and special case for first note
    previousNote.dynamic = commandLine.dynamic; // unnec?
    for (var elementIndex = 0; elementIndex < elements.length; elementIndex++) {
      if (elements[elementIndex] is Dynamic) { // new
        if (elements[elementIndex] == Dynamic.dd) {
          elements[elementIndex] = commandLine.dynamic;
        }
        log.finer('In Score.applyShorthands(), and because element is ${elements[elementIndex].runtimeType} and not a dynamicRamp, I am marking previousNote s dynamic to be same, and skipping');
        previousNote.dynamic = elements[elementIndex];
        continue;
      }
      // if (elements[elementIndex] is PipeNote) {
      if (elements[elementIndex] is Note) {
        // var note = elements[elementIndex] as PipeNote; // new
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
        if (note.noteType == NoteType.dot) { // hey hey hey, stop here.  Fill this in before trying to do some math using duration!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          note.duration = previousNote.duration;
          note.noteType = previousNote.noteType;
          //note.noteType = previousNote.noteType;
          note.dynamic = previousNote.dynamic;
          log.finest('In Score.applyShorthands(), and since note was just a dot, just set note to have previousNote props, so note is now ${note}');
        }
        else {
//        note.duration ??= previousNote.duration;
          note.duration.firstNumber ??= previousNote.duration.firstNumber; // new
          note.duration.secondNumber ??= previousNote.duration.secondNumber;
          note.noteType ??= previousNote.noteType;
          note.dynamic ??= previousNote.dynamic;
          //log.finest('In Score.applyShorthands(), and now note is ${note}');
        }
        //previousNote = note; // No.  Do a copy, not a reference.       watch for previousNoteDurationOrType
        previousNote.dynamic = note.dynamic;
        previousNote.velocity = note.velocity; // unnec?
        //previousNote.articulation = note.articulation;
        previousNote.duration = note.duration;
        previousNote.noteType = note.noteType;

        //log.finest('bottom of loop Score.applyShorthands(), just updated previousNote to point to be this ${previousNote}.');
      }
    }
    log.finest('leaving Score.applyShorthands()\n');
    return;
  }

  void correctTripletTempos(CommandLine commandLine) {
    latestTimeSig = commandLine.timeSig;
    for (var element in elements) {
      if (element is Tempo) {
        Tempo.fillInTempoDuration(element, latestTimeSig); // Yes, I know latestTimeSig is a global, just a test.  There's no guarantee commandLine.timeSig or tempo will have values that represent what's in the file
        continue;
      }
      if (element is TimeSig) {
        latestTimeSig = element; // latestTimeSig is a global defined in timesig.dart file
        continue;
      }
      continue;
    }
    return;
  }

  void applyDynamics() {
    log.finest('In Score.applyDynamics().  First this maybe only applies to non-pipe scores, but maybe just setting an initial volume.');
    setDynamicFieldOfNoteElementsIfNotDonePreviously();
    doDynamicRampStuff();
    //adjustVelocitiesByArticulations(); // only really for non-pipe notes
    log.finest('Leaving Score.applyDynamics');
    return;
  }

  void setDynamicFieldOfNoteElementsIfNotDonePreviously() {
    // SET THE note.dynamic FIELD AS IF NOT DONE PREVIOUSLY
    // For each note in the list, set the velocity field based on the dynamic field, which is strange, because why not do it initially?
    for (var element in elements) {
      // if (!(element is PipeNote)) {
      if (!(element is Note)) {
        continue;
      }
      //var note = element as PipeNote; // this looks like a cast, which is what I want
      var note = element as Note; // this looks like a cast, which is what I want
      if (note.dynamic == null) { // why?
        continue;
      }
      element.velocity = dynamicToVelocity(
          note.dynamic); // hmmmmm pipes and drums could have different dynamics.  I mean ff for snare different for pipes, or tenor or bass????
    }
  }

  void determineDynamicRampSlopeValues() {
    // FIRST DETERMINE SLOPE VALUE
    log.finest('gunna start looking for dynamic ramp markers and set their values');
    // Scan the elements list for dynamicRamp markers, and set their properties
    //print('');
    log.finest(
        'Score.applyDynamics(), Starting search for dynamicRamps and setting their values.  THIS MAY BE WRONG NOW THAT I''M APPLYING DYNAMICS DURING SHORTHAND PHASE');
    DynamicRamp currentDynamicRamp;
    Dynamic mostRecentDynamic;
    num accumulatedDurationAsFraction = 0;
    var inDynamicRamp = false;
    for (var element in elements) {
      //if (element is PipeNote) { // PipeNote and Note should be extensions of Note, probably.
      //if (element is Note) { // PipeNote and Note should be extensions of Note, probably.
      if (element is Note) { // PipeNote and Note should be extensions of Note, probably.
        mostRecentDynamic = element.dynamic; // I know, hack,
        if (inDynamicRamp) {
          print('In determineDynamicRampSlopeValues(), element: $element');
          accumulatedDurationAsFraction += element.duration.secondNumber / element.duration.firstNumber;
          log.finest('Score.applyDynamics(), Doing dynamicRamps... This note is inside a dynamicRamp.  accumulated duration: $accumulatedDurationAsFraction');
        }
        else {
          log.finest(
              'Score.applyDynamics(), Doing dynamicRamps... This note is NOT inside a dynamicRamp, so is ignored in this phase of setting dynamicRamp values.');
        }
        continue;
      }

      if (element is DynamicRamp) {
        currentDynamicRamp = element;
        currentDynamicRamp.startDynamic = mostRecentDynamic;
        currentDynamicRamp.startVelocity = dynamicToVelocity(mostRecentDynamic);
        inDynamicRamp = true;
        log.finest('Score.applyDynamics(), Doing dynamicRamps while looping only for dynamicRamps... found dynamicRamp marker and starting a dynamicRamp.');
        continue;
      }

      if (element is Dynamic) {
        if (inDynamicRamp) {
          currentDynamicRamp.endDynamic = element;
          currentDynamicRamp.endVelocity = dynamicToVelocity(element);
          var accumulatedTicks = (Midi.ticksPerBeat * accumulatedDurationAsFraction).round();
          currentDynamicRamp.totalTicksStartToEnd = accumulatedTicks;
          currentDynamicRamp.slope = (currentDynamicRamp.endVelocity - currentDynamicRamp.startVelocity) / accumulatedTicks; // rise / run
          log.finest(
              'Score.applyDynamics(), Doing dynamicsDynamicRamps... hit a Dynamic ($element) and currently in dynamicRamp, so ending dynamicRamp.  dynamicRamp slope: ${currentDynamicRamp
                  .slope}, accumulatedTicks: $accumulatedTicks, accumulatedDurationAsFraction: $accumulatedDurationAsFraction');
          accumulatedDurationAsFraction = 0;

          currentDynamicRamp = null; // good idea?
          inDynamicRamp = false;
        }
        else {
          log.finest('Score.applyDynamics(), Doing dynamicRamps... hit a Dynamic but not in currently in dynamicRamp.');
        }
        mostRecentDynamic =
            element; // yeah, we can have a dynamic mark followed immediately by a dynamicRamp, and so the previous note will not have the new dynamic
        continue;
      }
      //log.finest('Score.applyDynamics(), Doing dynamicRamps... found other kine element: ${element.runtimeType} and ignoring.');
    }
    log.finer('determineDynamicRampSlopeValues(), Done finding and setting dynamicRamp values for entire score.\n');
  }


  void adjustEachNotesDynamicValueIfInARamp() {
    DynamicRamp currentDynamicRamp;
    var inDynamicRamp = false;

    // NOW ADJUST EACH NOTE'S DYNAMIC VALUE IF IT'S IN A RAMP
    log.finer('Score.adjustEachNotesDynamicValueIfInARamp(), starting to adjust dynamicRamped notes...');
    // Adjust dynamicRamp note velocities based solely on their dynamicRamp and position in dynamicRamp, not articulations or type.
    // Each note already has a velocity.
    inDynamicRamp = false;
    var isFirstNoteInDynamicRamp = true;
    // PipeNote previousNote;
    Note previousNote;
    num cumulativeDurationSinceDynamicRampStartNote = 0;
    var elementCtr = 0; // test to see if can help pinpoint dynamic ramp mistake in score
    for (var element in elements) {
      elementCtr++;
      if (element is DynamicRamp) {
        log.finest('\telement $elementCtr is a DynamicRamp, so setting inDynamicRamp to true, and setting currentDynamicRamp to point to it.');
        inDynamicRamp = true;
        currentDynamicRamp = element;
        isFirstNoteInDynamicRamp = true;
        cumulativeDurationSinceDynamicRampStartNote = 0; // new
        continue;
      }
      if (element is Dynamic) {
        log.finest('\telement $elementCtr is a Dynamic, so resetting dynamicRamp related stuff.');
        inDynamicRamp = false;
        currentDynamicRamp = null;
        isFirstNoteInDynamicRamp = true;
        cumulativeDurationSinceDynamicRampStartNote = 0; // new
        continue;
      }
      // if (element is PipeNote) {
      if (element is Note) {
        log.finest('\telement is a Note..., lets see it: $element');
        // var note = element as PipeNote;
        var note = element as Note;
        // If a note is not in a dynamicRamp, skip it
        if (!inDynamicRamp) {
          log.finest('\t\tNote element $elementCtr is not in dynamicRamp, so skipping it.  But it has velocity ${note.velocity}');
          continue;
        }
        // We have a note in a dynamicRamp, and will now adjust its velocity solely by it's DynamicRamp slope and starting time in the dynamicRamp.
        if (isFirstNoteInDynamicRamp) {
          log.finest('\t\tGot first note (#$elementCtr ) in dynamicRamp.  Will not adjust velocity, which is ${note.velocity}');
          previousNote = note;
          isFirstNoteInDynamicRamp = false;
        }
        else {
          // Get note's current time position in the dynamicRamp.
          // Got subsequent note (#$elementCtr) in a dynamicRamp, so will calculate time position relative to first note by doing accumulation.');
          cumulativeDurationSinceDynamicRampStartNote += (previousNote.duration.secondNumber / previousNote.duration.firstNumber);
          log.finest('\t\t\tcumulativeDurationSinceRampStartNote: $cumulativeDurationSinceDynamicRampStartNote');
          var cumulativeTicksSinceDynamicRampStartNote = beatFractionToTicks(cumulativeDurationSinceDynamicRampStartNote);
          log.finest(
              '\t\t\tcumulativeTicksSinceDynamicRampStartNote: $cumulativeTicksSinceDynamicRampStartNote and dynamicsDynamicRamp slope is ${currentDynamicRamp
                  .slope}');
          if (currentDynamicRamp.slope == null) { // hack
            print('Still in dynamic ramp, right?  Well, got a null at note element $elementCtr, Note duration: ${note.duration}');
            log.severe('Error in dynamic ramp.  Not sure what to do.  Did we have a ramp start, and no ramp end?');
          }
          else {
            log.finest('\t\t\tUsing slope and position in dynamicRamp, wanna add this much to the velocity: ${currentDynamicRamp.slope *
                cumulativeTicksSinceDynamicRampStartNote}');
            note.velocity += (currentDynamicRamp.slope * cumulativeTicksSinceDynamicRampStartNote).round(); // HERE IT IS, FINALLY SET THE VELOCITY VALUE
            log.finest('\t\t\tSo now this element has velocity ${note.velocity}');
            isFirstNoteInDynamicRamp = false;
            previousNote = note; // new
          }
        }
      }
    }
    log.finest('Leaving adjustEachNotesDynamicValueIfInARamp()');
  }

  void doDynamicRampStuff() {
    determineDynamicRampSlopeValues();
    adjustEachNotesDynamicValueIfInARamp();
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

        ///////////////////////////////// ADD HERE CHECK HERE 4/5 //////////////////////////
        // SEEMS THERE ARE A LOT MISSING.  CHECK WITH OTHER LISTS, or alphabetize
        switch (note.noteType) {
          case NoteType.dA:
          case NoteType.dc:
          // case NoteType.ea:
          case NoteType.eA:
          case NoteType.GA:
          case NoteType.gA:
          case NoteType.ga:
          case NoteType.Gb:
          case NoteType.gb:
          case NoteType.gc:
          case NoteType.Gc:
          case NoteType.gd:
          case NoteType.ge:
          case NoteType.Ae:
          case NoteType.Ge: // new
          case NoteType.fg: // new
          case NoteType.ag: // new
          case NoteType.gf:
          case NoteType.ae: // new
          case NoteType.af:
          case NoteType.ac: // new
            graceNotesDuration = (0 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            // graceNotesDuration = (180 / (100 / mostRecentTempo.bpm)).round(); // The 180 is based on a tempo of 100bpm.  What does this do for dotted quarter tempos?
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.aga:
          case NoteType.cdc:
          case NoteType.dcd:
          case NoteType.gfg:
          case NoteType.fgf:
          case NoteType.efe:
            graceNotesDuration = (0 / (100 / mostRecentTempo.bpm)).round();
            // graceNotesDuration = (1400 / (100 / mostRecentTempo.bpm)).round();
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.gdGd: // new
          case NoteType.gbdb: // new?
          case NoteType.gdcd:
          case NoteType.gcdc:
          case NoteType.gefe:
          case NoteType.Gdcd:
          case NoteType.Gbdb:
          case NoteType.GdGb: // new
          case NoteType.GAGA:
          case NoteType.gAdA: // new
          case NoteType.gfgf:
          case NoteType.afgf:
          case NoteType.agfg: // new
            graceNotesDuration = (0 / (100 / mostRecentTempo.bpm)).round();
            // graceNotesDuration = (250 / (100 / mostRecentTempo.bpm)).round(); // do this after we get recordings and also measure the gracenote durations
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration;
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.GdGcd:
          case NoteType.GdGeA: // new
          case NoteType.AGAGA:
            graceNotesDuration = (0 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            // graceNotesDuration = (1900 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            previousNote.noteOffDeltaTimeShift -= graceNotesDuration; // at slow tempos coming in too late
            note.noteOffDeltaTimeShift += graceNotesDuration;
            previousNote = note; // probably wrong.  Just want to work with pointers
            break;
          case NoteType.gAGAGA:
            graceNotesDuration = (0 / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
            // graceNotesDuration = (???? / (100 / mostRecentTempo.bpm)).round(); // duration is absolute, but have to work with tempo ticks or something
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
