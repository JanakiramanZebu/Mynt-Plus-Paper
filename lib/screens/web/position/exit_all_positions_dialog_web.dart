import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/responsive_extensions.dart';
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
    ChartIframeGuard.acquire();
    _disableAllChartIframes();
  }

  /// Handle exit positions and close dialog when done
  Future<void> _handleExitAllPositions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final positionBook = ref.read(portfolioProvider);
      // FIX: Pass widget.isExitAll instead of hardcoded true
      // When isExitAll=true: exit ALL positions
      // When isExitAll=false: exit only SELECTED positions
      // Bug was introduced in commit 060b256a by divakar
      await positionBook.exitPosition(context, widget.isExitAll);

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
        if (iframe is html.IFrameElement &&
            iframe.id.contains('chart-iframe')) {
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
        if (iframe is html.IFrameElement &&
            iframe.id.contains('chart-iframe')) {
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
    final positionCount = widget.selectedPositions.length;

    // Responsive dialog sizing
    final dialogWidth = context.responsiveValue<double>(
      mobile: context.screenWidth * 0.9,
      smallTablet: 350,
      tablet: 380,
      desktop: 400,
    );
    final contentPadding = context.responsive<double>(
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    final headerHorizontalPadding = context.responsive<double>(
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    final buttonSpacing = context.responsive<double>(
      mobile: 18,
      tablet: 21,
      desktop: 24,
    );

    return PointerInterceptor(
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) {
          ChartIframeGuard.acquire();
          _disableAllChartIframes();
        },
        onHover: (_) {
          _disableAllChartIframes();
        },
        onExit: (_) {
          ChartIframeGuard.release();
          _enableAllChartIframes();
        },
        child: Listener(
          onPointerMove: (_) {
            _disableAllChartIframes();
          },
          child: Center(
            child: shadcn.Card(
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.zero,
              child: Container(
                width: dialogWidth,
                constraints: const BoxConstraints(maxHeight: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: headerHorizontalPadding,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                shadcn.Theme.of(context).colorScheme.border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exit Positions',
                            style: context.isMobile
                                ? MyntWebTextStyles.body(
                                    context,
                                    color: resolveThemeColor(
                                      context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary,
                                    ),
                                    fontWeight: MyntFonts.medium,
                                  )
                                : MyntWebTextStyles.title(
                                    context,
                                    color: resolveThemeColor(
                                      context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary,
                                    ),
                                  ),
                          ),
                          MyntCloseButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(contentPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.isExitAll
                                  ? 'Are you sure you want to square off all $positionCount open positions?'
                                  : 'Are you sure you want to square off $positionCount selected position${positionCount > 1 ? 's' : ''}?',
                              textAlign: TextAlign.center,
                              style: context.isMobile
                                  ? MyntWebTextStyles.bodySmall(
                                      context,
                                      fontWeight: FontWeight.w500,
                                      color: resolveThemeColor(
                                        context,
                                        dark: MyntColors.textPrimaryDark,
                                        light: MyntColors.textPrimary,
                                      ),
                                    )
                                  : MyntWebTextStyles.body(
                                      context,
                                      fontWeight: FontWeight.w500,
                                      color: resolveThemeColor(
                                        context,
                                        dark: MyntColors.textPrimaryDark,
                                        light: MyntColors.textPrimary,
                                      ),
                                    ),
                            ),
                            SizedBox(height: buttonSpacing),
                            MyntButton(
                              type: MyntButtonType.primary,
                              size: context.isMobile
                                  ? MyntButtonSize.medium
                                  : MyntButtonSize.large,
                              label: 'Exit Order',
                              isFullWidth: true,
                              isLoading: _isLoading,
                              backgroundColor: resolveThemeColor(
                                context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary,
                              ),
                              onPressed:
                                  _isLoading || widget.selectedPositions.isEmpty
                                      ? null
                                      : _handleExitAllPositions,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
