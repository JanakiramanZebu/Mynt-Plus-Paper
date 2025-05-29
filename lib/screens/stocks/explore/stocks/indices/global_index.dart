import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart'; 
import '../../../../../models/indices/global_indices_model.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/res.dart';

class GlobalIndices extends ConsumerStatefulWidget {
  final List<GlobalIndicesModel>? globalIndices;
  const GlobalIndices({super.key, this.globalIndices});

  @override
  ConsumerState<GlobalIndices> createState() => _GlobalIndicesState();
}

class _GlobalIndicesState extends ConsumerState<GlobalIndices> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stocksProvide).getGlobalIndices();
      },
      child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.globalIndices!.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(color: Color(0xffDDE2E7), height: 0);
          },
          itemBuilder: (context, int idex) {
            return ListTile(
                onTap: () {
                  // Navigator.pushNamed(context, Routes.globalIndies,
                  //     arguments: widget.globalIndices![idex]);
                },
                dense: true,
                title: Row(
                  children: [
                    Image.network("${widget.globalIndices![idex].flagUrl}"),
                    const SizedBox(width: 8),
                    Text(widget.globalIndices![idex].name!.toUpperCase(),
                        style: textStyles.scripNameTxtStyle),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text("Vol. : ",
                            style: textStyle(
                                const Color(0xff999999), 13, FontWeight.w500)),
                        Text("${widget.globalIndices![idex].prevClose}",
                            style: textStyle(
                                const Color(0xff000000), 13, FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("₹${widget.globalIndices![idex].price}",
                          style: textStyle(
                              const Color(0xff000000), 14, FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text("${widget.globalIndices![idex].percentChange}%",
                          style: textStyle(
                              Color(widget.globalIndices![idex].percentChange!
                                      .startsWith("-")
                                  ? 0xffFF1717
                                  : widget.globalIndices![idex].percentChange ==
                                          "0.00"
                                      ? 0xff999999
                                      : 0xff43A833),
                              12,
                              FontWeight.w600))
                    ]));
          }),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
