class GetOrderlistCopModel {
  List<Msg>? msg;

  GetOrderlistCopModel({this.msg});

  GetOrderlistCopModel.fromJson(Map<String, dynamic> json) {
    if (json['msg'] != null) {
      msg = <Msg>[];
      json['msg'].forEach((v) {
        msg!.add(Msg.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (msg != null) {
      data['msg'] = msg!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Msg {
  String? applicationNo;
  String? bidQuan;
  String? orderType;
  String? price;
  String? rejectionreason;
  String? series;
  String? status;
  String? symbol;

  Msg(
      {this.applicationNo,
      this.bidQuan,
      this.orderType,
      this.price,
      this.rejectionreason,
      this.series,
      this.status,
      this.symbol});

  Msg.fromJson(Map<String, dynamic> json) {
    applicationNo = json['application_no'];
    bidQuan = json['bid_quan'];
    orderType = json['order_type'];
    price = json['price'];
    rejectionreason = json['rejectionreason'];
    series = json['series'];
    status = json['status'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['application_no'] = applicationNo;
    data['bid_quan'] = bidQuan;
    data['order_type'] = orderType;
    data['price'] = price;
    data['rejectionreason'] = rejectionreason;
    data['series'] = series;
    data['status'] = status;
    data['symbol'] = symbol;
    return data;
  }
}
