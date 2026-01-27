import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../market_watch/tv_chart/chart_iframe_guard.dart';

class ExitAllPositionsDialogWeb extends ConsumerStatefulWidget {
  final List<PositionBookModel> selectedPositions;
  final List<int> selectedIndices;

  /// When true, exits ALL open positions. When false, exits only selected positions.
  final bool isExitAll;

  const ExitAllPositionsDialogWeb({
    super.key,
    required this.selectedPositions,
    required this.selectedIndices,
    required this.isExitAll,
  });

  @override
  ConsumerState<ExitAllPositionsDialogWeb> createState() =>
      _ExitAllPositionsDialogWebState();
}

class _ExitAllPositionsDialogWebState
    extends ConsumerState<ExitAllPositionsDialogWeb> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Disable chart iframe pointer events when dialog opens
    _disableAllChartIframes();
  }

  /// Handle exit all positions and close dialog when done
  Future<void> _handleExitAllPositions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final positionBook = ref.read(portfolioProvider);
      await positionBook.exitPosition(context, true);

      // Close the dialog after successful exit
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error exiting positions: $e');
      // Still close the dialog even on error
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    // Re-enable chart iframe pointer events when dialog closes
    ChartIframeGuard.release();
    _enableAllChartIframes();
    super.dispose();
  }

  // Disable all chart iframes to allow dialog interaction
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          iframe.style.cursor = 'default';
        }
      }
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  // Re-enable all chart iframes
  void _enableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
          iframe.style.cursor = '';
        }
      }
      html.document.body?.style.cursor = '';
    } catch (e) {
      debugPrint('Error enabling iframes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: resolveThemeColor(context,
              dark: MyntColors.listItemBgDark, light: MyntColors.textWhite),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close icon in top right
            Align(
              alignment: Alignment.centerRight,
              child: shadcn.IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => Navigator.of(context).pop(),
                variance: shadcn.ButtonVariance.ghost,
                size: shadcn.ButtonSize.small,
              ),
            ),

            const SizedBox(height: 2),

            // Confirmation Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: MyntWebTextStyles.title(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    fontWeight: MyntFonts.regular,
                  ).copyWith(fontSize: 18),
                  children: [
                    const TextSpan(text: 'Do you want to '),
                    TextSpan(
                      text: 'Square Off all',
                      style: TextStyle(fontWeight: MyntFonts.bold),
                    ),
                    const TextSpan(text: ' open positions?'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Exit Order Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: MyntPrimaryButton(
                  onPressed: _isLoading || widget.selectedPositions.isEmpty
                      ? null
                      : _handleExitAllPositions,
                  label: 'Exit Order',
                  isLoading: _isLoading,
                  backgroundColor: resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
                  isFullWidth: true,
                  size: MyntButtonSize.large,
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
