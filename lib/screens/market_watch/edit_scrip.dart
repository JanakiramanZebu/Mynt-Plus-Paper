import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_internet_widget.dart';

class EditScrip extends StatefulWidget {
  final String wlName;
  const EditScrip({super.key, required this.wlName});

  @override
  State<EditScrip> createState() => _EditScripState();
}

class _EditScripState extends State<EditScrip> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read(marketWatchProvider).setpageName("edit");
    });
    // context.read(networkStateProvider).networkStream();
    super.initState();
  }

  int delQty = 0;
  bool isSletcted = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final marketwatch = watch(marketWatchProvider);
      final theme = context.read(themeProvider);
      final internet = watch(networkStateProvider);

      return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return; // If system handled back, do nothing

            marketwatch.setpageName("");
            await context
                .read(marketWatchProvider)
                .requestMWScrip(context: context, isSubscribe: true);
            marketwatch.delQty();

            Navigator.of(context).pop(); // Proceed with back navigation
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 1,
              leadingWidth: 41,
              titleSpacing: 6,
              leading: InkWell(
                onTap: () {
                  marketwatch.setpageName("");
                  context
                      .read(marketWatchProvider)
                      .requestMWScrip(context: context, isSubscribe: true);
                  marketwatch.delQty();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack),
                ),
              ),
              shadowColor: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              title: Text(
                "Edit ${widget.wlName}'s Watchlist (${marketwatch.scrips.length})",
                style: textStyle(
                    Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                    14,
                    FontWeight.w600),
              ),
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
                        child: Text(
                          marketwatch.delScripQty == 0
                              ? "Delete"
                              : "Delete (${marketwatch.delScripQty})",
                          style: textStyle(
                              const Color(0xffFFFFFF), 12, FontWeight.w600),
                        ),
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
                                ? const Color(0xffFFFFFF).withOpacity(.3)
                                : const Color(0xff000000).withOpacity(.3)),
                        child: ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          // shrinkWrap: true,

                          // buildDefaultDragHandles: false,
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
                              contentPadding: const EdgeInsets.only(right: 16),
                              dense: true,
                              minLeadingWidth: 30,
                              leading: IconButton(
                                onPressed: () {
                                  marketwatch.selectDeleteScrip(i);
                                },
                                icon: SvgPicture.asset(
                                  theme.isDarkMode
                                      ? marketwatch.scrips[i]['isSelected']
                                          ? assets.darkCheckedboxIcon
                                          : assets.darkCheckboxIcon
                                      : marketwatch.scrips[i]['isSelected']
                                          ? assets.ckeckedboxIcon
                                          : assets.ckeckboxIcon,
                                  width: 22,
                                ),
                              ),
                              trailing: ReorderableDragStartListener(
                                  index: i,
                                  child: Icon(Icons.drag_handle_outlined,
                                      color: const Color(0xffB5C0CF)
                                          .withOpacity(.15))),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${marketwatch.scrips[i]['symbol']} ",
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  if (marketwatch.scrips[i]['option']
                                      .toString()
                                      .isNotEmpty)
                                    Text("${marketwatch.scrips[i]['option']}",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color:
                                                    const Color(0xff666666))),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text("${marketwatch.scrips[i]['exch']}  ",
                                          style: textStyles.scripExchTxtStyle),
                                      if (marketwatch.scrips[i]['expDate']
                                          .toString()
                                          .isNotEmpty)
                                        Text(
                                            "${marketwatch.scrips[i]['expDate']}",
                                            style: textStyles.scripExchTxtStyle
                                                .copyWith(
                                                    color: colors.colorBlack)),
                                    ],
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
