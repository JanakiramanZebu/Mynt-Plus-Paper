// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';

class BondCancelAlertWeb extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  const BondCancelAlertWeb({super.key, required this.bondcancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);
    
    return AlertDialog(
       backgroundColor: theme
                                                                        .isDarkMode
                                                                    ? const Color(
                                                                        0xFF121212)
                                                                    : const Color(
                                                                        0xFFF1F3F8),
       titlePadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            8),
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(
                                                                                8))),
                                                                scrollable: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 12,
                                                                  vertical: 12,
                                                                ),
                                                                actionsPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            16,
                                                                        right: 16,
                                                                        left: 16,
                                                                        top: 8),
                                                                insetPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            30,
                                                                        vertical:
                                                                            12),
      title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                           color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    TextWidget.subText(
                      text:"Are you sure you want to cancel the (${bondcancel.symbol} order)",
                      theme: theme.isDarkMode,
                     color: theme.isDarkMode
                                                                                ? colors.textSecondaryDark
                                                                                : colors.textPrimaryLight,
                      fw: 3,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

            actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(dialogContext).pop();
            //     // Go back to login or previous screen instead of recursive call
            //     Navigator.of(context).pop();
            //   },
            //   child: Text("Cancel", style: textStyles.btnText),
            // ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleCancelOrder(context, ref, bondcancel),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 45), // width, height
                  side: BorderSide(
                      color: colors.btnOutlinedBorder), // Outline border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: colors.primaryDark, // Transparent background
                ),
                child: TextWidget.titleText(
                    text: "Yes",
                    theme: theme.isDarkMode,
                    color: colors.colorWhite,
                    fw: 2),
              ),
            ),
          ],
     
      // actions: [
      //   _ActionButtons(
      //     bondcancel: bondcancel,
      //     bonds: bonds,
      //     theme: theme,
      //   ),
      // ],
    );
  }
}

class _AlertIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
    );
  }
}





class _NoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(155, 40),
        elevation: 0,
        backgroundColor: const Color(0xffF1F3F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text(
        "No",
        style: _textStyle(colors.colorGrey, 12, FontWeight.w500),
      ),
    );
  }
}

class _YesButton extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  final BondsProvider bonds;
  final ThemesProvider theme;

  const _YesButton({
    required this.bondcancel,
    required this.bonds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(155, 40),
        elevation: 0,
        backgroundColor: theme.isDarkMode
            ? colors.colorbluegrey
            : colors.colorBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: () => _handleCancelOrder(context, ref, bondcancel),
      child: Text(
        "Yes",
        style: _textStyle(
          theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          12,
          FontWeight.w500,
        ),
      ),
    );
  }

   
}

TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
  return GoogleFonts.inter(
    textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ),
  );
}


_handleCancelOrder(BuildContext context, WidgetRef ref, BondsOrderBookModel bondcancel) async {
    Map<String, dynamic> bondOrderData = {};
    bondOrderData["clientApplicationNumber"] = bondcancel.clientApplicationNumber;
    bondOrderData["orderNumber"] = bondcancel.orderNumber;
    bondOrderData["symbol"] = bondcancel.symbol;
    bondOrderData["investmentValue"] = bondcancel.investmentValue;
    bondOrderData["price"] = bondcancel.bidDetail?.price ?? 0;

    Navigator.pop(context);
    Navigator.pop(context);

    await ref.read(bondsProvider).cancelBondOrder(context, bondOrderData);
    print('cancel bond data :::::::; $bondOrderData');
  }
