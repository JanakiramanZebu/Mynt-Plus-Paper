import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';

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
    return AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color.fromARGB(255, 18, 18, 18)
            : colors.colorWhite,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        scrollable: true,
        actionsPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        titlePadding: const EdgeInsets.only(left: 16),
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rename Watchlist',
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600)),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              splashRadius: 16,
              icon: const Icon(Icons.close_rounded),
              color:
                  theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey)
        ]),
        content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              const ListDivider(),
              const SizedBox(height: 14),
              TextFormField(
                  controller: textCtrl,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                  ],
                  style: textStyles.textFieldLabelStyle.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack),
                  decoration: InputDecoration(
                      fillColor: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: "Enter watchlist name",
                      hintStyle: textStyle(Colors.grey, 13, FontWeight.w400),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      errorText: errorText,
                      errorStyle:
                          textStyle(colors.darkred, 10, FontWeight.w600),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50)),
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50))),
                  onChanged: (value) {
                    setState(() {
                      if (textCtrl.text.trim().isNotEmpty) {
                        errorText = null;
                        wlName = value.trim();
                      } else {
                        errorText = "Please enter watchlist name";
                      }
                    });
                  })
            ])),
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
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
                          borderRadius: BorderRadius.circular(50))),
                  child:
                      (_isProcessing || ref.read(marketWatchProvider).loading)
                          ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            )
                          : Text("Update",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500))))
        ]);
  }
}
