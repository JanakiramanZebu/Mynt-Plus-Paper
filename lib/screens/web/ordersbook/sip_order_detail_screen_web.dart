import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../models/order_book_model/sip_order_book.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../utils/responsive_snackbar.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../sharedWidget/functions.dart';
import '../../../routes/web_router.dart' show webNavigatorKey;

class SipOrderDetailScreenWeb extends ConsumerStatefulWidget {
  final SipDetails sipOrder;
  final BuildContext? parentContext;

  const SipOrderDetailScreenWeb({
    super.key,
    required this.sipOrder,
    this.parentContext,
  });

  @override
  ConsumerState<SipOrderDetailScreenWeb> createState() =>
      _SipOrderDetailScreenWebState();
}

class _SipOrderDetailScreenWebState
    extends ConsumerState<SipOrderDetailScreenWeb> {
  StreamSubscription? _socketSubscription;
  late SipDetails _sipOrder;

  @override
  void initState() {
    super.initState();
    _sipOrder = widget.sipOrder;
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  void _setupSocketSubscription() {
    if (!mounted || _sipOrder.scrips?.isEmpty == true) return;

    try {
      final wsProvider = ref.read(websocketProvider);

      _socketSubscription = wsProvider.socketDataStream.listen((socketData) {
        if (!mounted) return;

        bool hasUpdates = false;
        // Update LTP/change for all scrips in the basket
        for (int i = 0; i < _sipOrder.scrips!.length; i++) {
          final token = _sipOrder.scrips![i].token;
          if (token == null) continue;

          final data = socketData[token];
          if (data != null) {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();

            if (_isValidValue(lp)) {
              _sipOrder.scrips![i].ltp = lp;
              hasUpdates = true;
            }
            if (_isValidValue(pc)) {
              _sipOrder.scrips![i].perChange = pc;
              hasUpdates = true;
            }
            if (_isValidValue(chng)) {
              _sipOrder.scrips![i].change = chng;
              hasUpdates = true;
            }
          }
        }

        if (hasUpdates) {
          setState(() {});
        }
      });
    } catch (e) {
      debugPrint("Error setting up socket subscription: $e");
    }
  }

  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  String _getFrequencyText(String? frequency) {
    switch (frequency) {
      case '0':
        return 'Daily';
      case '1':
        return 'Weekly';
      case '2':
        return 'Fortnightly';
      case '3':
        return 'Monthly';
      default:
        return frequency ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          _buildHeader(context, theme),
          // Scrip info
          _buildScripInfo(context, theme),
          // Divider
          Divider(
            height: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
          // SIP Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIP Details',
                    style: MyntWebTextStyles.titlesub(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'SIP ID',
                      _sipOrder.internal?.sipId ?? 'N/A'),
                  _buildDetailRow(context, 'Registered On',
                      sipformatDateTime(value: _sipOrder.regDate ?? '')),
                  _buildDetailRow(context, 'Start Date',
                      duedateformate(value: _sipOrder.startDate ?? '')),
                  _buildDetailRow(context, 'Due Date',
                      duedateformate(value: _sipOrder.internal?.dueDate ?? '')),
                  _buildDetailRow(context, 'Execution Date',
                      duedateformate(value: _sipOrder.internal?.execDate ?? '')),
                  _buildDetailRow(
                      context, 'Frequency', _getFrequencyText(_sipOrder.frequency)),
                  _buildDetailRow(
                      context, 'Pending Period', _sipOrder.endPeriod ?? 'N/A'),
                  if (_sipOrder.scrips?.isNotEmpty == true) ...[
                    _buildDetailRow(
                        context,
                        'Product',
                        _sipOrder.scrips![0].sprdtali ?? 'N/A'),
                    _buildDetailRow(
                        context,
                        'Total Stocks',
                        '${_sipOrder.scrips!.length}'),
                  ],
                ],
              ),
            ),
          ),
          // Bottom action buttons
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SIP Order Details',
            style: MyntWebTextStyles.title(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
          IconButton(
            onPressed: () => shadcn.closeSheet(context),
            icon: Icon(
              Icons.close,
              color: resolveThemeColor(context,
                  dark: MyntColors.iconDark, light: MyntColors.icon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScripInfo(BuildContext context, ThemesProvider theme) {
    final scrips = _sipOrder.scrips ?? [];
    final hasMultipleScrips = scrips.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SIP Name header
          Text(
            _sipOrder.sipName ?? 'N/A',
            style: MyntWebTextStyles.titlesub(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
          if (hasMultipleScrips) ...[
            const SizedBox(height: 4),
            Text(
              '${scrips.length} stocks in basket',
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Display all scrips
          ...scrips.asMap().entries.map((entry) {
            final index = entry.key;
            final scrip = entry.value;
            return _buildScripRow(context, scrip, index, hasMultipleScrips);
          }),
        ],
      ),
    );
  }

  Widget _buildScripRow(BuildContext context, Scrips scrip, int index, bool showIndex) {
    final ltp = scrip.ltp ?? '0.00';
    final perChange = scrip.perChange ?? '0.00';
    final changeValue = double.tryParse(perChange) ?? 0.0;

    // Determine if this is qty or amount (prc) based SIP
    final isQtyMode = scrip.sipType != 'prc';
    final investLabel = isQtyMode ? 'Qty' : 'Amount';
    final investValue = isQtyMode ? (scrip.qty ?? '0') : '₹${scrip.prc ?? '0'}';

    Color changeColor;
    if (changeValue > 0) {
      changeColor = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (changeValue < 0) {
      changeColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else {
      changeColor = resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: showIndex
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scrip.tsym ?? 'N/A',
                  style: MyntWebTextStyles.body(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    fontWeight: MyntFonts.medium,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      scrip.exch ?? '',
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$investLabel: $investValue',
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$ltp',
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '($perChange%)',
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyntTertiaryButton(
              label: 'Cancel SIP',
              onPressed: () => _handleCancelSip(context),
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelSip(BuildContext context) async {
    // Capture needed data BEFORE closing sheet
    final orderProviderRef = ref.read(orderProvider);
    final sipId = _sipOrder.internal?.sipId ?? '';
    final sipName = _sipOrder.sipName ?? 'SIP';

    // Close the sheet FIRST
    shadcn.closeSheet(context);

    // Get navigator context for dialog and snackbar
    final navigatorContext = webNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    // Show confirmation dialog after sheet is closed
    final shouldCancel = await _showCancelConfirmDialogStandalone(navigatorContext, sipName);
    if (shouldCancel != true) return;

    // Perform cancel operation - fetchSipOrderCancel handles refresh and snackbar
    try {
      await orderProviderRef.fetchSipOrderCancel(sipId, navigatorContext);
    } catch (e) {
      if (navigatorContext.mounted) {
        ResponsiveSnackBar.showError(
            navigatorContext, 'Failed to cancel SIP order: ${e.toString()}');
      }
    }
  }

  /// Standalone cancel confirmation dialog that uses navigator context
  Future<bool?> _showCancelConfirmDialogStandalone(
      BuildContext navigatorContext, String sipName) async {
    return showDialog<bool>(
      context: navigatorContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(dialogContext,
                  dark: MyntColors.backgroundColorDark,
                  light: MyntColors.backgroundColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: shadcn.Border(
                      bottom: shadcn.BorderSide(
                        color: resolveThemeColor(
                          dialogContext,
                          dark: MyntColors.dividerDark,
                          light: MyntColors.divider,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cancel SIP Order',
                        style: MyntWebTextStyles.title(
                          dialogContext,
                          color: resolveThemeColor(dialogContext,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const shadcn.CircleBorder(),
                        child: InkWell(
                          customBorder: const shadcn.CircleBorder(),
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: resolveThemeColor(dialogContext,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Are you sure you want to cancel "$sipName"?',
                        textAlign: TextAlign.center,
                        style: MyntWebTextStyles.body(
                          dialogContext,
                          color: resolveThemeColor(dialogContext,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: resolveThemeColor(dialogContext,
                                dark: MyntColors.errorDark,
                                light: MyntColors.tertiary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Cancel SIP',
                            style: MyntWebTextStyles.buttonMd(
                              dialogContext,
                              color: Colors.white,
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
      },
    );
  }
}
