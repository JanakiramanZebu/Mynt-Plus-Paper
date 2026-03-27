class ClientBankDetailsResponse {
  String? stat;
  List<ClientBankDetail>? data;

  ClientBankDetailsResponse({this.stat, this.data});

  ClientBankDetailsResponse.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['data'] != null) {
      data = <ClientBankDetail>[];
      json['data'].forEach((v) {
        data!.add(ClientBankDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['stat'] = stat;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ClientBankDetail {
  String? status;
  String? micrNo;
  String? accountNo;
  String? bankName;
  String? ifscCode;
  String? createdAt;
  String? accountType;
  String? bankBranch;
  String? lastModifiedAt;
  String? defaultBankFlag;

  ClientBankDetail({
    this.status,
    this.micrNo,
    this.accountNo,
    this.bankName,
    this.ifscCode,
    this.createdAt,
    this.accountType,
    this.bankBranch,
    this.lastModifiedAt,
    this.defaultBankFlag,
  });

  ClientBankDetail.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    micrNo = json['MICR_No'];
    accountNo = json['AccountNo'];
    bankName = json['Bank_Name'];
    ifscCode = json['IFSC_Code'];
    createdAt = json['Created_At'];
    accountType = json['AccountType'];
    bankBranch = json['Bank_Branch'];
    lastModifiedAt = json['Last_Modified_At'];
    defaultBankFlag = json['Default_Bank_Flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['Status'] = status;
    map['MICR_No'] = micrNo;
    map['AccountNo'] = accountNo;
    map['Bank_Name'] = bankName;
    map['IFSC_Code'] = ifscCode;
    map['Created_At'] = createdAt;
    map['AccountType'] = accountType;
    map['Bank_Branch'] = bankBranch;
    map['Last_Modified_At'] = lastModifiedAt;
    map['Default_Bank_Flag'] = defaultBankFlag;
    return map;
  }
}
