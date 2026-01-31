// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';

class UpcomingIpo extends StatelessWidget {
  const UpcomingIpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      // Get filtered upcoming IPOs based on search
      List<dynamic> filteredUpcomingIPOs = _getFilteredUpcomingIPOs(ipos);
      final hasUpcomingIPOs = filteredUpcomingIPOs.isNotEmpty;

      // Show loader while data is being fetched
      if (ipos.loading) {
        return const Center(
          child: MyntLoader(size: MyntLoaderSize.large),
        );
      }

      if (!hasUpcomingIPOs && ipos.ipocommonsearchcontroller.text.isNotEmpty) {
        return _NoDataSection(devHeight: devHeight);
      }

      if(!hasUpcomingIPOs){
        return NoDataFound(
          title: "No Upcoming IPOs Found",
          subtitle: "There are no Upcoming IPO listings for today",
          primaryEnabled: false,
          secondaryEnabled: false,
        );
      }

      return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UpcomingIPOList(
              upcomingIPOs: filteredUpcomingIPOs,
              theme: theme,
            ),
          ],
        ),
      );
    });
  }

  List<dynamic> _getFilteredUpcomingIPOs(IPOProvider ipos) {
    final upcomingIPOs = ipos.upcomingModel?.upcoming ?? [];

    // If there's a search query, filter the upcoming IPOs
    if (ipos.ipocommonsearchcontroller.text.isNotEmpty) {
      final searchQuery = ipos.ipocommonsearchcontroller.text.toLowerCase();
      return upcomingIPOs.where((ipo) {
        final companyName = ipo.companyName?.toLowerCase() ?? '';
        final ipoType = ipo.ipoType?.toLowerCase() ?? '';
        return companyName.contains(searchQuery) ||
            ipoType.contains(searchQuery);
      }).toList();
    }

    // Otherwise, return all upcoming IPOs
    return upcomingIPOs;
  }
}

class _NoDataSection extends StatelessWidget {
  final double devHeight;

  const _NoDataSection({required this.devHeight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NoDataFound(
        title: "No Results Found",
        subtitle: "Try searching with different keywords",
        primaryEnabled: false,
        secondaryEnabled: false,
      ),
        );
  }
}

class _UpcomingIPOList extends StatelessWidget {
  final List<dynamic> upcomingIPOs;
  final ThemesProvider theme;

  const _UpcomingIPOList({
    required this.upcomingIPOs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingIPOs.length ?? 0,
      itemBuilder: (context, index) {
        return _UpcomingIPOItem(
          ipo: upcomingIPOs[index],
          theme: theme,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        );
      },
    );
  }
}

class _UpcomingIPOItem extends StatelessWidget {
  final dynamic ipo;
  final ThemesProvider theme;

  const _UpcomingIPOItem({
    required this.ipo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildCompanyInfo(),
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 280,
              child: TextWidget.subText(
                text: ipo.companyName!,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                textOverflow: TextOverflow.ellipsis,
                fw: 0,
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(),
              child: InkWell(
                onTap: () => _onDRHPTap(),
                customBorder: const RoundedRectangleBorder(),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: TextWidget.subText(
                    text: 'DRHP',
                    theme: false,
                    fw: 2,
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildIPOTypeChip(),
      ],
    );
  }

  Widget _buildIPOTypeChip() {
    return TextWidget.paraText(
      text: "${ipo.ipoType}",
      theme: false,
      fw: 0,
      color: theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight,
    );
  }

  // Widget _buildDRHPButton() {
  //   return;
  // }

  void _onDRHPTap() {
    final String? drhpUrl = ipo.drhp;
    if (drhpUrl != null && drhpUrl.isNotEmpty) {
      _launchURL(drhpUrl);
    } else {
      debugPrint("DRHP link is missing.");
    }
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
