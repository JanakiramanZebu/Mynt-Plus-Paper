import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../res/res.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart'; 

class OrderbookFilterBottomSheet extends StatefulWidget {
 
  const OrderbookFilterBottomSheet({super.key });

  @override
  State<OrderbookFilterBottomSheet> createState() =>
      _OrderbookFilterBottomSheetState();
}

class _OrderbookFilterBottomSheetState
    extends State<OrderbookFilterBottomSheet> {
  List<String> fliterList = [
    "Scrip - A to Z",
    "Scrip - Z to A",
    "Price - High to Low",
    "Price - Low to High",
    "Per.Chng - High to Low",
    "Per.Chng - Low to High"
  ];

  @override
  Widget build(BuildContext context) {final theme = context.read(themeProvider);
    return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Sort by", style: textStyles.appBarTitleTxt.copyWith(color:!theme.isDarkMode?colors.colorBlack: colors.colorWhite))])),
          Divider(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider),
          ListView.separated(
            shrinkWrap: true,
            itemCount: fliterList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onTap: () async {
                    selctedSortValue(index);
                    Navigator.pop(context);
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  dense: true,
                  title: Text(fliterList[index], style: textStyles.prdText),
                  trailing: SvgPicture.asset(
                    theme.isDarkMode? index == 0 ? assets.darkActProductIcon : assets.darkProductIcon:
                      index == 0 ? assets.actProductIcon : assets.productIcon));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          ),
        ],
      ),
    );
  }

  void selctedSortValue(int value) {
    return setState(() {
      if (value == 0) {
        context
            .read(orderProvider)
            .filterOrders(sorting: "ASC");
      } else if (value == 1) {
        context
            .read(orderProvider)
            .filterOrders(sorting: "DSC");
      } else if (value == 2) {
        context
            .read(orderProvider)
            .filterOrders(sorting: "LTPDSC");
      } else if (value == 3) {
        context
            .read(orderProvider)
            .filterOrders(sorting: "LTPASC");
      } else if (value == 4) {
        context
            .read(orderProvider)
            .filterOrders(sorting: "PCDESC");
      } else {
        context
            .read(orderProvider)
            .filterOrders(sorting: "PCASC");
      }
    });
  }
}
