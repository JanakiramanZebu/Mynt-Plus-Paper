import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/snack_bar.dart';

class TaxPnlScreen extends StatefulWidget {
  const TaxPnlScreen({super.key});

  @override
  _TaxPnlScreenState createState() => _TaxPnlScreenState();
}

class _TaxPnlScreenState extends State<TaxPnlScreen>
    with SingleTickerProviderStateMixin {
  final tablistitems = [
    {
      "title": "Profit & Loss",
      "index": 0,
    },
    {
      "title": "Turnover",
      "index": 1,
    },
    {
      "title": "Charges",
      "index": 2,
    }
  ];
  late TabController _tabController;
  String? errorMessage;
  String? yearErrorMessage;
  // bool isLoading = false;

  void showError(String message) {
    setState(() {
      yearErrorMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.watch(ledgerProvider);

      return SafeArea(
        child: Stack(
          children: [
            Container(
             
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.titleText(
                            text: "Tax P&L",
                            theme: theme.isDarkMode,
                            fw: 1,
                          ),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                Navigator.pop(context);
                                ledgerprovider.setistaxpnlclosed(true);
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.15),
                              highlightColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: theme.isDarkMode
                                      ? const Color(0xffBDBDBD)
                                      : colors.colorGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextWidget.subText(
                        text: "Financial Year",
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                        fw: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                           color:   theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                              border: Border.all(
                                color: colors.colorBlue,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: theme.isDarkMode
                                        ? colors.colorWhite.withOpacity(0.1)
                                        : colors.colorBlack.withOpacity(0.1),
                                    onTap: ledgerprovider.yearforTaxpnl <=
                                            (ledgerprovider.yearforTaxpnlDummy -
                                                4)
                                        ? null
                                        : () {
                                            ledgerprovider.fetchtaxpnleqdata(
                                                context,
                                                ledgerprovider.yearforTaxpnl -
                                                    1);
                                          },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.chevron_left,
                                        size: 24,
                                        color: ledgerprovider.yearforTaxpnl <=
                                                (ledgerprovider
                                                        .yearforTaxpnlDummy -
                                                    4)
                                            ? Colors.grey
                                            : theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "Apr ${ledgerprovider.yearforTaxpnl} - Mar ${ledgerprovider.yearforTaxpnl + 1}",
                                  style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: theme.isDarkMode
                                        ? colors.colorWhite.withOpacity(0.1)
                                        : colors.colorBlack.withOpacity(0.1),
                                    onTap: ledgerprovider.yearforTaxpnl >=
                                            ledgerprovider.yearforTaxpnlDummy
                                        ? null
                                        : () => {
                                              ledgerprovider.fetchtaxpnleqdata(
                                                  context,
                                                  ledgerprovider.yearforTaxpnl +
                                                      1)
                                            },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.chevron_right,
                                        size: 24,
                                        color: ledgerprovider.yearforTaxpnl >=
                                                ledgerprovider
                                                    .yearforTaxpnlDummy
                                            ? Colors.grey
                                            : theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (errorMessage != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextWidget.subText(
                            text: errorMessage!,
                            theme: theme.isDarkMode,
                            color: Colors.red,
                            fw: 1,
                            align: TextAlign.left,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // PDF Option
   Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
      ),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(),
        splashColor: theme.isDarkMode ? colors.splashColorDark: colors.splashColorLight,
        highlightColor: theme.isDarkMode ? colors.highlightDark: colors.highlightLight,
        onTap: () {
          ledgerprovider.selectedFormatFunction("PDF");
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.pdfIcon,
                height: 50,  // ← Keep consistent
                width: 50,   // ← Keep consistent
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10), // ← Keep this
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // ← Center under icon
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    child: Radio<String>(
                      value: "PDF",
                      groupValue: ledgerprovider.selectedFormat,
                      onChanged: (value) {
                        if (value != null) {
                          ledgerprovider.selectedFormatFunction(value);
                        }
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  TextWidget.subText(
                    text: "PDF",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),

    // Excel Option
    Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
      ),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(),
        splashColor: theme.isDarkMode ? colors.splashColorDark: colors.splashColorLight,
        highlightColor: theme.isDarkMode ? colors.highlightDark: colors.highlightLight,
        onTap: () {
          ledgerprovider.selectedFormatFunction("Excel");
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.excelIcon,
                height: 60, 
                width: 60,  
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // ← Center under icon
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    child: Radio<String>(
                      value: "Excel",
                      groupValue: ledgerprovider.selectedFormat,
                      onChanged: (value) {
                        if (value != null) {
                          ledgerprovider.selectedFormatFunction(value);
                        }
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  TextWidget.subText(
                    text: "Excel",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            elevation: 0,
                            minimumSize: const Size(0, 45),
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () async {
                            // Check if already loading using provider state
                            if (ledgerprovider.taxpnlloading) {
                              Navigator.pop(context);
                                warningMessage(context,
                                    'Previous request is still processing'
                              );
                              return;
                            }
                            try {
                              setState(() {
                                errorMessage = null;
                              });

                                ledgerprovider.pdfdownloadfortaxpnl(
                                context,
                                ledgerprovider.taxpnleq?.data?.toJson() ?? {},
                                ledgerprovider.taxpnldercomcur?.data
                                        ?.toJson() ??
                                    {},
                                ledgerprovider.taxpnleqCharge?.toJson() ?? {},
                                ledgerprovider.yearforTaxpnl,
                              );

                              setState(() {
                                errorMessage = null;
                              });
                              Navigator.pop(context);
                              successMessage(context, 'The file will be sent to your email shortly.');

                            } catch (e) {
                              // Show error in ScaffoldMessenger
                              // Navigator.pop(context);
                                warningMessage(
                                    context, 'Error: ${e.toString()}'
                              );
                              setState(() {
                                errorMessage = e.toString();
                              });
                            }
                          },
                          child: ledgerprovider.taxpnlloading
                              ? SizedBox(
                                  width: 18,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.colorWhite,
                                  ),
                                )
                              : TextWidget.subText(
                                  text: "Sent to mail",
                                  theme: theme.isDarkMode,
                                  color: colors.colorWhite,
                                  fw: 2,
                                  align: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Helper for white text color
Color getWhiteTextColor(bool isDarkMode) => const Color(0xffFFFFFF);
