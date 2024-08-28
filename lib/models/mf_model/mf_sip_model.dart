class MfSIPModel {
  List<SipData>? data;
  String? stat;

  MfSIPModel({this.data, this.stat});

  MfSIPModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SipData>[];
      json['data'].forEach((v) {
        data!.add(SipData.fromJson(v));
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

class SipData {
  String? aMCCODE;
  String? aMCNAME;
  String? iSIN;
  String? pAUSEFLAG;
  String? pAUSEMAXIMUMINSTALLMENTS;
  String? pAUSEMINIMUMINSTALLMENTS;
  String? pAUSEMODIFICATIONCOUNT;
  String? sCHEMECODE;
  String? sCHEMENAME;
  String? sIPDATES;
  String? sIPFREQUENCY;
  String? sIPINSTALLMENTGAP;
  String? sIPMAXIMUMGAP;
  String? sIPMAXIMUMINSTALLMENTAMOUNT;
  String? sIPMAXIMUMINSTALLMENTNUMBERS;
  String? sIPMINIMUMGAP;
  String? sIPMINIMUMINSTALLMENTAMOUNT;
  String? sIPMINIMUMINSTALLMENTNUMBERS;
  String? sIPMULTIPLIERAMOUNT;
  String? sIPSTATUS;
  String? sIPTRANSACTIONMODE;
  String? schemeType;

  SipData(
      {this.aMCCODE,
      this.aMCNAME,
      this.iSIN,
      this.pAUSEFLAG,
      this.pAUSEMAXIMUMINSTALLMENTS,
      this.pAUSEMINIMUMINSTALLMENTS,
      this.pAUSEMODIFICATIONCOUNT,
      this.sCHEMECODE,
      this.sCHEMENAME,
      this.sIPDATES,
      this.sIPFREQUENCY,
      this.sIPINSTALLMENTGAP,
      this.sIPMAXIMUMGAP,
      this.sIPMAXIMUMINSTALLMENTAMOUNT,
      this.sIPMAXIMUMINSTALLMENTNUMBERS,
      this.sIPMINIMUMGAP,
      this.sIPMINIMUMINSTALLMENTAMOUNT,
      this.sIPMINIMUMINSTALLMENTNUMBERS,
      this.sIPMULTIPLIERAMOUNT,
      this.sIPSTATUS,
      this.sIPTRANSACTIONMODE,
      this.schemeType});

  SipData.fromJson(Map<String, dynamic> json) {
    aMCCODE = json['AMC_CODE'];
    aMCNAME = json['AMC_NAME'];
    iSIN = json['ISIN'];
    pAUSEFLAG = json['PAUSE_FLAG'];
    pAUSEMAXIMUMINSTALLMENTS = json['PAUSE_MAXIMUM_INSTALLMENTS'];
    pAUSEMINIMUMINSTALLMENTS = json['PAUSE_MINIMUM_INSTALLMENTS'];
    pAUSEMODIFICATIONCOUNT = json['PAUSE_MODIFICATION_COUNT'];
    sCHEMECODE = json['SCHEME_CODE'];
    sCHEMENAME = json['SCHEME_NAME'];
    sIPDATES = json['SIP_DATES'];
    sIPFREQUENCY = json['SIP_FREQUENCY'];
    sIPINSTALLMENTGAP = json['SIP_INSTALLMENT_GAP'];
    sIPMAXIMUMGAP = json['SIP_MAXIMUM_GAP'];
    sIPMAXIMUMINSTALLMENTAMOUNT = json['SIP_MAXIMUM_INSTALLMENT_AMOUNT'];
    sIPMAXIMUMINSTALLMENTNUMBERS = json['SIP_MAXIMUM_INSTALLMENT_NUMBERS'];
    sIPMINIMUMGAP = json['SIP_MINIMUM_GAP'];
    sIPMINIMUMINSTALLMENTAMOUNT = json['SIP_MINIMUM_INSTALLMENT_AMOUNT'];
    sIPMINIMUMINSTALLMENTNUMBERS = json['SIP_MINIMUM_INSTALLMENT_NUMBERS'];
    sIPMULTIPLIERAMOUNT = json['SIP_MULTIPLIER_AMOUNT'];
    sIPSTATUS = json['SIP_STATUS'];
    sIPTRANSACTIONMODE = json['SIP_TRANSACTION_MODE'];
    schemeType = json['Scheme_Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AMC_CODE'] = aMCCODE;
    data['AMC_NAME'] = aMCNAME;
    data['ISIN'] = iSIN;
    data['PAUSE_FLAG'] = pAUSEFLAG;
    data['PAUSE_MAXIMUM_INSTALLMENTS'] = pAUSEMAXIMUMINSTALLMENTS;
    data['PAUSE_MINIMUM_INSTALLMENTS'] = pAUSEMINIMUMINSTALLMENTS;
    data['PAUSE_MODIFICATION_COUNT'] = pAUSEMODIFICATIONCOUNT;
    data['SCHEME_CODE'] = sCHEMECODE;
    data['SCHEME_NAME'] = sCHEMENAME;
    data['SIP_DATES'] = sIPDATES;
    data['SIP_FREQUENCY'] = sIPFREQUENCY;
    data['SIP_INSTALLMENT_GAP'] = sIPINSTALLMENTGAP;
    data['SIP_MAXIMUM_GAP'] = sIPMAXIMUMGAP;
    data['SIP_MAXIMUM_INSTALLMENT_AMOUNT'] = sIPMAXIMUMINSTALLMENTAMOUNT;
    data['SIP_MAXIMUM_INSTALLMENT_NUMBERS'] = sIPMAXIMUMINSTALLMENTNUMBERS;
    data['SIP_MINIMUM_GAP'] = sIPMINIMUMGAP;
    data['SIP_MINIMUM_INSTALLMENT_AMOUNT'] = sIPMINIMUMINSTALLMENTAMOUNT;
    data['SIP_MINIMUM_INSTALLMENT_NUMBERS'] = sIPMINIMUMINSTALLMENTNUMBERS;
    data['SIP_MULTIPLIER_AMOUNT'] = sIPMULTIPLIERAMOUNT;
    data['SIP_STATUS'] = sIPSTATUS;
    data['SIP_TRANSACTION_MODE'] = sIPTRANSACTIONMODE;
    data['Scheme_Type'] = schemeType;
    return data;
  }
}
