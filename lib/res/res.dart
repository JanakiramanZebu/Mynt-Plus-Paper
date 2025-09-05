import 'package:flutter/material.dart';

import 'assets.dart';
import 'colors.dart';
import 'text_styles.dart';

late Assets assets;
late AppColors colors;
// late AppSizes sizes;
late AppTextStyles textStyles;

// Exporting App colors,Asstes and text styles to acces the class

void initializeResources() {
  colors = AppColors();
  assets = Assets();
  textStyles = AppTextStyles();
  // sizes = AppSizes()..initializeSize(context);
}
