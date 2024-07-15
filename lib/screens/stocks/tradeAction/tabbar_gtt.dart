import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:group_radio_button/group_radio_button.dart';

import '../../../../res/res.dart';

enum SingingCharacter { Delivery, Intraday }

class GttTabView extends StatefulWidget {
  const GttTabView({
    super.key,
  });

  @override
  State<GttTabView> createState() => _GttTabViewState();
}

class _GttTabViewState extends State<GttTabView> {
  // @override
  // void initState() {
  //   super.initState();
  //   setState(() {
  //     isBuy = widget.tradedata.transType;

  //     priceCtrl = TextEditingController(text: "dd");
  //     qtyCtrl = TextEditingController(text: "${widget.tradedata.lotSize}");
  //   });
  // }
  // int _stackIndex = 0;

  // String _singleValue = "Text alignment right";
  // String _verticalGroupValue = "Pending";

  // final _status = ["Pending", "Released", "Blocked"];
  TextEditingController addtraget = TextEditingController();
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController palceorder = TextEditingController();
  TextEditingController stoploss = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  String selectedOption = 'Option 1';
  bool? isBuy;
  SingingCharacter? _character = SingingCharacter.Delivery;
  int simpleIntInput = 0;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Investment type',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff666666)),
            ),
          ),
          SizedBox(
            height: 20,
            child: Row(
              children: [
                Radio<SingingCharacter>(
                  activeColor: const Color(0xff000000),
                  value: SingingCharacter.Delivery,
                  groupValue: _character,
                  onChanged: (SingingCharacter? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
                Text(
                  'Singel',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff3E4763)),
                ),
                Radio<SingingCharacter>(
                  activeColor: const Color(0xff000000),
                  value: SingingCharacter.Intraday,
                  groupValue: _character,
                  onChanged: (SingingCharacter? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
                Text(
                  'OCO',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff666666)),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 50.0,
          //   child: RadioGroup<String>.builder(
          //     direction: Axis.horizontal,
          //     groupValue: _verticalGroupValue,
          //     horizontalAlignment: MainAxisAlignment.spaceAround,
          //     onChanged: (value) => setState(() {
          //       _verticalGroupValue = value ?? '';
          //     }),
          //     items: _status,
          //     textStyle: const TextStyle(
          //       fontSize: 15,
          //       color: Colors.blue,
          //     ),
          //     itemBuilder: (item) => RadioButtonBuilder(
          //       item,
          //     ),
          //   ),
          // ),
          // // ignore: unrelated_type_equality_checks
          // if (_verticalGroupValue == "Pending") ...[
          //  const SizedBox(
          //     height: 200,
          //     child: Row(
          //       children: [Text('data')],
          //     ),
          //   )
          // ],
          const SizedBox(
            height: 28,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quantity",
                        style: textStyle(
                            const Color(0xff000000), 14, FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      width: 164,
                      child: TextFormField(
                        controller: qtyCtrl,
                        style: textStyle(
                            const Color(0xff000000), 16, FontWeight.w600),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                            fillColor: const Color(0xffF1F3F8),
                            filled: true,
                            hintText: "43",
                            hintStyle: textStyle(
                                const Color(0xff999999), 16, FontWeight.w600),
                            labelStyle: textStyle(
                                const Color(0xff000000), 16, FontWeight.w600),
                            prefixIconColor: const Color(0xff586279),
                            suffixIcon: InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                assets.addIcon,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            prefixIcon: InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                assets.minusIcon,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30)),
                            disabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30))),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price",
                        style: textStyle(
                            const Color(0xff000000), 14, FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 44,
                      width: 164,
                      child: TextFormField(
                        controller: priceCtrl,
                        style: textStyle(
                            const Color(0xff000000), 16, FontWeight.w600),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            fillColor: const Color(0xffF1F3F8),
                            filled: true,
                            hintText: "1,288.90",
                            hintStyle: textStyle(
                                const Color(0xff999999), 16, FontWeight.w600),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            labelStyle: GoogleFonts.inter(
                                textStyle: textStyle(const Color(0xff000000),
                                    16, FontWeight.w600)),
                            prefixIconColor: const Color(0xff586279),
                            suffixIcon: SvgPicture.asset(
                              assets.lock,
                              fit: BoxFit.scaleDown,
                            ),
                            prefix: SvgPicture.asset(
                              assets.ruppeIcon,
                              fit: BoxFit.scaleDown,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30)),
                            disabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30))),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Divider(
              color: Color(0xffF1F2F4),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Place order',
                      style: GoogleFonts.inter(
                          color: const Color(0xff000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 9,
                    ),
                    Text(
                      'if order is above',
                      style: GoogleFonts.inter(
                          color: const Color(0xff666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    SvgPicture.asset(
                      assets.downArrow,
                      // ignore: deprecated_member_use
                      color: const Color(0xff0037B7),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 44,
                  width: screenWidth,
                  child: TextFormField(
                    controller: palceorder,
                    style:
                        textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                        hintText: "1,288.90",
                        hintStyle: textStyle(
                            const Color(0xff999999), 16, FontWeight.w600),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        labelStyle: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff000000), 16, FontWeight.w600)),
                        prefixIconColor: const Color(0xff586279),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 20, top: 7, bottom: 7),
                          child: Container(
                            alignment: Alignment.center,
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                // ignore: prefer_const_constructors
                                color: Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              '5.09%',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(
                                    0xff000000,
                                  ),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        prefix: SvgPicture.asset(
                          assets.ruppeIcon,
                          fit: BoxFit.scaleDown,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30))),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Color(0xffF1F2F4),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set stoploss and set Target',
                      style: GoogleFonts.inter(
                          letterSpacing: 0.28,
                          fontSize: 14,
                          color: const Color(
                            0xff666666,
                          ),
                          fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      child: isChecked
                          ? SvgPicture.asset(
                              assets.checkedbox,
                            )
                          : SvgPicture.asset(
                              assets.checkbox,
                            ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                Row(
                  children: [
                    Text(
                      'Add stop loss',
                      style: GoogleFonts.inter(
                          color: const Color(0xff000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 9,
                    ),
                    Text(
                      'Protected by MPP of 3%',
                      style: GoogleFonts.inter(
                          color: const Color(0xff666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 44,
                  width: screenWidth,
                  child: TextFormField(
                    controller: stoploss,
                    style:
                        textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                        hintText: "1,288.90",
                        hintStyle: textStyle(
                            const Color(0xff999999), 16, FontWeight.w600),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        labelStyle: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff000000), 16, FontWeight.w600)),
                        prefixIconColor: const Color(0xff586279),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 20, top: 7, bottom: 7),
                          child: Container(
                            alignment: Alignment.center,
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                // ignore: prefer_const_constructors
                                color: Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              '5.09%',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(
                                    0xff000000,
                                  ),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        prefix: SvgPicture.asset(
                          assets.ruppeIcon,
                          fit: BoxFit.scaleDown,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30))),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Add target',
                      style: GoogleFonts.inter(
                          color: const Color(0xff000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 44,
                  width: screenWidth,
                  child: TextFormField(
                    controller: addtraget,
                    style:
                        textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                        hintText: "1,288.90",
                        hintStyle: textStyle(
                            const Color(0xff999999), 16, FontWeight.w600),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        labelStyle: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff000000), 16, FontWeight.w600)),
                        prefixIconColor: const Color(0xff586279),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 20, top: 7, bottom: 7),
                          child: Container(
                            alignment: Alignment.center,
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                // ignore: prefer_const_constructors
                                color: Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              '5.09%',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(
                                    0xff000000,
                                  ),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        prefix: SvgPicture.asset(
                          assets.ruppeIcon,
                          fit: BoxFit.scaleDown,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30))),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(
                color: Color(0xffFAFBFF),
                border: Border(
                    top: BorderSide(color: Color(0xffF1F2F4), width: 1),
                    bottom: BorderSide(color: Color(0xffF1F2F4), width: 1))),
            child: Row(
              children: [
                Text(
                  'Margin: ',
                  style: GoogleFonts.inter(
                      color: const Color(0xff666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '₹2,33,800',
                  style: GoogleFonts.inter(
                      color: const Color(0xff000000),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                // ignore: prefer_const_constructors
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Charges: ',
                  style: GoogleFonts.inter(
                      color: const Color(0xff666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '₹1.58',
                  style: GoogleFonts.inter(
                      color: const Color(0xff000000),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: screenWidth,
              height: 45,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xff000000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  child: const Text('Buy Now')),
            ),
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

Container disableContainer() {
  return Container(
    height: 44,
    width: 140,
    decoration: BoxDecoration(
        color: const Color(0xff999999).withOpacity(.3),
        borderRadius: BorderRadius.circular(30)),
    child: const Center(
      child: Text(
        "0",
      ),
    ),
  );
}
