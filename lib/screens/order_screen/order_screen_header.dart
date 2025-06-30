import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
 
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';

class OrderScreenHeader extends ConsumerWidget {
  final OrderScreenArgs headerData;
  const OrderScreenHeader({super.key, required this.headerData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Update header data with real-time values
        if (snapshot.hasData && socketDatas.containsKey(headerData.token)) {
          final lp = socketDatas[headerData.token]['lp']?.toString();
          final pc = socketDatas[headerData.token]['pc']?.toString();
          
          if (lp != null && lp != "null") {
            headerData.ltp = lp;
          }
          
          if (pc != null && pc != "null") {
            headerData.perChange = pc;
          }
        }
        
        // Ensure LTP has a default value
        final ltp = headerData.ltp ?? "0.00";
        // Ensure perChange has a default value and isn't null
        final perChange = headerData.perChange ?? "0.00";
        
        // Determine color for percentage change
        Color percentageColor = colors.colorGrey;
        if (perChange.isNotEmpty) {
          if (perChange.startsWith("-")) {
            percentageColor = colors.darkred;
          } else if (perChange != "0.00") {
            percentageColor = colors.ltpgreen;
          }
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${ltp} ",
               style: textStyle(percentageColor, 16, FontWeight.w500)
            ),
            Text(
              " (${perChange}%)",
              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                12,
                FontWeight.w400),
            ),
          ],
        );
      }
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
