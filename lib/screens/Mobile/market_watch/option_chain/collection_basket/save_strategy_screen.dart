import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';

import '../../../../../models/trading_personality_model.dart';
import '../../../../../sharedWidget/snack_bar.dart';

class SaveStrategyScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSaved;
  final Function(String)? onError;
  final Function()? onClearError;
  final String? currentError;
  final bool isCreateFlow; // New parameter to distinguish create vs analyse flow
  final bool isEditMode; // New parameter for edit mode
  final String? editStrategyName; // Strategy name for editing
  final String? editStrategyUuid; // Strategy UUID for editing
  
  const SaveStrategyScreen({
    super.key,
    this.onSaved,
    this.onError,
    this.onClearError,
    this.currentError,
    this.isCreateFlow = false,
    this.isEditMode = false,
    this.editStrategyName,
    this.editStrategyUuid,
  });

  @override
  ConsumerState<SaveStrategyScreen> createState() => _SaveStrategyScreenState();
}

class _SaveStrategyScreenState extends ConsumerState<SaveStrategyScreen> {
  String? _currentError;

  @override
  void initState() {
    super.initState();
    // Initialize current error from widget parameter
    _currentError = widget.currentError;
    
    // Handle edit mode - pre-populate strategy name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final strategy = ref.read(dashboardProvider);
      strategy.clearStrategyNameError();
      
      if (widget.isEditMode && widget.editStrategyName != null) {
        strategy.strategyNameController.text = widget.editStrategyName!;
        
        // If we're in edit mode but don't have an editing strategy set,
        // we need to create a mock strategy data for the update to work
        if (!strategy.isEditingMode && widget.editStrategyUuid != null) {
          // Create a mock strategy data for editing
          final mockStrategyData = Data(
            uuid: widget.editStrategyUuid!,
            basketName: widget.editStrategyName!,
            // Add other required fields as needed
          );
          strategy.loadStrategy(mockStrategyData);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        elevation: 0,
        leading: const CustomBackBtn(),
        title: TextWidget.titleText(
          text: widget.isEditMode ? 'Update Strategy' : 'Save Strategy',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          _buildPlanetAvatarSelector(strategy, theme),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // Strategy Name Section
                    TextWidget.subText(
                      text: 'Enter a name for your strategy',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: strategy.strategyNameController,
                      onChanged: (value) {
                        // Clear error when user starts typing
                        if (strategy.strategyNameError != null) {
                          strategy.clearStrategyNameError();
                        }
                        // Clear current error and call onClearError if provided
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
                            // Remove emojis and special characters, keep only letters, numbers, spaces, and basic punctuation
                            String filteredText = newValue.text.replaceAll(RegExp(r'[^\w\s\-\.]'), '');
                            
                            // Capitalize the first letter
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
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0,
                      ),
                      decoration: InputDecoration(
                        fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                        filled: true,
                        hintText: 'Strategy name',
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: theme.isDarkMode,
                          color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                          fw: 0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colors.colorBlue
                          ),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colors.colorBlue
                          ),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(5)
                        ),
                      ),
                    ),
                    
                    // Error message below the field
                    if (strategy.strategyNameError != null) ...[
                      const SizedBox(height: 8),
                      TextWidget.paraText(
                        text: strategy.strategyNameError!,
                        theme: theme.isDarkMode,
                        color: colors.lossLight,
                        fw: 0,
                      ),
                    ],
                    // Current error message (from dialog parameters)
                    if (_currentError != null) ...[
                      const SizedBox(height: 8),
                      TextWidget.paraText(
                        text: _currentError!,
                        theme: theme.isDarkMode,
                        color: Colors.red,
                        fw: 0,
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
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                border: Border(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.1)
                        : colors.textSecondaryLight.withOpacity(0.1),
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
                      // Update the strategy with the new name
                      await strategy.updateStrategy(context);
                    } else {
                      await ref.read(dashboardProvider).saveStrategy(
                          strategy.strategyNameController.text.trim(), context);
                      
                      if (widget.isCreateFlow) {
                        // For create flow: pop back to saved strategies list
                        Navigator.of(context).pop(); // Close save strategy screen
                        Navigator.of(context).pop(); // Close create strategy screen
                      } else {
                        // For analyse flow: continue with existing logic
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                       if(!strategy.stratergysavebackbutton){
                        Navigator.of(context).pop();
                        await _performBacktest(context);
                       }
                      }
                    }
                    // _showSuccessDialog();
                    // Call onSaved callback if provided
                    if (widget.onSaved != null) {
                      widget.onSaved!();
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    error(
                        context, 'Failed to save strategy. Please try again.');
                  }
                } else {
                  // Show error message below the field for empty strategy name
                  if (widget.onError != null) {
                    widget.onError!('Please enter a strategy name.');
                  } else {
                    // Fallback to setting local error state
                    setState(() {
                      _currentError = 'Please enter a strategy name.';
                    });
                  }
                }
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryDark,
                    disabledBackgroundColor: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.3)
                        : colors.textSecondaryLight.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: TextWidget.subText(
                    text: "Save",
                    theme: theme.isDarkMode,
                    color: colors.colorWhite,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetAvatarSelector(DashboardProvider strategy, ThemesProvider theme) {
    final selectedPlanet = TradingPersonalities.getPersonality(strategy.selectedPersonality);
    
    return Column(
      children: [
        // Current Selected Planet (Large)
        GestureDetector(
          onTap: () => _showPlanetSelectionModal(context, strategy, theme),
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
        TextWidget.subText(
          text: selectedPlanet.name,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 4),
        TextWidget.paraText(
          text: selectedPlanet.description,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
       
      ],
    );
  }



  void _showPlanetSelectionModal(BuildContext context, DashboardProvider strategy, ThemesProvider theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.isDarkMode 
                    ? colors.textSecondaryDark.withOpacity(0.3)
                    : colors.textSecondaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            TextWidget.titleText(
              text: 'Choose Your Planet',
              theme: theme.isDarkMode,
              color: theme.isDarkMode 
                  ? colors.textPrimaryDark 
                  : colors.textPrimaryLight,
              fw: 1,
            ),
            const SizedBox(height: 8),
            TextWidget.paraText(
              text: 'Select a planet that represents your investment strategy',
              theme: theme.isDarkMode,
              color: theme.isDarkMode 
                  ? colors.textSecondaryDark 
                  : colors.textSecondaryLight,
              fw: 0,
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
                      Navigator.pop(context);
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
                                    color: theme.isDarkMode 
                                        ? colors.primaryDark 
                                        : colors.primaryLight,
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
                        TextWidget.paraText(
                          text: planet.name,
                          theme: theme.isDarkMode,
                          color: isSelected
                              ? (theme.isDarkMode 
                                  ? colors.primaryDark 
                                  : colors.primaryLight)
                              : (theme.isDarkMode 
                                  ? colors.textSecondaryDark 
                                  : colors.textSecondaryLight),
                          fw: isSelected ? 1 : 0,
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
    );
  }

  void handleSaveStrategy(DashboardProvider strategy, BuildContext context) async {
    if (strategy.strategyNameController.text.trim().isEmpty) {
      strategy.setStrategyNameError('Please enter a strategy name');
      return;
    }

    try {
      if (strategy.isEditingMode) {
        // Update existing strategy
        await strategy.updateStrategy(context);
        Navigator.of(context).pop();
      } else {
        // Save new strategy
        await strategy.saveStrategy(strategy.strategyNameController.text.trim(), context);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        
        // Navigate to backtest if not coming from back button
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
      // Handle backtest
      strategy.backtestAnalysis(
          uuid: strategy.editingStrategy?.data?.first.uuid ?? '');

      // Navigate to backtest screen
      Navigator.pushNamed(context, Routes.benchmarkBacktestAnalysis);
    } catch (e) {
      // Error handling
    }
  }

}
