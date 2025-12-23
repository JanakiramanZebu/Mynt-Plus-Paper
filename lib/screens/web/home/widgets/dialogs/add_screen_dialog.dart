import 'package:flutter/material.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/screens/web/home/models/screen_type.dart';
import 'package:mynt_plus/screens/web/home/models/panel_config.dart';
import 'package:mynt_plus/screens/web/home/utils/screen_utils.dart';

class AddScreenDialog {
  static void show(
    BuildContext context,
    bool isDarkMode,
    PanelConfig panel,
    Function(ScreenType) onScreenSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color:
                        isDarkMode ? WebDarkColors.primary : WebColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Screen Tab',
                    style: textStyle(
                      isDarkMode ? colors.colorWhite : colors.colorBlack,
                      18,
                      2,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: Icon(
                  Icons.close,
                  color: colors.colorGrey,
                  size: 24,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...ScreenType.values
                      .where((screenType) =>
                          _shouldShowScreenOption(screenType, panel))
                      .map((screenType) => _buildScreenOption(
                          dialogContext, screenType, isDarkMode, panel, onScreenSelected)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static bool _shouldShowScreenOption(ScreenType screenType, PanelConfig panel) {
    // Check if current panel has watchlist
    bool panelHasWatchlist = panel.screenType == ScreenType.watchlist ||
        (panel.screens.isNotEmpty &&
            panel.screens.contains(ScreenType.watchlist));

    // If panel has watchlist, only allow watchlist to be added (no other screens)
    if (panelHasWatchlist) {
      if (screenType != ScreenType.watchlist) {
        return false;
      }
      // If it's watchlist, check if watchlist already exists
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));
      if (hasWatchlist) {
        return false;
      }
    }

    // Check if screen already exists in current panel
    bool alreadyExistsInPanel = panel.screens.contains(screenType);

    return !alreadyExistsInPanel;
  }

  static Widget _buildScreenOption(
    BuildContext context,
    ScreenType screenType,
    bool isDarkMode,
    PanelConfig panel,
    Function(ScreenType) onScreenSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onScreenSelected(screenType);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? colors.colorGrey.withOpacity(0.1)
                : colors.colorGrey.withOpacity(0.05),
            border: Border.all(
              color: isDarkMode
                  ? colors.colorGrey.withOpacity(0.2)
                  : colors.colorGrey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  ScreenUtils.getIconForScreenType(screenType),
                  color: isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ScreenUtils.getScreenTitle(screenType),
                  style: textStyle(
                    isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    1,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
