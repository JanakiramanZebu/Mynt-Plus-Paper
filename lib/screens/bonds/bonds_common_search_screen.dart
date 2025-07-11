import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

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
      leadingWidth: _leadingWidth,
      centerTitle: false,
      titleSpacing: -8,
      leading: _buildBackButton(context, bonds, theme),
      shadowColor: const Color(0xffECEFF3),
      title: _buildSearchField(context, bonds, theme),
    );
  }

  Widget _buildBackButton(
      BuildContext context, BondsProvider bonds, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          bonds.clearCommonBondsSearch();
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_back_ios,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            size: _iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(
      BuildContext context, BondsProvider bonds, ThemesProvider theme) {
    return Container(
      height: _searchFieldHeight,
      padding: _searchPadding,
      child: TextFormField(
        autofocus: true,
        controller: bonds.bondscommonsearchcontroller,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500),
        decoration: InputDecoration(
            fillColor:
                theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            filled: true,
            hintStyle: textStyle(_hintColor, 14, FontWeight.w500),
            prefixIconColor: _iconColor,
            prefixIcon: Padding(
              padding: _iconPadding,
              child: SvgPicture.asset(assets.searchIcon,
                  color: _iconColor, fit: BoxFit.contain, width: 20),
            ),
            suffixIcon: InkWell(
              onTap: () => bonds.clearCommonBondsSearch(),
              child: Padding(
                padding: _iconPadding,
                child: SvgPicture.asset(assets.removeIcon,
                    fit: BoxFit.scaleDown, width: 20),
              ),
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(_borderRadius)),
            disabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(_borderRadius)),
            hintText: "Search Bonds",
            contentPadding: const EdgeInsets.only(top: 20),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(_borderRadius))),
        onChanged: (value) => bonds.searchCommonBonds(value, context),
      ),
    );
  }

  Widget _buildBody(BondsProvider bonds, ThemesProvider theme) {
    return SingleChildScrollView(
      child: bonds.bondsCommonSearchList.isNotEmpty
          ? _buildSearchResults(bonds, theme)
          : const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: _noDataPadding,
                child: NoDataFound(),
              ),
            ),
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
                            FontWeight.w500),
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
