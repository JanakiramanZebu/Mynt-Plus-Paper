import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StockList extends StatefulWidget {
  const StockList({super.key});

  @override
  State<StockList> createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  List<Cars> dummyData = [
    Cars(
      model: '  Reliance Industries Ltd',
      speed: '24.75',
    ),
    Cars(
      model: '- Hindustan Petroleum Corp Ltd',
      speed: '12.86',
    ),
    Cars(
      model: '- HDFC Bank Limited',
      speed: '12.86',
    ),
    Cars(
      model: '- Chennai Petroleum Corporation Ltd',
      speed: '12.86',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 50,
                child: ListTile(
                  title: Text(
                    dummyData[index].model,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff000000)),
                  ),
                  trailing: Text(
                    dummyData[index].speed,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Color(0xffDDDDDD),
            ),
          );
        });
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}

class Cars {
  String model;
  String speed;

  Cars({required this.model, required this.speed});
}
