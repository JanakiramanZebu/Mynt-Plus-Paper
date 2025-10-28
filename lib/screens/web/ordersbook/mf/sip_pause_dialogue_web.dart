import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';

class SipPauseDialogueWeb extends ConsumerWidget {
  final Xsip sipData;

  const SipPauseDialogueWeb({
    super.key,
    required this.sipData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                    highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // SIP Name
            Text(
              sipData.name ?? "",
              textAlign: TextAlign.center,
              style: TextWidget.textStyle(
                fontSize: 18,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                fw: 3,
              ),
            ),
            const SizedBox(height: 16),
            
            // Confirmation message
            Text(
              "Do you want to Pause this SIP?",
              textAlign: TextAlign.center,
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                fw: 3,
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                    highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                    onTap: () {
                      // TODO: Implement pause SIP functionality
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Close detail screen too
                    },
                    child: Center(
                      child: Text(
                        "Pause SIP",
                        style: TextWidget.textStyle(
                          fontSize: 16,
                          theme: false,
                          color: colors.colorWhite,
                          fw: 2,
                        ),
                      ),
                    ),
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

