import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/common_buttons_web.dart';
import '../../../../sharedWidget/common_text_fields_web.dart';

class CreateGroupPos extends ConsumerStatefulWidget {
  const CreateGroupPos({super.key});

  @override
  ConsumerState<CreateGroupPos> createState() => _CreateGroupPosState();
}

class _CreateGroupPosState extends ConsumerState<CreateGroupPos> {
  TextEditingController textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? errorText;

  @override
  void initState() {
    super.initState();
    // Request focus after dialog animation completes (web autofocus fix)
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (textCtrl.text.trim().isEmpty) {
      setState(() {
        errorText = "Please enter group name";
      });
    } else {
      final groupName = textCtrl.text;
      final portfolioProv = ref.read(portfolioProvider);

      try {

        // Close dialog first (like watchlist pattern)
        Navigator.of(context).pop();

        // Then call create function
        await portfolioProv.fetchGroupName(groupName, context, true);

      } catch (e, stackTrace) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Center(
          child: shadcn.Card(
            borderRadius: BorderRadius.circular(8),
            padding: EdgeInsets.zero,
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: shadcn.Theme.of(context).colorScheme.border,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create Group',
                          style: MyntWebTextStyles.title(
                            context,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary,
                            ),
                          ),
                        ),
                        MyntCloseButton(
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyntFormTextField(
                            controller: textCtrl,
                            focusNode: _focusNode,
                            placeholder: 'Enter group name',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9 ]'),
                              ),
                              // Capitalize first letter formatter
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }
                                // Capitalize first letter
                                final firstChar =
                                    newValue.text[0].toUpperCase();
                                final restOfText = newValue.text.length > 1
                                    ? newValue.text.substring(1)
                                    : '';
                                final capitalizedText = firstChar + restOfText;

                                return TextEditingValue(
                                  text: capitalizedText,
                                  selection: TextSelection.collapsed(
                                    offset: newValue.selection.baseOffset,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                if (textCtrl.text.trim().isNotEmpty) {
                                  errorText = null;
                                } else {
                                  errorText = "Please enter group name";
                                }
                              });
                            },
                          ),
                          if (errorText != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              errorText!,
                              style: MyntWebTextStyles.para(
                                context,
                                color: resolveThemeColor(
                                  context,
                                  dark: MyntColors.lossDark,
                                  light: MyntColors.loss,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          MyntPrimaryButton(
                            size: MyntButtonSize.large,
                            label: 'Create',
                            isFullWidth: true,
                            onPressed: _handleCreate,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
