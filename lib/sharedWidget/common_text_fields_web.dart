import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../res/mynt_web_text_styles.dart';
import '../res/mynt_web_color_styles.dart';

/// Common text field widget library for web project
/// Provides consistent text field styles across the application
///
/// Usage Examples:
///
/// 1. Basic text field:
///    MyntTextField(
///      controller: controller,
///      placeholder: 'Enter name',
///    )
///
/// 2. Text field with input formatters:
///    MyntTextField(
///      controller: controller,
///      placeholder: 'Enter watchlist name',
///      inputFormatters: [
///        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
///      ],
///    )
///
/// 3. Search field with icon:
///    MyntTextField(
///      controller: controller,
///      placeholder: 'Search & add',
///      leadingIcon: assets.searchIcon,
///    )

enum MyntTextFieldSize {
  small,
  medium,
  large,
}

/// Main text field widget
class MyntTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? placeholderWidget;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? leadingIcon;
  final Widget? leadingWidget;
  final bool leadingIconHoverEffect;
  final String? trailingIcon;
  final Widget? trailingWidget;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final double? height;
  final double? borderRadius;
  final MyntTextFieldSize size;
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const MyntTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.placeholderWidget,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.leadingIcon,
    this.leadingWidget,
    this.leadingIconHoverEffect = false,
    this.trailingIcon,
    this.trailingWidget,
    this.onClear,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.height,
    this.borderRadius,
    this.size = MyntTextFieldSize.medium,
    this.textStyle,
    this.placeholderStyle,
    this.backgroundColor,
    this.borderColor,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.textInputAction,
  }) : assert(
          placeholder != null || placeholderWidget != null,
          'Either placeholder or placeholderWidget must be provided',
        );

  @override
  State<MyntTextField> createState() => _MyntTextFieldState();
}

class _MyntTextFieldState extends State<MyntTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onClear != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standardized default height: 40 for all text fields
    final effectiveHeight = widget.height ?? 40;
    final effectiveBorderRadius = widget.borderRadius ?? _getDefaultBorderRadius();
    final effectiveTextStyle = widget.textStyle ?? _getDefaultTextStyle(context);
    final effectivePlaceholderStyle =
        widget.placeholderStyle ?? _getDefaultPlaceholderStyle(context);

    // Determine background color
    final effectiveBackgroundColor = widget.backgroundColor ??
        resolveThemeColor(
          context,
          darkColor: Color(0xffB5C0CF).withOpacity(.15),
          lightColor: Color(0xffF1F3F8),
        );

    // Determine border color
    final effectiveBorderColor = widget.borderColor ??
        resolveThemeColor(
          context,
          darkColor: WebColors.outlinedBorderDark,
          lightColor: WebColors.outlinedBorder,
        );

    // Build prefix icon
    Widget? prefixIconWidget;
    if (widget.leadingIcon != null) {
      prefixIconWidget = SvgPicture.asset(
        widget.leadingIcon!,
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
          resolveThemeColor(
            context,
            darkColor: WebColors.iconDark,
            lightColor: WebColors.icon,
          ),
          BlendMode.srcIn,
        ),
        fit: BoxFit.scaleDown,
      );
    } else if (widget.leadingWidget != null) {
      prefixIconWidget = widget.leadingWidget;
    }

    // Build suffix icon
    Widget? suffixIconWidget;
    if (widget.onClear != null && 
        widget.controller != null && 
        widget.controller!.text.isNotEmpty) {
      suffixIconWidget = IconButton(
        icon: Icon(Icons.clear, size: 16),
        onPressed: widget.onClear,
        color: resolveThemeColor(
          context,
          darkColor: WebColors.iconDark,
          lightColor: WebColors.icon,
        ),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      );
    } else if (widget.trailingIcon != null) {
      suffixIconWidget = SvgPicture.asset(
        widget.trailingIcon!,
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
          resolveThemeColor(
            context,
            darkColor: WebColors.iconDark,
            lightColor: WebColors.icon,
          ),
          BlendMode.srcIn,
        ),
        fit: BoxFit.scaleDown,
      );
    } else if (widget.trailingWidget != null) {
      suffixIconWidget = widget.trailingWidget;
    }

    Widget textField = TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      autofocus: false, // Always disabled
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      obscureText: widget.obscureText,
      textInputAction: widget.textInputAction,
      style: effectiveTextStyle,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: effectivePlaceholderStyle,
        prefixIcon: prefixIconWidget,
        suffixIcon: suffixIconWidget,
        filled: true,
        fillColor: effectiveBackgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
    );

    // Apply height constraint (always applied for consistency)
    textField = SizedBox(height: effectiveHeight, child: textField);

    return textField;
  }

  // Removed _getDefaultHeight - using standardized 40px height for all text fields

  double _getDefaultBorderRadius() {
    switch (widget.size) {
      case MyntTextFieldSize.small:
        return 4;
      case MyntTextFieldSize.medium:
        return 5;
      case MyntTextFieldSize.large:
        return 6;
    }
  }

  TextStyle _getDefaultTextStyle(BuildContext context) {
    switch (widget.size) {
      case MyntTextFieldSize.small:
        return WebTextStyles.bodySmall(context);
      case MyntTextFieldSize.medium:
        return WebTextStyles.searchText(context);
      case MyntTextFieldSize.large:
        return WebTextStyles.sub(context);
    }
  }

  TextStyle _getDefaultPlaceholderStyle(BuildContext context) {
    switch (widget.size) {
      case MyntTextFieldSize.small:
        return WebTextStyles.bodySmall(
          context,
          color: resolveThemeColor(
            context,
            darkColor: WebColors.textSecondaryDark,
            lightColor: WebColors.textSecondary,
          ),
        );
      case MyntTextFieldSize.medium:
        return WebTextStyles.placeholderText(context);
      case MyntTextFieldSize.large:
        return WebTextStyles.sub(
          context,
          color: resolveThemeColor(
            context,
            darkColor: WebColors.textSecondaryDark,
            lightColor: WebColors.textSecondary,
          ),
        );
    }
  }
}


/// Convenience widget for form input text fields
class MyntFormTextField extends MyntTextField {
  const MyntFormTextField({
    super.key,
    required super.controller,
    super.placeholder,
    super.placeholderWidget,
    super.enabled = true,
    super.autofocus = false,
    super.keyboardType,
    super.inputFormatters,
    super.textCapitalization = TextCapitalization.none,
    super.onChanged,
    super.onSubmitted,
    super.focusNode,
    super.height, // Defaults to 40 in MyntTextField
    super.borderRadius = 5,
    super.maxLines = 1,
    super.maxLength,
    super.obscureText = false,
    super.textInputAction,
  });
}

