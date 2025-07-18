import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/bonds/bonds_loader/logo_loader.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
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
        body: LogoLoaderScreen(
          isLoading: bonds.bondsMyBidsload!,
          child: _buildContent(bonds, theme, devHeight),
        ),
      );
    });
  }

  Widget _buildContent(
      BondsProvider bonds, ThemesProvider theme, double devHeight) {
    final bool isEmpty = (bonds.openOrderBook?.isEmpty ?? true) &&
        (bonds.closeOrderBook?.isEmpty ?? true);

    if (isEmpty) {
      return _buildEmptyState(devHeight);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bonds.openOrderBook != null && bonds.openOrderBook!.isNotEmpty)
            _buildOrderSection("Open Orders", const BondsOpenOrder(), theme),
          if (bonds.closeOrderBook != null && bonds.closeOrderBook!.isNotEmpty)
            _buildOrderSection("Closed Orders", const BondsCloseOrder(), theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double devHeight) {
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
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 0,
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
