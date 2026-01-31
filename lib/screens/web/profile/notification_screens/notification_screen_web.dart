import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/notification/notification_navigation_service.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/broker_message.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/exchange_message.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/exchange_alert.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/information_message.dart';

class NotificationScreenWeb extends ConsumerStatefulWidget {
  const NotificationScreenWeb({super.key});

  @override
  ConsumerState<NotificationScreenWeb> createState() => _NotificationScreenWebState();

  // Public static method to check if notification screen is visible
  static bool isCurrentlyVisible() => _NotificationScreenWebState._isScreenVisible;
}

class _NotificationScreenWebState extends ConsumerState<NotificationScreenWeb> {
  // Static flag to track if notification screen is currently visible
  static bool _isScreenVisible = false;

  // Stream subscription for navigation events (replaces timer-based polling)
  StreamSubscription<NotificationNavigationEvent>? _navigationSubscription;

  // Tab index state (replaces TabController for web)
  int _selectedTabIndex = 0;

  // Tab names for display
  final List<String> _tabNames = ['Message', 'Exch Alert', 'Exch Status', 'Information'];

  @override
  void initState() {
    super.initState();

    // Mark this screen as visible
    _isScreenVisible = true;
    if (kDebugMode) {
      debugPrint('[NotificationScreen] Screen opened');
    }

    // Subscribe to navigation events stream
    // This replaces the old timer-based polling system
    _navigationSubscription = NotificationNavigationService()
        .navigationStream
        .listen(_handleNavigationEvent);

    // Fetch notification data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final notificationProvider = ref.read(notificationprovider);

      // Fetch all three types of messages with error handling
      try {
        if (notificationProvider.brokermsg == null) {
          await notificationProvider.fetchbrokermsg(context);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationScreen] Error fetching broker messages: $e');
        }
      }

      try {
        if (notificationProvider.exchangemessage == null) {
          await notificationProvider.fetchexchagemsg(context);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationScreen] Error fetching exchange messages: $e');
        }
      }

      try {
        if (notificationProvider.informationMessages == null) {
          await notificationProvider.fetchInformationMessages(context);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationScreen] Error fetching information messages: $e');
        }
      }

      try {
        if (notificationProvider.exchangestatus == null) {
          await notificationProvider.fetchexchstatus(context);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationScreen] Error fetching exchange status: $e');
        }
      }
    });
  }

  /// Handles navigation events from the stream
  /// This is called whenever a notification is tapped (foreground/background/terminated)
  void _handleNavigationEvent(NotificationNavigationEvent event) {
    if (!mounted) return;

    // Only handle notification screen events
    if (!event.isNotificationScreenNavigation) {
      return;
    }

    final tabIndex = event.getNotificationTabIndex();
    if (tabIndex == null) {
      if (kDebugMode) {
        debugPrint('[NotificationScreen] Invalid tab index for event: $event');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[NotificationScreen] Handling navigation event: $event');
    }

    try {
      final provider = ref.read(notificationprovider);

      // Switch to correct tab if needed
      if (_selectedTabIndex != tabIndex) {
        setState(() {
          _selectedTabIndex = tabIndex;
        });
        provider.changeTabIndex(tabIndex);
      }

      // For Information tab (index 3), ensure data is fresh and wait for it to load before highlighting
      if (tabIndex == 3 && event.messageId != null) {
        // Force refresh information messages to get latest data

        provider.fetchInformationMessages(context).then((_) {
          // After data is fetched, highlight the message
          _highlightMessageAfterDataLoad(provider, event.messageId!);
        });
      } else {
        // For other tabs (broker, exchange), highlight immediately after tab animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && event.messageId != null) {
            provider.setHighlightedMessage(event.messageId);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationScreen] Error handling navigation event: $e');
      }
    }
  }

  void _highlightMessageAfterDataLoad(
    NotificationProvider provider,
    String messageId,
  ) async {
    // Wait for tab animation to complete first
    await Future.delayed(const Duration(milliseconds: 300));    

    if (!mounted) return;
    
    // Check if information messages are loaded
    final messages = provider.informationMessages;
    
    if (messages != null && messages.isNotEmpty) {
      // Data is loaded, check if message exists
      final messageExists = messages.any((msg) => msg.uniqueId == messageId);
      
      if (messageExists) {      
        provider.setHighlightedMessage(messageId);
      } else {
      
        if (kDebugMode) {
          debugPrint('[NotificationScreen] ⚠️ Message NOT found in API response: $messageId');
        }
       
      }
    } else {
      // Data is null or empty (API call might have failed)
      if (kDebugMode) {
        debugPrint('[NotificationScreen] ⚠️ Information messages are null or empty');
        debugPrint('[NotificationScreen] Cannot highlight - no data available');
      }
      // Don't set highlight - no data to check against
    }
  }

  @override
  void dispose() {
    // Mark screen as no longer visible
    _isScreenVisible = false;
    if (kDebugMode) {
      debugPrint('[NotificationScreen] Screen closed');
    }

    // Cancel stream subscription
    _navigationSubscription?.cancel();
    _navigationSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final notification = ref.watch(notificationprovider);

    // Get counts for each tab - filter out error responses (stat: "Not_Ok") with no actual content
    final brokerCount = notification.brokermsg
            ?.where((msg) => msg.dmsg != null && msg.dmsg!.isNotEmpty)
            .length ??
        0;
    final exchangeCount = notification.exchangemessage
            ?.where((msg) => msg.emsg == null || !msg.emsg!.contains('Session Expired'))
            .where((msg) => msg.stat != 'Not_Ok')
            .length ??
        0;
    final exchangeAlertCount = notification.exchangestatus
            ?.where((msg) => msg.stat != 'Not_Ok')
            .length ??
        0;
    final informationCount = notification.informationMessages?.length ?? 0;
    final List<int> counts = [brokerCount, exchangeCount, exchangeAlertCount, informationCount];

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tabs Row
              _buildTabsRow(theme, counts),
              const SizedBox(height: 16),
              // Tab Content
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: const [
                    BrokerMsg(),
                    ExchangeMessage(),
                    ExchangeAlert(),
                    InformationMessage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the custom tabs row matching HoldingScreenWeb style
  Widget _buildTabsRow(ThemesProvider theme, List<int> counts) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_tabNames.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < _tabNames.length - 1 ? 8 : 0),
            child: _buildTab(
              theme: theme,
              title: _tabNames[index],
              count: counts[index],
              isSelected: _selectedTabIndex == index,
              onTap: () {
                if (mounted && _selectedTabIndex != index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  // Update provider for compatibility
                  ref.read(notificationprovider).changeTabIndex(index);
                }
              },
            ),
          );
        }),
      ),
    );
  }

  /// Builds individual tab matching HoldingScreenWeb style
  Widget _buildTab({
    required ThemesProvider theme,
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                ).copyWith(
                  color: isSelected
                      ? shadcn.Theme.of(context).colorScheme.foreground
                      : shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    '$count',
                    style: MyntWebTextStyles.bodySmall(
                      context,
                      fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                    ).copyWith(
                      fontSize: 13,
                      color: isSelected
                          ? shadcn.Theme.of(context).colorScheme.foreground
                          : shadcn.Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
