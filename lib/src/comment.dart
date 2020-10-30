import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';
import '../pipelang.dart';

//final log = Logger('Comment');

class Comment {
  String comment;
  String toString() {
    return 'Comment: $comment';
  }
}

///
/// commentParser
///
Parser commentParser = (
    string('//') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('In commentParser and value is -->$value<--');
  var comment = Comment();
  comment.comment = value.trim();
  log.finest('Leaving CommentParser returning -->$comment<--');
  return comment;
});

