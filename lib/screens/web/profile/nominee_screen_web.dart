import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:mynt_plus/utils/digio_esign.dart';

class NomineeScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const NomineeScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<NomineeScreenWeb> createState() => _NomineeScreenWebState();
}

class _NomineeScreenWebState extends ConsumerState<NomineeScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _esignLoading = false;

  // Nominee choice: 'yes' = add nominees, 'no' = opt out
  String? _yesOrNo;

  // Active nominee panel (0, 1, 2)
  int _activePanel = 0;
  int _nomineeCount = 1; // 1, 2, or 3

  // Nominee status from /nom_stat
  bool _hasExistingNominee = false;
  bool _esignPending = false;
  bool _esignCompleted = false;
  String? _fileId;
  String? _esignEmail;
  String? _esignSession;

  // ── Nominee 1 Fields ──
  final _name1 = TextEditingController();
  final _percent1 = TextEditingController(text: '100');
  DateTime? _dob1;
  String? _relation1;
  bool _sameAddress1 = false;
  final _address1 = TextEditingController();
  final _city1 = TextEditingController();
  final _state1 = TextEditingController();
  final _country1 = TextEditingController(text: 'INDIA');
  final _pincode1 = TextEditingController();
  final _mobile1 = TextEditingController();
  final _email1 = TextEditingController();
  String? _proofType1;
  final _proofValue1 = TextEditingController();

  // ── Nominee 2 Fields ──
  final _name2 = TextEditingController();
  final _percent2 = TextEditingController();
  DateTime? _dob2;
  String? _relation2;
  bool _sameAddress2 = false;
  final _address2 = TextEditingController();
  final _city2 = TextEditingController();
  final _state2 = TextEditingController();
  final _country2 = TextEditingController(text: 'INDIA');
  final _pincode2 = TextEditingController();
  final _mobile2 = TextEditingController();
  final _email2 = TextEditingController();
  String? _proofType2;
  final _proofValue2 = TextEditingController();

  // ── Nominee 3 Fields ──
  final _name3 = TextEditingController();
  final _percent3 = TextEditingController();
  DateTime? _dob3;
  String? _relation3;
  bool _sameAddress3 = false;
  final _address3 = TextEditingController();
  final _city3 = TextEditingController();
  final _state3 = TextEditingController();
  final _country3 = TextEditingController(text: 'INDIA');
  final _pincode3 = TextEditingController();
  final _mobile3 = TextEditingController();
  final _email3 = TextEditingController();
  String? _proofType3;
  final _proofValue3 = TextEditingController();

  // ── Guardian Fields (for minor nominees) ──
  final _guardianName1 = TextEditingController();
  DateTime? _guardianDob1;
  String? _guardianRelation1;
  final _guardianMobile1 = TextEditingController();

  final _guardianName2 = TextEditingController();
  DateTime? _guardianDob2;
  String? _guardianRelation2;
  final _guardianMobile2 = TextEditingController();

  final _guardianName3 = TextEditingController();
  DateTime? _guardianDob3;
  String? _guardianRelation3;
  final _guardianMobile3 = TextEditingController();

  static const _relations = [
    'MOTHER', 'FATHER', 'BROTHER', 'SISTER', 'DAUGHTER',
    'WIFE', 'HUSBAND', 'SON', 'GRAND-SON', 'GRAND-FATHER',
    'GRAND-DAUGHTER', 'GRAND-MOTHER', 'FRIEND',
  ];

  static const _proofTypes = [
    'PAN Number',
    'Aadhaar number(last 4 digits)',
    'Driving Licence Number',
  ];

  bool _isMinor(DateTime? dob) {
    if (dob == null) return false;
    final age = DateTime.now().difference(dob).inDays / 365.25;
    return age < 18;
  }

  String _proofTypeToApiKey(String? type) {
    switch (type) {
      case 'PAN Number':
        return 'PAN';
      case 'Aadhaar number(last 4 digits)':
        return 'AADHAR';
      case 'Driving Licence Number':
        return 'PROOF OF IDENTITY';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNomineeStatus();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name1, _percent1, _address1, _city1, _state1, _country1, _pincode1,
      _mobile1, _email1, _proofValue1,
      _name2, _percent2, _address2, _city2, _state2, _country2, _pincode2,
      _mobile2, _email2, _proofValue2,
      _name3, _percent3, _address3, _city3, _state3, _country3, _pincode3,
      _mobile3, _email3, _proofValue3,
      _guardianName1, _guardianMobile1,
      _guardianName2, _guardianMobile2,
      _guardianName3, _guardianMobile3,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadNomineeStatus() async {
    setState(() => _loading = true);
    final provider = ref.read(profileAllDetailsProvider);
    await provider.fetchNomineeStatus();
    if (!mounted) return;

    final statusData = provider.nomineeStatusData;
    if (statusData != null) {
      final appStatus = statusData['app_status']?.toString() ?? '';
      final name1 = statusData['nominee1_name']?.toString() ?? '';

      setState(() {
        _hasExistingNominee = name1.isNotEmpty;
        _esignPending = appStatus == 'e-signed pending';
        _esignCompleted = appStatus == 'e-signed completed';
        _fileId = statusData['file_id']?.toString();
        _esignEmail = statusData['client_email']?.toString();
        _esignSession = statusData['session']?.toString();

        // Populate existing nominee data (read-only display)
        if (_hasExistingNominee) {
          _name1.text = name1;
          _relation1 = statusData['nominee1_relation']?.toString();
          _percent1.text = statusData['nominee1_percentage']?.toString() ?? '';
          final dob1Str = statusData['nominee1_DOB']?.toString() ?? '';
          if (dob1Str.isNotEmpty) {
            try { _dob1 = DateFormat('yyyy-MM-dd').parse(dob1Str); } catch (_) {}
          }

          // Nominee 2
          final name2 = statusData['nominee2_name']?.toString() ?? '';
          if (name2.isNotEmpty) {
            _nomineeCount = _nomineeCount < 2 ? 2 : _nomineeCount;
            _name2.text = name2;
            _relation2 = statusData['nominee2_relation']?.toString();
            _percent2.text = statusData['nominee2_percentage']?.toString() ?? '';
            final dob2Str = statusData['nominee2_DOB']?.toString() ?? '';
            if (dob2Str.isNotEmpty) {
              try { _dob2 = DateFormat('yyyy-MM-dd').parse(dob2Str); } catch (_) {}
            }
          }

          // Nominee 3
          final name3 = statusData['nominee3_name']?.toString() ?? '';
          if (name3.isNotEmpty) {
            _nomineeCount = 3;
            _name3.text = name3;
            _relation3 = statusData['nominee3_relation']?.toString();
            _percent3.text = statusData['nominee3_percentage']?.toString() ?? '';
            final dob3Str = statusData['nominee3_DOB']?.toString() ?? '';
            if (dob3Str.isNotEmpty) {
              try { _dob3 = DateFormat('yyyy-MM-dd').parse(dob3Str); } catch (_) {}
            }
          }
        }
      });
    }

    // Fallback: if nom_stat didn't have nominee data, use profile API data
    if (!_hasExistingNominee) {
      final clientData = provider.clientAllDetailsSafe?.clientData;
      if (clientData != null) {
        final nomName = clientData.nomineeName ?? '';
        if (nomName.isNotEmpty) {
          setState(() {
            _hasExistingNominee = true;
            _name1.text = nomName;
            _relation1 = clientData.nomineeRelation?.toUpperCase();
            _percent1.text = '100';
            final nomDob = clientData.nomineeDOB ?? '';
            if (nomDob.isNotEmpty) {
              try { _dob1 = DateFormat('dd/MM/yyyy').parse(nomDob); } catch (_) {
                try { _dob1 = DateFormat('yyyy-MM-dd').parse(nomDob); } catch (_) {}
              }
            }
            _mobile1.text = clientData.nomineePhone ?? '';
            _address1.text = clientData.nomineeAddress ?? '';
          });
        }
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _submitNominee() async {
    if (_yesOrNo == 'yes' && !(_formKey.currentState?.validate() ?? false)) return;

    // Validate percentages add up to 100
    if (_yesOrNo == 'yes') {
      final p1 = int.tryParse(_percent1.text) ?? 0;
      final p2 = _nomineeCount >= 2 ? (int.tryParse(_percent2.text) ?? 0) : 0;
      final p3 = _nomineeCount >= 3 ? (int.tryParse(_percent3.text) ?? 0) : 0;
      final total = p1 + p2 + p3;
      if (total != 100) {
        warningMessage(context, 'Total percentage must be 100%. Currently: $total%');
        return;
      }
    }

    setState(() => _loading = true);

    final provider = ref.read(profileAllDetailsProvider);
    final clientData = provider.clientAllDetails.clientData;
    if (clientData == null) {
      setState(() => _loading = false);
      return;
    }

    final fields = <String, String>{
      'clientcode': clientData.toJson()['CLIENT_ID'] ?? '',
      'client_email': clientData.toJson()['CLIENT_ID_MAIL'] ?? '',
      'client_pan': clientData.toJson()['PAN_NO'] ?? '',
      'client_name': clientData.toJson()['CLIENT_NAME'] ?? '',
      'dp_code': clientData.toJson()['CLIENT_DP_CODE'] ?? '',
      'nominee_req': _yesOrNo ?? 'no',

      // Nominee 1
      'Nominee1_name': _yesOrNo == 'yes' ? _name1.text : '',
      'Nominee1_PAN': _yesOrNo == 'yes' ? _proofValue1.text : '',
      'Nominee1_DOB': _yesOrNo == 'yes' && _dob1 != null
          ? DateFormat('yyyy-MM-dd').format(_dob1!)
          : '',
      'Nominee1_relation': _yesOrNo == 'yes' ? (_relation1 ?? '') : '',
      'Nominee1_address1': _yesOrNo == 'yes'
          ? (_sameAddress1
              ? (clientData.toJson()['CL_RESI_ADD1'] ?? '')
              : _address1.text)
          : '',
      'Nominee1_address2': _yesOrNo == 'yes' && _sameAddress1
          ? (clientData.toJson()['CL_RESI_ADD2'] ?? '')
          : '',
      'Nominee1_city': _yesOrNo == 'yes' ? _city1.text : '',
      'Nominee1_state': _yesOrNo == 'yes' ? _state1.text : '',
      'Nominee1_country': _yesOrNo == 'yes' ? _country1.text : '',
      'Nominee1_pincode': _yesOrNo == 'yes' ? _pincode1.text : '',
      'Nominee1_mobile': _yesOrNo == 'yes' ? _mobile1.text : '',
      'Nominee1_email': _yesOrNo == 'yes' ? _email1.text : '',
      'Nominee1_percentage': _yesOrNo == 'yes' ? _percent1.text : '',
      'Nominee1_Select_id': _yesOrNo == 'yes'
          ? _proofTypeToApiKey(_proofType1)
          : '',

      // Nominee 2
      'Nominee2_name': _nomineeCount >= 2 ? _name2.text : '',
      'Nominee2_PAN': _nomineeCount >= 2 ? _proofValue2.text : '',
      'Nominee2_DOB': _nomineeCount >= 2 && _dob2 != null
          ? DateFormat('yyyy-MM-dd').format(_dob2!)
          : '',
      'Nominee2_relation': _nomineeCount >= 2 ? (_relation2 ?? '') : '',
      'Nominee2_address1': _nomineeCount >= 2
          ? (_sameAddress2
              ? (clientData.toJson()['CL_RESI_ADD1'] ?? '')
              : _address2.text)
          : '',
      'Nominee2_address2': '',
      'Nominee2_city': _nomineeCount >= 2 ? _city2.text : '',
      'Nominee2_state': _nomineeCount >= 2 ? _state2.text : '',
      'Nominee2_country': _nomineeCount >= 2 ? _country2.text : '',
      'Nominee2_pincode': _nomineeCount >= 2 ? _pincode2.text : '',
      'Nominee2_mobile': _nomineeCount >= 2 ? _mobile2.text : '',
      'Nominee2_email': _nomineeCount >= 2 ? _email2.text : '',
      'Nominee2_percentage': _nomineeCount >= 2 ? _percent2.text : '',
      'Nominee2_Select_id': _nomineeCount >= 2
          ? _proofTypeToApiKey(_proofType2)
          : '',

      // Nominee 3
      'Nominee3_name': _nomineeCount >= 3 ? _name3.text : '',
      'Nominee3_PAN': _nomineeCount >= 3 ? _proofValue3.text : '',
      'Nominee3_DOB': _nomineeCount >= 3 && _dob3 != null
          ? DateFormat('yyyy-MM-dd').format(_dob3!)
          : '',
      'Nominee3_relation': _nomineeCount >= 3 ? (_relation3 ?? '') : '',
      'Nominee3_address1': _nomineeCount >= 3
          ? (_sameAddress3
              ? (clientData.toJson()['CL_RESI_ADD1'] ?? '')
              : _address3.text)
          : '',
      'Nominee3_address2': '',
      'Nominee3_city': _nomineeCount >= 3 ? _city3.text : '',
      'Nominee3_state': _nomineeCount >= 3 ? _state3.text : '',
      'Nominee3_country': _nomineeCount >= 3 ? _country3.text : '',
      'Nominee3_pincode': _nomineeCount >= 3 ? _pincode3.text : '',
      'Nominee3_mobile': _nomineeCount >= 3 ? _mobile3.text : '',
      'Nominee3_email': _nomineeCount >= 3 ? _email3.text : '',
      'Nominee3_percentage': _nomineeCount >= 3 ? _percent3.text : '',
      'Nominee3_Select_id': _nomineeCount >= 3
          ? _proofTypeToApiKey(_proofType3)
          : '',

      // Guardian 1
      'Guardian_name': _isMinor(_dob1) ? _guardianName1.text : '',
      'Guardian_dob': _isMinor(_dob1) && _guardianDob1 != null
          ? DateFormat('yyyy-MM-dd').format(_guardianDob1!)
          : '',
      'Guardian_relation': _isMinor(_dob1) ? (_guardianRelation1 ?? '') : '',
      'Guardian_mobile': _isMinor(_dob1) ? _guardianMobile1.text : '',
      'Guardian_address': '',
      'Guardian_city': '',
      'Guardian_state': '',
      'Guardian_country': '',
      'Guardian_email': '',
      'Guardian_doc_type': '',
      'Guardian_pincode': '',

      // Guardian 2
      'Guardian_name2': _isMinor(_dob2) ? _guardianName2.text : '',
      'Guardian_dob2': _isMinor(_dob2) && _guardianDob2 != null
          ? DateFormat('yyyy-MM-dd').format(_guardianDob2!)
          : '',
      'Guardian_relation2': _isMinor(_dob2) ? (_guardianRelation2 ?? '') : '',
      'Guardian_mobile2': _isMinor(_dob2) ? _guardianMobile2.text : '',
      'Guardian_address2': '',
      'Guardian_city2': '',
      'Guardian_state2': '',
      'Guardian_country2': '',
      'Guardian_email2': '',
      'Guardian_doc_type2': '',
      'Guardian_pincode2': '',

      // Guardian 3
      'Guardian_name3': _isMinor(_dob3) ? _guardianName3.text : '',
      'Guardian_dob3': _isMinor(_dob3) && _guardianDob3 != null
          ? DateFormat('yyyy-MM-dd').format(_guardianDob3!)
          : '',
      'Guardian_relation3': _isMinor(_dob3) ? (_guardianRelation3 ?? '') : '',
      'Guardian_mobile3': _isMinor(_dob3) ? _guardianMobile3.text : '',
      'Guardian_address3': '',
      'Guardian_city3': '',
      'Guardian_state3': '',
      'Guardian_country3': '',
      'Guardian_email3': '',
      'Guardian_doc_type3': '',
      'Guardian_pincode3': '',

      // Documents (empty for web)
      'nominee_doc1': '',
      'nominee_doc2': '',
      'nominee_doc3': '',
      'guardian_doc': '',
      'guardian_doc2': '',
      'guardian_doc3': '',
    };

    final result = await provider.submitNominee(fields: fields);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null && result['msg'] == 'Success') {
      setState(() {
        _esignPending = true;
        _fileId = result['fileid']?.toString();
      });
      _showEsignDialog();
    } else if (result != null && result['msg'] == 'Client already exists') {
      warningMessage(context, 'Nominee form already initiated');
    } else {
      warningMessage(context, result?['msg']?.toString() ?? 'Error in Server, please try again later');
    }
  }

  Future<void> _openDigioEsign() async {
    final statusData = ref.read(profileAllDetailsProvider).nomineeStatusData;
    final fileId = _fileId ?? statusData?['file_id']?.toString();
    final email = _esignEmail ?? statusData?['client_email']?.toString();
    final session = _esignSession ?? statusData?['session']?.toString();

    if (fileId == null || email == null || session == null) {
      warningMessage(context, 'E-Sign details not available');
      return;
    }

    setState(() => _esignLoading = true);
    final result = await startDigioEsign(
      fileId: fileId,
      email: email,
      session: session,
    );

    if (!mounted) return;
    setState(() => _esignLoading = false);

    if (result == 'success') {
      await ref.read(profileAllDetailsProvider).fetchNomineeStatus();
      await ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
      if (mounted) {
        setState(() {
          _esignCompleted = true;
          _esignPending = false;
        });
        successMessage(context, 'Nominee e-signed successfully');
      }
    }
  }

  void _showEsignDialog() {
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('E-Sign Is Pending!',
                        style: MyntWebTextStyles.body(context,
                            fontWeight: MyntFonts.semiBold, color: textColor)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, size: 20, color: subtitleColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Your nominee form has been submitted. Please complete the e-sign to finalize.',
                  style: MyntWebTextStyles.bodySmall(context,
                      fontWeight: MyntFonts.medium, color: textColor)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openDigioEsign();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Click here E-sign',
                      style: MyntWebTextStyles.body(context,
                          fontWeight: MyntFonts.semiBold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);

    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final bgColor = resolveThemeColor(context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor);
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final cardBorder = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final successColor = resolveThemeColor(context,
        dark: MyntColors.successDark, light: MyntColors.success);
    final errorColor = resolveThemeColor(context,
        dark: MyntColors.errorDark, light: MyntColors.error);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);

    return Scaffold(
      backgroundColor: bgColor,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      if (widget.onBack != null)
                        InkWell(
                          onTap: widget.onBack,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_ios_outlined,
                              size: 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      if (widget.onBack != null) const SizedBox(width: 8),
                      Text('Nominee',
                          style: MyntWebTextStyles.head(context,
                              fontWeight: MyntFonts.semiBold,
                              color: textColor)
                              .copyWith(decoration: TextDecoration.none)),
                      const SizedBox(width: 12),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _hasExistingNominee
                              ? successColor.withValues(alpha: 0.1)
                              : errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _hasExistingNominee
                                ? successColor.withValues(alpha: 0.3)
                                : errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _hasExistingNominee
                                  ? Icons.verified_user_outlined
                                  : Icons.shield_outlined,
                              color: _hasExistingNominee ? successColor : errorColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hasExistingNominee ? 'Secured' : 'Unsecured',
                              style: MyntWebTextStyles.caption(context,
                                  color: _hasExistingNominee ? successColor : errorColor,
                                  fontWeight: MyntFonts.semiBold)
                                  .copyWith(decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Existing nominee display (read-only) ──
                        if (_hasExistingNominee) ...[
                          _buildExistingNomineeView(
                              textColor, subtitleColor, cardBorder, cardBg, dividerColor),
                          const SizedBox(height: 16),
                        ],

                        // ── E-sign pending banner ──
                        if (_esignPending) ...[
                          _buildEsignPendingBanner(primaryColor, errorColor),
                          const SizedBox(height: 24),
                        ],

                        // ── Single card for no-nominee state ──
                        if (!_hasExistingNominee && !_esignPending && !_esignCompleted)
                          _buildNoNomineeCard(textColor, subtitleColor, cardBg, cardBorder, primaryColor, errorColor),

                        // ── Nominee form (only show when editing/adding with existing nominee) ──
                        if (_hasExistingNominee && !_esignCompleted && !_esignPending) ...[
                          _buildChoiceSection(primaryColor, textColor, subtitleColor, cardBorder),
                          const SizedBox(height: 16),
                          if (_yesOrNo == 'yes') ...[
                            _buildNomineeForm(
                                textColor, subtitleColor, cardBorder, cardBg, primaryColor, dividerColor),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SINGLE CARD (no nominee state - info + actions combined)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNoNomineeCard(Color textColor, Color subtitleColor,
      Color cardBg, Color borderColor, Color primaryColor, Color errorColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
      color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_outlined, color: errorColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your account is not secured',
                        style: MyntWebTextStyles.title(context,
                            fontWeight: MyntFonts.semiBold, color: textColor)
                            .copyWith(decoration: TextDecoration.none)),
                    const SizedBox(height: 4),
                    Text('Add a nominee to protect your investments and ensure smooth transfer of assets.',
                        style: MyntWebTextStyles.bodySmall(context,
                            color: subtitleColor, fontWeight: MyntFonts.regular)
                            .copyWith(decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _yesOrNo = 'yes';
                    _activePanel = 0;
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add Nominee',
                    style: MyntWebTextStyles.bodySmall(context,
                        color: Colors.white, fontWeight: MyntFonts.semiBold)
                        .copyWith(decoration: TextDecoration.none)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() => _yesOrNo = 'no');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Skip for now',
                    style: MyntWebTextStyles.bodySmall(context,
                        color: subtitleColor, fontWeight: MyntFonts.medium)
                        .copyWith(decoration: TextDecoration.none)),
              ),
            ],
          ),

          // Opt-out continue button
          if (_yesOrNo == 'no') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submitNominee,
              style: ElevatedButton.styleFrom(
                backgroundColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Continue',
                      style: MyntWebTextStyles.bodySmall(context,
                          color: Colors.white, fontWeight: MyntFonts.semiBold)
                          .copyWith(decoration: TextDecoration.none)),
            ),
          ],

          // Nominee form (inline when "Add Nominee" is selected)
          if (_yesOrNo == 'yes') ...[
            const SizedBox(height: 20),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 20),
            _buildNomineeForm(textColor, subtitleColor, borderColor, cardBg, primaryColor,
                resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider)),
          ],

          // Regulatory note
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline, color: subtitleColor, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'As per SEBI regulations, you can add up to 3 nominees for your trading and demat account.',
                  style: MyntWebTextStyles.caption(context,
                      color: subtitleColor, fontWeight: MyntFonts.regular)
                      .copyWith(decoration: TextDecoration.none),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  EXISTING NOMINEE DISPLAY
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildExistingNomineeView(
      Color textColor, Color subtitleColor, Color borderColor,
      Color cardBg, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Existing Nominee',
              style: MyntWebTextStyles.title(context,
                  fontWeight: MyntFonts.semiBold,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary)
                  .copyWith(decoration: TextDecoration.none)),
          const SizedBox(height: 16),

          // Nominee 1 — 3-column grid
          Row(
            children: [
              Expanded(child: _buildReadOnlyField('NOMINEE NAME', _name1.text, textColor, subtitleColor, borderColor)),
              const SizedBox(width: 24),
              Expanded(child: _buildReadOnlyField('NOMINEE RELATION', _relation1 ?? '', textColor, subtitleColor, borderColor)),
              const SizedBox(width: 24),
              Expanded(child: _buildReadOnlyField('NOMINEE DOB', _dob1 != null ? DateFormat('dd/MM/yyyy').format(_dob1!) : '-', textColor, subtitleColor, borderColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildReadOnlyField('PERCENTAGE', _percent1.text.isNotEmpty ? '${_percent1.text}%' : '-', textColor, subtitleColor, borderColor)),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
            ],
          ),

          // Nominee 2
          if (_nomineeCount >= 2 && _name2.text.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: dividerColor),
            ),
            Text('Nominee 2',
                style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.semiBold,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary)
                    .copyWith(decoration: TextDecoration.none)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReadOnlyField('NOMINEE NAME', _name2.text, textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                Expanded(child: _buildReadOnlyField('NOMINEE RELATION', _relation2 ?? '', textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                Expanded(child: _buildReadOnlyField('NOMINEE DOB', _dob2 != null ? DateFormat('dd/MM/yyyy').format(_dob2!) : '-', textColor, subtitleColor, borderColor)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReadOnlyField('PERCENTAGE', _percent2.text.isNotEmpty ? '${_percent2.text}%' : '-', textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],

          // Nominee 3
          if (_nomineeCount >= 3 && _name3.text.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: dividerColor),
            ),
            Text('Nominee 3',
                style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.semiBold,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary)
                    .copyWith(decoration: TextDecoration.none)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReadOnlyField('NOMINEE NAME', _name3.text, textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                Expanded(child: _buildReadOnlyField('NOMINEE RELATION', _relation3 ?? '', textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                Expanded(child: _buildReadOnlyField('NOMINEE DOB', _dob3 != null ? DateFormat('dd/MM/yyyy').format(_dob3!) : '-', textColor, subtitleColor, borderColor)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReadOnlyField('PERCENTAGE', _percent3.text.isNotEmpty ? '${_percent3.text}%' : '-', textColor, subtitleColor, borderColor)),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
      String label, String value, Color textColor, Color subtitleColor, Color borderColor) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: MyntWebTextStyles.body(context, color: textColor)
          .copyWith(decoration: TextDecoration.none),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: MyntWebTextStyles.caption(context,
            color: subtitleColor, fontWeight: MyntFonts.medium)
            .copyWith(decoration: TextDecoration.none, letterSpacing: 0.5),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ESIGN PENDING BANNER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEsignPendingBanner(Color primaryColor, Color errorColor) {
    final warningBg = resolveThemeColor(context,
        dark: const Color(0xFF3D2E00), light: const Color(0xFFFCEFD4));
    final warningText = resolveThemeColor(context,
        dark: const Color(0xFFFFD780), light: Colors.brown[800]!);
    final warningIcon = resolveThemeColor(context,
        dark: MyntColors.warningDark, light: MyntColors.warning);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: warningIcon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Esign Pending - Click here to complete',
              style: MyntWebTextStyles.bodySmall(context,
                  color: warningText, fontWeight: MyntFonts.medium)
                  .copyWith(decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(width: 8),
          _esignLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: primaryColor))
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openDigioEsign,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text('Click here E-sign',
                          style: MyntWebTextStyles.bodySmall(context,
                              color: primaryColor,
                              fontWeight: MyntFonts.semiBold)
                              .copyWith(decoration: TextDecoration.none)),
                    ),
                  ),
                ),
          const SizedBox(width: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showCancelConfirmation,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: Text('Cancel request',
                    style: MyntWebTextStyles.bodySmall(context,
                        color: errorColor,
                        fontWeight: MyntFonts.semiBold)
                        .copyWith(decoration: TextDecoration.none)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final errorColor = resolveThemeColor(context,
        dark: MyntColors.errorDark, light: MyntColors.error);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Cancel request?',
            style: MyntWebTextStyles.title(context,
                fontWeight: MyntFonts.semiBold,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary)
                .copyWith(decoration: TextDecoration.none)),
        content: RichText(
          text: TextSpan(
            style: MyntWebTextStyles.body(context, color: subtitleColor)
                .copyWith(decoration: TextDecoration.none),
            children: [
              const TextSpan(text: 'Are you sure you want to cancel your '),
              TextSpan(
                text: '"Nominee"',
                style: TextStyle(fontWeight: MyntFonts.semiBold, color: textColor),
              ),
              const TextSpan(text: ' request?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No',
                style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Proceed',
                style: MyntWebTextStyles.bodySmall(context,
                    color: Colors.white, fontWeight: MyntFonts.semiBold)
                    .copyWith(decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest() async {
    try {
      final provider = ref.read(profileAllDetailsProvider);
      final fileId = _fileId ?? '';
      final api = locator<ApiExporter>();
      final response = await api.cancelPendingStatusApi('nominee', fileId);
      if (mounted) {
        if (response == 'Cancel Success') {
          setState(() => _esignPending = false);
          successMessage(context, 'Esign Cancellation Success');
          provider.fetchNomineeStatus();
        } else {
          warningMessage(context, 'Esign Cancellation Failed');
        }
      }
    } catch (e) {
      if (mounted) {
        warningMessage(context, 'Something Went Wrong');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CHOICE SECTION
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildChoiceSection(
      Color primaryColor, Color textColor, Color subtitleColor, Color borderColor) {
    final isEdit = _hasExistingNominee;
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEdit ? 'What would you like to do?' : 'Get started',
          style: MyntWebTextStyles.bodySmall(context,
              color: subtitleColor, fontWeight: MyntFonts.medium)
              .copyWith(decoration: TextDecoration.none),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Primary action button
            _buildChoiceButton(
              icon: isEdit ? Icons.edit_outlined : Icons.shield_outlined,
              label: isEdit ? 'Edit your nominee' : 'Add Nominee',
              subtitle: isEdit ? 'Update nominee details' : 'Secure your account now',
              isSelected: _yesOrNo == 'yes',
              isPrimary: true,
              primaryColor: primaryColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              borderColor: borderColor,
              cardBg: cardBg,
              onTap: () {
                setState(() {
                  _yesOrNo = 'yes';
                  _activePanel = 0;
                });
              },
            ),
            const SizedBox(width: 12),
            // Secondary action button
            _buildChoiceButton(
              icon: Icons.schedule_outlined,
              label: 'Skip for now',
              subtitle: 'I\'ll do it later',
              isSelected: _yesOrNo == 'no',
              isPrimary: false,
              primaryColor: primaryColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              borderColor: borderColor,
              cardBg: cardBg,
              onTap: () {
                setState(() {
                  _yesOrNo = 'no';
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required bool isPrimary,
    required Color primaryColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isPrimary ? primaryColor.withValues(alpha: 0.06) : cardBg)
                : cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryColor : borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.1)
                      : subtitleColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    size: 18,
                    color: isSelected ? primaryColor : subtitleColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: MyntWebTextStyles.bodySmall(context,
                            color: isSelected ? primaryColor : textColor,
                            fontWeight: MyntFonts.semiBold)
                            .copyWith(decoration: TextDecoration.none)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: MyntWebTextStyles.caption(context,
                            color: subtitleColor,
                            fontWeight: MyntFonts.regular)
                            .copyWith(decoration: TextDecoration.none)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NOMINEE FORM
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNomineeForm(
      Color textColor, Color subtitleColor, Color borderColor,
      Color cardBg, Color primaryColor, Color dividerColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nominee tabs (1st, 2nd, 3rd)
          _buildNomineeTabs(primaryColor, subtitleColor, borderColor),
          const SizedBox(height: 16),

          // Active nominee panel form
          if (_activePanel == 0)
            _buildSingleNomineeForm(
              1, _name1, _percent1, _dob1, (d) => setState(() => _dob1 = d),
              _relation1, (r) => setState(() => _relation1 = r),
              _sameAddress1, (v) => setState(() => _sameAddress1 = v),
              _address1, _city1, _state1, _country1, _pincode1,
              _mobile1, _email1, _proofType1,
              (t) => setState(() => _proofType1 = t), _proofValue1,
              _guardianName1, _guardianDob1,
              (d) => setState(() => _guardianDob1 = d),
              _guardianRelation1,
              (r) => setState(() => _guardianRelation1 = r),
              _guardianMobile1,
              textColor, subtitleColor, borderColor, primaryColor,
            ),
          if (_activePanel == 1 && _nomineeCount >= 2)
            _buildSingleNomineeForm(
              2, _name2, _percent2, _dob2, (d) => setState(() => _dob2 = d),
              _relation2, (r) => setState(() => _relation2 = r),
              _sameAddress2, (v) => setState(() => _sameAddress2 = v),
              _address2, _city2, _state2, _country2, _pincode2,
              _mobile2, _email2, _proofType2,
              (t) => setState(() => _proofType2 = t), _proofValue2,
              _guardianName2, _guardianDob2,
              (d) => setState(() => _guardianDob2 = d),
              _guardianRelation2,
              (r) => setState(() => _guardianRelation2 = r),
              _guardianMobile2,
              textColor, subtitleColor, borderColor, primaryColor,
            ),
          if (_activePanel == 2 && _nomineeCount >= 3)
            _buildSingleNomineeForm(
              3, _name3, _percent3, _dob3, (d) => setState(() => _dob3 = d),
              _relation3, (r) => setState(() => _relation3 = r),
              _sameAddress3, (v) => setState(() => _sameAddress3 = v),
              _address3, _city3, _state3, _country3, _pincode3,
              _mobile3, _email3, _proofType3,
              (t) => setState(() => _proofType3 = t), _proofValue3,
              _guardianName3, _guardianDob3,
              (d) => setState(() => _guardianDob3 = d),
              _guardianRelation3,
              (r) => setState(() => _guardianRelation3 = r),
              _guardianMobile3,
              textColor, subtitleColor, borderColor, primaryColor,
            ),

          const SizedBox(height: 24),

          // Add nominee buttons + Continue
          _buildActionButtons(primaryColor, subtitleColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildNomineeTabs(Color primaryColor, Color subtitleColor, Color borderColor) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_activePanel == 0) ...[
                const Icon(Icons.check, size: 16, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text('1st nominee'),
            ],
          ),
          selected: _activePanel == 0,
          showCheckmark: false,
          onSelected: (_) => setState(() => _activePanel = 0),
          selectedColor: resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary)  ,
          labelStyle: MyntWebTextStyles.bodySmall(context,
              color: _activePanel == 0 ? Colors.white : subtitleColor,
              fontWeight: MyntFonts.medium)
              .copyWith(decoration: TextDecoration.none),
          backgroundColor: Colors.transparent,
          shape: StadiumBorder(
              side: BorderSide(
                  color: _activePanel == 0 ? resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary)   : borderColor)),
        ),
        if (_nomineeCount >= 2)
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activePanel == 1) ...[
                  const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text('2nd nominee'),
                if (_nomineeCount >= 2 && _nomineeCount < 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: InkWell(
                      onTap: () => setState(() {
                        _nomineeCount = 1;
                        _activePanel = 0;
                        _clearNominee2();
                      }),
                      child: Icon(Icons.backspace_outlined,
                          size: 14,
                          color: _activePanel == 1
                              ? Colors.white
                              : subtitleColor),
                    ),
                  ),
              ],
            ),
            selected: _activePanel == 1,
            showCheckmark: false,
            onSelected: (_) => setState(() => _activePanel = 1),
            selectedColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
            labelStyle: MyntWebTextStyles.bodySmall(context,
                color: _activePanel == 1 ? Colors.white : subtitleColor,
                fontWeight: MyntFonts.medium)
                .copyWith(decoration: TextDecoration.none),
            backgroundColor: Colors.transparent,
            shape: StadiumBorder(
                side: BorderSide(
                    color: _activePanel == 1 ? primaryColor : borderColor)),
          ),
        if (_nomineeCount >= 3)
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activePanel == 2) ...[
                  const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text('3rd nominee'),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: InkWell(
                    onTap: () => setState(() {
                      _nomineeCount = 2;
                      _activePanel = 1;
                      _clearNominee3();
                    }),
                    child: Icon(Icons.backspace_outlined,
                        size: 14,
                        color: _activePanel == 2
                            ? Colors.white
                            : subtitleColor),
                  ),
                ),
              ],
            ),
            selected: _activePanel == 2,
            showCheckmark: false,
            onSelected: (_) => setState(() => _activePanel = 2),
            selectedColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
            labelStyle: MyntWebTextStyles.bodySmall(context,
                color: _activePanel == 2 ? Colors.white : subtitleColor,
                fontWeight: MyntFonts.medium)
                .copyWith(decoration: TextDecoration.none),
            backgroundColor: Colors.transparent,
            shape: StadiumBorder(
                side: BorderSide(
                    color: _activePanel == 2 ? primaryColor : borderColor)),
          ),
      ],
    );
  }

  void _clearNominee2() {
    _name2.clear();
    _percent2.clear();
    _dob2 = null;
    _relation2 = null;
    _address2.clear();
    _city2.clear();
    _state2.clear();
    _pincode2.clear();
    _mobile2.clear();
    _email2.clear();
    _proofType2 = null;
    _proofValue2.clear();
    _percent1.text = '100';
  }

  void _clearNominee3() {
    _name3.clear();
    _percent3.clear();
    _dob3 = null;
    _relation3 = null;
    _address3.clear();
    _city3.clear();
    _state3.clear();
    _pincode3.clear();
    _mobile3.clear();
    _email3.clear();
    _proofType3 = null;
    _proofValue3.clear();
  }

  Widget _buildActionButtons(Color primaryColor, Color subtitleColor, Color borderColor) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // + Add 2nd Nominee
        if (_nomineeCount < 2)
          OutlinedButton(
            onPressed: () => setState(() {
              _nomineeCount = 2;
              _activePanel = 1;
              _percent1.text = '50';
              _percent2.text = '50';
            }),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('+ Add 2nd Nominee',
                style: MyntWebTextStyles.bodySmall(context,
                    color: primaryColor, fontWeight: MyntFonts.semiBold)
                    .copyWith(decoration: TextDecoration.none)),
          ),

        // + Add 3rd Nominee
        if (_nomineeCount == 2)
          OutlinedButton(
            onPressed: () => setState(() {
              _nomineeCount = 3;
              _activePanel = 2;
            }),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('+ Add 3rd Nominee',
                style: MyntWebTextStyles.bodySmall(context,
                    color: primaryColor, fontWeight: MyntFonts.semiBold)
                    .copyWith(decoration: TextDecoration.none)),
          ),

        // Continue button
        ElevatedButton(
          onPressed: _loading ? null : _submitNominee,
          style: ElevatedButton.styleFrom(
            backgroundColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Continue',
                  style: MyntWebTextStyles.bodySmall(context,
                      color: Colors.white, fontWeight: MyntFonts.semiBold)
                      .copyWith(decoration: TextDecoration.none)),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SINGLE NOMINEE FORM
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSingleNomineeForm(
    int index,
    TextEditingController nameCtrl,
    TextEditingController percentCtrl,
    DateTime? dob,
    ValueChanged<DateTime?> onDobChanged,
    String? relation,
    ValueChanged<String?> onRelationChanged,
    bool sameAddress,
    ValueChanged<bool> onSameAddressChanged,
    TextEditingController addressCtrl,
    TextEditingController cityCtrl,
    TextEditingController stateCtrl,
    TextEditingController countryCtrl,
    TextEditingController pincodeCtrl,
    TextEditingController mobileCtrl,
    TextEditingController emailCtrl,
    String? proofType,
    ValueChanged<String?> onProofTypeChanged,
    TextEditingController proofValueCtrl,
    TextEditingController guardianNameCtrl,
    DateTime? guardianDob,
    ValueChanged<DateTime?> onGuardianDobChanged,
    String? guardianRelation,
    ValueChanged<String?> onGuardianRelationChanged,
    TextEditingController guardianMobileCtrl,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Name + DOB + Percentage
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                'Nominee name *',
                nameCtrl,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                validator: _requiredValidator,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                'Date of birth *',
                dob,
                onDobChanged,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                helperText: '(Minor info displayed on DOB)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Percentage *',
                percentCtrl,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _requiredValidator,
                suffixIcon: Icon(Icons.percent, size: 16, color: subtitleColor),
                enabled: _nomineeCount > 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Relationship + Mobile + Email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(
                'Relationship *',
                relation,
                _relations,
                onRelationChanged,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Mobile number *',
                mobileCtrl,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                    return 'Enter valid 10-digit number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Email *',
                emailCtrl,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(v)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Proof type + Proof value + (empty spacer)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(
                'Identity proof type *',
                proofType,
                _proofTypes,
                onProofTypeChanged,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                proofType == 'PAN Number'
                    ? 'PAN Number *'
                    : proofType == 'Aadhaar number(last 4 digits)'
                        ? 'Aadhaar (last 4 digits) *'
                        : 'Proof Number *',
                proofValueCtrl,
                textColor,
                subtitleColor,
                borderColor,
                primaryColor,
                textCapitalization: proofType == 'PAN Number'
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (proofType == 'PAN Number') {
                    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)) {
                      return 'Enter valid PAN (e.g., ABCDE1234F)';
                    }
                  } else if (proofType == 'Aadhaar number(last 4 digits)') {
                    if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                      return 'Enter last 4 digits';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 12),

        // Same address checkbox
        Row(
          children: [
            Checkbox(
              value: sameAddress,
              onChanged: (v) => onSameAddressChanged(v ?? false),
              activeColor: primaryColor,
            ),
            Text('Nominee address is same as my address',
                style: MyntWebTextStyles.bodySmall(context,
                    color: textColor, fontWeight: MyntFonts.regular)
                    .copyWith(decoration: TextDecoration.none)),
          ],
        ),

        // Address fields (hidden if same address)
        if (!sameAddress) ...[
          const SizedBox(height: 8),
          _buildTextField('Address *', addressCtrl, textColor, subtitleColor,
              borderColor, primaryColor,
              validator: _requiredValidator),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildTextField(
                      'Pincode *', pincodeCtrl, textColor, subtitleColor,
                      borderColor, primaryColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _requiredValidator)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                      'City *', cityCtrl, textColor, subtitleColor,
                      borderColor, primaryColor,
                      validator: _requiredValidator)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                      'State *', stateCtrl, textColor, subtitleColor,
                      borderColor, primaryColor,
                      validator: _requiredValidator)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildTextField(
                      'Country *', countryCtrl, textColor, subtitleColor,
                      borderColor, primaryColor,
                      validator: _requiredValidator)),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],

        // Guardian section (if minor)
        if (_isMinor(dob)) ...[
          const SizedBox(height: 24),
          Text('Guardian Details',
              style: MyntWebTextStyles.title(context,
                  fontWeight: MyntFonts.semiBold,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary)
                  .copyWith(decoration: TextDecoration.none)),
          const SizedBox(height: 4),
          Text('Nominee is under 18. Guardian details are required.',
              style: MyntWebTextStyles.caption(context,
                  color: subtitleColor)
                  .copyWith(decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField('Guardian name *', guardianNameCtrl,
                    textColor, subtitleColor, borderColor, primaryColor,
                    validator: _requiredValidator,
                    textCapitalization: TextCapitalization.characters),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  'Guardian DOB *',
                  guardianDob,
                  onGuardianDobChanged,
                  textColor,
                  subtitleColor,
                  borderColor,
                  primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Guardian relationship *',
                  guardianRelation,
                  _relations,
                  onGuardianRelationChanged,
                  textColor,
                  subtitleColor,
                  borderColor,
                  primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  'Guardian mobile *',
                  guardianMobileCtrl,
                  textColor,
                  subtitleColor,
                  borderColor,
                  primaryColor,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                      return 'Enter valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  FORM FIELD BUILDERS
  // ═══════════════════════════════════════════════════════════════════

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primaryColor, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: MyntWebTextStyles.bodySmall(context,
                color: textColor, fontWeight: MyntFonts.medium)
                .copyWith(decoration: TextDecoration.none)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: enabled ? validator : null,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          enabled: enabled,
          style: MyntWebTextStyles.body(context,
              color: enabled ? textColor : textColor.withValues(alpha: 0.5))
              .copyWith(decoration: TextDecoration.none),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: resolveThemeColor(context,
                  dark: MyntColors.errorDark, light: MyntColors.error)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primaryColor, {
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: label,
                  style: MyntWebTextStyles.bodySmall(context,
                      color: textColor, fontWeight: MyntFonts.medium)
                      .copyWith(decoration: TextDecoration.none)),
              if (helperText != null)
                TextSpan(
                    text: ' $helperText',
                    style: MyntWebTextStyles.caption(context,
                        color: subtitleColor)
                        .copyWith(decoration: TextDecoration.none, fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(2000),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: subtitleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('yyyy-MM-dd').format(value)
                        : 'DOB',
                    style: MyntWebTextStyles.body(context,
                        color: value != null ? textColor : subtitleColor)
                        .copyWith(decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primaryColor,
  ) {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: MyntWebTextStyles.bodySmall(context,
                color: textColor, fontWeight: MyntFonts.medium)
                .copyWith(decoration: TextDecoration.none)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value != null && items.contains(value) ? value : null,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: MyntWebTextStyles.body(context, color: textColor)
                            .copyWith(decoration: TextDecoration.none)),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          dropdownColor: cardBg,
        ),
      ],
    );
  }
}
