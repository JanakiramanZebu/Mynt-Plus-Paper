class CAEventsModel {
  List<Rights>? rights;
  List<AGMEGM>? aGMEGM;
  List<Boardmeeting>? boardmeeting;
  List<Bonus>? bonus;
  List<Dividend>? dividend;
  List<Split>? split;

  CAEventsModel(
      {this.rights,
      this.aGMEGM,
      this.boardmeeting,
      this.bonus,
      this.dividend,
      this.split});

  CAEventsModel.fromJson(Map<String, dynamic> json) {
    if (json['rights'] != null) {
      rights = <Rights>[];
      json['rights'].forEach((v) {
        rights!.add(new Rights.fromJson(v));
      });
    }
    if (json['AGM/EGM'] != null) {
      aGMEGM = <AGMEGM>[];
      json['AGM/EGM'].forEach((v) {
        aGMEGM!.add(new AGMEGM.fromJson(v));
      });
    }
    if (json['boardmeeting'] != null) {
      boardmeeting = <Boardmeeting>[];
      json['boardmeeting'].forEach((v) {
        boardmeeting!.add(new Boardmeeting.fromJson(v));
      });
    }
    if (json['bonus'] != null) {
      bonus = <Bonus>[];
      json['bonus'].forEach((v) {
        bonus!.add(new Bonus.fromJson(v));
      });
    }
    if (json['dividend'] != null) {
      dividend = <Dividend>[];
      json['dividend'].forEach((v) {
        dividend!.add(new Dividend.fromJson(v));
      });
    }
    if (json['split'] != null) {
      split = <Split>[];
      json['split'].forEach((v) {
        split!.add(new Split.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rights != null) {
      data['rights'] = this.rights!.map((v) => v.toJson()).toList();
    }
    if (this.aGMEGM != null) {
      data['AGM/EGM'] = this.aGMEGM!.map((v) => v.toJson()).toList();
    }
    if (this.boardmeeting != null) {
      data['boardmeeting'] = this.boardmeeting!.map((v) => v.toJson()).toList();
    }
    if (this.bonus != null) {
      data['bonus'] = this.bonus!.map((v) => v.toJson()).toList();
    }
    if (this.dividend != null) {
      data['dividend'] = this.dividend!.map((v) => v.toJson()).toList();
    }
    if (this.split != null) {
      data['split'] = this.split!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rights {
  String? companyName;
  String? exRightsDate;
  String? offerPrice;
  String? premiumRs;
  String? ratioN;
  String? rationD;
  String? recordDate;
  String? sourceDate;

  Rights(
      {this.companyName,
      this.exRightsDate,
      this.offerPrice,
      this.premiumRs,
      this.ratioN,
      this.rationD,
      this.recordDate,
      this.sourceDate});

  Rights.fromJson(Map<String, dynamic> json) {
    companyName = json['company name'];
    exRightsDate = json['ex_rights_date'];
    offerPrice = json['offer price'];
    premiumRs = json['premium_rs'];
    ratioN = json['ratio_n'];
    rationD = json['ration_d'];
    recordDate = json['record date'];
    sourceDate = json['source date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company name'] = this.companyName;
    data['ex_rights_date'] = this.exRightsDate;
    data['offer price'] = this.offerPrice;
    data['premium_rs'] = this.premiumRs;
    data['ratio_n'] = this.ratioN;
    data['ration_d'] = this.rationD;
    data['record date'] = this.recordDate;
    data['source date'] = this.sourceDate;
    return data;
  }
}

class AGMEGM {
  String? eGMDate;
  String? agenda;
  String? companyName;

  AGMEGM({this.eGMDate, this.agenda, this.companyName});

  AGMEGM.fromJson(Map<String, dynamic> json) {
    eGMDate = json['EGM date'];
    agenda = json['agenda'];
    companyName = json['company name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EGM date'] = this.eGMDate;
    data['agenda'] = this.agenda;
    data['company name'] = this.companyName;
    return data;
  }
}

class Boardmeeting {
  String? agenda;
  String? boardMeetingDate;
  String? companyName;

  Boardmeeting({this.agenda, this.boardMeetingDate, this.companyName});

  Boardmeeting.fromJson(Map<String, dynamic> json) {
    agenda = json['agenda'];
    boardMeetingDate = json['board meeting date'];
    companyName = json['company name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['agenda'] = this.agenda;
    data['board meeting date'] = this.boardMeetingDate;
    data['company name'] = this.companyName;
    return data;
  }
}

class Bonus {
  String? companyName;
  String? cumBonusDate;
  String? exBonusDate;
  String? ratioD;
  String? ratioN;
  String? recordDate;
  String? sourceDate;

  Bonus(
      {this.companyName,
      this.cumBonusDate,
      this.exBonusDate,
      this.ratioD,
      this.ratioN,
      this.recordDate,
      this.sourceDate});

  Bonus.fromJson(Map<String, dynamic> json) {
    companyName = json['company name'];
    cumBonusDate = json['cum_bonus_date'];
    exBonusDate = json['ex_bonus_date'];
    ratioD = json['ratio_d'];
    ratioN = json['ratio_n'];
    recordDate = json['record_date'];
    sourceDate = json['source_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company name'] = this.companyName;
    data['cum_bonus_date'] = this.cumBonusDate;
    data['ex_bonus_date'] = this.exBonusDate;
    data['ratio_d'] = this.ratioD;
    data['ratio_n'] = this.ratioN;
    data['record_date'] = this.recordDate;
    data['source_date'] = this.sourceDate;
    return data;
  }
}

class Dividend {
  String? companyName;
  String? details;
  String? dividendDate;
  String? dividendPercent;
  String? dividendpershare;
  String? exDate;
  String? recordDate;

  Dividend(
      {this.companyName,
      this.details,
      this.dividendDate,
      this.dividendPercent,
      this.dividendpershare,
      this.exDate,
      this.recordDate});

  Dividend.fromJson(Map<String, dynamic> json) {
    companyName = json['company name'];
    details = json['details'];
    dividendDate = json['dividend date'];
    dividendPercent = json['dividend percent'];
    dividendpershare = json['dividendpershare'];
    exDate = json['ex-date'];
    recordDate = json['record date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company name'] = this.companyName;
    data['details'] = this.details;
    data['dividend date'] = this.dividendDate;
    data['dividend percent'] = this.dividendPercent;
    data['dividendpershare'] = this.dividendpershare;
    data['ex-date'] = this.exDate;
    data['record date'] = this.recordDate;
    return data;
  }
}

class Split {
  String? companyName;
  String? exDate;
  String? fvChangeFrom;
  String? fvChangeTo;
  String? recordDate;

  Split(
      {this.companyName,
      this.exDate,
      this.fvChangeFrom,
      this.fvChangeTo,
      this.recordDate});

  Split.fromJson(Map<String, dynamic> json) {
    companyName = json['company name'];
    exDate = json['ex_date'];
    fvChangeFrom = json['fv_change_from'];
    fvChangeTo = json['fv_change_to'];
    recordDate = json['record date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company name'] = this.companyName;
    data['ex_date'] = this.exDate;
    data['fv_change_from'] = this.fvChangeFrom;
    data['fv_change_to'] = this.fvChangeTo;
    data['record date'] = this.recordDate;
    return data;
  }
}
