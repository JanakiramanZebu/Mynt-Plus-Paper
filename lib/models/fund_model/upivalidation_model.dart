class UpiIdValidationModel {
  Data? data;

  UpiIdValidationModel({this.data});

  UpiIdValidationModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? clientVPA;
  String? orderNumber;
  String? verifiedVPAStatus1;
  String? verifiedVPAStatus2;
  String? verifiedClientName;

  Data(
      {this.clientVPA,
      this.orderNumber,
      this.verifiedVPAStatus1,
      this.verifiedVPAStatus2,
      this.verifiedClientName});

  Data.fromJson(Map<String, dynamic> json) {
    clientVPA = json['client_VPA'];
    orderNumber = json['orderNumber'];
    verifiedVPAStatus1 = json['verified_VPA_status1'];
    verifiedVPAStatus2 = json['verified_VPA_status2'];
    verifiedClientName = json['verified_client_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_VPA'] = clientVPA;
    data['orderNumber'] = orderNumber;
    data['verified_VPA_status1'] = verifiedVPAStatus1;
    data['verified_VPA_status2'] = verifiedVPAStatus2;
    data['verified_client_name'] = verifiedClientName;
    return data;
  }
}
