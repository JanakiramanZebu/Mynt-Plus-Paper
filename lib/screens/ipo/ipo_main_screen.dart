import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/screens/ipo/ipo_explore_screens.dart';
import '../../../res/res.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';

class IPOScreen extends StatefulWidget {
  const IPOScreen({super.key});

  @override
  State<IPOScreen> createState() => _IPOmainScreenState();
}

class _IPOmainScreenState extends State<IPOScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final theme = ref.watch(themeProvider);
        
        return Scaffold(
          appBar: _buildAppBar(context, theme),
          body: IpoExploreScreens(theme: theme),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemesProvider theme) {
    return AppBar(
      leading: _BackButton(theme: theme),
      elevation: 0,
      centerTitle: false,
      titleSpacing: -8,
      shadowColor: const Color(0xffECEFF3),
      title: _SearchBarSection(theme: theme),
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: fWeight,
        color: color,
        fontSize: fontSize,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final ThemesProvider theme;

  const _BackButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.arrow_back_ios,
          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          size: 22,
        ),
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  final ThemesProvider theme;

  const _SearchBarSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 45,
              child: SearchBar(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.pushNamed(context, Routes.iposearchscreen);
                },
                hintText: "Search IPO",
                hintStyle: WidgetStateProperty.all(
                  const TextStyle(
                    color: Color(0xff69758F),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide.none,
                  ),
                ),
                textStyle: WidgetStateProperty.all(
                  _IPOmainScreenState._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500,
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SvgPicture.asset(
                    assets.searchIcon,
                    color: const Color(0xff586279),
                    fit: BoxFit.contain,
                    width: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
