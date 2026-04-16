import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../../models/trading_personality_model.dart';
import '../../../../sharedWidget/snack_bar.dart';

class SaveStrategyScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onSaved;
  final Function(String)? onError;
  final Function()? onClearError;
  final String? currentError;
  final bool isCreateFlow;
  final bool isEditMode;
  final String? editStrategyName;
  final String? editStrategyUuid;
  final VoidCallback? onBack;
  final VoidCallback? onBacktest;

  const SaveStrategyScreenWeb({
    super.key,
    this.onSaved,
    this.onError,
    this.onClearError,
    this.currentError,
    this.isCreateFlow = false,
    this.isEditMode = false,
    this.editStrategyName,
    this.editStrategyUuid,
    this.onBack,
    this.onBacktest,
  });

  @override
  ConsumerState<SaveStrategyScreenWeb> createState() => _SaveStrategyScreenWebState();
}

class _SaveStrategyScreenWebState extends ConsumerState<SaveStrategyScreenWeb> {
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _currentError = widget.currentError;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final strategy = ref.read(dashboardProvider);
      strategy.clearStrategyNameError();

      if (widget.isEditMode && widget.editStrategyName != null) {
        strategy.strategyNameController.text = widget.editStrategyName!;

        if (!strategy.isEditingMode && widget.editStrategyUuid != null) {
          final mockStrategyData = Data(
            uuid: widget.editStrategyUuid!,
            basketName: widget.editStrategyName!,
          );
          strategy.loadStrategy(mockStrategyData);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    final dark = isDarkMode(context);

    return Container(
      color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
      child: Column(
        children: [
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  widget.isEditMode ? 'Update Strategy' : 'Save Strategy',
                  style: MyntWebTextStyles.title(context, fontWeight: MyntFonts.medium,
                    darkColor: MyntColors.textPrimaryDark, lightColor: MyntColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Planet Avatar Selection
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildPlanetAvatarSelector(context, strategy),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Strategy Name Section
                  Text(
                    'Enter a name for your strategy',
                    style: MyntWebTextStyles.body(context, fontWeight: MyntFonts.regular,
                      darkColor: MyntColors.textPrimaryDark, lightColor: MyntColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: strategy.strategyNameController,
                    onChanged: (value) {
                      if (strategy.strategyNameError != null) {
                        strategy.clearStrategyNameError();
                      }
                      if (_currentError != null) {
                        setState(() {
                          _currentError = null;
                        });
                        if (widget.onClearError != null) {
                          widget.onClearError!();
                        }
                      }
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isNotEmpty) {
                          String filteredText = newValue.text.replaceAll(RegExp(r'[^\w\s\-\.]'), '');
                          String capitalizedText = filteredText.isNotEmpty
                              ? filteredText[0].toUpperCase() +
                                (filteredText.length > 1 ? filteredText.substring(1) : '')
                              : '';
                          return TextEditingValue(
                            text: capitalizedText,
                            selection: TextSelection.collapsed(offset: capitalizedText.length),
                          );
                        }
                        return newValue;
                      }),
                    ],
                    style: MyntWebTextStyles.body(context, fontWeight: MyntFonts.regular,
                      darkColor: MyntColors.textPrimaryDark, lightColor: MyntColors.textPrimary),
                    decoration: InputDecoration(
                      fillColor: dark ? colors.darkGrey : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: 'Strategy name',
                      hintStyle: MyntWebTextStyles.para(context, fontWeight: MyntFonts.regular,
                        color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary).withOpacity(0.4)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: MyntColors.primary),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: MyntColors.primary),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  // Error message below the field
                  if (strategy.strategyNameError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      strategy.strategyNameError!,
                      style: MyntWebTextStyles.para(context, fontWeight: MyntFonts.regular,
                        color: resolveThemeColor(context, dark: MyntColors.lossDark, light: MyntColors.loss)),
                    ),
                  ],
                  // Current error message (from dialog parameters)
                  if (_currentError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _currentError!,
                      style: MyntWebTextStyles.para(context, fontWeight: MyntFonts.regular,
                        color: Colors.red),
                    ),
                  ],

                ],
              ),
            ),
          ),

          // Save Button (Fixed at bottom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
              border: Border(
                top: BorderSide(
                  color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (strategy.strategyNameController.text.trim().isNotEmpty) {
                    try {
                      if (strategy.isEditingMode) {
                        await strategy.updateStrategy(context);
                      } else {
                        await ref.read(dashboardProvider).saveStrategy(
                            strategy.strategyNameController.text.trim(), context);

                        if (widget.isCreateFlow) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          if (!strategy.stratergysavebackbutton) {
                            Navigator.of(context).pop();
                            await _performBacktest(context);
                          }
                        }
                      }
                      if (widget.onSaved != null) {
                        widget.onSaved!();
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      error(context, 'Failed to save strategy. Please try again.');
                    }
                  } else {
                    if (widget.onError != null) {
                      widget.onError!('Please enter a strategy name.');
                    } else {
                      setState(() {
                        _currentError = 'Please enter a strategy name.';
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyntColors.primaryDark,
                  disabledBackgroundColor: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: MyntWebTextStyles.body(context, fontWeight: MyntFonts.semiBold,
                    color: MyntColors.textWhite),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetAvatarSelector(BuildContext context, DashboardProvider strategy) {
    final selectedPlanet = TradingPersonalities.getPersonality(strategy.selectedPersonality);

    return Column(
      children: [
        // Current Selected Planet (Large)
        GestureDetector(
          onTap: () => _showPlanetSelectionDialog(context, strategy),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  selectedPlanet.primaryColor,
                  selectedPlanet.secondaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedPlanet.primaryColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                selectedPlanet.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          selectedPlanet.name,
          style: MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textPrimaryDark, lightColor: MyntColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          selectedPlanet.description,
          style: MyntWebTextStyles.para(context, fontWeight: MyntFonts.regular,
            darkColor: MyntColors.textSecondaryDark, lightColor: MyntColors.textSecondary),
        ),
      ],
    );
  }

  void _showPlanetSelectionDialog(BuildContext context, DashboardProvider strategy) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Choose Your Planet',
                style: MyntWebTextStyles.title(context, fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textPrimaryDark, lightColor: MyntColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a planet that represents your investment strategy',
                style: MyntWebTextStyles.para(context, fontWeight: MyntFonts.regular,
                  darkColor: MyntColors.textSecondaryDark, lightColor: MyntColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Planet Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: TradingPersonalities.personalities.length,
                  itemBuilder: (context, index) {
                    final planet = TradingPersonalities.personalities[index];
                    final isSelected = planet.type == strategy.selectedPersonality;

                    return GestureDetector(
                      onTap: () {
                        strategy.updateSelectedPersonality(planet.type);
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  planet.primaryColor,
                                  planet.secondaryColor,
                                ],
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: resolveThemeColor(context,
                                        dark: MyntColors.primaryDark, light: MyntColors.primary),
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: planet.primaryColor.withOpacity(0.3),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                planet.emoji,
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            planet.name,
                            style: MyntWebTextStyles.para(context,
                              fontWeight: isSelected ? MyntFonts.medium : MyntFonts.regular,
                              color: isSelected
                                  ? resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary)
                                  : resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleSaveStrategy(DashboardProvider strategy, BuildContext context) async {
    if (strategy.strategyNameController.text.trim().isEmpty) {
      strategy.setStrategyNameError('Please enter a strategy name');
      return;
    }

    try {
      if (strategy.isEditingMode) {
        await strategy.updateStrategy(context);
        Navigator.of(context).pop();
      } else {
        await strategy.saveStrategy(strategy.strategyNameController.text.trim(), context);
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        if (!strategy.stratergysavebackbutton) {
          Navigator.of(context).pop();
          await _performBacktest(context);
        }
      }
    } catch (e) {
      // Error handling is done in the provider methods
    }
  }

  Future<void> _performBacktest(BuildContext context) async {
    final strategy = ref.read(dashboardProvider);

    try {
      strategy.backtestAnalysis(
          uuid: strategy.editingStrategy?.data?.firstOrNull?.uuid ?? '');

      widget.onBacktest?.call();
    } catch (e) {
      // Error handling
    }
  }
}
