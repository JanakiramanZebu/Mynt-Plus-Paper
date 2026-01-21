import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../locator/constant.dart';
import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/loader_ui.dart';

class ProfileWebViewApp extends StatefulWidget {
  final String argument;
  const ProfileWebViewApp({super.key, required this.argument});

  @override
  _ProfileWebViewApp createState() => _ProfileWebViewApp();
}

class _ProfileWebViewApp extends State<ProfileWebViewApp> {
  double progress = 0;
  late ContextMenu contextMenu;
  final Preferences pref = locator<Preferences>();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final hstoken = ref.watch(fundProvider);
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
                      child: SvgPicture.asset(assets.backArrow)))),
          body: TransparentLoaderScreen(
            isLoading: progress < 1.0,
            child: SafeArea(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: WebUri(
                                'https://profile.mynt.in/${widget.argument}/?sAccountId=${pref.clientId}&sToken=${hstoken.fundHstoken!.hstk}&src=app')),
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
                        }))),
          ));
    });
  }
}
