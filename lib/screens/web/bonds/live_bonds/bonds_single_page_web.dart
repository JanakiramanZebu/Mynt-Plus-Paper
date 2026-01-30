import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/ipo_time_line.dart';

class BondsSinglePageWeb extends StatefulWidget {
  const BondsSinglePageWeb({super.key});

  @override
  State<BondsSinglePageWeb> createState() => _BondsSinglePageStateWeb();
}

class _BondsSinglePageStateWeb extends State<BondsSinglePageWeb> {
  double initSize = 0.88;
  bool _isExpanded = false;
  
  // Static constants for better performance
  static const double _initialSheetSize = 0.88;
  static const double _maxSheetSize = 0.99;
  static const BorderRadius _sheetBorderRadius = BorderRadius.vertical(top: Radius.circular(16));
  
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final singlepage = ref.watch(ipoProvide);
        final upi = ref.watch(transcationProvider);

        return DraggableScrollableSheet(
          initialChildSize: _initialSheetSize,
          maxChildSize: _maxSheetSize,
          expand: false,
          builder: (context, scrollController) {
            if (singlepage.iposinglepage?.data == "no data") {
              return _buildEmptyState();
            }
            
            return _buildContentContainer(
              theme, 
              singlepage, 
              scrollController,
              context
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return const Column(
      children: [
        CustomDragHandler(),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 250),
          child: NoDataFound(
            title: "No Bonds Found",
            subtitle: "",
            primaryEnabled: false,
            secondaryEnabled: false,
          )
        ),
      ],
    );
  }
  
  Widget _buildContentContainer(
    ThemesProvider theme, 
    IPOProvider singlepage, 
    ScrollController scrollController,
    BuildContext context
  ) {
    final isOpen = singlepage.iposinglepage!.data["status"] != "CLOSED";
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: _sheetBorderRadius,
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        boxShadow: const [
          BoxShadow(
            color: Color(0xff999999),
            blurRadius: 4.0,
            offset: Offset(2.0, 0.0)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          const SizedBox(height: 6),
          
          if (isOpen) _buildOpenIPOBanner(theme, singlepage),
          
          _buildCompanyHeader(theme, singlepage),
          
          Expanded(
            child: _buildScrollableContent(
              theme, 
              singlepage, 
              scrollController,
              context
            ),
          ),
          
          if (isOpen) _buildApplyButton(theme, singlepage),
        ]
      ),
    );
  }
  
  Widget _buildOpenIPOBanner(ThemesProvider theme, IPOProvider singlepage) {
    return Container(
      height: 35,
      color: const Color(0xFFE6F7E4),
      child: Center(
        child: Text(
          "This IPO application is open for ${singlepage.iposinglepage!.data!['CloseAt']} days",
          style: _textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            12,
            FontWeight.w500
          )
        ),
      ),
    );
  }
  
  Widget _buildCompanyHeader(ThemesProvider theme, IPOProvider singlepage) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.darkGrey : const Color(0xfffafbff)
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        trailing: _buildCompanyLogo(singlepage),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${singlepage.iposinglepage!.data!['Company Name']} ",
              style: _textStyle(
                !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                15,
                FontWeight.w600
              )
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatusBadge(theme),
                const SizedBox(width: 10),
                _buildTypeBadge(theme),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompanyLogo(IPOProvider singlepage) {
    return ClipOval(
      child: Container(
        color: colors.colorDivider.withOpacity(.3),
        width: 50,
        height: 50,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: CachedNetworkImage(
            imageUrl: singlepage.iposinglepage!.data!['image_link'].toString(),
            memCacheWidth: 100,
            memCacheHeight: 100,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Text('Failed to load image'),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: "Open" == "Open"
            ? theme.isDarkMode
                ? const Color(0xffECF8F1).withOpacity(.3)
                : const Color(0xffECF8F1)
            : theme.isDarkMode
                ? const Color(0xffFFF6E6).withOpacity(.3)
                : const Color(0xffFFF6E6),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        "Date",
        style: _textStyle(
          const Color("Open" == "Open" ? 0xff43A833 : 0xffB37702),
          11,
          FontWeight.w500
        )
      )
    );
  }
  
  Widget _buildTypeBadge(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.colorGrey.withOpacity(.1)
            : const Color(0xffF1F3F8),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        "Type",
        style: _textStyle(
          const Color(0xff666666),
          9,
          FontWeight.w500
        )
      )
    );
  }
  
  Widget _buildScrollableContent(
    ThemesProvider theme, 
    IPOProvider singlepage, 
    ScrollController scrollController,
    BuildContext context
  ) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      controller: scrollController,
      children: [
        _buildIPODetails(theme, singlepage),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
          ),
        ),
        
        _buildSubscriptionStatus(theme, singlepage),
        
        _buildIPOTimeline(theme, singlepage),
        
        _buildAboutCompany(theme, singlepage),
      ],
    );
  }
  
  Widget _buildIPODetails(ThemesProvider theme, IPOProvider singlepage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "IPO Details",
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              15,
              FontWeight.w600
            )
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            "IPO date",
            singlepage.iposinglepage!.data["IpoDetails"]["IpoDate"],
            "Listing date",
            singlepage.iposinglepage!.data["IpoDetails"]["ListingDt"],
            theme
          ),
          
          const SizedBox(height: 8),
          
          _buildInfoRow(
            "Price range",
            "widget.pricerange",
            "Min. amount",
            "(widget.mininv)",
            theme
          ),
          
          const SizedBox(height: 8),
          
          _buildInfoRow(
            "Total Issue Size",
            "Total Issue Size",
            "Lot size",
            "Lot Size",
            theme
          ),
          
          _buildListingInfo(theme, singlepage),
        ],
      ),
    );
  }
  
  Widget _buildListingInfo(ThemesProvider theme, IPOProvider singlepage) {
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
                style: _textStyle(const Color(0xff666666), 10, FontWeight.w400)
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
                  FontWeight.w600
                )
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider
              )
            ]
          )
        ),
        const SizedBox(width: 18),
        if (singlepage.iposinglepage!.data!['IpoDetails']['RHP'] != "")
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RHP DOC",
                  style: _textStyle(const Color(0xff666666), 10, FontWeight.w400)
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _launchURL(singlepage.iposinglepage!.data!['IpoDetails']['RHP']),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 20),
                    padding: const EdgeInsets.only(
                      right: 16,
                      top: 0,
                      bottom: 0,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.topLeft,
                  ),
                  child: Text(
                    "Download",
                    style: _textStyle(
                      theme.isDarkMode ? colors.colorBlue : colors.colorBlue,
                      14,
                      FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider
                )
              ],
            ),
          )
      ]
    );
  }
  
  Widget _buildSubscriptionStatus(ThemesProvider theme, IPOProvider singlepage) {
    final subscriptionData = singlepage.iposinglepage!.data['subsciption'];

    if (subscriptionData == null || subscriptionData.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: colors.kColorLightGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subscription Status",
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              15,
              FontWeight.w600
            )
          ),
          const SizedBox(height: 3),
          Text(
            "The IPO has been subscribed ${singlepage.iposinglepage!.data['tlSub']['Subscription (times)']} times",
            style: _textStyle(
              !theme.isDarkMode ? colors.colorGrey : colors.colorWhite,
              14,
              FontWeight.w500
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subscriptionData.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ),
            itemBuilder: (context, index) {
              final category = subscriptionData[index]["Category"] ?? "Unknown";
              final subscriptionTimes = subscriptionData[index]["Subscription (times)"]?.toString() ?? "N/A";

              return ipoDateDisplay(
                theme,
                singlepage,
                category,
                subscriptionTimes,
              );
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
          ),
        ]
      ),
    );
  }
  
  Widget _buildIPOTimeline(ThemesProvider theme, IPOProvider singlepage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "IPO TimeLine",
            style: _textStyle(
              !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              15,
              FontWeight.w600
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
                orderHistoryData: singlepage.iposinglepage!.data['IPO_Timeline'][index]
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutCompany(ThemesProvider theme, IPOProvider singlepage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "About the company",
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              15,
              FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                singlepage.iposinglepage!.data['about'],
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.7,
                ),
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 0),
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0037B7),
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildApplyButton(ThemesProvider theme, IPOProvider singlepage) {
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
          onPressed: () async {
            // Apply button functionality
          },
          child: Text(
            "Apply Now!",
            style: _textStyle(
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              14,
              FontWeight.w500,
            ),
          ),
        ),
      )
    );
  }

  Widget _buildInfoRow(String title1, String value1, String title2, String value2, ThemesProvider theme) {
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
                style: _textStyle(const Color(0xff666666), 10, FontWeight.w400)
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600
                )
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider
              )
            ]
          )
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title2,
                style: _textStyle(const Color(0xff666666), 10, FontWeight.w400)
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600
                ),
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider
              )
            ]
          )
        ),
      ]
    );
  }

  Column ipoDateDisplay(ThemesProvider theme, IPOProvider singlepage, String text, String value) {
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
                getInvestorCategory(text),
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
            color: progress < 1 ? const Color.fromARGB(255, 233, 196, 7) : const Color(0xffff148564),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  String getInvestorCategory(String category) {
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

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch "$url"';
    }
  }
  
  // Static method for text styling
  TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize
    );
  }
}
