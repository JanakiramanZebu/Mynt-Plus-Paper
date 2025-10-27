import 'package:flutter/material.dart';
import 'global_font_web.dart';
import 'web_colors.dart';

// Re-export the classes so they can be used directly
export 'global_font_web.dart';
export 'web_colors.dart';

// Global web resource variables (like in res.dart)
late WebFonts webFonts;
late WebColors webColors;
late WebDarkColors webDarkColors;
late WebTextStyles webTextStyles;

/// Web resource initialization (similar to res.dart but for web only)
void initializeWebResources() {
  webFonts = WebFonts();
  webColors = WebColors();
  webDarkColors = WebDarkColors();
  webTextStyles = WebTextStyles();
}
