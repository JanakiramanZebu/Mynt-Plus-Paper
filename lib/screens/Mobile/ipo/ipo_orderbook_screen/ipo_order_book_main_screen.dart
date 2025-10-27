import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import 'ipo_order_book_tab/close_ipo_tab.dart';
import 'ipo_order_book_tab/open_ipo_tab.dart';

class IpoOrderbookMainScreen extends ConsumerStatefulWidget {
  const IpoOrderbookMainScreen({super.key});

  @override
  ConsumerState<IpoOrderbookMainScreen> createState() =>
      _IpoOrderbookMainScreenState();
}

class _IpoOrderbookMainScreenState extends ConsumerState<IpoOrderbookMainScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ipoProvide).getipoorderbookmodel(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipo = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      return TransparentLoaderScreen(
            isLoading: ipo.myBidsload!,
        child: Scaffold(
          body: _buildBody(ipo, theme, devHeight),
        ),
      );
    });
  }

  Widget _buildBody(ipo, theme, double devHeight) {
    // Get filtered orders based on search
    final filteredOpenOrders = _getFilteredOpenOrders(ipo);
    final filteredCloseOrders = _getFilteredCloseOrders(ipo);

    final hasOrders =
        filteredOpenOrders.isNotEmpty || filteredCloseOrders.isNotEmpty;

    if (!hasOrders) {
      return _buildNoDataState(devHeight);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredOpenOrders.isNotEmpty) ...[
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.2) : colors.textSecondaryLight.withOpacity(0.05),
                  // border: Border(
                  //   top: BorderSide(
                  //     color: theme.isDarkMode
                  //         ? colors.dividerDark
                  //         : colors.dividerLight,
                  //   ),
                  //   bottom: BorderSide(
                  //     color: theme.isDarkMode
                  //         ? colors.dividerDark
                  //         : colors.dividerLight,
                  //   ),
                  // ),
                ),
                child: _buildSectionHeader("Open Orders", theme)),
            IpoOpenOrder(filteredOrders: filteredOpenOrders),
          ],
          if (filteredCloseOrders.isNotEmpty) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
               color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.2) : colors.textSecondaryLight.withOpacity(0.05),
                // border: Border(
                //   top: BorderSide(
                //     color: theme.isDarkMode
                //         ? colors.dividerDark
                //         : colors.dividerLight,
                //   ),
                //   bottom: BorderSide(
                //     color: theme.isDarkMode
                //         ? colors.dividerDark
                //         : colors.dividerLight,
                //   ),
                // ),
              ),
              child: _buildSectionHeader("Closed Orders", theme),
            ),
            IpoCloseOrder(filteredOrders: filteredCloseOrders),
          ],
        ],
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

  Widget _buildNoDataState(double devHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 225),
        child: SizedBox(
          height: devHeight - 140,
          child: const Column(
            children: [
              NoDataFound(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextWidget.subText(
        text: title,
        theme: false,
        fw: 0,
        color: theme.isDarkMode
            ? colors.textPrimaryDark
            : colors.textPrimaryLight,
      ),
    );
  }
}
