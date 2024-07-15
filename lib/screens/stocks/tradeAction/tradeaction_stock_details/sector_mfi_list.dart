import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EftMutualFundList extends StatefulWidget {
  const EftMutualFundList({super.key});

  @override
  State<EftMutualFundList> createState() => _EftMutualFundListState();
}

class _EftMutualFundListState extends State<EftMutualFundList> {
  List<Cars> dummyData = [
    Cars(
      listname: 'ICICI Prudential Bluechip Fund',
      value: '0.15%',
    ),
    Cars(
      listname: 'Mirae Asset Large Cap Fund',
      value: '0.34%',
    ),
    Cars(
      listname: 'HDFC Life Insurance Company Ltd ',
      value: '0.19%',
    ),
    Cars(
      listname: 'SBI Equity Hybrid Fund',
      value: '-0.03%',
    ),
    Cars(
      listname: 'Kotak Flexicap Fund - Growth',
      value: '-0.48%',
    )
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        dummyData[index].listname,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff000000)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        dummyData[index].value,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff000000)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Divider(
            color: Color(0xffECEDEE),
          ),
        );
      },
    );
  }
}

class Cars {
  String listname;
  String value;

  Cars({
    required this.listname,
    required this.value,
  });
}
