class OrderMarginModel {
  String? requestTime;
  String? stat;
  String? cash;
  String? marginused;
  String? remarks;
  String? marginusedprev;
  String? ordermargin;
  String? emsg;
  String? marginusedtrade;
  OrderMarginModel(
      {this.requestTime,
      this.stat,
      this.cash,
      this.marginused,
      this.remarks,
      this.marginusedprev,
      this.emsg,
      this.ordermargin,this.marginusedtrade});

  OrderMarginModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    cash = json['cash'];
    emsg = json['emsg'];
    marginused = json['marginused'];
    remarks = json['remarks'];
    marginusedprev = json['marginusedprev'];
    marginusedtrade=json['marginusedtrade']
;    ordermargin = json['ordermargin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['cash'] = cash;
    data['emsg'] = emsg;
    data['marginused'] = marginused;
    data['remarks'] = remarks;
    data['marginusedprev'] = marginusedprev;
    data['ordermargin'] = ordermargin;
    data['marginusedtrade']=marginusedtrade;
    return data;
  }

  // Parsed values
  double get _used => double.tryParse(marginused ?? '0') ?? 0;
  double get _usedPrev => double.tryParse(marginusedprev ?? '0') ?? 0;
  double get _usedTrade => double.tryParse(marginusedtrade ?? '0') ?? 0;

  /// Basket margin excluding existing margin = marginused - marginusedprev
  double get basketMargin => _used - _usedPrev;

  /// Basket margin including existing margin = marginused
  double get basketMarginWithExisting => _used;

  /// Post trade margin excluding existing = marginusedtrade - marginusedprev
  double get postTradeMargin => _usedTrade - _usedPrev;

  /// Post trade margin including existing = marginusedtrade
  double get postTradeMarginWithExisting => _usedTrade;

  /// Existing margin used = marginusedprev
  double get existingMarginUsed => _usedPrev;

  /// Margin benefit (hedge savings) = marginused - marginusedtrade
  double get marginBenefit => _used - _usedTrade;
}

class BrokerageInput {
  String exch;
  String tsym;
  String qty;
  String prc;
  String prd;
  String trantype;

  BrokerageInput(
      {required this.exch,
      required this.prc,
      required this.prd,
      required this.qty,
      required this.trantype,
      required this.tsym});
}

class OrderMarginInput {
  String exch;
  String tsym;
  String qty;
  String prc;
  String prd;
  String trantype;
  String prctyp;
  String rorgqty;
  String rorgprc;
  String blprc;
  String bpprc;
  String trgprc;
  OrderMarginInput(
      {required this.exch,
      required this.prc,
      required this.prctyp,
      required this.prd,
      required this.qty,
      required this.rorgprc,
      required this.rorgqty,
      required this.trantype,
      required this.tsym,
      required this.blprc,
      required this.bpprc,
      required this.trgprc});
}
