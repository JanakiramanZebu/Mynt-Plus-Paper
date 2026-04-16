import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/routes/route_names.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import 'invest_ipo_banner/invest_banner_ui.dart';
import 'preclose_ipo/preclose_ipo_screen.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';

class IPOSubScreen extends StatefulWidget {
  const IPOSubScreen({super.key});

  @override
  State<IPOSubScreen> createState() => _IPOSubScreenState();
}

class _IPOSubScreenState extends State<IPOSubScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final ipo = ref.watch(ipoProvide);
        
        return Column(
          children: [
            _HeaderSection(ref: ref),
            const SizedBox(height: 12),
            _TabButtonsSection(ipo: ipo, theme: theme),
            Expanded(
              child: _ContentSection(ipo: ipo),
            ),
          ],
        );
      },
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

class _HeaderSection extends StatelessWidget {
  final WidgetRef ref;

  const _HeaderSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const InvestIPO(),
          const SizedBox(height: 13),
          _ViewBidsButton(ref: ref),
        ],
      ),
    );
  }
}

class _ViewBidsButton extends StatelessWidget {
  final WidgetRef ref;

  const _ViewBidsButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: () async {
          Future.delayed(const Duration(microseconds: 100), () async {
            await ref.read(ipoProvide).getipoorderbookmodel(context, true);
          });
          Navigator.pushNamed(context, Routes.ipoorderbook);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(width: 1.2, color: colors.colorBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/explore/firefox.svg',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "View my bids",
                style: _IPOSubScreenState._textStyle(
                  colors.colorBlue,
                  16,
                  FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: colors.colorBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButtonsSection extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;

  const _TabButtonsSection({
    required this.ipo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
      height: 52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            width: 0,
          ),
          top: BorderSide(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            width: 0,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ipo.inIPOTabNameBtns.length,
        itemBuilder: (context, index) {
          return _TabButton(
            ipo: ipo,
            theme: theme,
            index: index,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;
  final int index;

  const _TabButton({
    required this.ipo,
    required this.theme,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = ipo.inIPOTabNameAct == ipo.inIPOTabNameBtns[index]['btnName'];
    
    return ElevatedButton(
      onPressed: () async {
        ipo.chngDephBtn(ipo.inIPOTabNameBtns[index]['btnName']);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        backgroundColor: theme.isDarkMode
            ? isActive
                ? colors.colorbluegrey
                : const Color(0xffB5C0CF).withOpacity(.15)
            : isActive
                ? const Color(0xff000000)
                : const Color(0xffF1F3F8),
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "${ipo.inIPOTabNameBtns[index]['imgPath']}",
            color: theme.isDarkMode
                ? Color(isActive ? 0xff000000 : 0xffffffff)
                : Color(isActive ? 0xffffffff : 0xff000000),
          ),
          const SizedBox(width: 8),
          Text(
            "${ipo.inIPOTabNameBtns[index]['btnName']}",
            style: _IPOSubScreenState._textStyle(
              theme.isDarkMode
                  ? Color(isActive ? 0xff000000 : 0xffffffff)
                  : Color(isActive ? 0xffffffff : 0xff000000),
              12.5,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final IPOProvider ipo;

  const _ContentSection({required this.ipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ListView(
        children: [
          if (ipo.inIPOTabNameAct == "Live / Pre Open") ...[
            const MainSmeListCard()
          ] else if (ipo.inIPOTabNameAct == "Closed") ...[
            const ClosedIPOScreen()
          ] else if (ipo.inIPOTabNameAct == "Listed") ...[
            const IPOPerformance()
          ],
        ],
      ),
    );
  }
}
