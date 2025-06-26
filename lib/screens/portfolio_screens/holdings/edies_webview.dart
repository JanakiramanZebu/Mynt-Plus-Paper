import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../../locator/constant.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
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
    final portfolioProviderRef = ref.read(portfolioProvider);
    
    return PopScope(
      canPop: false, // Prevent default back navigation so we can handle it ourselves
      onPopInvokedWithResult: (didPop, result) async {
        // If didPop is true, the system already handled the pop - shouldn't happen with canPop: false
        if (didPop) return;
        
        // Use a local flag to track navigation state
        bool isNavigating = false;
        
        try {
          if (isNavigating) return; // Prevent multiple navigation attempts
          isNavigating = true;
          
          // First refresh the holdings data
          await portfolioProviderRef.fetchHoldings(context, "Refresh");
          
          // Then navigate back if the context is still valid
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          // If any error occurs, ensure we still navigate back
          print("Error during EDIS navigation: $e");
          if (context.mounted && !isNavigating) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
              centerTitle: false,
              elevation: 1,
              leadingWidth: 41,
              title: TextWidget.titleText(
                  text: "Verify Holdings", theme: theme.isDarkMode, fw: 1),
              leading: InkWell(
                  onTap: () async {
                    // Use a safer approach for AppBar back button too
                    try {
                      // First refresh the holdings data
                      await portfolioProviderRef.fetchHoldings(context, "Refresh");
                      
                      // Then navigate back if the context is still mounted
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      // If any error occurs, ensure we still navigate back
                      print("Error during EDIS AppBar navigation: $e");
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
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
