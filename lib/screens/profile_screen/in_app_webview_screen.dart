import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/splash_loader.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;

  const InAppWebViewScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool canGoBack = false;
  int navigationCount = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleBackPress();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () async {
              await _handleBackPress();
            },
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    useOnLoadResource: true,
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    allowFileAccessFromFileURLs: true,
                    allowUniversalAccessFromFileURLs: true,
                    userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
                    supportZoom: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    supportMultipleWindows: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                    allowsAirPlayForMediaPlayback: true,
                  ),
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'closeWebView',
                    callback: (args) {
                      print('JavaScript closeWebView called');
                      Navigator.of(context).pop();
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  final urlString = url?.toString() ?? '';
                  print('Loading started: $urlString');
                  
                  if (!urlString.contains('about:blank#blocked')) {
                    setState(() {
                      isLoading = true;
                    });
                    navigationCount++;
                  }
                },
                onLoadStop: (controller, url) async {
                  final currentUrl = url?.toString() ?? '';
                  print('Loading completed: $currentUrl');
                  
                  if (currentUrl.contains('about:blank#blocked')) {
                    print('Blocked URL detected, ignoring...');
                    return;
                  }
                  
                  setState(() {
                    isLoading = false;
                  });
                  canGoBack = await controller.canGoBack();
          
                  print('Current URL: $currentUrl');
                },
                onReceivedError: (controller, request, errorResponse) {
                  print('WebView error: ${errorResponse.description}');
                  final url = request.url?.toString() ?? '';
                  
                  if (!url.contains('about:blank#blocked')) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                onCreateWindow: (controller, createWindowRequest) async {
                  final requestUrl = createWindowRequest.request.url?.toString() ?? '';
                  print('Creating popup window for: $requestUrl');
          
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    useSafeArea: true,
                    elevation: 0,
                    isDismissible: false,
                    enableDrag: false,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.8,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          expand: false,
                          snap: true,
                          snapSizes: const [0.5, 0.8, 0.95],
                          builder: (context, scrollController) {
                            return Column(
                              children: [
                                // const CustomDragHandler(),
                                // const SizedBox(height: 10),
                                Container(
                                  height: 50,
                                  color: Colors.grey[200],
                                  child:  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('eSign',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          color: Colors.black,
                                          iconSize: 20,
                                          splashRadius: 18,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InAppWebView(
                                    windowId: createWindowRequest.windowId,
                                    initialOptions: InAppWebViewGroupOptions(
                                      crossPlatform: InAppWebViewOptions(
                                        javaScriptEnabled: true,
                                        userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
                                        supportZoom: true,
                                        useOnDownloadStart: true,
                                        horizontalScrollBarEnabled: true,
                                        verticalScrollBarEnabled: true,
                                        javaScriptCanOpenWindowsAutomatically: true,
                                      ),
                                      android: AndroidInAppWebViewOptions(
                                        useHybridComposition: true,
                                        domStorageEnabled: true,
                                        databaseEnabled: true,
                                        supportMultipleWindows: true,
                                        overScrollMode: AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
                                      ),
                                      ios: IOSInAppWebViewOptions(
                                        allowsInlineMediaPlayback: true,
                                        allowsAirPlayForMediaPlayback: true,
                                        disallowOverScroll: false,
                                      ),
                                    ),
                                    onWebViewCreated: (popupController) {
                                      popupController.addJavaScriptHandler(
                                        handlerName: 'closePopup',
                                        callback: (args) {
                                          print("Popup close requested via JS");
                                          Navigator.of(context, rootNavigator: true).pop();
                                          return;
                                        },
                                      );
                                    },
                                    onLoadStop: (popupController, popupUrl) async {
                                      final popupUrlString = popupUrl?.toString() ?? '';
                                      print('Popup loaded: $popupUrlString');
                                                                    
                                      if ((popupUrlString.contains("/gateway/exit") && 
                                           popupUrlString.contains("https://192.168.1.100:8080/"))
                                          // popupUrlString.contains("esign=success") ||
                                          // popupUrlString.contains("status=completed") ||
                                          // popupUrlString.contains("digio_success")
                                          ) {
                                        print('✅ Success detected in popup - closing bottom sheet...');
                                        
                                        await Future.delayed(const Duration(milliseconds: 1000));
                                        
                                        if (mounted) {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        }
                                      }
                                    },
                                    onReceivedError: (popupController, request, errorResponse) {
                                      print('Popup error: ${errorResponse.description}');
                                      if (mounted) {
                                        Navigator.of(context, rootNavigator: true).pop();
                                      }
                                    },
                                    gestureRecognizers: {
                                      Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                                      Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
                                      Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                  return true;
                },
                onPermissionRequest: (controller, request) async {
                  print('Permission requested: ${request.resources}');
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url?.toString() ?? '';
                  print('Navigation to: $url');
          
                  if (url.contains('about:blank#blocked')) {
                    print('Blocking navigation to: $url');
                    return NavigationActionPolicy.CANCEL;
                  }
          
                  if (url.contains('digio.in') ||
                      url.contains('gateway') ||
                      url.contains('esign')) {
                    return NavigationActionPolicy.ALLOW;
                  }
          
                  return NavigationActionPolicy.ALLOW;
                },
                onConsoleMessage: (controller, consoleMessage) {
                  if (!consoleMessage.message.contains('[Vue warn]')) {
                    print('Console: ${consoleMessage.message}');
                  }
                },
              ),
              if (isLoading)
                const Center(
                  child: CircularLoaderImage(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackPress() async {
    print('Back button pressed. Navigation count: $navigationCount');

    if (webViewController != null) {
      try {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error in _handleBackPress: $e');
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      print('No web controller - closing screen');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
