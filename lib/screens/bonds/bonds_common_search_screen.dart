
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

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final bonds = watch(bondsProvider);
    final theme = watch(themeProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          leadingWidth: 40,
          centerTitle: false,
          titleSpacing: -8,
          leading: Padding(
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
                  size: 22,
                ),
              ),
            ),
          ),         
          
          //  InkWell(
          //     onTap: () {
          //       bonds.clearCommonBondsSearch();
          //       Navigator.pop(context);
          //     },
          //     child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 9),
          //         child: SvgPicture.asset(assets.backArrow,
          //             color: theme.isDarkMode
          //                 ? colors.colorWhite
          //                 : colors.colorBlack))),
          shadowColor: const Color(0xffECEFF3),
          title: Container(
              height: 62,
             padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: TextFormField(
                autofocus: true,
                controller: bonds.bondscommonsearchcontroller,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500),
                decoration: InputDecoration(
                    fillColor: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    filled: true,
                    hintStyle: textStyle(
                        const Color(0xff69758F), 14, FontWeight.w500),
                    prefixIconColor: const Color(0xff586279),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SvgPicture.asset(assets.searchIcon,
                          color: const Color(0xff586279),
                          fit: BoxFit.contain,
                          width: 20),
                    ),
                    suffixIcon: InkWell(
                      onTap: () async {
                        bonds.clearCommonBondsSearch();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SvgPicture.asset(assets.removeIcon,
                            fit: BoxFit.scaleDown, width: 20),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    disabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    hintText: "Search Bonds",
                    contentPadding: const EdgeInsets.only(top: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20))),
                onChanged: (value) async {
                  bonds.searchCommonBonds(value, context);
                },
              )),

          // Text("IPO Search",
          //     style: textStyles.appBarTitleTxt.copyWith(
          //         color: theme.isDarkMode
          //             ? colors.colorWhite
          //             : colors.colorBlack))
        ),
        body: SingleChildScrollView(
          child: bonds.bondsCommonSearchList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bonds.bondsCommonSearchList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () async {
                         
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.symmetric(
                                    horizontal: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffEEF0F2),
                                        width: 1.5),
                                    vertical: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffEEF0F2),
                                        width: 1.5))),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                              Text(
                                                  "${bonds.bondsCommonSearchList[index].companyName}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                              const SizedBox(height: 4),
                                             
                                            ])),
                                      ]),
                                ])));
                  },
                )
              : const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 250),
                    child: NoDataFound(),
                  ),
                ),
        ),
      ),
    );
  }
}
