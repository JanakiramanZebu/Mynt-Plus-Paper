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
          borderRadius: BorderRadius.circular(16),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         boxShadow: const [
              BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0),
              )
            ],
         
        ),
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
                    child: TextFormField(
                      controller: textCtrl,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9 ]')),
                      ],
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter watchlist name",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: false,
                      ),
                      textAlignVertical: TextAlignVertical.center,
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
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget.captionText(
                        text: errorText!,
                        color: colors.error,
                        theme: theme.isDarkMode,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (textCtrl.text.trim().isEmpty) {
                                setState(() {
                                  errorText = "Please enter watchlist name";
                                });
                              } else {
                                List<String> watchList = [];
                                for (var element in widget.wList) {
                                  watchList.add(element.toUpperCase());
                                }
                                if (watchList.isNotEmpty) {
                                  if (watchList
                                      .contains(textCtrl.text.toUpperCase())) {
                                    setState(() {
                                      errorText =
                                          "This watchlist name already exists";
                                    });
                                  } else {
                                    await _handlebutton();
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 40), // width, height

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
                                  color: colors.textSecondaryLight),
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
    );
  }
}
