import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../res/res.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import 'watchlist_screen_web.dart' show deleteModeProvider;

class EditScripWeb extends ConsumerStatefulWidget {
  final String wlName;
  final bool showInDialog;
  const EditScripWeb({super.key, required this.wlName, this.showInDialog = false});

  @override
  ConsumerState<EditScripWeb> createState() => _EditScripWebState();
}

class _EditScripWebState extends ConsumerState<EditScripWeb> {
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

            // Disable delete mode if not in dialog (when shown inline in watchlist screen)
            if (!widget.showInDialog) {
              ref.read(deleteModeProvider.notifier).setDeleteMode(false);
            }

            if (widget.showInDialog) {
              // If in dialog, just close the dialog
              Navigator.of(context).pop();
            } else {
              // If full screen/non-dialog, navigation is handled by disabling delete mode
            }
          },
          child: Scaffold(
            appBar: null, // Hide AppBar
            body: Column(
              children: [
                Expanded(
                  child: Stack(
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
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    marketwatch.scrips[i]['symbol']
                                        .toString()
                                        .replaceAll("-EQ", "")
                                        .toUpperCase(),
                                    style: WebTextStyles.custom(
                                      fontSize: 13,
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (marketwatch.scrips[i]['option']
                                      .toString()
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        "${marketwatch.scrips[i]['option']}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      "${marketwatch.scrips[i]['exch']}",
                                      style: WebTextStyles.caption(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.textSecondary
                                            : WebColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (marketwatch.scrips[i]['expDate']
                                        .toString()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          " ${marketwatch.scrips[i]['expDate']}",
                                          style: WebTextStyles.custom(
                                            fontSize: 10,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textSecondary
                                                : WebColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
                ),
                // Bottom buttons: Select All, Delete, Cancel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    border: Border(
                      top: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Select All button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.15),
                            highlightColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.08),
                            onTap: () {
                              // Toggle select all
                              bool allSelected = marketwatch.scrips.every((scrip) => scrip['isSelected'] == true);
                              for (int i = 0; i < marketwatch.scrips.length; i++) {
                                if (allSelected) {
                                  // Unselect all
                                  if (marketwatch.scrips[i]['isSelected'] == true) {
                                    marketwatch.selectDeleteScrip(i);
                                  }
                                } else {
                                  // Select all
                                  if (marketwatch.scrips[i]['isSelected'] != true) {
                                    marketwatch.selectDeleteScrip(i);
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextWidget.subText(
                                  text: "Select All",
                                  color: const Color(0xffFFFFFF),
                                  theme: theme.isDarkMode,
                                  fw: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Delete button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.15),
                            highlightColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.08),
                            onTap: marketwatch.delScripQty == 0 ||
                                    internet.connectionStatus == ConnectivityResult.none
                                ? null
                                : () {
                                    marketwatch.deleteScrip(context, widget.wlName);
                                    // Disable delete mode after deletion if not in dialog
                                    if (!widget.showInDialog) {
                                      ref.read(deleteModeProvider.notifier).setDeleteMode(false);
                                    }
                                  },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: marketwatch.delScripQty == 0
                                    ? colors.darkred.withOpacity(.2)
                                    : colors.darkred,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextWidget.subText(
                                  text: "Delete",
                                  color: const Color(0xffFFFFFF),
                                  theme: theme.isDarkMode,
                                  fw: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Cancel button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.15),
                            highlightColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.08),
                            onTap: () {
                              if (widget.showInDialog) {
                                Navigator.of(context).pop();
                              } else {
                                // Disable delete mode and reset selections
                                marketwatch.delQty();
                                ref.read(deleteModeProvider.notifier).setDeleteMode(false);
                              }
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: theme.isDarkMode
                                      ? WebDarkColors.primary
                                      : WebColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: TextWidget.subText(
                                  text: "Cancel",
                                  color: theme.isDarkMode
                                      ? WebDarkColors.primary
                                      : WebColors.primary,
                                  theme: theme.isDarkMode,
                                  fw: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }
}
