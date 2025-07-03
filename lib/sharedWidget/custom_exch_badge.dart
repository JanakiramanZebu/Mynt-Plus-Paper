import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';

import '../provider/thems.dart';
import '../res/global_state_text.dart';
<<<<<<< HEAD
import '../res/res.dart';
=======
>>>>>>> 9869f2b53d8963762cb31e72b98a185281f0ffd9

// A cached map of exchange badges to avoid recreating them
final _exchangeBadgeCache = <String, Widget>{};

class CustomExchBadge extends ConsumerWidget {
  final String exch;

  // Constructor with const for optimization
  const CustomExchBadge({super.key, required this.exch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    // Use the cacheKey to identify this specific badge
    final cacheKey = '${exch}_${theme.isDarkMode}';

    // Return cached version if available
    if (_exchangeBadgeCache.containsKey(cacheKey)) {
      return _exchangeBadgeCache[cacheKey]!;
    }

    // Create a new badge if not in cache
    final badge = Container(
<<<<<<< HEAD
      child: TextWidget.paraText(
        text: exch,
        textOverflow: TextOverflow.ellipsis,
        maxLines: 1,
        color: colors.textSecondaryLight,
        theme: theme.isDarkMode,
=======
      child: TextWidget.subText(
        text: exch,
        textOverflow: TextOverflow.ellipsis,
        maxLines: 1,
        color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        theme: false,
        fw: 3,
>>>>>>> 9869f2b53d8963762cb31e72b98a185281f0ffd9
      ),
    );

    // Cache the badge for future use
    _exchangeBadgeCache[cacheKey] = badge;
    return badge;
  }
}
