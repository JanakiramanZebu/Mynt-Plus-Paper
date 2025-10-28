import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../utils/responsive_modal.dart';
import 'basket/basket_list.dart';
import 'filter_scrip_bottom_sheet.dart';
import 'gtt_order_book.dart';
import 'order_book.dart';
import 'pending_alert_card.dart';
import 'sip_order_book_screen.dart';
import 'trade_book.dart';

class OrderBookScreen extends ConsumerStatefulWidget {
  const OrderBookScreen({super.key});

  @override
  ConsumerState<OrderBookScreen> createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends ConsumerState<OrderBookScreen>
    with TickerProviderStateMixin {
  int _lastTabLength = 0;
  
  @override
  void initState() {
    // Get the current tab count and selected tab
    final orderProv = ref.read(orderProvider);
    final tabLength = orderProv.orderTabName.length;
    final selectedTab = orderProv.selectedTab;
    
    // Ensure we have at least one tab and valid initial index
    final safeTabLength = tabLength > 0 ? tabLength : 1;
    final safeInitialIndex = selectedTab >= 0 && selectedTab < safeTabLength 
        ? selectedTab 
        : 0;
    
    _lastTabLength = safeTabLength;
    
    setState(() {
      orderProv.tabCtrl = TabController(
          length: safeTabLength,
          vsync: this,
          initialIndex: safeInitialIndex);

      orderProv.tabCtrl.addListener(() {
        orderProv.changeTabIndex(orderProv.tabCtrl.index, context);
      });
    });

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Place order screen',
      screenClass: 'Order_screen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderBook = ref.watch(orderProvider);
      final theme = ref.watch(themeProvider);
      
      // Check if tab length has changed and recreate TabController if needed
      if (orderBook.orderTabName.length != _lastTabLength) {
        final newTabLength = orderBook.orderTabName.length;
        _lastTabLength = newTabLength;
        
        // Dispose old controller if it exists
        if (orderBook.tabCtrl.length != newTabLength) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final safeTabLength = newTabLength > 0 ? newTabLength : 1;
              orderBook.tabCtrl.dispose();
              orderBook.tabCtrl = TabController(
                length: safeTabLength,
                vsync: this,
                initialIndex: 0
              );
              orderBook.tabCtrl.addListener(() {
                orderBook.changeTabIndex(orderBook.tabCtrl.index, context);
              });
            }
          });
        }
      }

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: orderBook.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    _buildFilterSearchHeader(orderBook, theme),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 35,
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     bottom: BorderSide(
                      //       color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                      //       width: 1,
                      //     ),
                      //   ),
                      // ),
                      child: TabBar(
                        controller: orderBook.tabCtrl,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        // indicatorColor:
                        //    theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, // hide default underline
                        indicator: BoxDecoration(
                          // pill-shaped highlight[4]
                          color: theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8),
                          borderRadius: BorderRadius.circular(5),
                          // border: Border.all(
                          //   color: theme.isDarkMode
                          //       ? colors.darkColorDivider
                          //       : colors.colorDivider,
                          // ),
                        ),
                        // labelColor: theme.isDarkMode
                        //     ? colors.colorLightBlue
                        //     : colors.colorBlue,
                        unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        labelStyle: TextWidget.textStyle(
                            fontSize: 14, theme: false, fw: 1, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                        unselectedLabelStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: false,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 0,
                            letterSpacing: -0.28),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),

                        // build the "Open 4" badge and the rest of the tabs
                        tabs: orderBook.orderTabName.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tabString = entry.value;
                          
                          /// If the value looks like "Open 4", split it once on the space
                          final parts = tabString.text?.split(' ') ??
                              []; // Dart's split()[3]
                          final title = parts.first; // "Open"
                          final badge =
                              parts.length > 1 ? parts[1] : null; // "4" or null

                          return Tab(
                            child: Builder(
                              builder: (context) {
                                final isSelected = orderBook.tabCtrl.index == index;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 0, bottom: 0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextWidget.paraText(
                                          text: title,
                                          theme: false,
                                           color: isSelected ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight :  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                          fw: isSelected ? 2 : 3),
                                      if (badge != null) ...[
                                        const SizedBox(width: 3),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          // decoration: BoxDecoration(
                                          //   color: colors.colorWhite,
                                          //   borderRadius: BorderRadius.circular(4),
                                          // ),
                                          child: Text(
                                            badge,
                                            style: TextWidget.textStyle(
                                                fontSize: 12, theme: false, 
                                                color: isSelected ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight :  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, fw : isSelected ? 2 : 3),
                                                
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                        child: _CustomTabBarView(
                            controller: orderBook.tabCtrl,
                            children: [
                          // OrderBook(orderBook: orderBook.allOrder!),
                          OrderBook(
                              orderBook:
                                  orderBook.orderSearchCtrl.text.isNotEmpty
                                      ? orderBook.orderSearchItem ?? []
                                      : orderBook.openOrder!),
                          OrderBook(
                              orderBook:
                                  orderBook.orderSearchCtrl.text.isNotEmpty
                                      ? orderBook.orderSearchItem ?? []
                                      : orderBook.executedOrder!),
                          TradeBook(
                              tradeBook:
                                  orderBook.orderSearchCtrl.text.isNotEmpty
                                      ? orderBook.tradeBooksearch ?? []
                                      : orderBook.tradeBook ?? []),

                          GttOrderBook(
                              gttOrderBook:
                                  orderBook.orderSearchCtrl.text.isNotEmpty
                                      ? orderBook.gttOrderBookSearch ?? []
                                      : orderBook.gttOrderBookModel ?? []),
                          const BasketList(),

                          // SipOrderBook(
                          //   sipbook: orderBook.orderSearchCtrl.text.isNotEmpty
                          //       ? sipBook.siporderBookSearch
                          //       : sipBook.siporderBookModel?.sipDetails,
                          // ),
                          const PendingAlert(),
                        ]))
                  ]),
      );
    });
  }

  // Filter and search header
  Widget _buildFilterSearchHeader(OrderProvider order, ThemesProvider theme) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          // border: Border(
          //   bottom: BorderSide(
          //     color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
          //     width: 1,
          //   ),
          // ),
        ),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset(
                assets.searchIcon,
                width: 20,
                height: 20,
                fit: BoxFit.scaleDown,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: order.orderSearchCtrl,
                  autofocus: false,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 3,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    order.searchOrders(value, context);
                  },
                ),
              ),
              if (order.orderSearchCtrl.text.isNotEmpty)
                Material(
                   color: Colors.transparent,
                      shape: const CircleBorder(),
                  child: InkWell(
                   borderRadius: BorderRadius.circular(20),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      order.clearOrderSearch();
                    },
                    child: Padding(
                       padding: const EdgeInsets.all(6.0),
                      child: SvgPicture.asset(
                        assets.removeIcon,
                        width: 20,
                        height: 20,
                         fit: BoxFit.scaleDown,
                               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              // const VerticalDivider(
              //   color: Color(0xFFCED3DE),
              //   width: 1,
              //   thickness: 1,
              //   indent: 8,
              //   endIndent: 8,
              // ),
              Material(
                color: Colors.transparent,
                shape: CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      FocusScope.of(context).unfocus();
                      ResponsiveModal.show(
                        context: context,
                        child: const OrderbookFilterBottomSheet(),
                        useSafeArea: true,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      assets.filterIcon,
                      width: 14,
                      height: 14,
                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ));
  }
}

// Custom TabBarView that handles edge swipe gestures to parent tabs
class _CustomTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;

  const _CustomTabBarView({
    required this.controller,
    required this.children,
  });

  @override
  State<_CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<_CustomTabBarView> {
  late PageController _pageController;
  bool _isExternalTabChange = false;

  // Track pointer events for edge swipes
  double _startX = 0;
  double _startY = 0;
  double _currentX = 0;
  double _currentY = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.index);

    // Listen to internal tab controller changes (sync with page)
    widget.controller.addListener(() {
      if (_isExternalTabChange) {
        return; // Avoid sync during external tab transition
      }

      final currentPage = _pageController.page?.round();
      final newIndex = widget.controller.index;

      if (_pageController.hasClients && currentPage != newIndex) {
        // Use jumpToPage for distant tabs to avoid scrolling through all intermediate tabs
        // Use animateToPage only for adjacent tabs (distance of 1)
        final distance = (currentPage! - newIndex).abs();
        if (distance > 1) {
          _pageController.jumpToPage(newIndex);
        } else {
          _pageController.animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToOuterTab({
    required int current,
    required int target,
    required VoidCallback action,
  }) {
    if (_isExternalTabChange || current == target) return;

    _isExternalTabChange = true;
    action();
    Future.delayed(const Duration(milliseconds: 500), () {
      _isExternalTabChange = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, child) {
        final portfolio = ref.read(portfolioProvider);

        return Listener(
          onPointerDown: (PointerDownEvent event) {
            _startX = event.position.dx;
            _startY = event.position.dy;
            _currentX = _startX;
            _currentY = _startY;
            _isTracking = true;
          },
          onPointerMove: (PointerMoveEvent event) {
            if (_isTracking) {
              _currentX = event.position.dx;
              _currentY = event.position.dy;
            }
          },
          onPointerUp: (PointerUpEvent event) {
            if (!_isTracking) return;
            _isTracking = false;

            final deltaX = _currentX - _startX;
            final deltaY = _currentY - _startY;
            final currentPage = _pageController.page?.round() ?? 0;

            // Only process if horizontal movement is greater than vertical
            if (deltaX.abs() <= deltaY.abs()) return;

            // Minimum distance for edge swipe
            const minDistance = 50.0;

            // Right swipe from first tab -> Holdings
            if (deltaX > minDistance && currentPage == 0) {
              _navigateToOuterTab(
                current: portfolio.selectedTab,
                target: portfolio.selectedTab - 1,
                action: () {
                  portfolio.portTab.animateTo(portfolio.selectedTab - 1);
                },
              );
            }

            // Left swipe from last tab -> Funds
            if (deltaX < -minDistance &&
                currentPage == widget.children.length - 1) {
              _navigateToOuterTab(
                current: portfolio.selectedTab,
                target: portfolio.selectedTab + 1,
                action: () {
                  portfolio.portTab.animateTo(portfolio.selectedTab + 1);
                },
              );
            }
          },
          onPointerCancel: (PointerCancelEvent event) {
            _isTracking = false;
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.children.length,
            onPageChanged: (index) {
              widget.controller.animateTo(index);
            },
            itemBuilder: (context, index) => widget.children[index],
          ),
        );
      },
    );
  }
}
