import 'package:flutter/material.dart';
// It regulates the scroll's behaviour.
class ScrollBehaviors extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
