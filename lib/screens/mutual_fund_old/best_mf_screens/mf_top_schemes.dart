// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../provider/mf_provider.dart';
// import '../../../provider/thems.dart';
// import '../../../res/res.dart';
// import '../../../sharedWidget/functions.dart';

// class TopSchemeList extends ConsumerWidget {
//   const TopSchemeList({super.key});

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final mf = watch(mfProvider);
//     final theme = watch(themeProvider);
//     // final fund = watch(fundProvider);
//     return Column(
//       children: [
//         ListView.builder(
//                                         shrinkWrap: true,
//                                         physics: const AlwaysScrollableScrollPhysics(),
//                                         itemCount: 
//                                              mf.topSchemeListDashboard.length,
//                                         itemBuilder: (BuildContext context, int index) {
//                                           return Column(children: [
//                                             InkWell(
//                           onTap: () async {
//                             await mf.fetchFactSheet(
//                                 "${mf.bestmfFilter![index].iSIN}");
                                      
//                             // Navigator.pushNamed(context, Routes.mfStockDetail,
//                             //     arguments: mf.bestmfFilter![index]);
//                           },
//                           child: Container(
                            
//                           )
//                           ),
                                            
//                                           ]);
//                                         })
//       ],
//     );
//   }
// }