import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../provider/index_list_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/no_data_found.dart'; 

class LogMessage extends ConsumerWidget {
  const LogMessage({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final logMessage = watch(indexListProvider).logError;
 final theme =context.read(themeProvider);
    return Scaffold(
    
      appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(), 
          elevation: 0.2,
          
          
          title: Text('Log Message',
              style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w600)),
          ),
      body: logMessage.isEmpty
          ? const Center(child: NoDataFound())
          : ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0);
              },
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    dense: true,
                    title: Text("${logMessage[index]["type"]}",style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                    subtitle: Text("${logMessage[index]["Error"]}",style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)));
              },
              itemCount: logMessage.length,
            ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
