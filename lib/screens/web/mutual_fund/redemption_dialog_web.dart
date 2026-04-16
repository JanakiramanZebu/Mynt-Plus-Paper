import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/res.dart';

class RedemptionDialogWeb extends ConsumerWidget {
  final dynamic holdingData;
  final ThemesProvider theme;

  const RedemptionDialogWeb({
    super.key,
    required this.holdingData,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mfdata = ref.watch(mfProvider);

    return Dialog(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 450, // Fixed width for web/desktop look
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Redemption",
                        style: MyntWebTextStyles.title(
                          context,
                          fontWeight: FontWeight.bold,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        holdingData.name ?? "Unknown Fund",
                        style: MyntWebTextStyles.body(
                          context,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(
              height: 1,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            const SizedBox(height: 24),

            // Units Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Redemption units",
                  style: MyntWebTextStyles.bodyMedium(
                    context,
                    fontWeight: FontWeight.w600,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: "Total units : ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                    children: [
                      TextSpan(
                        text: holdingData.avgQty ?? "0",
                        style: MyntWebTextStyles.body(
                          context,
                          fontWeight: FontWeight.bold,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Text Field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                ),
              ),
              child: TextField(
                controller: mfdata.redemptionQty,
                style: MyntWebTextStyles.body(
                  context,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                ),
                cursorColor: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  isDense: true,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Min. redemption units 0.001",
              style: MyntWebTextStyles.bodySmall(
                context,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),

            // Redeem Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement redemption logic
                  // Example: mfdata.placeRedeemOrder(...)
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff0037B7), // Blue color from image
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Redeem",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
