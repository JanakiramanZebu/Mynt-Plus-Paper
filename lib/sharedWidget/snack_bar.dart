import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../res/res.dart';

SnackBar error(BuildContext context, String error) => SnackBar(
      content: ListTile(
        minLeadingWidth: 10,
        leading: const Icon(
          Icons.error,
          size: 20,
          color: Colors.red,
        ),
        title: Text(error,
            style: TextStyle(fontSize: 14, color: colors.colorWhite)),
        // trailing: InkWell(
        //   customBorder: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   onTap: () {
        //     ScaffoldMessenger.of(context). hideCurrentSnackBar();
        //   },
        //   child: SvgPicture.asset(
        //     assets.removeIcon,
        //     color: colors.colorWhite,
        //     fit: BoxFit.scaleDown,
        //   ),
        // ),
      ),
      showCloseIcon: true,
      closeIconColor: Color(0xffFFFFFF),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(vertical: 0),
      elevation: 0,
    );

SnackBar successMessage(BuildContext context, String success) => SnackBar(
      content: ListTile(
        minLeadingWidth: 10,
        leading: const Icon(Icons.check_circle_outline,
            size: 20, color: Colors.green),
        title: Text(success,
            style: TextStyle(fontSize: 14, color: colors.colorWhite)),
        // trailing: InkWell(
        //   customBorder:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //   onTap: () {
        //     ScaffoldMessenger.of(context). hideCurrentSnackBar();
        //   },
        //   child: SvgPicture.asset(
        //     assets.removeIcon,
        //     color: colors.colorWhite,
        //     fit: BoxFit.scaleDown,
        //   ),
        // ),
      ),
      showCloseIcon: true,
      closeIconColor: Color(0xffFFFFFF),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(vertical: 0),
      elevation: 0,
    );

SnackBar warningMessage(BuildContext context, String warning) => SnackBar(
      content: ListTile(
        minLeadingWidth: 10,
        leading: const Icon(
          Icons.warning_amber_outlined,
          size: 20,
          color: Colors.amber,
        ),
        title: Text(warning,
            style: TextStyle(fontSize: 14, color: colors.colorWhite)),
        trailing: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onTap: () {
            ScaffoldMessenger.of(context). hideCurrentSnackBar();
          },
          child: SvgPicture.asset(
            assets.removeIcon,
            color: colors.colorWhite,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(vertical: 0),
      elevation: 0,
    );

// void successMessage(BuildContext context, String successtoaster) {
//   final snackBar = SnackBar(
//     content: ListTile(
//       minLeadingWidth: 10,
//       leading: const Padding(
//         padding: EdgeInsets.only(top: 3.5),
//         child: Icon(
//           Icons.check_circle_outline,
//           size: 20,
//           color: Colors.green,
//         ),
//       ),
//       title: Text(successtoaster,
//           style: TextStyle(fontSize: 14, color: colors.colorWhite)),
//     ),
//     duration: const Duration(seconds: 4),
//     backgroundColor: Colors.black87,
//     behavior: SnackBarBehavior.floating,
//     padding: const EdgeInsets.symmetric(vertical: 0),
//     elevation: 0,
//   );
//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }

void warningToaster(BuildContext context, String warningtoaster) {
  final snackBar = SnackBar(
    content: ListTile(
      minLeadingWidth: 10,
      leading: const Padding(
        padding: EdgeInsets.only(top: 3.5),
        child: Icon(
          Icons.warning_amber_outlined,
          size: 20,
          color: Colors.amber,
        ),
      ),
      title: Text(warningtoaster,
          style: TextStyle(fontSize: 14, color: colors.colorWhite)),
    ),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.black87,
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(vertical: 0),
    elevation: 0,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
