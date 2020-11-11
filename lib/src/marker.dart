import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';


///
/// Want to do markers using '/marker <text>' to end of line where <text> is what should be placed in the track
///

class Marker {
  String text;
  String toString() {
    return 'marker: $text';
  }
}
