import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/api_key_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../sharedWidget/cust_text_formfield.dart';

class ApiKeyScreenNew extends ConsumerStatefulWidget {
  const ApiKeyScreenNew({super.key});

  @override
  ConsumerState<ApiKeyScreenNew> createState() => _ApiKeyScreenNewState();
}

class _ApiKeyScreenNewState extends ConsumerState<ApiKeyScreenNew> {
  // Error state variables like margin_calculator.dart
  String? _errorMessageUrl;
  String? _errorMessagePrimaryIp;
  String? _errorMessageBackupIp;

  @override
  void initState() {
    super.initState();
    _loadApiKeyData();
  }

  void _loadApiKeyData() async {
    await ref.read(apikeyprovider).fetchgenerateapikeynew(context);
  }

  void _toggleSecretVisibility() {
    ref.read(apikeyprovider).toggleSecretVisibility();
  }

  // Validation helper functions
  void _validateUrl(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _errorMessageUrl = "Redirect URL is required";
      });
    } else {
      // URL format validation
      final uri = Uri.tryParse(value);
      if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
        setState(() {
          _errorMessageUrl = "Please enter a valid URL";
        });
      } else {
        setState(() {
          _errorMessageUrl = null; // Clear error if valid
        });
      }
    }
  }

  void _validatePrimaryIp(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _errorMessagePrimaryIp = "Primary IP is required";
      });
    } else {
      // IP address format validation
      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipRegex.hasMatch(value.trim())) {
        setState(() {
          _errorMessagePrimaryIp = "Please enter a valid IP address";
        });
      } else {
        setState(() {
          _errorMessagePrimaryIp = null; // Clear error if valid
        });
      }
    }
  }

  void _validateBackupIp(String value) {
    // Backup IP is optional but must be valid format if provided
    if (value.trim().isNotEmpty) {
      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      if (!ipRegex.hasMatch(value.trim())) {
        setState(() {
          _errorMessageBackupIp = "Please enter a valid IP address";
        });
      } else {
        setState(() {
          _errorMessageBackupIp = null; // Clear error if valid
        });
      }
    } else {
      setState(() {
        _errorMessageBackupIp = null; // Clear error if empty (optional field)
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show message before closing bottom sheet using project's successMessage
    successMessage(context, "Copied to clipboard");
    // Close bottom sheet after a short delay
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.pop(context);
    });
  }

  void _showRegenerateConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = ref.read(themeProvider);
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
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
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
             
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWidget.subText(
                text: "Are you sure you want to regenerate the secret code? This will generate a new secret code and the old one will no longer work.",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 3,
                align: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(apikeyprovider).generateNewSecretCode();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: TextWidget.subText(
                  text: "Regenerate",
                  theme: false,
                  color: colors.colorWhite,
                  fw: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    final provider = ref.read(apikeyprovider);

    // Validate all fields using the helper functions
    _validateUrl(provider.urlController.text);
    _validatePrimaryIp(provider.primaryIpController.text);
    _validateBackupIp(provider.backupIpController.text);

    // Check if there are any errors
    bool hasErrors = _errorMessageUrl != null || 
                     _errorMessagePrimaryIp != null || 
                     _errorMessageBackupIp != null;

    // Return early if there are validation errors
    if (hasErrors) {
      return;
    }

    final apiData = provider.generateApikeyNew;
      if (apiData == null) {
      error(context, "API data not available. Please refresh and try again.");
        return;
      }

      final ipAddresses = <String>[];
    if (provider.primaryIpController.text.isNotEmpty) {
      ipAddresses.add(provider.primaryIpController.text);
      }
    if (provider.backupIpController.text.isNotEmpty) {
      ipAddresses.add(provider.backupIpController.text);
      }

    final userIds = apiData.userIds.isNotEmpty
        ? apiData.userIds.map((e) => e.userId).toList()
        : [apiData.appKey]; // Use app key as default user ID for new API keys

    final result = await provider.submitApiKeyNew(
        appKey: apiData.appKey,
      secretCode: provider.generatedSecretCode ??
          (apiData.stat == "Ok" ? apiData.secretCode : ""),
      redirectUrl: provider.urlController.text,
        displayName: apiData.displayName,
        ipAddresses: ipAddresses,
        userIds: userIds,
      );

      if (result?.stat == "Ok") {
        successMessage(context, "API Key updated successfully");
        Navigator.pop(context);
      } else {
        error(context, result?.emsg ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final apiData = ref.watch(apikeyprovider).generateApikeyNew;
    final provider = ref.watch(apikeyprovider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              border: Border(
                top: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                left: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                right: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
              ),
            ),
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client ID Section - Always show if we have API data
                        if (apiData != null) ...[
                          Row(
                            children: [
                              TextWidget.subText(
                                text: 'Client Id :',
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 1,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: TextWidget.titleText(
                                        text: "${apiData.appKey}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => _copyToClipboard(apiData.appKey),
                                        child: Container(
                                          height: 28,
                                          width: 28,
                                          child: Center(
                                            child: Icon(
                                              Icons.copy,
                                              size: 16,
                                              color: theme.isDarkMode 
                                                  ? colors.textSecondaryDark 
                                                  : colors.textSecondaryLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
      
                        // Form Fields (always visible but disabled when no API data)
                        // Redirect URL Label
                        TextWidget.subText(
                          text: 'Redirect URL',
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        const SizedBox(height: 8),
                        // URL Input Field (project-styled)
                        CustomTextFormField(
                          textCtrl: provider.urlController,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.url,
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          hintText: 'URL',
                          hintStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 0,
                          ),
                          style: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                          ),
                          onChanged: (value) {
                            _validateUrl(value);
                          },
                        ),
                        // Custom error message display like margin_calculator.dart
                        if (_errorMessageUrl != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextWidget.captionText(
                              text: _errorMessageUrl!,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.lossDark
                                  : colors.lossLight,
                              fw: 0,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
      
                        // IP Address Fields
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                    text: 'Primary IP Address',
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomTextFormField(
                                    textCtrl: provider.primaryIpController,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    hintText: 'Primary IP Address',
                                    fillColor: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffF1F3F8),
                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 0,
                                    ),
                                    style: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 0,
                                    ),
                                    inputFormate: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]')),
                                    ],
                                    onChanged: (value) {
                                      _validatePrimaryIp(value);
                                    },
                                  ),
                                  // Custom error message display for Primary IP
                                  if (_errorMessagePrimaryIp != null) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextWidget.captionText(
                                        text: _errorMessagePrimaryIp!,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.lossDark
                                            : colors.lossLight,
                                        fw: 0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                    text: 'Backup IP Address',
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomTextFormField(
                                    textCtrl: provider.backupIpController,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.number,
                                    hintText: 'Backup IP Address',
                                    fillColor: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffF1F3F8),
                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 0,
                                    ),
                                    style: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 0,
                                    ),
                                    errorStyle: TextWidget.textStyle(
                                      fontSize: 12,
                                      theme: theme.isDarkMode,
                                      color: Colors.red,
                                      fw: 0,
                                    ),
                                    onChanged: (value) {
                                      _validateBackupIp(value);
                                    },
                                  ),
                                  // Custom error message display for Backup IP
                                  if (_errorMessageBackupIp != null) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextWidget.captionText(
                                        text: _errorMessageBackupIp!,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.lossDark
                                            : colors.lossLight,
                                        fw: 0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
      
                        if (apiData != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            TextWidget.subText(
                              text: 'Secret Code',
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 1,
                              ),
                              // Regenerate button (only show for existing data)
                              if (apiData.stat == "Ok")
                                Material(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      _showRegenerateConfirmation();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: TextWidget.paraText(
                                        text: 'Regenerate',
                                        theme: false,
                                        color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                                        fw: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: colors.primaryLight,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextWidget.paraText(
                                      text: provider.hideSecret
                                          ? "•" *
                                              ((provider.generatedSecretCode
                                                              ?.length ??
                                                          0) >
                                                      0
                                                  ? provider
                                                      .generatedSecretCode!.length
                                                  : (apiData.stat == "Ok"
                                                      ? apiData.secretCode.length
                                                      : 0))
                                          : (provider.generatedSecretCode ??
                                              (apiData.stat == "Ok"
                                                  ? apiData.secretCode
                                                  : "")),
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        textOverflow: TextOverflow.ellipsis,
                                        fw: 0,
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        splashColor: theme.isDarkMode
                                            ? colors.splashColorDark
                                            : colors.splashColorLight,
                                        highlightColor: theme.isDarkMode
                                            ? colors.highlightDark
                                            : colors.highlightLight,
                                        onTap: _toggleSecretVisibility,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(
                                          provider.hideSecret
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 20,
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        splashColor: theme.isDarkMode
                                            ? colors.splashColorDark
                                            : colors.splashColorLight,
                                        highlightColor: theme.isDarkMode
                                            ? colors.highlightDark
                                            : colors.highlightLight,
                                      onTap: () => _copyToClipboard(
                                          provider.generatedSecretCode ??
                                              (apiData.stat == "Ok"
                                                  ? apiData.secretCode
                                                  : "")),
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          child: Center(
                                            child: Icon(
                                              Icons.copy,
                                              size: 18,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Add extra padding at bottom for keyboard
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
                      ],
                    ),
                  ),
                ),
                
                // Fixed bottom button
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                    // border: Border(
                    //   top: BorderSide(
                    //     color: theme.isDarkMode
                    //         ? colors.textSecondaryDark.withOpacity(0.2)
                    //         : colors.textSecondaryLight.withOpacity(0.2),
                    //     width: 1,
                    //   ),
                    // ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: apiData == null ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: TextWidget.subText(
                        text: apiData?.stat == "Ok" ? "Update" : "Create",
                        theme: false,
                        color: colors.colorWhite,
                        fw: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




