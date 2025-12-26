import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/screens/Mobile/ipo/ipo_explore_screens.dart';
import '../../../../res/res.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../utils/no_emoji_inputformatter.dart';

class IPOScreen extends StatefulWidget {
  final int? initialTabIndex;
  final bool? isIpo;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  const IPOScreen({super.key, this.initialTabIndex, this.isIpo, this.onBoundaryReached});

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
        final ipo = ref.watch(ipoProvide);

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: widget.isIpo == true
                ? _buildAppBar(context, theme, ipo)
                : null,
            body: IpoExploreScreens(
              theme: theme,
              initialTabIndex: widget.initialTabIndex,
              onBoundaryReached: widget.onBoundaryReached,
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context, ThemesProvider theme, IPOProvider ipo) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: theme.isDarkMode
                ? colors.splashColorDark
                : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 18,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            ),
          ),
        ),
      ),
      elevation: 0,
      centerTitle: false,
      titleSpacing: -8,
      title: TextWidget.titleText(
          text: "IPO",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: _SearchBarSection(
          theme: theme,
          ipo: ipo,
        ),
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  final ThemesProvider theme;
  final IPOProvider ipo;

  const _SearchBarSection({
    required this.theme,
    required this.ipo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: SizedBox(
            height: 40,
            child: TextFormField(
              controller: ipo.ipocommonsearchcontroller,
              style: TextWidget.textStyle(
                  fontSize: 16,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                UpperCaseTextFormatter(),
                NoEmojiInputFormatter(),
                FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
              ],
              decoration: InputDecoration(
                  hintText: "Search",
                   hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                     fw: 0,
                                    ),
                  fillColor: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                  filled: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(assets.searchIcon,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        fit: BoxFit.scaleDown,
                        width: 20),
                  ),
                  suffixIcon: ipo.ipocommonsearchcontroller.text.isNotEmpty
                      ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            highlightColor: theme.isDarkMode
                                ? colors.highlightDark
                                : colors.highlightLight,
                            onTap: () async {
                              ipo.clearCommonIpoSearch();
                              Future.delayed(const Duration(milliseconds: 150),
                                  () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              });
                            },
                            child: SvgPicture.asset(assets.removeIcon,
                                fit: BoxFit.scaleDown, width: 20, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                          ),
                        )
                      : const SizedBox.shrink(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20)),
                  disabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20))),
              onChanged: (value) {
                ipo.searchCommonIpo(value, context);
              },
            ),
          )),
        ],
      ),
    );
  }
}
