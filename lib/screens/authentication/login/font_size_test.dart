// import 'package:flutter/material.dart';

// import 'package:google_fonts/google_fonts.dart';

// import '../../../../../res/res.dart';

// class AutoFontSizeTestinging extends StatefulWidget {
//   const AutoFontSizeTestinging({super.key});

//   @override
//   State<AutoFontSizeTestinging> createState() => _AutoFontSizeTestingingState();
// }

// class _AutoFontSizeTestingingState extends State<AutoFontSizeTestinging> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: colors.colorWhite,
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Premkumar",
//                   style: textStyle(
//                       colors.colorBlack, sizes.jumboFontSize, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(colors.colorBlack, sizes.extraLargeFontSize,
//                       FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(
//                       colors.colorBlue, sizes.largeFontSize, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(colors.colorBlack, sizes.extraMediumFontSize,
//                       FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(colors.colorBlack, sizes.mediumFontSize,
//                       FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(colors.colorBlack, sizes.regularFontSize,
//                       FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(
//                       colors.colorBlack, sizes.smallFontSize, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar",
//                   style: textStyle(colors.colorBlack, sizes.extraSmallFontSize,
//                       FontWeight.w500)),
//               const SizedBox(height: 8),
//               Divider(color: colors.colorBlack),
//               Text("Premkumar -11",
//                   style: textStyle(colors.colorBlack, 11, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -12",
//                   style: textStyle(colors.colorBlack, 12, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar - 14",
//                   style: textStyle(colors.colorBlack, 14, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -16",
//                   style: textStyle(colors.colorBlack, 16, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -18",
//                   style: textStyle(colors.colorBlack, 18, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -20",
//                   style: textStyle(colors.colorBlue, 20, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -24",
//                   style: textStyle(colors.colorBlack, 24, FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text("Premkumar -32",
//                   style: textStyle(colors.colorBlack, 32.0, FontWeight.w500)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
//   }
// }
