class MandateDetailModel {
  MandateData? data;
  String? stat;
  String? emsg;

  MandateDetailModel({this.data, this.stat, this.emsg});

  MandateDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? MandateData.fromJson(json['data']) : null;
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class MandateData {
  List<MandateDetails>? mandateDetails;
  String? message;
  String? status;

  MandateData({this.mandateDetails, this.message, this.status});

  MandateData.fromJson(Map<String, dynamic> json) {
    if (json['MandateDetails'] != null) {
      mandateDetails = <MandateDetails>[];
      json['MandateDetails'].forEach((v) {
        mandateDetails!.add(MandateDetails.fromJson(v));
      });
    }
    message = json['Message'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mandateDetails != null) {
      data['MandateDetails'] = mandateDetails!.map((v) => v.toJson()).toList();
    }
    data['Message'] = message;
    data['Status'] = status;
    return data;
  }
}

class MandateDetails {
  String? amount;
  String? approvedDate;
  String? bankAccNo;
  String? bankBranch;
  String? bankName;
  String? clientCode;
  String? clientName;
  String? collectionType;
  String? mandateId;
  String? mandateType;
  String? memberCode;
  String? regnDate;
  String? remarks;
  String? status;
  String? uMRNNo;
  String? uploadDate;

  MandateDetails(
      {this.amount,
      this.approvedDate,
      this.bankAccNo,
      this.bankBranch,
      this.bankName,
      this.clientCode,
      this.clientName,
      this.collectionType,
      this.mandateId,
      this.mandateType,
      this.memberCode,
      this.regnDate,
      this.remarks,
      this.status,
      this.uMRNNo,
      this.uploadDate});

  MandateDetails.fromJson(Map<String, dynamic> json) {
    amount = json['Amount'];
    approvedDate = json['ApprovedDate'];
    bankAccNo = json['BankAccNo'];
    bankBranch = json['BankBranch'];
    bankName = json['BankName'];
    clientCode = json['ClientCode'];
    clientName = json['ClientName'];
    collectionType = json['CollectionType'];
    mandateId = json['MandateId'];
    mandateType = json['MandateType'];
    memberCode = json['MemberCode'];
    regnDate = json['RegnDate'];
    remarks = json['Remarks'];
    status = json['Status'];
    uMRNNo = json['UMRNNo'];
    uploadDate = json['UploadDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Amount'] = amount;
    data['ApprovedDate'] = approvedDate;
    data['BankAccNo'] = bankAccNo;
    data['BankBranch'] = bankBranch;
    data['BankName'] = bankName;
    data['ClientCode'] = clientCode;
    data['ClientName'] = clientName;
    data['CollectionType'] = collectionType;
    data['MandateId'] = mandateId;
    data['MandateType'] = mandateType;
    data['MemberCode'] = memberCode;
    data['RegnDate'] = regnDate;
    data['Remarks'] = remarks;
    data['Status'] = status;
    data['UMRNNo'] = uMRNNo;
    data['UploadDate'] = uploadDate;
    return data;
  }
}
