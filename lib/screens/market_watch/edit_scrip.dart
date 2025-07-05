import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_internet_widget.dart';

class EditScrip extends ConsumerStatefulWidget {
  final String wlName;
  const EditScrip({super.key, required this.wlName});

  @override
  ConsumerState<EditScrip> createState() => _EditScripState();
}

class _EditScripState extends ConsumerState<EditScrip> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(marketWatchProvider).setpageName("edit");
    });
    // ref.read(networkStateProvider).networkStream();
    super.initState();
  }

  int delQty = 0;
  bool isSletcted = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final marketwatch = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);
      final internet = ref.watch(networkStateProvider);

      return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return; // If system handled back, do nothing

            marketwatch.setpageName("");
            await ref
                .read(marketWatchProvider)
                .requestMWScrip(context: context, isSubscribe: true);
            marketwatch.delQty();

            Navigator.of(context).pop(); // Proceed with back navigation
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 1,
              leadingWidth: 48,
              titleSpacing: 0,
              leading: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.grey.withOpacity(0.4),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  onTap: () {
                    marketwatch.setpageName("");
                    ref
                        .read(marketWatchProvider)
                        .requestMWScrip(context: context, isSubscribe: true);
                    marketwatch.delQty();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44, // Increased touch area
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      size: 18,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                ),
              ),

              shadowColor: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              title: TextWidget.titleText(
                  text:
                      "Edit ${widget.wlName}'s",
                      //  (${marketwatch.scrips.length})
                  color: theme.isDarkMode ? colors.textPrimaryDark :  colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                  fw: 1),
              actions: [
                Row(
                  children: [
                    InkWell(
                      onTap: marketwatch.delScripQty == 0 ||
                              internet.connectionStatus ==
                                  ConnectivityResult.none
                          ? null
                          : () {
                              marketwatch.deleteScrip(context, widget.wlName);
                            },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: marketwatch.delScripQty == 0
                                ? colors.darkred.withOpacity(.2)
                                : colors.darkred,
                            borderRadius: BorderRadius.circular(32)),
                        child: TextWidget.paraText(
                            text: marketwatch.delScripQty == 0
                                ? "Delete"
                                : "Delete (${marketwatch.delScripQty})",
                            color: const Color(0xffFFFFFF),
                            theme: theme.isDarkMode,
                            fw: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Stack(
              children: [
                marketwatch.loading
                    ? const Center(child: CircularProgressIndicator())
                    : Theme(
                        data: ThemeData(
                            canvasColor: theme.isDarkMode
                                ? const Color(0xffFFFFFF).withOpacity(.05)
                                : const Color(0xff000000).withOpacity(.05)),
                        child: ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          // shrinkWrap: true,
                          buildDefaultDragHandles: false, // Disable default drag behavior - only drag icon will work
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: theme.isDarkMode
                                  ? colors
                                      .colorBlack // your custom dark drag color
                                  : colors
                                      .colorWhite, // your custom light drag color
                              elevation: 6,
                              shadowColor: Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                              child: child,
                            );
                          },
                          itemBuilder: (_, int i) => Container(
                            // padding: const EdgeInsets.on(horizontal: 16),
                            key: ValueKey(i.toString()),
                            decoration: BoxDecoration(
                                border: i == 0
                                    ? null
                                    : Border(
                                        top: BorderSide(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider,
                                            width: 0))),
                            child: ListTile(
                              onTap: () {
                                marketwatch.selectDeleteScrip(i);
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              dense: false,
                              minLeadingWidth: 24, // Just enough for checkbox + minimal spacing
                              leading: SizedBox(
                                width: 20, // Fixed width for the checkbox
                                height: 20, // Fixed height for the checkbox
                                child: SvgPicture.asset(
                                  theme.isDarkMode
                                      ? marketwatch.scrips[i]['isSelected']
                                          ? assets.darkCheckedboxIcon
                                          : assets.darkCheckboxIcon
                                      : marketwatch.scrips[i]['isSelected']
                                          ? assets.ckeckedboxIcon
                                          : assets.ckeckboxIcon,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              trailing: ReorderableDragStartListener(
                                  index: i,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.drag_handle_outlined,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite.withOpacity(0.6)
                                          : colors.colorBlack.withOpacity(0.6),
                                      size: 20,
                                    ),
                                  )),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${marketwatch.scrips[i]['symbol']}",
                                      style: TextWidget.textStyle(
                                          fontSize: 14,
                                          color : theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          ),
                                    ),
                                    if (marketwatch.scrips[i]['option']
                                        .toString()
                                        .isNotEmpty)
                                      Text(
                                        " ${marketwatch.scrips[i]['option']}",
                                        style: TextWidget.textStyle(
                                            fontSize: 14,
                                            color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                                            theme: theme.isDarkMode,
                                            ),
                                      )
                                  ],
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                // const SizedBox(height: 8),

                                  TextWidget.paraText(
                                      text: "${marketwatch.scrips[i]['exch']}",
                                      color: theme.isDarkMode ? colors.textSecondaryDark :  colors.textSecondaryLight,
                                      theme: theme.isDarkMode,
                                      ),
                                  const SizedBox(width: 4),
                                  if (marketwatch.scrips[i]['expDate']
                                      .toString()
                                      .isNotEmpty)
                                    TextWidget.paraText(
                                        text: "${marketwatch.scrips[i]['expDate']}",
                                        color: theme.isDarkMode ? colors.textSecondaryDark :  colors.textSecondaryLight,
                                        theme: theme.isDarkMode,
                                        ),
                                ],
                              ),
                            ),
                          ),
                          itemCount: marketwatch.scrips.length,
                          onReorder: (int oldIndex, int newIndex) {
                            if (internet.connectionStatus !=
                                ConnectivityResult.none) {
                              marketwatch.reOrderList(
                                  context: context,
                                  newIndex: newIndex,
                                  oldIndex: oldIndex,
                                  wlName: widget.wlName);
                            }
                          },
                        ),
                      ),
                if (internet.connectionStatus == ConnectivityResult.none) ...[
                  const NoInternetWidget()
                ]
              ],
            ),
          ));
    });
  }
}
