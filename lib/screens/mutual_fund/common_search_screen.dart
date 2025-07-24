import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MfCommonSearch extends ConsumerStatefulWidget {
  const MfCommonSearch({super.key});

  @override
  ConsumerState<MfCommonSearch> createState() => _MfCommonSearchState();
}

class _MfCommonSearchState extends ConsumerState<MfCommonSearch> {
  late FocusNode searchFocusNode;

@override
void initState() {
  super.initState();
  searchFocusNode = FocusNode();

  searchFocusNode.addListener(() {
    if (searchFocusNode.hasFocus) {
      print("TextFormField is focused");
    }
  });

  // Automatically focus the field when screen opens
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).requestFocus(searchFocusNode);
  });
}

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme.isDarkMode;
    final deviceHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          leadingWidth: 38,
          centerTitle: false,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: TextFormField(
                focusNode: searchFocusNode,
                controller: mfData.mfsearchcontroller,
                style: textStyle(
                  isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600,
                ),
                decoration: InputDecoration(
                  fillColor: isDarkMode ? colors.darkGrey : colors.kColorLightGrey,
                  filled: true,
                  hintStyle: textStyle(
                    isDarkMode ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                    14,
                    FontWeight.w600,
                  ),
                  prefixIconColor: const Color(0xff586279),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Icon(
                      Icons.search,
                      color: isDarkMode ? Colors.white : Colors.black54,
                    ),
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: mfData.mfsearchcontroller,
                    builder: (context, value, child) {
                      return value.text.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                mfData.mfsearchcontroller.clear();
                                mfData.fetchmfCommonsearch("", context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: SvgPicture.asset(
                                  assets.removeIcon,
                                  fit: BoxFit.scaleDown,
                                  width: 20,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Search Mutual Fund",
                  contentPadding: const EdgeInsets.only(top: 20),
                ),
                onChanged: (value) async => mfData.fetchmfCommonsearch(value, context),
              ),
            ),
          ),
        ),
        body: TransparentLoaderScreen(
          isLoading: mfData.bestmfloader ?? false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (mfData.mutualFundsearchdata != null) ...[
                  mfData.mutualFundsearchdata!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: mfData.mutualFundsearchdata!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final fund = mfData.mutualFundsearchdata![index];
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    try {
                                      mfData.loaderfun();
                                      if (fund.iSIN != null) {
                                        await mfData.fetchFactSheet(fund.iSIN!);
                                        mfData.fetchmatchisan(fund.iSIN!);
                                        if (mfData.factSheetDataModel?.stat != "Not Ok") {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.mfStockDetail,
                                            arguments: fund,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            successMessage(context, "No Single Page Data"),
                                          );
                                          final jsondata = MutualFundList.fromJson(fund.toJson());
                                          Navigator.pushNamed(
                                            context,
                                            Routes.mforderScreen,
                                            arguments: jsondata,
                                          );
                                          mfData.orderchangetitle("One-time");
                                          mfData.chngOrderType("One-time");
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          successMessage(context, "Invalid fund data"),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        successMessage(context, "Error loading fund details"),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? "default"}.png",
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.6,
                                                    child: Text(
                                                      fund.mfsearchnamename ?? "",
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: textStyles.scripNameTxtStyle.copyWith(
                                                        color: isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    height: 18,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: [
                                                        CustomExchBadge(exch: fund.type ?? ""),
                                                        const SizedBox(width: 5),
                                                        CustomExchBadge(exch: fund.subtype ?? ""),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              splashRadius: 20,
                                              onPressed: () async {
                                                if (fund.iSIN != null) {
                                                  await mfData.fetchcommonsearchWadd(
                                                    fund.iSIN!,
                                                    fund.isAdd == true ? "delete" : "add",
                                                    context,
                                                    false,
                                                  );
                                                }
                                              },
                                              icon: SvgPicture.asset(
                                                color: colors.colorBlue,
                                                fund.isAdd == true
                                                    ? assets.bookmarkIcon
                                                    : assets.bookmarkedIcon,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          color: isDarkMode
                                              ? colors.darkColorDivider
                                              : colors.colorDivider,
                                          thickness: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 225),
                            child: SizedBox(
                              height: deviceHeight - 140,
                              child: const NoDataFound(),
                            ),
                          ),
                        )
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 225),
                      child: SizedBox(
                        height: deviceHeight - 140,
                        child: const NoDataFound(),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
