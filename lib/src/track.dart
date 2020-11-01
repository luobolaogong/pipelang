import 'dart:io';
import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';
// Maybe change track to "track"
/// I think the idea here is to be able to insert the keywords '/track pipes' or
/// '/track tenor', ... and that track continues on as the only track being written
/// to, until either the end of the score, or there's another /track designation.
/// So, it's 'track <name>'
enum TrackId {
  chanter,
  pipes,
  met
}

class Track {
  // Why not initialize?
  TrackId id; // the default should be pipes.  How do you do that?
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
    case 'pipes':
      trackId = TrackId.pipes;
      break;
    case 'met':
    case 'metronome':
      trackId = TrackId.met;
      break;
    case 'chanter':
      trackId = TrackId.chanter;
      break;
    default:
      log.severe('Bad track identifier: $trackString');
      trackId = TrackId.chanter;
      break;
  }
  return trackId;
}

String trackIdToString(TrackId id) {
  switch (id) {
    case TrackId.met:
      return 'met';
    case TrackId.pipes:
      return 'pipes';
    case TrackId.chanter:
      return 'chanter';
    default:
      log.severe('Bad track id: $id');
      return null;
  }
}