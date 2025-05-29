import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/bonds/bonds_loader/logo_loader.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
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

class _BondsOrderbookMainScreenState extends ConsumerState<BondsOrderbookMainScreen>
    with TickerProviderStateMixin {
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
      final dev_height = MediaQuery.of(context).size.height;

      return LogoLoaderScreen(
        isLoading: bonds.bondsMyBidsload!,
        child: (
                bonds.openOrderBook!.isEmpty &&
                bonds.closeOrderBook!.isEmpty)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 225),
                  child: Container(
                    height: dev_height - 140,
                    child: const Column(
                      children: [
                        NoDataFound(),
                      ],
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bonds.openOrderBook != null &&
                        bonds.openOrderBook!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Text(
                          "Open Orders",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite.withOpacity(0.3)
                                  : colors.colorBlack.withOpacity(0.3),
                              16,
                              FontWeight.w600),
                        ),
                      ),
                      const BondsOpenOrder(),
                       Divider(
                  height: 0,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
                    ],
                    if (bonds.closeOrderBook != null &&
                        bonds.closeOrderBook!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Text(
                          "Closed Orders",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite.withOpacity(0.3)
                                  : colors.colorBlack.withOpacity(0.3),
                              16,
                              FontWeight.w600),
                        ),
                      ),
                      const BondsCloseOrder(),
                       Divider(
                  height: 0,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,)
                    ],
                  ],
                ),
              ),
      );
    });
  }
}
