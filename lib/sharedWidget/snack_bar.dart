import 'package:flutter/material.dart';
import '../../res/res.dart';

//It serves to display information to the user.

SnackBar error(BuildContext context, String error) => SnackBar(
    content: ListTile(
        minLeadingWidth: 10,
        leading: const Icon(Icons.error, size: 20, color: Colors.red),
        title: Text(error,
            style: TextStyle(fontSize: 14, color: colors.colorWhite))),
    showCloseIcon: true,
    closeIconColor: const Color(0xffFFFFFF),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.black87,
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(vertical: 0),
    elevation: 0);

SnackBar successMessage(BuildContext context, String success) => SnackBar(
    content: ListTile(
        minLeadingWidth: 10,
        leading: const Icon(Icons.check_circle_outline,
            size: 20, color: Colors.green),
        title: Text(success,
            style: TextStyle(fontSize: 14, color: colors.colorWhite))),
    showCloseIcon: true,
    closeIconColor: const Color(0xffFFFFFF),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.black87,
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(vertical: 0),
    elevation: 0);

SnackBar warningMessage(BuildContext context, String warning) => SnackBar(
    content: ListTile(
      minLeadingWidth: 10,
      leading: const Icon(Icons.warning_amber_outlined,
          size: 20, color: Colors.amber),
      title: Text(warning,
          style: TextStyle(fontSize: 14, color: colors.colorWhite)),
    ),
    showCloseIcon: true,
    closeIconColor: const Color(0xffFFFFFF),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.black87,
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(vertical: 0),
    elevation: 0);

void warningToaster(BuildContext context, String warningtoaster) {
  final snackBar = SnackBar(
      content: ListTile(
          minLeadingWidth: 10,
          leading: const Padding(
              padding: EdgeInsets.only(top: 3.5),
              child: Icon(Icons.warning_amber_outlined,
                  size: 20, color: Colors.amber)),
          title: Text(warningtoaster,
              style: TextStyle(fontSize: 14, color: colors.colorWhite))),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(vertical: 0),
      elevation: 0);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
