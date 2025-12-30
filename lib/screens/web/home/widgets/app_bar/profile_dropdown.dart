import 'package:flutter/material.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/screens/web/profile/profile_main_screen_web.dart';

// Profile dropdown widget
class ProfileDropdown extends StatefulWidget {
  final bool isDarkMode;
  final String clientId;

  const ProfileDropdown({
    super.key,
    required this.isDarkMode,
    required this.clientId,
  });

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> {
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => ProfileDropdownOverlay(
        isDarkMode: widget.isDarkMode,
        clientId: widget.clientId,
        onClose: () {
          _removeOverlay();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(10),
        splashColor:
            (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                .withOpacity(0.2),
        highlightColor:
            (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                .withOpacity(0.1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.clientId,
              style: WebTextStyles.sub(
                isDarkTheme: widget.isDarkMode,
                color: widget.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.semiBold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: widget.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// Profile dropdown overlay widget
class ProfileDropdownOverlay extends StatelessWidget {
  final bool isDarkMode;
  final String clientId;
  final VoidCallback onClose;

  const ProfileDropdownOverlay({
    super.key,
    required this.isDarkMode,
    required this.clientId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        isDarkMode ? WebColorScheme.dark() : WebColorScheme.light();

    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Profile dropdown content positioned at top-right
            Positioned(
              top: 55, // Position below the app bar
              right: 16, // Align with the profile section
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping on content
                child: Container(
                  width: 350,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProfileMenuContentWrapper(
                      onNavigate:
                          onClose, // Pass callback to close on any navigation
                    ),
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

// Wrapper widget that provides close callback to UserAccountScreen via InheritedWidget
class ProfileMenuContentWrapper extends StatelessWidget {
  final VoidCallback onNavigate;

  const ProfileMenuContentWrapper({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCloseCallback(
      onClose: onNavigate,
      child: const UserAccountScreenWeb(),
    );
  }
}

// InheritedWidget to provide close callback to UserAccountScreen
class ProfileCloseCallback extends InheritedWidget {
  final VoidCallback onClose;

  const ProfileCloseCallback({
    super.key,
    required this.onClose,
    required super.child,
  });

  static ProfileCloseCallback? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileCloseCallback>();
  }

  @override
  bool updateShouldNotify(ProfileCloseCallback oldWidget) {
    return onClose != oldWidget.onClose;
  }
}
