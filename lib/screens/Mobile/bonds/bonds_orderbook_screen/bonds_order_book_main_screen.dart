import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/mobile/bonds/bonds_loader/logo_loader.dart';
// import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
// import '../../../sharedWidget/functions.dart';
import 'bonds_order_book_tab/close_bonds_tab.dart';
import 'bonds_order_book_tab/open_bonds_tab.dart';

class BondsOrderbookMainScreen extends ConsumerStatefulWidget {
  const BondsOrderbookMainScreen({super.key});

  @override
  ConsumerState<BondsOrderbookMainScreen> createState() =>
      _BondsOrderbookMainScreenState();
}

class _BondsOrderbookMainScreenState
    extends ConsumerState<BondsOrderbookMainScreen> {
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

      return Scaffold(
        body: _buildContent(bonds, theme, devHeight),
      );
    });
  }

  Widget _buildContent(
      BondsProvider bonds, ThemesProvider theme, double devHeight) {
    // Apply search filter for My Bids via provider's search controller
    final filteredOpen = bonds.filterOpenOrdersBySearch();
    final filteredClose = bonds.filterCloseOrdersBySearch();

    final bool isEmpty = (filteredOpen.isEmpty) && (filteredClose.isEmpty);

    if (isEmpty && bonds.bondscommonsearchcontroller.text.isNotEmpty) {
      return _buildEmptyState(devHeight);
    }

    if(bonds.bondsOrderBook!.isEmpty){
      return NoDataFound(
        title: "No Open or Closed Orders Found",
        subtitle: "There's nothing here yet. Buy some Bonds to see them here.",
        primaryEnabled: false,
        secondaryEnabled: false,
      );
    }

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredOpen.isNotEmpty)
            _buildOrderSection(
                "Open Orders",
                BondsOpenOrderList(
                    orders: filteredOpen, theme: theme),
                theme),
          if (filteredClose.isNotEmpty)
            _buildOrderSection(
                "Closed Orders",
                BondsCloseOrderList(
                    orders: filteredClose, theme: theme),
                theme),
          // const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double devHeight) {
    return const Center(
      child: NoDataFound(
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
