import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../../locator/constant.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class EdisWebview extends ConsumerStatefulWidget {
  final String params;
  const EdisWebview({super.key, required this.params});

  @override
  ConsumerState<EdisWebview> createState() => _EdisWebviewState();
}

class _EdisWebviewState extends ConsumerState<EdisWebview> {
  double progress = 0;
  late ContextMenu contextMenu;
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        await ref.read(portfolioProvider).fetchHoldings(context, "Refresh");
        Navigator.of(context).pop(); // Proceed with back navigation
      },
      child: Scaffold(
          appBar: AppBar(
              centerTitle: false,
              elevation: 1,
              leadingWidth: 41,
              title: Text(
                "Verify Holdings",
                style: textStyles.appBarTitleTxt.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
              ),
              leading: InkWell(
                  onTap: () async {
                    await ref.read(portfolioProvider)
                        .fetchHoldings(context, "Refresh");
                    Navigator.pop(context);
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: SvgPicture.asset(assets.backArrow)))),
          body: SafeArea(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: InAppWebView(
                      initialUrlRequest: URLRequest(
                          url: WebUri(
                              'https://go.mynt.in/NorenEdis/NonPoaHoldings/?${widget.params}')),
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions()),
                      onWebViewCreated: (InAppWebViewController controller) {
                        setState(() {
                          ConstantName.webViewController = controller;
                        });
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        setState(() {
                          this.progress = progress / 100;
                        });
                      })))),
    );
  }
}
