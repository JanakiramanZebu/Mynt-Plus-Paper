import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Shadcn Button wrapper for Mynt Plus
class ShadButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final ShadButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool expanded;
  final bool isLoading;
  final Widget? child;

  const ShadButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ShadButtonVariant.primary,
    this.size = ShadButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.expanded = false,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = child ??
        Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: _iconSize),
              const SizedBox(width: 8),
            ],
            if (isLoading)
              SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(text),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: _iconSize),
            ],
          ],
        );

    final button = shadcn.Button(
      onPressed: isLoading ? null : onPressed,
      style: _mapStyle(),
      child: content,
    );

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  // -------------------------
  // Helpers
  // -------------------------

  double get _iconSize {
    switch (size) {
      case ShadButtonSize.small:
        return 14;
      case ShadButtonSize.medium:
        return 16;
      case ShadButtonSize.large:
        return 18;
      case ShadButtonSize.icon:
        return 20;
    }
  }

  shadcn.ButtonStyle _mapStyle() {
    switch (variant) {
      case ShadButtonVariant.primary:
        return shadcn.ButtonStyle.primary();
      case ShadButtonVariant.secondary:
        return shadcn.ButtonStyle.secondary();
      case ShadButtonVariant.outline:
        return shadcn.ButtonStyle.outline();
      case ShadButtonVariant.ghost:
        return shadcn.ButtonStyle.ghost();
      case ShadButtonVariant.destructive:
        return shadcn.ButtonStyle.destructive();
      case ShadButtonVariant.link:
        return shadcn.ButtonStyle.link();
    }
  }
}

/// Button variants
enum ShadButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  link,
}

/// Button sizes (manual icon sizing only)
enum ShadButtonSize {
  small,
  medium,
  large,
  icon,
}

/// Icon-only button
class ShadIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final String? tooltip;

  const ShadIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = ShadButtonVariant.ghost,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ShadButton(
      text: '',
      onPressed: onPressed,
      variant: variant,
      size: ShadButtonSize.icon,
      child: Icon(icon),
    );

    return tooltip != null
        ? Tooltip(message: tooltip!, child: button)
        : button;
  }
}
