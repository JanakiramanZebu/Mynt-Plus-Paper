import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';
import '../ipo_orderbook_details/close_order_details.dart';

class IpoCloseOrder extends ConsumerWidget {
  const IpoCloseOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ipo.closeorder?.length ?? 0,
            itemBuilder: (context, index) => _CloseOrderItem(
              order: ipo.closeorder![index],
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
            _buildTopRow(),
            const SizedBox(height: 16),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 250,
          child: TextWidget.subText(
            text: order.companyName.toString(),
            theme: false,
            fw: 0,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
          ),
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

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.subText(
          text: order.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(order.responseDatetime.toString()),
          theme: false,
          fw: 3,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // SvgPicture.asset(
            //     order.reponseStatus == "cancel success"
            //         ? "assets/icon/failed.svg"
            //         : "assets/icon/failed.svg"),
            // const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: order.reponseStatus == "cancel success"
                    ? colors.pending.withOpacity(0.1)
                    : theme.isDarkMode
                        ? colors.lossDark.withOpacity(0.1)
                        : colors.lossLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextWidget.subText(
                text: order.reponseStatus == "cancel success"
                    ? "Cancelled"
                    : "Failed",
                theme: false,
                fw: 0,
                color: order.reponseStatus == "cancel success"
                    ? theme.isDarkMode
                        ? colors.pending
                        : colors.pending
                    : theme.isDarkMode
                        ? colors.lossDark
                        : colors.lossLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInvestedAmount() {
    return order.type == "BSE"
        ? "${getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].rate!) * double.parse(order.bidDetail![0].quantity!)).toString()}"
        : "${getFormatter(
            noDecimal: true,
            v4d: false,
            value:
                double.parse(order.bidDetail![0].amount.toString()).toDouble(),
          )}";
  }
}
