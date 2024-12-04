class Camsmodel {
  String? clienttxnid;
  String? consentHandle;
  String? custom;
  String? customerUniqueIdentifier;
  String? fiuid;
  String? redirectionurl;
  String? sessionId;
  String? timestamp;
  String? txnid;
  String? usecaseid;

  Camsmodel(
      {this.clienttxnid,
      this.consentHandle,
      this.custom,
      this.customerUniqueIdentifier,
      this.fiuid,
      this.redirectionurl,
      this.sessionId,
      this.timestamp,
      this.txnid,
      this.usecaseid});

  Camsmodel.fromJson(Map<String, dynamic> json) {
    clienttxnid = json['clienttxnid'];
    consentHandle = json['consentHandle'];
    custom = json['custom'];
    customerUniqueIdentifier = json['customerUniqueIdentifier'];
    fiuid = json['fiuid'];
    redirectionurl = json['redirectionurl'];
    sessionId = json['sessionId'];
    timestamp = json['timestamp'];
    txnid = json['txnid'];
    usecaseid = json['usecaseid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clienttxnid'] = clienttxnid;
    data['consentHandle'] = consentHandle;
    data['custom'] = custom;
    data['customerUniqueIdentifier'] = customerUniqueIdentifier;
    data['fiuid'] = fiuid;
    data['redirectionurl'] = redirectionurl;
    data['sessionId'] = sessionId;
    data['timestamp'] = timestamp;
    data['txnid'] = txnid;
    data['usecaseid'] = usecaseid;
    return data;
  }
}