import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/thems.dart'; 

// A cached map of exchange badges to avoid recreating them
final _exchangeBadgeCache = <String, Widget>{};

class CustomExchBadge extends StatelessWidget {
  final String exch;
  
  // Constructor with const for optimization
  const CustomExchBadge({super.key, required this.exch});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    
    // Use the cacheKey to identify this specific badge
    final cacheKey = '${exch}_${theme.isDarkMode}';
    
    // Return cached version if available
    if (_exchangeBadgeCache.containsKey(cacheKey)) {
      return _exchangeBadgeCache[cacheKey]!;
    }
    
    // Create a new badge if not in cache
    final badge = Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: theme.isDarkMode
              ? const Color(0xff666666).withOpacity(.3)
              : const Color(0xffF1F3F8)),
      child: Text(exch,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: _getTextStyle(
              theme.isDarkMode
                  ? const Color(0xffFFFFFF)
                  : const Color(0xff666666),
              10,
              FontWeight.w500)),
    );
    
    // Cache the badge for future use
    _exchangeBadgeCache[cacheKey] = badge;
    return badge;
  }

  // Static text style method to avoid creating new instances
  static TextStyle _getTextStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
