import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../provider/option_strategy.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';

class StrategyListBottomSheet extends ConsumerWidget {
  const StrategyListBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final optStrgy = ref.watch(optStrategyProvider);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? Colors.black : Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0))
          ]),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: 
                            
                             TextWidget.subText(
                      text:"Strategies" ,
                      
                      theme: theme.isDarkMode,
                      fw: 1),
                            
                            
                            
                            ),
            const SizedBox(height: 10),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider),
            Expanded(
                child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    children: [
                


                               TextWidget.subText(
                      text:"Bullish" ,
                
                      theme: theme.isDarkMode,
                      fw: 1),
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 11.0,
                              childAspectRatio: .8,
                              mainAxisSpacing: 10.0),
                      itemCount: optStrgy.strategyData!.bullish!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await optStrgy.strgStikeSelection("Bullish",
                                "${optStrgy.strategyData!.bullish![index].name}");
                            Navigator.pop(context);
                          },
                          child: Column(children: [
                            SvgPicture.asset(
                                height: 70,
                                "${optStrgy.strategyData!.bullish![index].img}"),
                            const SizedBox(height: 12),
                            Text(
                                " ${optStrgy.strategyData!.bullish![index].name}",
                                overflow: TextOverflow.ellipsis)
                          ]),
                        );
                      }),
                 


                               TextWidget.subText(
                      text: "Bearish",                    
                      theme: theme.isDarkMode,
                      fw: 1),
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 11.0,
                              childAspectRatio: .8,
                              mainAxisSpacing: 10),
                      itemCount: optStrgy.strategyData!.bearish!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await optStrgy.strgStikeSelection("Bearish",
                                "${optStrgy.strategyData!.bearish![index].name}");
                            Navigator.pop(context);
                          },
                          child: Column(children: [
                            SvgPicture.asset(
                                height: 70,
                                "${optStrgy.strategyData!.bearish![index].img}"),
                            const SizedBox(height: 12),
                            Text(
                                " ${optStrgy.strategyData!.bearish![index].name}",
                                overflow: TextOverflow.ellipsis)
                          ]),
                        );
                      }),
                  
                               TextWidget.subText(
                      text: "Neutral",
                   
                      theme: theme.isDarkMode,
                      fw: 1),
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 11.0,
                              childAspectRatio: .8,
                              mainAxisSpacing: 10),
                      itemCount: optStrgy.strategyData!.neutral!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await optStrgy.strgStikeSelection("Neutral",
                                "${optStrgy.strategyData!.neutral![index].name}");
                            Navigator.pop(context);
                          },
                          child: Column(children: [
                            SvgPicture.asset(
                                height: 70,
                                "${optStrgy.strategyData!.neutral![index].img}"),
                            const SizedBox(height: 12),
                            Text(
                                " ${optStrgy.strategyData!.neutral![index].name}",
                                overflow: TextOverflow.ellipsis)
                          ]),
                        );
                      })
                ]))
          ]),
    );
  }
}
