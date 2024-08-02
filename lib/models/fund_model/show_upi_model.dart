class ViewUpiIdModel {
  List<Data>? data;
  String? stat;

  ViewUpiIdModel({this.data, this.stat});

  ViewUpiIdModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class Data {
  String? accountNumber;
  String? bankName;
  String? clientId;
  String? upiId;

  Data({this.accountNumber, this.bankName, this.clientId, this.upiId});

  Data.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    bankName = json['bank_name'];
    clientId = json['client_id'];
    upiId = json['upi_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_number'] = accountNumber;
    data['bank_name'] = bankName;
    data['client_id'] = clientId;
    data['upi_id'] = upiId;
    return data;
  }
}
