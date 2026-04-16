class DercomcurModel {
  Data? data;
  Map<String, dynamic>? details;

  DercomcurModel({this.data, this.details});

  DercomcurModel.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null ? Data.fromJson(json['data']['data']) : null;
    if (json['data'] != null && json['data']['data'] != null && json['data']['data']['details'] != null && json['data']['data']['details'] is Map) {
      details = Map<String, dynamic>.from(json['data']['data']['details']);
    }
  }
}

class Data {
  Charges? charges;
  Commodity? commodity;
  Currency? currency;
  Derivatives? derivatives;

  Data({this.charges, this.commodity, this.currency, this.derivatives});

  Data.fromJson(Map<String, dynamic> json) {
    charges =
        json['Charges'] != null ? Charges.fromJson(json['Charges']) : null;
    commodity = json['Commodity'] != null
        ? Commodity.fromJson(json['Commodity'])
        : null;
    currency = json['Currency'] != null
        ? Currency.fromJson(json['Currency'])
        : null;
    derivatives = json['Derivatives'] != null
        ? Derivatives.fromJson(json['Derivatives'])
        : null;
  }
  Map<String, dynamic> toJson() {
    return {
      "Charges": charges?.toJson(),
      "Commodity": commodity?.toJson(),
      "Currency": currency?.toJson(),
      "Derivatives": derivatives?.toJson(),
    };
  }
}

class Charges {
  List<Map<String, dynamic>>? commCharges;
  List<Map<String, dynamic>>? curCharges;
  List<Map<String, dynamic>>? derCharges;

  String? derChargesTotal;
  String? curChargesTotal;
  String? commChargesTotal;

  Charges(
      {this.commCharges,
      this.commChargesTotal,
      this.curCharges,
      this.curChargesTotal,
      this.derCharges,
      this.derChargesTotal});

  Charges.fromJson(Map<String, dynamic> json) {
    if (json['comm_charges'] != null) {
      commCharges = <Map<String, dynamic>>[];
      json['comm_charges'].forEach((v) {
        commCharges!.add(v);
      });
    }
    if (json['cur_charges'] != null) {
      curCharges = <Map<String, dynamic>>[];
      json['cur_charges'].forEach((v) {
        curCharges!.add(v);
      });
    }
    if (json['der_charges'] != null) {
      derCharges = <Map<String, dynamic>>[];
      json['der_charges'].forEach((v) {
        derCharges!.add(v);
      });
    }

    commChargesTotal = json['comm_charges_total'].toStringAsFixed(2);
    curChargesTotal = json['cur_charges_total'].toString();
    derChargesTotal = json['der_charges_total'].toString();
  }
  Map<String, dynamic> toJson() {
    return {
      "comm_charges": commCharges,
      "cur_charges": curCharges,
      "der_charges": derCharges,
      "comm_charges_total": commChargesTotal,
      "cur_charges_total": curChargesTotal,
      "der_charges_total": derChargesTotal,
    };
  }
}

class Commodity {
  List<Map<String, dynamic>>? comFutOpen;
  List<Map<String, dynamic>>? comFutBooked;
  List<Map<String, dynamic>>? comOptBooked;
  List<Map<String, dynamic>>? comOptOpen;

  String? commFutPnl;
  String? commFutTo;
  String? commOptPnl;
  String? commOptTo;

  Commodity(
      {this.comFutOpen,
      this.comFutBooked,
      this.comOptBooked,
      this.comOptOpen,
      this.commFutPnl,
      this.commFutTo,
      this.commOptPnl,
      this.commOptTo});

  Commodity.fromJson(Map<String, dynamic> json) {
    if (json['com_fut_open'] != null) {
      comFutOpen = <Map<String, dynamic>>[];
      json['com_fut_open'].forEach((v) {
        comFutOpen!.add(v);
      });
    }
    if (json['com_fut_booked'] != null) {
      comFutBooked = <Map<String, dynamic>>[];
      json['com_fut_booked'].forEach((v) {
        comFutBooked!.add(v);
      });
    }
    if (json['com_opt_booked'] != null) {
      comOptBooked = <Map<String, dynamic>>[];
      json['com_opt_booked'].forEach((v) {
        comOptBooked!.add(v);
      });
    }
    if (json['com_opt_open'] != null) {
      comOptOpen = <Map<String, dynamic>>[];
      json['com_opt_open'].forEach((v) {
        comOptOpen!.add(v);
      });
    }

    commFutPnl = json['comm_fut_pnl'].toString();
    commFutTo = json['comm_fut_to'].toString();
    commOptPnl = json['comm_opt_pnl'].toString();
    commOptTo = json['comm_opt_to'].toString();
  }
   Map<String, dynamic> toJson() {
    return {
      "com_fut_open": comFutOpen,
      "com_fut_booked": comFutBooked,
      "com_opt_booked": comOptBooked,
      "com_opt_open": comOptOpen,
      "comm_fut_pnl": commFutPnl,
      "comm_fut_to": commFutTo,
      "comm_opt_pnl": commOptPnl,
      "comm_opt_to": commOptTo,
    };
  }
}

class Currency {
  List<Map<String, dynamic>>? currFutBooked;
  List<Map<String, dynamic>>? currFutOpen;
  List<Map<String, dynamic>>? currOptBooked;
  List<Map<String, dynamic>>? currOptOpen;
  String? currFutPnl;
  String? currFutTo;
  String? currOptPnl;
  String? currOptTo;

  Currency(
      {this.currFutBooked,
      this.currFutOpen,
      this.currOptBooked,
      this.currOptOpen,
      this.currFutPnl,
      this.currFutTo,
      this.currOptPnl,
      this.currOptTo});

  Currency.fromJson(Map<String, dynamic> json) {
    if (json['curr_fut_booked'] != null) {
      currFutBooked = <Map<String, dynamic>>[];
      json['curr_fut_booked'].forEach((v) {
        currFutBooked!.add(v);
      });
    }
    if (json['curr_fut_open'] != null) {
      currFutOpen = <Map<String, dynamic>>[];
      json['curr_fut_open'].forEach((v) {
        currFutOpen!.add(v);
      });
    }
    if (json['curr_opt_booked'] != null) {
      currOptBooked = <Map<String, dynamic>>[];
      json['curr_opt_booked'].forEach((v) {
        currOptBooked!.add(v);
      });
    }
    if (json['curr_opt_open'] != null) {
      currOptOpen = <Map<String, dynamic>>[];
      json['curr_opt_open'].forEach((v) {
        currOptOpen!.add(v);
      });
    }
    currOptPnl = json['curr_opt_pnl'].toString();
    currOptTo = json['curr_opt_to'].toString();
    currFutPnl = json['curr_fut_pnl'].toString();
    currFutTo = json['curr_fut_to'].toString();
  }
    Map<String, dynamic> toJson() {
    return {
      "curr_fut_booked": currFutBooked,
      "curr_fut_open": currFutOpen,
      "curr_opt_booked": currOptBooked,
      "curr_opt_open": currOptOpen,
      "curr_fut_pnl": currFutPnl,
      "curr_fut_to": currFutTo,
      "curr_opt_pnl": currOptPnl,
      "curr_opt_to": currOptTo,
    };
  }
}

class Derivatives {
  List<Map<String, dynamic>>? derFutBooked;
  List<Map<String, dynamic>>? derFutOpen;
  List<Map<String, dynamic>>? derOptBooked;
  List<Map<String, dynamic>>? derOptOpen;
  String? derFutPnl;
  String? derFutTo;
  String? derOptPnl;
  String? derOptTo;

  Derivatives(
      {this.derFutBooked,
      this.derFutOpen,
      this.derOptBooked,
      this.derOptOpen,
      this.derFutPnl,
      this.derFutTo,
      this.derOptPnl,
      this.derOptTo});

  Derivatives.fromJson(Map<String, dynamic> json) {
    if (json['der_Fut_booked'].isNotEmpty) {
      derFutBooked = <Map<String, dynamic>>[];
      json['der_Fut_booked'].forEach((v) {
        derFutBooked!.add(v);
      });
    }
    if (json['der_Fut_open'].isNotEmpty) {
      derFutOpen = <Map<String, dynamic>>[];
      json['der_Fut_open'].forEach((v) {
        derFutOpen!.add(v);
      });
    }
    if (json['der_Opt_booked'].isNotEmpty) {
      derOptBooked = <Map<String, dynamic>>[];
      json['der_Opt_booked'].forEach((v) {
        derOptBooked!.add(v);
      });
    }
    if (json['der_Opt_open'].isNotEmpty) {
      derOptOpen = <Map<String, dynamic>>[];
      json['der_Opt_open'].forEach((v) {
        derOptOpen!.add(v);
      });
    }
    derFutPnl = json['der_fut_pnl'].toString();
    derFutTo = json['der_fut_to'].toString();
    derOptPnl = json['der_opt_pnl'].toString();
    derOptTo = json['der_opt_to'].toString();
  }
    Map<String, dynamic> toJson() {
    return {
      "der_Fut_booked": derFutBooked,
      "der_Fut_open": derFutOpen,
      "der_Opt_booked": derOptBooked,
      "der_Opt_open": derOptOpen,
      "der_fut_pnl": derFutPnl,
      "der_fut_to": derFutTo,
      "der_opt_pnl": derOptPnl,
      "der_opt_to": derOptTo,
    };
  }
}
