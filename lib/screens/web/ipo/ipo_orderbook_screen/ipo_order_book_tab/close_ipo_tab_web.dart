import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../provider/iop_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/functions.dart';
import '../ipo_orderbook_details/close_order_details_web.dart';

class IpoCloseOrder extends ConsumerWidget {
  final List<dynamic>? filteredOrders;

  const IpoCloseOrder({super.key, this.filteredOrders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    // Use filtered orders if provided, otherwise use original orders
    final ordersToDisplay = filteredOrders ?? ipo.closeorder ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ordersToDisplay.length,
            itemBuilder: (context, index) => _CloseOrderItem(
              order: ordersToDisplay[index],
              theme: theme,
            ),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                  height: 1,
                  color: theme.isDarkMode
                      ? colors.dividerDark
                      : colors.dividerLight);
            },
          )
        ],
      ),
    );
  }
}

class _CloseOrderItem extends StatelessWidget {
  final dynamic order;
  final dynamic theme;

  const _CloseOrderItem({
    required this.order,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          isDismissible: true,
          enableDrag: false,
          useSafeArea: true,
          context: context,
          builder: (context) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: IpoCloseOrderDetails(ipoclose: order)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopRow(context),
            const SizedBox(height: 8),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextWidget.subText(
            text: order.companyName.toString(),
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis,
            fw: 0,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: order.reponseStatus == "cancel success"
                ? colors.pending.withOpacity(0.1)
                : theme.isDarkMode
                    ? colors.lossDark.withOpacity(0.1)
                    : colors.lossLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextWidget.paraText(
            text: order.reponseStatus == "cancel success"
                ? "Cancelled"
                : "Failed",
            theme: false,
            color: order.reponseStatus == "cancel success"
                ? theme.isDarkMode
                    ? colors.pending
                    : colors.pending
                : theme.isDarkMode
                    ? colors.lossDark
                    : colors.lossLight,
            fw: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.paraText(
          text: order.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(order.responseDatetime.toString()),
          theme: false,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
        TextWidget.subText(
          text: _getInvestedAmount(),
          theme: false,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
        ),
      ],
    );
  }

  String _getInvestedAmount() {
    return order.type == "BSE"
        ? getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].rate!) * double.parse(order.bidDetail![0].quantity!)).toString()
        : getFormatter(
            noDecimal: true,
            v4d: false,
            value:
                double.parse(order.bidDetail![0].amount.toString()).toDouble(),
          );
  }
}
