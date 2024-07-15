import 'package:upgrader/upgrader.dart';

class MyUpgraderMessages extends UpgraderMessages {

  @override
  String get prompt => "Kindly Update the App.";

  @override
  String get body => "A new version of {{appName}} is available!. you have an older version.";
}


