import 'package:flutter/material.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/order_screen/place_order_screen.dart';
import 'package:mynt_plus/utils/responsive_modal.dart';

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
      // Desktop: Show as dialog
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.3, // set your desired width here
              child: PlaceOrderScreen(
                orderArg: arguments['orderArg'],
                scripInfo: arguments['scripInfo'],
                isBasket: arguments['isBskt'] ?? false,
              ),
            ),
          );
        },
      );
    } else {
      // Mobile: Navigate normally
      return Navigator.pushNamed(
        context,
        Routes.placeOrderScreen,
        arguments: arguments,
      );
    }
  }
}
