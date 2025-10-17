import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../res/global_state_text.dart';

class BondsCommonSearch extends ConsumerWidget {
  const BondsCommonSearch({super.key});

  // Static constants for better performance
  static const double _appBarElevation = 0.2;
  static const double _leadingWidth = 40.0;
  static const double _iconSize = 22.0;
  static const double _searchFieldHeight = 62.0;
  static const double _borderRadius = 20.0;
  static const EdgeInsets _searchPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 10);
  static const EdgeInsets _iconPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets _listPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const EdgeInsets _noDataPadding = EdgeInsets.only(top: 250);
  static const Color _iconColor = Color(0xff586279);
  static const Color _hintColor = Color(0xff69758F);
  static const Color _borderColor = Color(0xffEEF0F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonds = ref.watch(bondsProvider);
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(context, bonds, theme),
        body: _buildBody(bonds, theme),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, BondsProvider bonds, ThemesProvider theme) {
    return AppBar(
      elevation: _appBarElevation,
      leadingWidth: 48,
      centerTitle: false,
      titleSpacing: 0,
      leading: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.black.withOpacity(0.15),
          highlightColor: Colors.black.withOpacity(0.08),
          onTap: () {
            bonds.clearCommonBondsSearch();
            Navigator.pop(context);
          },
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 18,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      shadowColor: const Color(0xffECEFF3),
      title: _buildSearchField(context, bonds, theme),
    );
  }

  Widget _buildSearchField(
      BuildContext context, BondsProvider bonds, ThemesProvider theme) {
    final controller = bonds.bondscommonsearchcontroller;
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 8, bottom: 7),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colors.searchBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            SvgPicture.asset(
              assets.searchIcon,
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                autofocus: true,
                controller: controller,
                style: TextWidget.textStyle(
                  fontSize: 14,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Search Bonds",
                  hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                ),
                onChanged: (value) => bonds.searchCommonBonds(value, context),
              ),
            ),
            if (controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => bonds.clearCommonBondsSearch(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        assets.removeIcon,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BondsProvider bonds, ThemesProvider theme) {
    return SingleChildScrollView(
      child: bonds.bondsCommonSearchList.isNotEmpty
          ? _buildSearchResults(bonds, theme)
          : const Center(child: NoDataFound()),
    );
  }

  Widget _buildSearchResults(BondsProvider bonds, ThemesProvider theme) {
    return ListView.builder(
      shrinkWrap: true,
      padding: _listPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bonds.bondsCommonSearchList.length,
      itemBuilder: (context, index) =>
          _buildSearchItem(context, bonds, theme, index),
    );
  }

  Widget _buildSearchItem(BuildContext context, BondsProvider bonds,
      ThemesProvider theme, int index) {
    final item = bonds.bondsCommonSearchList[index];

    return InkWell(
      onTap: () async {
        // Item tap action would go here
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(
                    color: theme.isDarkMode ? colors.darkGrey : _borderColor,
                    width: 1.5),
                vertical: BorderSide(
                    color: theme.isDarkMode ? colors.darkGrey : _borderColor,
                    width: 1.5))),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item.symbol ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            0),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
