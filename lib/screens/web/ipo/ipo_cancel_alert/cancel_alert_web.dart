// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_font_web.dart';

import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';

class IpoCancelAlert extends ConsumerStatefulWidget {
  final IpoOrderBookModel ipocancel;

  const IpoCancelAlert({super.key, required this.ipocancel});

  @override
  ConsumerState<IpoCancelAlert> createState() => _IpoCancelAlertState();
}

class _IpoCancelAlertState extends ConsumerState<IpoCancelAlert> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final symbol = widget.ipocancel.symbol ?? '';

    return Dialog(
      backgroundColor:
          theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cancel Order',
                    style: WebTextStyles.dialogTitle(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.08),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Are you sure you want to cancel the (${symbol.toUpperCase()} order)?',
                          textAlign: TextAlign.center,
                          style: WebTextStyles.dialogContent(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? WebDarkColors.error
                              : WebColors.error,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                            onTap: _isCancelling
                                ? null
                                : () => _handleCancelOrder(context),
                            child: Center(
                              child: _isCancelling
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Cancel',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancelOrder(BuildContext context) async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final menudata = MenuData(
        flow: "can",
        type: widget.ipocancel.type.toString(),
        symbol: widget.ipocancel.symbol.toString(),
        category: "",
        name: widget.ipocancel.companyName.toString(),
        applicationNumber: widget.ipocancel.applicationNumber.toString(),
        respBid: [BidReference(bidReferenceNumber: '67890')],
      );

      const List<IposBid> iposbids = [];

      await ref
          .read(ipoProvide)
          .getipoplaceorder(context, menudata, iposbids, "");

      // Close the dialog after successful cancellation
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Handle error - dialog will remain open
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }
}
