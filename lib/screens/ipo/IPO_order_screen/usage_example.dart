// Example usage of UnifiedIpoOrderScreen
// This file demonstrates how to use the unified screen for both SME and Mainstream IPOs

import 'package:flutter/material.dart';
import 'package:mynt_plus/models/ipo_model/ipo_sme_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_mainstream_model.dart';
import 'ipo_order_screen.dart';

class IpoOrderUsageExample {
  // Example 1: Navigate to SME IPO Order Screen
  static void navigateToSMEIpoOrder(BuildContext context, SMEIPO smeIpo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedIpoOrderScreen(
          ipoData: smeIpo, // Pass SMEIPO object
        ),
      ),
    );
  }

  // Example 2: Navigate to Mainstream IPO Order Screen
  static void navigateToMainstreamIpoOrder(
      BuildContext context, MainIPO mainstreamIpo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedIpoOrderScreen(
          ipoData: mainstreamIpo, // Pass MainIPO object
        ),
      ),
    );
  }

  // Example 3: Show modal bottom sheet for SME IPO
  static void showSMEIpoOrderModal(BuildContext context, SMEIPO smeIpo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: UnifiedIpoOrderScreen(
          ipoData: smeIpo,
        ),
      ),
    );
  }

  // Example 4: Show modal bottom sheet for Mainstream IPO
  static void showMainstreamIpoOrderModal(
      BuildContext context, MainIPO mainstreamIpo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: UnifiedIpoOrderScreen(
          ipoData: mainstreamIpo,
        ),
      ),
    );
  }
}

// Example widget showing how to use the unified screen
class IpoOrderButton extends StatelessWidget {
  final dynamic ipoData; // Can be either SMEIPO or MainIPO
  final bool useModal;

  const IpoOrderButton({
    Key? key,
    required this.ipoData,
    this.useModal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (useModal) {
          if (ipoData is SMEIPO) {
            IpoOrderUsageExample.showSMEIpoOrderModal(context, ipoData);
          } else if (ipoData is MainIPO) {
            IpoOrderUsageExample.showMainstreamIpoOrderModal(context, ipoData);
          }
        } else {
          if (ipoData is SMEIPO) {
            IpoOrderUsageExample.navigateToSMEIpoOrder(context, ipoData);
          } else if (ipoData is MainIPO) {
            IpoOrderUsageExample.navigateToMainstreamIpoOrder(context, ipoData);
          }
        }
      },
      child: Text('Apply for IPO'),
    );
  }
}
