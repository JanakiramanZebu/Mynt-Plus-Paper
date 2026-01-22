// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mynt_plus/res/res.dart';
// import '../../../../provider/thems.dart';
// import '../../../../provider/transcation_provider.dart';
// import '../../../../sharedWidget/custom_back_btn.dart';
// import '../../../../sharedWidget/functions.dart';
// import '../../../../sharedWidget/payment_loader.dart';

// class TransactionHistoryWidget extends ConsumerWidget {
//   final TranctionProvider
//       fund; // Replace 'dynamic' with the correct type for your fund object.

//   TransactionHistoryWidget({
//     required this.fund,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//      final theme = ref.watch(themeProvider);
//         final transhis = ref.watch(transcationProvider);
//     return Scaffold(
      
//       appBar: AppBar(
//         centerTitle: false,
//         leadingWidth: 41,
//         titleSpacing: 6,
//         leading: const CustomBackBtn(),
//         elevation: .4,
//         title: Text(
//             'Trancation History(${fund.tranctionHistoryModel?.data?.length ?? 0})',
//             style: textStyle(
//                 theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                 14,
//                 FontWeight.w600)),
//       ),
//       body: transhis.fundisLoad
//           ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//               const ProgressiveDotsLoader(),
//               const SizedBox(height: 3),
//               Text('This will take a few seconds.',
//                   style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
//             ])
//           : ListView.separated(
//               shrinkWrap: true,
//               physics: const ScrollPhysics(),
//               itemCount: fund.tranctionHistoryModel!.data!.length,
//               separatorBuilder: (BuildContext context, int index) {
//                 return Divider(color: colors.colorDivider);
//               },
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   leading: Padding(
//                     padding: const EdgeInsets.only(top: 5),
//                     child: SvgPicture.string(
//                       transhis.url![index],
//                       placeholderBuilder: (BuildContext context) =>
//                           const CircularProgressIndicator(),
//                       width: 35,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   title: Row(
//                     children: [
//                       Text(
//                         "${fund.tranctionHistoryModel!.data![index].transtype}",
//                         style: textStyle(
//                             colors.colorBlack, 16, FontWeight.w600),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 8),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 5, vertical: 3),
//                         decoration: BoxDecoration(
//                             color: const Color(0xffD8D8D8),
//                             borderRadius: BorderRadius.circular(5)),
//                         child: Text(
//                           fund.tranctionHistoryModel!.data![index].vendor!
//                               .toLowerCase(),
//                           style: textStyle(
//                               colors.colorBlack, 12, FontWeight.w500),
//                         ),
//                       )
//                     ],
//                   ),
//                   subtitle: Text(
//                     "${fund.tranctionHistoryModel!.data![index].dateTime}",
//                     style: textStyle(colors.colorGrey, 12, FontWeight.w500),
//                   ),
//                   trailing: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "${fund.tranctionHistoryModel!.data![index].amount}",
//                         style: textStyle(
//                             colors.colorBlack, 16, FontWeight.w600),
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                         "${fund.tranctionHistoryModel!.data![index].status?.toLowerCase()}",
//                         style: textStyle(
//                             fund.tranctionHistoryModel!.data![index]
//                                         .status ==
//                                     "SUCCESS"
//                                 ? colors.ltpgreen
//                                 : colors.darkred,
//                             14,
//                             FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
