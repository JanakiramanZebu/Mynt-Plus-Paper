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
  final TextEditingController _principalCtrl = TextEditingController(text: '5000');
  final TextEditingController _finalAmountCtrl = TextEditingController(text: '25000');
  double _tenureYears = 5.0;
  String _cagrResult = '38.01'; // Default result based on initial values
  double _principalSliderValue = 5000; // Match initial value
  double _finalAmountSliderValue = 25000; // Match initial value

  @override
  void initState() {
    super.initState();
    
    // Calculate initial CAGR
    calculateCAGR();
    
    // Add listeners to text controllers
    _principalCtrl.addListener(_onPrincipalChanged);
    _finalAmountCtrl.addListener(_onFinalAmountChanged);
  }

  void _onPrincipalChanged() {
    final value = double.tryParse(_principalCtrl.text) ?? 0.0;
    if (value > 0) {
      setState(() {
        _principalSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    }
  }

  void _onFinalAmountChanged() {
    final value = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
    if (value > 0) {
      setState(() {
        _finalAmountSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    }
  }

  void calculateCAGR() {
    final principal = double.tryParse(_principalCtrl.text) ?? 0.0;
    final finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
    
    if (principal > 0 && finalAmount > 0 && _tenureYears > 0) {
      try {
        final first = finalAmount / principal;
        final second = pow(first, 1 / _tenureYears) - 1;
        final cagr = second * 100;
        
        setState(() {
          _cagrResult = cagr.toStringAsFixed(2);
        });
      } catch (e) {
        setState(() {
          _cagrResult = '0.00';
        });
      }
    } else {
      setState(() {
        _cagrResult = '0.00';
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    _principalCtrl.removeListener(_onPrincipalChanged);
    _finalAmountCtrl.removeListener(_onFinalAmountChanged);
    
    // Dispose controllers
    _principalCtrl.dispose();
    _finalAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final isDarkMode = theme.isDarkMode;
      
      // Safely parse values for chart
      final double principal = double.tryParse(_principalCtrl.text) ?? 0.0;
      final double finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
      
      final List<ChartData> donutChart = [
        ChartData('Initial Investment Value', principal, colors.colorBlack),
        ChartData('Final Investment', finalAmount, const Color(0xff015FEC)),
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
                    color: isDarkMode ? colors.colorWhite : colors.colorBlack),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              "CAGR Calculator",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                // CAGR Donut Chart
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
                                Colors.grey,
                                12,
                                FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_cagrResult %",
                              textAlign: TextAlign.center,
                              style: textStyle(
                                colors.colorBlack,
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
                            !isDarkMode ? colors.colorWhite : colors.colorBlack,
                            0,
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Initial Investment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Initial Investment",
                      style: textStyle(
                        isDarkMode ? colors.colorWhite : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 150,
                      height: 40,
                      child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: '10000',
                        textCtrl: _principalCtrl,
                        style: textStyle(
                          isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDarkMode
                                ? const Color(0xff555555)
                                : colors.colorWhite,
                          ),
                          child: SvgPicture.asset(
                            color: isDarkMode
                                ? colors.colorWhite
                                : colors.colorGrey,
                            assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                // Initial Investment Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: const Color(0xFFA3C8FF),
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: const Color(0xFFCCCCCC),
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

                // Final Investment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Investment",
                      style: textStyle(
                        isDarkMode ? colors.colorWhite : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 150,
                      height: 40,
                      child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: '10000',
                        textCtrl: _finalAmountCtrl,
                        style: textStyle(
                          isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDarkMode
                                ? const Color(0xff555555)
                                : colors.colorWhite,
                          ),
                          child: SvgPicture.asset(
                            color: isDarkMode
                                ? colors.colorWhite
                                : colors.colorGrey,
                            assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                // Final Investment Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: const Color(0xFFA3C8FF),
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: const Color(0xFFCCCCCC),
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
                
                // Duration of Investment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Duration of Investment (Years)",
                      style: textStyle(
                        isDarkMode ? colors.colorWhite : colors.colorBlack,
                        16,
                        FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_tenureYears.toStringAsFixed(0)} Yr",
                      style: textStyle(
                        isDarkMode ? colors.colorWhite : colors.colorBlack,
                        14,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Duration Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: const Color(0xFFA3C8FF),
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbColor: Colors.blue,
                    overlayColor: const Color(0xFFCCCCCC),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
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
                
                // Estimation Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Estimation",
                      style: textStyle(
                        isDarkMode ? colors.colorWhite : colors.colorBlack,
                        16,
                        FontWeight.w600
                      )
                    ),
                    const SizedBox(height: 16),
                    
                    // Initial and Final Values
                    resultRow("Initial Value", int.tryParse(_principalCtrl.text) ?? 0),
                    resultRow("Final Value", int.tryParse(_finalAmountCtrl.text) ?? 0),
                    const SizedBox(height: 4),
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
              Icon(
                Icons.circle,
                color: label == 'Initial Value'
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : const Color(0xff015FEC),
                size: 14
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500),
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
  
  TextStyle textStyle(Color color, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
