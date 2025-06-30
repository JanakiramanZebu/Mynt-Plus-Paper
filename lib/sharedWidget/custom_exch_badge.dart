import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/thems.dart';
import '../res/global_state_text.dart'; 

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
     
      
         
         
      child:

               TextWidget.paraText(
                      text: exch,
                      textOverflow: TextOverflow.ellipsis,
                      maxLines: 1,                     
                      color:theme.isDarkMode
                  ? const Color(0xffFFFFFF)
                  : const Color(0xff666666), 
                      theme: theme.isDarkMode,
                      
                      
                      
                      ),
    );
    
    // Cache the badge for future use
    _exchangeBadgeCache[cacheKey] = badge;
    return badge;
  }
 
}
