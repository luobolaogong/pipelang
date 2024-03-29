import 'package:logging/logging.dart';

final log = Logger('Dynamic');

/// Dynamics aren't used much if at all in pipe music.  It's all one volume/level.
/// But it may turn out that some volume adjustments need to be made, due to recording
/// levels or something.  Plus, on the commandline the user should be able to specify
/// a volume.  So this class is here to support these things.  But the rest of the
/// stuff, like putting dynamics into the score itself will probably not be done.
///
/// Dynamic markings in the text version, such as f, and fff apply to the notes
/// following it.  Likewise, DynamicRamp marks apply to notes following it and apply to
/// all notes prior to the next Dynamic mark.
///
/// The code does not account for errors, such as hitting another dynamicRamp marker
/// before hitting another dynamic marker, or hitting the end of the score.
/// I suppose if two hairpins were next to each other, like <> or >< then
/// you could perhaps guess what the missing dynamic would be, but for now will
/// just ignore all dynamicRamps until hit the next Dynamic marker.  If there isn't
/// one, then the DynamicRamp marker doesn't get its full value, and we should ignore
/// it when determining velocities.  So, just ignore DynamicRamps that don't have a slope.
///
/// 10/24/2020 Adding default dynamic, because some scores don't specify any dynamics
/// but have crescendos in the score, expecting the player to know what dynamic ranges
/// work in the environment.  When not specified, the default has been mf, but the
/// user can specify a starting dynamic on the command line to overwrite the default.
/// As a shorthand, in the score I could create a new dynamic marker, like '/dd' to
/// mean "return to the default dynamic, whatever that is".  This is not the most
/// recent dynamic.  It's the default value, which would be /mf if the user didn't
/// overwrite it.
class DynamicRamp {
  Dynamic startDynamic; // perhaps should store as velocity?
  Dynamic endDynamic;
  int startVelocity;
  int endVelocity;
  int totalTicksStartToEnd;
  num slope;

  @override
  String toString() {
    return 'DynamicRamp: startDynamic: $startDynamic, endDynamic: $endDynamic, startVelocity: $startVelocity, endVelocity: $endVelocity, totalTicksStartToEnd: $totalTicksStartToEnd, Slope: $slope';
  }
}

// Probably should change this to be a class, then can add other things like
// default dynamic.  Maybe, maybe not.  be careful
enum Dynamic {
  ppp,
  pp,
  p,
  mp,
  mf,
  f,
  ff,
  fff,
  dd
}

// Let's maybe just use the parabolic equation
// velocity = 1.7 * dynamic^2 + 5
// int dynamicToVelocity(Dynamic dynamic, CommandLine commandLine) {
int dynamicToVelocity(Dynamic dynamic) {
  if (dynamic == Dynamic.dd) { // don't expect this to happen for bagpipe music
    log.severe('stop here, do we want to use a Dynamic.dd for a value to convert?  No, substitute first.');
    //dynamic = Dynamic.mf; // wrong, should be the default value
  }
  //print('Parabolic2');
  num newVelocity = (10 * 0.19 * (dynamic.index + 1) * (dynamic.index + 1)).round();
  //log.finest('dynamicToVelocity(), dynamic $dynamic, with index ${dynamic.index} returns a velocity of ${newVelocity}');
  return newVelocity;

  // Parabolic1:
  // num newVelocity = (20 * (3.0 * sin(((pi / 2) * (dynamic.index+1) - 6.3)/4.0) + 3.0)).round();
  // print('\t\t\t\tHey, dynamic $dynamic, with index ${dynamic.index} gets a velocity of ${newVelocity}');
  // return newVelocity;
  // //return (1.7 * dynamic.index * dynamic.index + 5).round();
}

Dynamic stringToDynamic(dynamicString) {
  switch (dynamicString) {
    case 'ppp':
      return Dynamic.ppp;
    case 'pp':
      return Dynamic.pp;
    case 'p':
      return Dynamic.p;
    case 'mp':
      return Dynamic.mp;
    case 'mf':
      return Dynamic.mf;
    case 'f':
      return Dynamic.f;
    case 'ff':
      return Dynamic.ff;
    case 'fff':
      return Dynamic.fff;
    default:
      log.info('What kinda string is that? -->$dynamicString<--');
      return Dynamic.ff; // check this
  }
}
