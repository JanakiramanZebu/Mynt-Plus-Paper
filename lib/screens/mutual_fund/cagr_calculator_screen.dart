import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/screens/mutual_fund/widget/allocation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/thems.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';

class MFCAGRCAL extends StatefulWidget {
  const MFCAGRCAL({super.key});

  @override
  State<MFCAGRCAL> createState() => _MFCAGRCALState();
}

class _MFCAGRCALState extends State<MFCAGRCAL> {
  final TextEditingController _principalCtrl =
      TextEditingController(text: '5000');
  final TextEditingController _finalAmountCtrl =
      TextEditingController(text: '25000');
  double _tenureYears = 5.0;
  String _cagrResult = '';

  double _principalSliderValue = 10000;
  double _finalAmountSliderValue = 20000;
  int _toteinv = 0;
  int _finalret = 0;

  @override
  void initState() {
    super.initState();
    calculateCAGR();
      double initialValue = double.tryParse(_principalCtrl.text) ?? 0.0;
        double finalval = double.tryParse(_principalCtrl.text) ?? 0.0;
    if(initialValue > 0){
    _principalCtrl.addListener(() {
      double value = double.tryParse(_principalCtrl.text) ?? 0.0;
      setState(() {
        _principalSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    });
    }
if(finalval > 0){
  _finalAmountCtrl.addListener(() {
      double value = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
      setState(() {
        _finalAmountSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    });
}
  
  }

  void calculateCAGR() {
    double principal = double.tryParse(_principalCtrl.text) ?? 0.0;
    double finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
    double tenure = _tenureYears;

    if (principal > 0 && finalAmount > 0 && tenure > 0) {
      double first = finalAmount / principal;
      double second = pow(first, 1 / tenure) - 1;
      double cagr = second * 100;
      setState(() {
        _cagrResult = cagr.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _cagrResult = '';
      });
    }
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _finalAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final List<ChartData> donutChart = [
        ChartData('Initial Investment Value',
            double.tryParse(_principalCtrl.text) ?? 0.0, colors.colorBlack),
        ChartData(
            'Final Investment',
            double.tryParse(_finalAmountCtrl.text) ?? 0.0,
            const Color(0xff015FEC)),
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
              "CAGR Calculator",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
     Container(
  padding: EdgeInsets.zero,
  margin: EdgeInsets.zero,
  height: 230,
  child: SfCircularChart(
    margin: EdgeInsets.zero,
    annotations: <CircularChartAnnotation>[
      CircularChartAnnotation(
     widget: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'CAGR',
        textAlign: TextAlign.center,
        style: textStyle(
          Colors.grey, // Label in grey
          12,
          FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
       "${_cagrResult} %", // The value
        textAlign: TextAlign.center,
        style: textStyle(
          colors.colorBlack, // Value in black
          16,
          FontWeight.bold,
        ),
      ),
    ],
  ),
      ),
    ],
    series: <DoughnutSeries<ChartData, String>>[
      DoughnutSeries<ChartData, String>(
        animationDuration: 0,
        radius: '96',
        innerRadius: '70%',
        dataSource: donutChart,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelMapper: (ChartData data, _) => '${data.y}%',
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: textStyle(
            !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            0,
            FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
),




                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Initial Investment",
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

                const SizedBox(height: 6),

                // Text("Initial Investment",
                //     style: textStyle(
                //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //         16,
                //         FontWeight.w600)),
                // const SizedBox(height: 6),
                // CustomTextFormField(
                //   textAlign: TextAlign.start,
                //   fillColor: theme.isDarkMode
                //       ? colors.darkGrey
                //       : const Color(0xffF1F3F8),
                //   hintText: '10000',
                //   textCtrl: _principalCtrl,
                //   style: textStyle(
                //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //       14,
                //       FontWeight.w600),
                // ),

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
                      min: 1,
                      max: 10000000,
                      value: _principalSliderValue.clamp(1, 10000000),
                      label: _principalSliderValue.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _principalSliderValue = value;
                          _principalCtrl.text = value.toStringAsFixed(0);
                        });
                        calculateCAGR();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Investment",
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
                      width: 150,
                      height: 40,
                      child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: '10000',
                        textCtrl: _finalAmountCtrl,
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

                const SizedBox(height: 6),

                // Text("Final Investment (Maturity)",
                //     style: textStyle(
                //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //         16,
                //         FontWeight.w600)),
                // const SizedBox(height: 6),
                // CustomTextFormField(
                //   textAlign: TextAlign.start,
                //   fillColor: theme.isDarkMode
                //       ? colors.darkGrey
                //       : const Color(0xffF1F3F8),
                //   hintText: '20000',
                //   textCtrl: _finalAmountCtrl,
                //   style: textStyle(
                //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //       14,
                //       FontWeight.w600),
                // ),

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
                      min: 1,
                      max: 10000000,
                      value: _finalAmountSliderValue.clamp(1, 10000000),
                      label: _finalAmountSliderValue.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _finalAmountSliderValue = value;
                          _finalAmountCtrl.text = value.toStringAsFixed(0);
                        });
                        calculateCAGR();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Duration of Investment (Years)",
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
                    activeTrackColor: const Color(0xFFA3C8FF),
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: const Color(0xFFCCCCCC),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 0.0),
                  ),
                  child: Slider(
                    value: _tenureYears.clamp(1, 50),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: "${_tenureYears.toStringAsFixed(0)} Yr",
                    onChanged: (value) {
                      setState(() {
                        _tenureYears = value;
                      });
                      calculateCAGR();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Estimation",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                    const SizedBox(height: 16),

                    resultRow("Initial Value", int.parse(_principalCtrl.text)),
                    resultRow("Final Value", int.parse(_finalAmountCtrl.text)),
// resultRow("CAGR(%)", double.parse(_cagrResult).round()),
                              const SizedBox(height: 4),
                  
                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Icon(Icons.circle,
                    //               color: Color.fromARGB(255, 0, 0, 0), size: 0),
                    //           const SizedBox(width: 18),
                    //           Text(
                    //             "CAGR(%)",
                    //             style: textStyle(
                    //                 Color(0xff666666), 14, FontWeight.w500),
                    //           ),
                    //         ],
                    //       ),
                    //       Text(
                    //         "${_cagrResult} %",
                    //         style: textStyle(
                    //             colors.colorBlack, 14, FontWeight.w600),
                    //       ),
                    //     ]),
                    // Transform(
                    //   alignment: Alignment.center,
                    //   transform: Matrix4.rotationY(3.14159),
                    //   child: Container(
                    //     height: 45,
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[400],
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: LayoutBuilder(
                    //       builder: (context, constraints) {
                    //         double totalWidth = constraints.maxWidth;
                    //         double cagrPercent = double.tryParse(_cagrResult) ?? 0.0;
                    //         double barWidth = totalWidth * (cagrPercent / 100).clamp(0.0, 1.0);

                    //         int segments = (barWidth / 6).floor();
                    //         double spacing = 6.0;

                    //         return Stack(
                    //           children: [
                    //             for (int i = 0; i < segments; i++)
                    //               Positioned(
                    //                 left: i * spacing,
                    //                 top: 0,
                    //                 bottom: 0,
                    //                 child: Container(
                    //                   width: 4,
                    //                   decoration: BoxDecoration(
                    //                     color: const Color(0xFF015FEC),
                    //                     borderRadius: BorderRadius.circular(2),
                    //                   ),
                    //                 ),
                    //               ),
                    //           ],
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    //   Row(
                    //     children: [
                    //       Container(
                    //         width: 5,
                    //         height: 40,
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xFF015FEC),
                    //           borderRadius: BorderRadius.circular(2),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 10),
                    //       Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           const Text(
                    //             "Total CAGR is",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               color: Colors.grey,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 4),
                    //           Text(
                    //             "$_cagrResult%",
                    //             style: const TextStyle(
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
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
                  color: label == 'Initial Value'
                      ? Color.fromARGB(255, 0, 0, 0)
                      : label == 'Final Value'
                          ? Color(0xff015FEC)
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
