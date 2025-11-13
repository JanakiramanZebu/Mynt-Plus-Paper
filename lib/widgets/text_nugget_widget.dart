import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';
import '../models/text_nugget_model/text_nugget_model.dart';
import '../provider/text_nugget_provider.dart';

/// Widget to display text nuggets for a specific screen
class TextNuggetWidget extends ConsumerStatefulWidget {
  final TextNuggetScreenType screenType;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const TextNuggetWidget({
    Key? key,
    required this.screenType,
    this.padding,
    this.backgroundColor,
    this.textStyle,
  }) : super(key: key);

  @override
  ConsumerState<TextNuggetWidget> createState() => _TextNuggetWidgetState();
}

class _TextNuggetWidgetState extends ConsumerState<TextNuggetWidget> {
  List<TextNuggetModel> _textNuggets = [];
  int _currentIndex = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  void _loadTexts() {
    final provider = ref.read(textNuggetProvider);
    final texts = provider.getTextsForScreen(widget.screenType);
    final userId = provider.pref.clientId ?? '';

    // Filter out seen texts
    final unseenTexts = texts
        .where((text) => !provider.pref.isTextNuggetSeen(userId, text.id))
        .toList();

    if (mounted) {
      setState(() {
        _textNuggets = unseenTexts;
        _currentIndex = 0;
      });
    }
  }

  Future<void> _handleDismiss() async {
    if (_textNuggets.isEmpty || _isDismissing) return;

    setState(() {
      _isDismissing = true;
    });

    // Mark current text as shown
    // final currentText = _textNuggets[_currentIndex];
    // await ref.read(textNuggetProvider).markTextAsShown(currentText.id);

    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _textNuggets.removeAt(_currentIndex);
        _isDismissing = false;

        // Reset index if needed
        if (_currentIndex >= _textNuggets.length && _textNuggets.isNotEmpty) {
          _currentIndex = _textNuggets.length - 1;
        }
      });
    }
  }

  Future<void> _handleTap() async {
    if (_textNuggets.isEmpty) return;
    final currentText = _textNuggets[_currentIndex];

    if (currentText.actionUrl != null && currentText.actionUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(currentText.actionUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } else {
          log('Could not launch ${currentText.actionUrl}');
        }
      } catch (e) {
        log('Error launching URL: $e');
      }
    }
  }

  Widget _buildPageIndicator() {
    if (_textNuggets.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_textNuggets.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildStackedCard(int index, bool isDark) {
    final text = _textNuggets[index];
    final isTop = index == _currentIndex;
    final offset = (index - _currentIndex).toDouble();

    // Only show current and next 2 cards
    if (offset > 2) return const SizedBox.shrink();

    return Positioned(
      top: offset * 8,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 + (offset * 8)),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isTop ? 1.0 : (1.0 - (offset * 0.3)).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: isTop ? 1.0 : (1.0 - (offset * 0.05)).clamp(0.85, 1.0),
            child: isTop
                ? Dismissible(
                    key: Key(text.id),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) => _handleDismiss(),
                    background: _buildDismissBackground(isDark, Alignment.centerLeft),
                    secondaryBackground: _buildDismissBackground(isDark, Alignment.centerRight),
                    child: _buildCardContent(text, isDark, true),
                  )
                : IgnorePointer(
                    child: _buildCardContent(text, isDark, false),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(bool isDark, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildCardContent(TextNuggetModel text, bool isDark, bool isInteractive) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.backgroundColor == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E3A5F),
                        const Color(0xFF2C5282),
                      ]
                    : [
                        const Color(0xFFE3F2FD),
                        const Color(0xFFBBDEFB),
                      ],
              )
            : null,
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : colors.primaryLight.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive && text.actionUrl != null ? _handleTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: isDark
                    //         ? Colors.blue.shade700.withOpacity(0.3)
                    //         : Colors.blue.shade700.withOpacity(0.15),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Icon(
                    //     Icons.trending_up,
                    //     color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                    //     size: 20,
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //   decoration: BoxDecoration(
                    //     color: isDark
                    //         ? Colors.amber.shade700.withOpacity(0.3)
                    //         : Colors.amber.shade100,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     'Market Update',
                    //     style: TextStyle(
                    //       fontSize: 11,
                    //       fontWeight: FontWeight.w600,
                    //       color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                    //       letterSpacing: 0.5,
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),
                    if (isInteractive)
                      Row(
                        children: [
                          Icon(
                            Icons.swipe,
                            size: 16,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Swipe',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content text
                Text(
                  text.content,
                  style: widget.textStyle ??
                      TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                ),
                // Action URL indicator
                if (text.actionUrl != null && text.actionUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to learn more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                // Page indicator at bottom
                if (_textNuggets.length > 1 && isInteractive) ...[
                  const SizedBox(height: 12),
                  _buildPageIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes
    ref.watch(textNuggetProvider);

    if (_textNuggets.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate visible cards count (max 3)
    final visibleCards = (_textNuggets.length - _currentIndex).clamp(1, 3);

    // Add offset for stacking effect - need extra space for shadows and rounded corners
    final stackOffset = (visibleCards - 1) * 8.0 + 32; // Extra 12px for shadow/overflow

    return Container(
      margin: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Invisible card to define height (the front card with bottom padding for stack)
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: stackOffset, left: 16, right: 16),
              child: _buildCardContent(_textNuggets[_currentIndex], isDark, false),
            ),
          ),
          // Render cards from back to front
          for (int i = _textNuggets.length - 1; i >= _currentIndex && i < _currentIndex + 3; i--)
            _buildStackedCard(i, isDark),
        ],
      ),
    );
  }
}

/// Auto-loading text nugget widget that loads text nuggets on mount
class AutoLoadTextNuggetWidget extends ConsumerStatefulWidget {
  final TextNuggetScreenType screenType;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const AutoLoadTextNuggetWidget({
    Key? key,
    required this.screenType,
    this.padding,
    this.backgroundColor,
    this.textStyle,
  }) : super(key: key);

  @override
  ConsumerState<AutoLoadTextNuggetWidget> createState() => _AutoLoadTextNuggetWidgetState();
}

class _AutoLoadTextNuggetWidgetState extends ConsumerState<AutoLoadTextNuggetWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTextNuggets();
  }

  Future<void> _loadTextNuggets() async {
    final provider = ref.read(textNuggetProvider);

    // Only load if not already loaded
    if (provider.textNuggets.isEmpty && !provider.loading) {
      await provider.loadTextNuggets();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return TextNuggetWidget(
      screenType: widget.screenType,
      padding: widget.padding,
      backgroundColor: widget.backgroundColor,
      textStyle: widget.textStyle,
    );
  }
}
