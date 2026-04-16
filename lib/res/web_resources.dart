import 'global_font_web.dart';
import 'web_colors.dart';
import 'res.dart'; // Import to access late variables (colors, assets, textStyles, webTextStyles)
import 'colors.dart'; // Import AppColors class
import 'assets.dart'; // Import Assets class
import 'text_styles.dart'; // Import AppTextStyles class

// Re-export the classes so they can be used directly
export 'global_font_web.dart';
export 'web_colors.dart';

// Global web resource variables (like in res.dart)
late WebFonts webFonts;
late WebColors webColors;
late WebDarkColors webDarkColors;
late WebTextStyles webTextStyles;

/// Web resource initialization (similar to res.dart but for web only)
/// Also initializes mobile resources (colors, assets, textStyles) for compatibility
void initializeWebResources() {
  // Initialize web-specific resources
  webFonts = WebFonts();
  webColors = WebColors();
  webDarkColors = WebDarkColors();
  webTextStyles = WebTextStyles();
  
  // Also initialize mobile resources for screens that use them (like LoginBannerScreen)
  // This ensures compatibility with screens that import res.dart
  colors = AppColors();
  assets = Assets();
  textStyles = AppTextStyles();
  // webTextStyles is already initialized above, no need to set it twice
}
