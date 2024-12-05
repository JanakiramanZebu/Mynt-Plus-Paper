import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../locator/constant.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/res.dart';

class CamsWebView extends StatefulWidget {
  final String argument;
  const CamsWebView({super.key, required this.argument});

  @override
  CamsWebViewState createState() => CamsWebViewState();
}

class CamsWebViewState extends State<CamsWebView> {
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
      body: SafeArea(
        child: Stack(
          children: [
            // InAppWebView
            InAppWebView(
                // windowId: 0,
                initialUrlRequest: URLRequest(url: Uri.parse(widget.argument)),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions()),
                onWebViewCreated: (InAppWebViewController controller) {
                  setState(() {
                    ConstantName.webViewController = controller;
                  });
                  // String asf= controller.toString();
                  //  print('creat start');
                  // print(asf);
                  // print('creat end');
                },
                onLoadStart: (InAppWebViewController controller, progress) {
                  String redirUrl = progress.toString();
                  print(redirUrl);
                  // Uri url = Uri.parse(redirUrl);
                  // Map<String, String> queryParams = url.queryParameters;
                  // String? query = queryParams['response'];
                  //     print('load start');
                  // print(progress);
                  // print('load end');
                  if (redirUrl.contains('profile.mynt.in')) {
                    print('web is');
                    if (mounted) {
                      Future.microtask(() {
                        Navigator.of(context).pop();
                        context
                            .read(portfolioProvider)
                            .fetchBrokerDetails(context, true);
                      });
                    }
                  }
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                }),

            // CircularProgressIndicator when loading
            if (progress < 1.0)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
