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

    return Container(
      width: 400,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, isDark),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
          const SizedBox(height: 24),

          // Units label with range
          _buildUnitsLabel(context, isDark),
          const SizedBox(height: 12),

          // Quantity selector using MyntTextField
          _buildQuantitySelector(context, isDark, bonds),

          // Error messages
          if (bondDetails.quantityerrortext.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              bondDetails.quantityerrortext,
              style: MyntWebTextStyles.para(
                context,
                color: const Color(0xFFE53935),
              ),
            ),
          ],

          // Insufficient balance warning
          if (hasInsufficientBalance && bondDetails.quantityerrortext.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Insufficient balance, Add fund ₹${shortfall.toStringAsFixed(2)}',
              style: MyntWebTextStyles.para(
                context,
                color: const Color(0xFFE53935),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Bottom section - Cash / Investment
          _buildBottomSection(context, isDark, cashBalance, investmentAmount, hasInsufficientBalance),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                style: MyntWebTextStyles.title(
                  context,
                  darkColor: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  lightColor: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  fontWeight: MyntFonts.medium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.bondInfo.symbol ?? ''} ${widget.bondInfo.isin ?? ''}',
                style: MyntWebTextStyles.para(
                  context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${cutoffPrice.toStringAsFixed(1)}',
              style: MyntWebTextStyles.title(
                context,
                darkColor: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                lightColor: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: MyntFonts.medium,
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
        const SizedBox(width: 12),
        // Close button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 24,
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
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.semiBold,
            ),
          ),
          TextSpan(
            text: '($minUnits - $maxUnits)',
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: const Color(0xFF666666),
              fontWeight: MyntFonts.regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, bool isDark, BondsProvider bonds) {
    return MyntTextField(
      controller: bondDetails.quantityController,
      placeholder: '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.start,
      height: 48,
      borderRadius: 4,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F5F7),
      borderColor: MyntColors.primary,
      textStyle: MyntWebTextStyles.body(
          context,
          darkColor: MyntColors.textPrimaryDark,
          lightColor: MyntColors.textPrimary,
          fontWeight: MyntFonts.medium),
      leadingWidget: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: bonds.loading
              ? null
              : () {
                  bonds.substractQuantity(bondDetails);
                  setState(() {});
                },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              Icons.remove_circle_outline,
              color: MyntColors.primary,
              size: 26,
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
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              Icons.add_circle_outline,
              color: MyntColors.primary,
              size: 26,
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

  Widget _buildBottomSection(BuildContext context, bool isDark, double cashBalance, double investmentAmount, bool hasInsufficientBalance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cash / Investment
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${cashBalance.toStringAsFixed(1)} / ₹${investmentAmount.toStringAsFixed(1)}',
              style: MyntWebTextStyles.title(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: Colors.black,
                fontWeight: MyntFonts.semiBold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Cash / Invesment',
              style: MyntWebTextStyles.para(
                context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: const Color(0xFF666666),
              ),
            ),
          ],
        ),
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
            backgroundColor: MyntColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            hasInsufficientBalance ? 'Add Fund' : 'Place Order',
            style: MyntWebTextStyles.body(
              context,
              color: Colors.white,
              fontWeight: MyntFonts.semiBold,
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
