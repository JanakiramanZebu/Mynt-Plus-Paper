import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoOpenOrder extends ConsumerWidget {
  // final IPOProvider ipo;
  const IpoOpenOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ipo.showSearch) _SearchBar(ipo: ipo, theme: theme),
          ipo.iposearch!.isEmpty
              ? _OpenOrderList(orders: ipo.openorder!, theme: theme)
              : _OpenOrderList(orders: ipo.iposearch!, theme: theme, isSearch: true),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final dynamic ipo;
  final dynamic theme;

  const _SearchBar({required this.ipo, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.only(left: 16, top: 8),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffF1F3F8),
                  width: 6))),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: ipo.openOrderController,
              style: _textStyle(
                  theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                  16,
                  FontWeight.w600),
              decoration: InputDecoration(
                  fillColor: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffF1F3F8),
                  filled: true,
                  hintStyle: GoogleFonts.inter(
                      textStyle: _textStyle(const Color(0xff69758F), 15,
                          FontWeight.w500)),
                  prefixIconColor: const Color(0xff586279),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SvgPicture.asset(assets.searchIcon,
                        color: const Color(0xff586279),
                        fit: BoxFit.contain,
                        width: 20),
                  ),
                  suffixIcon: InkWell(
                    onTap: ipo.clearopenoreder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SvgPicture.asset(assets.removeIcon,
                          fit: BoxFit.scaleDown, width: 20),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  disabledBorder: InputBorder.none,
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  hintText: "Search Ipo",
                  contentPadding: const EdgeInsets.only(top: 20),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20)))),
              onChanged: (value) async {
                ipo.openOrderSearch(value, context);
              },
            ),
          ),
          TextButton(
              onPressed: () {
                ipo.showOpenSearch(false);
                ipo.getipoorderbookmodel(false);
              },
              child: Text("Close",
                  style: textStyles.textBtn.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue)))
        ],
      ),
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class _OpenOrderList extends StatelessWidget {
  final List<dynamic> orders;
  final dynamic theme;
  final bool isSearch;

  const _OpenOrderList({
    required this.orders,
    required this.theme,
    this.isSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) => _OpenOrderItem(
        order: orders[index],
        theme: theme,
        isSearch: isSearch,
      ),
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 0,
          color: theme.isDarkMode
              ? colors.darkColorDivider
              : colors.colorDivider,
        );
      },
    );
  }
}

class _OpenOrderItem extends StatelessWidget {
  final dynamic order;
  final dynamic theme;
  final bool isSearch;

  const _OpenOrderItem({
    required this.order,
    required this.theme,
    this.isSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
            context, Routes.ipoopendetailsscreen,
            arguments: order);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
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
          child: Text(
              order.companyName.toString(),
              style: textStyles.scripNameTxtStyle.copyWith(
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack),
              overflow: TextOverflow.ellipsis),
        ),
        Text(
          _getInvestedAmount(),
          style: _textStyle(
              theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
              14,
              FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(order.responseDatetime.toString()),
          style: _textStyle(
              isSearch 
                  ? (theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
                  : const Color(0xff666666),
              isSearch ? 14 : 12,
              FontWeight.w600),
        ),
        Row(
          children: [
            SvgPicture.asset(order.reponseStatus == "new success"
                ? "assets/icon/success.svg"
                : "assets/icon/pendingicon.svg"),
            SizedBox(width: isSearch ? 4 : 5),
            Text(
              order.reponseStatus == "new success"
                  ? "Success"
                  : "Pending",
              style: _textStyle(
                  theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                  14,
                  FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _getInvestedAmount() {
    if (isSearch) {
      return order.type == "BSE"
          ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].rate!) * double.parse(order.bidDetail![0].quantity!)).toString()}"
          : "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].amount.toString()))}";
    } else {
      // For regular orders, calculate max value
      List<String> stringList = [];
      for (var i = 0; i < order.bidDetail!.length; i++) {
        stringList.add(order.type == "BSE"
            ? (double.parse(order.bidDetail![i].rate!) *
                double.parse(order.bidDetail![i].quantity!))
                .toString()
            : order.bidDetail![i].amount.toString());
      }
      String maxValue = stringList
          .reduce((curr, next) =>
              double.parse(curr) > double.parse(next) ? curr : next)
          .toString();
      return "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(maxValue))}";
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
