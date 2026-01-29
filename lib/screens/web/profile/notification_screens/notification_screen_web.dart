import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/notification/notification_navigation_service.dart';
// import '../../../notification/notification_navigation_service.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/broker_message.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/exchange_message.dart';
import 'package:mynt_plus/screens/web/profile/notification_screens/tabs/information_message.dart';

class NotificationScreenWeb extends ConsumerStatefulWidget {
  const NotificationScreenWeb({super.key});

  @override
  ConsumerState<NotificationScreenWeb> createState() => _NotificationScreenWebState();

  // Public static method to check if notification screen is visible
  static bool isCurrentlyVisible() => _NotificationScreenWebState._isScreenVisible;
}

class _NotificationScreenWebState extends ConsumerState<NotificationScreenWeb>
    with TickerProviderStateMixin {
  // Static flag to track if notification screen is currently visible
  static bool _isScreenVisible = false;

  // Stream subscription for navigation events (replaces timer-based polling)
  StreamSubscription<NotificationNavigationEvent>? _navigationSubscription;

  @override
  void initState() {
    super.initState();

    // Mark this screen as visible
    _isScreenVisible = true;
    if (kDebugMode) {
      debugPrint('[NotificationScreen] Screen opened');
    }

    // Initialize TabController with default tab (Message)
    final notificationProvider = ref.read(notificationprovider);

    // Dispose old controller if it exists
    try {
      notificationProvider.notifytab.dispose();
    } catch (e) {
      // Controller might not exist yet
    }

    notificationProvider.notifytab = TabController(
      length: notificationProvider.notifyTabName.length,
      vsync: this,
      initialIndex: 0, // Always start at Message tab
    );

    notificationProvider.notifytab.addListener(() {
      notificationProvider.changeTabIndex(notificationProvider.notifytab.index);
      notificationProvider.tabSize();
    });

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
      if (provider.notifytab.index != tabIndex) {
        provider.notifytab.animateTo(tabIndex);
        provider.changeTabIndex(tabIndex);
      }

      // For Information tab (index 2), ensure data is fresh and wait for it to load before highlighting
      if (tabIndex == 2 && event.messageId != null) {
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

    // Clean up tab controller
    try {
      ref.read(notificationprovider).notifytab.dispose();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationScreen] Error disposing tab controller: $e');
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          title: TextWidget.titleText(
            text: "Notificaton",
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          )),
      body: Consumer(builder: (context, WidgetRef ref, _) {
        final notification = ref.watch(notificationprovider);
        return SafeArea(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0))),
                  width: MediaQuery.of(context).size.width,
                  height: 46,
                  child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: theme.isDarkMode
                          ? colors.secondaryDark
                          : colors.secondaryLight,
                      unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      unselectedLabelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        fw: 2,

                      ),
                      labelColor: theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                      labelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color:theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                        fw: 2,
                      ),
                      controller: notification.notifytab,
                      tabs: notification.notifyTabName)),
              Expanded(
                  child: TabBarView(
                      controller: notification.notifytab,
                      children: const [
                    BrokerMsg(),
                    ExchangeMessage(),
                    InformationMessage(),
                  ]))
            ],
          ),
        );
      }),
    );
  }
}
