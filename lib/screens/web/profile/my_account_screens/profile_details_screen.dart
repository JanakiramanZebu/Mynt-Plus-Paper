import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/client_profile_all_details/profile_all_details_model.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/res/res.dart';

import 'dart:io' show Platform;


class ProfileInfoDetails extends ConsumerStatefulWidget {
  const ProfileInfoDetails({super.key});

  @override
  ConsumerState<ProfileInfoDetails> createState() => _ProfileInfoDetailsState();
}

class _ProfileInfoDetailsState extends ConsumerState<ProfileInfoDetails> {
  @override
  void initState() {
    ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
    super.initState();
  }

  bool active = false;
  bool nomineeActive = false;
  bool mtfActive = false;
  bool tradingPreferenceActive = false;
  bool formDownActive = false;

  var _formKey = GlobalKey<FormState>();

  var isLoading = false;

  void _submit() {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final profileprovider = ref.watch(profileAllDetailsProvider);
        final theme = ref.watch(themeProvider);
        bool DDPIActive =
            profileprovider.clientAllDetails.clientData!.dDPI == 'Y';
        bool POAActive =
            profileprovider.clientAllDetails.clientData!.pOA == 'Y';
        // final incomeLabels = [
        //   "Latest 6 months Bank Statement",
        //   "Latest ITR Copy",
        //   "Latest 6 months salary slip",
        //   "DP holding statement as on date",
        //   "Net worth Certificate",
        //   "Copy of Form 16 in case of salary income",
        // ];

        final accountClosureReason = [
          "Brokerage & Charges Issues",
          "Platform Trading Issues",
          "Financial & Transaction Issues",
          "Support & Service Issues",
          "Personal Reasons",

          // 'High brokerage and charges',
          // 'Annual maintenance charges',
          // 'Faced losses',
          // 'No time to focus on trading',
          // 'Moving to other broker',
        ];

        // final bankchip = [
        //   'Savings Account',
        //   'Current Account',
        // ];

        return Scaffold(
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          // appBar: AppBar(
          //   backgroundColor:
          //       theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          //   elevation: 0,
          //   leadingWidth: 41,
          //   titleSpacing: 6,
          //   leading: InkWell(
          //     onTap: () {
          //       Navigator.pop(context);
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 9),
          //       child:  Icon(
          //           Icons.arrow_back_ios,
          //           color:theme.isDarkMode
          //                       ? colors.colorWhite
          //                       : colors.colorBlack,
          //           size: 17,
          //         ),
          //     ),
          //   ),
          //   title: Text('My Account',
          //       style: textStyle(
          //           theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          //           14,
          //           FontWeight.w600)),
          // ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            // padding: EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.subText(
                                text:
                                    "UCC : ${profileprovider.clientAllDetails.clientData!.cLIENTID}",
                                theme: theme.isDarkMode,
                                fw: 1),
                            // Text(
                            //     "UCC : ${profileprovider.clientAllDetails.clientData!.cLIENTID}",
                            //     style: TextStyle(
                            //         fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(
                              height: 8,
                            ),
                            TextWidget.titleText(
                                text: profileprovider
                                        .clientAllDetails.clientData?.panName ??
                                    "",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 2),
                            // Text(
                            //     profileprovider
                            //             .clientAllDetails.clientData?.panName ??
                            //         "",
                            //     overflow: TextOverflow.ellipsis,
                            //     style: TextStyle(
                            //         fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CircleAvatar(
                        minRadius: 30,
                        backgroundColor: theme.isDarkMode
                            ? colors.colorbluegrey
                            : const Color(0xffF1F3F8),
                        child: TextWidget.custmText(
                            text: profileprovider
                                        .clientAllDetails.clientData?.panName !=
                                    null
                                ? '${profileprovider.clientAllDetails.clientData?.panName![0]}'
                                : "",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fs: 24,
                            fw: 1),

                        // Text(profileprovider.clientAllDetails.clientData?.panName!=null
                        //                       ? '${profileprovider.clientAllDetails.clientData?.panName![0]}'
                        //                       : "",style: textStyle(theme.isDarkMode
                        //   ? colors.colorWhite
                        //   : colors.colorBlack, 24, FontWeight.w600),),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                // SizedBox(height: 8),
                // Divider(
                //   thickness: 0.5,
                //   color: ref.read(themeProvider).isDarkMode
                //           ? colors.colorWhite
                //           : colors.colorBlack,),
                UserInfoCard(
                  profileprovider: profileprovider,
                  theme: theme,
                ),
                // SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                // SizedBox(height: 8),

                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                //   child:
                // ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DematDetailsCard(
                          profileprovider: profileprovider, theme: theme),
                      if (!DDPIActive && !POAActive)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                                text:
                                    "Do you want to sell your stocks without CDSL T-Pin",
                                theme: theme.isDarkMode,
                                fw: 1),

                            // Text(
                            //     "Do you want to sell your stocks without CDSL T-Pin",
                            //     style: TextStyle(
                            //         fontSize: 12, fontWeight: FontWeight.w400)),
                            ElevatedButton(
                              // style: ElevatedButton.styleFrom(
                              //   // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              //   backgroundColor: Colors.black,
                              // ),
                              onPressed: () async{
                                // if (Platform.isAndroid) {
                                //     await ref.read(fundProvider).fetchHstoken(context);
                                //       Navigator.pushNamed(
                                //           context, Routes.profileWebViewApp,
                                //           arguments: "deposltory");

                                  // } else {
                                    profileprovider.openInWebURL(context,"deposltory" );
                                  // }
                                
                                 
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                // minimumSize: Size(double.infinity, 30),
                                backgroundColor:
                                    ref.read(themeProvider).isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorWhite,
                                shape:
                                    // MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(40) ))
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  width: 1,
                                  color: ref.read(themeProvider).isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                ),
                              ),
                              child: TextWidget.subText(
                                  text: "Activate DDPI",
                                  theme: theme.isDarkMode,
                                  fw: 1),

                              // Text("Activate DDPI",
                              //     style: textStyle(
                              //         !ref.read(themeProvider).isDarkMode
                              //             ? colors.colorBlack
                              //             : colors.colorWhite,
                              //         14,
                              //         FontWeight.w500)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // const SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                // const SizedBox(height: 8),
                
                 // MTF section
                ExpansionPanelList(
                  elevation: 0,
                  expandIconColor:
                      !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  expansionCallback: (panelIndex, expanded) {
                    mtfActive = !mtfActive;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: TextWidget.titleText(
                                text: "Enable & Manage Margin Trading", theme: theme.isDarkMode, fw: 1),

                            // Text("Nominee",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: MTFSection(
                          profileprovider: profileprovider,
                          theme: theme,
                        ),
                        isExpanded: mtfActive,
                        canTapOnHeader: true),
                  ],
                ),


                // Trading Prefference section
                ExpansionPanelList(
                  elevation: 0,
                  expandIconColor:
                      !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  expansionCallback: (panelIndex, expanded) {
                    tradingPreferenceActive = !tradingPreferenceActive;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: TextWidget.titleText(
                                text: "Customize Trading Preferences",
                                theme: theme.isDarkMode,
                                fw: 1),

                            // Text("Nominee",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: TradingPreferencesCard(
                          profileprovider: profileprovider,
                          theme: theme,
                        ),
                        isExpanded: tradingPreferenceActive,
                        canTapOnHeader: true),
                  ],
                ),

                // TradingPreferencesCard(
                //     profileprovider: profileprovider, theme: theme),

                // const SizedBox(height: 8),
                // Divider(
                //     thickness: 4,
                //     color: theme.isDarkMode
                //         ? colors.darkColorDivider
                //         : colors.colorDivider),
                // const SizedBox(height: 8),

               
                // Nominee section
                ExpansionPanelList(
                  elevation: 0,
                  expandIconColor:
                      !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  expansionCallback: (panelIndex, expanded) {
                    nomineeActive = !nomineeActive;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: TextWidget.titleText(
                                text: "Manage Nominee Details",
                                theme: theme.isDarkMode,
                                fw: 1),

                            // Text("Nominee",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: UserNomineeInfoCard(
                          profileprovider: profileprovider,
                          theme: theme,
                        ),
                        isExpanded: nomineeActive,
                        canTapOnHeader: true),
                  ],
                ),

                // Form Download section
                ExpansionPanelList(
                  elevation: 0,
                  expandIconColor:
                      !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  expansionCallback: (panelIndex, expanded) async {
                              //  if (Platform.isAndroid) {
                              //       await ref.read(fundProvider).fetchHstoken(context);
                              //         Navigator.pushNamed(
                              //             context, Routes.profileWebViewApp,
                              //             arguments: "formdownload");
                              //     } else {
                                    profileprovider.openInWebURL(context,"formdownload" );
                                  // }
                                



                    // await ref.read(fundProvider).fetchHstoken(context);
                    // Navigator.pushNamed(context, Routes.profileWebViewApp,arguments: "formdownload");
                    //  profileprovider.openInWebURL(context,"formdownload");
                    // formDownActive = !formDownActive;
                    // setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: TextWidget.titleText(
                                text: "Form Download",
                                theme: theme.isDarkMode,
                                fw: 1),

                            // Text("Nominee",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: 
                        // Container(
                        //   child:ElevatedButton(
                        //     onPressed: (){
                        //      profileprovider.downloadFile("https://rekycbe.mynt.in/report/static/cmr/2025-03-13/1208040000444330.pdf");
                        //     },
                        //     child: Text("Download"),),
                        // ),
                        
                        
                        UserNomineeInfoCard(
                          profileprovider: profileprovider,
                          theme: theme,
                        ),
                        isExpanded: formDownActive,
                        canTapOnHeader: true),
                  ],
                ),

                // Account Closure
                ExpansionPanelList(
                  expandIconColor:
                      !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  elevation: 0,
                  expansionCallback: (panelIndex, expanded) {
                    active = !active;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: TextWidget.titleText(
                                text: "Request Account Closure",
                                theme: theme.isDarkMode,
                                fw: 1),

                            // const Text("Closure",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 40),
                              // const Text(
                              //   '  Account Closure ? ',
                              //   style: TextStyle(
                              //       fontSize: 20,
                              //       fontWeight:
                              //           FontWeight.bold),
                              // ),

                              if (profileprovider.chackaccbalace['stage'] ==
                                  null) ...{
                                // SizedBox(height: 20),
                                TextWidget.subText(
                                  text:
                                      "* Closing your account is a permanent and irreversible action",
                                  theme: theme.isDarkMode,
                                ),

                                // Text(
                                //   "* Closing your account is a permanent and irreversible action",
                                //  // "What's causing you to step away?",
                                //   style: TextStyle(
                                //       fontSize: 14,
                                //       fontWeight: FontWeight.w400),
                                // ),
                                // SizedBox(height: 20),

                                // DropdownButton<String>(
                                //   value: profileprovider
                                //       .selectedAccountClosureReasonValue,
                                //   hint: const Text('Select reason for closure'),
                                //   isExpanded: true,
                                //   items: accountClosureReason.map((value) {
                                //     return DropdownMenuItem<String>(
                                //       value: value,
                                //       child: Text(value),
                                //     );
                                //   }).toList(),

                                //   // const [

                                //   //   DropdownMenuItem<
                                //   //       String>(
                                //   //     value:
                                //   //         'Annual maintenance charges',
                                //   //     child: Text(
                                //   //         'Annual maintenance charges'),
                                //   //   ),
                                //   //   DropdownMenuItem<
                                //   //       String>(
                                //   //     value: 'Faced losses',
                                //   //     child: Text(
                                //   //         'Faced losses'),
                                //   //   ),
                                //   //   DropdownMenuItem<
                                //   //       String>(
                                //   //     value:
                                //   //         'No time to focus on trading',
                                //   //     child: Text(
                                //   //         'No time to focus on trading'),
                                //   //   ),
                                //   //   DropdownMenuItem<
                                //   //       String>(
                                //   //     value:
                                //   //         'Moving to other broker',
                                //   //     child: Text(
                                //   //         'Moving to other broker'),
                                //   //   ),
                                //   // ],
                                //   onChanged: (String? newValue) {
                                //     // context
                                //     //         .read(closedroup)
                                //     //         .state =
                                //     //     newValue;
                                //   },
                                // ),

                                // Text("Stage: ${popproprv.chackaccbalace['stage'] ?? 'Loading...'}"),
                                // Text("Balance: ${popproprv.chackaccbalace['balance'] ?? 'Loading...'}"),
                                SizedBox(height: 20),

                                Row(
                                  children: [
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: OutlinedButton(
                                    //     onPressed: () {
                                    //       Navigator.pop(context);
                                    //     },
                                    //     style: OutlinedButton.styleFrom(
                                    //       side: BorderSide(
                                    //           color: colors.colorBlack),
                                    //       backgroundColor: Colors.white,
                                    //       padding: const EdgeInsets.symmetric(
                                    //           vertical: 12, horizontal: 12),
                                    //       shape: RoundedRectangleBorder(
                                    //         borderRadius:
                                    //             BorderRadius.circular(4),
                                    //       ),
                                    //     ),
                                    //     child: Text(
                                    //       'Close',
                                    //       style: TextStyle(
                                    //           color: colors.colorBlack),
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton(
                                        onPressed: () async {

                                // if (Platform.isAndroid) {
                                //     await ref.read(fundProvider).fetchHstoken(context);
                                //       Navigator.pushNamed(
                                //           context, Routes.profileWebViewApp,
                                //           arguments: "closure");

                                //   } else {
                                    profileprovider.openInWebURL(context,"closure" );
                                  // }
                                


                                          // await context
                                          //     .read(fundProvider)
                                          //     .fetchHstoken(context);
                                          // Navigator.pushNamed(
                                          //     context, Routes.profileWebViewApp,
                                          //     arguments: "closure");
                                          // profileprovider.openInWebURL(context,"closure");

                                          // profileprovider.clearProfilePop(
                                          //     context, 'accclose');

                                          // profileprovider.closeaccnalprov(
                                          //   profileprovider
                                          //       .selectedAccountClosureReasonValue!,
                                          //   (profileprovider
                                          //       .clientAllDetails.clientData),
                                          // );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        child: TextWidget.subText(
                                            text: 'Close Account',
                                            theme: !theme.isDarkMode,
                                            fw: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              },
                              // Text("1111Stage 2: Negative Balance${popproprv.chackaccbalace['balance'] }"),

                              // if (profileprovider.chackaccbalace['stage'] ==
                              //     "Stage 2: Negative Balance") ...{
                              //   const SizedBox(height: 5),
                              //   Text(
                              //     "You have a ledger balance of Rs ${profileprovider.chackaccbalace['balance']} in your ${profileprovider.clientAllDetails.clientData?.cLIENTID ?? ""}. Please settle the outstanding amount so we can proceed further.",
                              //     style: const TextStyle(
                              //       color: Color.fromARGB(255, 0, 0, 0),
                              //       fontSize: 18,
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //   ),
                              //   const SizedBox(height: 20),
                              //   Row(
                              //     children: [
                              //       Expanded(
                              //         flex: 1,
                              //         child: OutlinedButton(
                              //           onPressed: () {
                              //             Navigator.pop(context);
                              //           },
                              //           style: OutlinedButton.styleFrom(
                              //             side: BorderSide(
                              //                 color: colors.colorBlack),
                              //             backgroundColor: const Color.fromARGB(
                              //                 255, 0, 0, 0),
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 12, horizontal: 12),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //           ),
                              //           child: Text(
                              //             'Close',
                              //             style: TextStyle(
                              //                 color: colors.colorWhite),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // },

                              // if (profileprovider.chackaccbalace['stage'] ==
                              //     "Stage 1: Positive Balance") ...{
                              //   const SizedBox(height: 5),
                              //   Text(
                              //     "Please withdraw your available balance of  ${profileprovider.clientAllDetails.clientData?.cLIENTID ?? ""}. before submitting your closure request.",
                              //     style: const TextStyle(
                              //       color: Color.fromARGB(255, 0, 0, 0),
                              //       fontSize: 18,
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //   ),
                              //   const SizedBox(height: 20),
                              //   Row(
                              //     children: [
                              //       Expanded(
                              //         flex: 1,
                              //         child: OutlinedButton(
                              //           onPressed: () {
                              //             Navigator.pop(context);
                              //           },
                              //           style: OutlinedButton.styleFrom(
                              //             side: BorderSide(
                              //                 color: colors.colorBlack),
                              //             backgroundColor: const Color.fromARGB(
                              //                 255, 0, 0, 0),
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 12, horizontal: 12),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //           ),
                              //           child: Text(
                              //             'Close',
                              //             style: TextStyle(
                              //                 color: colors.colorWhite),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // },

                              // if (profileprovider.chackaccbalace['stage'] ==
                              //     "Stage 5: Zero Balance & Some Holdings") ...{
                              //   SizedBox(height: 20),
                              //   const Text(
                              //     'Kindly transfer  your stocks to another demat account according to your wish',
                              //     style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              //   SizedBox(height: 20),
                              //   const Text(
                              //     'Please enter your another Demat account details',
                              //     style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              //   SizedBox(height: 20),
                              //   SizedBox(height: 15),
                              //   Text("DP ID *",
                              //       style: textStyle(
                              //           const Color.fromARGB(255, 0, 0, 0),
                              //           15,
                              //           FontWeight.w600)),
                              //   TextFormField(
                              //     controller:
                              //         profileprovider.closureDPIDController,
                              //     onChanged: (value) {
                              //       // context
                              //       //         .read(closdpidpro)
                              //       //         .state =
                              //       //     value; // Update state
                              //     },
                              //     decoration: const InputDecoration(
                              //       hintText: 'DP ID ',
                              //       border: UnderlineInputBorder(),
                              //     ),
                              //   ),
                              //   SizedBox(height: 15),
                              //   Text("BO ID *",
                              //       style: textStyle(
                              //           const Color.fromARGB(255, 0, 0, 0),
                              //           15,
                              //           FontWeight.w600)),
                              //   TextFormField(
                              //     controller:
                              //         profileprovider.closureBOIDController,
                              //     onChanged: (value) {
                              //       // context
                              //       //         .read(closeboidprov)
                              //       //         .state =
                              //       //     value; // Update state
                              //     },
                              //     decoration: const InputDecoration(
                              //       hintText: 'BO ID ',
                              //       border: UnderlineInputBorder(),
                              //     ),
                              //   ),
                              //   SizedBox(height: 20),
                              //   Text(
                              //       "Attach a copy of the CMR that is either digitally signed or sealed, and physically signed by the respective DP *",
                              //       style: textStyle(
                              //           const Color.fromARGB(255, 0, 0, 0),
                              //           15,
                              //           FontWeight.w600)),
                              //   SizedBox(height: 15),
                              //   SizedBox(height: 0),
                              //   Text("Proof Type *",
                              //       style: textStyle(
                              //           const Color.fromARGB(255, 0, 0, 0),
                              //           15,
                              //           FontWeight.w600)),
                              //   ElevatedButton(
                              //     child: Text('UPLOAD FILE'),
                              //     onPressed: () async {
                              //       var picked =
                              //           await FilePicker.platform.pickFiles();

                              //       if (picked != null &&
                              //           picked.files.first.path != null) {
                              //         String filePath =
                              //             picked.files.first.path!;
                              //         String fileName = picked.files.first.name;

                              //         print("Selected File: $fileName");
                              //         print("File Path: $filePath");

                              //         // Store file path in provider
                              //         // context
                              //         //     .read(filePathProvider)
                              //         //     .state = filePath;
                              //       }

                              //       Text("elseee");
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //       elevation: 0,
                              //       backgroundColor: colors.colorBlack,
                              //       padding: const EdgeInsets.symmetric(
                              //           vertical: 12, horizontal: 12),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(4),
                              //       ),
                              //     ),
                              //   ),
                              //   const SizedBox(height: 20),
                              //   Row(
                              //     children: [
                              //       Expanded(
                              //         flex: 1,
                              //         child: OutlinedButton(
                              //           onPressed: () {
                              //             Navigator.pop(context);
                              //           },
                              //           style: OutlinedButton.styleFrom(
                              //             side: BorderSide(
                              //                 color: colors.colorBlack),
                              //             backgroundColor: Colors.white,
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 12, horizontal: 12),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //           ),
                              //           child: Text(
                              //             'Close',
                              //             style: TextStyle(
                              //                 color: colors.colorBlack),
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(width: 10),
                              //       Expanded(
                              //         flex: 1,
                              //         child: ElevatedButton(
                              //           onPressed: () {
                              //           },
                              //           style: ElevatedButton.styleFrom(
                              //             elevation: 0,
                              //             backgroundColor: colors.colorBlack,
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 12, horizontal: 12),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //           ),
                              //           child: Text('Submit'),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // }
                            ],
                          ),
                        ),
                        isExpanded: active,
                        canTapOnHeader: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget changeEmailBottomSheetWidget(
      ProfileProvider profileprovider, ThemesProvider theme) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 40),
              const Text(
                ' Email change request ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Old email id",
                  style: textStyle(
                      const Color.fromARGB(255, 0, 0, 0), 14, FontWeight.w600)),
              TextFormField(
                initialValue:
                    profileprovider.clientAllDetails.clientData?.cLIENTIDMAIL ??
                        "",
                readOnly: true, // Makes the field non-editable
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("New email id *",
                  style: textStyle(
                      const Color.fromARGB(255, 0, 0, 0), 16, FontWeight.w600)),
              TextFormField(
                controller: profileprovider.newEmailController,
                //  autovalidate: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,

                validator: (input) {
                  print("INPUT :: $input");
                  return RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(input ?? "")
                      ? null
                      : "Enter a valid email";
                },
                // onChanged: (value) {
                //       print("value :: $value");
                //        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value) ? null : "Check your email";
                //     },
                decoration: const InputDecoration(
                  hintText: 'New email id',
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              if (profileprovider.responseval == "success send mail") ...[
                Text(
                  "Enter a 4-digit Otp *",
                  style: textStyle(
                    const Color.fromARGB(255, 0, 0, 0),
                    16,
                    FontWeight.w600,
                  ),
                ),
                TextFormField(
                  controller: profileprovider.newEmailOTPController,
                  onChanged: (value) {
                    // ref.read(emailotpver).state =
                    //     value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter Otp',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ],
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 1, // Takes 50% width
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        profileprovider.newEmailController.clear();
                        profileprovider.newEmailOTPController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: colors.colorBlack), // Border color
                        backgroundColor: Colors.white, // Background color
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: colors.colorBlack),
                        // Text color
                      ),
                    ),
                  ),

                  SizedBox(width: 10), // Adds spacing between buttons
                  if (profileprovider.responseval != "success send mail")
                    Expanded(
                      flex: 1, // Takes 50% width
                      child: ElevatedButton(
                        onPressed: () {
                          String enteredText = "";
                          // context
                          //   .read(textFieldProvider)
                          //   .state;

                          profileprovider.emaileotpfun(
                            enteredText,
                            (profileprovider
                                    .clientAllDetails.clientData?.cLIENTIDMAIL)
                                .toString(),
                            (profileprovider
                                    .clientAllDetails.clientData?.cLIENTNAME)
                                .toString(),
                            (profileprovider
                                    .clientAllDetails.clientData?.cLIENTDPCODE)
                                .toString(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: colors.colorBlack,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('Submit'),
                      ),
                    ),

                  if (profileprovider.responseval == "success send mail")
                    Expanded(
                      flex: 1, // Takes 50% width
                      child: ElevatedButton(
                        onPressed: () {
                          // String emilotetext = context
                          //     .read(emailotpver)
                          //     .state;
                          // String newmailtext = context
                          //     .read(textFieldProvider)
                          //     .state;

                          // profileprovider.emailotpres(
                          //   emilotetext,
                          //   newmailtext,
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: colors.colorBlack,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('Submit otp'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget changeMobileBottomSheetWidget(
      ProfileProvider profileprovider, ThemesProvider theme) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   ' Mobile change request ',
            //   style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 40),
            const Text(
              ' Mobile change request ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            Text("Present Number",
                style: textStyle(
                    const Color.fromARGB(255, 0, 0, 0), 17, FontWeight.w600)),
            TextFormField(
              initialValue:
                  profileprovider.clientAllDetails.clientData?.mOBILENO ?? "",
              readOnly: true, // Makes the field non-editable
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("New Mobile number  *",
                style: textStyle(
                    const Color.fromARGB(255, 0, 0, 0), 17, FontWeight.w600)),
            TextFormField(
              controller: profileprovider.newMobController,
              onChanged: (value) {
                // ref.read(newmobilno).state =
                //     value; // Update state
              },
              decoration: const InputDecoration(
                hintText: 'New Mobile no',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (profileprovider.mobileotp == "otp sent") ...[
              Text(
                "Enter a 4-digit Otp *",
                style: textStyle(
                  const Color.fromARGB(255, 0, 0, 0),
                  15,
                  FontWeight.w600,
                ),
              ),
              TextFormField(
                controller: profileprovider.newMobOTPController,
                onChanged: (value) {
                  // ref.read(mobilotpval).state =
                  //     value; // Update state
                },
                decoration: const InputDecoration(
                  hintText: 'Enter Otp',
                  border: UnderlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 1, // Takes 50% width
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: colors.colorBlack), // Border color
                      backgroundColor: Colors.white, // Background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: colors.colorBlack), // Text color
                    ),
                  ),
                ),

                SizedBox(width: 10), // Adds spacing between buttons

                if (profileprovider.mobileotp != "otp sent")
                  Expanded(
                    flex: 1, // Takes 50% width
                    child: ElevatedButton(
                      onPressed: () {
                        String newmobilenotext =
                            profileprovider.newMobOTPController.text;

                        profileprovider.mobileotpfun(
                            newmobilenotext,
                            (profileprovider
                                    .clientAllDetails.clientData?.cLIENTIDMAIL)
                                .toString(),
                            (profileprovider
                                    .clientAllDetails.clientData?.mOBILENO)
                                .toString(),
                            (profileprovider.clientAllDetails.clientData));
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colors.colorBlack,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text('Submit'),
                    ),
                  ),

                if (profileprovider.mobileotp == "otp sent")
                  Expanded(
                    flex: 1, // Takes 50% width
                    child: ElevatedButton(
                      onPressed: () {
                        String newmobilenotext =
                            profileprovider.newMobController.text;
                        String mobileotptext =
                            profileprovider.newMobOTPController.text;
                        profileprovider.mobileotpverify(
                          newmobilenotext,
                          mobileotptext,
                          (profileprovider.clientAllDetails.clientData),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colors.colorBlack,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('Submit otp'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget changeAddressBottomSheetWidget(
      ProfileProvider profileprovider, ThemesProvider theme) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            const Text(
              ' Address change request ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text("Old Address",
                style: textStyle(
                    const Color.fromARGB(255, 0, 0, 0), 15, FontWeight.w600)),
            SizedBox(height: 10),
            Text(
              "${profileprovider.clientAllDetails.clientData?.cLRESIADD1}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD2}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD3}" ??
                  "",
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const Divider(color: Color(0xffDDDDDD)),
            SizedBox(height: 20),
            Text(
              'New Address *',
              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                16,
                FontWeight.w600,
              ),
            ),
            TextFormField(
              controller: profileprovider.newAddressController,
              onChanged: (value) {
                // ref.read(newaddprov).state =
                //     value; // Update state
              },
              decoration: const InputDecoration(
                hintText: 'New Address ',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1, // Takes 50% width
                  child: Column(
                    // Added a Column to wrap both Text and TextFormField
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pincode *',
                        style: textStyle(
                          const Color.fromARGB(255, 0, 0, 0),
                          16,
                          FontWeight.w600,
                        ), // Text color
                      ),
                      TextFormField(
                        controller: profileprovider.newAddressPincodeController,
                        onChanged: (value) {
                          // context
                          //         .read(pincodeprov)
                          //         .state =
                          //     value; // Update state
                        },
                        decoration: const InputDecoration(
                          hintText: 'Pincode',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10), // Adds spacing between buttons

                Expanded(
                  flex: 1, // Takes 50% width
                  child: Column(
                    // Added a Column to wrap both Text and TextFormField
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'District *',
                        style: textStyle(
                          const Color.fromARGB(255, 0, 0, 0),
                          16,
                          FontWeight.w600,
                        ), // Text color
                      ),
                      TextFormField(
                        controller:
                            profileprovider.newAddressDistrictController,
                        onChanged: (value) {
                          // context
                          //         .read(districtprov)
                          //         .state =
                          //     value; // Update state
                        },
                        decoration: const InputDecoration(
                          hintText: 'District ',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1, // Takes 50% width
                  child: Column(
                    // Added a Column to wrap both Text and TextFormField
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'State * ',
                        style: textStyle(
                          const Color.fromARGB(255, 0, 0, 0),
                          16,
                          FontWeight.w600,
                        ), // Text color
                      ),
                      TextFormField(
                        controller: profileprovider.newAddressStateController,
                        onChanged: (value) {
                          // context
                          //         .read(stateprov)
                          //         .state =
                          //     value; // Update state
                        },
                        decoration: const InputDecoration(
                          hintText: 'State ',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10), // Adds spacing between buttons

                Expanded(
                  flex: 1, // Takes 50% width
                  child: Column(
                    // Added a Column to wrap both Text and TextFormField
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Country *',
                        style: textStyle(
                          const Color.fromARGB(255, 0, 0, 0),
                          16,
                          FontWeight.w600,
                        ), // Text color
                      ),
                      TextFormField(
                        controller: profileprovider.newAddressCountryController,
                        onChanged: (value) {
                          // context
                          //         .read(countryprov)
                          //         .state =
                          //     value; // Update state
                        },
                        decoration: const InputDecoration(
                          hintText: 'Country ',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Proof Type *",
              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                16,
                FontWeight.w600,
              ),
            ),
            TextFormField(
              controller: profileprovider.newAddressProofTypeController,
              onChanged: (value) {
                // ref.read(proofprov).state =
                //     value; // Update state
              },
              decoration: const InputDecoration(
                hintText: 'Proof Type',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('UPLOAD FILE'),
              onPressed: () async {
                var picked = await FilePicker.platform.pickFiles();

                if (picked != null && picked.files.first.path != null) {
                  String filePath = picked.files.first.path!;
                  String fileName = picked.files.first.name;

                  print("Selected File: $fileName");
                  print("File Path: $filePath");

                  // Store file path in provider
                  // context
                  //     .read(filePathProvider)
                  //     .state = filePath;
                }

                Text("elseee");
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: colors.colorBlack,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 50),
            // SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 1, // Takes 50% width
                  child: OutlinedButton(
                    onPressed: () {
                      profileprovider.clearProfilePop(context, 'manbank');
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: colors.colorBlack), // Border color
                      backgroundColor: Colors.white, // Background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: colors.colorBlack),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1, // Takes 50% width
                  child: ElevatedButton(
                    onPressed: () {
                      // String newaddresswtext =
                      //     context
                      //         .read(newaddprov)
                      //         .state;
                      // String pincodetext = context
                      //     .read(pincodeprov)
                      //     .state;
                      // String districttext = context
                      //     .read(districtprov)
                      //     .state;
                      // String statetext = context
                      //     .read(stateprov)
                      //     .state;
                      // String countrytet = context
                      //     .read(countryprov)
                      //     .state;
                      // String prooftext = context
                      //     .read(proofprov)
                      //     .state;
                      // String filePath = context
                      //     .read(filePathProvider)
                      //     .state;

                      // if (filePath.isEmpty) {
                      //   ScaffoldMessenger.of(
                      //           context)
                      //       .showSnackBar(
                      //     SnackBar(
                      //         content: Text(
                      //             "Please select a file first!")),
                      //   );
                      //   return;
                      // }

                      // profileprovider
                      //     .addmanbankverf(
                      //   newaddresswtext,
                      //   pincodetext,
                      //   districttext,
                      //   statetext,
                      //   countrytet,
                      //   prooftext,
                      //   (profileprovider.clientAllDetails
                      //       .clientData),
                      //   filePath,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: colors.colorBlack,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Text headerText(String text, ThemesProvider theme) {
  //   return Text(text,
  //       style: textStyle(
  //           theme.isDarkMode ? colors.kColorGreyDarkTheme : colors.colorGrey,
  //           11,
  //           FontWeight.w600));
  // }

  // TextStyle textStyle(Color color, double fontSize, fWeight) {
  //   return GoogleFonts.inter(
  //     textStyle: TextStyle(
  //       fontWeight: fWeight,
  //       color: color,
  //       fontSize: fontSize,
  //     ),
  //   );
  // }

//  Widget buildBottomSheetSection(ThemesProvider theme) {
//                            return  showModalBottomSheet(
//                                             isScrollControlled: true,
//                                             useSafeArea: true,
//                                             isDismissible: true,
//                                             shape: const RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.vertical(
//                                                     top: Radius.circular(16))),
//                                             context: context,
//                                             builder: (context) => Container(
//                                               padding: EdgeInsets.only(
//                                                 bottom: MediaQuery.of(context)
//                                                     .viewInsets
//                                                     .bottom,
//                                               ),
//                                               child: BottomSheetScreen(),
//                                             ),
//                                           );
//       }




}

class UserInfoCard extends StatelessWidget {
  final ProfileProvider profileprovider;
  final ThemesProvider theme;

  const UserInfoCard(
      {super.key, required this.profileprovider, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                    text: "Manage Personal Information", theme: theme.isDarkMode, fw: 1),

                // const Text("Personal Details",
                //     style:
                //         TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),

                IconButton(
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  iconSize: 17,
                  splashRadius: 20,
                    onPressed: () async {
                            // if (Platform.isAndroid) {
                                    // await ref.read(fundProvider).fetchHstoken(context);
                                    //   Navigator.pushNamed(
                                    //       context, Routes.profileWebViewApp,
                                    //       arguments: "profile");

                                  // } else {
                                    profileprovider.openInWebURL(context,"profile" );
                                  // }
                                



                      // await ref.read(fundProvider).fetchHstoken(context);
                      // Navigator.pushNamed(context, Routes.profileWebViewApp,
                      //     arguments: "profile");
                      // profileprovider.openInWebURL(context,"profile");

                    },
                    icon: Icon(
                      Icons.edit,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      
                    ),
                 
                ),


                // InkWell(
                //   onTap: () async {
                //     await ref.read(fundProvider).fetchHstoken(context);
                //     Navigator.pushNamed(context, Routes.profileWebViewApp,
                //         arguments: "profile");
                //   },
                //   child: Icon(
                //     Icons.edit,
                //     color: theme.isDarkMode
                //         ? colors.colorLightBlue
                //         : colors.colorBlue,
                //     size: 17,
                //   ),
                // ),
              ],
            ),

            // const Text("Personal Details",
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Flexible(
                    child: UserInfoColumn(
                        label: "PAN",
                        value:profileprovider.formateDataToDisplay(profileprovider.clientAllDetails.clientData?.pANNO??"",0,3),
                            // '*******${profileprovider.clientAllDetails.clientData?.pANNO?.substring(7)}',
                        theme: theme)),
                Flexible(
                  child: UserInfoColumn(
                      label: "Mobile",
                      value: profileprovider
                              .clientAllDetails.clientData?.mOBILENO ??
                          "",
                      theme: theme,
                      editable: false),
                ),
              ],
            ),
            UserInfoColumn(
                label: "Email",
                value:
                    profileprovider.clientAllDetails.clientData?.cLIENTIDMAIL ??
                        "",
                theme: theme,
                editable: false),
            UserInfoColumn(
              label: "Address",
              value:
                  "${profileprovider.clientAllDetails.clientData?.cLRESIADD1?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD2?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD3?.toLowerCase()}",
              theme: theme,
              editable: false,
              expandable: true,
            ),
            UserInfoColumn(
                label: "Annual Income",
                value:
                    profileprovider.clientAllDetails.clientData?.aNNUALINCOME ??
                        "",
                theme: theme,
                section: "annualincome",
                editable: false)
          ],
        ),
      ),
    );
  }
}

class UserNomineeInfoCard extends StatelessWidget {
  final ProfileProvider profileprovider;
  final ThemesProvider theme;

  const UserNomineeInfoCard(
      {super.key, required this.profileprovider, required this.theme});

  @override
  Widget build(BuildContext context) {
    List<String> formatPart = profileprovider
            .clientAllDetails.clientData?.nomineeDOB
            ?.split(" ")[0]
            .split("-") ??
        [];
    String nomineeDOB = formatPart.length == 3
        ? '${formatPart[2]}-${formatPart[1]}-${formatPart[0]}'
        : "";
    return Card(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profileprovider.clientAllDetails.clientData?.nomineeName ==
                    null ||
                profileprovider.clientAllDetails.clientData?.nomineeName == "")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    //     const Text("Do you want to sell your stocks without CDSL T-Pin",
                    // style:TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                    ElevatedButton(
                      // style: ElevatedButton.styleFrom(
                      //   // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      //   backgroundColor: Colors.black,
                      // ),
                      onPressed: () async {
                        //  if (Platform.isAndroid) {
                        //             await ref.read(fundProvider).fetchHstoken(context);
                        //               Navigator.pushNamed(
                        //                   context, Routes.profileWebViewApp,
                        //                   arguments: "nominee");

                        //           } else {
                                    profileprovider.openInWebURL(context,"nominee" );
                                  // }
                                



                        // profileprovider.openInWebURL(context,"nominee");
                        // await ref.read(fundProvider).fetchHstoken(context);
                        // Navigator.pushNamed(context, Routes.profileWebViewApp,
                        //     arguments: "nominee");
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: Size(double.infinity, 35),
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        shape:
                            // MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(40) ))
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          width: 1,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
                      ),
                      child: TextWidget.titleText(
                        text: "Add Nominee",
                        theme: theme.isDarkMode,
                      ),

                      // Text("Add Nominee",
                      //     style: textStyle(
                      //         !ref.read(themeProvider).isDarkMode
                      //             ? colors.colorBlack
                      //             : colors.colorWhite,
                      //         16,
                      //         FontWeight.w500)),
                    ),
                  ],
                ),
              ),

            if (profileprovider.clientAllDetails.clientData?.nomineeName !=
                    null ||
                profileprovider.clientAllDetails.clientData?.nomineeName != "")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: "Nominee Details",
                    theme: theme.isDarkMode,
                  ),

                  // const Text("Nominee Details",
                  //     style:
                  //         TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),

            IconButton(
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  iconSize: 17,
                  splashRadius: 20,
                    onPressed: () async {

                      //  if (Platform.isAndroid) {
                      //               await ref.read(fundProvider).fetchHstoken(context);
                      //                 Navigator.pushNamed(
                      //                     context, Routes.profileWebViewApp,
                      //                     arguments: "nominee");

                      //             } else {
                                    profileprovider.openInWebURL(context,"nominee" );
                                  // }
                                

                    //  await ref.read(fundProvider).fetchHstoken(context);
                    //   Navigator.pushNamed(context, Routes.profileWebViewApp,
                    //       arguments: "nominee");
                    //  profileprovider.openInWebURL(context,"nominee");
                    },
                    icon: Icon(
                      Icons.edit,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      
                    ),
                 
                ),



                  // InkWell(
                  //   onTap: () async {
                  //     await ref.read(fundProvider).fetchHstoken(context);
                  //     Navigator.pushNamed(context, Routes.profileWebViewApp,
                  //         arguments: "nominee");
                  //   },
                  //   child: Icon(
                  //     Icons.edit,
                  //     color: theme.isDarkMode
                  //         ? colors.colorLightBlue
                  //         : colors.colorBlue,
                  //     size: 17,
                  //   ),
                  // ),
                ],
              ),

            // const Text("Personal Details",
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      // fit: FlexFit.tight,
                        child: UserInfoColumn(
                            label: "Nominee Name",
                            value: profileprovider.clientAllDetails.clientData
                                    ?.nomineeName ??
                                "",
                            theme: theme,
                            expandable: true),),
                       const SizedBox(width: 10,),
                    Flexible(
                      child: UserInfoColumn(
                          label: "Nominee Relation",
                          value: profileprovider.clientAllDetails.clientData
                                  ?.nomineeRelation ??
                              "",
                          theme: theme,
                          editable: false),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                        child: UserInfoColumn(
                            label: "Nominee DOB",
                            value: nomineeDOB,
                            theme: theme)),
                     const SizedBox(width: 10,),
                    Flexible(
                      child: UserInfoColumn(
                          label: "Nominee Percentage",
                          value: "",
                          theme: theme,
                          editable: false),
                    ),
                  ],
                ),
              ],
            ),

            // UserInfoColumn(
            //     label: "Email",
            //     value:
            //         profileprovider.clientAllDetails.clientData?.cLIENTIDMAIL ??
            //             "",
            //     editable: true),
            // UserInfoColumn(
            //     label: "Address",
            //     value:
            //         "${profileprovider.clientAllDetails.clientData?.cLRESIADD1?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD2?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD3?.toLowerCase()}",
            //     editable: true),
            // UserInfoColumn(
            //     label: "Annual Income",
            //     value:
            //         profileprovider.clientAllDetails.clientData?.aNNUALINCOME ??
            //             "",
            //     section: "annualincome",
            //     editable: true)
          ],
        ),
      ),
    );
  }
}

class DematDetailsCard extends StatelessWidget {
  final ProfileProvider profileprovider;
  final ThemesProvider theme;

  const DematDetailsCard(
      {super.key, required this.profileprovider, required this.theme});

  @override
  Widget build(BuildContext context) {
    bool DDPIActive = profileprovider.clientAllDetails.clientData!.dDPI == 'Y';
    bool POAActive = profileprovider.clientAllDetails.clientData!.pOA == 'Y';

    return Card(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text("Demat (CDSL)",
          //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                    text: "Demat (CDSL)", theme: theme.isDarkMode, fw: 1),
                // const Text("Demat (CDSL)",
                //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.isDarkMode
                            ? DDPIActive
                                ? const Color.fromARGB(255, 9, 163, 17)
                                : colors.colorGrey
                            : DDPIActive
                                ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                                : const Color(0xff666666).withOpacity(.1),
                      ),
                      child: Text("DDPI",
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 1,
                          style: textStyle(
                              theme.isDarkMode
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xff666666),
                              12,
                              FontWeight.w600)),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.isDarkMode
                            ? POAActive
                                ? const Color.fromARGB(255, 9, 163, 17)
                                : colors.colorGrey
                            : POAActive
                                ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                                : const Color(0xff666666).withOpacity(.1),
                      ),
                      child: Text("POA",
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 1,
                          style: textStyle(
                              theme.isDarkMode
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xff666666),
                              12,
                              FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // const SizedBox(
          //   height: 10,
          // ),
          Row(
            children: [
              Flexible(
                child: UserInfoColumn(
                    label: "DP ID",
                    value: profileprovider
                            .clientAllDetails.clientData?.cLIENTDPCODE!
                            .substring(0, 8) ??
                        "",
                    theme: theme),
              ),
              Flexible(
                child: UserInfoColumn(
                    label: "BO ID",
                    value: profileprovider
                            .clientAllDetails.clientData?.cLIENTDPCODE!
                            .substring(8) ??
                        "",
                    theme: theme),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text("DP Name".toUpperCase(),
          //               style: const TextStyle(
          //                   fontWeight: FontWeight.w400, fontSize: 12)),
          //           Row(
          //             children: [
          //               Container(
          //                 margin: const EdgeInsets.symmetric(horizontal: 4),
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 6, vertical: 3),
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(2),
          //                   color: ref.read(themeProvider).isDarkMode
          //                       ? DDPIActive
          //                           ? const Color.fromARGB(255, 9, 163, 17)
          //                           : const Color(0xffF1F3F8)
          //                       : DDPIActive
          //                           ? Color.fromARGB(255, 9, 255, 0)
          //                               .withOpacity(.1)
          //                           : const Color(0xff666666).withOpacity(.1),
          //                 ),
          //                 child: Text("DDPI",
          //                     overflow: TextOverflow.ellipsis,
          //                     // maxLines: 1,
          //                     style: textStyle(
          //                         ref.read(themeProvider).isDarkMode
          //                             ? const Color(0xffFFFFFF)
          //                             : const Color(0xff666666),
          //                         10,
          //                         FontWeight.w500)),
          //               ),
          //               Container(
          //                 margin: const EdgeInsets.symmetric(horizontal: 4),
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 6, vertical: 3),
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(2),
          //                   color: ref.read(themeProvider).isDarkMode
          //                       ? POAActive
          //                           ? const Color.fromARGB(255, 9, 163, 17)
          //                           : const Color(0xffF1F3F8)
          //                       : POAActive
          //                           ? Color.fromARGB(255, 9, 255, 0)
          //                               .withOpacity(.1)
          //                           : const Color(0xff666666).withOpacity(.1),
          //                 ),
          //                 child: Text("POA",
          //                     overflow: TextOverflow.ellipsis,
          //                     // maxLines: 1,
          //                     style: textStyle(
          //                         ref.read(themeProvider).isDarkMode
          //                             ? const Color(0xffFFFFFF)
          //                             : const Color(0xff666666),
          //                         10,
          //                         FontWeight.w500)),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //       TextFormField(
          //         initialValue:
          //             profileprovider.clientAllDetails.clientData?.dPNAME ??
          //                 "",
          //         readOnly: true,
          //         decoration: const InputDecoration(
          //           enabled: false,
          //           isDense: true,
          //         ),
          //         style: TextStyle(
          //           color: ref.read(themeProvider).isDarkMode
          //               ? colors.colorWhite
          //               : colors.colorBlack,
          //           fontSize: 15,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          UserInfoColumn(
              label: "DP Name",
              value: profileprovider.clientAllDetails.clientData?.dPNAME ?? "",
              theme: theme,
              expandable: true,
              ),
        ],
      ),
    );
  }

  // TextStyle textStyle(Color color, double fontSize, fWeight) {
  //   return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  // }
}

class TradingPreferencesCard extends StatelessWidget {
  final ProfileProvider profileprovider;
  final ThemesProvider theme;

  const TradingPreferencesCard(
      {super.key, required this.profileprovider, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0), // , vertical: 16.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                    text: "Segments", //Trading Preferences
                    theme: theme.isDarkMode,
                    fw: 1),
                // const Text("Trading Preferences",
                //     style:
                //         TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                IconButton(
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  iconSize: 17,
                  splashRadius: 20,
                    onPressed: () async {

                      //  if (Platform.isAndroid) {
                      //               await ref.read(fundProvider).fetchHstoken(context);
                      //                 Navigator.pushNamed(
                      //                     context, Routes.profileWebViewApp,
                      //                     arguments: "segment");

                      //             } else {
                                    profileprovider.openInWebURL(context,"segment" );
                                  // }
                                

                    //  await ref.read(fundProvider).fetchHstoken(context);
                    // Navigator.pushNamed(context, Routes.profileWebViewApp,
                    //     arguments: "segment");
                    //  profileprovider.openInWebURL(context,"segment");
                    },
                    icon: Icon(
                      Icons.edit,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      
                    ),
                 
                ),



                // InkWell(
                //   onTap: () async {
                //     await ref.read(fundProvider).fetchHstoken(context);
                //     Navigator.pushNamed(context, Routes.profileWebViewApp,
                //         arguments: "segment");
                //   },
                //   child: Icon(
                //     Icons.edit,
                //     color: theme.isDarkMode
                //         ? colors.colorLightBlue
                //         : colors.colorBlue,
                //     size: 17,
                //   ),
                // ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            CustomTFExchBadge(
                label: "Equities",
                exch: profileprovider.clientAllDetails.clientData!.segmentsData
                        ?.where((segment) => ['BSE_CASH', 'NSE_CASH']
                            .contains(segment.cOMPANYCODE)) ??
                    []),
            CustomTFExchBadge(
                label: "F&O",
                exch: profileprovider.clientAllDetails.clientData!.segmentsData
                        ?.where((segment) => ['NSE_FNO', 'BSE_FNO']
                            .contains(segment.cOMPANYCODE)) ??
                    []),
            CustomTFExchBadge(
                label: "Currency",
                exch: profileprovider.clientAllDetails.clientData!.segmentsData
                        ?.where((segment) => ['CD_NSE', 'CD_BSE']
                            .contains(segment.cOMPANYCODE)) ??
                    []),
            CustomTFExchBadge(
                label: "Commodities",
                exch: profileprovider.clientAllDetails.clientData!.segmentsData
                        ?.where((segment) => ['MCX', 'NSE_COM', 'BSE_COM']
                            .contains(segment.cOMPANYCODE)) ??
                    []),
          ],
        ),
      ),
    );
  }
}

class UserInfoColumn extends StatelessWidget {
  final ThemesProvider theme;
  final String section;
  final String label;
  final String value;
  final bool editable;
  final bool expandable;
  const UserInfoColumn(
      {super.key,
      required this.theme,
      required this.label,
      required this.value,
      this.section = "profile",
      this.editable = false,
      this.expandable = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.paraText(
            text: label.toUpperCase(),
            theme: theme.isDarkMode,
          ),

          // Text(label.toUpperCase(),
          //     style:
          //         const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
          // Text(value, softWrap: true, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),

          TextFormField(
            initialValue: value,
            // keyboardType:expandable?TextInputType.text:TextInputType.multiline,
            readOnly: true,
            maxLines: expandable ? 4 : 1,
            // expands:expandable,
            // minLines:null,
            minLines: 1,
            // maxLines: 4,

            //  maxLines: null,
            // keyboardType: TextInputType.text,

            decoration: InputDecoration(
              enabled: editable ? true : false,
              
              // isDense: true,
              // suffix: editable
              //     ? InkWell(
              //         onTap: () async {
              //           await ref.read(fundProvider).fetchHstoken(context);
              //           Navigator.pushNamed(context, Routes.profileWebViewApp,
              //               arguments: section);
              //         },
              //         child:  Icon(
              //           Icons.edit,
              //           color:  theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
              //           size: 17,
              //         ),
              //       )
              //     : null,
            ),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTFExchBadge extends ConsumerWidget {
  final String label;
  final Iterable<SegmentsData> exch;
  const CustomTFExchBadge({super.key, required this.label, required this.exch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(text: label, theme: theme.isDarkMode),
          // Text(label,
          //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          Row(
              children: exch.map((segment) {
            bool isactive = false;
            if (segment.aCTIVEINACTIVE == "A") {
              isactive = true;
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: theme.isDarkMode
                    ? isactive
                        ? const Color.fromARGB(255, 9, 163, 17)
                        : colors.colorGrey
                    : isactive
                        ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                        : const Color(0xff666666).withOpacity(.1),
              ),
              child: Text(
                  ['CD_BSE', 'CD_NSE'].contains(segment.cOMPANYCODE)
                      ? segment.cOMPANYCODE!.split("_")[1]
                      : segment.cOMPANYCODE!.split("_")[0],
                  overflow: TextOverflow.ellipsis,
                  // maxLines: 1,
                  style: textStyle(
                      theme.isDarkMode
                          ? const Color(0xffFFFFFF)
                          : const Color(0xff666666),
                      12,
                      FontWeight.w600)),
            );
          }).toList()),
        ],
      ),
    );
  }

  // TextStyle textStyle(Color color, double fontSize, fWeight) {
  //   return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  // }
}

class MTFSection extends ConsumerWidget {
  final ProfileProvider profileprovider;
  final ThemesProvider theme;

  const MTFSection(
      {super.key, required this.profileprovider, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool DDPIActive = profileprovider.clientAllDetails.clientData!.dDPI == 'Y';
    bool POAActive = profileprovider.clientAllDetails.clientData!.pOA == 'Y';
    bool mtfCl = profileprovider.clientAllDetails.clientData!.mTFCl == 'Y';
    bool mtfClAuto =
        profileprovider.clientAllDetails.clientData!.mTFClAuto == "Y";

    return Card(
      elevation: 0,
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const Text(""),
                // TextWidget.titleText(
                //     text: "Margin Trading Facility (MTF)",
                //     theme: theme.isDarkMode,
                //     fw: 1),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.isDarkMode
                            ? DDPIActive
                                ? const Color.fromARGB(255, 9, 163, 17)
                                : colors.colorGrey
                            : DDPIActive
                                ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                                : const Color(0xff666666).withOpacity(.1),
                      ),
                      child: Text("DDPI",
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 1,
                          style: textStyle(
                              theme.isDarkMode
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xff666666),
                              12,
                              FontWeight.w600)),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.isDarkMode
                            ? POAActive
                                ? const Color.fromARGB(255, 9, 163, 17)
                                : colors.colorGrey
                            : POAActive
                                ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                                : const Color(0xff666666).withOpacity(.1),
                      ),
                      child: Text("POA",
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 1,
                          style: textStyle(
                              theme.isDarkMode
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xff666666),
                              12,
                              FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),

            // Padding(
            //   padding: const EdgeInsets.only(top: 16),
            //   child: TextWidget.subText(
            //           text:" Would you like to activate Margin Trading Facility (MTF) on your account ",
            //             theme: theme.isDarkMode,
            //         ),
            // ),
            // const SizedBox(
            //   height: 16,
            // ),
            if (!DDPIActive && !POAActive)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextWidget.subText(
                    text:"You need to enable DDPI before you can proceed with processing MTF (Margin Trading Facility).",
                    theme: theme.isDarkMode,
                    fw: 1,
                    color: colors.kColorRedText),
              ),

            if ((mtfCl && mtfClAuto)) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 16,),
                  Padding(
                   padding: const EdgeInsets.only(top: 16.0),
                    child: TextWidget.subText(
                        text:
                            "You have activated the Margin Trading Facility (MTF) on your account ",
                        theme: theme.isDarkMode,
                        ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Chip(
                          label: TextWidget.subText(
                              text: 'MTF Enabled',
                              theme: theme.isDarkMode,
                              fw: 1),
                              // labelPadding:EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                          backgroundColor: theme.isDarkMode
                              ? mtfCl && mtfClAuto
                                  ? const Color.fromARGB(255, 9, 163, 17)
                                  : colors.colorGrey
                              : mtfCl && mtfClAuto
                                  ? Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                                  : const Color(0xff666666)
                                      .withOpacity(.1), // Color(0xffecf8f1),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite, // Color(0xffc1e7ba),
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            if ((profileprovider.clientAllDetails.clientData!.mTFCl == 'N' &&
                    profileprovider.clientAllDetails.clientData!.mTFClAuto ==
                        'N') &&
                (profileprovider.clientAllDetails.clientData!.dDPI == 'Y' ||
                    profileprovider.clientAllDetails.clientData!.pOA == "Y"))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                        text:
                            "Would you like to activate Margin Trading Facility (MTF) on your account ",
                        theme: theme.isDarkMode,
                        ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {

                          //  if (Platform.isAndroid) {
                          //           await ref.read(fundProvider).fetchHstoken(context);
                          //             Navigator.pushNamed(
                          //                 context, Routes.profileWebViewApp,
                          //                 arguments: "mtf");

                          //         } else {
                                    profileprovider.openInWebURL(context,"mtf" );
                                  // }
                                

                          // await ref.read(fundProvider).fetchHstoken(context);
                          // Navigator.pushNamed(context, Routes.profileWebViewApp,
                          //     arguments: "mtf");
                          //  profileprovider.openInWebURL(context,"mtf");
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          
                          backgroundColor: theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          shape:
                             
                              RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          ),
                        ),
                        child: TextWidget.subText(
                            text: "Enable MTF",
                            theme: theme.isDarkMode,
                            fw: 1),
                      
                      ),
                    ),
                  ],
                ),

             
              ),
          ],
        ),
      ),
    );
  }
}
