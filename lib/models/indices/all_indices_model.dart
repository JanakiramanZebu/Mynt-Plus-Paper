class AllIndicesModel {
  List<BSE>? bSE;
  List<MCX>? mCX;
  List<NSE>? nSE;

  AllIndicesModel({this.bSE, this.mCX, this.nSE});

  AllIndicesModel.fromJson(Map<String, dynamic> json) {
    if (json['BSE'] != null) {
      bSE = <BSE>[];
      json['BSE'].forEach((v) {
        bSE!.add(BSE.fromJson(v));
      });
    }
    if (json['MCX'] != null) {
      mCX = <MCX>[];
      json['MCX'].forEach((v) {
        mCX!.add(MCX.fromJson(v));
      });
    }
    if (json['NSE'] != null) {
      nSE = <NSE>[];
      json['NSE'].forEach((v) {
        nSE!.add(NSE.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bSE != null) {
      data['BSE'] = bSE!.map((v) => v.toJson()).toList();
    }
    if (mCX != null) {
      data['MCX'] = mCX!.map((v) => v.toJson()).toList();
    }
    if (nSE != null) {
      data['NSE'] = nSE!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BSE {
  String? exchange;
  String? change;
  String? close;
  String? highX;
  String? idxname;
  String? lowX;
  String? lp;
  String? openX;
  String? token;
  String? vol;

  BSE(
      {this.exchange,
      this.change,
      this.close,
      this.highX,
      this.idxname,
      this.lowX,
      this.lp,
      this.openX,
      this.token,
      this.vol});

  BSE.fromJson(Map<String, dynamic> json) {
    exchange = json['Exchange'];
    change = json['change'];
    close = json['close'];
    highX = json['high_x'];
    idxname = json['idxname'];
    lowX = json['low_x'];
    lp = json['lp'];
    openX = json['open_x'];
    token = json['token'];
    vol = json['vol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Exchange'] = exchange;
    data['change'] = change;
    data['close'] = close;
    data['high_x'] = highX;
    data['idxname'] = idxname;
    data['low_x'] = lowX;
    data['lp'] = lp;
    data['open_x'] = openX;
    data['token'] = token;
    data['vol'] = vol;
    return data;
  }
}

class NSE {
  String? exchange;
  String? change;
  String? close;
  String? highX;
  String? idxname;
  String? lowX;
  String? lp;
  String? openX;
  String? pb;
  String? pe;
  String? token;
  String? vol;

  NSE(
      {this.exchange,
      this.change,
      this.close,
      this.highX,
      this.idxname,
      this.lowX,
      this.lp,
      this.openX,
      this.pb,
      this.pe,
      this.token,
      this.vol});

  NSE.fromJson(Map<String, dynamic> json) {
    exchange = json['Exchange'];
    change = json['change'];
    close = json['close'];
    highX = json['high_x'];
    idxname = json['idxname'];
    lowX = json['low_x'];
    lp = json['lp'];
    openX = json['open_x'];
    pb = json['pb'];
    pe = json['pe'];
    token = json['token'];
    vol = json['vol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Exchange'] = exchange;
    data['change'] = change;
    data['close'] = close;
    data['high_x'] = highX;
    data['idxname'] = idxname;
    data['low_x'] = lowX;
    data['lp'] = lp;
    data['open_x'] = openX;
    data['pb'] = pb;
    data['pe'] = pe;
    data['token'] = token;
    data['vol'] = vol;
    return data;
  }
}

class MCX {
  String? exchange;
  String? change;
  String? close;
  String? highX;
  String? idxname;
  String? lowX;
  String? lp;
  String? openX;
  String? token;
  String? vol;

  MCX(
      {this.exchange,
      this.change,
      this.close,
      this.highX,
      this.idxname,
      this.lowX,
      this.lp,
      this.openX,
      this.token,
      this.vol});

  MCX.fromJson(Map<String, dynamic> json) {
    exchange = json['Exchange'];
    change = json['change'];
    close = json['close'];
    highX = json['high_x'];
    idxname = json['idxname'];
    lowX = json['low_x'];
    lp = json['lp'];
    openX = json['open_x'];
    token = json['token'];
    vol = json['vol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Exchange'] = exchange;
    data['change'] = change;
    data['close'] = close;
    data['high_x'] = highX;
    data['idxname'] = idxname;
    data['low_x'] = lowX;
    data['lp'] = lp;
    data['open_x'] = openX;
    data['token'] = token;
    data['vol'] = vol;
    return data;
  }
}
