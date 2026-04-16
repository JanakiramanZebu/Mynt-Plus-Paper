import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/models/bonds_model/bonds_place_order_details_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';

import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';

import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';

class BondOrderPopupWeb extends ConsumerStatefulWidget {
  final BondsList bondInfo;

  const BondOrderPopupWeb({
    super.key,
    required this.bondInfo,
  });

  @override
  ConsumerState<BondOrderPopupWeb> createState() => _BondOrderPopupWebState();
}

class _BondOrderPopupWebState extends ConsumerState<BondOrderPopupWeb> {
  late BondDetails bondDetails;

  @override
  void initState() {
    super.initState();
    _initializeBondDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bondsProvider).fetchLedgerBal();
    });
  }

  void _initializeBondDetails() {
    final bondInfo = widget.bondInfo;
    final faceValue = double.parse(bondInfo.faceValue ?? '1');
    final minBidQty = int.parse(bondInfo.minBidQuantity ?? '1');
    final maxQty = int.parse(bondInfo.maxQuantity ?? '1');
    final cutoffPrice = double.parse(bondInfo.cutoffPrice ?? '0');
    final lotSize = int.parse(bondInfo.lotSize ?? '1');

    bondDetails = BondDetails(
      quantitytext: '${(minBidQty / faceValue).toInt()}',
      bidprice: '${cutoffPrice.toInt()}',
      lotsize: (lotSize / faceValue).toInt(),
      minrequriedprice: (cutoffPrice * (minBidQty / faceValue)).toInt(),
      maxrequriedprice: (cutoffPrice * (maxQty / faceValue)).toInt(),
    );
  }

  int get minUnits {
    final faceValue = double.parse(widget.bondInfo.faceValue ?? '1');
    final minBidQty = int.parse(widget.bondInfo.minBidQuantity ?? '1');
    return (minBidQty / faceValue).toInt();
  }

  int get maxUnits {
    final faceValue = double.parse(widget.bondInfo.faceValue ?? '1');
    final maxQty = int.parse(widget.bondInfo.maxQuantity ?? '1');
    return (maxQty / faceValue).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);
    final isDark = theme.isDarkMode;

    final cashBalance = double.tryParse(bonds.ledgerBalModel?.total ?? '0') ?? 0;
    final investmentAmount = bondDetails.minrequriedprice.toDouble();
    final hasInsufficientBalance = cashBalance < investmentAmount;
    final shortfall = investmentAmount - cashBalance;

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Width: scales from 85% on very small screens to 400px max
    final double popupWidth;
    if (screenWidth < 360) {
      popupWidth = screenWidth * 0.85;
    } else if (screenWidth < 450) {
      popupWidth = screenWidth * 0.88;
    } else if (screenWidth < 600) {
      popupWidth = 380.0;
    } else {
      popupWidth = 400.0;
    }

    // Padding scales with screen size
    final horizontalPadding = screenWidth < 360 ? 12.0 : (screenWidth < 450 ? 16.0 : 24.0);
    final verticalPadding = screenWidth < 360 ? 12.0 : (screenWidth < 450 ? 16.0 : 24.0);
    final isSmallScreen = screenWidth < 450;
    final isVerySmallScreen = screenWidth < 360;

    return Container(
      width: popupWidth,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? MyntColors.dialogDark : MyntColors.dialog,
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 8 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with padding
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              isVerySmallScreen ? 12 : 16,
            ),
            child: _buildHeader(context, isDark, isSmallScreen),
          ),
          // Full width divider
          Container(
            width: double.infinity,
            height: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: const Color(0xFFE8E8E8)),
          ),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),

          // Units label with range
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildUnitsLabel(context, isDark),
          ),
          SizedBox(height: isVerySmallScreen ? 6 : 10),

          // Quantity selector using MyntTextField
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildQuantitySelector(context, isDark, bonds, isSmallScreen),
          ),

          // Error messages
          if (bondDetails.quantityerrortext.isNotEmpty) ...[
            SizedBox(height: isVerySmallScreen ? 6 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                bondDetails.quantityerrortext,
                style: MyntWebTextStyles.para(
                  context,
                  color: MyntColors.primary,
                ),
              ),
            ),
          ],

          // Insufficient balance warning
          if (hasInsufficientBalance && bondDetails.quantityerrortext.isEmpty) ...[
            SizedBox(height: isVerySmallScreen ? 6 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                'Insufficient balance, Add fund ₹${shortfall.toStringAsFixed(2)}',
                style: MyntWebTextStyles.para(
                  context,
                  color: resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error),
                ),
              ),
            ),
          ],

          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),

          // Bottom section - Cash / Investment
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, verticalPadding),
            child: _buildBottomSection(context, isDark, cashBalance, investmentAmount, hasInsufficientBalance, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isSmallScreen) {
    final cutoffPrice = double.tryParse(widget.bondInfo.cutoffPrice ?? '0') ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bond info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bondInfo.name ?? '',
                style: isSmallScreen
                    ? MyntWebTextStyles.body(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                      )
                    : MyntWebTextStyles.title(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                '${widget.bondInfo.symbol ?? ''} ${widget.bondInfo.isin ?? ''}',
                style: isSmallScreen
                    ? MyntWebTextStyles.caption(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary,
                      )
                    : MyntWebTextStyles.para(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary,
                      ),
              ),
            ],
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 16),
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${cutoffPrice.toStringAsFixed(1)}',
              style: isSmallScreen
                  ? MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                    )
                  : MyntWebTextStyles.title(
                      context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              'Cut-off Price',
              style: MyntWebTextStyles.caption(
                context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        // Close button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
              child: Icon(
                Icons.close,
                size: isSmallScreen ? 18 : 20,
                color: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsLabel(BuildContext context, bool isDark) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Units ',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          TextSpan(
            text: '($minUnits - $maxUnits)',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.regular,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, bool isDark, BondsProvider bonds, bool isSmallScreen) {
    final fieldHeight = isSmallScreen ? 40.0 : 48.0;
    final buttonSize = isSmallScreen ? 40.0 : 48.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return MyntTextField(
      controller: bondDetails.quantityController,
      placeholder: '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.left,
      height: fieldHeight,
      borderRadius: 8,
      backgroundColor: isDark ? MyntColors.transparent : const Color(0xFFF5F7FA),
      borderColor: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
      textStyle: isSmallScreen
          ? MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.medium,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            )
          : MyntWebTextStyles.titlesub(
              context,
              fontWeight: MyntFonts.medium,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
      leadingWidget: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: bonds.loading
              ? null
              : () {
                  bonds.substractQuantity(bondDetails);
                  setState(() {});
                },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            child: Icon(
              Icons.remove_circle_outline,
              color: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
              size: iconSize,
            ),
          ),
        ),
      ),
      trailingWidget: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: bonds.loading
              ? null
              : () {
                  bonds.addQuantity(bondDetails);
                  setState(() {});
                },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            child: Icon(
              Icons.add_circle_outline,
              color:resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
              size: iconSize,
            ),
          ),
        ),
      ),
      onChanged: (value) {
        bonds.quantityOnchange(bondDetails, value);
        setState(() {});
      },
    );
  }

  Widget _buildBottomSection(BuildContext context, bool isDark, double cashBalance, double investmentAmount, bool hasInsufficientBalance, double screenWidth) {
    final isSmallScreen = screenWidth < 450;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cash / Investment
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${cashBalance.toStringAsFixed(1)} / ₹${investmentAmount.toStringAsFixed(1)}',
                style: MyntWebTextStyles.title(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cash / Invesment',
                style: isSmallScreen
                    ? MyntWebTextStyles.caption(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: const Color(0xFF666666),
                      )
                    : MyntWebTextStyles.para(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: const Color(0xFF666666),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 16),
        // Add Fund / Place Order button
        ElevatedButton(
          onPressed: hasInsufficientBalance
              ? () {
                  Navigator.pop(context);
                  if (WebNavigationHelper.isAvailable) {
                    WebNavigationHelper.navigateTo(Routes.fundscreen,
                        arguments: 'addMoney');
                  }
                }
              : () {
                  _placeOrder();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: isSmallScreen ? 12 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            hasInsufficientBalance ? 'Add Fund' : 'Place Order',
            style: isSmallScreen
                ? MyntWebTextStyles.bodySmall(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: Colors.white,
                  )
                : MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }

  void _placeOrder() async {
    final bonds = ref.read(bondsProvider);
    if (bonds.isBondPlaceOrderBtnActive) {
      final bondOrderData = {
        "symbol": widget.bondInfo.symbol ?? '',
        "investmentValue": bondDetails.minrequriedprice,
        "price": int.tryParse(bondDetails.bidprice) ?? 0,
      };
      await bonds.placeBondOrder(context, bondOrderData);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

/// Shows the bond order popup dialog
void showBondOrderPopup(BuildContext context, BondsList bondInfo) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BondOrderPopupWeb(bondInfo: bondInfo),
    ),
  );
}
