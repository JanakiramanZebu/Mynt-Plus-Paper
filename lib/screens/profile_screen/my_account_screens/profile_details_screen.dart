import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/client_profile_all_details/profile_all_details_model.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../res/res.dart';

class ProfileInfoDetails extends StatefulWidget {
  const ProfileInfoDetails({super.key});

  @override
  State<ProfileInfoDetails> createState() => _ProfileInfoDetailsState();
}

class _ProfileInfoDetailsState extends State<ProfileInfoDetails> {
  @override
  void initState() {
    context.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
    super.initState();
  }

  bool active = false;
  bool nomineeActive = false;

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
      builder: (context, ScopedReader watch, _) {
        final profileprovider = watch(profileAllDetailsProvider);
        final theme = watch(themeProvider);
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
            // padding: EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "UCC : ${profileprovider.clientAllDetails.clientData!.cLIENTID}",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                profileprovider
                                        .clientAllDetails.clientData?.panName ??
                                    "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CircleAvatar(
                              minRadius: 30,
                              backgroundColor:
                                  const Color(0xffF1F3F8),
                              child: Text(profileprovider.clientAllDetails.clientData?.panName!=null
                                                    ? '${profileprovider.clientAllDetails.clientData?.panName![0]}'
                                                    : "",style: textStyle(theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack, 24, FontWeight.w600),)
                      ,
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                SizedBox(height: 8),
                // Divider(
                //   thickness: 0.5,
                //   color: context.read(themeProvider).isDarkMode
                //           ? colors.colorWhite
                //           : colors.colorBlack,),
                UserInfoCard(
                  profileprovider: profileprovider,
                ),
                SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                SizedBox(height: 8),
                DematDetailsCard(profileprovider: profileprovider),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                //   child:
                // ),
                if (!DDPIActive && !POAActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8,),
                        const Text(
                            "Do you want to sell your stocks without CDSL T-Pin",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400)),
                                SizedBox(height: 8,),
                        ElevatedButton(
                          // style: ElevatedButton.styleFrom(
                          //   // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          //   backgroundColor: Colors.black,
                          // ),
                          onPressed: () async {
                            await context.read(fundProvider).fetchHstoken(context);
                            Navigator.pushNamed(
                                context, Routes.profileWebViewApp,
                                arguments: "deposltory");
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            // minimumSize: Size(double.infinity, 30),
                            backgroundColor:
                                context.read(themeProvider).isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                            shape:
                                // MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(40) ))
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: BorderSide(
                              width: 1,
                              color: context.read(themeProvider).isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                            ),
                          ),
                          child: Text("Activate DDPI",
                              style: textStyle(
                                  !context.read(themeProvider).isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                const SizedBox(height: 8),

                TradingPreferencesCard(profileprovider: profileprovider),

                const SizedBox(height: 8),
                Divider(
                    thickness: 4,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                const SizedBox(height: 8),

                // Nominee section
                ExpansionPanelList(
                  elevation: 0,
                  expansionCallback: (panelIndex, expanded) {
                    nomineeActive = !nomineeActive;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            title: Text("Nominee",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                          );
                        },
                        body: UserNomineeInfoCard(
                          profileprovider: profileprovider,
                        ),
                        isExpanded: nomineeActive,
                        canTapOnHeader: true),
                  ],
                ),

                // Account Closure
                ExpansionPanelList(
                  elevation: 0,
                  expansionCallback: (panelIndex, expanded) {
                    active = !active;
                    setState(() {});
                  },
                  children: [
                    ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            title: const Text("Account Closure",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
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
                                const Text(
                                  "* Closing your account is a permanent and irreversible action",
                                 // "What's causing you to step away?",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
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
                                    //             BorderRadius.circular(25),
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
                                           await context.read(fundProvider).fetchHstoken(context);
                                           Navigator.pushNamed(context, Routes.profileWebViewApp,
                                              arguments: "closure");
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
                                          backgroundColor: colors.colorBlack,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text('Close Account'),
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
                              //                   BorderRadius.circular(25),
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
                              //                   BorderRadius.circular(25),
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
                              //         borderRadius: BorderRadius.circular(25),
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
                              //                   BorderRadius.circular(25),
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
                              //                   BorderRadius.circular(25),
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
                    // context.read(emailotpver).state =
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
                          borderRadius: BorderRadius.circular(25),
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
                            borderRadius: BorderRadius.circular(25),
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
                            borderRadius: BorderRadius.circular(25),
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
                // context.read(newmobilno).state =
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
                  // context.read(mobilotpval).state =
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
                        borderRadius: BorderRadius.circular(25),
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
                          borderRadius: BorderRadius.circular(25),
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
                          borderRadius: BorderRadius.circular(25),
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
                // context.read(newaddprov).state =
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
                // context.read(proofprov).state =
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
                  borderRadius: BorderRadius.circular(25),
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
                        borderRadius: BorderRadius.circular(25),
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
                        borderRadius: BorderRadius.circular(25),
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

  const UserInfoCard({super.key, required this.profileprovider});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Personal Details",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                InkWell(
                  onTap: () async {
                    await context.read(fundProvider).fetchHstoken(context);
                    Navigator.pushNamed(context, Routes.profileWebViewApp,
                        arguments: "profile");
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF0037B7),
                    size: 17,
                  ),
                ),
              ],
            ),

            // const Text("Personal Details",
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Flexible(
                    child: UserInfoColumn(
                        label: "PAN",
                        value: profileprovider
                                .clientAllDetails.clientData?.pANNO ??
                            "")),
                Flexible(
                  child: UserInfoColumn(
                      label: "Mobile",
                      value: profileprovider
                              .clientAllDetails.clientData?.mOBILENO ??
                          "",
                      editable: false),
                ),
              ],
            ),
            UserInfoColumn(
                label: "Email",
                value:
                    profileprovider.clientAllDetails.clientData?.cLIENTIDMAIL ??
                        "",
                editable: false),
            UserInfoColumn(
                label: "Address",
                value:
                    "${profileprovider.clientAllDetails.clientData?.cLRESIADD1?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD2?.toLowerCase()}, ${profileprovider.clientAllDetails.clientData?.cLRESIADD3?.toLowerCase()}",
                editable: false,
                expandable: true,),
            UserInfoColumn(
                label: "Annual Income",
                value:
                    profileprovider.clientAllDetails.clientData?.aNNUALINCOME ??
                        "",
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

  const UserNomineeInfoCard({super.key, required this.profileprovider});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      //   backgroundColor: Colors.black,
                      // ),
                      onPressed: () async {
                        await context.read(fundProvider).fetchHstoken(context);
                        Navigator.pushNamed(context, Routes.profileWebViewApp,
                            arguments: "nominee");
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: Size(double.infinity, 30),
                        backgroundColor: context.read(themeProvider).isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        shape:
                            // MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(40) ))
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        side: BorderSide(
                          width: 1,
                          color: context.read(themeProvider).isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
                      ),
                      child: Text("Add Nominee",
                          style: textStyle(
                              !context.read(themeProvider).isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite,
                              16,
                              FontWeight.w500)),
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
                  const Text("Nominee Details",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  InkWell(
                    onTap: () async {
                      await context.read(fundProvider).fetchHstoken(context);
                      Navigator.pushNamed(context, Routes.profileWebViewApp,
                          arguments: "nominee");
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF0037B7),
                      size: 17,
                    ),
                  ),
                ],
              ),

            // const Text("Personal Details",
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            Column(children: [
              // profileprovider.clientAllDetails.nomineeData!.map((nominee){
              // return
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                          child: UserInfoColumn(
                              label: "Nominee Name",
                              value: profileprovider.clientAllDetails.clientData
                                      ?.nomineeName ??
                                  "")),
                      Flexible(
                        child: UserInfoColumn(
                            label: "Nominee Relation",
                            value: profileprovider.clientAllDetails.clientData
                                    ?.nomineeRelation ??
                                "",
                            editable: false),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: UserInfoColumn(
                              label: "Nominee DOB",
                              value: profileprovider.clientAllDetails.clientData
                                      ?.nomineeDOB ??
                                  "")),
                      Flexible(
                        child: UserInfoColumn(
                            label: "Nominee Percentage",
                            value: profileprovider
                                    .clientAllDetails.clientData?.nomineeDOB ??
                                "",
                            editable: false),
                      ),
                    ],
                  ),
                ],
              ),
              // }).toList()
            ]),

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
  const DematDetailsCard({super.key, required this.profileprovider});

  @override
  Widget build(BuildContext context) {
    bool DDPIActive = profileprovider.clientAllDetails.clientData!.dDPI == 'Y';
    bool POAActive = profileprovider.clientAllDetails.clientData!.pOA == 'Y';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text("Demat (CDSL)",
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Demat (CDSL)",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: context.read(themeProvider).isDarkMode
                                  ? DDPIActive
                                      ? const Color.fromARGB(255, 9, 163, 17)
                                      : const Color(0xffF1F3F8)
                                  : DDPIActive
                                      ? Color.fromARGB(255, 9, 255, 0)
                                          .withOpacity(.1)
                                      : const Color(0xff666666).withOpacity(.1),
                            ),
                            child: Text("DDPI",
                                overflow: TextOverflow.ellipsis,
                                // maxLines: 1,
                                style: textStyle(
                                    context.read(themeProvider).isDarkMode
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xff666666),
                                    10,
                                    FontWeight.w500)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: context.read(themeProvider).isDarkMode
                                  ? POAActive
                                      ? const Color.fromARGB(255, 9, 163, 17)
                                      : const Color(0xffF1F3F8)
                                  : POAActive
                                      ? Color.fromARGB(255, 9, 255, 0)
                                          .withOpacity(.1)
                                      : const Color(0xff666666).withOpacity(.1),
                            ),
                            child: Text("POA",
                                overflow: TextOverflow.ellipsis,
                                // maxLines: 1,
                                style: textStyle(
                                    context.read(themeProvider).isDarkMode
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xff666666),
                                    10,
                                    FontWeight.w500)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Flexible(
                  child: UserInfoColumn(
                      label: "DP ID",
                      value: profileprovider
                              .clientAllDetails.clientData?.cLIENTDPCODE!
                              .substring(0, 8) ??
                          ""),
                ),
                Flexible(
                  child: UserInfoColumn(
                      label: "BO ID",
                      value: profileprovider
                              .clientAllDetails.clientData?.cLIENTDPCODE!
                              .substring(8) ??
                          ""),
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
            //                   color: context.read(themeProvider).isDarkMode
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
            //                         context.read(themeProvider).isDarkMode
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
            //                   color: context.read(themeProvider).isDarkMode
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
            //                         context.read(themeProvider).isDarkMode
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
            //           color: context.read(themeProvider).isDarkMode
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
                value:
                    profileprovider.clientAllDetails.clientData?.dPNAME ?? ""),
          ],
        ),
      ),
    );
  }

  // TextStyle textStyle(Color color, double fontSize, fWeight) {
  //   return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  // }
}

class TradingPreferencesCard extends StatelessWidget {
  final ProfileProvider profileprovider;
  const TradingPreferencesCard({super.key, required this.profileprovider});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trading Preferences",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                InkWell(
                  onTap: () async {
                    await context.read(fundProvider).fetchHstoken(context);
                    Navigator.pushNamed(context, Routes.profileWebViewApp,
                        arguments: "segment");
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF0037B7),
                    size: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
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
  final String section;
  final String label;
  final String value;
  final bool editable;
  final bool expandable;
  const UserInfoColumn(
      {super.key,
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
          Text(label.toUpperCase(),
              style:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
          // Text(value, softWrap: true, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),

          TextFormField(
            initialValue: value,
            // keyboardType:expandable?TextInputType.text:TextInputType.multiline,
            readOnly: true,
            // maxLines: expandable ? null : 1,
            // expands:expandable,
            // minLines:null,
            minLines: 1,
            maxLines: 4,
            
            //  maxLines: null,
            // keyboardType: TextInputType.text,

            decoration: InputDecoration(
              enabled: editable ? true : false,
              isDense: true,
              // suffix: editable
              //     ? InkWell(
              //         onTap: () async {
              //           await context.read(fundProvider).fetchHstoken(context);
              //           Navigator.pushNamed(context, Routes.profileWebViewApp,
              //               arguments: section);
              //         },
              //         child: const Icon(
              //           Icons.edit,
              //           color: Color(0xFF0037B7),
              //           size: 17,
              //         ),
              //       )
              //     : null,
            ),
            style: TextStyle(
              color: context.read(themeProvider).isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTFExchBadge extends StatelessWidget {
  final String label;
  final Iterable<SegmentsData> exch;
  const CustomTFExchBadge({super.key, required this.label, required this.exch});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
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
                        : const Color(0xffF1F3F8)
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
                      10,
                      FontWeight.w500)),
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
