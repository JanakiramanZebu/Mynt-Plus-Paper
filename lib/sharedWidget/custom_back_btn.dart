import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

class CustomBackBtn extends ConsumerWidget {
  const CustomBackBtn({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  customBorder: const CircleBorder(),
                splashColor: theme.isDarkMode
                                                  ? colors.splashColorDark
                                                  : colors.splashColorLight,
                                              highlightColor: theme.isDarkMode
                                                  ? colors.highlightDark
                                                  : colors.highlightLight,
                  onTap: () {                  
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44, // Increased touch area
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      size: 18,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                ),
              );
  }
}
