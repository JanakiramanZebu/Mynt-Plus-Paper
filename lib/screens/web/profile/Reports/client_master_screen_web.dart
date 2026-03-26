import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';

class ClientMasterScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const ClientMasterScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<ClientMasterScreenWeb> createState() =>
      _ClientMasterScreenWebState();
}

class _ClientMasterScreenWebState extends ConsumerState<ClientMasterScreenWeb> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final ledgerProv = ref.watch(ledgerProvider);

    return Column(
      children: [
        // Header with back button and title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CustomBackBtn(onBack: widget.onBack),
              const SizedBox(width: 8),
              Text(
                'Client Master (CMR)',
                style: MyntWebTextStyles.title(context,
                    fontWeight: MyntFonts.semiBold),
              ),
            ],
          ),
        ),
        // Divider(
        //   height: 1,
        //   color: resolveThemeColor(
        //     context,
        //     dark: Colors.white.withValues(alpha: 0.06),
        //     light: Colors.black.withValues(alpha: 0.06),
        //   ),
        // ),

        // Content
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: () {
                    ledgerProv.fetchcmrdownload(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? resolveThemeColor(
                              context,
                              dark: Colors.white.withValues(alpha: 0.04),
                              light: Colors.black.withValues(alpha: 0.02),
                            )
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(
                      //   color: resolveThemeColor(
                      //     context,
                      //     dark: Colors.white.withValues(alpha: 0.08),
                      //     light: Colors.black.withValues(alpha: 0.08),
                      //   ),
                      // ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          assets.pdfIcon,
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download,
                              size: 18,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Download PDF',
                              style: MyntWebTextStyles.body(context,
                                  fontWeight: MyntFonts.medium),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
