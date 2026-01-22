import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/common_buttons_web.dart';

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
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final positionBook = ref.read(portfolioProvider);

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
                      : () => positionBook.exitPosition(context, true),
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
