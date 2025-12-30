import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Shadcn Input wrapper for Mynt Plus
/// Provides a consistent input field API while using shadcn components
///
/// Usage:
/// ```dart
/// ShadInput(
///   label: 'Email',
///   placeholder: 'Enter your email',
///   controller: emailController,
/// )
/// ```
class ShadInput extends StatelessWidget {
  /// Input label (displayed above input)
  final String? label;

  /// Placeholder text
  final String? placeholder;

  /// Text controller
  final TextEditingController? controller;

  /// Initial value
  final String? initialValue;

  /// Callback when value changes
  final ValueChanged<String>? onChanged;

  /// Callback when editing is complete
  final VoidCallback? onEditingComplete;

  /// Callback when submitted
  final ValueChanged<String>? onSubmitted;

  /// Input type
  final TextInputType? keyboardType;

  /// Obscure text (for passwords)
  final bool obscureText;

  /// Max lines (1 for single line, >1 for multiline)
  final int maxLines;

  /// Min lines (for multiline)
  final int? minLines;

  /// Max length
  final int? maxLength;

  /// Enabled state
  final bool enabled;

  /// Read only
  final bool readOnly;

  /// Auto focus
  final bool autofocus;

  /// Error text (validation message)
  final String? errorText;

  /// Helper text (hint below input)
  final String? helperText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node
  final FocusNode? focusNode;

  /// Text input action
  final TextInputAction? textInputAction;

  const ShadInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Input field with icons wrapper
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: shadcn.TextField(
                controller: controller,
                initialValue: initialValue,
                placeholder: placeholder != null ? shadcn.Text(placeholder!) : null,
                obscureText: obscureText,
                enabled: enabled,
                readOnly: readOnly,
                autofocus: autofocus,
                maxLines: maxLines,
                minLines: minLines,
                maxLength: maxLength,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                focusNode: focusNode,
                textInputAction: textInputAction,
                onChanged: onChanged,
                onEditingComplete: onEditingComplete,
                onSubmitted: onSubmitted,
              ),
            ),
            if (suffixIcon != null) ...[
              const SizedBox(width: 8),
              Icon(suffixIcon, size: 16),
            ],
          ],
        ),

        // Helper or error text
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText ?? helperText!,
            style: TextStyle(
              fontSize: 12,
              color: errorText != null
                  ? theme.colorScheme.destructive
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

/// Form Field wrapper for ShadInput
/// Use this when you need form validation
class ShadFormField extends FormField<String> {
  ShadFormField({
    super.key,
    String? label,
    String? placeholder,
    TextEditingController? controller,
    String? initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    int? minLines,
    int? maxLength,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    String? helperText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          initialValue: controller != null ? controller.text : (initialValue ?? ''),
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            return ShadInput(
              label: label,
              placeholder: placeholder,
              controller: controller,
              initialValue: initialValue,
              keyboardType: keyboardType,
              obscureText: obscureText,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              enabled: enabled,
              readOnly: readOnly,
              autofocus: autofocus,
              errorText: field.errorText,
              helperText: helperText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              inputFormatters: inputFormatters,
              focusNode: focusNode,
              textInputAction: textInputAction,
              onChanged: (value) {
                field.didChange(value);
                onChanged?.call(value);
              },
              onEditingComplete: onEditingComplete,
              onSubmitted: onSubmitted,
            );
          },
        );
}
