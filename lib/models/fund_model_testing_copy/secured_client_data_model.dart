class DecryptClientCheck {
  String? emsg;
  ClientCheck? clientCheck;
  List<String>? companyCode;

  DecryptClientCheck({
    this.emsg,
    this.clientCheck,
    this.companyCode,
  });

  DecryptClientCheck.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    clientCheck = json['client_check'] != null
        ? ClientCheck.fromJson(json['client_check'])
        : null;
    companyCode = json['company_code']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (emsg != null) {
      data['emsg'] = emsg!;
    }
    if (clientCheck != null) {
      data['client_check'] = clientCheck!.toJson();
    }
    if (companyCode != null) {
      data['company_code'] = companyCode;
    }
    return data;
  }
}

class ClientCheck {
  List<String>? cOLUMNS;
  List<List<dynamic>>? dATA;

  ClientCheck({
    this.cOLUMNS,
    this.dATA,
  });

  ClientCheck.fromJson(Map<String, dynamic> json) {
    cOLUMNS = json['COLUMNS']?.cast<String>();
    if (json['DATA'] != null) {
      dATA = List<List<dynamic>>.from(
        json['DATA'].map((v) => List<dynamic>.from(v)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cOLUMNS != null) {
      data['COLUMNS'] = cOLUMNS;
    }
    if (dATA != null) {
      data['DATA'] = dATA!.map((v) => v).toList();
    }
    return data;
  }
}

class Emsg {
  String? emsg;

  Emsg({this.emsg});

  Emsg.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (emsg != null) {
      data['emsg'] = emsg;
    }
    return data;
  }
}
