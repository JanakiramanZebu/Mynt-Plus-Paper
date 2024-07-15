import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TopCollection extends StatelessWidget {
  const TopCollection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Tradinganddemataccount> dematedata = [
      Tradinganddemataccount(
        topic: 'Pharma Track',
        info: 'Multicap',
        info1: 'longterm',
        logo: 'assets/icon/medicine 1.svg',
        risklogo: 'assets/icon/high_range.svg',
        riskname: 'Low Risk',
        min_invest: 'Min. Invest',
        min_value: '₹ 45,324',
        cagrs: '3y Cagr',
        cagrvalue: '23.2%',
        totalstock: 'Total stocks',
        stockcount: '14 stocks',
      ),
      Tradinganddemataccount(
        topic: 'Green Energy',
        info: 'Multicap',
        info1: 'longterm',
        logo: 'assets/icon/forest.svg',
        risklogo: 'assets/icon/high_range.svg',
        riskname: 'High Risk',
        min_invest: 'Min. Invest',
        min_value: '₹ 45,324',
        cagrs: '3y Cagr',
        cagrvalue: '23.2%',
        totalstock: 'Total stocks',
        stockcount: '14 stocks',
      ),
      Tradinganddemataccount(
        topic: 'Compound Wealth',
        info: 'Multicap',
        info1: 'longterm',
        logo: 'assets/icon/compound_wealth (1).svg',
        risklogo: 'assets/icon/high_range.svg',
        riskname: 'High Risk',
        min_invest: 'Min. Invest',
        min_value: '₹ 45,324',
        cagrs: '3y Cagr',
        cagrvalue: '23.2%',
        totalstock: 'Total stocks',
        stockcount: '14 stocks',
      ),
      Tradinganddemataccount(
        topic: 'Vision 2030',
        info: 'Multicap',
        info1: 'longterm',
        logo: 'assets/icon/binaculore.svg',
        risklogo: 'assets/icon/high_range.svg',
        riskname: 'High Risk',
        min_invest: 'Min. Invest',
        min_value: '₹ 45,324',
        cagrs: '3y Cagr',
        cagrvalue: '23.2%',
        totalstock: 'Total stocks',
        stockcount: '14 stocks',
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dematedata.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffCCCCCC)),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(dematedata[index].logo),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffCCCCCC)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(19))),
                              child: Row(
                                children: [
                                  SvgPicture.asset(dematedata[index].risklogo),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    dematedata[index].riskname,
                                    style: textStyle(const Color(0xff282B2F),
                                        11, FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffCCCCCC)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(19))),
                              child: SvgPicture.asset('assets/icon/wl.svg'),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      dematedata[index].topic,
                      style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xffF1F3F8),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            dematedata[index].info.toUpperCase(),
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff666666)),
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xffF1F3F8),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            dematedata[index].info1.toUpperCase(),
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff666666)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dematedata[index].min_invest.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  letterSpacing: 0.88,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff666666)),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              dematedata[index].min_value,
                              style: textStyle(
                                  const Color(0xff000000), 14, FontWeight.w500),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dematedata[index].cagrs.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  letterSpacing: 0.88,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff666666)),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              dematedata[index].cagrvalue,
                              style: textStyle(
                                  const Color(0xff43A833), 14, FontWeight.w500),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dematedata[index].totalstock.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  letterSpacing: 0.88,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff666666)),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              dematedata[index].stockcount,
                              style: textStyle(
                                  const Color(0xff000000), 14, FontWeight.w500),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 16,
              );
            },
          ),
        ),
        TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'See more',
                  style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icon/Icon (5).svg'),
              ],
            ))
      ],
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

class Tradinganddemataccount {
  String topic;
  String info;
  String info1;
  String logo;
  String risklogo;
  String riskname;
  String min_invest;
  String min_value;
  String cagrs;
  String cagrvalue;
  String totalstock;
  String stockcount;
  Tradinganddemataccount(
      {required this.topic,
      required this.info,
      required this.info1,
      required this.logo,
      required this.risklogo,
      required this.riskname,
      required this.min_invest,
      required this.min_value,
      required this.cagrs,
      required this.cagrvalue,
      required this.totalstock,
      required this.stockcount});
}
