import 'package:flutter/material.dart';

class IpoDetails {
  String qualitytext;
  String bidprice;
  String qualityerrortext;
  String biderrortext;
  int lotsize;
  int requriedprice;
  bool isChecked;
  TextEditingController qualityController;
  TextEditingController bidpricecontroller;

  IpoDetails({
    this.qualitytext = '',
    this.bidprice = '',
    this.isChecked = false,
    this.qualityerrortext = '',
    this.biderrortext = '',
    this.lotsize = 0,
    this.requriedprice = 0,
  })  : qualityController = TextEditingController(text: qualitytext),
        bidpricecontroller = TextEditingController(text: bidprice);
}
