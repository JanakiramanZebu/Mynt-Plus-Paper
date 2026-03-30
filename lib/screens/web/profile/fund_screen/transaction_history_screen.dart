import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/models/fund_model_testing_copy/client_history_model.dart';
import 'package:mynt_plus/res/assets.dart';
import 'package:mynt_plus/sharedWidget/common_search_fields_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../res/responsive_extensions.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const TransactionHistoryScreen({super.key, this.onBack});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<ClientHistoryItem> _transactions = [];
  String? _error;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  final ScrollController _verticalScrollController = ScrollController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final TextEditingController _searchController = TextEditingController();
  final _assets = Assets();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery.value) {
        _searchQuery.value = _searchController.text;
      }
    });
    _fetchHistory();
  }

  @override
  void dispose() {
    _hoveredRowIndex.dispose();
    _verticalScrollController.dispose();
    _searchQuery.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ClientHistoryItem> _getFilteredTransactions() {
    final query = _searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return _transactions;
    return _transactions.where((item) {
      final date = _formatDate(item.dateTime).toLowerCase();
      final order = (item.orderNumber ?? '').toLowerCase();
      final type = (item.transtype ?? '').toLowerCase();
      final amount = (item.amount ?? '').toLowerCase();
      return date.contains(query) ||
          order.contains(query) ||
          type.contains(query) ||
          amount.contains(query);
    }).toList();
  }

  Future<void> _fetchHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final api = locator<ApiExporter>();
      final response = await api.getClientHistory();
      if (mounted) {
        setState(() {
          _transactions = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load transactions";
          _isLoading = false;
        });
      }
    }
  }

  // Text styles matching holdings table
  TextStyle _cellStyle({Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _headerStyle() {
    return MyntWebTextStyles.tableHeader(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      appBar: AppBar(
        centerTitle: false,
        leadingWidth: 48,
        titleSpacing: 6,
        backgroundColor: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: MyntColors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            size: 18,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction History',
          style: MyntWebTextStyles.title(
            context,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
            fontWeight: MyntFonts.semiBold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: context.responsiveValue<double>(
                mobile: 140,
                smallTablet: 180,
                tablet: 220,
                desktop: 300,
                largeDesktop: 350,
                widescreen: 400,
              ),
              child: MyntSearchTextField.withSmartClear(
                controller: _searchController,
                placeholder: 'Search transactions',
                leadingIcon: _assets.searchIcon,
                onClear: () => _searchController.clear(),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: resolveThemeColor(context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: MyntWebTextStyles.body(context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.errorDark,
                                  light: MyntColors.error))),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: _fetchHistory,
                          child: const Text("Retry")),
                    ],
                  ),
                )
              : _transactions.isEmpty
                  ? Center(
                      child: Text(
                        "No transactions found",
                        style: MyntWebTextStyles.body(
                          context,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary),
                        ),
                      ),
                    )
                  : LayoutBuilder(builder: (context, constraints) {
                      return _buildTable(constraints);
                    }),
    );
  }

  Widget _buildTable(BoxConstraints constraints) {
    final totalWidth = constraints.maxWidth;

    // Column: Icon 5%, Date 18%, OrderNo 22%, Type 13%, Gateway 10%, Amount 16%, Status 16%
    final iconW    = totalWidth * 0.05;
    final dateW    = totalWidth * 0.18;
    final orderW   = totalWidth * 0.22;
    final typeW    = totalWidth * 0.13;
    final gatewayW = totalWidth * 0.10;
    final amountW  = totalWidth * 0.16;
    final statusW  = totalWidth * 0.16;

    final columnWidths = <int, shadcn.TableSize>{
      0: shadcn.FixedTableSize(iconW),
      1: shadcn.FixedTableSize(dateW),
      2: shadcn.FixedTableSize(orderW),
      3: shadcn.FixedTableSize(typeW),
      4: shadcn.FixedTableSize(gatewayW),
      5: shadcn.FixedTableSize(amountW),
      6: shadcn.FixedTableSize(statusW),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Fixed header
          shadcn.Table(
            columnWidths: columnWidths,
            defaultRowHeight: const shadcn.FixedTableSize(44),
            rows: [
              shadcn.TableHeader(
                cells: [
                  _buildHeaderCell('', isFirst: true),
                  _buildHeaderCell('Date & Time'),
                  _buildHeaderCell('Order No'),
                  _buildHeaderCell('Type'),
                  _buildHeaderCell('Gateway'),
                  _buildHeaderCell('Amount', alignRight: true),
                  _buildHeaderCell('Status', isLast: true),
                ],
              ),
            ],
          ),
        // Scrollable body
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, query, _) {
              final filtered = _getFilteredTransactions();
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'No matching transactions',
                    style: MyntWebTextStyles.body(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                  ),
                );
              }
              return RawScrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            trackColor: resolveThemeColor(context,
                dark: MyntColors.scrollbarTrackDark,
                light: MyntColors.scrollbarTrack),
            thumbColor: resolveThemeColor(context,
                dark: MyntColors.scrollbarThumbDark,
                light: MyntColors.scrollbarThumbLight),
            thickness: 6,
            radius: const Radius.circular(3),
            interactive: true,
            child: ListView.builder(
              controller: _verticalScrollController,
              itemCount: filtered.length,
              itemExtent: 50.0,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return shadcn.Table(
                  columnWidths: columnWidths,
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableRow(
                      cells: [
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 0,
                          isFirst: true,
                          child: _buildBankLogo(
                              _extractBankCode(item.bankifsc)),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 1,
                          child: Text(_formatDate(item.dateTime),
                              style: _cellStyle(),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 2,
                          child: Text(item.orderNumber ?? "-",
                              style: _cellStyle(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                              ),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 3,
                          child: Text(item.transtype ?? "-",
                              style: _cellStyle(),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 4,
                          child: Text(item.vendor ?? "-",
                              style: _cellStyle(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                              ),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 5,
                          alignRight: true,
                          child: Text("₹${item.amount ?? "0.00"}",
                              style: _cellStyle().copyWith(
                                  fontWeight: MyntFonts.semiBold),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 6,
                          isLast: true,
                          child: _buildStatusChip(item),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
              );
            },
          ),
        ),
      ],
      ),
    );
  }

  shadcn.TableCell _buildHeaderCell(String label,
      {bool alignRight = false, bool isFirst = false, bool isLast = false}) {
    EdgeInsets padding;
    if (isFirst) {
      padding = const EdgeInsets.fromLTRB(16, 6, 4, 6);
    } else if (isLast) {
      padding = const EdgeInsets.fromLTRB(4, 6, 16, 6);
    } else {
      padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    }

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
        padding: padding,
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(label, style: _headerStyle()),
      ),
    );
  }

  shadcn.TableCell _buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    EdgeInsets cellPadding;
    if (isFirst) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLast) {
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }

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
          child: child,
          builder: (context, hoveredIndex, cachedChild) {
            final isRowHovered = hoveredIndex == rowIndex;
            return Container(
              padding: cellPadding,
              alignment:
                  alignRight ? Alignment.centerRight : Alignment.centerLeft,
              color: isRowHovered
                  ? resolveThemeColor(
                      context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary,
                    ).withValues(alpha: 0.06)
                  : Colors.transparent,
              child: cachedChild,
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(ClientHistoryItem item) {
    final statusColor = _getStatusColor(item.status);
    final reason = item.statusDescription ?? item.status ?? "-";
    return Tooltip(
      message: reason,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          (item.status ?? "-").toUpperCase(),
          style: MyntWebTextStyles.bodySmall(
            context,
            color: statusColor,
            fontWeight: MyntFonts.medium,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildBankLogo(String? bankCode) {
    if (bankCode == null) {
      return Icon(
        Icons.account_balance_rounded,
        size: 18,
        color: resolveThemeColor(context,
            dark: MyntColors.iconSecondaryDark,
            light: MyntColors.iconSecondary),
      );
    }

    final logoUrl =
        "https://ekycbe.mynt.in/zebu/banklogo?bank=$bankCode&type=svg";
    return SvgPicture.network(
      logoUrl,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => Icon(
        Icons.account_balance_rounded,
        size: 18,
        color: resolveThemeColor(context,
            dark: MyntColors.iconSecondaryDark,
            light: MyntColors.iconSecondary),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      case 'FAILURE':
      case 'FAILED':
      case 'REJECTED':
      case 'EXPIRED':
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      case 'INITIATED':
      case 'PENDING':
        return resolveThemeColor(context,
            dark: MyntColors.warning, light: MyntColors.warning);
      default:
        return resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.textSecondary);
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return "-";
    try {
      final parsed =
          DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(dateTime);
      return DateFormat("dd MMM yyyy, hh:mm a").format(parsed);
    } catch (_) {
      return dateTime;
    }
  }

  String? _extractBankCode(String? ifsc) {
    if (ifsc == null || ifsc == "NA" || ifsc == "None" || ifsc.length < 4) {
      return null;
    }
    return ifsc.substring(0, 4);
  }
}
