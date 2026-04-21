import 'dart:convert';
import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../api/core/api_link.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../routes/web_router.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../utils/responsive_snackbar.dart';

enum _OAuthStage { checking, validating, ready, invalid, restricted, mismatch }

class OAuthLoginScreen extends ConsumerStatefulWidget {
  const OAuthLoginScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<OAuthLoginScreen> createState() => _OAuthLoginScreenState();
}

class _OAuthLoginScreenState extends ConsumerState<OAuthLoginScreen> {
  String get _validateUrl => locator<ApiLinks>().myntValidate;
  String get _authUrl => locator<ApiLinks>().myntAuth;

  _OAuthStage _stage = _OAuthStage.checking;
  String _dname = '';
  String _uid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didUpdateWidget(OAuthLoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the URL's client_id changes (e.g. user clicked "Continue as ...",
    // which rewrites the URL via context.go), GoRouter reuses this widget but
    // passes a new clientId. Reset and re-bootstrap so mismatch/validate runs
    // against the new value.
    if (oldWidget.clientId != widget.clientId) {
      setState(() {
        _stage = _OAuthStage.checking;
        _dname = '';
        _uid = '';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    }
  }

  String get _clientId => (widget.clientId ?? '').trim();

  String? get _nwcId {
    final s = locator<Preferences>().clientSession ?? '';
    return s.isEmpty ? null : s;
  }

  bool get _hasSession {
    final pref = locator<Preferences>();
    return (pref.clientId ?? '').isNotEmpty &&
        (pref.clientSession ?? '').isNotEmpty;
  }

  Future<void> _bootstrap() async {
    if (_clientId.isEmpty) {
      setState(() => _stage = _OAuthStage.invalid);
      return;
    }

    if (!_hasSession) {
      // Pass client_id through the URL so it survives page refresh / back nav.
      // auth_provider reads this off Uri.base after successful login to route back here.
      if (!mounted) return;
      context.go(
        '${WebRoutes.login}?client_id=${Uri.encodeQueryComponent(_clientId)}',
      );
      return;
    }

    // Compare URL's client_id (stripped of _U suffix) with the logged-in user's
    // clientId. If they differ, ask the user whether to continue as themselves
    // or switch account — don't silently force one or the other.
    final pref = locator<Preferences>();
    final loggedInClient = (pref.clientId ?? '').trim();
    final urlClientStripped = _clientId.replaceFirst(RegExp(r'_U$'), '');
    if (loggedInClient.isNotEmpty && urlClientStripped != loggedInClient) {
      setState(() => _stage = _OAuthStage.mismatch);
      return;
    }

    setState(() => _stage = _OAuthStage.validating);
    await _validate();
  }

  void _onContinueAsLoggedIn() {
    final loggedInClient =
        (locator<Preferences>().clientId ?? '').trim();
    if (loggedInClient.isEmpty) return;
    final newClientId = '${loggedInClient}_U';
    // Rewrite URL with the logged-in user's client_id so state matches URL.
    // The route rebuilds OAuthLoginScreen with the new clientId → validate runs.
    context.go(
      '${WebRoutes.oauthAuthorize}?client_id=${Uri.encodeQueryComponent(newClientId)}',
    );
  }

  Future<void> _validate() async {
    final nwcId = _nwcId;
    if (nwcId == null) {
      setState(() => _stage = _OAuthStage.invalid);
      return;
    }

    final payload = {'client_id': _clientId, 'nwc_id': nwcId};
    if (kDebugMode) log('mynt-validate Request => $payload');

    try {
      final res = await http.post(
        Uri.parse(_validateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        log('mynt-validate status => ${res.statusCode}');
        log('mynt-validate body => ${res.body}');
      }

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() => _stage = _OAuthStage.invalid);
        return;
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final stat = json['stat'];
      final uid = (json['uid'] ?? '').toString();
      // Backend contract: a valid caller returns stat=Ok AND a uid. Anything else
      // (stat=Not_Ok, missing uid, or account-mismatch) is treated as a session
      // that can't authorise this client — clear it and send the user to /login,
      // preserving client_id so they can return after re-login.
      final emsg = (json['emsg'] ?? '').toString().toLowerCase();
      if (stat == 'Ok' && uid.isNotEmpty) {
        setState(() {
          _stage = _OAuthStage.ready;
          _dname = (json['dname'] ?? '').toString();
          _uid = uid;
        });
      } else if (stat == 'Not_Ok' && emsg.contains('no data')) {
        // API-only user — not allowed to use this OAuth flow. Show a dedicated
        // restricted screen instead of logging them out.
        setState(() => _stage = _OAuthStage.restricted);
      } else {
        _redirectToLoginAsExpired();
      }
    } catch (e) {
      if (kDebugMode) log('mynt-validate error => $e');
      if (!mounted) return;
      setState(() => _stage = _OAuthStage.invalid);
    }
  }

  Future<void> _redirectToLoginAsExpired() async {
    // Mirror the app's standard logout flow (profile dropdown / logged-user
    // bottom sheet both use this): await fetchLogout so server-side APIs
    // (getLogout + getDeskLogout) finish invalidating the session before we
    // navigate. Pass a custom target so the OAuth client_id survives into the
    // login URL and we can return afterwards.
    await ref.read(authProvider).fetchLogout(
          context,
          target:
              '${WebRoutes.login}?client_id=${Uri.encodeQueryComponent(_clientId)}',
        );
  }

  void _onAuthorisePressed() {
    final nwcId = _nwcId;
    if (_clientId.isEmpty || nwcId == null) {
      ResponsiveSnackBar.showError(context, 'Session not found.');
      return;
    }

    if (kDebugMode) log('mynt-auth submit => client_id=$_clientId, nwc_id=$nwcId');

    final form = html.FormElement()
      ..action = _authUrl
      ..method = 'POST'
      ..target = '_self'
      ..style.display = 'none';

    form.append(
      html.InputElement()
        ..type = 'hidden'
        ..name = 'client_id'
        ..value = _clientId,
    );

    form.append(
      html.InputElement()
        ..type = 'hidden'
        ..name = 'nwc_id'
        ..value = nwcId,
    );

    html.document.body?.append(form);
    form.submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyntColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 48),
                child: _buildBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _OAuthStage.checking:
      case _OAuthStage.validating:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      case _OAuthStage.invalid:
        return _buildInvalidView();
      case _OAuthStage.ready:
        return _buildAuthoriseView();
      case _OAuthStage.restricted:
        return _buildRestrictedView();
      case _OAuthStage.mismatch:
        return _buildMismatchView();
    }
  }

  Widget _buildMismatchView() {
    final cardColor = resolveThemeColor(
      context,
      dark: MyntColors.cardDark,
      light: MyntColors.card,
    );
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.cardBorderDark,
      light: MyntColors.cardBorder,
    );
    final secondaryText = resolveThemeColor(
      context,
      dark: MyntColors.textTertiaryDark,
      light: MyntColors.textTertiary,
    );

    final loggedInClient = (locator<Preferences>().clientId ?? '').trim();
    final urlClientStripped =
        _clientId.replaceFirst(RegExp(r'_U$'), '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          Text(
            'Account Mismatch',
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.head(
              context,
              fontWeight: MyntFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: MyntWebTextStyles.body(
                context,
                color: secondaryText,
              ),
              children: [
                const TextSpan(text: 'You are logged in as '),
                TextSpan(
                  text: loggedInClient,
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.bold,
                  ),
                ),
                const TextSpan(
                    text: ', but this link is requesting access for '),
                TextSpan(
                  text: urlClientStripped,
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.bold,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 44,
            child: MyntPrimaryButton(
              label: 'Continue as $loggedInClient',
              isFullWidth: true,
              onPressed: _onContinueAsLoggedIn,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: MyntOutlinedButton(
              label: 'Logout',
              isFullWidth: true,
              onPressed: () async {
                await _redirectToLoginAsExpired();
              },
              textColor: resolveThemeColor(
                context,
                dark: MyntColors.textWhite,
                light: MyntColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Backend returns dname like "ZP00285 s apikey". Product wants it shown as
  // "ZP00285 API Key" — drop the possessive "s" and uppercase "API Key".
  String _prettyDname(String raw) {
    return raw.replaceAll(
      RegExp(r'\s+s\s+api\s*key\s*$', caseSensitive: false),
      ' API Key',
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icon/Mynt New logo.svg',
          width: 120,
          height: 44,
        ),
      ),
    );
  }

  Widget _buildInvalidView() {
    final cardColor = resolveThemeColor(
      context,
      dark: MyntColors.cardDark,
      light: MyntColors.card,
    );
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.cardBorderDark,
      light: MyntColors.cardBorder,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          Text(
            'Invalid link',
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.head(
              context,
              fontWeight: MyntFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This authorization link is missing required information.',
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.body(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedView() {
    final cardColor = resolveThemeColor(
      context,
      dark: MyntColors.cardDark,
      light: MyntColors.card,
    );
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.cardBorderDark,
      light: MyntColors.cardBorder,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          Text(
            'Access Restricted for API Only Users',
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: MyntOutlinedButton(
              label: 'Close',
              isFullWidth: true,
              onPressed: () {
                if (!mounted) return;
                context.go(WebRoutes.home);
              },
              textColor: resolveThemeColor(
                context,
                dark: MyntColors.textWhite,
                light: MyntColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthoriseView() {
    final cardColor = resolveThemeColor(
      context,
      dark: MyntColors.cardDark,
      light: MyntColors.card,
    );
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.cardBorderDark,
      light: MyntColors.cardBorder,
    );
    final secondaryText = resolveThemeColor(
      context,
      dark: MyntColors.textTertiaryDark,
      light: MyntColors.textTertiary,
    );

    final appName = _dname.isEmpty ? 'this app' : _prettyDname(_dname);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          Text(
            appName,
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.head(
              context,
              fontWeight: MyntFonts.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'wants to access your account${_uid.isEmpty ? '' : ' $_uid'}',
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.body(
              context,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'This will allow $appName to :',
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildBullet('View your profile details, including account balance.'),
          _buildBullet(
              'Access your portfolio, including positions and holdings.'),
          _buildBullet('Place, modify, and cancel orders.'),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _onAuthorisePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyntColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Authorize',
                style: MyntWebTextStyles.title(
                  context,
                  fontWeight: MyntFonts.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 12),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: MyntWebTextStyles.body(context),
            ),
          ),
        ],
      ),
    );
  }
}
