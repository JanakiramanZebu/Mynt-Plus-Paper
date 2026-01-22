import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';


class InAppWebViewScreen extends ConsumerStatefulWidget {
  final String url;

  const InAppWebViewScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  ConsumerState<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends ConsumerState<InAppWebViewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool canGoBack = false;
  int navigationCount = 0;
  List<InAppWebViewController> _popupControllers = [];

  @override
  void dispose() {
    _cleanupWebView();
    super.dispose();
  }

  Future<void> _cleanupWebView() async {
    try {
      // Clear main WebView
      if (webViewController != null) {
        await webViewController!.clearCache();
        await webViewController!.clearFocus();
        await webViewController!.stopLoading();
        webViewController = null;
      }

      // Clear all popup WebViews
      for (var controller in _popupControllers) {
        try {
          await controller.clearCache();
          await controller.clearFocus();
          await controller.stopLoading();
        } catch (e) {
          print('Error cleaning popup controller: $e');
        }
      }
      _popupControllers.clear();

      // Force garbage collection on iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Clear WebView cache and cookies
        await CookieManager.instance().deleteAllCookies();
        // Note: clearAll() method may not be available in all versions
        // The individual cleanup above should be sufficient
      }
    } catch (e) {
      print('Error during WebView cleanup: $e');
    }
  }

  Future<void> _cleanupPopupController(InAppWebViewController controller) async {
    try {
      await controller.clearCache();
      await controller.clearFocus();
      await controller.stopLoading();
      _popupControllers.remove(controller);
    } catch (e) {
      print('Error cleaning popup controller: $e');
    }
  }

  Future<void> _injectFallbackCameraHandler() async {
    if (webViewController != null) {
      try {
        // Inject a simpler fallback camera handler
        await webViewController!.evaluateJavascript(source: """
          (function() {
            console.log('Fallback camera handler loaded');
            
            // Add a global function that can be called directly
            window.openCameraFromFlutter = function() {
              console.log('openCameraFromFlutter called');
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('openCamera', {
                  accept: 'image/*',
                  capture: 'camera',
                  inputId: 'fallback-camera'
                });
              } else {
                console.log('Flutter InAppWebView not available in fallback');
              }
            };
            
            // Add a test function
            window.testCamera = function() {
              console.log('testCamera called');
              if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('testCamera');
              } else {
                console.log('Flutter InAppWebView not available for test');
              }
            };
            
            // Also try to intercept any file input changes
            document.addEventListener('change', function(e) {
              if (e.target && e.target.type === 'file' && e.target.files.length === 0) {
                console.log('File input change detected with no files - might be camera trigger');
                var accept = e.target.getAttribute('accept') || '';
                var capture = e.target.getAttribute('capture') || '';
                
                if (accept.includes('image') && capture.includes('camera')) {
                  console.log('Detected camera file input change');
                  // Don't prevent default here, just log
                }
              }
            });
            
            console.log('Fallback camera handler injected');
          })();
        """);
        
        print('Fallback camera handler injected successfully');
      } catch (e) {
        print('Error injecting fallback camera handler: $e');
      }
    }
  }

  Future<void> _injectCameraHandler() async {
    if (webViewController != null) {
      try {
        // Inject JavaScript to handle file inputs with camera capture
        await webViewController!.evaluateJavascript(source: """
          (function() {
            // Store original input element for camera capture
            var cameraInput = null;
            
            console.log('Camera handler script loaded');
            
            // Function to check if input should trigger camera
            function shouldTriggerCamera(input) {
              var accept = input.getAttribute('accept') || '';
              var capture = input.getAttribute('capture') || '';
              
              console.log('Checking input:', {
                accept: accept,
                capture: capture,
                type: input.type
              });
              
              return input.type === 'file' && 
                     accept.includes('image') && 
                     (capture.includes('camera') || capture.includes('user') || capture.includes('environment'));
            }
            
            // Function to trigger camera
            function triggerCamera(input) {
              console.log('Triggering camera for input:', input);
              
              // Store reference to the input
              cameraInput = input;
              
              // Trigger camera capture via Flutter
              if (window.flutter_inappwebview) {
                console.log('Calling Flutter camera handler');
                window.flutter_inappwebview.callHandler('openCamera', {
                  accept: input.getAttribute('accept') || '',
                  capture: input.getAttribute('capture') || '',
                  inputId: input.id || 'file-input-' + Date.now()
                });
              } else {
                console.log('Flutter InAppWebView not available');
              }
            }
            
            // Override file input click behavior
            document.addEventListener('click', function(e) {
              console.log('Click event detected:', e.target);
              
              if (e.target && e.target.type === 'file') {
                console.log('File input clicked');
                
                if (shouldTriggerCamera(e.target)) {
                  console.log('Should trigger camera - preventing default');
                  e.preventDefault();
                  e.stopPropagation();
                  triggerCamera(e.target);
                }
              }
            }, true); // Use capture phase
            
            // Also handle programmatic file input triggers
            var originalClick = HTMLInputElement.prototype.click;
            HTMLInputElement.prototype.click = function() {
              console.log('Programmatic click on input:', this);
              
              if (shouldTriggerCamera(this)) {
                console.log('Programmatic camera trigger');
                triggerCamera(this);
              } else {
                console.log('Normal file input click');
                originalClick.call(this);
              }
            };
            
            // Handle label clicks that trigger file inputs
            document.addEventListener('click', function(e) {
              if (e.target.tagName === 'LABEL' && e.target.getAttribute('for')) {
                var inputId = e.target.getAttribute('for');
                var input = document.getElementById(inputId);
                
                if (input && input.type === 'file' && shouldTriggerCamera(input)) {
                  console.log('Label click for camera input - preventing default');
                  e.preventDefault();
                  e.stopPropagation();
                  triggerCamera(input);
                }
              }
            }, true);
            
            // Expose function to set camera file data
            window.setCameraFileData = function(base64Data, fileName) {
              console.log('setCameraFileData called with:', fileName);
              
              if (cameraInput) {
                try {
                  // Create a blob from base64 data
                  var byteCharacters = atob(base64Data);
                  var byteNumbers = new Array(byteCharacters.length);
                  for (var i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                  }
                  var byteArray = new Uint8Array(byteNumbers);
                  var blob = new Blob([byteArray], {type: 'image/jpeg'});
                  
                  // Create a File object
                  var file = new File([blob], fileName || 'camera_capture.jpg', {type: 'image/jpeg'});
                  
                  // Create a FileList-like object
                  var fileList = {
                    0: file,
                    length: 1,
                    item: function(index) { return index === 0 ? file : null; }
                  };
                  
                  // Set the files property
                  Object.defineProperty(cameraInput, 'files', {
                    value: fileList,
                    writable: false
                  });
                  
                  // Trigger change event
                  var changeEvent = new Event('change', { bubbles: true });
                  cameraInput.dispatchEvent(changeEvent);
                  
                  // Also trigger input event for better compatibility
                  var inputEvent = new Event('input', { bubbles: true });
                  cameraInput.dispatchEvent(inputEvent);
                  
                  console.log('Camera file data set successfully');
                  
                } catch (e) {
                  console.error('Error setting camera file data:', e);
                }
              } else {
                console.error('No camera input reference available');
              }
            };
            
            // Listen for camera image captured events
            document.addEventListener('cameraImageCaptured', function(event) {
              console.log('Camera image captured event received:', event.detail);
            });
            
            console.log('Camera handler JavaScript injected successfully');
          })();
        """);
        
        print('Camera handler JavaScript injected successfully');
      } catch (e) {
        print('Error injecting camera handler: $e');
      }
    }
  }

  Future<void> _handleCameraRequest(Map<String, dynamic> data) async {
    try {
      print('Camera request received: $data');
      
      // Use image_picker to launch camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        print('Camera image captured: ${image.path}');
        
        // Convert image to base64
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        // Inject the image data using the setCameraFileData function
        await webViewController!.evaluateJavascript(source: """
          (function() {
            try {
              if (typeof window.setCameraFileData === 'function') {
                window.setCameraFileData('$base64Image', 'camera_capture.jpg');
                console.log('Camera file data injected successfully');
              } else {
                console.error('setCameraFileData function not available');
              }
            } catch (e) {
              console.error('Error injecting camera data:', e);
            }
          })();
        """);
      } else {
        print('No image captured from camera');
      }
    } catch (e) {
      print('Error handling camera request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleBackPress();
          await ref.read(profileAllDetailsProvider).fetchPendingstatus();
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
              await ref.read(profileAllDetailsProvider).fetchPendingstatus();
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
                    // Memory optimization options
                    cacheEnabled: true,
                    clearCache: false,
                    mediaPlaybackRequiresUserGesture: false,
                    // Disable unnecessary features for better memory management
                    disableHorizontalScroll: false,
                    disableVerticalScroll: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    supportMultipleWindows: true,
                    // Android memory optimizations
                    mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    thirdPartyCookiesEnabled: false,
                    allowContentAccess: true,
                    allowFileAccess: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                    allowsAirPlayForMediaPlayback: true,
                    // iOS specific memory optimizations
                    allowsBackForwardNavigationGestures: false,
                    allowsLinkPreview: false,
                    isFraudulentWebsiteWarningEnabled: false,
                    // Disable unnecessary iOS features
                    allowsPictureInPictureMediaPlayback: false,
                    // Memory management
                    sharedCookiesEnabled: false,
                    selectionGranularity: IOSWKSelectionGranularity.DYNAMIC,
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
                   controller.addJavaScriptHandler(
                     handlerName: 'openCamera',
                     callback: (args) {
                       print('JavaScript openCamera called with args: $args');
                       if (args.isNotEmpty && args[0] is Map<String, dynamic>) {
                         _handleCameraRequest(args[0] as Map<String, dynamic>);
                       } else {
                         print('Invalid arguments received for openCamera handler');
                       }
                     },
                   );
                   controller.addJavaScriptHandler(
                     handlerName: 'testCamera',
                     callback: (args) {
                       print('JavaScript testCamera called');
                       _handleCameraRequest({
                         'accept': 'image/*',
                         'capture': 'camera',
                         'inputId': 'test-camera'
                       });
                     },
                   );
                 },
                onProgressChanged: (controller, progress) {
                  // Ensure loader works reliably on initial and subsequent loads
                  final safeProgress = progress.clamp(0, 100);
                  if (mounted) {
                    setState(() {
                      isLoading = safeProgress < 100;
                    });
                  }
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
                   
                   // Inject camera handler JavaScript after page loads
                   await _injectCameraHandler();
                   
                   // Also inject a simple fallback handler
                   await _injectFallbackCameraHandler();
                 },
                onReceivedError: (controller, request, errorResponse) {
                  print('WebView error: ${errorResponse.description}');
                  final url = request.url.toString();
                  
                  if (!url.contains('about:blank#blocked')) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                onCreateWindow: (controller, createWindowRequest) async {
                  // final requestUrl = createWindowRequest.request.url.toString();
          
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
                          initialChildSize: 0.98,
                          minChildSize: 0.5,
                          maxChildSize: 0.98,
                          expand: false,
                          snap: true,
                          snapSizes: const [0.5, 0.8, 0.95],
                          builder: (context, scrollController) {
                            return SafeArea(
                              child: Column(
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
                                          TextWidget.subText(text: 'eSign',theme: theme.isDarkMode,color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,fw: 0),
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
                                          // Memory optimization for popup
                                          cacheEnabled: true,
                                          clearCache: false,
                                          mediaPlaybackRequiresUserGesture: false,
                                        ),
                                        android: AndroidInAppWebViewOptions(
                                          useHybridComposition: true,
                                          domStorageEnabled: true,
                                          databaseEnabled: true,
                                          supportMultipleWindows: true,
                                          overScrollMode: AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
                                          // Android memory optimizations for popup
                                          thirdPartyCookiesEnabled: false,
                                          allowContentAccess: true,
                                          allowFileAccess: true,
                                        ),
                                        ios: IOSInAppWebViewOptions(
                                          allowsInlineMediaPlayback: true,
                                          allowsAirPlayForMediaPlayback: true,
                                          disallowOverScroll: false,
                                          // iOS memory optimizations for popup
                                          allowsBackForwardNavigationGestures: false,
                                          allowsLinkPreview: false,
                                          isFraudulentWebsiteWarningEnabled: false,
                                          allowsPictureInPictureMediaPlayback: false,
                                          sharedCookiesEnabled: false,
                                        ),
                                      ),
                                      onWebViewCreated: (popupController) {
                                        _popupControllers.add(popupController);
                                        popupController.addJavaScriptHandler(
                                          handlerName: 'closePopup',
                                          callback: (args) {
                                            print("Popup close requested via JS");
                                            _cleanupPopupController(popupController);
                                            Navigator.of(context, rootNavigator: true).pop();
                                            return;
                                          },
                                        );
                                      },
                                      onUpdateVisitedHistory: (popupController, url, androidIsReload) async {
                                        final popupUrlString = url?.toString() ?? '';
                                        if (_shouldCloseForUrl(popupUrlString)) {
                                          if (mounted) {
                                            _cleanupPopupController(popupController);
                                            Navigator.of(context, rootNavigator: true).pop();
                                          }
                                        }
                                      },
                                      onLoadStop: (popupController, popupUrl) async {
                                        final popupUrlString = popupUrl?.toString() ?? '';
                                                                      
                                        if (_shouldCloseForUrl(popupUrlString)) {
                                          await Future.delayed(const Duration(milliseconds: 500));
                                          if (mounted) {
                                            _cleanupPopupController(popupController);
                                            Navigator.of(context, rootNavigator: true).pop();
                                          }
                                        }
                                      },
                                                                             onReceivedError: (popupController, request, errorResponse) {
                                         if (mounted) {
                                           _cleanupPopupController(popupController);
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
                              ),
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

bool _shouldCloseForUrl(String url) {
    if (url.isEmpty) return false;

    if ((url.contains("profile.mynt.in/")) ) {
      return true;
    }

    return false;
  }




  Future<void> _handleBackPress() async {
    // Clean up WebView resources before navigating back
    await _cleanupWebView();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
