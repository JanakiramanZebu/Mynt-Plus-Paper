class HoldingsModel {
  String? stat;
  List<ExchTsym>? exchTsym;
  String? upldprc;
  String? sellAmt;
  String? holdqty;
  String? npoadqty;
  String? npoadt1qty;
  String? benqty;
  String? sPrdtAli;
  String? prd;
  String? btstqty;
  String? usedqty;
  String? trdqty;
  String? invested;
  String? totalPnL;
  String? currentValue;
  String? emsg;
  String? brkcolqty;
  int? currentQty;
  int? saleableQty;
  String? dpQty;
  bool? isExitHoldings;

  String? avgPrc;

  HoldingsModel(
      {this.stat,
      this.exchTsym,
      this.upldprc,
      this.sellAmt,
      this.holdqty,
      this.npoadqty,
      this.benqty,
      this.sPrdtAli,
      this.prd,
      this.btstqty,
      this.usedqty,
      this.emsg,
      this.invested,
      this.brkcolqty,
      this.currentQty,
      this.npoadt1qty,
      this.dpQty,
      this.trdqty,
      this.currentValue,
      this.totalPnL,
      this.saleableQty,
      this.isExitHoldings,
      this.avgPrc});

  HoldingsModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['exch_tsym'] != null) {
      exchTsym = <ExchTsym>[];
      json['exch_tsym'].forEach((v) {
        exchTsym!.add(ExchTsym.fromJson(v));
      });
    }
    upldprc = json['upldprc'];
    sellAmt = json['sell_amt'];
    holdqty = json['holdqty'];
    npoadqty = json['npoadqty'];
    benqty = json['benqty'];
    brkcolqty = json['brkcolqty'];
    sPrdtAli = json['s_prdt_ali'];
    prd = json['prd'];
    dpQty = json['dpqty'];
    npoadt1qty = json['npoadt1qty'];
    btstqty = json['btstqty'];
    usedqty = json['usedqty'];
    currentValue = json['currentValue'];
    emsg = json['emsg'].toString();
    trdqty = json['trdqty'];
    avgPrc = json['avgPrc'];
    currentQty = json["currentQty"];
    saleableQty = json['saleableQty'];
    invested = invested == null ? "0.00" : json['invested'];
    totalPnL = totalPnL == null ? "0.00" : json['totalPnL'];
    isExitHoldings = json['isExitHoldings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (exchTsym != null) {
      data['exch_tsym'] = exchTsym!.map((v) => v.toJson()).toList();
    }
    data['upldprc'] = upldprc;
    data['sell_amt'] = sellAmt;
    data['currentValue'] = currentValue;
    data['holdqty'] = holdqty;
    data['npoadqty'] = npoadqty;
    data['npoadt1qty'] = npoadt1qty;
    data['brkcolqty'] = brkcolqty;
    data['benqty'] = benqty;
    data['s_prdt_ali'] = sPrdtAli;
    data['prd'] = prd;
    data['currentQty'] = currentQty;
    data['btstqty'] = btstqty;
    data['usedqty'] = usedqty;
    data['trdqty'] = trdqty;
    data['invested'] = invested;
    data['emsg'] = emsg;
    data['saleableQty'] = saleableQty;
    data['totalPnL'] = totalPnL;
    data['dpqty'] = dpQty;
    data['avgPrc'] = avgPrc;
    data['isExitHoldings'] = isExitHoldings;
    return data;
  }
}

class ExchTsym {
  String? exch;
  String? token;
  String? tsym;
  String? pp;
  String? ti;
  String? ls;
  String? isin;
  String? lp;
  String? low;
  String? high;
  String? open;
  String? close;
  String? profitNloss;
  String? change;
  String? perChange;
  String? pNlChng;
  String? currentAmt;
  bool? isExit;
  String? oneDayChg;
  String? symbol;
  String? expDate;
  String? option;
  ExchTsym(
      {this.exch,
      this.token,
      this.tsym,
      this.pp,
      this.ti,
      this.ls,
      this.isin,
      this.lp,
      this.low,
      this.high,
      this.open,
      this.close,
      this.profitNloss,
      this.change,
      this.perChange,
      this.pNlChng,
      this.currentAmt,
      this.isExit,
      this.oneDayChg,
      this.expDate,
      this.option,
      this.symbol});

  ExchTsym.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    pp = json['pp'];
    ti = json['ti'];
    ls = json['ls'];
    isin = json['isin'];
    lp = lp == null ? "0.00" : json['lp'];
    low = low == null ? "0.00" : json['low'];
    high = high == null ? "0.00" : json['high'];
    open = open == null ? "0.00" : json['open'];
    close = close == null ? "0.00" : json['close'];
    profitNloss = profitNloss == null ? "0.00" : json['profitNloss'];
    change = change == null ? "0.00" : json['change'];
    perChange = perChange == null ? "0.00" : json['perChange'];
    pNlChng = pNlChng == null ? "0.00" : json['pNlChng'];
    currentAmt = currentAmt == null ? "0.00" : json['currentAmt'];
    isExit = json['isExit'];
    oneDayChg = json['oneDayChg'];
    expDate = json['expDate'];
    symbol = json['symbol'];
    option = json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['pp'] = pp;
    data['ti'] = ti;
    data['ls'] = ls;
    data['isin'] = isin;
    data['lp'] = lp;
    data['low'] = low;
    data['high'] = high;
    data['open'] = open;
    data['close'] = close;
    data['profitNloss'] = profitNloss;
    data['change'] = change;
    data['perChange'] = perChange;
    data['pNlChng'] = pNlChng;
    data['isExit'] = isExit;
    data['currentAmt'] = currentAmt;
    data['oneDayChg'] = oneDayChg;
    data['option'] = option;
    data['expDate'] = expDate;
    data['symbol'] = symbol;
    return data;
  }
}
