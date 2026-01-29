// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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

  // Popover state management
  shadcn.PopoverController? _activePopoverController;
  int? _popoverRowIndex;
  bool _isHoveringDropdown = false;
  Timer? _popoverCloseTimer;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _hoveredRowIndex.addListener(_onHoverChanged);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _onHoverChanged() {
    if (_activePopoverController != null) {
      final currentHover = _hoveredRowIndex.value;
      if (currentHover == _popoverRowIndex) {
        _cancelPopoverCloseTimer();
        return;
      }
      if (_isHoveringDropdown) {
        _cancelPopoverCloseTimer();
        return;
      }
      _startPopoverCloseTimer();
    }
  }

  void _startPopoverCloseTimer() {
    _cancelPopoverCloseTimer();
    _popoverCloseTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isHoveringDropdown && _hoveredRowIndex.value != _popoverRowIndex) {
        _closePopover();
      }
    });
  }

  void _cancelPopoverCloseTimer() {
    _popoverCloseTimer?.cancel();
    _popoverCloseTimer = null;
  }

  void _closePopover() {
    _cancelPopoverCloseTimer();
    try {
      _activePopoverController?.close();
    } catch (_) {}
    final needsRebuild = _activePopoverController != null || _popoverRowIndex != null;
    _activePopoverController = null;
    _popoverRowIndex = null;
    _isHoveringDropdown = false;
    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cancelPopoverCloseTimer();
    _hoveredRowIndex.removeListener(_onHoverChanged);
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
            final isRowHovered = hoveredIndex == rowIndex;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isRowHovered
                  ? resolveThemeColor(context,
                      dark: MyntColors.primary.withValues(alpha: 0.08),
                      light: MyntColors.primary.withValues(alpha: 0.08))
                  : null,
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

  // Build fund name cell with hover dropdown menu
  shadcn.TableCell _buildFundNameCellWithActions({
    required dynamic item,
    required int rowIndex,
    required ThemesProvider theme,
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
        onEnter: (_) {
          _hoveredRowIndex.value = rowIndex;
          if (_activePopoverController != null && _popoverRowIndex == rowIndex) {
            _cancelPopoverCloseTimer();
          }
        },
        onExit: (_) {
          _hoveredRowIndex.value = null;
          if (_activePopoverController != null && !_isHoveringDropdown) {
            _startPopoverCloseTimer();
          }
        },
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            final isHovered = hoveredIndex == rowIndex || _popoverRowIndex == rowIndex;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isHovered
                  ? resolveThemeColor(context,
                      dark: MyntColors.primary.withValues(alpha: 0.08),
                      light: MyntColors.primary.withValues(alpha: 0.08))
                  : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fund info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                          "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
                        ),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isHovered ? 40.0 : 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name ?? "Unknown Fund",
                                style: _getTextStyle(
                                    context,
                                    color: resolveThemeColor(context,
                                        dark: MyntColors.textPrimaryDark,
                                        light: MyntColors.textPrimary),
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                (item.sCHEMECATEGORY ?? "Other Scheme").toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 3-dot dropdown button on hover
                  if (isHovered)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildOptionsMenuButton(
                          item: item,
                          rowIndex: rowIndex,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Build the 3-dot options menu button with shadcn dropdown
  Widget _buildOptionsMenuButton({
    required dynamic item,
    required int rowIndex,
  }) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () {
            // Close any existing popover first
            _closePopover();

            // Build menu items
            List<shadcn.MenuItem> menuItems = [];
            final iconColor = resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary);
            final textColor = resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary);

            // One-Time option
            menuItems.add(
              _buildMenuButton(
                icon: Icons.payments_outlined,
                title: 'One-Time',
                iconColor: iconColor,
                textColor: textColor,
                onPressed: (ctx) {
                  _closePopover();
                  _handleOrder(item, 'One-time');
                },
              ),
            );

            // SIP option (only if SIP is allowed)
            if (item.sIPFLAG == "Y") {
              menuItems.add(
                _buildMenuButton(
                  icon: Icons.autorenew,
                  title: 'SIP',
                  iconColor: iconColor,
                  textColor: textColor,
                  onPressed: (ctx) {
                    _closePopover();
                    _handleOrder(item, 'SIP');
                  },
                ),
              );
            }

            // Divider
            menuItems.add(const shadcn.MenuDivider());

            // Details option
            menuItems.add(
              _buildMenuButton(
                icon: Icons.info_outline,
                title: 'Details',
                iconColor: iconColor,
                textColor: textColor,
                onPressed: (ctx) {
                  _closePopover();
                  // Navigate to details - can be implemented later
                },
              ),
            );

            // Create a controller for this popover
            final controller = shadcn.PopoverController();
            _activePopoverController = controller;
            _popoverRowIndex = rowIndex;

            // Show the shadcn popover menu anchored to this button
            controller.show(
              context: buttonContext,
              alignment: Alignment.topRight,
              offset: const Offset(0, 4),
              builder: (ctx) {
                return MouseRegion(
                  onEnter: (_) {
                    _isHoveringDropdown = true;
                    _cancelPopoverCloseTimer();
                  },
                  onExit: (_) {
                    _isHoveringDropdown = false;
                    _startPopoverCloseTimer();
                  },
                  child: shadcn.DropdownMenu(
                    children: menuItems,
                  ),
                );
              },
            );

            // Force rebuild to show row highlight
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.primary.withValues(alpha: 0.1),
                  light: MyntColors.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.more_vert,
              size: 18,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
        );
      },
    );
  }

  // Helper method for building menu buttons
  shadcn.MenuButton _buildMenuButton({
    required IconData icon,
    required String title,
    required void Function(BuildContext) onPressed,
    required Color iconColor,
    required Color textColor,
  }) {
    return shadcn.MenuButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
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
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                          size: 18,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                                style: MyntWebTextStyles.tableCell(context,
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
                                            const shadcn.FixedTableSize(60),
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
                                                _buildFundNameCellWithActions(
                                                  item: item,
                                                  rowIndex: index,
                                                  theme: theme,
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

}
