import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
import 'dart:math';
import '../pipelang.dart';

// program change vs patch vs channel???  Need more than 127 notes for a set of bagpipe recorded embellishments
// Would like to know how to havemore than one set of 127 notes available.

bool soundFontHasSoftMediumLoudRecordings = false; // Change this later when sound font file has soft,med,loud recordings, and mapped offsets by 10
///
/// The Dart midi library, which is basically a rewrite of a JavaScript library:
/// https://pub.dev/documentation/dart_midi/latest/midi/midi-library.html
/// https://www.mixagesoftware.com/en/midikit/help/HTML/meta_events.html
/// A midi spec: http://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf
/// is based on https://github.com/gasman/jasmid, with no API documentation.
///
/// RoseGarden software can play midi that this program creates.  It needs QSynth to be running
/// which knows about my sound font file.  Start QSynth first.
///
/// All PipeLang note designations are just the reciprocal of their ratio durations
/// to a 4/4 bar.
///
/// The form is X:Y where X is the number of notes in Y bars.
/// There are 4 quarter notes in 1 4/4 bar.  Therefore "4:1", or just "4"
/// Or, there is 1 quarter note in 1/4 of a bar: 1:1/4, which is also "4:1", or just "4"
/// A note that takes 2/5ths of a bar is 1:2/5 or "5:2".  No decimal values, like "2.5"
///
/// A "tick" is the resolution of a midi clock, and is used in midi note durations.
///
/// I do not know how a midi clock is calibrated.
///
/// A "beat" is a metronome click, which is determined by a desired tempo, like 84 bpm.
///
/// "ticksPerBeat" (or "ppq"?) is the number of subdivisions in a metronome beat.
/// This is important.
///
/// I don't know how ticksPerBeat is determined.  It may be just a convenient number
/// like 384.  If the tempo is slow, like 64, it probably makes sense to have more
/// ticksPerBeat than if the tempo is fast, like 148.  I don't know if you can change
/// this number in a midi file once it's set in the header, even if the tempo changes,
/// which can be set anywhere in a piece.
///
/// Tempo is related to the value of "microsecondsPerBeat".  60 bpm is 1 beat per second,
/// or 1,000,000 microseconds.  The formulas for tempo and microsecondsPerBeat are
/// tempoBpm = 60,000,000 / microsecondsPerBeat
/// microsecondsPerBeat = 60,000,000 / tempoBpm
///
/// We don't care about durations per second or microsecond.  We also don't care about the
/// "metronome number" which is the number of midi clock ticks per metronome click because
/// I think it's only used for device synchronization.
///
/// So, how do you calculate and set midi note durations (deltaTime in ticksPerBeat) for
/// PipeLang note name durations such as "5:2"  or "30"?  It may be as simple as this:
///
/// noteTicks = (4 * ticksPerBeat) / PipeLangNoteNameValue
///
/// It seems it is that simple, based on the few tests I ran when only the tempo was
/// changed, and also when the time signature was changed, (4/4, 3/4, 6/8, with and without
/// metronome set to dotted quarter for the 6/8).  Therefore, to ward off problems
/// with integer math round errors, it would be good to use 840 for the "ppq"
/// (microsecondsPerBeat) value.  The missing even subdivisions would might be helpful
/// are 9, 36, and 64.  Plus a higher number will probably make gracenotes better positioned.
///


class Midi {
  static final ticksPerBeat = 10080; // put this elsewhere later
  static final microsecondsPerMinute = 60000000;

  double cumulativeRoundoffTicks = 0.0;

  ///
  ///   Create a MidiHeader object, which I did not define, which is part of MidiFile, and return it.
  ///   I don't think there's anything much in this header.  I don't know how it relates to a real
  ///   midi file.
  MidiHeader createMidiHeader() {
    var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format:1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
    return midiHeaderOut;
  }


  List<List<MidiEvent>> addMidiEventsToTracks(List<List> midiTracks, List elements, commandLine) {
    log.fine('In Midi.createMidiEventsTracksList()');
    var trackEventsList = <MidiEvent>[];
    var trackNameEvent = TrackNameEvent();
    trackNameEvent.text = trackIdToString(commandLine.track.id);
    trackNameEvent.deltaTime = 0;

    // Go through the elements, seeing what each one is, and add it to the current track if right kind of element.
    // Of course this is not yet written to midi.
    log.finer('Looping through elements in the list to add to midi track...');
    for (var element in elements) {
      log.info('element: $element');
      if (element is Track) { // I do not trust the logic in this section.  Revisit later.  Does this mean that we'd better have a Track command at the start of a score?????????????  Bad idea/dependency
        if (trackEventsList.isNotEmpty) {
          var endOfTrackEvent = EndOfTrackEvent(); // this is new
          endOfTrackEvent.deltaTime = 0;
          trackEventsList.add(endOfTrackEvent); // sure???????
          log.fine('addMidiEventsToTrack() added endOfTrackEvent $endOfTrackEvent to trackEventsList');

          midiTracks.add(trackEventsList);
          trackEventsList = <MidiEvent>[]; // start a new one
        }
        var trackNameEvent = TrackNameEvent();
        trackNameEvent.text = trackIdToString(element.id); // ????????????????????????????????????????????????????????????????????????????????????????????????
        trackNameEvent.deltaTime = 0;  // time since the previous event?
        trackEventsList.add(trackNameEvent);
        log.finer('Added track name: ${trackNameEvent.text}');
        continue; // new here
      }
      if (element is Note) {
        // If the note is flam, drag, or ruff we should adjust placement of the note in the timeline so that the
        // principle part of the note is where it should go (and adjust after the note by the same difference.)
        // To do this, we need access to the previous note to shorten it.  So that means gotta process in a separate
        // loop, probably, prior to this point, or maybe after.  And it's only for a pipes staff/track.
        // And can't assume the previous element in the list was a note!  Could be a dynamic element, or tempo, etc.
        //
        // addNoteOnOffToTrackEventsList(element, noteChannel, pipesTrackEventsList, usePadSoundFont);
        addNoteOnOffToTrackEventsList(element, trackEventsList);
        continue;
      }
      if (element is Tempo) {
        var tempo = element as Tempo; // don't have to do this, but wanna
        // For a test, output the tempo value as text in the track at the tempo change.
        // Tempo.scaleThis(tempo, tempoScalar);
        // tempo = Tempo.scaleThis(tempo, tempoScalar);     // removing this.  The tempo has already been scaled I hope
        // var markerEvent = MarkerEvent();
        // markerEvent.text = 'Tempo ${element.bpm}';
        // trackEventsList.add(markerEvent);

        //Tempo.fillInTempoDuration(tempo, overrideTimeSig); // check on this.  If already has duration, what happens?

        addTempoChangeToTrackEventsList(tempo, trackEventsList); // also add to trackzero?
        continue;
      }
      if (element is TimeSig) { // THIS IS WRONG.  SHOULD BE 2/2 for that tune in 2/2  not 2/4 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
        // addTimeSigChangeToTrackEventsList(element, noteChannel, pipesTrackEventsList);
        addTimeSigChangeToTrackEventsList(element, trackEventsList); // also add to trackzero?
        continue;
      }
      if (element is Comment) {
        log.finest('Not putting comment into track event list: ${element.comment}');
        continue;
      }
      if (element is Text) {
        var textEvent = TextEvent();
        textEvent.deltaTime = 0; // nec?  Ignored?
        textEvent.text = element.text;
        trackEventsList.add(textEvent);
        continue;
      }
      if (element is Marker) {
        var markerEvent = MarkerEvent();
        markerEvent.deltaTime = 0; // nec?  Ignored?
        markerEvent.text = element.text;
        trackEventsList.add(markerEvent);
        continue;
      }
      log.finest('have something else not putting into the track: ${element.runtimeType}, $element');
    } // end of list of events to add to pipes track

    if (trackEventsList.isEmpty) {  // right here?????
      log.warning('What?  no events for track?');
    }
    // Is this necessary?  Was working fine without it.
    var endOfTrackEvent = EndOfTrackEvent(); // this is new too.  One above like it
    endOfTrackEvent.deltaTime = 0;
    trackEventsList.add(endOfTrackEvent); // quite sure???

    midiTracks.add(trackEventsList); // right?
    // return trackEventsList;
    return midiTracks;
  }


  void addTimeSigChangeToTrackEventsList(TimeSig timeSig, List<MidiEvent> trackEventsList) {
    var timeSignatureEvent = TimeSignatureEvent();
    timeSignatureEvent.type = 'timeSignature';
    timeSignatureEvent.numerator = timeSig.numerator;
    timeSignatureEvent.denominator = timeSig.denominator;
    timeSignatureEvent.metronome = 18; // for module synchronization  What?
    timeSignatureEvent.thirtyseconds = 8; // Perhaps for notation purposes
    trackEventsList.add(timeSignatureEvent);
  }

  void addTempoChangeToTrackEventsList(Tempo tempo, List<MidiEvent> trackEventsList) {
    var setTempoEvent = SetTempoEvent();
    setTempoEvent.type = 'setTempo';
    // I think this next line is to account for tempos based on nonquarter notes, like 6/8 time.
    var useThisTempo = tempo.bpm / (tempo.noteDuration.firstNumber / tempo.noteDuration.secondNumber / 4); // this isn't really right.
    setTempoEvent.microsecondsPerBeat = (microsecondsPerMinute / useThisTempo).round(); // how does this affect anything?  If no tempo is set in 2nd track, then this takes precedence?
    log.finer('Adding tempo change event to some track events list, possibly track zero, but any track events list');
    trackEventsList.add(setTempoEvent);
  }



  ///
  /// Create and add a NoteOnEvent and a NoteOffEvent to the list of events for a track,
  /// The caller of this method has access to the Note which holds the nameValue and type, etc.
  /// May want to watch out for cumulative rounding errors.  "pipesLangNoteNameValue" can be
  /// a something like 1.333333, so it shouldn't be called a NameValue like "4:3" could be.
  ///
  /// Need to work out timing of notes that have grace notes, like 3 stroke ruffs.
  ///
  /// First, for a pipes drum I usually think of the note as happening at a point in time and
  /// that the note has no duration, but that's not really true.  A tenor drum has a long ring
  /// to is.  The sound decays over a long period of time.  The pipes not so much, but it
  /// too has a sound that has a duration, if only for the acoustics of the room where it was
  /// recorded.  It's just not as noticeable.  So, I should forget the idea that a note is
  /// just a point in time.  A note has a duration that is specified by the NoteOn and NoteOff
  /// events.  When the NoteOff event happens, then the note's duration stops.
  ///
  /// Every note has a NoteOn and NoteOff event, and both those events have a deltaTime value.
  /// DeltaTime says when the event starts relative to the previous NoteOn or NoteOff.
  /// A NoteOn event usually has a DeltaTime of 0 because it starts immediately when the
  /// previous NoteOff event occurs.  A NoteOff event has a DeltaTime that represents the
  /// duration of the note, which means the amount of time since NoteOn started.
  ///
  /// So, DeltaTime is a duration since the previous event, but for the NoteOff event it represents the
  /// duration of the note which started with a NoteOn event.
  ///
  /// This would therefore be a simple sequence of 0 followed by the note duration for the
  /// NoteOn and NoteOff sequence for each note, if we didn't have to adjust for grace notes.
  ///
  /// For notes with grace notes we need to slide the note's sound/sample to the left by
  /// the duration of the grace notes so that the principle note will be where it's expected to be.
  /// That means the the previous note's duration has to be shortened, which means it's
  /// NoteOff event's DeltaTime has to be reduced, and the current note's NoteOff deltaTime
  /// should be lengthened the same amount.  (Don't play with the NoteOn's deltaTime.  More complicated that way)
  /// But that lengthened NoteOff's deltaTime may be shortened later if the following note
  /// has grace notes.
  ///
  /// So, basically you're looking at two notes at once: the current note and the previous note.
  /// If the current note has grace notes, reduce the previous note's NoteOff deltaTime, and
  /// increase the current note's NoteOff deltaTime the same amount.  Then advance.
  /// Special condition for first note.  Maybe not last note.
  ///
  /// BUT in this method we only have access to the current note.  So the logic doesn't go here.
  ///
  /// Clean this up later.  It's too long for one thing.
  ///
  /// And should we add rest notes to track zero so that we know where to do the timesig and tempo changes?
  // double addNoteOnOffToTrackEventsList(Note note, int channel, List<MidiEvent> trackEventsList, bool usePadSoundFont) {
  double addNoteOnOffToTrackEventsList(Note note, List<MidiEvent> trackEventsList) { // add track?
    // var graceOffset = 0;
    if (note.duration == null) {
      log.severe('note should not have a null duration.');
    }

    // Determine the noteNumber for the note.  The noteNumber determines what soundFont sample to play
    note.setNoteNumber();

    // // var pipesLangNoteNameValue = (note.duration.firstNumber / note.duration.secondNumber).floor(); // is this right???????
    var pipesLangNoteNameValue = note.duration.firstNumber / note.duration.secondNumber; // is this right???????  A double?
    // if (note.noteName == NoteName.rest) {
    if (note.embellishmentAndNoteName == EmbellishmentAndNoteName.r) {
      note.velocity = 0; // new, nec?
    }


    //
    // Here it is.  Here's where the note will go into a list of midi events.
    // deltaTime has been 0, but may need to adjust for roundoffs, or perhaps for gracenotes preceding beat?
    //
    // Not sure.  But if the note is something like a three stroke ruff then it probably needs to be
    // shifted earlier in the timeline, which means subtract time off the previous note, and then add
    // that time back to the end of the note.  And to do this I need access to the previous note, or next
    // note.  And that means this adjustment has to be done before we write it to midi.  Well,
    // what happens in this method?  Do we write to midi here?  No, looks like it's just written to a
    // list.  But, noteOnEvent and noteOffEvent are midi objects, not mine.
    //
    var noteOnEvent = NoteOnEvent();
    noteOnEvent.type = 'noteOn';
    noteOnEvent.deltaTime = 0; // might need to adjust to handle roundoff???  Can you do a negative amount, and add the rest on the off note?????????????????????????????????????????
    noteOnEvent.noteNumber = note.noteNumber; // this was determined above by all that code
    noteOnEvent.velocity = note.velocity;
    noteOnEvent.channel = 0; // dumb question: What's a channel?  Will I ever need to use it?
    log.info('hey, are we shifting or not?????  note has note off delta time shift value of ${note.noteOffDeltaTimeShift}');
    trackEventsList.add(noteOnEvent);
    log.finest('addNoteOnOffToTrackEventsList() added endOnEvent $noteOnEvent to trackEventsList');

    var noteOffEvent = NoteOffEvent();
    noteOffEvent.type = 'noteOff';

    noteOffEvent.deltaTime = (4 * ticksPerBeat / pipesLangNoteNameValue).round(); // keep track of roundoff?
    noteOffEvent.deltaTime += note.noteOffDeltaTimeShift; // for grace notes.  May be zero if no grace notes, or if consecutive same grace notes, like 2 or more flams
    noteOffEvent.noteNumber = note.noteNumber;
    noteOffEvent.velocity = 0; // shouldn't this just be 0?
    noteOffEvent.channel = 0; // dumb question: What's a channel?  Will I ever need to use it?

    trackEventsList.add(noteOffEvent);
    log.finest('addNoteOnOffToTrackEventsList() added endOffvent $noteOffEvent to trackEventsList');

    num noteTicksAsDouble = 4 * ticksPerBeat / pipesLangNoteNameValue;
    var diffTicksAsDouble = noteTicksAsDouble - noteOffEvent.deltaTime;
    cumulativeRoundoffTicks += diffTicksAsDouble;

    log.finest('noteOnNoteOff, Created note events for noteNameValue ${pipesLangNoteNameValue}, '
        'deltaTime ${noteOffEvent.deltaTime} (${noteTicksAsDouble}), velocity: ${note.velocity}, '
        'number: ${note.noteNumber}, cumulative roundoff ticks: $cumulativeRoundoffTicks');
    return diffTicksAsDouble; // kinda strange
  }
}

