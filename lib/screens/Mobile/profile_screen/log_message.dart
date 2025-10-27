import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/index_list_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/no_data_found.dart';

class LogMessage extends ConsumerWidget {
  const LogMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logMessage = ref.watch(indexListProvider).logError;
    final theme = ref.read(themeProvider);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        titleSpacing: 6,
        centerTitle: false,
        leading: const CustomBackBtn(),
        elevation: 0.2,
        title: TextWidget.subText(
            text: 'Log Message',
            theme: false,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            fw: 1),
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
                    title: TextWidget.subText(
                        text: "${logMessage[index]["type"]}",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 0),
                    subtitle: TextWidget.subText(
                        text: "${logMessage[index]["Error"]}",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 0));
              },
              itemCount: logMessage.length,
            ),
    );
  }
}
