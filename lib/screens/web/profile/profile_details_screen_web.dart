import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mynt_plus/models/client_profile_all_details/profile_all_details_model.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:mynt_plus/utils/digio_esign.dart';

class ProfileDetailsScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  /// Digilocker callback params (from same-window redirect)
  final String? digilockerCode;
  final String? digilockerState;

  const ProfileDetailsScreenWeb({
    super.key,
    this.onBack,
    this.digilockerCode,
    this.digilockerState,
  });

  @override
  ConsumerState<ProfileDetailsScreenWeb> createState() =>
      _ProfileDetailsScreenWebState();
}

class _ProfileDetailsScreenWebState
    extends ConsumerState<ProfileDetailsScreenWeb> {
  bool _mobileEsignLoading = false;
  bool _emailEsignLoading = false;
  bool _addressEsignLoading = false;
  bool _cancelLoading = false;
  bool _kraProcessLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
      ref.read(profileAllDetailsProvider).fetchPendingstatus();
      ref.read(profileAllDetailsProvider).fetchMobEmailStatus();

      // Auto-trigger Digilocker address change if callback params present
      _checkDigilockerCallback();
    });
  }

  /// Check if we returned from Digilocker OAuth redirect with code/state params.
  /// If so, clear URL params and trigger the address change flow automatically.
  Future<void> _checkDigilockerCallback() async {
    final code = widget.digilockerCode;
    final state = widget.digilockerState;
    if (code != null && code.isNotEmpty && state != null && state.isNotEmpty) {
      // Clear code/state from URL so refresh doesn't re-trigger
      clearDigilockerCallbackParams();
      setState(() => _kraProcessLoading = true);
      await _handleDigilockerAddressChange(code, state);
    }
  }

  /// Navigate same window to Digilocker OAuth (like Vue: window.location.href = url)
  void _launchDigilockerFlow() {
    launchDigilockerAuth();
  }

  Future<void> _handleDigilockerAddressChange(String code, String state) async {
    final provider = ref.read(profileAllDetailsProvider);

    // Step 1: KRA image check
    final kraResult = await provider.kraImageCheck();
    if (kraResult != 'image found') {
      if (!mounted) return;
      setState(() => _kraProcessLoading = false);
      final selfieBytes = await showDialog<List<int>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _KraSelfieDialog(
          isDarkMode: ref.read(themeProvider).isDarkMode,
        ),
      );
      if (selfieBytes == null || selfieBytes.isEmpty) {
        return;
      }
      setState(() => _kraProcessLoading = true);
      final uploadResult =
          await provider.uploadKraSelfie(imageBytes: selfieBytes);
      if (uploadResult != 'image saved') {
        if (mounted) {
          setState(() => _kraProcessLoading = false);
          warningMessage(context, uploadResult ?? 'Image upload failed');
        }
        return;
      }
    }

    // Step 2: Submit Digilocker address change
    final result = await provider.addressChangeDigilocker(
      code: code,
      state: state,
    );

    if (mounted) setState(() => _kraProcessLoading = false);

    if (result != null && result['fileid'] != null) {
      // Fetch status and show esign dialog
      await provider.fetchMobEmailStatus();
      if (mounted) _showEsignPendingDialog('address');
    } else if (mounted) {
      warningMessage(context, 'Error in Server, please try again later');
    }
  }

  // ─── Digio Inline E-Sign ───
  Future<void> _openDigioEsign({
    required String fileId,
    required String email,
    required String session,
    required String type,
  }) async {
    final provider = ref.read(profileAllDetailsProvider);

    if (fileId.isEmpty || email.isEmpty) {
      warningMessage(context, 'E-Sign details not available');
      return;
    }

    setState(() {
      if (type == 'mobile_change') _mobileEsignLoading = true;
      if (type == 'email_change') _emailEsignLoading = true;
      if (type == 'address_change') _addressEsignLoading = true;
    });

    try {
      final result = await startDigioEsign(
        fileId: fileId,
        email: email,
        session: session,
      );

      if (fileId.isNotEmpty) {
        provider.reportFiledownload(
          fileId: fileId,
          response: result,
          type: type,
        );
      }

      provider.fetchClientProfileAllDetails();
      provider.fetchMobEmailStatus();
      provider.fetchPendingstatus();

      if (mounted) {
        if (result == 'success') {
          successMessage(context, 'E-Sign completed successfully');
        } else {
          warningMessage(context, 'E-Sign was cancelled');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _mobileEsignLoading = false;
          _emailEsignLoading = false;
          _addressEsignLoading = false;
        });
      }
    }
  }

  // ─── Cancel Request ───
  Future<void> _cancelRequest(String type) async {
    final provider = ref.read(profileAllDetailsProvider);
    setState(() => _cancelLoading = true);
    try {
      provider.cancelPendingloader(true);
      final fileid = await provider.api.fetctfileidapi(type);
      final response =
          await provider.api.cancelPendingStatusApi(type, fileid ?? '');
      if (response == 'Cancel Success') {
        await provider.fetchMobEmailStatus();
        await provider.fetchPendingstatus();
        if (mounted) successMessage(context, 'Cancellation Success');
      } else {
        if (mounted) warningMessage(context, 'Cancellation Failed');
      }
    } catch (e) {
      if (mounted) warningMessage(context, 'Something Went Wrong');
    } finally {
      provider.cancelPendingloader(false);
      if (mounted) setState(() => _cancelLoading = false);
    }
  }

  // ─── Cancel Request Confirmation Dialog ───
  void _showCancelRequestDialog(String type, String displayName) {
    final themeVal = ref.read(themeProvider);
    final isDark = themeVal.isDarkMode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cancel request?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close,
                          size: 20,
                          color: isDark
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to cancel your "$displayName" request?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cancelRequest(type);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Proceed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── E-Sign Pending Confirmation Dialog (after OTP verify) ───
  void _showEsignPendingDialog(String type) {
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    String displayName = '';
    if (type == 'mobile') {
      displayName = 'Mobile';
    } else if (type == 'email') {
      displayName = 'Email';
    } else if (type == 'address') {
      displayName = 'Address';
    } else if (type == 'income') {
      displayName = 'Income';
    }

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
              Text('Your $displayName Change request is not yet Completed.',
                  style: MyntWebTextStyles.bodySmall(context,
                      fontWeight: MyntFonts.medium, color: textColor)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final freshStatus = ref.read(profileAllDetailsProvider).mobEmailStatus;
                    String fId = '';
                    String em = '';
                    String sess = '';
                    if (type == 'mobile') {
                      fId = freshStatus?.mobileFileId ?? '';
                      em = (freshStatus?.mobClientEmail ?? '').toUpperCase();
                      sess = freshStatus?.mobSession ?? '';
                    } else if (type == 'email') {
                      fId = freshStatus?.emailFileId ?? '';
                      em = (freshStatus?.emailNewEmailId ?? '').toLowerCase();
                      sess = freshStatus?.emailSession ?? '';
                    } else if (type == 'address') {
                      fId = freshStatus?.addressFileId ?? '';
                      em = (freshStatus?.addressClientEmail ?? '').toLowerCase();
                      sess = freshStatus?.addressSession ?? '';
                    }
                    _openDigioEsign(fileId: fId, email: em, session: sess, type: '${type}_change');
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

  // ─── KRA Image Check + File Write Flow ───
  Future<void> _handleKraCheckAndProceed(String type) async {
    final profileProvider = ref.read(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;

    setState(() => _kraProcessLoading = true);

    try {
      // Step 1: Check KRA image
      final kraResult = await profileProvider.kraImageCheck();

      if (kraResult == 'image found') {
        // Step 2a: Image exists → proceed with file write
        await _proceedFileWrite(type, profileProvider, clientData!);
      } else {
        // Step 2b: No image → hide loader, show selfie capture dialog
        if (!mounted) return;
        setState(() => _kraProcessLoading = false);
        final selfieBytes = await showDialog<List<int>>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _KraSelfieDialog(
            isDarkMode: ref.read(themeProvider).isDarkMode,
          ),
        );
        if (selfieBytes != null && selfieBytes.isNotEmpty) {
          if (!mounted) return;
          setState(() => _kraProcessLoading = true);
          // Step 3: Upload selfie
          final uploadResult =
              await profileProvider.uploadKraSelfie(imageBytes: selfieBytes);
          if (uploadResult == 'image saved') {
            // Step 4: Proceed with file write
            if (!mounted) return;
            await _proceedFileWrite(type, profileProvider, clientData!);
          } else {
            if (mounted) {
              warningMessage(context, uploadResult ?? 'Image upload failed');
            }
          }
        }
      }
    } finally {
      if (mounted) setState(() => _kraProcessLoading = false);
    }
  }

  Future<void> _proceedFileWrite(
      String type, ProfileProvider profileProvider, ClientData clientData) async {
    Map<String, dynamic>? result;
    if (type == 'mobile') {
      result = await profileProvider.mobileFileWriteWeb(
        profileProvider.newMobController.text,
        clientData,
      );
    } else if (type == 'email') {
      result = await profileProvider.emailFileWriteWeb(
        profileProvider.newEmailController.text,
        clientData.cLIENTIDMAIL ?? '',
        clientData.cLIENTDPCODE ?? '',
      );
    } else if (type == 'address') {
      // Address already submitted via addressChangeWeb; just refresh + show esign
      await profileProvider.fetchMobEmailStatus();
      if (mounted) _showEsignPendingDialog(type);
      return;
    }

    if (result != null && result['fileid'] != null) {
      await profileProvider.fetchMobEmailStatus();
      if (mounted) _showEsignPendingDialog(type);
    } else {
      if (mounted) {
        warningMessage(
            context, result?['msg']?.toString() ?? 'Request failed');
      }
    }
  }

  // ─── Email Change Dialog ───
  void _showEmailChangeDialog() {
    final profileProvider = ref.read(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;
    profileProvider.newEmailController.clear();
    profileProvider.newEmailOTPController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _EmailChangeDialog(
          profileProvider: profileProvider,
          clientData: clientData!,
          onEsign: () {
            Navigator.of(ctx).pop();
            _handleKraCheckAndProceed('email');
          },
        );
      },
    );
  }

  // ─── Mobile Change Dialog ───
  void _showMobileChangeDialog() {
    final profileProvider = ref.read(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;
    profileProvider.newMobController.clear();
    profileProvider.newMobOTPController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _MobileChangeDialog(
          profileProvider: profileProvider,
          clientData: clientData!,
          onEsign: () {
            Navigator.of(ctx).pop();
            _handleKraCheckAndProceed('mobile');
          },
        );
      },
    );
  }

  // ─── Address Change Dialog ───
  void _showAddressChangeDialog() {
    final profileProvider = ref.read(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;
    final themeVal = ref.watch(themeProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _AddressChangeDialog(
          profileProvider: profileProvider,
          clientData: clientData!,
          isDarkMode: themeVal.isDarkMode,
          onDone: () {
            Navigator.of(ctx).pop();
            // Refresh to get esign details then show esign pending dialog
            profileProvider.fetchMobEmailStatus().then((_) {
              _showEsignPendingDialog('address');
            });
          },
          onAadhaarTap: () {
            // Dialog is already popped in the button handler
            _launchDigilockerFlow();
          },
        );
      },
    );
  }

  // ─── Income Change Dialog ───
  void _showIncomeChangeDialog() {
    final profileProvider = ref.read(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;
    final themeVal = ref.watch(themeProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _IncomeChangeDialog(
          profileProvider: profileProvider,
          clientData: clientData!,
          isDarkMode: themeVal.isDarkMode,
          onDone: () {
            Navigator.of(ctx).pop();
            // Refresh data after income change
            profileProvider.fetchClientProfileAllDetails();
            profileProvider.fetchMobEmailStatus();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = ref.watch(profileAllDetailsProvider);
    final clientData = profileProvider.clientAllDetails.clientData;

    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final cardBorder = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);

    return Stack(
      children: [
        Scaffold(
      backgroundColor: Colors.transparent,
      body: clientData == null
          ? const Center(child: MyntLoader())
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Page Title with back ---
                  Row(
                    children: [
                      CustomBackBtn(onBack: widget.onBack),
                      const SizedBox(width: 4),
                      Text(
                        "Profile Details",
                        style: MyntWebTextStyles.title(context,
                          color: textColor, fontWeight: MyntFonts.semiBold,
                        ).copyWith(decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Personal Information ---
                  _buildPersonalInfoSection(clientData, profileProvider, cardBg,
                      cardBorder, textColor, subtitleColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    ),
        // Loading overlay
        if (_kraProcessLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0037B7),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  USER HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUserHeader(ClientData clientData, Color textColor,
      Color subtitleColor, Color cardBg, Color cardBorder) {
    final profileImage = ref.watch(userProfileProvider).getprofileImage;
    final initial = (clientData.panName != null && clientData.panName!.isNotEmpty)
        ? clientData.panName![0]
        : "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          // Profile image or initial
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resolveThemeColor(context,
                dark: MyntColors.cardHoverDark,
                light: MyntColors.cardHover),
              border: Border.all(
                color: resolveThemeColor(context,
                  dark: MyntColors.cardBorderDark,
                  light: MyntColors.cardBorder),
                width: 2,
              ),
              image: profileImage != null
                  ? DecorationImage(
                      image: MemoryImage(profileImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileImage == null
                ? Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Name, UCC, PAN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientData.panName ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: MyntWebTextStyles.title(context,
                    color: textColor, fontWeight: MyntFonts.semiBold,
                  ).copyWith(decoration: TextDecoration.none),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoChip("UCC: ${clientData.cLIENTID ?? ''}"),
                    const SizedBox(width: 8),
                    _buildInfoChip("PAN: ${clientData.pANNO ?? ''}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
          dark: MyntColors.cardHoverDark,
          light: MyntColors.cardHover),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: MyntWebTextStyles.caption(context,
          darkColor: MyntColors.textSecondaryDark,
          lightColor: MyntColors.textSecondary,
          fontWeight: MyntFonts.medium,
        ).copyWith(decoration: TextDecoration.none),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PENDING STATUS SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPendingStatusSection(ProfileProvider profileProvider,
      Color textColor, Color subtitleColor, Color cardBg, Color dividerColor) {
    if (profileProvider.pendingStatusList.isEmpty ||
        profileProvider.pendingStatusList[0].data == null ||
        profileProvider.pendingStatusList[0].data!.isEmpty) {
      return const SizedBox.shrink();
    }

    final pendingStatuses = profileProvider.pendingStatusList[0].data!;

    final warningBg = resolveThemeColor(context,
        dark: const Color(0xFF3D2E00), light: const Color(0xFFFCEFD4));
    final warningText = resolveThemeColor(context,
        dark: const Color(0xFFFFD780), light: Colors.brown[800]!);
    final warningIcon = resolveThemeColor(context,
        dark: MyntColors.warningDark, light: MyntColors.warning);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final errorColor = resolveThemeColor(context,
        dark: MyntColors.errorDark, light: MyntColors.error);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    var mobStatus = profileProvider.mobEmailStatus;
                    if (mobStatus == null ||
                        ((mobStatus.emailFileId ?? '').isEmpty &&
                            (mobStatus.mobileFileId ?? '').isEmpty &&
                            (mobStatus.addressFileId ?? '').isEmpty)) {
                      await profileProvider.fetchMobEmailStatus();
                      mobStatus = profileProvider.mobEmailStatus;
                    }
                    if (!mounted) return;
                    if (pendingStatuses
                        .any((s) => s == 'email_change_pending')) {
                      _openDigioEsign(
                        fileId: mobStatus?.emailFileId ?? '',
                        email: (mobStatus?.emailNewEmailId ?? '').toLowerCase(),
                        session: mobStatus?.emailSession ?? '',
                        type: 'email_change',
                      );
                    } else if (pendingStatuses
                        .any((s) => s == 'mobile_change_pending')) {
                      _openDigioEsign(
                        fileId: mobStatus?.mobileFileId ?? '',
                        email: (mobStatus?.mobClientEmail ?? '').toUpperCase(),
                        session: mobStatus?.mobSession ?? '',
                        type: 'mobile_change',
                      );
                    } else if (pendingStatuses
                        .any((s) => s == 'address_change_pending')) {
                      _openDigioEsign(
                        fileId: mobStatus?.addressFileId ?? '',
                        email:
                            (mobStatus?.addressClientEmail ?? '').toLowerCase(),
                        session: mobStatus?.addressSession ?? '',
                        type: 'address_change',
                      );
                    }
                  },
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
                  onTap: () => _showCancelRequestDialog(
                      'pending_status', 'Pending E-Sign'),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pendingStatuses.map((status) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: warningIcon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: warningIcon.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _getPendingDisplayName(status),
                  style: MyntWebTextStyles.caption(context,
                          color: warningText,
                          fontWeight: MyntFonts.semiBold)
                      .copyWith(decoration: TextDecoration.none),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getPendingDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'email_change_pending':
        return 'Email Change';
      case 'mobile_change_pending':
        return 'Mobile Change';
      case 'address_change_pending':
        return 'Address Change';
      case 'bank_change_pending':
        return 'Bank Change';
      case 'ddpicre_pending':
        return 'DDPI';
      case 'mtf_pending':
        return 'MTF';
      case 'closure_pending':
        return 'Account Closure';
      case 'nominee_pending':
        return 'Nominee';
      case 'segments_change_pending':
        return 'Segments Change';
      case 'income_change_pending':
        return 'Income Change';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  PERSONAL INFO SECTION (with inline edit buttons)
  // ═══════════════════════════════════════════════════════════════
  // ─── Status Banner Widget ───
  Widget _buildStatusBanner({
    required String status,
    required String label,
    required String esignType,
    required String cancelType,
    required String fileId,
    required String email,
    required String session,
    required bool esignLoading,
  }) {
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final errorColor = resolveThemeColor(context,
        dark: MyntColors.errorDark, light: MyntColors.error);
    final warningBg = resolveThemeColor(context,
        dark: const Color(0xFF3D2E00), light: const Color(0xFFFCEFD4));
    final warningText = resolveThemeColor(context,
        dark: const Color(0xFFFFD780), light: Colors.brown[800]!);
    final warningIcon = resolveThemeColor(context,
        dark: MyntColors.warningDark, light: MyntColors.warning);
    final successBg = resolveThemeColor(context,
        dark: const Color(0xFF0A3D1E), light: const Color(0xFFE6F9ED));
    final successText = resolveThemeColor(context,
        dark: MyntColors.successDark, light: MyntColors.success);

    if (status == 'e-signed pending') {
      return Container(
        margin: const EdgeInsets.only(top: 10),
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
            esignLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primaryColor))
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final provider = ref.read(profileAllDetailsProvider);
                        if (fileId.isEmpty || email.isEmpty) {
                          await provider.fetchMobEmailStatus();
                          if (!mounted) return;
                          final fresh = provider.mobEmailStatus;
                          String fId = '';
                          String em = '';
                          String sess = '';
                          if (esignType == 'mobile_change') {
                            fId = fresh?.mobileFileId ?? '';
                            em = (fresh?.mobClientEmail ?? '').toUpperCase();
                            sess = fresh?.mobSession ?? '';
                          } else if (esignType == 'email_change') {
                            fId = fresh?.emailFileId ?? '';
                            em = (fresh?.emailNewEmailId ?? '').toLowerCase();
                            sess = fresh?.emailSession ?? '';
                          } else if (esignType == 'address_change') {
                            fId = fresh?.addressFileId ?? '';
                            em = (fresh?.addressClientEmail ?? '').toLowerCase();
                            sess = fresh?.addressSession ?? '';
                          }
                          _openDigioEsign(fileId: fId, email: em, session: sess, type: esignType);
                        } else {
                          _openDigioEsign(fileId: fileId, email: email, session: session, type: esignType);
                        }
                      },
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
            _cancelLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: errorColor))
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _showCancelRequestDialog(cancelType, '$label Change'),
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
    } else if (status == 'e-signed completed') {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: successBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded, size: 20, color: successText),
            const SizedBox(width: 12),
            Text(
              "$label change in process",
              style: MyntWebTextStyles.bodySmall(context,
                color: successText,
                fontWeight: MyntFonts.medium,
              ).copyWith(decoration: TextDecoration.none),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPersonalInfoSection(
      ClientData clientData,
      ProfileProvider profileProvider,
      Color cardBg,
      Color cardBorder,
      Color textColor,
      Color subtitleColor) {
    final mobStatus = profileProvider.mobEmailStatus;
    final mobileStatus = mobStatus?.mobileStatus ?? '';
    final emailStatus = mobStatus?.emailStatus ?? '';
    final addressStatus = mobStatus?.addressStatus ?? '';
    final incomeStatus = mobStatus?.incomeStatus ?? '';
    final mobilePendingOrDone =
        mobileStatus == 'e-signed pending' || mobileStatus == 'e-signed completed';
    final emailPendingOrDone =
        emailStatus == 'e-signed pending' || emailStatus == 'e-signed completed';
    final addressPendingOrDone =
        addressStatus == 'e-signed pending' || addressStatus == 'e-signed completed';

    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    // Build list of field data
    final fields = <_FlatFieldData>[
      _FlatFieldData(
        label: "Name as per PAN",
        value: clientData.panName ?? "N/A",
      ),
      _FlatFieldData(
        label: "Birth Date",
        value: clientData.bIRTHDATE ?? "N/A",
      ),
      _FlatFieldData(
        label: "Marital Status",
        value: clientData.maritalStatus ?? "N/A",
      ),
      _FlatFieldData(
        label: "PAN Number",
        value: profileProvider.formateDataToDisplay(
            clientData.pANNO ?? "", 0, 3),
      ),
      _FlatFieldData(
        label: "Email",
        value: clientData.cLIENTIDMAIL ?? "N/A",
        onEdit: emailPendingOrDone ? null : _showEmailChangeDialog,
        statusBanner: _buildStatusBanner(
          status: emailStatus,
          label: 'Email',
          esignType: 'email_change',
          cancelType: 'email_change',
          fileId: mobStatus?.emailFileId ?? '',
          email: (mobStatus?.emailNewEmailId ?? '').toLowerCase(),
          session: mobStatus?.emailSession ?? '',
          esignLoading: _emailEsignLoading,
        ),
      ),
      _FlatFieldData(
        label: "Mobile",
        value: clientData.mOBILENO ?? "N/A",
        onEdit: mobilePendingOrDone ? null : _showMobileChangeDialog,
        statusBanner: _buildStatusBanner(
          status: mobileStatus,
          label: 'Mobile',
          esignType: 'mobile_change',
          cancelType: 'mobile_change',
          fileId: mobStatus?.mobileFileId ?? '',
          email: (mobStatus?.mobClientEmail ?? '').toUpperCase(),
          session: mobStatus?.mobSession ?? '',
          esignLoading: _mobileEsignLoading,
        ),
      ),
      _FlatFieldData(
        label: "Address",
        value: "${clientData.cLRESIADD1 ?? ''}  ${clientData.cLRESIADD2 ?? ''}  ${clientData.cLRESIADD3 ?? ''}"
            .toUpperCase(),
        onEdit: addressPendingOrDone ? null : _showAddressChangeDialog,
        statusBanner: _buildStatusBanner(
          status: addressStatus,
          label: 'Address',
          esignType: 'address_change',
          cancelType: 'address_change',
          fileId: mobStatus?.addressFileId ?? '',
          email: (mobStatus?.addressClientEmail ?? '').toLowerCase(),
          session: mobStatus?.addressSession ?? '',
          esignLoading: _addressEsignLoading,
        ),
      ),
      _FlatFieldData(
        label: "Annual Income",
        value: clientData.aNNUALINCOME ?? "N/A",
        onEdit: (incomeStatus == 'e-signed completed' || incomeStatus == 'e-signed pending')
            ? null
            : _showIncomeChangeDialog,
        statusBanner: incomeStatus == 'e-signed completed'
            ? Builder(builder: (context) {
                final successBg = resolveThemeColor(context,
                    dark: const Color(0xFF0A3D1E), light: const Color(0xFFE6F9ED));
                final successText = resolveThemeColor(context,
                    dark: MyntColors.successDark, light: MyntColors.success);
                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: successBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_rounded, size: 14, color: successText),
                      const SizedBox(width: 6),
                      Text(
                        "Income change request is in process",
                        style: MyntWebTextStyles.caption(context,
                          color: successText,
                          fontWeight: MyntFonts.medium,
                        ).copyWith(decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                );
              })
            : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width > 900 ? 3 : width > 500 ? 2 : 1;

        // Chunk fields into rows
        final List<List<_FlatFieldData>> rows = [];
        for (int i = 0; i < fields.length; i += cols) {
          rows.add(fields.sublist(i, (i + cols).clamp(0, fields.length)));
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          decoration: BoxDecoration(
            color: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title inside container
              Text(
                "Personal Details",
                style: MyntWebTextStyles.title(context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: MyntFonts.medium,
                ).copyWith(decoration: TextDecoration.none),
              ),
              const SizedBox(height: 32),

              // Rows of fields
              for (int r = 0; r < rows.length; r++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int c = 0; c < cols; c++) ...[
                      Expanded(
                        child: c < rows[r].length
                            ? _buildFlatField(
                                field: rows[r][c],
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                dividerColor: dividerColor,
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (c < cols - 1) const SizedBox(width: 40),
                    ],
                  ],
                ),
                if (r < rows.length - 1) const SizedBox(height: 32),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Flat field: uppercase label, bold value, underline, optional EDIT pill
  Widget _buildFlatField({
    required _FlatFieldData field,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          field.label.toUpperCase(),
          style: MyntWebTextStyles.caption(context,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
            fontWeight: MyntFonts.semiBold,
          ).copyWith(
            letterSpacing: 0.5,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 10),
        // Value + Edit button row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                field.value.isNotEmpty ? field.value : "N/A",
                style: MyntWebTextStyles.body(context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: MyntFonts.medium,
                ).copyWith(decoration: TextDecoration.none),
              ),
            ),
            if (field.onEdit != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: field.onEdit,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 16,
                    color: resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        // Underline
        Divider(height: 1, thickness: 1, color: dividerColor),
        // Status banner
        if (field.statusBanner != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: field.statusBanner!,
          ),
      ],
    );
  }

}

/// Simple data holder for flat field rows
class _FlatFieldData {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final Widget? statusBanner;

  const _FlatFieldData({
    required this.label,
    required this.value,
    this.onEdit,
    this.statusBanner,
  });
}

// ═══════════════════════════════════════════════════════════════════════
//  EMAIL CHANGE DIALOG (inline OTP flow)
// ═══════════════════════════════════════════════════════════════════════
class _EmailChangeDialog extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ClientData clientData;
  final VoidCallback onEsign;

  const _EmailChangeDialog({
    required this.profileProvider,
    required this.clientData,
    required this.onEsign,
  });

  @override
  State<_EmailChangeDialog> createState() => _EmailChangeDialogState();
}

class _EmailChangeDialogState extends State<_EmailChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change Email",
                      style: MyntWebTextStyles.title(context, color: textColor)),
                  MyntCloseButton(
                    onPressed: () {
                      widget.profileProvider.clearProfilePop(context, 'email');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Current Email",
                          style: MyntWebTextStyles.caption(context,
                              color: subtitleColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 4),
                      Text(widget.clientData.cLIENTIDMAIL ?? "",
                          style: MyntWebTextStyles.body(context,
                              color: textColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 16),
                      Text("New Email *",
                          style: MyntWebTextStyles.bodySmall(context,
                              color: textColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 6),
                      MyntFormTextField(
                        controller: widget.profileProvider.newEmailController,
                        placeholder: 'Enter new email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        Text("Enter OTP *",
                            style: MyntWebTextStyles.bodySmall(context,
                                color: textColor,
                                fontWeight: MyntFonts.medium)),
                        const SizedBox(height: 6),
                        MyntFormTextField(
                          controller: widget.profileProvider.newEmailOTPController,
                          placeholder: 'Enter 4-digit OTP',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!_otpSent)
                        MyntPrimaryButton(
                          label: 'Send OTP',
                          size: MyntButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isLoading = true);
                            await widget.profileProvider.emaileotpfun(
                              widget.profileProvider.newEmailController.text,
                              widget.clientData.cLIENTIDMAIL ?? "",
                              widget.clientData.cLIENTNAME ?? "",
                              widget.clientData.cLIENTDPCODE ?? "",
                            );
                            setState(() {
                              _otpSent = true;
                              _isLoading = false;
                            });
                          },
                        ),
                      if (_otpSent)
                        MyntPrimaryButton(
                          label: 'Verify & E-Sign',
                          size: MyntButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            final result = await widget.profileProvider
                                .emailOtpVerifyWeb(
                              widget.profileProvider.newEmailOTPController.text,
                              widget.profileProvider.newEmailController.text,
                            );
                            setState(() => _isLoading = false);
                            if (result == 'otp valid') {
                              widget.onEsign();
                            } else {
                              if (mounted) {
                                error(context, result ?? 'OTP verification failed');
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  MOBILE CHANGE DIALOG (inline OTP flow)
// ═══════════════════════════════════════════════════════════════════════
class _MobileChangeDialog extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ClientData clientData;
  final VoidCallback onEsign;

  const _MobileChangeDialog({
    required this.profileProvider,
    required this.clientData,
    required this.onEsign,
  });

  @override
  State<_MobileChangeDialog> createState() => _MobileChangeDialogState();
}

class _MobileChangeDialogState extends State<_MobileChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change Mobile",
                      style: MyntWebTextStyles.title(context, color: textColor)),
                  MyntCloseButton(
                    onPressed: () {
                      widget.profileProvider.clearProfilePop(context, 'mobile');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Current Mobile",
                          style: MyntWebTextStyles.caption(context,
                              color: subtitleColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 4),
                      Text(widget.clientData.mOBILENO ?? "",
                          style: MyntWebTextStyles.body(context,
                              color: textColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 16),
                      Text("New Mobile Number *",
                          style: MyntWebTextStyles.bodySmall(context,
                              color: textColor,
                              fontWeight: MyntFonts.medium)),
                      const SizedBox(height: 6),
                      MyntFormTextField(
                        controller: widget.profileProvider.newMobController,
                        placeholder: 'Enter new mobile number',
                        keyboardType: TextInputType.phone,
                      ),
                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        Text("Enter OTP *",
                            style: MyntWebTextStyles.bodySmall(context,
                                color: textColor,
                                fontWeight: MyntFonts.medium)),
                        const SizedBox(height: 6),
                        MyntFormTextField(
                          controller: widget.profileProvider.newMobOTPController,
                          placeholder: 'Enter OTP',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!_otpSent)
                        MyntPrimaryButton(
                          label: 'Send OTP',
                          size: MyntButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isLoading = true);
                            await widget.profileProvider.mobileotpfun(
                              widget.profileProvider.newMobController.text,
                              widget.clientData.cLIENTIDMAIL ?? "",
                              widget.clientData.mOBILENO ?? "",
                              widget.clientData,
                            );
                            setState(() {
                              _otpSent = true;
                              _isLoading = false;
                            });
                          },
                        ),
                      if (_otpSent)
                        MyntPrimaryButton(
                          label: 'Verify & E-Sign',
                          size: MyntButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            final result = await widget.profileProvider
                                .mobileOtpVerifyWeb(
                              widget.profileProvider.newMobController.text,
                              widget.profileProvider.newMobOTPController.text,
                              widget.clientData,
                            );
                            setState(() => _isLoading = false);
                            if (result == 'otp valid') {
                              widget.onEsign();
                            } else {
                              if (mounted) {
                                error(context, result ?? 'OTP verification failed');
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  INCOME CHANGE DIALOG
// ═══════════════════════════════════════════════════════════════════════
class _IncomeChangeDialog extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ClientData clientData;
  final bool isDarkMode;
  final VoidCallback onDone;

  const _IncomeChangeDialog({
    required this.profileProvider,
    required this.clientData,
    required this.isDarkMode,
    required this.onDone,
  });

  @override
  State<_IncomeChangeDialog> createState() => _IncomeChangeDialogState();
}

class _IncomeChangeDialogState extends State<_IncomeChangeDialog> {
  String? _selectedRange;
  bool _otpSent = false;
  bool _isLoading = false;
  bool _showProofUpload = false;
  String _selectedDocType = 'bs';
  List<int>? _fileBytes;
  String? _fileName;
  bool _passwordRequired = false;
  bool _showPasswordField = false;
  final _passwordController = TextEditingController();
  int _currentIncomeIndex = -1;

  final _incomeRanges = [
    'Below 1L',
    '1L to 5L',
    '5L to 10L',
    '10L to 25L',
    'Above 25L',
  ];

  final _docTypes = {
    'bs': 'Bank Statement',
    'pc': 'Latest ITR Copy',
    'bp': 'Latest 6 months salary slip',
    'dp': 'DP holding statement as on date',
    'nc': 'Net worth Certificate',
    'sif': 'Copy of Form 16 in case of salary income',
  };

  // Theme helpers
  bool get _isDark => widget.isDarkMode;
  Color get _textPrimary => _isDark ? colors.textPrimaryDark : colors.textPrimaryLight;
  Color get _textSecondary => _isDark ? colors.textSecondaryDark : colors.textSecondaryLight;
  Color get _dialogBg => _isDark ? const Color(0xFF121212) : colors.colorWhite;
  Color get _cardBg => _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F7FA);
  Color get _borderColor => _isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE0E0E0);
  Color get _inputFillColor => _isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;

  @override
  void initState() {
    super.initState();
    _resolveCurrentIncomeIndex();
  }

  void _resolveCurrentIncomeIndex() {
    final income = widget.clientData.aNNUALINCOME ?? '';
    if (income.contains('Less') || income.contains('Below')) {
      _currentIncomeIndex = 0;
    } else if (income.contains('One To Five') || income.contains('1L to 5L')) {
      _currentIncomeIndex = 1;
    } else if (income.contains('Five To Ten') || income.contains('5L to 10L')) {
      _currentIncomeIndex = 2;
    } else if (income.contains('Ten To Twenty') || income.contains('10L to 25L')) {
      _currentIncomeIndex = 3;
    } else if (income.contains('TwentyFive') || income.contains('Above') || income.contains('Crore')) {
      _currentIncomeIndex = 4;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes == null) return;

      setState(() {
        _fileBytes = file.bytes!.toList();
        _fileName = file.name;
      });

      // Check if PDF is password protected
      final lockResult = await widget.profileProvider.pdfLockCheck(
        fileBytes: _fileBytes!,
        fileName: _fileName!,
      );
      if (lockResult != null && lockResult['password required'] == 'True') {
        setState(() {
          _passwordRequired = true;
          _showPasswordField = true;
        });
      } else {
        setState(() {
          _passwordRequired = false;
          _showPasswordField = false;
        });
      }
    }
  }

  Future<void> _onSubmit() async {
    if (_selectedRange == null) return;

    final rangeIndex = _incomeRanges.indexOf(_selectedRange!);

    // For "Above 25L", proof file is required
    if (rangeIndex == 4 && _fileBytes == null) {
      error(context, "Please upload proof document");
      return;
    }

    // If password required, verify it first
    if (_passwordRequired && _showPasswordField) {
      setState(() => _isLoading = true);
      final result = await widget.profileProvider.pdfPasswordCheck(
        fileBytes: _fileBytes!,
        fileName: _fileName!,
        password: _passwordController.text,
      );
      if (result != null && result['password required'] == 'In-Correct') {
        setState(() => _isLoading = false);
        _passwordController.clear();
        if (mounted) {
          error(context, "Incorrect Password");
        }
        return;
      }
      setState(() => _isLoading = false);
    }

    // Send OTP
    setState(() => _isLoading = true);
    final otpResult = await widget.profileProvider.incomeotpsenpro(
      widget.clientData.mOBILENO ?? "",
    );
    setState(() {
      _isLoading = false;
      if (otpResult == "otp send") {
        _otpSent = true;
      }
    });
  }

  Future<void> _onVerifyOtp() async {
    final otp = widget.profileProvider.newIncomeOTPController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      error(context, "Please enter a valid 4-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    final result = await widget.profileProvider.incomeotpverpro(
      otp,
      widget.clientData,
      _selectedRange ?? "",
      fileBytes: _fileBytes,
      fileName: _fileName,
      proftye: _selectedDocType,
    );
    setState(() => _isLoading = false);

    if (result == "otp valid" || result == "success") {
      widget.onDone();
    } else if (result != null) {
      if (mounted) {
        error(context, result);
      }
      widget.profileProvider.newIncomeOTPController.clear();
    }
  }

  InputDecoration _themedInputDecoration({String? hintText, String? counterText}) {
    return InputDecoration(
      hintText: hintText,
      counterText: counterText,
      hintStyle: TextStyle(color: _textSecondary, fontSize: 13),
      filled: true,
      fillColor: _inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyntColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _otpSent ? "Verify Your OTP" : "Income change request",
                    style: MyntWebTextStyles.title(context, color: textColor),
                  ),
                  MyntCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: _otpSent
                          ? _buildOtpView()
                          : _buildIncomeSelectionView(),
                    ),
                    const SizedBox(height: 24),
                    MyntPrimaryButton(
                      label: _otpSent ? 'Verify OTP' : 'Submit',
                      size: MyntButtonSize.large,
                      isFullWidth: true,
                      isLoading: _isLoading,
                      onPressed: (!_otpSent && _selectedRange == null)
                          ? null
                          : (_otpSent ? _onVerifyOtp : _onSubmit),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSelectionView() {
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final chipBg = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: const Color(0xFFF5F7FA));
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Income per annum",
              style: MyntWebTextStyles.bodySmall(context,
                  color: textColor, fontWeight: MyntFonts.medium)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_incomeRanges.length, (index) {
              final range = _incomeRanges[index];
              final isSelected = _selectedRange == range;
              final isDisabled = _currentIncomeIndex > index;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(range),
                  ],
                ),
                showCheckmark: false,
                selected: isSelected,
                onSelected: isDisabled
                    ? null
                    : (selected) {
                        setState(() {
                          _selectedRange = selected ? range : null;
                          _showProofUpload = selected && index == 4;
                          if (!_showProofUpload) {
                            _fileBytes = null;
                            _fileName = null;
                            _passwordRequired = false;
                            _showPasswordField = false;
                          }
                        });
                      },
                selectedColor: resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary),
                disabledColor: chipBg,
                backgroundColor: chipBg,
                side: BorderSide(
                  color: isSelected ? resolveThemeColor(context,
            dark: MyntColors.secondary, light: MyntColors.primary) : borderColor,
                ),
                labelStyle: MyntWebTextStyles.bodySmall(context,
                  color: isDisabled
                      ? subtitleColor
                      : isSelected
                          ? Colors.white
                          : textColor,
                  fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.regular,
                ).copyWith(decoration: TextDecoration.none),
              );
            }),
          ),
          if (_showProofUpload) ...[
            const SizedBox(height: 20),
            Text("Document type *",
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ..._docTypes.entries.map((entry) {
              final isRadioSelected = _selectedDocType == entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isRadioSelected
                        ? (_isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFBBBBBB))
                        : _borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: isRadioSelected ? _cardBg : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  value: entry.key,
                  groupValue: _selectedDocType,
                  onChanged: (val) =>
                      setState(() => _selectedDocType = val!),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(entry.value,
                            style: TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      if (entry.key == 'bs')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("Recommended",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                  activeColor: _isDark ? Colors.white : Colors.black,
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text("Upload proof *",
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _borderColor,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10),
                color: _cardBg,
              ),
              child: Column(
                children: [
                  Text("Upload your Bank Proof",
                      style: TextStyle(
                          color: MyntColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      "Select a file or drag it into the box below.",
                      style: TextStyle(
                          color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload, size: 16,
                        color: Colors.white),
                    label: const Text("Choose File",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyntColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Accepted formats: .pdf",
                      style: TextStyle(
                          color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_fileName!,
                        style: TextStyle(
                            color: _textPrimary, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            if (_showPasswordField) ...[
              const SizedBox(height: 16),
              Text("Password *",
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    _themedInputDecoration(hintText: 'PDF password'),
                style: TextStyle(color: _textPrimary, fontSize: 14),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildOtpView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mobile number",
            style: TextStyle(color: _textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: widget.clientData.mOBILENO ?? "",
          readOnly: true,
          decoration: _themedInputDecoration(),
          style: TextStyle(color: _textPrimary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: TextStyle(color: _textPrimary, fontSize: 13),
            children: [
              const TextSpan(text: 'Enter 4 digit OTP sent to mobile no. '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.profileProvider.newIncomeOTPController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: _themedInputDecoration(
              hintText: '00-00', counterText: ''),
          style: TextStyle(color: _textPrimary, fontSize: 14),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  ADDRESS CHANGE DIALOG
// ═══════════════════════════════════════════════════════════════════════
class _AddressChangeDialog extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ClientData clientData;
  final bool isDarkMode;
  final VoidCallback onDone;
  final VoidCallback? onAadhaarTap;
  final bool startWithManual;

  const _AddressChangeDialog({
    required this.profileProvider,
    required this.clientData,
    required this.isDarkMode,
    required this.onDone,
    this.onAadhaarTap,
    this.startWithManual = false,
  });

  @override
  State<_AddressChangeDialog> createState() => _AddressChangeDialogState();
}

class _AddressChangeDialogState extends State<_AddressChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _pinLoading = false;
  late bool _showManualForm;

  late TextEditingController _addressCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  String _proofType = '';
  List<int>? _proofBytes;
  String? _proofFileName;
  Timer? _pincodeDebounce;

  Color get _textPrimary =>
      widget.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight;
  Color get _textSecondary =>
      widget.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
  Color get _dialogBg =>
      widget.isDarkMode ? MyntColors.cardDark : MyntColors.card;
  Color get _inputFillColor =>
      widget.isDarkMode ? const Color(0xFF1C2333) : const Color(0xFFF6F7F9);
  Color get _borderColor =>
      widget.isDarkMode ? MyntColors.dividerDark : MyntColors.divider;

  final _proofTypes = [
    'Aadhar Card',
    'Passport',
    'Voter ID',
    'Driving Licence',
    'Latest Bank Statement',
    'Utility Bill',
  ];

  @override
  void initState() {
    super.initState();
    _showManualForm = widget.startWithManual;
    _addressCtrl = TextEditingController();
    _pincodeCtrl = TextEditingController();
    _districtCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController(text: 'India');
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeDebounce?.cancel();
    super.dispose();
  }

  void _onPincodeChanged(String val) {
    _pincodeDebounce?.cancel();
    _pincodeDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchPincode(val);
    });
  }

  Future<void> _fetchPincode(String pincode) async {
    if (pincode.length < 6) return;
    setState(() => _pinLoading = true);
    final data = await widget.profileProvider.pincodeLookup(pincode);
    if (data != null && mounted) {
      setState(() {
        _stateCtrl.text = data['State'] ?? '';
        _districtCtrl.text = data['District'] ?? '';
        _countryCtrl.text = data['Country'] ?? 'India';
        _pinLoading = false;
      });
    } else {
      if (mounted) setState(() => _pinLoading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _proofBytes = file.bytes!.toList();
          _proofFileName = file.name;
        });
      }
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proofType.isEmpty) {
      error(context, 'Please select a proof type');
      return;
    }
    if (_proofBytes == null) {
      error(context, 'Please upload address proof');
      return;
    }

    setState(() => _isLoading = true);

    // Step 1: KRA image check before address change
    final kraResult = await widget.profileProvider.kraImageCheck();
    if (kraResult != 'image found') {
      // Show selfie capture dialog
      if (!mounted) return;
      final selfieBytes = await showDialog<List<int>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _KraSelfieDialog(isDarkMode: widget.isDarkMode),
      );
      if (selfieBytes == null || selfieBytes.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final uploadResult =
          await widget.profileProvider.uploadKraSelfie(imageBytes: selfieBytes);
      if (uploadResult != 'image saved') {
        if (mounted) {
          setState(() => _isLoading = false);
          error(context, uploadResult ?? 'Image upload failed');
        }
        return;
      }
    }

    // Step 2: Submit address change
    final result = await widget.profileProvider.addressChangeWeb(
      newAddress: _addressCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      proofType: _proofType,
      proofBytes: _proofBytes,
      proofFileName: _proofFileName,
    );

    if (mounted) setState(() => _isLoading = false);

    if (result != null) {
      widget.onDone();
    } else if (mounted) {
      error(context, 'Address change request failed');
    }
  }

  InputDecoration _themedInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: _textSecondary),
      filled: true,
      fillColor: _inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0037B7)),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required_ = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        children: required_
            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oldAddress =
        '${widget.clientData.cLRESIADD1 ?? ''} ${widget.clientData.cLRESIADD2 ?? ''} ${widget.clientData.cLRESIADD3 ?? ''}';

    return Dialog(
      backgroundColor: _dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _borderColor,
          width: 0.5,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _borderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Address change request',
                    style: MyntWebTextStyles.title(context,
                        color: _textPrimary,
                    )
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      splashColor: (widget.isDarkMode
                              ? MyntColors.primaryDark
                              : MyntColors.primary)
                          .withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded,
                            size: 20, color: _textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

              // Options view: Aadhaar (Digilocker) / Type manually
              if (!_showManualForm) ...[
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onAadhaarTap?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resolveThemeColor(context,
                          dark: MyntColors.secondary,
                          light: MyntColors.primary),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Aadhar (Digilocker)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
            //     SizedBox(
            //       width: double.infinity,
            //       height: 44,
            //       child: OutlinedButton(
            //         onPressed: () {
            //           setState(() => _showManualForm = true);
            //         },
            //         style: OutlinedButton.styleFrom(
            //           side:  BorderSide(color:resolveThemeColor(context,
            // dark: MyntColors.secondary, light: MyntColors.primary)),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //         child:  Text(
            //           'Type manually',
            //           style: TextStyle(
            //             color: resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
            //             fontSize: 14,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
              ],

              // Manual form
              if (_showManualForm)
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Old Address
                Text(
                  'Old Address',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  initialValue: oldAddress,
                  readOnly: true,
                  style: TextStyle(fontSize: 14, color: _textPrimary),
                  decoration: _themedInputDecoration(''),
                ),
                const SizedBox(height: 16),

                // New Address
                _buildLabel('New Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressCtrl,
                  style: TextStyle(fontSize: 14, color: _textPrimary),
                  decoration: _themedInputDecoration('New Address'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Pincode & District row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Pincode'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pincodeCtrl,
                            keyboardType: TextInputType.number,
                            style:
                                TextStyle(fontSize: 14, color: _textPrimary),
                            decoration: _themedInputDecoration('Pincode')
                                .copyWith(
                              suffixIcon: _pinLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child:
                                              CircularProgressIndicator(
                                                  strokeWidth: 2)),
                                    )
                                  : null,
                            ),
                            onChanged: _onPincodeChanged,
                            validator: (v) =>
                                (v == null || v.length < 6)
                                    ? 'Enter valid pincode'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('District'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _districtCtrl,
                            style:
                                TextStyle(fontSize: 14, color: _textPrimary),
                            decoration: _themedInputDecoration('District'),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // State & Country row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('State'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stateCtrl,
                            style:
                                TextStyle(fontSize: 14, color: _textPrimary),
                            decoration: _themedInputDecoration('State'),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Country'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _countryCtrl,
                            style:
                                TextStyle(fontSize: 14, color: _textPrimary),
                            decoration: _themedInputDecoration('Country'),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Proof Type
                _buildLabel('Proof type'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _inputFillColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _proofType.isEmpty ? null : _proofType,
                      hint: Text('Proof type',
                          style:
                              TextStyle(fontSize: 14, color: _textSecondary)),
                      isExpanded: true,
                      dropdownColor: widget.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      style: TextStyle(fontSize: 14, color: _textPrimary),
                      items: _proofTypes.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _proofType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload proof
                _buildLabel('Upload proof'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _inputFillColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _borderColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Upload your Address Proof',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0037B7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a file or drag it into the box below.',
                          style:
                              TextStyle(fontSize: 13, color: _textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0037B7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.upload,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Choose File',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Accepted formats: .pdf',
                          style:
                              TextStyle(fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected file indicator
                if (_proofFileName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _proofFileName!,
                          style:
                              TextStyle(fontSize: 13, color: _textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                    ],
                  ),
                ),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  KRA SELFIE CAPTURE DIALOG
// ═══════════════════════════════════════════════════════════════════════
class _KraSelfieDialog extends StatefulWidget {
  final bool isDarkMode;
  const _KraSelfieDialog({required this.isDarkMode});

  @override
  State<_KraSelfieDialog> createState() => _KraSelfieDialogState();
}

class _KraSelfieDialogState extends State<_KraSelfieDialog> {
  List<int>? _imageBytes;
  final bool _isUploading = false;

  Future<void> _captureFromCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 475,
        maxHeight: 520,
        imageQuality: 80,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imageBytes = bytes.toList();

        });
      }
    } catch (e) {
      if (mounted) {
        error(context, 'Camera not available. Please upload a photo.');
      }
    }
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 475,
      maxHeight: 520,
      imageQuality: 80,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _imageBytes = bytes.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
    final subtitleColor = widget.isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Let's take a selfie",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Click a selfie for your Re-KYC verification. Please make sure you are in a well-lit area.',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
              const SizedBox(height: 20),

              // Preview or buttons
              if (_imageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uint8List.fromList(_imageBytes!),
                    width: 250,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _imageBytes = null;

                  }),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Change Photo'),
                ),
              ] else ...[
                // Camera button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _captureFromCamera,
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    label: const Text('Open Camera',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('OR', style: TextStyle(fontSize: 13, color: subtitleColor)),
                const SizedBox(height: 10),
                // Upload button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _uploadPhoto,
                    icon: const Icon(Icons.upload, size: 18, color: Color(0xFF0037B7)),
                    label: const Text('Upload Photo',
                        style: TextStyle(
                            color: Color(0xFF0037B7), fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0037B7)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: (_imageBytes == null || _isUploading)
                      ? null
                      : () {
                          Navigator.pop(context, _imageBytes);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0037B7),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
