// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';

import '../../../../models/ipo_model/ipo_details_model.dart';
import '../../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../models/ipo_model/ipo_sme_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../Mobile/ipo/mainstream_order_screen/orderscreenbottompage.dart';

// InheritedWidget to pass close callback to child widgets
class _IpoOrderDialogCloseNotifier extends InheritedWidget {
  final VoidCallback onClose;

  const _IpoOrderDialogCloseNotifier({
    required this.onClose,
    required super.child,
  });

  static _IpoOrderDialogCloseNotifier? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IpoOrderDialogCloseNotifier>();
  }

  @override
  bool updateShouldNotify(_IpoOrderDialogCloseNotifier oldWidget) {
    return onClose != oldWidget.onClose;
  }
}

// InheritedWidget to pass drag handlers to child widgets
class _IpoOrderDialogDragNotifier extends InheritedWidget {
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final bool isDragging;

  const _IpoOrderDialogDragNotifier({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.isDragging,
    required super.child,
  });

  static _IpoOrderDialogDragNotifier? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IpoOrderDialogDragNotifier>();
  }

  @override
  bool updateShouldNotify(_IpoOrderDialogDragNotifier oldWidget) {
    return onPanStart != oldWidget.onPanStart ||
        onPanUpdate != oldWidget.onPanUpdate ||
        onPanEnd != oldWidget.onPanEnd ||
        isDragging != oldWidget.isDragging;
  }
}

class UnifiedIpoOrderScreen extends ConsumerStatefulWidget {
  final dynamic ipoData; // Can be either SMEIPO or MainIPO
  const UnifiedIpoOrderScreen({
    super.key,
    required this.ipoData,
  });

  @override
  ConsumerState<UnifiedIpoOrderScreen> createState() =>
      _UnifiedIpoOrderScreenState();

  // Static variable to track the current overlay entry
  static OverlayEntry? _currentOverlayEntry;

  /// Static method to show UnifiedIpoOrderScreen as a draggable dialog
  static void showDraggable({
    required BuildContext context,
    required dynamic ipoData,
    Offset? initialPosition,
  }) {
    final overlay = Overlay.of(context);
    
    // Close existing IPO order screen if one is already open
    if (_currentOverlayEntry != null) {
      try {
        _currentOverlayEntry!.remove();
      } catch (e) {
        // Entry might already be removed, ignore error
      }
      _currentOverlayEntry = null;
    }

    final position = initialPosition ??
        Offset(
          MediaQuery.of(context).size.width * 0.1,
          MediaQuery.of(context).size.height * 0.05,
        );

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _DraggableIpoOrderScreenDialog(
        ipoData: ipoData,
        initialPosition: position,
        onPositionChanged: (newPosition) {
          // Position can be saved if needed
        },
        onClose: () {
          overlayEntry.remove();
          _currentOverlayEntry = null;
        },
      ),
    );

    // Store the current overlay entry
    _currentOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }
}

class _UnifiedIpoOrderScreenState extends ConsumerState<UnifiedIpoOrderScreen> {
  String upierrortext = "";
  String selectedChip = "Individual";
  List<IpoDetails> addIpo = [];

  // Helper getters to determine IPO type and access data
  bool get isSME => widget.ipoData is SMEIPO;
  bool get isMainstream => widget.ipoData is MainIPO;

  dynamic get ipoData => widget.ipoData;
  String get ipoName => isSME ? (ipoData.name ?? "") : (ipoData.name ?? "");
  String get ipoKey => isSME ? (ipoData.key ?? "") : (ipoData.key ?? "");
  String get ipoSymbol =>
      isSME ? (ipoData.symbol ?? "") : (ipoData.symbol ?? "");
  String get ipoType => isSME ? (ipoData.type ?? "") : (ipoData.type ?? "");
  String get lotSize =>
      isSME ? (ipoData.lotSize ?? "") : (ipoData.lotSize ?? "");
  String get minPrice =>
      isSME ? (ipoData.minPrice ?? "") : (ipoData.minPrice ?? "");
  String get maxPrice =>
      isSME ? (ipoData.maxPrice ?? "") : (ipoData.maxPrice ?? "");
  String get minBidQuantity =>
      isSME ? (ipoData.minBidQuantity ?? "") : (ipoData.minBidQuantity ?? "");
  String get dailyStartTime =>
      isSME ? (ipoData.dailyStartTime ?? "") : (ipoData.dailyStartTime ?? "");
  String get dailyEndTime =>
      isSME ? (ipoData.dailyEndTime ?? "") : (ipoData.dailyEndTime ?? "");
  String get biddingStartDate => isSME
      ? (ipoData.biddingStartDate ?? "")
      : (ipoData.biddingStartDate ?? "");
  String get biddingEndDate =>
      isSME ? (ipoData.biddingEndDate ?? "") : (ipoData.biddingEndDate ?? "");

  @override
  void initState() {
    setState(() {
      addNewItem();
    });
    super.initState();
  }

  void addNewItem() {
    setState(() {
      addIpo.add(IpoDetails(
          qualitytext: lotSize,
          bidprice:
              "${double.parse(minPrice.isEmpty ? "0" : minPrice).toInt()}",
          lotsize: int.parse(lotSize.isEmpty ? "0" : lotSize),
          requriedprice: mininv(
                  double.parse(minPrice.isEmpty ? "0" : minPrice).toDouble(),
                  int.parse(minBidQuantity.isEmpty ? "0" : minBidQuantity)
                      .toInt())
              .toInt(),
          isChecked: false));
    });
  }

  void removeItem(int index) {
    setState(() {
      addIpo.removeAt(index);
    });
  }

  // Helper method to get appropriate provider methods based on IPO type
  void _updateProviderState(IPOProvider ipo) {
    if (isSME) {
      if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
        ipo.setisSMEPlaceOrderBtnActiveValue = true;
      }
      ipo.setsmePlaceOrderRequiredMaxPrice = addIpo;
    } else {
      if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
        ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
      }
      ipo.setMainIPOPlaceOrderRequiredMaxPrice = addIpo;
    }
  }

  // Helper method to get button active state
  bool _getButtonActiveState(IPOProvider ipo) {
    return isSME
        ? ipo.isSMEPlaceOrderBtnActive
        : ipo.isMainIPOPlaceOrderBtnActive;
  }

  // Helper method to get max price
  int _getMaxPrice(IPOProvider ipo) {
    return isSME
        ? ipo.smePlaceOrderRequiredMaxPrice
        : ipo.mainIPOPlaceOrderRequiredMaxPrice;
  }

  // Helper method to set button active state
  void _setButtonActiveState(IPOProvider ipo, bool value) {
    if (isSME) {
      ipo.setisSMEPlaceOrderBtnActiveValue = value;
    } else {
      ipo.setisMainIPOPlaceOrderBtnActiveValue = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer(
        builder: (context, ref, child) {
          final ipo = ref.watch(ipoProvide);
          final theme = ref.watch(themeProvider);
          final status = ipostartdate(biddingStartDate, biddingEndDate);
          final isOpen = status == "Open";

          var chips =
              ipo.ipoCategory.map((e) => e['subCatCode']).toSet().toList();
          // Only set selectedChip to first chip if it's still the default value
          if (selectedChip == "Individual" && chips.isNotEmpty) {
            selectedChip = chips[0];
          }

          _updateProviderState(ipo);

          // Check if we're in a draggable dialog
          final closeNotifier = _IpoOrderDialogCloseNotifier.of(context);
          final dragNotifier = _IpoOrderDialogDragNotifier.of(context);

          // Build header content
          Widget headerContent = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : WebColors.background,
              border: Border(
                bottom: BorderSide(
                  color: theme.isDarkMode
                      ? WebDarkColors.divider
                      : WebColors.divider,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleText(
                          text: ipoName,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TextWidget.paraText(
                              text: ipoKey,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 0),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? theme.isDarkMode
                                      ? colors.profitDark.withOpacity(0.2)
                                      : colors.profitLight.withOpacity(0.2)
                                  : theme.isDarkMode
                                      ? colors.lossDark.withOpacity(0.2)
                                      : colors.lossLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextWidget.paraText(
                              text: status.toUpperCase(),
                              theme: false,
                              fw: 0,
                              color: isOpen
                                  ? theme.isDarkMode
                                      ? colors.profitDark
                                      : colors.profitLight
                                  : theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // Wrap with drag functionality if drag notifier is available
          if (dragNotifier != null) {
            headerContent = MouseRegion(
              cursor: SystemMouseCursors.move,
              child: GestureDetector(
                onPanStart: dragNotifier.onPanStart,
                onPanUpdate: dragNotifier.onPanUpdate,
                onPanEnd: dragNotifier.onPanEnd,
                child: headerContent,
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              elevation: .2,
              centerTitle: false,
              leadingWidth: closeNotifier != null ? 0 : 38,
              titleSpacing: 1,
              leading: closeNotifier == null
                  ? Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                          size: 18,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              backgroundColor:
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              title: headerContent,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(chips.isNotEmpty ? 50 : 0),
                child: chips.isNotEmpty
                    ? Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final isSelected = selectedChip == chips[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: InkWell(
                                  onTap: () async {
                                    final chip = chips[index];
                                    setState(() {
                                      selectedChip = chip;
                                      _updateProviderState(ipo);
                                    });
                                    ipo.chngCategoryType(chip);
                                    await ipo.categoryOnChange(
                                      addIpo,
                                      ipo.maxUPIAmt,
                                      _getButtonActiveState(ipo),
                                      selectedChip,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (theme.isDarkMode
                                              ? WebDarkColors.backgroundTertiary
                                              : WebColors.backgroundTertiary)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? (theme.isDarkMode
                                                ? WebDarkColors.primary
                                                : WebColors.primary)
                                            : (theme.isDarkMode
                                                ? WebDarkColors.textSecondary
                                                : WebColors.textSecondary),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      chips[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: WebTextStyles.tab(
                                        isDarkTheme: theme.isDarkMode,
                                        color: isSelected
                                            ? (theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary)
                                            : (theme.isDarkMode
                                                ? WebDarkColors.navItem
                                                : WebColors.navItem),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: chips.length,
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Container(
                          //   color: Color(0xFFFCEFD4),
                          //   height: 30,
                          //   child: Center(
                          //     child: Text(
                          //         "IPO window is open from $dailyStartTime till $dailyEndTime on trading days.",
                          //         style: textStyle(
                          //             theme.isDarkMode
                          //                 ? colors.colorWhite
                          //                 : colors.colorBlack,
                          //             10,
                          //             FontWeight.w600)),
                          //   ),
                          // ),
                        
                          // Category chips container with conditional styling
                        
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: addIpo.length,
                            itemBuilder: (context, index) {
                              _updateProviderState(ipo);
                        
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Text("Bid - 0${index + 1}",
                                          //     style: textStyle(
                                          //         theme.isDarkMode
                                          //             ? colors.colorWhite
                                          //             : colors.colorBlack,
                                          //         14,
                                          //         FontWeight.w600)),
                                          index > 0
                                              ? InkWell(
                                                  splashFactory: InkSparkle
                                                      .constantTurbulenceSeedSplashFactory,
                                                  onTap: ipo.loading
                                                      ? null
                                                      : () {
                                                          removeItem(index);
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          assets.trash,
                                                          color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        TextWidget.subText(
                                                          text: "Delete",
                                                          theme: false,
                                                          fw: 2,
                                                          color:  theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget.subText(
                                                  text: "Qty",
                                                  theme: false,
                                                  fw: 1,
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors.textPrimaryLight,
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  height: 45,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    textAlign: TextAlign.center,
                                                    style: TextWidget.textStyle(
                                                      fontSize: 16,
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                      
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: addIpo[index]
                                                        .qualityController,
                                                    decoration: InputDecoration(
                                                       fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                                                        filled: true,
                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: colors
                                                                    .btnOutlinedBorder),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    5)),
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: colors
                                                                    .btnOutlinedBorder),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    5)),
                                                        contentPadding:
                                                            const EdgeInsets.all(
                                                                13),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: colors
                                                                    .btnOutlinedBorder),
                                                            borderRadius:
                                                                BorderRadius.circular(5)),
                                                        suffixIcon: Material(
                                                          color:
                                                              Colors.transparent,
                                                          shape:
                                                              const CircleBorder(),
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          child: InkWell(
                                                            customBorder:
                                                                const CircleBorder(),
                                                            splashColor: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .splashColorDark
                                                                : colors
                                                                    .splashColorLight,
                                                            highlightColor: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .highlightDark
                                                                : colors
                                                                    .highlightLight,
                                                            onTap: ipo.loading
                                                                ? null
                                                                : () {
                                                                    if (isSME) {
                                                                      ipo.smequalityplusefunction(
                                                                          addIpo[
                                                                              index],
                                                                          _getButtonActiveState(
                                                                              ipo),
                                                                          ipoData,
                                                                          ipo.maxUPIAmt,
                                                                          selectedChip);
                                                                    } else {
                                                                      ipo.qualityplusefunction(
                                                                          addIpo[
                                                                              index],
                                                                          _getButtonActiveState(
                                                                              ipo),
                                                                          ipo,
                                                                          ipoData,
                                                                          selectedChip);
                                                                    }
                                                                    setState(() {
                                                                      _updateProviderState(
                                                                          ipo);
                                                                    });
                                                                  },
                                                            child: SvgPicture.asset(
                                                                theme.isDarkMode
                                                                    ? assets
                                                                        .darkAdd
                                                                    : assets
                                                                        .addIcon,
                                                                fit: BoxFit
                                                                    .scaleDown),
                                                          ),
                                                        ),
                                                        prefixIcon: InkWell(
                                                          onTap: addIpo[index]
                                                                      .qualityController
                                                                      .text ==
                                                                  addIpo[index]
                                                                      .qualitytext
                                                              ? null
                                                              : ipo.loading
                                                                  ? null
                                                                  : () {
                                                                      if (isSME) {
                                                                        ipo.smequantityminusfunction(
                                                                            addIpo[
                                                                                index],
                                                                            _getButtonActiveState(
                                                                                ipo),
                                                                            ipoData,
                                                                            ipo.maxUPIAmt,
                                                                            selectedChip);
                                                                      } else {
                                                                        ipo.quantityminusfunction(
                                                                            addIpo[
                                                                                index],
                                                                            _getButtonActiveState(
                                                                                ipo),
                                                                            ipo,
                                                                            ipoData,
                                                                            selectedChip);
                                                                      }
                                                                      setState(
                                                                          () {
                                                                        _updateProviderState(
                                                                            ipo);
                                                                      });
                                                                    },
                                                          child: SvgPicture.asset(
                                                              theme.isDarkMode
                                                                  ? assets
                                                                      .darkCMinus
                                                                  : assets
                                                                      .minusIcon,
                                                              fit: BoxFit
                                                                  .scaleDown),
                                                        )),
                                                    onChanged: (value) {
                                                      if (isSME) {
                                                        ipo.smequantityOnchange(
                                                            value,
                                                            addIpo[index],
                                                            ipoData,
                                                            _getButtonActiveState(
                                                                ipo),
                                                            ipo.maxUPIAmt,
                                                            selectedChip);
                                                      } else {
                                                        ipo.quantityOnchange(
                                                            addIpo[index],
                                                            _getButtonActiveState(
                                                                ipo),
                                                            ipo,
                                                            value,
                                                            ipoData,
                                                            selectedChip);
                                                      }
                                                      setState(() {
                                                        _updateProviderState(ipo);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextWidget.subText(
                                                      text: "Bid Price",
                                                      theme: false,
                                                      fw: 1,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                    ),
                                                    // Text(
                                                    //     "(${double.parse(minPrice).toInt()}- ${double.parse(maxPrice).toInt()})",
                                                    //     style: textStyle(
                                                    //         theme.isDarkMode
                                                    //             ? colors.colorWhite
                                                    //             : colors.colorBlack,
                                                    //         10,
                                                    //         FontWeight.w600)),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  height: 45,
                                                  child: TextFormField(
                                                    style: TextWidget.textStyle(
                                                      fontSize: 16,
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    readOnly: ipo.loading
                                                        ? true
                                                        : addIpo[index]
                                                                    .isChecked ==
                                                                true
                                                            ? true
                                                            : false,
                                                    controller: addIpo[index]
                                                        .bidpricecontroller,
                                                    decoration: InputDecoration(
                                                    fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                                                      filled: true,
                                                      labelStyle:
                                                          TextWidget.textStyle(
                                                        fontSize: 16,
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors.textPrimaryDark
                                                            : colors
                                                                .textPrimaryLight,
                                                        
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: colors
                                                                  .btnOutlinedBorder),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: colors
                                                                  .btnOutlinedBorder),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              13),
                                                      border: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: colors
                                                                  .btnOutlinedBorder),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      suffixIcon: Material(
                                                        color: Colors.transparent,
                                                        shape:
                                                            const CircleBorder(),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        child: InkWell(
                                                          customBorder:
                                                              const CircleBorder(),
                                                          splashColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .splashColorDark
                                                              : colors
                                                                  .splashColorLight,
                                                          highlightColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .highlightDark
                                                              : colors
                                                                  .highlightLight,
                                                          onTap: ipo.loading
                                                              ? null
                                                              : () {
                                                                  if (isSME) {
                                                                    ipo.smecutoffprice(
                                                                      addIpo[
                                                                          index],
                                                                      ipoData,
                                                                    );
                                                                  } else {
                                                                    ipo.cutoffprice(
                                                                        addIpo[
                                                                            index],
                                                                        ipoData);
                                                                  }
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  _updateProviderState(
                                                                      ipo);
                                                                },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(14.0),
                                                            child: SvgPicture.asset(
                                                                assets.switchIcon,
                                                                fit: BoxFit
                                                                    .contain),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      if (isSME) {
                                                        ipo.smebidpriceOnChange(
                                                            value,
                                                            addIpo[index],
                                                            _getButtonActiveState(
                                                                ipo),
                                                            ipoData);
                                                      } else {
                                                        ipo.bidpricefunction(
                                                            addIpo[index],
                                                            ipoData,
                                                            value,
                                                            _getButtonActiveState(
                                                                ipo));
                                                      }
                                                      setState(() {
                                                        _updateProviderState(ipo);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.center,
                                      //   children: [
                                      //     const Padding(
                                      //         padding: EdgeInsets.symmetric(
                                      //             horizontal: 55, vertical: 20)),
                        
                                      //   ],
                                      // ),
                                     if (addIpo[index]
                                            .qualityerrortext
                                            .isNotEmpty ||
                                        addIpo[index]
                                            .biderrortext
                                            .isNotEmpty) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: TextWidget.captionText(
                                              theme: false,
                                              text:
                                                  addIpo[index].qualityerrortext,
                                              color: colors.error,
                                              fw: 0,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextWidget.captionText(
                                              theme: false,
                                              text: addIpo[index].biderrortext,
                                              color: colors.error,
                                              fw: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                        
                                      // if (addIpo[index]
                                      //     .qualityerrortext
                                      //     .isNotEmpty) ...[
                                      //   const SizedBox(height: 6),
                                      //   IpoErrorBadge(
                                      //     errorName:
                                      //         addIpo[index].qualityerrortext,
                                      //   )
                                      // ],
                                      // if (addIpo[index]
                                      //     .biderrortext
                                      //     .isNotEmpty) ...[
                                      //   const SizedBox(height: 6),
                                      //   IpoErrorBadge(
                                      //     errorName: addIpo[index].biderrortext,
                                      //   )
                                      // ],
                                    ],
                                    ],
                              ),
                              );
                            },
                          ),
                          addIpo.length == 3
                              ? Container()
                              : Material(
                                  color: Colors.transparent,
                                  shape: const RoundedRectangleBorder(),
                                  child: InkWell(
                                    customBorder: const RoundedRectangleBorder(),
                                    splashColor: theme.isDarkMode
                                        ? colors.splashColorDark
                                        : colors.splashColorLight,
                                    highlightColor: theme.isDarkMode
                                        ? colors.highlightDark
                                        : colors.highlightLight,
                                    onTap: ipo.loading
                                        ? null
                                        : () {
                                            addNewItem();
                                            ipo.categoryOnChange(
                                                addIpo,
                                                ipo.maxUPIAmt,
                                                _getButtonActiveState(ipo),
                                                selectedChip);
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWidget.subText(
                                            text: "Add another bid",
                                            theme: false,
                                            fw: 0,
                                            color: theme.isDarkMode
                                                ? colors.primaryDark
                                                : colors.primaryLight,
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: colors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.isDarkMode ? colors.darkGrey : colors.btnBg,
                          border: Border(
                            top: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.dividerDark
                                  : colors.dividerLight,
                            ),
                            bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.dividerDark
                                  : colors.dividerLight,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextWidget.paraText(
                                text: "Margin",
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                fw: 0,
                              ),
                              TextWidget.paraText(
                                text: " ${_getMaxPrice(ipo)}",
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight,
                                fw: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Close button (only show when in draggable dialog)
                            if (closeNotifier != null)
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      closeNotifier.onClose();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 45),
                                      backgroundColor: theme.isDarkMode
                                          ? WebDarkColors.background
                                          : WebColors.background,
                                      side: BorderSide(
                                        color: theme.isDarkMode
                                            ? WebDarkColors.divider
                                            : WebColors.divider,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: TextWidget.titleText(
                                      text: "Close",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 2,
                                    ),
                                  ),
                                ),
                              ),
                            if (closeNotifier != null) const SizedBox(width: 12),
                            // Continue button
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _getButtonActiveState(ipo)
                                      ? () {
                                          if (addIpo[addIpo.length - 1].requriedprice >
                                              ipo.maxUPIAmt) {
                                            warningMessage(context,
                                                "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ");
                                            _setButtonActiveState(ipo, false);
                                          } else if (addIpo[addIpo.length - 1]
                                                  .bidpricecontroller
                                                  .text
                                                  .isEmpty ||
                                              addIpo[addIpo.length - 1]
                                                      .bidpricecontroller
                                                      .text ==
                                                  "0") {
                                            warningMessage(
                                                context,
                                                addIpo[addIpo.length - 1]
                                                            .bidpricecontroller
                                                            .text ==
                                                        "0"
                                                    ? "Bid Price Value cannot be 0"
                                                    : "*Bid Price Value is required");
                                          } else if (addIpo[addIpo.length - 1]
                                                  .qualityController
                                                  .text
                                                  .isEmpty ||
                                              addIpo[addIpo.length - 1]
                                                      .qualityController
                                                      .text ==
                                                  "0") {
                                            warningMessage(
                                                context,
                                                addIpo[addIpo.length - 1]
                                                            .qualityController
                                                            .text ==
                                                        "0"
                                                    ? '* Quantity cannot be 0'
                                                    : '* Quantity cannot be empty');
                                          } else {
                                            if (ipo.checkForErrorsInSMEPlaceOrder(
                                                addIpo)) {
                                              _setButtonActiveState(ipo, true);
                                              // Show payment screen as overlay dialog above the order screen
                                              final overlay = Overlay.of(context, rootOverlay: true);
                                              late OverlayEntry paymentOverlayEntry;

                                              // Get the close notifier for the order screen
                                              final orderScreenCloseNotifier = closeNotifier;

                                              paymentOverlayEntry = OverlayEntry(
                                                builder: (overlayContext) => Consumer(
                                                  builder: (context, ref, _) {
                                                    final currentTheme = ref.watch(themeProvider);
                                                    return Stack(
                                                      children: [
                                                        // Backdrop
                                                        Positioned.fill(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              paymentOverlayEntry.remove();
                                                            },
                                                            child: Container(
                                                              color: Colors.black.withOpacity(0.5),
                                                            ),
                                                          ),
                                                        ),
                                                        // Dialog centered
                                                        Center(
                                                          child: Material(
                                                            color: Colors.transparent,
                                                            child: Container(
                                                              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                                                              margin: const EdgeInsets.symmetric(horizontal: 16),
                                                              decoration: BoxDecoration(
                                                                color: currentTheme.isDarkMode
                                                                    ? WebDarkColors.surface
                                                                    : WebColors.surface,
                                                                borderRadius: BorderRadius.circular(5),
                                                              ),
                                                              child: PaymentDialogWrapper(
                                                                onClose: () {
                                                                  paymentOverlayEntry.remove();
                                                                },
                                                                onOrderScreenClose: orderScreenCloseNotifier != null
                                                                    ? () {
                                                                        orderScreenCloseNotifier.onClose();
                                                                      }
                                                                    : null,
                                                                child: OrderScreenbottomPage(
                                                                  mainstream: ipoData,
                                                                  addIpo: addIpo,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              );

                                              overlay.insert(paymentOverlayEntry);
                                            } else {
                                              warningMessage(context,
                                                      "can't able place Order with current selected combination of Bids");
                                              _setButtonActiveState(ipo, false);
                                            }
                                          }
                                        }
                                      : () {},
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 45),
                                    backgroundColor: _getButtonActiveState(ipo) == false
                                        ?  theme.isDarkMode
                                                    ? colors.primaryDark
                                                        .withOpacity(0.5)
                                                    : colors.primaryLight
                                                        .withOpacity(0.5) 
                                        : theme.isDarkMode
                                                    ? colors.primaryDark
                                                    : colors.primaryLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: TextWidget.titleText(
                                    text: "Continue",
                                    theme: false,
                                    color: _getButtonActiveState(ipo) == false
                                    ? colors.colorWhite
                                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                    fw: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: ipoType,
      symbol: ipoSymbol,
      category:
          ipo.ipoCategoryvalue == "Individual" || ipo.ipoCategoryvalue == "HNI"
              ? "IND"
              : ipo.ipoCategoryvalue == "Employee"
                  ? "EMP"
                  : ipo.ipoCategoryvalue == "Shareholder"
                      ? "SHA"
                      : ipo.ipoCategoryvalue == "Policyholder"
                          ? "POL"
                          : "",
      name: ipoName,
      applicationNumber: '',
      respBid: [BidReference(bidReferenceNumber: '')],
    );
    final String iposupiid = upiid.upiid.text;
    List<IposBid> iposbids = [];
    for (int i = 0; i < addIpo.length; i++) {
      iposbids.add(IposBid(
          bitis: true,
          qty: int.parse(addIpo[i].qualityController.text).toInt(),
          cutoff: addIpo[i].isChecked,
          price: double.parse(addIpo[i].bidpricecontroller.text).toDouble(),
          total: addIpo[i].requriedprice.toDouble()));
    }

    // Check if we're in an overlay dialog wrapper
    final paymentWrapper = PaymentDialogWrapper.of(context);

    await ref.read(ipoProvide).fetchupiidvalidation(
        context, upiid.upiid.text, "343245", menudata, iposbids, iposupiid,
        isOverlayDialog: paymentWrapper != null);

    // If in overlay dialog, close both dialogs after order is placed
    // Note: We wait for the API call to complete, then close dialogs
    // The success message is shown by getipoplaceorder in the provider
    if (paymentWrapper != null) {
      // Close payment dialog
      paymentWrapper.onClose();
      // Close order screen dialog if callback is available
      if (paymentWrapper.onOrderScreenClose != null) {
        // Add a small delay to allow success message to appear first
        Future.delayed(const Duration(milliseconds: 300), () {
          paymentWrapper.onOrderScreenClose!();
        });
      }
    }
  }
}

// Wrapper widget to pass close callbacks to OrderScreenbottomPage
class PaymentDialogWrapper extends InheritedWidget {
  final VoidCallback onClose;
  final VoidCallback? onOrderScreenClose; // Callback to close the order screen overlay

  const PaymentDialogWrapper({
    super.key,
    required this.onClose,
    this.onOrderScreenClose,
    required super.child,
  });

  static PaymentDialogWrapper? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaymentDialogWrapper>();
  }

  @override
  bool updateShouldNotify(PaymentDialogWrapper oldWidget) {
    return onClose != oldWidget.onClose || onOrderScreenClose != oldWidget.onOrderScreenClose;
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}

// Draggable IPO Order Screen Dialog Widget
class _DraggableIpoOrderScreenDialog extends ConsumerStatefulWidget {
  final dynamic ipoData;
  final Offset initialPosition;
  final Function(Offset) onPositionChanged;
  final VoidCallback onClose;

  const _DraggableIpoOrderScreenDialog({
    required this.ipoData,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onClose,
  });

  @override
  ConsumerState<_DraggableIpoOrderScreenDialog> createState() =>
      _DraggableIpoOrderScreenDialogState();
}

class _DraggableIpoOrderScreenDialogState
    extends ConsumerState<_DraggableIpoOrderScreenDialog> {
  late Offset _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenSize = MediaQuery.of(context).size;

    // Constrain position to screen bounds
    const dialogWidth = 550.0;
    final dialogHeight = screenSize.height * 0.8;
    final constrainedPosition = Offset(
      _position.dx.clamp(0, screenSize.width - dialogWidth),
      _position.dy.clamp(0, screenSize.height - dialogHeight),
    );

    return Stack(
      children: [
        // Actual dialog
        Positioned(
          left: constrainedPosition.dx,
          top: constrainedPosition.dy,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating to background
            child: Material(
              elevation: _isDragging ? 16 : 8,
              borderRadius: BorderRadius.circular(5),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : WebColors.background,
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
                child: _IpoOrderDialogCloseNotifier(
                  onClose: widget.onClose,
                  child: _IpoOrderDialogDragNotifier(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _position = Offset(
                          _position.dx + details.delta.dx,
                          _position.dy + details.delta.dy,
                        );
                      });
                      widget.onPositionChanged(_position);
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    isDragging: _isDragging,
                    child: UnifiedIpoOrderScreen(
                      ipoData: widget.ipoData,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
