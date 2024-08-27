class BankDetailsModel {
  List<BankData>? data;
  String? stat;
  String? emsg;

  BankDetailsModel({this.data, this.stat, this.emsg});

  BankDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <BankData>[];
      json['data'].forEach((v) {
        data!.add(BankData.fromJson(v));
      });
    }
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class BankData {
  String? accountCode;
  String? bANKACCTYPE;
  String? bankAcNo;
  String? bankName;
  String? defaultAc;
  String? iFSCCode;
  String? micrCode;

  BankData(
      {this.accountCode,
      this.bANKACCTYPE,
      this.bankAcNo,
      this.bankName,
      this.defaultAc,
      this.iFSCCode,
      this.micrCode});

  BankData.fromJson(Map<String, dynamic> json) {
    accountCode = json['Account_Code'];
    bANKACCTYPE = json['BANK_ACCTYPE'];
    bankAcNo = json['Bank_AcNo'];
    bankName = json['Bank_Name'];
    defaultAc = json['Default_Ac'];
    iFSCCode = json['IFSC_Code'];
    micrCode = json['Micr_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Account_Code'] = accountCode;
    data['BANK_ACCTYPE'] = bANKACCTYPE;
    data['Bank_AcNo'] = bankAcNo;
    data['Bank_Name'] = bankName;
    data['Default_Ac'] = defaultAc;
    data['IFSC_Code'] = iFSCCode;
    data['Micr_code'] = micrCode;
    return data;
  }
}

class UPIDetailsModel {
  List<UPIData>? data;
  String? stat;
  String? emsg;

  UPIDetailsModel({this.data, this.stat, this.emsg});

  UPIDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <UPIData>[];
      json['data'].forEach((v) {
        data!.add(UPIData.fromJson(v));
      });
    }
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class UPIData {
  String? accountNumber;
  String? bankName;
  String? clientId;
  String? upiId;

  UPIData({this.accountNumber, this.bankName, this.clientId, this.upiId});

  UPIData.fromJson(Map<String, dynamic> json) {
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

class VerifyUPIModel {
  UPIVerifyData? data;
  String? emsg;

  VerifyUPIModel({this.data, this.emsg});

  VerifyUPIModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? UPIVerifyData.fromJson(json['data']) : null;
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['emsg'] = emsg;
    return data;
  }
}

class UPIVerifyData {
  String? clientVPA;
  String? orderNumber;
  String? verifiedVPAStatus1;
  String? verifiedVPAStatus2;
  String? verifiedClientName;

  UPIVerifyData(
      {this.clientVPA,
      this.orderNumber,
      this.verifiedVPAStatus1,
      this.verifiedVPAStatus2,
      this.verifiedClientName});

  UPIVerifyData.fromJson(Map<String, dynamic> json) {
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
