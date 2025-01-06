import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../locator/constant.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';

class IpoWebview extends StatefulWidget {
  final String argument;
  const IpoWebview({super.key, required this.argument});

  @override
  IpoWebviewState createState() => IpoWebviewState();
}

class IpoWebviewState extends State<IpoWebview> {
  double progress = 0;
  late ContextMenu contextMenu;

  final Preferences pref = locator<Preferences>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        elevation: 1,
        leadingWidth: 41,
        titleSpacing: 6,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: SvgPicture.asset(assets.backArrow),
          ),
        ),
      ),
      body: TransparentLoaderScreen(
        isLoading: progress < 1.0,
        child: SafeArea(
          child: Stack(
            children: [
              // InAppWebView
              InAppWebView(
                  // windowId: 0,
                  initialUrlRequest:
                      URLRequest(url: WebUri(widget.argument)),
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
                  }),

              // CircularProgressIndicator when loading
              // if (progress < 1.0)
              //   const Center(
              //     child: CircularProgressIndicator(),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
