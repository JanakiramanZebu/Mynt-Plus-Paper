import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/api_key_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

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
    // Show message using project's successMessage
    successMessage(context, "Copied to clipboard");
  }

  void _showRegenerateConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: resolveThemeColor(ctx,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
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
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      splashColor: resolveThemeColor(ctx,
                          dark: MyntColors.rippleDark,
                          light: MyntColors.rippleLight),
                      highlightColor: resolveThemeColor(ctx,
                          dark: MyntColors.highlightDark,
                          light: MyntColors.highlightLight),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: resolveThemeColor(ctx,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
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
              Text(
                "Are you sure you want to regenerate the secret code? This will generate a new secret code and the old one will no longer work.",
                textAlign: TextAlign.center,
                style: MyntWebTextStyles.bodySmall(ctx,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                    fontWeight: MyntFonts.medium),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(apikeyprovider).generateNewSecretCode();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  backgroundColor: MyntColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "Regenerate",
                  style: MyntWebTextStyles.bodySmall(ctx,
                      color: Colors.white,
                      fontWeight: MyntFonts.semiBold),
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
    } else {
      error(context, result?.emsg ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiData = ref.watch(apikeyprovider).generateApikeyNew;
    final provider = ref.watch(apikeyprovider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            border: Border(
              top: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.backgroundColor),
              ),
              left: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.backgroundColor),
              ),
              right: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.backgroundColor),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Client ID Section - Always show if we have API data
                  if (apiData != null) ...[
                    Row(
                      children: [
                        Text(
                          'Client Id :',
                          style: MyntWebTextStyles.bodySmall(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary,
                              fontWeight: MyntFonts.medium),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "${apiData.appKey}",
                                  style: MyntWebTextStyles.title(context,
                                      darkColor: MyntColors.textPrimaryDark,
                                      lightColor: MyntColors.textPrimary,
                                      fontWeight: MyntFonts.medium),
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
                                  child: SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: Center(
                                      child: Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: resolveThemeColor(context,
                                            dark: MyntColors.textSecondaryDark,
                                            light: MyntColors.textSecondary),
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
                  Text(
                    'Redirect URL',
                    style: MyntWebTextStyles.bodySmall(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.medium),
                  ),
                  const SizedBox(height: 8),
                  // URL Input Field (project-styled)
                  CustomTextFormField(
                    textCtrl: provider.urlController,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.url,
                    fillColor: resolveThemeColor(context,
                        dark: MyntColors.listItemBgDark,
                        light: MyntColors.listItemBg),
                    hintText: 'URL',
                    hintStyle: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary),
                    style: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                    onChanged: (value) {
                      _validateUrl(value);
                    },
                  ),
                  // Custom error message display like margin_calculator.dart
                  if (_errorMessageUrl != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _errorMessageUrl!,
                        style: MyntWebTextStyles.caption(context,
                            color: MyntColors.loss),
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
                            Text(
                              'Primary IP Address',
                              style: MyntWebTextStyles.bodySmall(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.medium),
                            ),
                            const SizedBox(height: 8),
                            CustomTextFormField(
                              textCtrl: provider.primaryIpController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.number,
                              hintText: 'Primary IP Address',
                              fillColor: resolveThemeColor(context,
                                  dark: MyntColors.listItemBgDark,
                                  light: MyntColors.listItemBg),
                              hintStyle: MyntWebTextStyles.para(context,
                                  darkColor: MyntColors.textSecondaryDark,
                                  lightColor: MyntColors.textSecondary),
                              style: MyntWebTextStyles.para(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary),
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
                                child: Text(
                                  _errorMessagePrimaryIp!,
                                  style: MyntWebTextStyles.caption(context,
                                      color: MyntColors.loss),
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
                            Text(
                              'Backup IP Address',
                              style: MyntWebTextStyles.bodySmall(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.medium),
                            ),
                            const SizedBox(height: 8),
                            CustomTextFormField(
                              textCtrl: provider.backupIpController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.number,
                              hintText: 'Backup IP Address',
                              fillColor: resolveThemeColor(context,
                                  dark: MyntColors.listItemBgDark,
                                  light: MyntColors.listItemBg),
                              hintStyle: MyntWebTextStyles.para(context,
                                  darkColor: MyntColors.textSecondaryDark,
                                  lightColor: MyntColors.textSecondary),
                              style: MyntWebTextStyles.para(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary),
                              errorStyle: MyntWebTextStyles.caption(context,
                                  color: MyntColors.loss),
                              onChanged: (value) {
                                _validateBackupIp(value);
                              },
                            ),
                            // Custom error message display for Backup IP
                            if (_errorMessageBackupIp != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _errorMessageBackupIp!,
                                  style: MyntWebTextStyles.caption(context,
                                      color: MyntColors.loss),
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
                        Text(
                          'Secret Code',
                          style: MyntWebTextStyles.bodySmall(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary,
                              fontWeight: MyntFonts.medium),
                        ),
                        // Regenerate button (only show for existing data)
                        if (apiData.stat == "Ok")
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: () {
                                _showRegenerateConfirmation();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Regenerate',
                                  style: MyntWebTextStyles.para(context,
                                      color: MyntColors.primary,
                                      fontWeight: MyntFonts.semiBold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                            dark: MyntColors.listItemBgDark,
                            light: MyntColors.listItemBg),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: MyntColors.primary,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                provider.hideSecret
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
                                overflow: TextOverflow.ellipsis,
                                style: MyntWebTextStyles.para(context,
                                    darkColor: MyntColors.textPrimaryDark,
                                    lightColor: MyntColors.textPrimary),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: resolveThemeColor(context,
                                    dark: MyntColors.rippleDark,
                                    light: MyntColors.rippleLight),
                                highlightColor: resolveThemeColor(context,
                                    dark: MyntColors.highlightDark,
                                    light: MyntColors.highlightLight),
                                onTap: _toggleSecretVisibility,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    provider.hideSecret
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                    color: resolveThemeColor(context,
                                        dark: MyntColors.textSecondaryDark,
                                        light: MyntColors.textSecondary),
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
                                splashColor: resolveThemeColor(context,
                                    dark: MyntColors.rippleDark,
                                    light: MyntColors.rippleLight),
                                highlightColor: resolveThemeColor(context,
                                    dark: MyntColors.highlightDark,
                                    light: MyntColors.highlightLight),
                                onTap: () => _copyToClipboard(
                                    provider.generatedSecretCode ??
                                        (apiData.stat == "Ok"
                                            ? apiData.secretCode
                                            : "")),
                                child: SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Center(
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: resolveThemeColor(context,
                                          dark: MyntColors.textSecondaryDark,
                                          light: MyntColors.textSecondary),
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
                  // SizedBox(
                  //     height: MediaQuery.of(context).viewInsets.bottom > 0
                  //         ? 100
                  //         : 20),
                  Container(
                              // padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.backgroundColorDark,
                  light: MyntColors.backgroundColor),
                              ),
                              child: SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: apiData == null ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                backgroundColor: MyntColors.primary,
                foregroundColor: MyntColors.backgroundColor,
                // padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
                child: Text(
                  apiData?.stat == "Ok" ? "Update" : "Create",
                  style: MyntWebTextStyles.bodySmall(context,
                      color: Colors.white,
                      fontWeight: MyntFonts.semiBold),
                ),
              ),
                              ),
                            ),
                ],
              ),
        
              // Fixed bottom button
              
            ],
          ),
        ),
      ),
    );
  }
}
