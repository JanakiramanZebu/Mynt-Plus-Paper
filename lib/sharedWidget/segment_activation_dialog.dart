import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/thems.dart';
import '../res/res.dart';
import '../res/global_state_text.dart';

class SegmentActivationDialog extends ConsumerWidget {
  final String segmentName;
  final VoidCallback onActivate;

  const SegmentActivationDialog({
    super.key,
    required this.segmentName,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    return AlertDialog(
      backgroundColor: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      scrollable: true,
      titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: "Segment Not Active",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 3,
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 150));
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
              highlightColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: "You are not active in the $segmentName segment. Please activate this segment to place orders.",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
            align: TextAlign.left,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  side: BorderSide(
                    color: theme.isDarkMode ? colors.btnOutlinedBorder : colors.btnOutlinedBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: TextWidget.subText(
                  text: "Cancel",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.pop(context);
                  onActivate();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                ),
                child: TextWidget.subText(
                  text: "Activate Segment",
                  theme: theme.isDarkMode,
                  color: colors.colorWhite,
                  fw: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
