import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../locator/constant.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/scroll_behavior.dart'; 

class ResolutionBottom extends StatefulWidget {
  const ResolutionBottom({super.key});

  @override
  State<ResolutionBottom> createState() => _ResolutionBottomState();
}

class _ResolutionBottomState extends State<ResolutionBottom> {
  // List<String> dateRange = ["1D", "5D", "1M", "3M", "6M", "1Y", "5Y"];
  List<String> minute = ["1m", "3m", "5m", "15m", "30m", "45m"];
  List<String> minuteDuration = ["1", "3", "5", "15", "30", "45"];
  List<String> hour = ["1h", "2h", "3h", "4h"];
  List<String> hourDuration = ["60", "120", "180", "240"];
  List<String> day = ["1D", "1W", "1M"];

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
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
              physics: const NeverScrollableScrollPhysics
              (),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                ListTile(
                    title: Text("Interval",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.clear,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
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
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    // Sizer.qtr(),
                    Text("Minutes",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    minutes(theme),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider),
                    Text("Hours",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    hours(theme),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider),
                    Text("Days",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    days(theme)
                  ],
                ),
              ),
            ),
          )
          // )
        ],
      ),
    );
  }

  Consumer minutes(ThemesProvider theme) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final tvChart = watch(marketWatchProvider);
      return SizedBox(
        height: 80,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          scrollDirection: Axis.horizontal,
          itemCount: minute.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                tvChart.activeResolution(minute[index]);
                tvChart.activeDuration(minuteDuration[index]);
                await ConstantName.webViewController!.evaluateJavascript(
                    source:
                        "window.tvWidget.activeChart().setResolution('${minuteDuration[index]}')");
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                    color: theme.isDarkMode && minute[index] == tvChart.duration
                        ? colors.colorWhite
                        : minute[index] == tvChart.duration
                            ? colors.colorBlack
                            : colors.darkGrey,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Text(
                    minute[index],
                    style: textStyle(
                        theme.isDarkMode && minute[index] == tvChart.duration
                            ? colors.colorBlack
                            : minute[index] == tvChart.duration
                                ? colors.colorWhite
                                : colors.colorGrey,
                        13,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              width: 12,
            );
          },
        ),
      );
    });
  }

  Consumer hours(ThemesProvider theme) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final tvChart = watch(marketWatchProvider);
      return SizedBox(
        height: 80,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          scrollDirection: Axis.horizontal,
          itemCount: hour.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                tvChart.activeResolution(hour[index]);
                tvChart.activeDuration(hourDuration[index]);
                await ConstantName.webViewController!.evaluateJavascript(
                    source:
                        "window.tvWidget.activeChart().setResolution('${hourDuration[index]}')");
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                    color: theme.isDarkMode && hour[index] == tvChart.duration
                        ? colors.colorWhite
                        : hour[index] == tvChart.duration
                            ? colors.colorBlack
                            : colors.darkGrey,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Text(
                    hour[index],
                    style: textStyle(
                        theme.isDarkMode && hour[index] == tvChart.duration
                            ? colors.colorBlack
                            : hour[index] == tvChart.duration
                                ? colors.colorWhite
                                : colors.colorGrey,
                        13,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              width: 12,
            );
          },
        ),
      );
    });
  }

  Consumer days(ThemesProvider theme) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final tvChart = watch(marketWatchProvider);
      return SizedBox(
        height: 80,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          scrollDirection: Axis.horizontal,
          itemCount: day.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                tvChart.activeResolution(day[index]);
                tvChart.activeDuration(day[index]);
                await ConstantName.webViewController!.evaluateJavascript(
                    source:
                        "window.tvWidget.activeChart().setResolution('${day[index]}')");
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                    color: theme.isDarkMode && day[index] == tvChart.duration
                        ? colors.colorWhite
                        : day[index] == tvChart.duration
                            ? colors.colorBlack
                            : colors.darkGrey,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Text(
                    day[index],
                    style: textStyle(
                        theme.isDarkMode && day[index] == tvChart.duration
                            ? colors.colorBlack
                            : day[index] == tvChart.duration
                                ? colors.colorWhite
                                : colors.colorGrey,
                        13,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              width: 12,
            );
          },
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
