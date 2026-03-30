// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Razorpay')
extension type RazorpayJS._(JSObject _) implements JSObject {
  external RazorpayJS(JSObject options);
  external void open();
}

typedef RazorpayWebCallback = void Function(String? paymentId, String? orderId, String? signature);
typedef RazorpayWebErrorCallback = void Function(String? code, String? description, String? paymentId);

void openRazorpayWeb({
  required Map<String, dynamic> options,
  required RazorpayWebCallback onSuccess,
  required RazorpayWebErrorCallback onError,
}) {
  final jsOptions = _mapToJSObject(options);

  // Set handler for success
  jsOptions['handler'] = ((JSObject response) {
    final paymentId = (response['razorpay_payment_id'] as JSString?)?.toDart;
    final orderId = (response['razorpay_order_id'] as JSString?)?.toDart;
    final signature = (response['razorpay_signature'] as JSString?)?.toDart;
    print("Razorpay Success Response => paymentId: $paymentId, orderId: $orderId, signature: $signature");
    onSuccess(paymentId, orderId, signature);
  }).toJS;

  // Set modal dismiss handler
  final modal = JSObject();
  modal['ondismiss'] = (() {
    print("Razorpay Modal Dismissed => Payment cancelled by user");
    onError('MODAL_CLOSED', 'Payment cancelled by user', null);
  }).toJS;
  jsOptions['modal'] = modal;

  final rzp = RazorpayJS(jsOptions);
  rzp.open();
}

JSObject _mapToJSObject(Map<String, dynamic> map) {
  final obj = JSObject();
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      obj[key] = _mapToJSObject(value);
    } else if (value is int) {
      obj[key] = value.toJS;
    } else if (value is double) {
      obj[key] = value.toJS;
    } else if (value is bool) {
      obj[key] = value.toJS;
    } else if (value is String) {
      obj[key] = value.toJS;
    }
  });
  return obj;
}
