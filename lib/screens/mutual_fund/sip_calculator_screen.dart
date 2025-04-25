import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/screens/mutual_fund/widget/allocation.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';

class MFSIPSCREEN extends StatefulWidget {
  const MFSIPSCREEN({super.key});

  @override
  State<MFSIPSCREEN> createState() => _MFSIPSCREENState();
}

class _MFSIPSCREENState extends State<MFSIPSCREEN> {
  double _interestRate = 10.0;
  double _tenureYears = 12.0;
  final TextEditingController _principalCtrl =
      TextEditingController(text: '25000');

  int _totalAmount = 0;
  int _investedAmount = 0;
  int _returns = 0;

  double _sliderPrincipalAmount = 10000.0;

  @override
  void initState() {
    super.initState();
    calculateSIP();
  }

  void calculateSIP() {
    int principal = int.tryParse(_principalCtrl.text) ?? 0;
    double interestRate = _interestRate / (100 * 12);
    int tenureMonths = (_tenureYears * 12).toInt();
    if (principal < 100000) {
      if (principal > 0 &&
          interestRate > 0 &&
          tenureMonths > 0 &&
          principal <= pow(10, 9) &&
          interestRate <= (50 / (100 * 12)) &&
          tenureMonths <= 50 * 12) {
        double first = 1 + interestRate;
        double second = pow(first, tenureMonths) - 1;
        double third = second / interestRate;
        double fourth = 1 + interestRate;
        double cofinal = third * fourth;
        double finalAmount = cofinal * principal;

        int estimatedReturn =
            (finalAmount - (principal * tenureMonths)).round();

        setState(() {
          _totalAmount = finalAmount.round();
          _investedAmount = principal * tenureMonths;
          _returns = estimatedReturn;
        });
      } else {
        setState(() {
          _totalAmount = 0;
          _investedAmount = 0;
          _returns = 0;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          error(context, "Please enter an amount below ₹1,00,000."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);

      final List<ChartData> donutChart = [
        ChartData('Margin Used', double.parse("${_returns ?? 0.00}"),
            colors.colorBlack),
        ChartData('Available Margin',
            double.parse("${_investedAmount ?? 0.00}"), const Color(0xff015FEC))
      ];

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            elevation: 0.2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              "SIP Calculator",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xff6eb94b), width: 12)),
                    height: 230,
                    child: SfCircularChart(margin: EdgeInsets.zero, series: [
                      DoughnutSeries<ChartData, String>(
                          radius: "96",
                          dataSource: donutChart,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelMapper: (ChartData data, _) => "${data.y}%",
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  0,
                                  FontWeight.w600)),
                          innerRadius: "70%")
                    ])),
                const SizedBox(height: 16),

                // Principal Amount Slider + TextField

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Principal Amount",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Expanded(
                    Container(
                      width: 150, // Adjust the width as per your requirement
                      height: 40,
                      child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: '10000',
                        textCtrl: _principalCtrl,
                        onChanged: (_) {
                          if (_principalCtrl.text.isNotEmpty) {
                            _sliderPrincipalAmount =
                                double.tryParse(_principalCtrl.text) ?? 0.0;
                          }
                          calculateSIP();
                        },
                        style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: theme.isDarkMode
                                ? const Color(0xff555555)
                                : colors.colorWhite,
                          ),
                          child: SvgPicture.asset(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorGrey,
                            assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    )
                    // ),
                  ],
                ),

                // Text("Principal Amount",
                //     style: textStyle(
                //         theme.isDarkMode
                //             ? colors.colorWhite
                //             : colors.colorBlack,
                //         16,
                //         FontWeight.w600)),
                const SizedBox(height: 6),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: Color(0xFFA3C8FF),
                    inactiveTrackColor: Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: Color(0xFFCCCCCC),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 0.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Slider(
                      value: _sliderPrincipalAmount,
                      min: 1,
                      max: 100000,
                      divisions: 100000,
                      label: _sliderPrincipalAmount.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _sliderPrincipalAmount = value;
                          _principalCtrl.text = value.toStringAsFixed(0);
                        });
                        calculateSIP();
                      },
                    ),
                  ),
                ),

                // Row(
                //   children: [
                //     Expanded(
                //       child: Slider(
                //         value: _sliderPrincipalAmount,
                //         min: 1,
                //         max: 100000,
                //         divisions: 100000,
                //         label: _sliderPrincipalAmount.round().toString(),
                //         onChanged: (value) {
                //           setState(() {
                //             _sliderPrincipalAmount = value;
                //             _principalCtrl.text = value.toStringAsFixed(0);
                //           });
                //           calculateSIP();
                //         },
                //       ),
                //     ),
                //     SizedBox(width: 16),
                //     Container(
                //       width: 100,
                //       child: TextField(
                //         controller: _principalCtrl,
                //         keyboardType: TextInputType.number,
                //         decoration: InputDecoration(
                //           hintText: '10000',
                //           filled: true,
                //           fillColor: theme.isDarkMode
                //               ? colors.darkGrey
                //               : const Color(0xffF1F3F8),
                //         ),
                //         onChanged: (_) {
                //           if (_principalCtrl.text.isNotEmpty) {
                //             _sliderPrincipalAmount = double.tryParse(
                //                     _principalCtrl.text) ??
                //                 0.0;
                //           }
                //           calculateSIP();
                //         },
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Interest Rate (p.a.)",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_interestRate.toStringAsFixed(0)}%",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: Color(0xFFA3C8FF),
                    inactiveTrackColor: Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: Color(0xFFCCCCCC),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 0.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Slider(
                      value: _interestRate.clamp(1, 20),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: "${_interestRate.toStringAsFixed(0)}%",
                      onChanged: (value) {
                        setState(() => _interestRate = value);
                        calculateSIP();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tenure Period (Years)",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_tenureYears.toStringAsFixed(0)} Yr",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: Color(0xFFA3C8FF),
                    inactiveTrackColor: Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: Color(0xFFCCCCCC),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 0.0,
                    ),
                  ),
                  child: Slider(
                    value: _tenureYears.clamp(1, 50),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: "${_tenureYears.toStringAsFixed(0)} years",
                    onChanged: (value) {
                      setState(() => _tenureYears = value);
                      calculateSIP();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text("Estimation",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600)),
                const SizedBox(height: 16),

                resultRow("Principal Amount", _investedAmount),
                resultRow("Total Interest", _returns),
                resultRow("Total Amount", _totalAmount),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget resultRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle,
                  color: label == 'Total Amount'
                      ? Color(0xff6eb94b)
                      : label == 'Total Interest'
                          ? Color.fromARGB(255, 0, 0, 0)
                          : Color(0xff015FEC),
                  size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: textStyle(Color(0xff666666), 14, FontWeight.w500),
              ),
            ],
          ),
          Text(
            "₹ ${value.toStringAsFixed(0)}",
            style: textStyle(colors.colorBlack, 14, FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
