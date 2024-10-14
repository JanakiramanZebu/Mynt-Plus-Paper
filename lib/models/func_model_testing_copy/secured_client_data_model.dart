class DecryptClientCheck {
  ClientCheck? clientCheck;
  List<String>? companyCode;

  DecryptClientCheck({this.clientCheck, this.companyCode});

  DecryptClientCheck.fromJson(Map<String, dynamic> json) {
    clientCheck = json['client_check'] != null
        ? ClientCheck.fromJson(json['client_check'])
        : null;
    companyCode = json['company_code'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (clientCheck != null) {
      data['client_check'] = clientCheck!.toJson();
    }
    data['company_code'] = companyCode;
    return data;
  }
}

class ClientCheck {
  List<String>? cOLUMNS;
  List<List>? dATA;

  ClientCheck({this.cOLUMNS, this.dATA});

  ClientCheck.fromJson(Map<String, dynamic> json) {
    cOLUMNS = json['COLUMNS'].cast<String>();
    if (json['DATA'] != null) {
      dATA = <List>[];
      json['DATA'].forEach((v) {
        dATA!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['COLUMNS'] = cOLUMNS;
    if (dATA != null) {
      data['DATA'] = dATA!.map((v) => v).toList();
    }
    return data;
  }
}
