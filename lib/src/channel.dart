import '../pipelang.dart';
/// I think the idea here is to be able to insert the keywords '/channel <num>' or
/// '/chan <num>' or '/program <num>', or '/prog <num>' and that channel
/// continues on as the only channel being written
/// to, until either the end of the score, or there's another /channel designation.
/// The default number is 0.

class Channel {
  // static const DefaultChannelNumber = 0;
  static const DefaultChannelNumber = 4; // THIS IS A TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  int number; // the default should be 0.
  Channel() {
    number = DefaultChannelNumber;
  }
  @override
  String toString() {
    return 'Channel: num: $number';
  }
}


