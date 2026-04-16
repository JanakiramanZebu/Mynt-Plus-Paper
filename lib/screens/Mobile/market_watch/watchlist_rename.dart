import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

class WatchListRename extends ConsumerStatefulWidget {
  final String wlname;
  const WatchListRename({super.key, required this.wlname});

  @override
  ConsumerState<WatchListRename> createState() => _WatchListRenameState();
}

class _WatchListRenameState extends ConsumerState<WatchListRename> {
  bool _isProcessing = false;
  _handlebutton() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      errorText = "";
      await ref
          .read(marketWatchProvider)
          .fetchWatchListRename(widget.wlname, textCtrl.text, context);
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
  void initState() {
    setState(() {
      textCtrl = TextEditingController(text: widget.wlname);
    });
    super.initState();
  }

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
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextWidget.titleText(
                      text: 'Edit Watchlist Name',
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
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
                              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                              theme: theme.isDarkMode,
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
                          color: colors.error,
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
                                if (textCtrl.text.trim().isEmpty) {
                                  setState(() {
                                    errorText = "Please enter watchlist name";
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
                                    color: colors.colorWhite),
                              )
                            : TextWidget.subText(
                                text: "Update",
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
