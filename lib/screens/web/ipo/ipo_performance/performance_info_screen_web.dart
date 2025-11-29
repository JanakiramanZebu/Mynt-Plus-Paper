import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/ipo_model/ipo_performance_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../Mobile/market_watch/over_view/funtamental_data_widget.dart';

class PerformanceInfoScreen extends StatefulWidget {
  final IpoScrip ipoFundamental;
  final MarketWatchProvider market;
  final int indexipo;
  
  const PerformanceInfoScreen({
    super.key,
    required this.ipoFundamental,
    required this.market,
    required this.indexipo,
  });

  @override
  State<PerformanceInfoScreen> createState() => _PerformanceInfoScreenState();
}

class _PerformanceInfoScreenState extends State<PerformanceInfoScreen> {
  static const double _initialChildSize = 0.88;
  static const double _maxChildSize = 0.99;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        
        return DraggableScrollableSheet(
          initialChildSize: _initialChildSize,
          maxChildSize: _maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return _buildContent(theme, scrollController);
          },
        );
      },
    );
  }

  Widget _buildContent(theme, ScrollController scrollController) {
    if (widget.market.fundamentalData?.msg == "no data found") {
      return const _NoDataWidget();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        boxShadow: const [
          BoxShadow(
            color: Color(0xff999999),
            blurRadius: 4.0,
            offset: Offset(2.0, 0.0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          _CompanyHeader(
            ipoFundamental: widget.ipoFundamental,
            theme: theme,
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [FundamentalDataWidget()],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataWidget extends StatelessWidget {
  const _NoDataWidget();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CustomDragHandler(),
        Padding(
          padding: EdgeInsets.only(top: 260),
          child: NoDataFound(),
        ),
      ],
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final IpoScrip ipoFundamental;
  final dynamic theme;

  const _CompanyHeader({
    required this.ipoFundamental,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.darkGrey
            : const Color(0xfffafbff),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: _buildCompanyIcon(),
        title: _buildCompanyInfo(),
      ),
    );
  }

  Widget _buildCompanyIcon() {
    return ClipOval(
      child: Container(
        color: colors.colorDivider.withOpacity(.3),
        width: 50,
        height: 50,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              ipoFundamental.companyName!.toUpperCase().substring(0, 1),
              style: _textStyle(colors.colorBlack, 24, FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${ipoFundamental.companyName!.toUpperCase()} ",
          style: _textStyle(
            !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            15,
            FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.colorGrey.withOpacity(.1)
                : const Color(0xffF1F3F8),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Text(
            ipoFundamental.symbol.toString(),
            style: _textStyle(
              const Color(0xff666666),
              9,
              FontWeight.w500,
            ),
          ),
        ),
      ],
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
