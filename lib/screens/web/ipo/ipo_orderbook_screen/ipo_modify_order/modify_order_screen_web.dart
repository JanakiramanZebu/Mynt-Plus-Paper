// ignore_for_file: deprecated_member_use

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../models/ipo_model/ipo_details_model.dart';
import '../../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../../provider/iop_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../provider/transcation_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/snack_bar.dart';

class ModifyIpoOrderScreen extends ConsumerStatefulWidget {
  final IpoOrderBookModel modifyipoorder;

  const ModifyIpoOrderScreen({
    super.key,
    required this.modifyipoorder,
  });

  @override
  ConsumerState<ModifyIpoOrderScreen> createState() => _ModifyIpoOrderScreenState();
}

class _ModifyIpoOrderScreenState extends ConsumerState<ModifyIpoOrderScreen> {
  bool ischecked = false;
  String alertValue = "";
  String upierrortext = "";
  int bidbrice = 0;

  List<int> stringList = [];
  int? maxValue;
  List<IpoDetails> addIpo = [];
  
  final RegExp emailExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static RegExp upiRegex = RegExp(r'^[\w.-]+@[\w]+$');

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      addNewItem();
      maxValue = mininv(
              double.parse(widget.modifyipoorder.minprice!).toDouble(),
              int.parse(widget.modifyipoorder.minbidquantity!).toInt())
          .toInt();
    });
  }

  void addNewItem() {
    setState(() {
      for (int i = 0; i < widget.modifyipoorder.bidDetail!.length; i++) {
        addIpo.add(IpoDetails(
            qualitytext: "${widget.modifyipoorder.lotsize}",
            bidprice:
                "${double.parse(widget.modifyipoorder.bidDetail![i].atCutOff == true ? widget.modifyipoorder.maxprice! : widget.modifyipoorder.minprice!).toInt()}",
            lotsize: int.parse("${widget.modifyipoorder.lotsize}"),
            requriedprice: mininv(
                    double.parse(widget.modifyipoorder.minprice!).toDouble(),
                    int.parse(widget.modifyipoorder.minbidquantity!).toInt())
                .toInt(),
            isChecked: widget.modifyipoorder.bidDetail![i].atCutOff == null
                ? false
                : widget.modifyipoorder.bidDetail![i].atCutOff as bool));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ipo = ref.watch(ipoProvide);
        final theme = ref.watch(themeProvider);
        
        return Scaffold(
          appBar: _buildAppBar(theme),
          body: _buildBody(theme, ipo),
          bottomSheet: _buildBottomSheet(theme, ipo),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(theme) {
    return AppBar(
      elevation: .2,
      centerTitle: false,
      leadingWidth: 41,
      titleSpacing: 6,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: SvgPicture.asset(
            assets.backArrow,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          ),
        ),
      ),
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shadowColor: const Color(0xffECEFF3),
      title: Text(
        "Modify IPO",
        style: textStyles.appBarTitleTxt.copyWith(
          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        ),
      ),
    );
  }

  Widget _buildBody(theme, ipo) {
    return ListView(
      children: [
        _CompanyInfoHeader(
          modifyipoorder: widget.modifyipoorder,
          theme: theme,
        ),
        _CategorySection(ipo: ipo, theme: theme),
        _BidsList(
          addIpo: addIpo,
          modifyipoorder: widget.modifyipoorder,
          theme: theme,
          ipo: ipo,
          onMaxValueChanged: (value) {
            setState(() {
              maxValue = value;
            });
          },
          onErrorUpdate: () => setState(() {}),
        ),
        _UPISection(
          ipo: ipo,
          theme: theme,
          upierrortext: upierrortext,
          onUPIChanged: (error) {
            setState(() {
              upierrortext = error;
            });
          },
        ),
        _AgreementSection(
          ischecked: ischecked,
          theme: theme,
          ipo: ipo,
          addIpo: addIpo,
          modifyipoorder: widget.modifyipoorder,
          onCheckChanged: (checked) {
            setState(() {
              ischecked = checked;
            });
          },
        ),
        const SizedBox(height: 86),
      ],
    );
  }

  Widget _buildBottomSheet(theme, ipo) {
    return BottomAppBar(
      elevation: .14,
      child: ListTile(
        title: Text(
          "₹$maxValue",
          style: _textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            16,
            FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "Total Investment",
          style: _textStyle(const Color(0xff666666), 13, FontWeight.w500),
        ),
        trailing: ElevatedButton(
          onPressed: ischecked == true
              ? () => _handleContinuePressed(ipo)
              : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: !theme.isDarkMode
                ? ischecked == false
                    ? const Color(0xfff5f5f5)
                    : colors.colorBlack
                : ischecked == false
                    ? colors.darkGrey
                    : colors.colorbluegrey,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          ),
          child: Text(
            "Continue",
            style: _textStyle(
              !theme.isDarkMode
                  ? ischecked == false
                      ? const Color(0xff999999)
                      : colors.colorWhite
                  : ischecked == false
                      ? colors.darkGrey
                      : colors.colorBlack,
              14,
              FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinuePressed(ipo) {
    if (_validateForm(ipo)) {
      ipoplaceorder(ref.read(transcationProvider), ipo);
    }
  }

  bool _validateForm(ipo) {
    final lastIndex = addIpo.length - 1;
    
    if (addIpo[lastIndex].requriedprice > ipo.maxUPIAmt) {
      _showError("Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ");
      return false;
    }
    
    if (addIpo[lastIndex].bidpricecontroller.text.isEmpty || addIpo[lastIndex].bidpricecontroller.text == "0") {
      _showError(addIpo[lastIndex].bidpricecontroller.text == "0" 
          ? "Bid Price Value cannot be 0" 
          : "*Bid Price Value is required");
      return false;
    }
    
    if (addIpo[lastIndex].qualityController.text.isEmpty || addIpo[lastIndex].qualityController.text == "0") {
      _showError(addIpo[lastIndex].qualityController.text == "0"
          ? '* Quantity cannot be 0'
          : '* Quantity cannot be empty');
      return false;
    }
    
    if (ipo.viewupiid.text.isEmpty) {
      _showError('* UPI ID cannot be empty');
      return false;
    }
    
    if (!upiRegex.hasMatch(ipo.viewupiid.text)) {
      _showError('Invalid UPI ID format');
      return false;
    }
    
    return true;
  }

  void _showError(String message) {
    warningMessage(context, message);
  }

  Future<void> ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    final menudata = MenuData(
      flow: "mod",
      type: widget.modifyipoorder.type.toString(),
      symbol: widget.modifyipoorder.symbol.toString(),
      category: _getCategoryCode(ipo.ipoCategoryvalue),
      name: widget.modifyipoorder.companyName.toString(),
      applicationNumber: "${widget.modifyipoorder.applicationNumber}",
      respBid: [
        BidReference(
            bidReferenceNumber: "${widget.modifyipoorder.bidReferenceNumber}")
      ],
    );
    
    final String iposupiid = ipo.viewupiid.text;
    List<IposBid> iposbids = [];
    
    for (int i = 0; i < addIpo.length; i++) {
      iposbids.add(IposBid(
          bitis: true,
          qty: int.parse(addIpo[i].qualityController.text).toInt(),
          cutoff: addIpo[i].isChecked,
          price: double.parse(addIpo[i].bidpricecontroller.text).toDouble(),
          total: addIpo[i].requriedprice.toDouble()));
    }
    
    await ref.read(ipoProvide).fetchupiidvalidation(
        context, ipo.viewupiid.text, "343245", menudata, iposbids, iposupiid);
  }

  String _getCategoryCode(String? categoryValue) {
    switch (categoryValue) {
      case "Individual":
      case "HNI":
        return "IND";
      case "Employee":
        return "EMP";
      case "Shareholder":
        return "SHA";
      case "Policyholder":
        return "POL";
      default:
        return "";
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

// Extract header component
class _CompanyInfoHeader extends StatelessWidget {
  final IpoOrderBookModel modifyipoorder;
  final dynamic theme;

  const _CompanyInfoHeader({
    required this.modifyipoorder,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.colorBlack
            : const Color(0xffF1F3F8),
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : Colors.transparent,
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "${modifyipoorder.companyName}",
              style: _textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                15,
                FontWeight.w600,
              ),
            ),
            subtitle: _buildSubtitle(),
          ),
          _buildMetrics(),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        _buildChip("${modifyipoorder.symbol}"),
        const SizedBox(width: 8),
        _buildChip("IPO"),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.colorGrey.withOpacity(.1)
            : colors.colorWhite,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        text,
        style: _textStyle(const Color(0xff666666), 9, FontWeight.w500),
      ),
    );
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricColumn(
            "Price Range",
            "₹${double.parse(modifyipoorder.minprice!).toInt()}- ₹${double.parse(modifyipoorder.maxprice!).toInt()}",
          ),
          _buildMetricColumn(
            "Min.Qty",
            "${modifyipoorder.minbidquantity}",
          ),
          _buildMetricColumn(
            "IPO Size",
            formatInCrore(double.parse(modifyipoorder.issuesize!).toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: _textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: _textStyle(const Color(0xff666666), 12, FontWeight.w500),
        ),
      ],
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

// Extract category section
class _CategorySection extends StatelessWidget {
  final dynamic ipo;
  final dynamic theme;

  const _CategorySection({
    required this.ipo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Category',
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: !theme.isDarkMode
                      ? colors.colorWhite
                      : const Color.fromARGB(255, 16, 16, 16),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                customHeights: ipo.getCustomItemsHeight(ipo.ipoCategory),
              ),
              buttonStyleData: ButtonStyleData(
                height: 40,
                width: 124,
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.1)
                      : const Color(0xffF1F3F8),
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                ),
              ),
              isExpanded: true,
              style: _textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                13,
                FontWeight.w500,
              ),
              hint: Text(
                ipo.ipoCategorys,
                style: _textStyle(colors.colorBlack, 13, FontWeight.w500),
              ),
              items: ipo.addDividerSubCategory(ipo.ipoCategory.toSet().toList()),
              value: ipo.ipoCategoryvalue,
              onChanged: (value) async {
                ipo.chngCategoryType("$value");
                ipo.categoryOnChange(
                    [], ipo.maxUPIAmt, ipo.isMainIPOPlaceOrderBtnActive, "");
              },
            ),
          ),
        ),
      ],
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

// Extract bids list component
class _BidsList extends StatefulWidget {
  final List<IpoDetails> addIpo;
  final IpoOrderBookModel modifyipoorder;
  final dynamic theme;
  final dynamic ipo;
  final Function(int) onMaxValueChanged;
  final VoidCallback onErrorUpdate;

  const _BidsList({
    required this.addIpo,
    required this.modifyipoorder,
    required this.theme,
    required this.ipo,
    required this.onMaxValueChanged,
    required this.onErrorUpdate,
  });

  @override
  State<_BidsList> createState() => _BidsListState();
}

class _BidsListState extends State<_BidsList> {
  void _updateMaxValue() {
    int newMaxValue = widget.addIpo
        .map((map) => map.requriedprice)
        .reduce((a, b) => a > b ? a : b);
    widget.onMaxValueChanged(newMaxValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.addIpo.length,
      itemBuilder: (context, index) {
        return _BidItem(
          index: index,
          ipoDetail: widget.addIpo[index],
          modifyipoorder: widget.modifyipoorder,
          theme: widget.theme,
          ipo: widget.ipo,
          onChanged: () {
            _updateMaxValue();
            widget.onErrorUpdate();
          },
        );
      },
    );
  }
}

// Extract individual bid item
class _BidItem extends StatefulWidget {
  final int index;
  final IpoDetails ipoDetail;
  final IpoOrderBookModel modifyipoorder;
  final dynamic theme;
  final dynamic ipo;
  final VoidCallback onChanged;

  const _BidItem({
    required this.index,
    required this.ipoDetail,
    required this.modifyipoorder,
    required this.theme,
    required this.ipo,
    required this.onChanged,
  });

  @override
  State<_BidItem> createState() => _BidItemState();
}

class _BidItemState extends State<_BidItem> {
  void _updateQuantity(int change) {
    setState(() {
      if (widget.ipoDetail.qualityController.text.isNotEmpty) {
        int currentValue = int.parse(widget.ipoDetail.qualityController.text);
        int newValue = currentValue + change;
        if (newValue >= 0) {
          widget.ipoDetail.qualityController.text = newValue.toString();
          _updateRequiredPrice();
          _validateQuantity();
        }
      }
      widget.onChanged();
    });
  }

  void _updateRequiredPrice() {
    if (widget.ipoDetail.qualityController.text.isNotEmpty) {
      int quantity = int.parse(widget.ipoDetail.qualityController.text);
      double price = widget.ipoDetail.isChecked
          ? double.parse(widget.modifyipoorder.maxprice!)
          : double.parse(widget.modifyipoorder.minprice!);
      widget.ipoDetail.requriedprice = (price * quantity).toInt();
    }
  }

  void _validateQuantity() {
    if (widget.ipoDetail.qualityController.text.isEmpty ||
        widget.ipoDetail.qualityController.text == "0") {
      widget.ipoDetail.qualityerrortext = widget.ipoDetail.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else if (widget.ipoDetail.requriedprice > widget.ipo.maxUPIAmt) {
      widget.ipoDetail.qualityerrortext =
          "Maximum investment upto ₹${double.parse(widget.ipo.maxUPIAmt.toString()).toInt()} only ";
    } else if (int.parse(widget.ipoDetail.qualityController.text) <
        int.parse(widget.modifyipoorder.minbidquantity.toString()).toInt()) {
      widget.ipoDetail.qualityerrortext =
          "Minimum Bid quantity is ₹${widget.modifyipoorder.minbidquantity.toString()} only ";
    } else {
      widget.ipoDetail.qualityerrortext = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Bid - 0${widget.index + 1}",
            style: _textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuantityField()),
              const SizedBox(width: 10),
              Expanded(child: _buildBidPriceField()),
            ],
          ),
          if (widget.ipoDetail.qualityerrortext.isNotEmpty) ...[
            const SizedBox(height: 6),
            TextWidget.captionText(
              theme: false,
              text: widget.ipoDetail.qualityerrortext,
              color: colors.error,
              fw: 3,
            ),
          ],
          if (widget.ipoDetail.biderrortext.isNotEmpty) ...[
            const SizedBox(height: 6),
            TextWidget.captionText(
              theme: false,
              text: widget.ipoDetail.biderrortext,
              color: colors.error,
              fw: 3,
            ),
          ],
          _buildCutoffCheckbox(),
        ],
      ),
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quantity",
          style: _textStyle(
            widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: TextFormField(
            style: _textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            controller: widget.ipoDetail.qualityController,
            decoration: InputDecoration(
              fillColor: widget.theme.isDarkMode
                  ? colors.darkGrey
                  : const Color(0xffF1F3F8),
              filled: true,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              disabledBorder: InputBorder.none,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: const EdgeInsets.all(13),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              suffixIcon: InkWell(
                onTap: () => _updateQuantity(widget.ipoDetail.lotsize),
                child: SvgPicture.asset(
                  widget.theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                  fit: BoxFit.scaleDown,
                ),
              ),
              prefixIcon: InkWell(
                onTap: widget.ipoDetail.qualityController.text == widget.ipoDetail.qualitytext
                    ? null
                    : () => _updateQuantity(-widget.ipoDetail.lotsize),
                child: SvgPicture.asset(
                  widget.theme.isDarkMode ? assets.darkCMinus : assets.minusIcon,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                widget.ipoDetail.qualityController.text = value;
                _updateRequiredPrice();
                _validateQuantity();
                widget.onChanged();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBidPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bid Price",
          style: _textStyle(
            widget.theme.isDarkMode
                ? widget.ipoDetail.isChecked == true
                    ? colors.colorGrey
                    : colors.colorWhite
                : widget.ipoDetail.isChecked == true
                    ? colors.colorGrey
                    : colors.colorBlack,
            14,
            FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: TextFormField(
            style: _textStyle(
              widget.theme.isDarkMode
                  ? widget.ipoDetail.isChecked == true
                      ? colors.colorGrey
                      : colors.colorWhite
                  : widget.ipoDetail.isChecked == true
                      ? colors.colorGrey
                      : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            readOnly: widget.ipoDetail.isChecked == true,
            controller: widget.ipoDetail.bidpricecontroller,
            decoration: InputDecoration(
              fillColor: widget.theme.isDarkMode
                  ? colors.darkGrey
                  : const Color(0xffF1F3F8),
              filled: true,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              disabledBorder: InputBorder.none,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: const EdgeInsets.all(13),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              prefixIcon: SvgPicture.asset(
                assets.rupee,
                fit: BoxFit.values[5],
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 30),
            ),
            onChanged: (value) {
              setState(() {
                _validateBidPrice();
                widget.onChanged();
              });
            },
          ),
        ),
      ],
    );
  }

  void _validateBidPrice() {
    if (widget.ipoDetail.bidpricecontroller.text.isEmpty ||
        widget.ipoDetail.bidpricecontroller.text == "0") {
      widget.ipoDetail.biderrortext = widget.ipoDetail.bidpricecontroller.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else {
      int bidPrice = int.parse(widget.ipoDetail.bidpricecontroller.text);
      int minPrice = double.parse(widget.modifyipoorder.minprice!).toInt();
      int maxPrice = double.parse(widget.modifyipoorder.maxprice!).toInt();
      
      if (bidPrice > maxPrice || bidPrice < minPrice) {
        widget.ipoDetail.biderrortext =
            "Your bid price ranges lesser than ₹$minPrice ₹$maxPrice";
      } else {
        widget.ipoDetail.biderrortext = "";
      }
    }
  }

  Widget _buildCutoffCheckbox() {
    return Row(
      children: [
        IconButton(
          splashRadius: 20,
          onPressed: () {
            setState(() {
              widget.ipoDetail.biderrortext = "";
              widget.ipoDetail.isChecked = !widget.ipoDetail.isChecked;
              
              widget.ipoDetail.bidpricecontroller.text = widget.ipoDetail.isChecked
                  ? "${double.parse(widget.modifyipoorder.maxprice!).toInt()}"
                  : "${double.parse(widget.modifyipoorder.minprice!).toInt()}";
              
              _updateRequiredPrice();
              widget.onChanged();
              FocusScope.of(context).unfocus();
            });
          },
          icon: SvgPicture.asset(
            widget.theme.isDarkMode
                ? widget.ipoDetail.isChecked
                    ? assets.darkCheckedboxIcon
                    : assets.darkCheckboxIcon
                : widget.ipoDetail.isChecked
                    ? assets.checkedbox
                    : assets.checkbox,
          ),
        ),
        Text(
          "Cut-off price",
          style: _textStyle(const Color(0xff666666), 13, FontWeight.w600),
        ),
      ],
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

// Extract UPI section
class _UPISection extends StatefulWidget {
  final dynamic ipo;
  final dynamic theme;
  final String upierrortext;
  final Function(String) onUPIChanged;

  const _UPISection({
    required this.ipo,
    required this.theme,
    required this.upierrortext,
    required this.onUPIChanged,
  });

  @override
  State<_UPISection> createState() => _UPISectionState();
}

class _UPISectionState extends State<_UPISection> {
  static RegExp upiRegex = RegExp(r'^[\w.-]+@[\w]+$');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "UPI ID (Virtual payment address)",
            style: _textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 44,
          child: TextFormField(
            controller: widget.ipo.viewupiid,
            style: _textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
            decoration: InputDecoration(
              fillColor: widget.theme.isDarkMode
                  ? colors.darkGrey
                  : const Color(0xffF1F3F8),
              filled: true,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              disabledBorder: InputBorder.none,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: const EdgeInsets.all(13),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onChanged: (value) {
              String errorText = '';
              if (value.isEmpty) {
                errorText = "* UPI ID cannot be empty";
              } else if (!upiRegex.hasMatch(value)) {
                errorText = 'Invalid UPI ID format';
              }
              widget.onUPIChanged(errorText);
            },
          ),
        ),
        if (widget.upierrortext.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget.captionText(
              theme: false,
              text: widget.upierrortext,
              color: colors.error,
              fw: 3,
            ),
          ),
        ],
      ],
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

// Extract agreement section
class _AgreementSection extends StatelessWidget {
  final bool ischecked;
  final dynamic theme;
  final dynamic ipo;
  final List<IpoDetails> addIpo;
  final IpoOrderBookModel modifyipoorder;
  final Function(bool) onCheckChanged;

  const _AgreementSection({
    required this.ischecked,
    required this.theme,
    required this.ipo,
    required this.addIpo,
    required this.modifyipoorder,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              IconButton(
                splashRadius: 20,
                onPressed: ipo.loading ? null : () => _handleAgreementCheck(context),
                icon: SvgPicture.asset(
                  theme.isDarkMode
                      ? ischecked
                          ? assets.darkCheckedboxIcon
                          : assets.darkCheckboxIcon
                      : ischecked
                          ? assets.checkedbox
                          : assets.checkbox,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!ischecked) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 10),
            child: Text(
              "You Must Agree To Invest",
              style: _textStyle(colors.darkred, 13, FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }

  void _handleAgreementCheck(BuildContext context) {
    bool newChecked = !ischecked;
    
    if (!_validateAgreement(context)) {
      newChecked = false;
    }
    
    onCheckChanged(newChecked);
  }

  bool _validateAgreement(BuildContext context) {
    final lastBid = addIpo[addIpo.length - 1];
    
    if (lastBid.requriedprice > ipo.maxUPIAmt) {
      _showError(context, "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ");
      return false;
    }
    
    if (lastBid.bidpricecontroller.text.isEmpty || lastBid.bidpricecontroller.text == "0") {
      _showError(context, lastBid.bidpricecontroller.text == "0" 
          ? "*Bid Price Value cannot be 0" 
          : "*Bid Price Value is required");
      return false;
    }
    
    final bidPrice = int.parse(lastBid.bidpricecontroller.text);
    final minPrice = double.parse(modifyipoorder.minprice!).toInt();
    final maxPrice = double.parse(modifyipoorder.maxprice!).toInt();
    
    if (bidPrice > maxPrice || bidPrice < minPrice) {
      _showError(context, "Your bid price ranges between ₹$minPrice-₹$maxPrice");
      return false;
    }
    
    final quantity = int.parse(lastBid.qualityController.text);
    final minQuantity = int.parse(modifyipoorder.minbidquantity!);
    
    if (quantity < minQuantity) {
      _showError(context, "Minimum Bid quantity is ₹${modifyipoorder.minbidquantity} only ");
      return false;
    }
    
    if (lastBid.qualityController.text.isEmpty || lastBid.qualityController.text == "0") {
      _showError(context, lastBid.qualityController.text == "0" 
          ? '* Quantity cannot be 0' 
          : '* Quantity cannot be empty');
      return false;
    }
    
    if (ipo.viewupiid.text.isEmpty) {
      _showError(context, "UPI ID cannot be empty");
      return false;
    }
    
    if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(ipo.viewupiid.text)) {
      return false;
    }
    
    return true;
  }

  void _showError(BuildContext context, String message) {
    warningMessage(context, message);
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}
