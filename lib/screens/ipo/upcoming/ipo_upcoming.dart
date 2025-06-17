// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class UpcomingIpo extends StatelessWidget {
  const UpcomingIpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      final hasUpcomingIPOs = ipos.upcomingModel?.upcoming?.isNotEmpty ?? false;

      if (!hasUpcomingIPOs) {
        return _NoDataSection(devHeight: devHeight);
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UpcomingIPOList(
              upcomingIPOs: ipos.upcomingModel!.upcoming!,
              theme: theme,
            ),
          ],
        ),
      );
    });
  }

  static TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _NoDataSection extends StatelessWidget {
  final double devHeight;

  const _NoDataSection({required this.devHeight});

  @override
  Widget build(BuildContext context) {
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingIPOs.length,
      itemBuilder: (context, index) {
        return _UpcomingIPOItem(
          ipo: upcomingIPOs[index],
          theme: theme,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color: theme.isDarkMode
              ? colors.darkColorDivider
              : const Color(0xffECEDEE),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildCompanyInfo()),
          _buildDRHPButton(),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: Text(
            ipo.companyName!,
            overflow: TextOverflow.ellipsis,
            style: UpcomingIpo.textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildIPOTypeChip(),
      ],
    );
  }

  Widget _buildIPOTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ipo.ipoType == "SME"
            ? theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 243, 242, 174)
            : theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 251, 215, 148),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "${ipo.ipoType}",
        style: UpcomingIpo.textStyle(
          const Color(0xff666666),
          10,
          FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDRHPButton() {
    return GestureDetector(
      onTap: () => _onDRHPTap(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.open_in_new,
              size: 14,
              color: Color(0xFF0037B7),
            ),
            const SizedBox(width: 2),
            Text(
              'DRHP',
              style: UpcomingIpo.textStyle(
                const Color(0xFF0037B7),
                12,
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
