import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';

import '../../models/profile_model/algo_strategy_model.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/cust_text_formfield.dart';

class CreateAlgoStrategyScreen extends ConsumerStatefulWidget {
  final AlgoStrategyModel? strategyToEdit;

  const CreateAlgoStrategyScreen({super.key, this.strategyToEdit});

  @override
  ConsumerState<CreateAlgoStrategyScreen> createState() =>
      _CreateAlgoStrategyScreenState();
}

class _CreateAlgoStrategyScreenState
    extends ConsumerState<CreateAlgoStrategyScreen> {
  @override
  void initState() {
    super.initState();
    // Clear form when screen is first opened to ensure fresh start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.strategyToEdit != null) {
        ref
            .read(userProfileProvider)
            .populateFormForEdit(widget.strategyToEdit!);
      } else {
        ref.read(userProfileProvider).clearForm();
      }
    });
  }

  @override
  void dispose() {
    // Don't clear form in dispose as it causes ref issues
    // Form will be cleared when screen is opened fresh
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final provider = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        centerTitle: false,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: theme.isDarkMode
                ? colors.splashColorDark
                : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ),
          ),
        ),
        elevation: 0.2,
        title: Row(
          children: [
            Expanded(
              child: TextWidget.titleText(
                text: widget.strategyToEdit != null
                    ? widget.strategyToEdit!.algorithmName
                    : "Create Algo Strategy",
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.strategyToEdit != null) ...[
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _showDeleteConfirmation(context, theme),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [                     
                        TextWidget.subText(
                          text: 'Delete',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.lossDark
                              : colors.lossLight,
                          fw: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SafeArea(
        child: Form(
          key: provider.formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Algorithm Name
                _buildTextField(
                  controller: provider.algorithmNameController,
                  label: "Algorithm Name",
                  hintText: "e.g., EMA Crossover Strategy",
                  isRequired: true,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Algorithm Type
                _buildDropdownField(
                  label: "Algorithm Type",
                  hintText: "Select algorithm type",
                  value: provider.selectedAlgorithmType,
                  items: provider.algorithmTypes,
                  onChanged: provider.setAlgorithmType,
                  isRequired: true,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Category
                _buildDropdownField(
                  label: "Category",
                  hintText: "Select category",
                  value: provider.selectedCategory,
                  items: provider.categories,
                  onChanged: provider.setCategory,
                  isRequired: true,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Risk Level
                _buildRadioField(
                  label: "Risk Level",
                  value: provider.selectedRiskLevel,
                  items: provider.riskLevels,
                  onChanged: provider.setRiskLevel,
                  isRequired: true,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Algorithm Description
                _buildTextField(
                  controller: provider.descriptionController,
                  label: "Algorithm Description",
                  hintText:
                      "Describe your algorithm, its purpose, and target market conditions.",
                  isRequired: true,
                  maxLines: 4,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Strategy Logic
                _buildTextField(
                  controller: provider.strategyLogicController,
                  label: "Strategy Logic",
                  hintText:
                      "Explain the trading logic, entry/exit conditions, and risk management rules.",
                  isRequired: true,
                  maxLines: 4,
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // File Upload
                _buildFileUploadField(
                  label: "Upload Code",
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 16),

                // Terms and Conditions
                _buildTermsCheckbox(
                  theme: theme.isDarkMode,
                  provider: provider,
                ),

                const SizedBox(height: 32),

                // Submit/Update Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.strategyToEdit != null) {
                        // Update mode
                        final success = await provider.updateForm(
                          context,
                          widget.strategyToEdit!.submissionId,
                          widget.strategyToEdit!.algoId,
                        );
                        if (success) {
                          Navigator.pop(context);
                        }
                      } else {
                        // Create mode
                        final success = await provider.submitForm(context);
                        if (success) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      foregroundColor: Colors.white,
                      // padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: TextWidget.subText(
                      text: widget.strategyToEdit != null
                          ? "Update Strategy"
                          : "Create Strategy",
                      theme: false,
                      color: Colors.white,
                      fw: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isRequired,
    required bool theme,
    required UserProfileProvider provider,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme,
          color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          textCtrl: controller,
          hintText: hintText,
          textAlign: TextAlign.start,
          maxLines: maxLines,
          fillColor: theme ? colors.searchBgDark : colors.searchBg,
          hintStyle: TextWidget.textStyle(
            fontSize: 14,
            theme: theme,
            color: theme ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: theme,
            color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 0,
          ),
          errorStyle: TextWidget.textStyle(
            fontSize: 10,
            theme: theme,
            color: theme ? colors.lossDark : colors.lossLight,
            fw: 0,
          ),
          validator: (value) => provider.validateField(label, value),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isRequired,
    required bool theme,
    required UserProfileProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme,
          color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showBottomSheet(label, items, onChanged, theme),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: theme ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: colors.colorBlue),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextWidget.subText(
                    text: value ?? hintText,
                    theme: theme,
                    color: value != null
                        ? (theme
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight)
                        : (theme
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight),
                    fw: 0,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: theme
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isRequired && value == null && provider.hasAttemptedSubmit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextWidget.captionText(
              text: label == 'Algorithm Type'
                  ? 'Algorithm type is required'
                  : label == 'Category'
                      ? 'Category is required'
                      : 'This field is required',
              theme: theme,
              color: theme ? colors.lossDark : colors.lossLight,
              fw: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildRadioField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isRequired,
    required bool theme,
    required UserProfileProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme,
          color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        Row(
          children: items.map((String item) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(item),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: item,
                      groupValue: value,
                      onChanged: onChanged,
                      activeColor: colors.colorBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    // const SizedBox(width: 4),
                    TextWidget.subText(
                      text: item,
                      theme: theme,
                      color: theme
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (isRequired && value == null && provider.hasAttemptedSubmit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextWidget.captionText(
              text: 'Risk level is required',
              theme: theme,
              color: theme ? colors.lossDark : colors.lossLight,
              fw: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required bool theme,
    required UserProfileProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme,
          color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => provider.selectFile(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: colors.colorBlue),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: theme
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                TextWidget.subText(
                  text: widget.strategyToEdit != null
                      ? "Update File"
                      : "Upload File",
                  theme: theme,
                  color: theme
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 1,
                ),
                const Spacer(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextWidget.subText(
                        text: provider.selectedFileName ?? "No file chosen",
                        theme: theme,
                        color: provider.selectedFileName != null
                            ? (theme
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight)
                            : (theme
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight),
                        fw: 0,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      if (provider.selectedFile != null)
                        TextWidget.captionText(
                          text: provider
                              .formatFileSize(provider.selectedFile!.size),
                          theme: theme,
                          color: theme
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextWidget.captionText(
          text:
              "Accepted formats: .py (Python), .pine (Pine Script), .js, .json (API config)",
          theme: theme,
          color: theme ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        if (provider.hasAttemptedSubmit &&
            provider.selectedFile == null &&
            !provider.isEditMode)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextWidget.captionText(
              text: 'File upload is required',
              theme: theme,
              color: theme ? colors.lossDark : colors.lossLight,
              fw: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildTermsCheckbox({
    required bool theme,
    required UserProfileProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: provider.acceptTerms,
              onChanged: (bool? value) =>
                  provider.setAcceptTerms(value ?? false),
              activeColor: colors.colorBlue,
            ),
            Expanded(
              child: TextWidget.subText(
                text: "I acknowledge and accept the terms and conditions",
                theme: theme,
                color: theme ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: TextWidget.captionText(
            text:
                "By submitting this algorithm, you agree to the AlgoPilot Terms of Service and NSE compliance requirements.",
            theme: theme,
            color: theme ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
        ),
        if (provider.hasAttemptedSubmit && !provider.acceptTerms)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 40),
            child: TextWidget.captionText(
              text: 'You must accept the terms and conditions',
              theme: theme,
              color: theme ? colors.lossDark : colors.lossLight,
              fw: 0,
            ),
          ),
      ],
    );
  }

  void _showBottomSheet(String title, List<String> items,
      Function(String?) onChanged, bool theme) {
    String? currentValue;
    if (title == "Algorithm Type") {
      currentValue = ref.read(userProfileProvider).selectedAlgorithmType;
    } else if (title == "Category") {
      currentValue = ref.read(userProfileProvider).selectedCategory;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme ? colors.colorBlack : colors.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: theme ? colors.colorBlack : colors.colorWhite,
            border: Border(
              top: BorderSide(
                color: theme
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              left: BorderSide(
                color: theme
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              right: BorderSide(
                color: theme
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: title,
                      theme: theme,
                      color: theme
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 150));
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: theme
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.15),
                        highlightColor: theme
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: theme
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: theme ? colors.darkColorDivider : colors.colorDivider,
                height: 0,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: items.map((String item) {
                        return RadioListTile<String>(
                          title: TextWidget.subText(
                            text: item,
                            theme: theme,
                            color: theme
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                          ),
                          value: item,
                          groupValue: currentValue,
                          onChanged: (String? value) {
                            onChanged(value);
                            Navigator.pop(context);
                          },
                          activeColor: colors.colorBlue,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, theme) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F8),
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          actionsPadding: const EdgeInsets.only(
              bottom: 16, right: 16, left: 16, top: 8),
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 30, vertical: 12),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(
                            const Duration(milliseconds: 150));
                        Navigator.of(context).pop(false);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
             
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    "Are you sure you want to delete \"${widget.strategyToEdit!.algorithmName}\"? This action cannot be undone.",
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 45), // width, height
                  side: BorderSide(
                      color: colors
                          .btnOutlinedBorder), // Outline border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor:
                      colors.primaryDark, // Transparent background
                ),
                child: Text(
                  "Delete",
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    color: colors.colorWhite,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    
    // Only proceed with deletion if user confirmed (result == true)
    if (result == true) {
      final success = await ref.read(userProfileProvider).deleteAlgoStrategy(
        context,
        widget.strategyToEdit!.submissionId,
        widget.strategyToEdit!.algoId,
      );
      if (success) {
        Navigator.of(context).pop(); // Go back to list only if delete was successful
      }
    }
  }
}
