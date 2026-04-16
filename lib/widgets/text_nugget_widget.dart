import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:mynt_plus/res/res.dart';
import '../models/text_nugget_model/text_nugget_model.dart';
import '../provider/text_nugget_provider.dart';
import '../res/global_state_text.dart';
import '../provider/thems.dart';

/// Widget to display text nuggets for a specific screen
class TextNuggetWidget extends ConsumerStatefulWidget {
  final TextNuggetScreenType screenType;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const TextNuggetWidget({
    super.key,
    required this.screenType,
    this.padding,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  ConsumerState<TextNuggetWidget> createState() => _TextNuggetWidgetState();
}

class _TextNuggetWidgetState extends ConsumerState<TextNuggetWidget>
    with TickerProviderStateMixin {
  List<TextNuggetModel> _textNuggets = [];
  int _currentIndex = 0;
  bool _isDismissing = false;
  final Set<String> _dismissingCards = {}; // Track cards being dismissed for animation
  
  // Animation controllers for dismiss gestures
  final Map<String, AnimationController> _dismissControllers = {};
  final Map<String, double> _dragOffsets = {}; // Track cumulative drag offset per card
  // bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _dismissControllers.values) {
      controller.dispose();
    }
    _dismissControllers.clear();
    super.dispose();
  }

  void _initializeDismissAnimations(String cardId) {
    if (_dismissControllers.containsKey(cardId)) return;

    final controller = AnimationController(
      lowerBound: -1.0,
      upperBound: 1.0,
      value: 0.0, // Initialize at 0 (no drag)
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dismissControllers[cardId] = controller;
  }

  void _disposeDismissAnimations(String cardId) {
    _dismissControllers[cardId]?.dispose();
    _dismissControllers.remove(cardId);
    _dragOffsets.remove(cardId);
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
        // Clear dismissing state for cards that no longer exist
        _dismissingCards.removeWhere((id) => !unseenTexts.any((text) => text.id == id));
      });
    }
  }

  void _handleDismiss(String cardId) {
    if (_textNuggets.isEmpty || _isDismissing) return;

    // Find and remove the card immediately to prevent Dismissible error
    final indexToRemove = _textNuggets.indexWhere((text) => text.id == cardId);
    if (indexToRemove == -1) return;

    // Mark as dismissing and remove immediately
    setState(() {
      _dismissingCards.add(cardId);
      _isDismissing = true;
      _textNuggets.removeAt(indexToRemove);

      ref.read(textNuggetProvider).markTextAsShown(cardId);

      // Reset index if needed
      if (_textNuggets.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _textNuggets.length) {
        _currentIndex = _textNuggets.length - 1;
      } else if (indexToRemove < _currentIndex) {
        _currentIndex--;
      }
    });

    // Dispose animations for dismissed card
    _disposeDismissAnimations(cardId);

    // Clear dismissing state after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _dismissingCards.remove(cardId);
          _isDismissing = false;
          // _hasTriggeredHaptic = false;
        });
      }
    });
  }

  // Future<void> _handleTap() async {
  //   if (_textNuggets.isEmpty) return;
  //   final currentText = _textNuggets[_currentIndex];

  //   if (currentText.actionUrl != null && currentText.actionUrl!.isNotEmpty) {
  //     try {
  //       final uri = Uri.parse(currentText.actionUrl!);
  //       if (await canLaunchUrl(uri)) {
  //         await launchUrl(uri, mode: LaunchMode.inAppWebView);
  //       } else {
  //         log('Could not launch ${currentText.actionUrl}');
  //       }
  //     } catch (e) {
  //       log('Error launching URL: $e');
  //     }
  //   }
  // }

  // Widget _buildPageIndicator() {
  //   if (_textNuggets.length <= 1) return const SizedBox.shrink();

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: List.generate(_textNuggets.length, (index) {
  //       final isActive = index == _currentIndex;
  //       return AnimatedContainer(
  //         duration: const Duration(milliseconds: 300),
  //         margin: const EdgeInsets.symmetric(horizontal: 4),
  //         width: isActive ? 20 : 6,
  //         height: 6,
  //         decoration: BoxDecoration(
  //           color: isActive ? Colors.blue : Colors.grey.shade400,
  //           borderRadius: BorderRadius.circular(3),
  //         ),
  //       );
  //     }),
  //   );
  // }

  Widget _buildStackedCard(int index, bool isDark) {
    // Safety check
    if (index < 0 || index >= _textNuggets.length) {
      return const SizedBox.shrink();
    }

    final text = _textNuggets[index];
    final isTop = index == _currentIndex;
    final offset = (index - _currentIndex).toDouble();
    final isDismissing = _dismissingCards.contains(text.id);

    // Don't render dismissed cards
    if (isDismissing) {
      return const SizedBox.shrink();
    }

    // Only show current and next 2 cards
    if (offset > 2) return const SizedBox.shrink();

    // Initialize animations for top card
    if (isTop) {
      _initializeDismissAnimations(text.id);
    }

    return Transform.translate(
      offset: Offset(0, offset * 6),
      child: Transform.scale(
        scale: isTop ? 1.0 : (1.0 - (offset * 0.05)).clamp(0.85, 1.0),
        child: isTop
            ? _buildCustomDismissibleCard(text, isDark, index)
            : IgnorePointer(
                child: _buildCardContent(text, isDark, false),
              ),
      ),
    );
  }

  Widget _buildCustomDismissibleCard(TextNuggetModel text, bool isDark, int index) {
    final cardId = text.id;
    final controller = _dismissControllers[cardId]!;

    return GestureDetector(
      onHorizontalDragStart: (_) {
        // _hasTriggeredHaptic = false;
        _dragOffsets[cardId] = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        _dragOffsets[cardId] = (_dragOffsets[cardId] ?? 0.0) + delta;
        
        final screenWidth = MediaQuery.of(context).size.width;
        final dragProgress = (_dragOffsets[cardId]!.abs() / screenWidth).clamp(0.0, 1.0);
        
        // Set controller value based on drag direction
        controller.value = dragProgress * (_dragOffsets[cardId]!.sign);

      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final dragProgress = controller.value.abs();
        
        // Dismiss if dragged more than 40% or with sufficient velocity
        if (dragProgress > 0.4 || velocity.abs() > 500) {
          _animateDismiss(cardId);
        } else {
          // Snap back
          controller.animateTo(0.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
          // _hasTriggeredHaptic = false;
          _dragOffsets[cardId] = 0.0;
        }
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final dragProgress = controller.value;
          final absProgress = dragProgress.abs();
          final isDraggingLeft = dragProgress < 0;
          final isDraggingRight = dragProgress > 0;
          final screenWidth = MediaQuery.of(context).size.width;
          
          // Calculate scale and opacity based on absolute progress
          final scale = 1.0 - (absProgress * 0.1);
          final opacity = 1.0 - (absProgress * 0.3);
          
          return Stack(
            children: [
              // Dismiss background with animated icons
              if (absProgress > 0.01)
                Positioned.fill(
                  child: _buildAnimatedDismissBackground(
                    isDark,
                    dragProgress,
                    isDraggingLeft,
                    isDraggingRight,
                  ),
                ),
              // Card content with transform
              Transform.translate(
                offset: Offset(dragProgress * screenWidth, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildCardContent(text, isDark, true),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _animateDismiss(String cardId) {
    final controller = _dismissControllers[cardId];
    if (controller == null) return;

    // Get current drag direction and animate to full dismiss in that direction
    final currentProgress = controller.value;
    final targetProgress = currentProgress > 0 ? 1.0 : -1.0;

    controller.animateTo(targetProgress, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut)
        .then((_) {
      _handleDismiss(cardId);
      _disposeDismissAnimations(cardId);
    });
  }

  Widget _buildAnimatedDismissBackground(
    bool isDark,
    double dragProgress,
    bool isDraggingLeft,
    bool isDraggingRight,
  ) {
    // Show delete button on opposite side of swipe
    // If swiping left, show delete on right (end)
    // If swiping right, show delete on left (start)
    final showDeleteOnRight = isDraggingLeft;
    
    // Use light red color instead of transparent
    final lightRed = colors.lossDark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: lightRed, // Light red background instead of gradient
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: showDeleteOnRight 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   color: Colors.white.withOpacity(0.2),
                // ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(TextNuggetModel text, bool isDark, bool isInteractive) {
    final theme = ref.watch(themeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (theme.isDarkMode
                ? const Color(0xFF1A2332)
                : const Color(0xFFFFF8E1)),
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? colors.dividerDark
                : const Color(0xFFFFE082),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: theme.isDarkMode
                ? const Color(0xFFFFB74D)
                : const Color(0xFFF57C00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ReadMoreText(
              text.content,
              style: TextWidget.textStyle(
                fontSize: 13,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                height: 1.4,
                letterSpacing: 0.2,
                fw: 0,
              ),
              textAlign: TextAlign.left,
              trimLines: 1,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' more',
              trimExpandedText: ' less',
              moreStyle: TextWidget.textStyle(
                fontSize: 13,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.primaryDark
                    : colors.primaryLight,
                fw: 1,
              ),
              lessStyle: TextWidget.textStyle(
                fontSize: 13,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.primaryDark
                    : colors.primaryLight,
                fw: 1,
              ),
              colorClickableText: theme.isDarkMode
                  ? colors.colorLightBlue
                  : colors.colorBlue,
            ),
          ),
          if (isInteractive)
            GestureDetector(
              onTap: () => _handleDismiss(text.id),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes and reload texts when provider updates
    ref.listen(textNuggetProvider, (previous, next) {
      _loadTexts();
    });
    ref.watch(textNuggetProvider);

    // Also reload if local list is empty but provider has data
    if (_textNuggets.isEmpty) {
      final provider = ref.read(textNuggetProvider);
      final texts = provider.getTextsForScreen(widget.screenType);
      if (texts.isNotEmpty) {
        // Provider has data we haven't picked up yet - schedule reload
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadTexts();
        });
      }
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (kIsWeb) {
      return _buildWebBanner(isDark);
    }

    // Mobile: stacked card layout
    // Calculate visible cards count (max 3)
    final visibleCards = (_textNuggets.length - _currentIndex).clamp(1, 3);

    // Add offset for stacking effect
    final stackOffset = (visibleCards - 1) * 6.0;

    return Container(
      margin: widget.padding ?? const EdgeInsets.only(top: 8, bottom: 12),
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
              padding: EdgeInsets.only(bottom: stackOffset),
              child: _buildCardContent(_textNuggets[_currentIndex], isDark, false),
            ),
          ),
          // Render cards from back to front (only if index is valid)
          for (int i = (_currentIndex + 2).clamp(_currentIndex, _textNuggets.length - 1);
               i >= _currentIndex && i < _textNuggets.length;
               i--)
            _buildStackedCard(i, isDark),
        ],
      ),
    );
  }

  Widget _buildWebBanner(bool isDark) {
    if (_currentIndex >= _textNuggets.length) {
      return const SizedBox.shrink();
    }

    final currentText = _textNuggets[_currentIndex];

    return _buildCardContent(currentText, isDark, true);
  }
}

/// Auto-loading text nugget widget that loads text nuggets on mount
class AutoLoadTextNuggetWidget extends ConsumerStatefulWidget {
  final TextNuggetScreenType screenType;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const AutoLoadTextNuggetWidget({
    super.key,
    required this.screenType,
    this.padding,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  ConsumerState<AutoLoadTextNuggetWidget> createState() => _AutoLoadTextNuggetWidgetState();
}

class _AutoLoadTextNuggetWidgetState extends ConsumerState<AutoLoadTextNuggetWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTextNuggets();
    });
  }

  Future<void> _loadTextNuggets() async {
    final provider = ref.read(textNuggetProvider);

    // Only trigger a new load if not already loaded and not currently loading
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
    // Watch provider so widget rebuilds when loading completes
    final provider = ref.watch(textNuggetProvider);

    // If still loading from provider, show nothing
    if (_isLoading && provider.loading) {
      return const SizedBox.shrink();
    }

    // Once provider finishes loading, ensure _isLoading is cleared
    if (_isLoading && !provider.loading) {
      _isLoading = false;
    }

    return TextNuggetWidget(
      screenType: widget.screenType,
      padding: widget.padding,
      backgroundColor: widget.backgroundColor,
      textStyle: widget.textStyle,
    );
  }
}
