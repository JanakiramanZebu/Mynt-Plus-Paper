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
        rights!.add(Rights.fromJson(v));
      });
    }
    if (json['AGM/EGM'] != null) {
      aGMEGM = <AGMEGM>[];
      json['AGM/EGM'].forEach((v) {
        aGMEGM!.add(AGMEGM.fromJson(v));
      });
    }
    if (json['boardmeeting'] != null) {
      boardmeeting = <Boardmeeting>[];
      json['boardmeeting'].forEach((v) {
        boardmeeting!.add(Boardmeeting.fromJson(v));
      });
    }
    if (json['bonus'] != null) {
      bonus = <Bonus>[];
      json['bonus'].forEach((v) {
        bonus!.add(Bonus.fromJson(v));
      });
    }
    if (json['dividend'] != null) {
      dividend = <Dividend>[];
      json['dividend'].forEach((v) {
        dividend!.add(Dividend.fromJson(v));
      });
    }
    if (json['split'] != null) {
      split = <Split>[];
      json['split'].forEach((v) {
        split!.add(Split.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rights != null) {
      data['rights'] = rights!.map((v) => v.toJson()).toList();
    }
    if (aGMEGM != null) {
      data['AGM/EGM'] = aGMEGM!.map((v) => v.toJson()).toList();
    }
    if (boardmeeting != null) {
      data['boardmeeting'] = boardmeeting!.map((v) => v.toJson()).toList();
    }
    if (bonus != null) {
      data['bonus'] = bonus!.map((v) => v.toJson()).toList();
    }
    if (dividend != null) {
      data['dividend'] = dividend!.map((v) => v.toJson()).toList();
    }
    if (split != null) {
      data['split'] = split!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company name'] = companyName;
    data['ex_rights_date'] = exRightsDate;
    data['offer price'] = offerPrice;
    data['premium_rs'] = premiumRs;
    data['ratio_n'] = ratioN;
    data['ration_d'] = rationD;
    data['record date'] = recordDate;
    data['source date'] = sourceDate;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EGM date'] = eGMDate;
    data['agenda'] = agenda;
    data['company name'] = companyName;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agenda'] = agenda;
    data['board meeting date'] = boardMeetingDate;
    data['company name'] = companyName;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company name'] = companyName;
    data['cum_bonus_date'] = cumBonusDate;
    data['ex_bonus_date'] = exBonusDate;
    data['ratio_d'] = ratioD;
    data['ratio_n'] = ratioN;
    data['record_date'] = recordDate;
    data['source_date'] = sourceDate;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company name'] = companyName;
    data['details'] = details;
    data['dividend date'] = dividendDate;
    data['dividend percent'] = dividendPercent;
    data['dividendpershare'] = dividendpershare;
    data['ex-date'] = exDate;
    data['record date'] = recordDate;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company name'] = companyName;
    data['ex_date'] = exDate;
    data['fv_change_from'] = fvChangeFrom;
    data['fv_change_to'] = fvChangeTo;
    data['record date'] = recordDate;
    return data;
  }
}
