import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import '../provider/thems.dart';
import '../res/res.dart';

class CameraPermissionDialog extends ConsumerWidget {
  const CameraPermissionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: theme.isDarkMode 
          ? const Color(0xFF1E1E1E) 
          : Colors.white,
      title: Row(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: theme.isDarkMode 
                ? colors.colorWhite 
                : colors.colorBlack,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextWidget.subText(
              text: "Camera Permission Required",
              theme: theme.isDarkMode,
              color: theme.isDarkMode 
                  ? colors.textPrimaryDark 
                  : colors.textPrimaryLight,
             fw: 0
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.paraText(
            text: "To scan QR codes, please enable camera permission in your device settings.",
            theme: theme.isDarkMode,
            color: theme.isDarkMode 
                ? colors.textSecondaryDark 
                : colors.textSecondaryLight,
            fw: 3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                  ? colors.colorBlack.withOpacity(0.3) 
                  : colors.colorGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                  text: Platform.isAndroid ? "For Android:" : "For iOS:",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode 
                      ? colors.textPrimaryDark 
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
               
               
                const SizedBox(height: 8),
                if (Platform.isAndroid) ...[
                  _buildStep(theme, "1. Go to Settings"),
                  _buildStep(theme, "2. Tap on Apps & notifications"),
                  _buildStep(theme, "3. Find and tap on Mynt"),
                  _buildStep(theme, "4. Tap on Permissions"),
                  _buildStep(theme, "5. Enable Camera permission"),
                ] else ...[
                  _buildStep(theme, "1. Go to Settings"),
                  _buildStep(theme, "2. Scroll down and tap on Mynt"),
                  _buildStep(theme, "3. Tap on Camera"),
                  _buildStep(theme, "4. Select 'Allow'"),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () { 
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: theme.isDarkMode 
                  ? colors.colorWhite.withOpacity(0.7) 
                  : colors.colorGrey,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _openAppSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            "Open Settings",
            style: TextStyle(
              color: colors.colorWhite,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(ThemesProvider theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   width: 4,
          //   height: 4,
          //   margin: const EdgeInsets.only(top: 6, right: 8),
          //   decoration: BoxDecoration(
          //     color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          //     shape: BoxShape.circle,
          //   ),
          // ),
          Expanded(
            child: TextWidget.paraText(
              text: text,
              theme: theme.isDarkMode,
              color: theme.isDarkMode 
                  ? colors.textPrimaryDark 
                  : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    try {
      // Method 1: Use permission_handler (most reliable)
      await openAppSettings();
    } catch (e) {
      try {
        // Method 2: Use app_settings package
        await AppSettings.openAppSettings();
      } catch (e2) {
        try {
          // Method 3: Use URL launcher with correct schemes
          if (Platform.isAndroid) {
            // Android: Open app-specific settings
            await launchUrl(
              Uri.parse('android.settings.APPLICATION_DETAILS_SETTINGS'),
              mode: LaunchMode.externalApplication,
            );
          } else if (Platform.isIOS) {
            // iOS: Open app settings
            await launchUrl(
              Uri.parse('app-settings:'),
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (e3) {
          try {
            // Method 4: Final fallback to general settings
            if (Platform.isAndroid) {
              await launchUrl(
                Uri.parse('android.settings.SETTINGS'),
                mode: LaunchMode.externalApplication,
              );
            } else if (Platform.isIOS) {
              await launchUrl(
                Uri.parse('app-prefs:'),
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (e4) {
            // If all else fails, show a message to user
            print('Unable to open settings: $e4');
          }
        }
      }
    }
  }
}
