import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransparentLoaderScreen extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const TransparentLoaderScreen({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Stack(
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
                ),
              ),
            ),
          ),
      ],
    );
  }
}
