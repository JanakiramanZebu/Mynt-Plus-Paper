import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';

class MfCategory extends ConsumerWidget {
  const MfCategory({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);

    final mfData = watch(mfProvider);
    return Container(
      height: 68,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mfData.mfCategorys.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(onTap: (){

            mfData.chngMFCategory("${mfData.mfCategorys[index].name}");
          },
            child: Container(
              width: 142,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xffEEF0F2), width: 1.5),
                  color: mfData.mfCategorys[index].name == mfData.mfCategory ? const Color(0xffF1F3F8) : null),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${mfData.mfCategorys[index].name}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500)),
                  const Divider(
                      endIndent: 80,
                      height: 16,
                      color: Color(0xff000000),
                      thickness: 1.5),
                  Text("${mfData.mfCategorys[index].length}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                          const Color(0xff999999), 12, FontWeight.w500)),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 12);
        },
      ),
    );
  }
}
