import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/cust_text_formfield.dart';

class CreatewatchList extends ConsumerStatefulWidget {
  final List<String> wList;
  const CreatewatchList({super.key, required this.wList});

  @override
  ConsumerState<CreatewatchList> createState() => _CreatewatchListState();
}

class _CreatewatchListState extends ConsumerState<CreatewatchList> {
  bool _isProcessing = false;
  _handlebutton() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      errorText = "";
      await ref.read(marketWatchProvider).addWatchList(textCtrl.text, context);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  TextEditingController textCtrl = TextEditingController();
  String? errorText;
  String wlName = "";
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
           borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

         
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // const CustomDragHandler(),
              Container(
               padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                          
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: 'Create Watchlist',
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          await Future.delayed(const Duration(milliseconds: 150));
                          Navigator.pop(context);
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
                            color:   theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                      child: SizedBox(
                        height: 45,
                        child: CustomTextFormField(
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          onChanged: (value) {
                            setState(() {
                              if (textCtrl.text.trim().isNotEmpty) {
                                errorText = null;
                                wlName = value.trim();
                              } else {
                                errorText = "Please enter watchlist name";
                              }
                            });
                          },
                          hintText: "Enter watchlist name",
                          hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                    fw: 0,
                                    ),
                            
                          keyboardType: TextInputType.text,
                           style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                          textCtrl: textCtrl,
                          textAlign: TextAlign.start,
                          autofocus: true,
                          inputFormate: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9 ]')),
                          ],
                        ),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextWidget.captionText(
                          text: errorText!,
                          color: theme.isDarkMode
                                                        ? colors.lossDark
                                                        : colors.lossLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? (){}
                            : () async {
                                // Use centralized validation from provider
                                final validationError = ref
                                    .read(marketWatchProvider)
                                    .validateWatchlistName(textCtrl.text);

                                if (validationError != null) {
                                  setState(() {
                                    errorText = validationError;
                                  });
                                } else {
                                  await _handlebutton();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size(0, 45), // width, height
          
                          backgroundColor: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: (_isProcessing ||
                                ref.read(marketWatchProvider).loading)
                            ? SizedBox(
                                width: 18,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:  colors.colorWhite),
                              )
                            : TextWidget.subText(
                                text: "Create",
                                color: colors.colorWhite,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
