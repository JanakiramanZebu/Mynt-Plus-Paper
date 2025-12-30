import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../buttons/shad_button.dart';

/// Shadcn Dialog wrapper for Mynt Plus
/// Provides a consistent dialog API while using shadcn components
///
/// Usage:
/// ```dart
/// showShadDialog(
///   context: context,
///   title: 'Confirm Action',
///   description: 'Are you sure you want to continue?',
///   actions: [
///     ShadDialogAction(
///       text: 'Cancel',
///       onPressed: () => Navigator.pop(context),
///       variant: ShadButtonVariant.outline,
///     ),
///     ShadDialogAction(
///       text: 'Continue',
///       onPressed: () {
///         // Handle action
///         Navigator.pop(context);
///       },
///     ),
///   ],
/// );
/// ```

/// Show a shadcn dialog
Future<T?> showShadDialog<T>({
  required BuildContext context,
  required String title,
  String? description,
  Widget? content,
  List<ShadDialogAction>? actions,
  bool barrierDismissible = true,
  double? width,
  double? maxWidth = 500,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ShadDialog(
      title: title,
      description: description,
      content: content,
      actions: actions,
      width: width,
      maxWidth: maxWidth,
    ),
  );
}

/// Shadcn Dialog widget
class ShadDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;
  final List<ShadDialogAction>? actions;
  final double? width;
  final double? maxWidth;

  const ShadDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    this.actions,
    this.width,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 500,
        ),
        decoration: BoxDecoration(
          color: shadcn.Theme.of(context).colorScheme.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Description
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],

              // Content
              if (content != null) ...[
                const SizedBox(height: 16),
                content!,
              ],

              // Actions
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      ShadButton(
                        text: actions![i].text,
                        onPressed: actions![i].onPressed,
                        variant: actions![i].variant,
                        isLoading: actions![i].isLoading,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog action configuration
class ShadDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final bool isLoading;

  const ShadDialogAction({
    required this.text,
    this.onPressed,
    this.variant = ShadButtonVariant.primary,
    this.isLoading = false,
  });
}

/// Show a confirmation dialog (Yes/No)
Future<bool?> showShadConfirmDialog({
  required BuildContext context,
  required String title,
  String? description,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  ShadButtonVariant confirmVariant = ShadButtonVariant.primary,
}) {
  return showShadDialog<bool>(
    context: context,
    title: title,
    description: description,
    actions: [
      ShadDialogAction(
        text: cancelText,
        onPressed: () => Navigator.pop(context, false),
        variant: ShadButtonVariant.outline,
      ),
      ShadDialogAction(
        text: confirmText,
        onPressed: () => Navigator.pop(context, true),
        variant: confirmVariant,
      ),
    ],
  );
}

/// Show a destructive confirmation dialog (for delete actions)
Future<bool?> showShadDestructiveDialog({
  required BuildContext context,
  required String title,
  String? description,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
}) {
  return showShadConfirmDialog(
    context: context,
    title: title,
    description: description,
    confirmText: confirmText,
    cancelText: cancelText,
    confirmVariant: ShadButtonVariant.destructive,
  );
}

/// Show an alert dialog (single OK button)
Future<void> showShadAlertDialog({
  required BuildContext context,
  required String title,
  String? description,
  Widget? content,
  String okText = 'OK',
}) {
  return showShadDialog(
    context: context,
    title: title,
    description: description,
    content: content,
    actions: [
      ShadDialogAction(
        text: okText,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}
