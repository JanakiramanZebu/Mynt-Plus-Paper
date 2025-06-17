import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import 'ipo_order_book_tab/close_ipo_tab.dart';
import 'ipo_order_book_tab/open_ipo_tab.dart';

class IpoOrderbookMainScreen extends ConsumerStatefulWidget {
  const IpoOrderbookMainScreen({super.key});

  @override
  ConsumerState<IpoOrderbookMainScreen> createState() => _IpoOrderbookMainScreenState();
}

class _IpoOrderbookMainScreenState extends ConsumerState<IpoOrderbookMainScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ipoProvide).getipoorderbookmodel(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipo = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: TransparentLoaderScreen(
          isLoading: ipo.myBidsload!,
          child: _buildBody(ipo, theme, devHeight),
        ),
      );
    });
  }

  Widget _buildBody(ipo, theme, double devHeight) {
    final hasOrders = (ipo.openorder?.isNotEmpty ?? false) || 
                      (ipo.closeorder?.isNotEmpty ?? false);
    
    if (!hasOrders) {
      return _buildNoDataState(devHeight);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ipo.openorder!.isNotEmpty) ...[
            _buildSectionHeader("Open Orders", theme),
            const IpoOpenOrder(),
          ],
          if (ipo.closeorder!.isNotEmpty) ...[
            _buildSectionHeader("Closed Orders", theme),
            const IpoCloseOrder(),
          ],
        ],
      ),
    );
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
      child: Text(
        title,
        style: _textStyle(
            theme.isDarkMode
                ? colors.colorWhite.withOpacity(0.3)
                : colors.colorBlack.withOpacity(0.3),
            16,
            FontWeight.w600),
      ),
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
