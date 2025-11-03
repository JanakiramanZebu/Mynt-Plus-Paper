import 'package:flutter/material.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/web/order/place_order_screen_web.dart';

import '../sharedWidget/functions.dart';

/// Utility class for responsive navigation
/// Handles navigation logic based on screen size
class ResponsiveNavigation {
  /// Navigate to PlaceOrderScreen responsively
  /// Shows as dialog on desktop (width >= 600) and navigates normally on mobile
  static Future<dynamic> toPlaceOrderScreen({
    required BuildContext context,
    required Map<String, dynamic> arguments,
  }) {
    if (getResponsiveWidth(context) >= 600) {
      // Desktop: Show as dialog using web version
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: SizedBox(
              width: 500,
              height: 600,

              child: StatefulBuilder(
                builder: (context, setState) {
                  return PlaceOrderScreenWeb(
                    orderArg: arguments['orderArg'],
                    scripInfo: arguments['scripInfo'],
                    isBasket: arguments['isBskt']?.toString() ?? "",
                    fromChart: arguments['fromChart'] ?? false,
                  );
                }
              ),
            ),
          );
        },
      );
    } else {
      // Mobile: Navigate normally using mobile version
      return Navigator.pushNamed(
        context,
        Routes.placeOrderScreen,
        arguments: arguments,
      );
    }
  }
}
