import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../locator/constant.dart'; 
import '../../../models/tv_chart_model/chart_types.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/scroll_behavior.dart'; 

class ChartTypeBottomSheet extends ConsumerWidget {
  const ChartTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    return Container(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      child: Column(
        children: [
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                ListTile(
                    title: Text("Chart Types",
                        style: textStyle(
                            !theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            14,
                            FontWeight.w500)),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.clear,
                        color: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                      ),
                    )),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ScrollConfiguration(
                behavior: ScrollBehaviors(),
                child: GridView.count(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3.5,
                    children: List.generate(ChartTypeModel.categories.length,
                        (index) {
                      return InkWell(
                        onTap: () async {
                          await ConstantName.webViewController.evaluateJavascript(
                              source:
                                  "window.tvWidget.activeChart().setChartType($index)");
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: ListTile(
                            dense: true,
                            minLeadingWidth: 0,
                            horizontalTitleGap: 10,
                            leading: SvgPicture.asset(
                                ChartTypeModel.categories[index].chartIcon,
                                color: !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite),
                            title: Text(
                              ChartTypeModel.categories[index].chartType,
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    })),
              ),
            ),
          )
          // )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
