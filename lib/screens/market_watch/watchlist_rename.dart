import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/custom_drag_handler.dart';

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
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? Colors.black : Colors.white,
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
            const CustomDragHandler(),
            Container(
             padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget.titleText(
                    text: 'Edit Watchlist Name',
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
                          color: theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
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
                        color: theme.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: textCtrl,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                      ],
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter watchlist name",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          color: const Color(0xff666666),
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        color: colors.darkred,
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
                          ? null
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
                        backgroundColor: theme.isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: (_isProcessing || ref.read(marketWatchProvider).loading)
                          ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            )
                          : TextWidget.subText(
                              text: "Update",
                              color: !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              theme: theme.isDarkMode,
                              fw: 0,
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
