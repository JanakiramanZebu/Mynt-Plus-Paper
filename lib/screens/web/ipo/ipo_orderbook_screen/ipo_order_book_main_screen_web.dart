import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/web_colors.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'ipo_order_book_tab/open_orders_table_web.dart';
import 'ipo_order_book_tab/close_orders_table_web.dart';

class IpoOrderbookMainScreen extends ConsumerStatefulWidget {
  const IpoOrderbookMainScreen({super.key});

  @override
  ConsumerState<IpoOrderbookMainScreen> createState() =>
      _IpoOrderbookMainScreenState();
}

class _IpoOrderbookMainScreenState extends ConsumerState<IpoOrderbookMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  VoidCallback? _tabControllerListener; // Store listener reference for proper cleanup
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    // Store listener reference for proper cleanup
    _tabControllerListener = () {
      if (_tabController.indexIsChanging || _tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    };
    _tabController.addListener(_tabControllerListener!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ipoProvide).getipoorderbookmodel(context, true);
    });
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent memory leaks
    if (_tabControllerListener != null) {
      _tabController.removeListener(_tabControllerListener!);
      _tabControllerListener = null;
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ipo = ref.watch(ipoProvide);
    final theme = ref.watch(themeProvider);

    // Get filtered orders based on search
    final filteredOpenOrders = _getFilteredOpenOrders(ipo);
    final filteredCloseOrders = _getFilteredCloseOrders(ipo);

    final hasOpenOrders = filteredOpenOrders.isNotEmpty;
    final hasCloseOrders = filteredCloseOrders.isNotEmpty;
    final hasAnyOrders = hasOpenOrders || hasCloseOrders;

    if (!hasAnyOrders && ipo.ipocommonsearchcontroller.text.isNotEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    if (!hasAnyOrders) {
      return const Center(
        child: NoDataFound(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        _buildTabs(theme),
        const SizedBox(height: 16),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OpenOrdersTable(filteredOrders: filteredOpenOrders),
              CloseOrdersTable(filteredOrders: filteredCloseOrders),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(ThemesProvider theme) {
    final tabs = ['Open orders', 'Close orders'];
    
    return SizedBox(
      height: 40,     
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < tabs.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildTab(tabs[index], index, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, ThemesProvider theme) {
    final isSelected = _selectedTabIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          if (_tabController.index != index) {
            _tabController.animateTo(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<dynamic> _getFilteredOpenOrders(IPOProvider ipo) {
    final openOrders = ipo.openorder ?? [];

    // If there's a search query, filter the open orders
    if (ipo.ipocommonsearchcontroller.text.isNotEmpty) {
      final searchQuery = ipo.ipocommonsearchcontroller.text.toLowerCase();
      return openOrders.where((order) {
        final companyName = order.companyName?.toLowerCase() ?? '';
        final symbol = order.symbol?.toLowerCase() ?? '';
        return companyName.contains(searchQuery) ||
            symbol.contains(searchQuery);
      }).toList();
    }

    // Otherwise, return all open orders
    return openOrders;
  }

  List<dynamic> _getFilteredCloseOrders(IPOProvider ipo) {
    final closeOrders = ipo.closeorder ?? [];

    // If there's a search query, filter the close orders
    if (ipo.ipocommonsearchcontroller.text.isNotEmpty) {
      final searchQuery = ipo.ipocommonsearchcontroller.text.toLowerCase();
      return closeOrders.where((order) {
        final companyName = order.companyName?.toLowerCase() ?? '';
        final symbol = order.symbol?.toLowerCase() ?? '';
        return companyName.contains(searchQuery) ||
            symbol.contains(searchQuery);
      }).toList();
    }

    // Otherwise, return all close orders
    return closeOrders;
  }
}
