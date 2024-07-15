import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../locator/constant.dart'; 
import '../../../models/tv_chart_model/drawings.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/scroll_behavior.dart'; 
class DrawingBottomSheet extends ConsumerWidget {
  const DrawingBottomSheet({
    super.key,
  });

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
                    title: Text("Drawings",
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    drawingHeader(theme),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Trend lines",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  TrendingLineModel.trendingLineList.length,
                                  (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${TrendingLineId.trendingLineIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      dense: true,
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      leading: SvgPicture.asset(
                                          TrendingLineModel
                                              .trendingLineList[index]
                                              .drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        TrendingLineModel
                                            .trendingLineList[index]
                                            .drawingName,
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
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("GANN & Fibnocci",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  FibonacciModel.fibonacciList.length, (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${FibonacciId.fibonacciIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      dense: true,
                                      leading: SvgPicture.asset(
                                          FibonacciModel
                                              .fibonacciList[index].drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        FibonacciModel
                                            .fibonacciList[index].drawingName,
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
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Geometric shapes",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  GeometricModel.geometricList.length, (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${GeometricId.geometricIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      dense: true,
                                      leading: SvgPicture.asset(
                                          GeometricModel
                                              .geometricList[index].drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        GeometricModel
                                            .geometricList[index].drawingName,
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
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Annotation",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  AnnotationModel.annotationList.length,
                                  (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${AnnotationId.annotationIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      dense: true,
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      leading: SvgPicture.asset(
                                          AnnotationModel.annotationList[index]
                                              .drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        AnnotationModel
                                            .annotationList[index].drawingName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            14,
                                            FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Patterns",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  PatternModel.patternList.length, (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${PatternId.patternIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      dense: true,
                                      leading: SvgPicture.asset(
                                          PatternModel
                                              .patternList[index].drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        PatternModel
                                            .patternList[index].drawingName,
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
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Prediction & Measurement",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  PredictionModel.predictionModelList.length,
                                  (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${PredictionId.predictionIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      dense: true,
                                      leading: SvgPicture.asset(
                                          PredictionModel
                                              .predictionModelList[index]
                                              .drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        PredictionModel
                                            .predictionModelList[index]
                                            .drawingName,
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
                        ]),
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        iconColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        initiallyExpanded: true,
                        title: Text("Visuals",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                14,
                                FontWeight.w600)),
                        children: [
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 3.5,
                              children: List.generate(
                                  VisualModel.visualList.length, (index) {
                                return InkWell(
                                  onTap: () async {
                                    await ConstantName.webViewController
                                        .evaluateJavascript(
                                            source:
                                                "window.tvWidget.selectLineTool('${VisualId.visualIdList[index].drawingName}')");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ListTile(
                                      minLeadingWidth: 0,
                                      horizontalTitleGap: 10,
                                      dense: true,
                                      leading: SvgPicture.asset(
                                          VisualModel
                                              .visualList[index].drawingIcon,
                                          color: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite),
                                      title: Text(
                                        VisualModel
                                            .visualList[index].drawingName,
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
                        ]),
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

  SizedBox drawingHeader(ThemesProvider theme) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 8),
        scrollDirection: Axis.horizontal,
        itemCount: DrawingModel.drawingList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
              await ConstantName.webViewController.evaluateJavascript(
                  source:
                      "window.tvWidget.selectLineTool('${DrawingId.drawingIdList[index].drawingId}')");

              Navigator.pop(context);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(DrawingModel.drawingList[index].drawingIcon,
                      color: !theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite),
                  Text(
                    DrawingModel.drawingList[index].drawingName,
                    style: textStyle(
                        !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        14,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
