import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';

///
/// Want to do text using '/text <text>' to end of line where <text> is what should be placed in the track
///

class Text {
  String text;
  String toString() {
    return 'text: $text';
  }
}

