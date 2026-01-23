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
  TextStyle _getTextStyle(BuildContext context, {Color? color, double? fontSize}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        // onExit: (_) => _hoveredRowIndex.value = null, // Don't clear on exit to keep last hovered if needed, usually we clear
        onExit: (_) => _hoveredRowIndex.value = null, 
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            // final isRowHovered = hoveredIndex == rowIndex; // Unused
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: null, // Removed hover color as requested
              alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            );
          },
        ),
      ),
    );
  }

  // --- Logic ---

  Future<void> _handleOrder(dynamic nfoItem, String type) async {
     final mf = ref.read(mfProvider);
     
     // Show loader while fetching dependencies
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => const Center(child: CircularProgressIndicator()),
     );
     
     try {
      // Fetch bank details to prevent null error in MFOrderScreen
      await ref.read(transcationProvider).fetchfundbank(context);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loader

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
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: 450,
              height: 650,
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
      backgroundColor: theme.isDarkMode ? colors.kColorDarkThemeBackground : colors.kColorlightThemeBackground,
      body: SafeArea(
        child: TransparentLoaderScreen(
          isLoading: mf.investloader,
          child: Column(
            children: [
              // --- Header Section ---
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Back Button (Left side)
                    IconButton(
                      onPressed: widget.onBack ?? () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, size: 20, color: theme.isDarkMode ? Colors.white : Colors.black),
                      tooltip: "Back",
                    ),
                    const SizedBox(width: 16),
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.card_giftcard, color: Colors.red, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "New Fund Offerings",
                                style: MyntWebTextStyles.head(context, 
                                  darkColor: MyntColors.textPrimaryDark, 
                                  lightColor: MyntColors.textPrimary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.colorBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  filteredList.length.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
                            style: MyntWebTextStyles.bodySmall(context, 
                                darkColor: MyntColors.textSecondaryDark, 
                                lightColor: MyntColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Search Bar
                    SizedBox(
                      width: 250,
                      child: shadcn.Theme(
                        data: shadcn.Theme.of(context).copyWith(
                          colorScheme: () => shadcn.Theme.of(context).colorScheme.copyWith(
                                ring: () => Colors.transparent,
                              ),
                        ),
                        child: shadcn.TextField(
                          controller: _searchController,
                          placeholder: const Text('Search'),
                          features: [
                            shadcn.InputFeature.leading(
                                const Icon(Icons.search, size: 16)),
                          ],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Table Section ---
              Expanded(
                child: filteredList.isEmpty
                  ? NoDataFound(secondaryEnabled: false, title: "No NFOs Found")
                  : shadcn.Table(
                      defaultRowHeight: const shadcn.FixedTableSize(70),
                      columnWidths: const {
                        0: shadcn.FlexTableSize(flex: 3), // Fund name
                        1: shadcn.FlexTableSize(flex: 1), // Opening
                        2: shadcn.FlexTableSize(flex: 1), // Closing
                        3: shadcn.FlexTableSize(flex: 1), // Min Invest
                      },
                      rows: [
                        // Header
                        shadcn.TableHeader(
                          cells: [
                            buildHeaderCell('Fund name'),
                            buildHeaderCell('Opening'),
                            buildHeaderCell('Closing'),
                            buildHeaderCell('Min. Invest', true),
                          ],
                        ),
                        // Data Rows
                        ...filteredList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return shadcn.TableRow(
                            cells: [
                              // Fund Name + Actions
                              buildCellWithHover(
                                rowIndex: index,
                                child: Row(
                                  children: [
                                    // Logo
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: NetworkImage(
                                        "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
                                      ),
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 12),
                                    // Name & Tags
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.name ?? "Unknown Fund",
                                            style: _getTextStyle(context, 
                                              color: null, // Changed from blue to default (black/theme)
                                              fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _buildTag(item.sCHEMECATEGORY ?? "OTHER SCHEME", theme),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Hover Actions
                                    ValueListenableBuilder<int?>(
                                      valueListenable: _hoveredRowIndex,
                                      builder: (context, hoveredIndex, _) {
                                        // Show buttons if row is hovered
                                        if (hoveredIndex == index) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildActionButton(
                                                context, 
                                                "Buy", 
                                                colors.colorBlue, 
                                                Colors.white, 
                                                () => _handleOrder(item, "One-time")),
                                              if (item.sIPFLAG == "Y") ...[
                                                const SizedBox(width: 8),
                                                  _buildActionButton(
                                                  context, 
                                                  "SIP", 
                                                  Colors.transparent, 
                                                  colors.colorBlue, 
                                                  () => _handleOrder(item, "SIP"),
                                                  isOutlined: true),
                                              ]
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Opening
                              buildCellWithHover(
                                rowIndex: index,
                                child: Text(_formatDate(item.startDate), style: _getTextStyle(context)),
                              ),
                              // Closing
                              buildCellWithHover(
                                rowIndex: index,
                                child: Text(_formatDate(item.endDate), style: _getTextStyle(context)),
                              ),
                              // Min Invest
                              buildCellWithHover(
                                rowIndex: index,
                                alignRight: true,
                                child: Text(
                                  "₹${double.tryParse(item.minimumPurchaseAmount ?? '0')?.toStringAsFixed(2) ?? '0.00'}", 
                                  style: _getTextStyle(context)
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.grey[800] : Colors.grey[200],
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

  Widget _buildActionButton(BuildContext context, String label, Color bg, Color fn, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: isOutlined ? Border.all(color: fn) : null,
        ),
        child: Text(
          label,
          style: TextStyle(color: fn, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
