// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/screens/ipo/preclose_ipo/preclose_ipo_screen.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import 'single_page.dart';

class MainSmeListCard extends StatelessWidget {
  const MainSmeListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final mainstreamipo = ref.watch(ipoProvide);
      final upi = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      List<dynamic> openIpos = mainstreamipo.mainsme
          .where((ipo) =>
              ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Open")
          .toList();

      List<dynamic> preOpenIpos = mainstreamipo.mainsme
          .where((ipo) =>
              ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) ==
              "Pre-open")
          .toList();

      final hasAnyData = openIpos.isNotEmpty ||
          preOpenIpos.isNotEmpty ||
          (ipos.ipoPreClose?.msg.isNotEmpty ?? false);

      if (!hasAnyData) {
        return Padding(
          padding: const EdgeInsets.only(top: 225),
          child: SizedBox(
            height: devHeight - 140,
            child: const Column(
              children: [NoDataFound()],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (openIpos.isNotEmpty) ...[
              _IPOListSection(
                ipos: openIpos,
                ipoProvider: ipos,
                upiProvider: upi,
                theme: theme,
                isPreOpen: false,
              ),
              _buildDivider(theme),
            ],
            if (preOpenIpos.isNotEmpty) ...[
              _IPOListSection(
                ipos: preOpenIpos,
                ipoProvider: ipos,
                upiProvider: upi,
                theme: theme,
                isPreOpen: true,
              ),
              _buildDivider(theme),
            ],
            if (ipos.ipoPreClose!.msg.isNotEmpty) ...[
              const ClosedIPOScreen(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildDivider(ThemesProvider theme) {
    return Divider(
      height: 0,
      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    );
  }

  static TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _IPOListSection extends StatelessWidget {
  final List<dynamic> ipos;
  final dynamic ipoProvider;
  final dynamic upiProvider;
  final ThemesProvider theme;
  final bool isPreOpen;

  const _IPOListSection({
    required this.ipos,
    required this.ipoProvider,
    required this.upiProvider,
    required this.theme,
    required this.isPreOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ipos.length,
      itemBuilder: (context, index) {
        return _IPOListItem(
          ipo: ipos[index],
          ipoProvider: ipoProvider,
          upiProvider: upiProvider,
          theme: theme,
          isPreOpen: isPreOpen,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        );
      },
    );
  }
}

class _IPOListItem extends StatelessWidget {
  final dynamic ipo;
  final dynamic ipoProvider;
  final dynamic upiProvider;
  final ThemesProvider theme;
  final bool isPreOpen;

  const _IPOListItem({
    required this.ipo,
    required this.ipoProvider,
    required this.upiProvider,
    required this.theme,
    required this.isPreOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onIPOTap(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: Text(
                  ipo.name,
                  overflow: TextOverflow.ellipsis,
                  style: MainSmeListCard.textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildIPOTypeChip(),
            ],
          ),
        ),
        if (!isPreOpen && ipo.totalsub != null && ipo.totalsub != '')
          _buildSubscriptionInfo(),
      ],
    );
  }

  Widget _buildIPOTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ipo.key == "SME"
            ? theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 243, 242, 174)
            : theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 251, 215, 148),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "${ipo.key}",
        style: MainSmeListCard.textStyle(
          const Color(0xff666666),
          10,
          FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${ipo.totalsub}x",
          style: MainSmeListCard.textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Subscription",
          style: MainSmeListCard.textStyle(
            const Color(0xff666666),
            10,
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateInfo(),
        _buildApplyButton(context),
      ],
    );
  }

  Widget _buildDateInfo() {
    final dateText = isPreOpen ? "Opens on" : "Closes on";
    final date = isPreOpen
        ? _formatDate(ipo.biddingStartDate!)
        : ipo.biddingEndDate!.substring(5, 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateText,
          style: MainSmeListCard.textStyle(
            const Color(0xff666666),
            10,
            FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: MainSmeListCard.textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    bool isApplyButtonEnabled = true;

    return SizedBox(
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          backgroundColor:
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: () {
          if (isApplyButtonEnabled) {
            isApplyButtonEnabled = false;
            _onApplyPressed(context);
          } else {
            return;
          }
        },
        child: ipoProvider.loading
            ? const SizedBox(
                width: 18,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xff666666),
                ),
              )
            : Text(
                isPreOpen ? 'Pre Apply' : 'Apply',
                style: MainSmeListCard.textStyle(
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  12,
                  FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Future<void> _onIPOTap(BuildContext context) async {
    await ipoProvider.getIpoSinglePage(ipoName: "${ipo.name}");
    if (context.mounted) {
      showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MainSmeSinglePage(
            pricerange:
                "₹${double.parse(ipo.minPrice!).toInt()} - ₹${double.parse(ipo.maxPrice!).toInt()}",
            mininv:
                "₹${convertCurrencyINRStandard(mininv(double.parse(ipo.minPrice!).toDouble(), int.parse(ipo.minBidQuantity!).toInt()).toInt())}",
            enddate: "${ipo.biddingEndDate}",
            startdate: "${ipo.biddingStartDate}",
            ipotype: "${ipo.key}",
            ipodetails: jsonEncode(ipo),
          ),
        ),
      );
    }
  }

  Future<void> _onApplyPressed(BuildContext context) async {
    ipoProvider.setisSMEPlaceOrderBtnActiveValue = false;
    ipoProvider.setisMainIPOPlaceOrderBtnActiveValue = false;

    await upiProvider.fetchupiIdView(
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][1] ?? "",
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][2] ?? "",
    );

    if (ipo.key == "SME") {
      await ipoProvider.smeipocategory();
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.smeapplyIPO,
          arguments: ipo,
        );
      }
    } else {
      await ipoProvider.mainipocategory();
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.applyIPO,
          arguments: ipo,
        );
      }
    }
  }

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    DateTime parsedDate = DateTime(year, month, day);
    return DateFormat('d MMM').format(parsedDate);
  }
}
