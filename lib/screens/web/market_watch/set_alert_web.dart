import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

class SetAlertWeb extends StatefulWidget {
  final GetQuotes depthdata;
  final DepthInputArgs wlvalue;
  const SetAlertWeb({super.key, required this.depthdata, required this.wlvalue});

  @override
  State<SetAlertWeb> createState() => _SetAlertWebState();
}

class _SetAlertWebState extends State<SetAlertWeb> {
  bool _handlesetalert = false;
  TextEditingController valueCtrl = TextEditingController();
  TextEditingController remark = TextEditingController();
  final List<String> alterItems = ['Above', 'Below'];
  final List<String> alertType = ["LTP"];
  String alertValue = "";
  String alertTypeVal = "";
  String validityTypeVal = "";
  String errorText = "";
  late GetQuotes depthdata;

  @override
  void initState() {
    alertValue = alterItems[0];
    alertTypeVal = alertType[0];
    // Initialize with widget data
    depthdata = widget.depthdata;
    super.initState();
  }

  // Process depth data with socket updates
  void _processDepthData(Map<String, dynamic> socketData) {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          depthdata.ap = "${socketData['ap']}";
          depthdata.lp = "${socketData['lp']}";
          depthdata.pc = "${socketData['pc']}";
          depthdata.o = "${socketData['o']}";
          depthdata.l = "${socketData['l']}";
          depthdata.c = "${socketData['c']}";
          depthdata.chng = "${socketData['chng']}";
          depthdata.h = "${socketData['h']}";
          depthdata.poi = "${socketData['poi']}";
          depthdata.v = "${socketData['v']}";
          depthdata.toi = "${socketData['toi']}";
        });
      }
    });
  }

  validatesetalret(value) {
    try {
      if (value == null || value.isEmpty) {
        errorText = "* Value is required";
        return;
      }

      if (alertTypeVal == "LTP" && value.isNotEmpty) {
        double enteredValue = double.parse(value);
        double currentLtp = double.parse(depthdata.lp ?? "0.0");

        // Format numbers to always show 2 decimal places
        String formattedLtp = currentLtp.toStringAsFixed(2);
        String formattedEnteredValue = enteredValue.toStringAsFixed(2);

        if (alertValue == "Above" && enteredValue <= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
        } else if (alertValue == "Below" && enteredValue >= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
        } else {
          errorText = "";
        }
      }
      //  else if (alertTypeVal == "Perc.Change") {
      //   errorText = "";
      // }
      else {
        errorText = "";
      }
    } catch (e) {
      errorText = "Please enter a valid number";
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final scripInfo = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);

      return Dialog(
        backgroundColor: theme.isDarkMode 
            ? WebDarkColors.surface 
            : WebColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: 300,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<Map>(
                  stream: ref.watch(websocketProvider).socketDataStream,
                  builder: (context, snapshot) {
                    final socketDatas = snapshot.data ?? {};
            
                    // Update depth data with WebSocket data if available
                    if (socketDatas.containsKey(widget.wlvalue.token)) {
                      _processDepthData(socketDatas[widget.wlvalue.token]);
                    }
            
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.wlvalue.symbol.toUpperCase()} ${widget.wlvalue.option}",
                          style: WebTextStyles.dialogTitle(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "${depthdata.lp != "null" ? depthdata.lp ?? depthdata.c ?? 0.00 : '0.00'}",
                              style: WebTextStyles.bodySmall(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textSecondary,
                                fontWeight: WebFonts.semiBold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${(double.tryParse(depthdata.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(depthdata.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                              style: WebTextStyles.bodySmall(
                                isDarkTheme: theme.isDarkMode,
                                color: (depthdata.chng == "null" ||
                                        depthdata.chng == null) ||
                                    depthdata.chng == "0.00"
                                    ? theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary
                                    : depthdata.chng!.startsWith("-") ||
                                        depthdata.pc!.startsWith("-")
                                        ? theme.isDarkMode ? WebDarkColors.loss : WebColors.loss
                                        : theme.isDarkMode ? WebDarkColors.profit : WebColors.profit,
                                fontWeight: WebFonts.semiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.15)
                            : Colors.black.withOpacity(.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.08)
                            : Colors.black.withOpacity(.08),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [         
          
              // Type Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type',
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                        dropdownStyleData: DropdownStyleData(
                             decoration: BoxDecoration(
                                 borderRadius:
                                     BorderRadius.circular(5),
                                 color: theme.isDarkMode
                                     ? WebDarkColors.surface
                                     : WebColors.surface,
                                 border: Border.all(
                                     color: theme.isDarkMode
                                         ? WebDarkColors.divider
                                         : WebColors.divider,
                                 ),
                             )),
                         buttonStyleData: ButtonStyleData(
                            height: 40,
                            decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.backgroundTertiary
                                    : WebColors.backgroundTertiary,
                                border: Border.all(
                                    color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary),
                                borderRadius:
                                    const BorderRadius.all(
                                        Radius.circular(5)))),
                        isExpanded: true,
                        menuItemStyleData: const MenuItemStyleData(
                          height: 32,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        ),
                        style: WebTextStyles.formInput(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textSecondary,
                        ),
                        hint: Text(
                          alertTypeVal,
                          style: WebTextStyles.helperText(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: alertType
                            .map((String item) =>
                                DropdownMenuItem<String>(
                                  value: item,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6),
                                    child: Text(
                                      item,
                                      style: WebTextStyles.formInput(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.textPrimary
                                            : WebColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: alertTypeVal,
                        onChanged: (value) {
                          setState(() {
                            alertTypeVal = value!;
                            valueCtrl.clear();
                          });
                          validatesetalret(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Alert me Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alert me',
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        splashColor: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.1),
                        highlightColor: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.05),
                        onTap: () {
                          setState(() {
                            alertValue = alertValue == "Above" ? "Below" : "Above";
                          });
                          validatesetalret(valueCtrl.text);
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? WebDarkColors.backgroundTertiary
                                : WebColors.backgroundTertiary,
                            border: Border.all(color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  alertValue,
                                  style: WebTextStyles.formInput(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textSecondary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.code,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textSecondary
                                          : WebColors.textSecondary,
                                      size: 18,
                                    ),                                               
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ENTER VALUE FIELD
              Text(
                'Enter Value',
                style: WebTextStyles.formLabel(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode
                      ? WebDarkColors.backgroundTertiary
                      : WebColors.backgroundTertiary,
                  onChanged: (value) {
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          validatesetalret(value);
                        });
                      }
                    });
                  },
                  hintText: "0",
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
                  ),
                  keyboardType: TextInputType.number,
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textSecondary,
                  ),
                  textCtrl: valueCtrl,
                  textAlign: TextAlign.start,
                  prefixIcon: SvgPicture.asset(assets.ruppeIcon,
                      fit: BoxFit.scaleDown,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary),
                ),
              ),
              if (errorText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  errorText,
                  style: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // REMARK FIELD
              Text(
                'Remarks',
                style: WebTextStyles.formLabel(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode
                      ? WebDarkColors.backgroundTertiary
                      : WebColors.backgroundTertiary,
                  hintText: "Remarks",
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
                  ),
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textSecondary,
                  ),
                  textCtrl: remark,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: errorText.isNotEmpty
                        ? theme.isDarkMode
                            ? WebDarkColors.primary.withOpacity(0.5)
                            : WebColors.primary.withOpacity(0.5)
                        : (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: _handlesetalert ||
                          valueCtrl.text.isEmpty ||
                          valueCtrl.text == "0" ||
                          errorText.isNotEmpty
                      ? () {}
                      : () async {
                          setState(() {
                            _handlesetalert = true;
                          });
              
                          if (valueCtrl.text.isEmpty) {
                            setState(() {
                              errorText = "Value cannot be empty";
                              _handlesetalert = false;
                            });
                            return;
                          }
              
                          if (valueCtrl.text == "0") {
                            setState(() {
                              errorText = "Value cannot be 0";
                              _handlesetalert = false;
                            });
                            return;
                          }
              
                          errorText = "";
              
                          try {
                            await ref.read(marketWatchProvider).fetchSetAlertWeb(
                                  widget.wlvalue.exch,
                                  widget.wlvalue.tsym,
                                  valueCtrl.text,
                                  alertValue == "Above" && alertTypeVal == "LTP"
                                      ? "LTP_A"
                                      : alertValue == "Below" &&
                                              alertTypeVal == "LTP"
                                          ? "LTP_B"
                                          : "LTP_B", // fallback
                                  context,
                                  scripInfo.alertPendingModel!.length,
                                  "${depthdata.lp}",
                                  remark.text,
                                );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _handlesetalert = false;
                              });
                            }
                          }
                        },
                  child: _handlesetalert || scripInfo.loading
                      ? const SizedBox(
                          width: 18,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                    : Text(
                        'Set alert',
                        style: WebTextStyles.buttonMd(
                          isDarkTheme: theme.isDarkMode,
                          color: errorText.isNotEmpty
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
                        ),
                      ),
                ),
              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
