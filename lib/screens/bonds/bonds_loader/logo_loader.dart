import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';

class LogoLoaderScreen extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LogoLoaderScreen({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final theme = ref.watch(themeProvider);
        
        return Stack(
          children: [
            child,
            if (isLoading) _LoadingOverlay(theme: theme),
          ],
        );
      },
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final ThemesProvider theme;

  const _LoadingOverlay({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: theme.isDarkMode
            ? colors.colorBlack.withOpacity(0.5)
            : colors.colorWhite.withOpacity(0.5),
        child: const Center(
          child: _LoadingIndicator(),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/icon/MYNT App Logo_v2.svg',
            width: 80,
            height: 80,
          ),
        ),
        const Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                strokeWidth: 5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}