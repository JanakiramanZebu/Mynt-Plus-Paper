import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/models/ipo_model/ipo_mainstream_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_sme_model.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/ipo_time_line.dart';

class MainSmeSinglePage extends StatefulWidget {
  final String ipotype;
  final String startdate;
  final String enddate;
  final String mininv;
  final String pricerange;
  final String ipodetails;
  
  const MainSmeSinglePage({
    super.key,
    required this.ipotype,
    required this.startdate,
    required this.enddate,
    required this.mininv,
    required this.pricerange,
    required this.ipodetails,
  });

  @override
  State<MainSmeSinglePage> createState() => _MainSmeSinglePageState();
}

class _MainSmeSinglePageState extends State<MainSmeSinglePage> {
  static const double _initialChildSize = 0.88;
  static const double _maxChildSize = 0.99;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final singlepage = ref.watch(ipoProvide);
        final upi = ref.watch(transcationProvider);

        return DraggableScrollableSheet(
          initialChildSize: _initialChildSize,
          maxChildSize: _maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            if (singlepage.iposinglepage?.data == "no data") {
              return const _NoDataWidget();
            }

            return _IPODetailsContainer(
              theme: theme,
              singlepage: singlepage,
              upi: upi,
              widget: widget,
              scrollController: scrollController,
              isExpanded: _isExpanded,
              onExpandToggle: () => setState(() => _isExpanded = !_isExpanded),
            );
          },
        );
      },
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
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 250),
          child: NoDataFound(),
        ),
      ],
    );
  }
}

class _IPODetailsContainer extends StatelessWidget {
  final ThemesProvider theme;
  final dynamic singlepage;
  final dynamic upi;
  final MainSmeSinglePage widget;
  final ScrollController scrollController;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const _IPODetailsContainer({
    required this.theme,
    required this.singlepage,
    required this.upi,
    required this.widget,
    required this.scrollController,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 6),
          _buildStatusBanner(),
          _buildCompanyHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildScrollableContent(),
          ),
          _buildApplyButton(context),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (singlepage.iposinglepage!.data["status"] == "CLOSED") {
      return const SizedBox();
    }
    
    return Container(
      height: 35,
      color: const Color(0xFFE6F7E4),
      child: Center(
        child: Text(
          "This IPO application is open for ${singlepage.iposinglepage!.data!['CloseAt']} days",
          style: _textStyle(colors.colorBlack, 12, FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.darkGrey : const Color(0xfffafbff),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        trailing: _buildCompanyLogo(),
        title: _buildCompanyInfo(),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return ClipOval(
      child: Container(
        color: colors.colorDivider.withOpacity(.3),
        width: 50,
        height: 50,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Image.network(
            singlepage.iposinglepage!.data!['image_link'].toString(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text('Failed to load image');
            },
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
          "${singlepage.iposinglepage!.data!['Company Name']} ",
          style: _textStyle(
            !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            16,
            FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusChips(),
      ],
    );
  }

  Widget _buildStatusChips() {
    return Row(
      children: [
        _buildStatusChip(),
        const SizedBox(width: 10),
        _buildTypeChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    final status = ipostartdate(widget.startdate, widget.enddate);
    final isOpen = status == "Open";
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? theme.isDarkMode
                ? const Color(0xffECF8F1).withOpacity(.3)
                : const Color(0xffECF8F1)
            : theme.isDarkMode
                ? const Color(0xffFFF6E6).withOpacity(.3)
                : const Color(0xffFFF6E6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: _textStyle(
          Color(isOpen ? 0xff43A833 : 0xffB37702),
          11,
          FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.colorGrey.withOpacity(.3)
            : const Color.fromARGB(255, 243, 242, 174),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.ipotype,
        style: _textStyle(const Color(0xff666666), 10, FontWeight.w500),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      controller: scrollController,
      children: [
        _IPODetailsSection(
          theme: theme,
          singlepage: singlepage,
          widget: widget,
        ),
        _buildDivider(),
        _SubscriptionSection(theme: theme, singlepage: singlepage),

        
        _IPOTimelineSection(theme: theme, singlepage: singlepage),
        _buildDivider(),
        _AboutCompanySection(
          theme: theme,
          singlepage: singlepage,
          isExpanded: isExpanded,
          onExpandToggle: onExpandToggle,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    if (singlepage.iposinglepage!.data['status'] == "CLOSED") {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: () => _handleApplyIPO(context),
          child: Text(
            "Apply for IPO",
            style: _textStyle(
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              14,
              FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleApplyIPO(BuildContext context) async {
    if (widget.ipodetails.isNotEmpty) {
      try {
        final Map<String, dynamic> decodedJson = jsonDecode(widget.ipodetails);
        
        // Fetch UPI ID View
        await upi.fetchupiIdView(
          upi.bankdetails!.dATA![upi.indexss][1],
          upi.bankdetails!.dATA![upi.indexss][2],
        );

        if (context.mounted) {
          if (decodedJson['subType'] == "SME") {
            final ipoOrderbookData = SMEIPO.fromJson(decodedJson);
            await singlepage.smeipocategory();
            Navigator.pushNamed(
              context,
              Routes.smeapplyIPO,
              arguments: ipoOrderbookData,
            );
          } else {
            final ipoOrderbookData = MainIPO.fromJson(decodedJson);
            await singlepage.mainipocategory();
            Navigator.pushNamed(
              context,
              Routes.applyIPO,
              arguments: ipoOrderbookData,
            );
          }
        }
      } catch (e) {
        print("Error decoding JSON or processing IPO details: $e");
      }
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _IPODetailsSection extends StatelessWidget {
  final ThemesProvider theme;
  final dynamic singlepage;
  final MainSmeSinglePage widget;

  const _IPODetailsSection({
    required this.theme,
    required this.singlepage,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "IPO Details",
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _rowOfInfoData(
            "IPO date",
            singlepage.iposinglepage!.data["IpoDetails"]["IpoDate"],
            "Listing date",
            singlepage.iposinglepage!.data["IpoDetails"]["ListingDt"],
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Price range",
            widget.pricerange,
            "Min. amount",
            widget.mininv,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Total Issue Size",
            singlepage.iposinglepage!.data["IpoDetails"]["tlShares"],
            "Lot size",
            singlepage.iposinglepage!.data["IpoDetails"]["LotSize"] == "" ||
                singlepage.iposinglepage!.data["IpoDetails"]["LotSize"] == null
                ? "--"
                : "${singlepage.iposinglepage!.data!["IpoDetails"]['LotSize']}",
          ),
          _buildListingAndRHPSection(),
        ],
      ),
    );
  }

  Widget _buildListingAndRHPSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Listing at",
                style: _textStyle(const Color(0xff666666), 12, FontWeight.w400),
              ),
              const SizedBox(height: 4),
              Text(
                singlepage.iposinglepage!.data["IpoDetails"]["ListingAt"] == "" ||
                    singlepage.iposinglepage!.data["IpoDetails"]["ListingAt"] == null
                    ? "--"
                    : "${singlepage.iposinglepage!.data['IpoDetails']['ListingAt']}",
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (singlepage.iposinglepage!.data['IpoDetails']['RHP'] != "")
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RHP DOC",
                  style: _textStyle(const Color(0xff666666), 12, FontWeight.w400),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _launchURL(singlepage.iposinglepage!.data!['IpoDetails']['RHP']),
                  child: Text(
                    "Download",
                    style: _textStyle(colors.colorBlue, 14, FontWeight.w600),
                  ),
                ),
                Divider(
                  color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _rowOfInfoData(String title1, String value1, String title2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: _textStyle(const Color(0xff666666), 12, FontWeight.w400),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title2,
                style: _textStyle(const Color(0xff666666), 12, FontWeight.w400),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch "$url"';
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  final ThemesProvider theme;
  final dynamic singlepage;

  const _SubscriptionSection({
    required this.theme,
    required this.singlepage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: theme.isDarkMode ? const Color(0xFF2A2A2A) : colors.kColorLightGrey,
      child: Builder(
        builder: (context) {
          final subscriptionData = singlepage.iposinglepage!.data['subsciption'];

          if (subscriptionData == null || subscriptionData.isEmpty) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                "Subscription Status",
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "The IPO has been subscribed ${singlepage.iposinglepage!.data['tlSub']['Subscription (times)']} times",
                style: _textStyle(colors.colorGrey, 14, FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subscriptionData.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: colors.colorDivider),
                ),
                itemBuilder: (context, index) {
                  final category = subscriptionData[index]["Category"] ?? "Unknown";
                  final subscriptionTimes = subscriptionData[index]["Subscription (times)"]?.toString() ?? "N/A";

                  return _ipoDateDisplay(category, subscriptionTimes);
                },
              ),
               Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
      ),
    )
            ],
          );
        },
      ),
    );
  }

  Widget _ipoDateDisplay(String text, String value) {
    double maxValue = 100;
    double convertedValue = 0.0;

    try {
      convertedValue = double.parse(value) * 100;
    } catch (e) {
      convertedValue = 0.0;
    }

    double progress = (convertedValue / maxValue);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _getInvestorCategory(text),
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500,
                ),
              ),
            ),
            Text(
              "$value x",
              style: _textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
            backgroundColor: Colors.grey[300],
            color: progress < 1 
                ? const Color.fromARGB(255, 233, 196, 7) 
                : const Color(0xFF148564),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  String _getInvestorCategory(String category) {
    switch (category) {
      case "QIB":
        return "Qualified Institution";
      case "NII*":
        return "Non Institution";
      case "Retail":
        return "Retail";
      case "bNII (bids above ₹10L)":
        return "Non Individual - big";
      case "sNII (bids below ₹10L)":
        return "Non Individual - small";
      case "NII":
        return "Non Individual";
      default:
        return category;
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _IPOTimelineSection extends StatelessWidget {
  final ThemesProvider theme;
  final dynamic singlepage;

  const _IPOTimelineSection({
    required this.theme,
    required this.singlepage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            "IPO TimeLine",
            style: _textStyle(
              !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              14,
              FontWeight.w600,
            ),
          ),
          ListView.builder(
            itemCount: singlepage.iposinglepage!.data['IPO_Timeline'].length - 1,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final isFirst = index == 0;
              final isLasts = index == singlepage.iposinglepage!.data['IPO_Timeline'].length - 2;

              return IpoTimeLineWidget(
                isfFrist: isFirst,
                isLast: isLasts,
                orderHistoryData: singlepage.iposinglepage!.data['IPO_Timeline'][index],
              );
            },
          ),
        ],
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

class _AboutCompanySection extends StatelessWidget {
  final ThemesProvider theme;
  final dynamic singlepage;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const _AboutCompanySection({
    required this.theme,
    required this.singlepage,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About the company",
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  singlepage.iposinglepage!.data['about'],
                  textAlign: TextAlign.justify,
                  style: _textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w400,
                  ).copyWith(height: 1.7),
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(0, 0)),
                  onPressed: onExpandToggle,
                  child: Text(
                    isExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0037B7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
