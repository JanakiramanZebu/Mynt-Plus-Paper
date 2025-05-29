import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_riverpod/all.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/api/core/api_core.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';

import '../../../res/res.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';

class CDSLWebView extends StatefulWidget {
  final Map argument;
  const CDSLWebView({super.key, required this.argument});
  @override
  CamsWebViewState createState() => CamsWebViewState();
}

class CamsWebViewState extends State<CDSLWebView> {
  double progress = 0;
  late ContextMenu contextMenu;
  // final Preferences pref = ref.read(preferencesProvider);
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);

      final ledgerprovider = ref.watch(ledgerProvider);
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
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(
                      "https://api.cdslindia.com/APIServices/pledgeapi/pledgesetup"),
                  method: 'POST',
                  body: Uint8List.fromList(
                    utf8.encode(
                        "dpid=${Uri.encodeComponent(widget.argument['dpid'])}&"
                        "pledgedtls=${Uri.encodeComponent(widget.argument['pledgedtls'])}&"
                        "reqid=${Uri.encodeComponent(widget.argument['reqid'])}&"
                        "version=${Uri.encodeComponent(widget.argument['version'])}"),
                  ),
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                  },
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  // You can store the controller if needed
                },
                onLoadStart: (InAppWebViewController controller, Uri? uri) {
                  String redirUrl = uri.toString();
                  // print(":::::redirUrl::::::${redirUrl}");
                  Uri url = Uri.parse(redirUrl);
                  Map<String, String> queryParams = url.queryParameters;
                  final res = queryParams['reqid'];
                  print("$res  objectobjectobjectobject");

                  if (redirUrl.contains('profile.mynt.in')) {
                    //   print('web is');
                    //   if (mounted) {
                    
                    Navigator.of(context).pop();
                    ledgerprovider.cdslresponsepage(context,res.toString());
                    Navigator.pushNamed(context, Routes.pledgeunpledgeresponse,
                        arguments: "DDDDD");
                    

                    //   }
                  }
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
              ),

              // CircularProgressIndicator when loading
              // if (progress < 1.0)
              //   const Center(
              //     child: CircularProgressIndicator(),
              //   ),
            ],
          ),
        ),
      );
    });
  }
}
