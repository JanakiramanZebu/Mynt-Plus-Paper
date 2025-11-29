import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/thems.dart';
import '../../../res/web_colors.dart';
import 'ipo_explore_screens_web.dart';

class IPOScreen extends StatefulWidget {
  final int? initialTabIndex;
  final bool? isIpo;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  const IPOScreen({super.key, this.initialTabIndex, this.isIpo, this.onBoundaryReached});

  @override
  State<IPOScreen> createState() => _IPOmainScreenState();
}

class _IPOmainScreenState extends State<IPOScreen> {
  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final theme = ref.watch(themeProvider);

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox.expand(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
              child: IpoExploreScreens(
                theme: theme,
                initialTabIndex: widget.initialTabIndex,
                onBoundaryReached: widget.onBoundaryReached,
              ),
            ),
          ),
        );
      },
    );
  }
}
