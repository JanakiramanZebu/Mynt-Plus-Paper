import 'package:flutter/material.dart';

class CustomWidgetButton extends StatelessWidget {
  final Function onPress;
  final Widget widget;
  const CustomWidgetButton({
    super.key,
    required this.onPress,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => onPress(),
        child: widget);
  }
}
