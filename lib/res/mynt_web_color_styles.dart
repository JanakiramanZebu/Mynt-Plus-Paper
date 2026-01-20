import 'package:flutter/material.dart';

/// ===============================================================
/// WEB COLORS (Brand + Business + Semantic Aliases)
/// ===============================================================
/// 
/// Usage: Use the singleton instance `MyntColors` instead of `WebColors()`
/// Example: MyntColors.primary instead of WebColors().primary
/// 
class WebColors {
  // Private constructor for singleton pattern
  const WebColors._();
  
  // Singleton instance - use this instead of WebColors()
  static const WebColors instance = WebColors._();

  // ---------------- BRAND ----------------

  static const Color primary = Color(0xFF0037B7);
  static const Color primaryDark = Color(0xFF002A8F);

  static const Color secondary = Color(0xFF0052CC);

  static const Color tertiary = Color(0xFFC40024);

  //-------------------------Text---------------------

  static const Color textPrimary = Color(0xFF121212);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textSecondaryDark = Color(0xFF8A8A8A);

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

  static const Color backgroundColor = Color(0xFFffffff);
static const Color backgroundColorDark  = Color(0xFF000000);


  // ---------------- BORDER / DIVIDER (Custom only) ----------------

  static const Color divider = Color(0xFFDDE2E7);
  static const Color dividerDark = Color(0xFF27272A);

  static const Color outlinedBorder = Color(0xFF0037B7);
  static const Color outlinedBorderDark = Color(0xFF2E65F6);

  // ---------------- ICON (Custom only) ----------------

  static const Color icon = Color(0xFF4A4A4A);
  static const Color iconDark = Color(0xFF8A8A8A);

  static const Color modalBarrierLight = Color(0x66000000); // black @ 40%
static const Color modalBarrierDark  = Color(0x99000000); // black @ 60%


// ---------------- SCROLLBAR ----------------
static const Color scrollbarThumbLight = Color(0x804A4A4A); // textSecondary @ 50%
static const Color scrollbarThumbDark  = Color(0x808A8A8A); // textSecondaryDark @ 50%

// ---------------- INTERACTION / RIPPLE ----------------
static const Color rippleLight = Color(0x26000000); // black @ 15%
static const Color rippleDark  = Color(0x26FFFFFF); // white @ 15%

static const Color highlightLight = Color(0x14000000); // black @ 8%
static const Color highlightDark  = Color(0x14FFFFFF); // white @ 8%




}

/// Convenient alias for WebColors - use this throughout the app
/// Example: MyntColors.primary, MyntColors.textPrimaryDark
typedef MyntColors = WebColors;
