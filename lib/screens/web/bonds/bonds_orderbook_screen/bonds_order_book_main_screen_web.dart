import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/web/bonds/bonds_orderbook_screen/bonds_order_book_tab/close_bonds_tab_web.dart';
import 'package:mynt_plus/screens/web/bonds/bonds_orderbook_screen/bonds_order_book_tab/open_bonds_tab_web.dart';
// import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
// import '../../../sharedWidget/functions.dart';
import 'bonds_my_bids_web.dart';

class BondsOrderbookMainScreenWeb extends ConsumerStatefulWidget {
  const BondsOrderbookMainScreenWeb({super.key});

  @override
  ConsumerState<BondsOrderbookMainScreenWeb> createState() =>
      _BondsOrderbookMainScreenState();
}

class _BondsOrderbookMainScreenState
    extends ConsumerState<BondsOrderbookMainScreenWeb> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bondsProvider).fetchBondsOrderBook();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;
      final devWidth = MediaQuery.of(context).size.width;

      if (devWidth > 800) {
        return const Scaffold(
            backgroundColor: Colors.transparent,
            body: BondsMyBidsWeb()
        );
      }

      return Scaffold(
        body: _buildContent(bonds, theme, devHeight),
      );
    });
  }

  Widget _buildContent(
      BondsProvider bonds, ThemesProvider theme, double devHeight) {
    // Show loader while data is being fetched
    if (bonds.bondsMyBidsload) {
      return const Center(
        child: MyntLoader(size: MyntLoaderSize.large),
      );
    }

    // Apply search filter for My Bids via provider's search controller
    final filteredOpen = bonds.filterOpenOrdersBySearch();
    final filteredClose = bonds.filterCloseOrdersBySearch();

    final bool isEmpty = (filteredOpen.isEmpty) && (filteredClose.isEmpty);

    if (isEmpty && bonds.bondscommonsearchcontroller.text.isNotEmpty) {
      return _buildEmptyState(devHeight);
    }

    if(bonds.bondsOrderBook!.isEmpty){
      return const NoDataFoundWeb(
        title: "No Open or Closed Orders Found",
        subtitle: "There's nothing here yet. Buy some Bonds to see them here.",
        primaryEnabled: false,
        secondaryEnabled: false,
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredOpen.isNotEmpty)
            _buildOrderSection(
                "Open Orders",
                BondsOpenOrderListWeb(
                    orders: filteredOpen, theme: theme),
                theme),
          if (filteredClose.isNotEmpty)
            _buildOrderSection(
                "Closed Orders",
                BondsCloseOrderListWeb(
                    orders: filteredClose, theme: theme),
                theme),
          // const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double devHeight) {
    return const Center(
      child: NoDataFoundWeb(
        title: "No Results Found",
        subtitle: "Try searching with different keywords",
        primaryEnabled: false,
        secondaryEnabled: false,
      ),
    );
  }

  Widget _buildOrderSection(
      String title, Widget orderWidget, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: TextWidget.subText(
            text: title,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
        ),
        orderWidget,
        Divider(
          height: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        ),
      ],
    );
  }
}
