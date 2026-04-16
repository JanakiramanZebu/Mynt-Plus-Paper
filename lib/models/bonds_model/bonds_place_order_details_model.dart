import 'package:flutter/material.dart';

class BondDetails {
  String quantitytext;
  String bidprice;
  String quantityerrortext;
  String biderrortext;
  int lotsize;
  int minrequriedprice;
  int maxrequriedprice;
  int faceValue;
  double availableLedgerBalance;
  String ledgerBalErrorText;
  TextEditingController quantityController;
  TextEditingController bidpricecontroller;

  BondDetails({
    this.quantitytext = '',
    this.bidprice = '',
    this.quantityerrortext = '',
    this.biderrortext = '',
    this.lotsize = 0,
    this.faceValue = 0,
    this.availableLedgerBalance=0.0,
    this.ledgerBalErrorText = '',
    this.minrequriedprice = 0,
    this.maxrequriedprice = 0,
  })  : quantityController = TextEditingController(text: quantitytext),
        bidpricecontroller = TextEditingController(text: bidprice);
}
