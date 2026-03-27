import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/common_text_fields_web.dart';

class CreateMandateDialogue extends ConsumerStatefulWidget {
  const CreateMandateDialogue({super.key});

  @override
  ConsumerState<CreateMandateDialogue> createState() =>
      _CreateMandateDialogueState();
}

class _CreateMandateDialogueState extends ConsumerState<CreateMandateDialogue> {
  final TextEditingController _amountController = TextEditingController();
  bool _amountTouched = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).getCurrentDate();
    });
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mfOrder = ref.watch(mfProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
              _buildHeader(context, theme),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount field
                      Text(
                        'Amount',
                        style: MyntWebTextStyles.body(context,
                            fontWeight: MyntFonts.medium,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary)),
                      ),
                      const SizedBox(height: 10),
                      MyntFormTextField(
                        controller: _amountController,
                        placeholder: 'Enter amount',
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
                        leadingWidget: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            assets.ruppeIcon,
                            colorFilter: ColorFilter.mode(
                              resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      if (_amountTouched &&
                          _amountController.text.trim().isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Please enter an amount',
                          style: MyntWebTextStyles.para(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Start Date & End Date row
                      _buildDateRow(context, theme, mfOrder),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer
              _buildFooter(context, theme, mfOrder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
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
            'Create Mandate',
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
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

  Future<void> _selectStartDate(MFProvider mfOrder) async {
    try {
      final isDark = ref.read(themeProvider).isDarkMode;
      final now = DateTime.now();
      final initialDate = mfOrder.pickedStartDate ?? now;
      final primary = isDark ? MyntColors.primaryDark : MyntColors.primary;
      final bg = isDark ? MyntColors.cardDark : MyntColors.card;
      final text = isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary;

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: DateTime(now.year + 200),
        builder: (dialogContext, child) => Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme:
                (isDark ? const ColorScheme.dark() : const ColorScheme.light())
                    .copyWith(
              primary: primary,
              onPrimary: Colors.white,
              surface: bg,
              onSurface: text,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: primary,
              headerForegroundColor: Colors.white,
              dividerColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null && mounted) {
        mfOrder.changeInstallmentDate(
            picked.day, picked.month, picked.year);
        setState(() {});
      }
    } catch (e) {
      debugPrint('Date picker error: $e');
    }
  }

  Future<void> _selectEndDate(MFProvider mfOrder) async {
    try {
      final isDark = ref.read(themeProvider).isDarkMode;
      final now = DateTime.now();
      final primary = isDark ? MyntColors.primaryDark : MyntColors.primary;
      final bg = isDark ? MyntColors.cardDark : MyntColors.card;
      final text = isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary;

      final firstAllowed = now.add(const Duration(days: 3));
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: firstAllowed,
        firstDate: firstAllowed,
        lastDate: DateTime(now.year + 200),
        builder: (dialogContext, child) => Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme:
                (isDark ? const ColorScheme.dark() : const ColorScheme.light())
                    .copyWith(
              primary: primary,
              onPrimary: Colors.white,
              surface: bg,
              onSurface: text,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: primary,
              headerForegroundColor: Colors.white,
              dividerColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null && mounted) {
        mfOrder.setEndDate(picked);
        setState(() {});
      }
    } catch (e) {
      debugPrint('Date picker error: $e');
    }
  }

  Widget _buildDateRow(
      BuildContext context, ThemesProvider theme, MFProvider mfOrder) {
    final hasStartDate = mfOrder.startDate.isNotEmpty;
    final hasEndDate = mfOrder.endDate.isNotEmpty;

    return Row(
      children: [
        // Start Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date',
                style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.medium,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectStartDate(mfOrder),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                        dark: MyntColors.inputBgDark,
                        light: const Color(0xfff5f5f5)),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDarkMode(context)
                          ? MyntColors.primaryDark
                          : MyntColors.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasStartDate ? mfOrder.startDate : 'Select date',
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: MyntFonts.medium,
                            color: hasStartDate
                                ? resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary)
                                : resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // End Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End Date',
                style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.medium,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectEndDate(mfOrder),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                        dark: MyntColors.inputBgDark,
                        light: const Color(0xfff5f5f5)),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDarkMode(context)
                          ? MyntColors.primaryDark
                          : MyntColors.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasEndDate ? mfOrder.endDate : 'Select date',
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: MyntFonts.medium,
                            color: hasEndDate
                                ? resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary)
                                : resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(
      BuildContext context, ThemesProvider theme, MFProvider mfOrder) {
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
          onPressed: () async {
            if (_amountController.text.trim().isEmpty) {
              setState(() => _amountTouched = true);
              return;
            }

            int installmentAmount =
                double.parse(_amountController.text).toInt();
            if (installmentAmount >= 100) {
              await mfOrder.fetchCreateMandate(
                  context,
                  double.parse(_amountController.text)
                      .toInt()
                      .toString(),
                  mfOrder.startDate,
                  mfOrder.endDate);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.isDarkMode
                ? MyntColors.secondary
                : MyntColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
          ),
          child: mfOrder.loading == true
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Submit',
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
