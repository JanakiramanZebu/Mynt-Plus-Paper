import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// ===============================================================
/// WEB COLORS (Brand + Business + Semantic Aliases)
/// ===============================================================
class WebColors {
  // ---------------- BRAND ----------------

  static const Color primary = Color(0xFF0037B7);
  static const Color primaryDark = Color(0xFF002A8F);

  static const Color secondary = Color(0xFF0052CC);

  static const Color tertiary = Color(0xFFC40024);

  //-------------------------Text---------------------

  final textPrimary = const Color(0xFF121212);
  final textPrimaryDark = const Color(0xFFFFFFFF);

  final textSecondary = const Color(0xFF4A4A4A);
  final textSecondaryDark = const Color(0xFF8A8A8A);

  // ---------------- BUSINESS / STATUS ----------------

  static const Color profit = Color(0xFF00B14F);
  static const Color profitDark = Color(0xFF68D391);

  static const Color loss = Color(0xFFFF1717);
  static const Color lossDark = Color(0xFFFF6B6B);

  static const Color success = Color(0xFF00B14F);
  static const Color successDark = Color(0xFF2F855A);

  static const Color error = Color(0xFFFF1717);
  static const Color errorDark = Color(0xFFC53030);

  static const Color warning = Color(0xFFFFB038);
  static const Color pending = Color(0xFFFFB038);

  // ---------------- BACKGROUND (Custom surfaces only) ----------------

  static const Color searchBg = Color(0xFFF9F9F9);
  static const Color searchBgDark = Color(0xFF1E1E1E);

  static const Color listItemBg = Color(0xFFF1F3F8);
  static const Color listItemBgDark = Color(0xFF1E1E1E);

  // ---------------- BORDER / DIVIDER (Custom only) ----------------

  static const Color divider = Color(0xFFDDE2E7);
  static const Color dividerDark = Color(0xFF27272A);

  static const Color outlinedBorder = Color(0xFF0037B7);
  static const Color outlinedBorderDark = Color(0xFF2E65F6);

  // ---------------- ICON (Custom only) ----------------

  static const Color icon = Color(0xFF777777);
  static const Color iconDark = Color(0xFF8A8A8A);
}
