import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../res/res.dart';
import '../../../sharedWidget/nofitication_coustom_switch.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notifiydata> notifydata = [
    Notifiydata(
      topic: 'News & Market Updates',
    ),
    Notifiydata(
      topic: 'Stock & Portfolio Updates',
    ),
    Notifiydata(
      topic: 'Account Reminders EQ',
    ),
    Notifiydata(
      topic: 'Educational- Stock Mkt',
    ),
    Notifiydata(
      topic: 'Whats New on Zebu \nTrade Stocks',
    ),
    Notifiydata(
      topic: 'Feedback & Review- \nStock Market',
    ),
    Notifiydata(
      topic: 'Account Reminders- \nZebu Trade Stocks',
    )
  ];
  List<bool> isActiveBtn1 = [false, true, false, true, true, false, true];
  List<bool> isActiveBtn2 = [true, false, true, true, false, true, true];
  List<bool> isActiveBtn3 = [true, false, true, true, false, true, true];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(assets.backArrow),
            ),
          ),
          backgroundColor: const Color(0xffFFFFFF),
          elevation: 0.3,
          iconTheme: const IconThemeData(color: Color(0xff000000)),
          ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Preferences',
                  style:
                      textStyle(const Color(0xff000000), 18, FontWeight.w600),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'View bank details and add new banks.',
                  style:
                      textStyle(const Color(0xff666666), 14, FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xffFAFBFF)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category',
                  style:
                      textStyle(const Color(0xff666666), 12, FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      'E-mail',
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      'SMS',
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      'On Site',
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
              itemCount: notifydata.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 198,
                            child: Text(
                              notifydata[index].topic,
                              style: textStyle(
                                  const Color.fromRGBO(0, 0, 0, 0.80),
                                  14,
                                  FontWeight.w600),
                            ),
                          ),
                          Flexible(
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(
                                  width: 2,
                                ),
                                NotifyCustomSwitch(
                                  value: isActiveBtn1[index],
                                  onChanged: (value) {
                                    print("VALUE : $value");
                                    setState(() {
                                      isActiveBtn1[index] = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                NotifyCustomSwitch(
                                  value: isActiveBtn2[index],
                                  onChanged: (value) {
                                    print("VALUE : $value");
                                    setState(() {
                                      isActiveBtn2[index] = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                NotifyCustomSwitch(
                                  value: isActiveBtn3[index],
                                  onChanged: (value) {
                                    print("VALUE : $value");
                                    setState(() {
                                      isActiveBtn3[index] = value;
                                    });
                                  },
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 17,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(0xffDDDDDD),
                      )
                    ],
                  ),
                );
              })
        ]),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

class Notifiydata {
  String topic;

  Notifiydata({
    required this.topic,
  });
}
