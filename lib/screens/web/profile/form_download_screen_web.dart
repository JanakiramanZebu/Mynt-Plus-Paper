import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:url_launcher/url_launcher.dart';

class FormDownloadScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const FormDownloadScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<FormDownloadScreenWeb> createState() =>
      _FormDownloadScreenWebState();
}

class _FormDownloadScreenWebState extends ConsumerState<FormDownloadScreenWeb> {
  bool _loading = true;
  bool _cmrLoading = false;
  String? _ekycDownloadPath;
  List<Map<String, String>> _modificationForms = [];

  final _api = locator<ApiExporter>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    await Future.wait([_fetchModificationForms(), _fetchEkycForm()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchModificationForms() async {
    try {
      final uri = Uri.parse('https://rekycbe.mynt.in/pdfdownload');
      final res = await _api.apiClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'client_id': _api.prefs.clientId}),
      );
      final json = jsonDecode(res.body);
      if (json['stat'] == 'ok' && json['values'] != null) {
        final List values = json['values'];
        final List<Map<String, String>> forms = [];
        for (final item in values) {
          if (item is Map) {
            for (final entry in item.entries) {
              if (entry.value != null && entry.value.toString().isNotEmpty) {
                forms.add({
                  'name': entry.key.toString(),
                  'path': entry.value.toString(),
                });
              }
            }
          }
        }
        if (mounted) setState(() => _modificationForms = forms);
      }
    } catch (e) {
      debugPrint('Error fetching modification forms: $e');
    }
  }

  Future<void> _fetchEkycForm() async {
    try {
      final provider = ref.read(profileAllDetailsProvider);
      final mobileNo =
          provider.clientAllDetailsSafe?.clientData?.mOBILENO ?? '';
      if (mobileNo.isEmpty) return;

      final uri = Uri.parse('https://ekycbe.mynt.in/dd/ekyc_form_download');
      final res = await _api.apiClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_number': mobileNo}),
      );
      final json = jsonDecode(res.body);
      if (json['stat'] == 'ok' && json['values'] != null) {
        if (mounted) {
          setState(() => _ekycDownloadPath = json['values'].toString());
        }
      }
    } catch (e) {
      debugPrint('Error fetching ekyc form: $e');
    }
  }

  Future<void> _downloadCmr() async {
    setState(() => _cmrLoading = true);
    try {
      final uri = Uri.parse('https://rekycbe.mynt.in/report/cmr');
      final res = await _api.apiClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'client_id': _api.prefs.clientId}),
      );
      final json = jsonDecode(res.body);
      if (json['path'] != null) {
        _openLink('https://rekycbe.mynt.in${json['path']}');
      }
    } catch (e) {
      debugPrint('Error downloading CMR: $e');
    } finally {
      if (mounted) setState(() => _cmrLoading = false);
    }
  }

  void _openLink(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final cardBorder = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    final bgColor = resolveThemeColor(context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 28, 20),
            child: Row(
              children: [
                if (widget.onBack != null) ...[
                  CustomBackBtn(onBack: widget.onBack),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Download',
                        style: MyntWebTextStyles.title(context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.semiBold,
                        ).copyWith(decoration: TextDecoration.none),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   'Download all forms related to your trading account',
                      //   style: MyntWebTextStyles.para(context,
                      //     darkColor: MyntColors.textSecondaryDark,
                      //     lightColor: MyntColors.textSecondary,
                      //     fontWeight: MyntFonts.regular,
                      //   ).copyWith(decoration: TextDecoration.none),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _cmrLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: primaryColor))
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _downloadCmr,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CMR Download',
                              style: MyntWebTextStyles.bodySmall(context,
                                color: Colors.white,
                                fontWeight: MyntFonts.semiBold,
                              ).copyWith(decoration: TextDecoration.none),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: primaryColor))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── All forms in a single table ──
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                decoration: BoxDecoration(
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.cardBorderDark,
                                      light: const Color(0xFFF8F9FA)),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'FORM NAME',
                                        style: MyntWebTextStyles.caption(
                                                context,
                                                darkColor: MyntColors
                                                    .textTertiaryDark,
                                                lightColor:
                                                    MyntColors.textTertiary,
                                                fontWeight: MyntFonts.semiBold)
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.none,
                                                letterSpacing: 0.5),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'TYPE',
                                        style: MyntWebTextStyles.caption(
                                                context,
                                                darkColor: MyntColors
                                                    .textTertiaryDark,
                                                lightColor:
                                                    MyntColors.textTertiary,
                                                fontWeight: MyntFonts.semiBold)
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.none,
                                                letterSpacing: 0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 120),
                                  ],
                                ),
                              ),

                              // KYC form row
                              if (_ekycDownloadPath != null &&
                                  _ekycDownloadPath!.isNotEmpty)
                                _buildTableRow(
                                  name: 'Trading and DP KYC',
                                  type: 'KYC Form',
                                  onDownload: () => _openLink(
                                      'https://ekycbe.mynt.in$_ekycDownloadPath'),
                                  primaryColor: primaryColor,
                                  dividerColor: dividerColor,
                                  showDivider: _modificationForms.isNotEmpty,
                                ),

                              // Modification form rows
                              if (_modificationForms.isEmpty &&
                                  (_ekycDownloadPath == null ||
                                      _ekycDownloadPath!.isEmpty))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 24),
                                  child: Text(
                                    'No forms available',
                                    style: MyntWebTextStyles.body(context,
                                      darkColor:
                                          MyntColors.textSecondaryDark,
                                      lightColor:
                                          MyntColors.textSecondary,
                                      fontWeight: MyntFonts.regular,
                                    ).copyWith(
                                        decoration: TextDecoration.none),
                                  ),
                                )
                              else
                                ...List.generate(
                                    _modificationForms.length, (i) {
                                  final form = _modificationForms[i];
                                  return _buildTableRow(
                                    name: form['name'] ?? '',
                                    type: 'Modification',
                                    onDownload: () => _openLink(
                                        'https://rekycbe.mynt.in${form['path']}'),
                                    primaryColor: primaryColor,
                                    dividerColor: dividerColor,
                                    showDivider:
                                        i < _modificationForms.length - 1,
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String name,
    required String type,
    required VoidCallback onDownload,
    required Color primaryColor,
    required Color dividerColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  name,
                  style: MyntWebTextStyles.body(context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                    fontWeight: MyntFonts.medium,
                  ).copyWith(decoration: TextDecoration.none),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  type,
                  style: MyntWebTextStyles.body(context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary,
                    fontWeight: MyntFonts.regular,
                  ).copyWith(decoration: TextDecoration.none),
                ),
              ),
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDownload,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download_outlined,
                                size: 16, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              'Download',
                              style: MyntWebTextStyles.bodySmall(context,
                                color: primaryColor,
                                fontWeight: MyntFonts.semiBold,
                              ).copyWith(decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Divider(height: 1, thickness: 1, color: dividerColor),
          ),
      ],
    );
  }
}
