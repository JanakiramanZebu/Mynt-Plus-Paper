import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/global_state_text.dart';

import 'package:mynt_plus/sharedWidget/nofitication_coustom_switch.dart';

class ProductSettings extends StatefulWidget {
  const ProductSettings({super.key});

  @override
  State<ProductSettings> createState() => _ProductSettingsState();
}

class _ProductSettingsState extends State<ProductSettings> {
  List<bool> isActiveOrder = [
    true,
    true,
    false,
    true,
    true,
    false,
    false,
    true
  ];
  List<navSettings> navset = [
    navSettings(
      topic: 'Stocks',
    ),
    navSettings(
      topic: 'Mutual Funds',
    ),
    navSettings(
      topic: 'Future & Option',
    ),
    navSettings(
      topic: 'Watchlist',
    ),
    navSettings(
      topic: 'IPOs',
    ),
    navSettings(
      topic: 'Bonds',
    ),
    navSettings(
      topic: 'Commodities',
    ),
    navSettings(
      topic: 'Currency',
    )
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            width: screenWidth,
            color: const Color(0xffFAFBFF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.paraText(
                  text: 'Type',
                  theme: false,
                  color: const Color(0xff666666),
                  fw: 00,
                ),
                TextWidget.paraText(
                  text: 'Status',
                  theme: false,
                  color: const Color(0xff666666),
                  fw: 0,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 21,
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: navset.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.subText(
                            text: navset[index].topic,
                            theme: false,
                            color: isActiveOrder[index]
                                ? const Color(0xff666666)
                                : const Color(0xff000000),
                            fw: 1,
                          ),
                          NotifyCustomSwitch(
                            value: isActiveOrder[index],
                            onChanged: (value) {
                              print("VALUE : $value");
                              setState(() {
                                isActiveOrder[index] = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(0xffDDDDDD),
                      )
                    ],
                  ),
                );
              }),
          const SizedBox(
            height: 15,
          ),
          TextWidget.paraText(
            text: 'You can select up-to 5 options to display on top nav bar ',
            theme: false,
            color: const Color(0xff666666),
            fw: 0,
          )
        ],
      ),
    );
  }
}

class navSettings {
  String topic;

  navSettings({
    required this.topic,
  });
}
