import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AutomobileOptions extends StatefulWidget {
  const AutomobileOptions({super.key});

  @override
  State<AutomobileOptions> createState() => _AutomobileOptionsState();
}

class _AutomobileOptionsState extends State<AutomobileOptions> {
  List<OptionsData> optiondata = [
    OptionsData(
      corp: 'CALL',
      optionname: 'Maruti 10000',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'Maruti 9700',
      optionvalue: '₹236.05',
      optionperchange: '(-1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'Maruti 9500',
      optionvalue: '₹236.05',
      optionperchange: '(-1.65%)',
    ),
    OptionsData(
      corp: 'CALL',
      optionname: 'Maruti 12000',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'Tatamotors 530',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'CALL',
      optionname: 'Tatamotors 560',
      optionvalue: '₹236.05',
      optionperchange: '(-1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'Tatamotors 580',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'Tatamotors 520',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'CALL',
      optionname: 'M&M 1400',
      optionvalue: '₹236.05',
      optionperchange: '(-1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'M&M 1420',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'PUT',
      optionname: 'M&M 1440',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
    OptionsData(
      corp: 'CALL',
      optionname: 'M&M 1410',
      optionvalue: '₹236.05',
      optionperchange: '(+1.65%)',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        elevation: .4,
        backgroundColor: const Color(0xffFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xff000000)),
        leadingWidth: 40,
        title: Text(
          'Top Automobile Options',
          style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
        ),
        actions: const [
          Icon(
            Icons.more_vert,
            color: Color(0xff000000),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 8),
                                decoration: BoxDecoration(
                                    color: const Color(0xffF1F3F8),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  optiondata[index].corp,
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff666666),
                                      letterSpacing: 0.9),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                optiondata[index].optionname,
                                style: textStyle(
                                    const Color(0xff000000), 14, FontWeight.w600),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                optiondata[index].optionvalue,
                                style: textStyle(
                                    const Color(0xff000000), 12, FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                optiondata[index].optionperchange,
                                style: textStyle(
                                    optiondata[index].optionperchange ==
                                            '(+1.65%)'
                                        ? const Color(0xff43A833)
                                        : const Color(0xffFF1717),
                                    12,
                                    FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: Color(0xffDDDDDD),
                      ),
                    );
                  },
                  itemCount: optiondata.length),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: screenWidth,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Color(0xffDDDDDD)),
                top: BorderSide(color: Color(0xffDDDDDD)),
              )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/img/options_img.svg'),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'More options',
                    style:
                        textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class OptionsData {
  String corp;
  String optionname;
  String optionvalue;
  String optionperchange;
  OptionsData({
    required this.corp,
    required this.optionname,
    required this.optionperchange,
    required this.optionvalue,
  });
}
