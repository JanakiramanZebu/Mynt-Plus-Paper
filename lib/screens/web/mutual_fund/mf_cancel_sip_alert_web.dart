// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/common_text_fields_web.dart';

class MfSipCancelalertWeb extends ConsumerStatefulWidget {
  final String mfcancels;
  final String message;
  final String mforderno;
  final String mffreqtype;
  final String mfnextsipdate;
  final String mfscode;

  const MfSipCancelalertWeb({
    super.key,
    required this.mfcancels,
    required this.mforderno,
    required this.message,
    required this.mffreqtype,
    required this.mfnextsipdate,
    required this.mfscode,
  });

  @override
  ConsumerState<MfSipCancelalertWeb> createState() =>
      _MfSipCancelalertWebState();
}

class _MfSipCancelalertWebState extends ConsumerState<MfSipCancelalertWeb> {
  /// Safely parse max installments with error handling
  String _getMaxInstallments(MFProvider mfData) {
    try {
      final maxInstallments =
          mfData.mfSIPModel?.data?.first.pAUSEMAXIMUMINSTALLMENTS;
      if (maxInstallments == null || maxInstallments.isEmpty) {
        return "0";
      }
      return double.parse(maxInstallments).toStringAsFixed(0);
    } catch (e) {
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    final schemeName =
        widget.mfcancels.isNotEmpty ? widget.mfcancels : "this mutual fund";
    final orderNo = widget.mforderno.isNotEmpty ? widget.mforderno : "";
    final freqType = widget.mffreqtype.isNotEmpty ? widget.mffreqtype : "";
    final nextSipDate =
        widget.mfnextsipdate.isNotEmpty ? widget.mfnextsipdate : "";
    final scode = widget.mfscode.isNotEmpty ? widget.mfscode : "";
    final isPause = widget.message == 'pause';

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: resolveThemeColor(context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          border: Border.all(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, theme, mfData, isPause),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Confirmation message
                    Center(
                      child: Text(
                        "Are you sure you want to ${isPause ? "Pause" : "Cancel"} the ($schemeName) SIP order",
                        textAlign: TextAlign.center,
                        style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.medium,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Cancel reason dropdown
                    if (widget.message == 'sip') ...[
                      Text(
                        "Cancel Reason",
                         style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.semiBold,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary)),
                      ),
                      const SizedBox(height: 10),
                      _buildReasonDropdown(context, mfData),
                    ],

                    // Pause installments field
                    if (isPause) ...[
                      Text(
                        "No of installments to pause (Range: 1-${_getMaxInstallments(mfData)})",
                        style: MyntWebTextStyles.body(
                          context,
                          fontWeight: MyntFonts.medium,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyntFormTextField(
                        controller: mfData.pausesip,
                        placeholder: 'Enter number',
                        height: 40,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textStyle: MyntWebTextStyles.title(
                          context,
                          fontWeight: MyntFonts.medium,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                        ),
                        onChanged: (value) {
                          mfData.installmentDuration(value, context);
                        },
                      ),
                      if (mfData.inpauseerror.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          mfData.inpauseerror,
                          style: MyntWebTextStyles.para(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Footer button
            _buildFooter(context, theme, mfData, isPause, orderNo, freqType,
                nextSipDate, scode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme,
      MFProvider mfData, bool isPause) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isPause ? 'SIP Pause' : 'SIP Cancel',
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              mfData.cleartext();
              mfData.rejectsip.text = "";
              mfData.pausesip.text = "";
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              size: 20,
              color: resolveThemeColor(context,
                  dark: MyntColors.iconSecondaryDark,
                  light: MyntColors.iconSecondary),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  /// Get the selected reason name for display
  String _getSelectedReasonName(MFProvider mfData) {
    if (mfData.droupreason.isEmpty ||
        mfData.mfrejectsiplist == null ||
        mfData.mfrejectsiplist!.isEmpty) {
      return '';
    }
    final match = mfData.mfrejectsiplist!
        .cast<Map<String, dynamic>>()
        .where((item) => item["id"] == mfData.droupreason);
    if (match.isNotEmpty) {
      return match.first["reason_name"] as String? ?? '';
    }
    return '';
  }

  void _showReasonPopover(BuildContext btnContext, MFProvider mfData) {
    final btnWidth = (btnContext.findRenderObject() as RenderBox).size.width;
    final hasReasonList =
        mfData.mfrejectsiplist != null && mfData.mfrejectsiplist!.isNotEmpty;
    if (!hasReasonList) return;

    shadcn.showPopover(
      context: btnContext,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 4),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(btnContext).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(popoverContext).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: btnWidth - 8,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mfData.mfrejectsiplist!.length,
                  itemBuilder: (context, index) {
                    final item = mfData.mfrejectsiplist![index];
                    final isSelected = item["id"] == mfData.droupreason;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          shadcn.closeOverlay(popoverContext);
                          mfData.orderrejectupdate(item["id"] as String? ?? '');
                          setState(() {});
                        },
                        splashColor: resolveThemeColor(context,
                            dark: MyntColors.rippleDark,
                            light: MyntColors.rippleLight),
                        highlightColor: resolveThemeColor(context,
                            dark: MyntColors.highlightDark,
                            light: MyntColors.highlightLight),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? resolveThemeColor(context,
                                    dark: MyntColors.primary
                                        .withValues(alpha: 0.1),
                                    light: MyntColors.primary
                                        .withValues(alpha: 0.06))
                                : null,
                          ),
                          child: Text(
                            item["reason_name"] as String? ?? "",
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: isSelected
                                  ? MyntFonts.semiBold
                                  : MyntFonts.medium,
                              color: isSelected
                                  ? resolveThemeColor(context,
                                      dark: MyntColors.primaryDark,
                                      light: MyntColors.primary)
                                  : resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReasonDropdown(BuildContext context, MFProvider mfData) {
    final hasReasonList =
        mfData.mfrejectsiplist != null && mfData.mfrejectsiplist!.isNotEmpty;
    final selectedName = _getSelectedReasonName(mfData);
    final hasSelection = selectedName.isNotEmpty;

    return Column(
      children: [
        Builder(
          builder: (btnContext) {
            return InkWell(
              onTap: hasReasonList
                  ? () => _showReasonPopover(btnContext, mfData)
                  : null,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.outlinedBorder),
                  ),
                  color: resolveThemeColor(context,
                      dark: MyntColors.inputBgDark,
                      light: const Color(0xfff5f5f5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasSelection ? selectedName : 'Select reason',
                        style: MyntWebTextStyles.body(
                          context,
                          fontWeight: MyntFonts.medium,
                          color: hasSelection
                              ? resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary)
                              : resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (mfData.droupreason == "13") ...[
          const SizedBox(height: 10),
          MyntFormTextField(
            controller: mfData.rejectsip,
            placeholder: 'Specify The Reason',
            height: 40,
            textStyle: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.medium,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfData,
    bool isPause,
    String orderNo,
    String freqType,
    String nextSipDate,
    String scode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: (isPause &&
                  mfData.inpauseerror.isNotEmpty &&
                  mfData.inpauseerror != "")
              ? null
              : () async {
                  try {
                    if (isPause) {
                      await mfData.pausesiporder(
                          context, orderNo, freqType, nextSipDate, scode);
                    } else {
                      await mfData.cancelsiporder(context, orderNo, scode);
                    }
                  } catch (e) {
                    // Handle error silently
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                theme.isDarkMode ? MyntColors.secondary : MyntColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
          ),
          child: mfData.loading == true
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Cancel',
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: MyntColors.backgroundColor,
                  ),
                ),
        ),
      ),
    );
  }
}
