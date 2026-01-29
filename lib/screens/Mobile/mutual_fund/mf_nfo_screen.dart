// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
// import '../../../../provider/fund_provider.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
// import '../../../../routes/route_names.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'mf_order_screen.dart';

class MFNFOScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const MFNFOScreen({super.key, this.onBack});

  @override
  ConsumerState<MFNFOScreen> createState() => _MFNFOScreenState();
}

class _MFNFOScreenState extends ConsumerState<MFNFOScreen> {
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  late ScrollController _verticalScrollController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _hoveredRowIndex.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Style Helpers ---
  TextStyle _getTextStyle(BuildContext context,
      {Color? color, double? fontSize}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    ).copyWith(fontSize: fontSize);
  }

  TextStyle _getHeaderStyle(BuildContext context) {
    return MyntWebTextStyles.tableHeader(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  Color resolveThemeColor(BuildContext context,
      {required Color dark, required Color light}) {
    final theme = ref.read(themeProvider);
    return theme.isDarkMode ? dark : light;
  }

  // --- Table Builders ---

  shadcn.TableCell buildHeaderCell(String label, [bool alignRight = false]) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 0), // Reduced vertical padding to 0
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: _getHeaderStyle(context),
        ),
      ),
    );
  }

  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    bool alignRight = false,
  }) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: null,
              alignment:
                  alignRight ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleOrder(dynamic nfoItem, String type) async {
    final mf = ref.read(mfProvider);

    try {
      mf.setInvestLoader(true);
      // Fetch bank details to prevent null error in MFOrderScreen
      await ref.read(transcationProvider).fetchfundbank(context);

      mf.setInvestLoader(false);

      if (!context.mounted) return;

      final isin = nfoItem.iSIN;
      final schemeCode = nfoItem.schemeCode;

      if ((nfoItem.sIPFLAG == "Y" && isin != null && schemeCode != null)) {
        mf.invertfun(isin, schemeCode, context);
      }

      // Pre-fill amount
      if (type == "One-time") {
        String amt = nfoItem.minimumPurchaseAmount ?? "0";
        mf.invAmt.text = amt.split('.').first;
      } else {
        String amt = nfoItem.minimumPurchaseAmount ?? "0";
        mf.installmentAmt.text = amt.split('.').first;
      }

      if (context.mounted) {
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.25; // 25% width
        final dialogHeight = screenSize.height * 0.60; // 60% height

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MFOrderScreen(mfData: nfoItem),
              ),
            ),
          ),
        );
        mf.chngOrderType(type);
        mf.orderchangetitle(type);
        mf.orderpagetite("NFO");
      }
    } catch (e) {
      mf.setInvestLoader(false);
      if (context.mounted) {
        showResponsiveErrorMessage(context, "Error: ${e.toString()}");
      }
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    return date.replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final mf = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);

    // Data filtering
    final nfoList = mf.mfNFOList?.mutualFundList ?? [];
    final filteredList = nfoList.where((item) {
      if (_searchQuery.isEmpty) return true;
      return (item.name?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? colors.kColorDarkThemeBackground
          : colors.kColorlightThemeBackground,
      body: SafeArea(
        child: TransparentLoaderScreen(
          isLoading: mf.investloader,
          child: Column(
            children: [
              // --- Header Section ---
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(
                    //     color: theme.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    //   ),
                    // ),
                    ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back Button (Left side)
                    IconButton(
                      onPressed: widget.onBack ?? () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new,
                          size: 20,
                          color:
                              theme.isDarkMode ? Colors.white : Colors.black),
                      alignment: Alignment.center,
                      tooltip: "Back",
                    ),
                    // const SizedBox(width: 16),
                    // // Icon
                    // Container(
                    //   width: 48,
                    //   height: 48,
                    //   decoration: BoxDecoration(
                    //     color: Colors.red.withValues(alpha: 0.1),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: const Icon(Icons.card_giftcard, color: Colors.red, size: 28),
                    // ),
                    // const SizedBox(width: 16),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "New Fund Offerings",
                                style: MyntWebTextStyles.title(context,
                                    darkColor: MyntColors.textPrimaryDark,
                                    lightColor: MyntColors.textPrimary,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.colorBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  filteredList.length.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
                            style: MyntWebTextStyles.para(context,
                                darkColor: MyntColors.textSecondaryDark,
                                lightColor: MyntColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(width: 24),
                    // Search Bar
                    // SizedBox(
                    //   width: 250,
                    //   child: shadcn.Theme(
                    //     data: shadcn.Theme.of(context).copyWith(
                    //       colorScheme: () => shadcn.Theme.of(context).colorScheme.copyWith(
                    //             ring: () => Colors.transparent,
                    //           ),
                    //     ),
                    //     child: shadcn.TextField(
                    //       controller: _searchController,
                    //       placeholder: const Text('Search'),
                    //       features: [
                    //         shadcn.InputFeature.leading(
                    //             const Icon(Icons.search, size: 16)),
                    //       ],
                    //       padding: const EdgeInsets.symmetric(
                    //           horizontal: 12, vertical: 8),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              // --- Table Section ---
              Expanded(
                child: filteredList.isEmpty
                    ? const NoDataFound(
                        secondaryEnabled: false, title: "No NFOs Found")
                    : LayoutBuilder(builder: (context, constraints) {
                        final double totalWidth = constraints.maxWidth;
                        final double fundNameWidth = totalWidth * 0.55;
                        final double otherColumnWidth = totalWidth * 0.15;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: shadcn.OutlinedContainer(
                            child: Column(
                              children: [
                                // Fixed Header
                                shadcn.Table(
                                  defaultRowHeight:
                                      const shadcn.FixedTableSize(50),
                                  columnWidths: {
                                    0: shadcn.FixedTableSize(fundNameWidth),
                                    1: shadcn.FixedTableSize(otherColumnWidth),
                                    2: shadcn.FixedTableSize(otherColumnWidth),
                                    3: shadcn.FixedTableSize(otherColumnWidth),
                                  },
                                  rows: [
                                    shadcn.TableHeader(
                                      cells: [
                                        buildHeaderCell('Fund name', false),
                                        buildHeaderCell('Opening', false),
                                        buildHeaderCell('Closing', false),
                                        buildHeaderCell('Min. Invest', true),
                                      ],
                                    ),
                                  ],
                                ),
                                // Scrollable Body
                                Expanded(
                                  child: Scrollbar(
                                    controller: _verticalScrollController,
                                    thumbVisibility: false,
                                    child: SingleChildScrollView(
                                      controller: _verticalScrollController,
                                      child: shadcn.Table(
                                        defaultRowHeight:
                                            const shadcn.FixedTableSize(70),
                                        columnWidths: {
                                          0: shadcn.FixedTableSize(
                                              fundNameWidth),
                                          1: shadcn.FixedTableSize(
                                              otherColumnWidth),
                                          2: shadcn.FixedTableSize(
                                              otherColumnWidth),
                                          3: shadcn.FixedTableSize(
                                              otherColumnWidth),
                                        },
                                        rows: [
                                          ...filteredList
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final item = entry.value;

                                            return shadcn.TableRow(
                                              cells: [
                                                buildCellWithHover(
                                                  rowIndex: index,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 14,
                                                        backgroundColor:
                                                            Colors.grey[200],
                                                        backgroundImage:
                                                            NetworkImage(
                                                          "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
                                                        ),
                                                        onBackgroundImageError:
                                                            (_, __) {},
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              item.name ??
                                                                  "Unknown Fund",
                                                              style: _getTextStyle(
                                                                  context,
                                                                  color: resolveThemeColor(
                                                                      context,
                                                                      dark: MyntColors
                                                                          .textPrimaryDark,
                                                                      light: MyntColors
                                                                          .textPrimary),
                                                                  fontSize: 14),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 2),
                                                            Row(
                                                              children: [
                                                                _buildTag(
                                                                    item.sCHEMECATEGORY ??
                                                                        "Other Scheme",
                                                                    theme),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ValueListenableBuilder<
                                                          int?>(
                                                        valueListenable:
                                                            _hoveredRowIndex,
                                                        builder: (context,
                                                            hoveredIndex, _) {
                                                          if (hoveredIndex ==
                                                              index) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: resolveThemeColor(
                                                                    context,
                                                                    dark: MyntColors
                                                                        .searchBgDark,
                                                                    light: MyntColors
                                                                        .backgroundColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                boxShadow:
                                                                    MyntShadows
                                                                        .card,
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  _buildActionButton(
                                                                      "One-time",
                                                                      const Color(
                                                                          0xff0037B7),
                                                                      () => _handleOrder(
                                                                          item,
                                                                          "One-time")),
                                                                  if (item.sIPFLAG ==
                                                                      "Y") ...[
                                                                    const SizedBox(
                                                                        width:
                                                                            6),
                                                                    _buildActionButton(
                                                                        "SIP",
                                                                        const Color(
                                                                            0xff0037B7),
                                                                        () => _handleOrder(
                                                                            item,
                                                                            "SIP")),
                                                                  ]
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                buildCellWithHover(
                                                  rowIndex: index,
                                                  child: Text(
                                                      _formatDate(
                                                          item.startDate),
                                                      style: _getTextStyle(
                                                          context)),
                                                ),
                                                buildCellWithHover(
                                                  rowIndex: index,
                                                  child: Text(
                                                      _formatDate(item.endDate),
                                                      style: _getTextStyle(
                                                          context)),
                                                ),
                                                buildCellWithHover(
                                                  rowIndex: index,
                                                  alignRight: true,
                                                  child: Text(
                                                      "₹${double.tryParse(item.minimumPurchaseAmount ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                                                      style: _getTextStyle(
                                                          context)),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap,
      {bool filled = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: filled ? null : Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
