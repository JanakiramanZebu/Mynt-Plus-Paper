import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../api/core/api_core.dart';
import '../../../models/profile_model/qr_response.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import 'invalid_qr.dart';
import 'qr_scan_detils.dart';

class BarcodeScannerWithScanWindow extends ConsumerStatefulWidget {
  const BarcodeScannerWithScanWindow({super.key});

  @override
  ConsumerState<BarcodeScannerWithScanWindow> createState() =>
      _BarcodeScannerWithScanWindowState();
}

class _BarcodeScannerWithScanWindowState
    extends ConsumerState<BarcodeScannerWithScanWindow> {
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 270,
      height: 270,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            scanWindow: scanWindow,
            controller: controller,
            onDetect: (barcode) {
              final String code = barcode.barcodes[0].displayValue ?? 'Unknown';
              controller.stop();
              _showBottomSheet(code);
            },
          ),
          // _buildBarcodeOverlay(),
          _buildScanWindow(scanWindow),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.only(right: 15),
            width: double.infinity,
            child: IconButton(
              onPressed: () {
                controller.stop();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close_rounded,
              ),
              color:
                  theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 200),
            width: double.infinity,
            child: TextWidget.subText(
              text: "Scan the QR code to Log into Zebu Webapp",
              theme: theme.isDarkMode,
              color: colors.colorWhite,
              fw: 0,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  _showBottomSheet(String data) async {
    String jsonString = data;
    String correctedJsonResponse = jsonString.replaceAll("'", '"');
    try {
      Map<String, dynamic> decodedJson = jsonDecode(correctedJsonResponse);

      final qrdata = QrResponces.fromJson(decodedJson);
      showModalBottomSheet(
        showDragHandle: false,
        useSafeArea: true,
        isScrollControlled: false,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        context: context,
        builder: (context) {
          // ignore: deprecated_member_use
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: QrDetails(details: qrdata, camera: controller));
        },
      );
    } catch (e) {
      showModalBottomSheet(
        showDragHandle: false,
        useSafeArea: true,
        isScrollControlled: false,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        context: context,
        builder: (context) {
          // ignore: deprecated_member_use
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: InValidQRui(camera: controller));
        },
      );
    }
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }
}

textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  ));
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: use `Offset.zero & size` instead of Rect.largest
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
