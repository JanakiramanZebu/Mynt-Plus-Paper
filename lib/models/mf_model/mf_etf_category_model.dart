class MfEtfCategoryModel {
  List<Indices>? indices;
  List<SectorTheme>? sectorTheme;
  List<StrategyBased>? strategyBased;
  List<Global>? global;
  List<Debt>? debt;
  List<GoldSilver>? goldSilver;

  MfEtfCategoryModel(
      {this.indices,
      this.sectorTheme,
      this.strategyBased,
      this.global,
      this.debt,
      this.goldSilver});

  MfEtfCategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['Indices'] != null) {
      indices = <Indices>[];
      json['Indices'].forEach((v) {
        indices!.add(new Indices.fromJson(v));
      });
    }
    if (json['Sector & Theme'] != null) {
      sectorTheme = <SectorTheme>[];
      json['Sector & Theme'].forEach((v) {
        sectorTheme!.add(new SectorTheme.fromJson(v));
      });
    }
    if (json['Strategy Based'] != null) {
      strategyBased = <StrategyBased>[];
      json['Strategy Based'].forEach((v) {
        strategyBased!.add(new StrategyBased.fromJson(v));
      });
    }
    if (json['Global'] != null) {
      global = <Global>[];
      json['Global'].forEach((v) {
        global!.add(new Global.fromJson(v));
      });
    }
    if (json['Debt'] != null) {
      debt = <Debt>[];
      json['Debt'].forEach((v) {
        debt!.add(new Debt.fromJson(v));
      });
    }
    if (json['Gold & Silver'] != null) {
      goldSilver = <GoldSilver>[];
      json['Gold & Silver'].forEach((v) {
        goldSilver!.add(new GoldSilver.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.indices != null) {
      data['Indices'] = this.indices!.map((v) => v.toJson()).toList();
    }
    if (this.sectorTheme != null) {
      data['Sector & Theme'] =
          this.sectorTheme!.map((v) => v.toJson()).toList();
    }
    if (this.strategyBased != null) {
      data['Strategy Based'] =
          this.strategyBased!.map((v) => v.toJson()).toList();
    }
    if (this.global != null) {
      data['Global'] = this.global!.map((v) => v.toJson()).toList();
    }
    if (this.debt != null) {
      data['Debt'] = this.debt!.map((v) => v.toJson()).toList();
    }
    if (this.goldSilver != null) {
      data['Gold & Silver'] = this.goldSilver!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Indices {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  Indices(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  Indices.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}

class SectorTheme {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  SectorTheme(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  SectorTheme.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}

class StrategyBased {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  StrategyBased(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  StrategyBased.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}

class Global {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  Global(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  Global.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}

class Debt {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  Debt(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  Debt.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}

class GoldSilver {
  String? sYMBOL;
  String? uNDERLYINGASSET;
  String? exch;
  String? companyName;
  String? sector;
  String? industry;
  String? house;
  double? marketCap;
  double? bseCode;
  String? bseGroup;
  String? bseScripName;
  String? tradingStatus;
  String? nseSymbol;
  String? nseSeries;
  String? bseScripId;
  String? listingStatus;
  String? isinNo;
  dynamic incorporationYear;
  String? zebuToken;
  String? nSESymbol;

  GoldSilver(
      {this.sYMBOL,
      this.uNDERLYINGASSET,
      this.exch,
      this.companyName,
      this.sector,
      this.industry,
      this.house,
      this.marketCap,
      this.bseCode,
      this.bseGroup,
      this.bseScripName,
      this.tradingStatus,
      this.nseSymbol,
      this.nseSeries,
      this.bseScripId,
      this.listingStatus,
      this.isinNo,
      this.incorporationYear,
      this.zebuToken,
      this.nSESymbol});

  GoldSilver.fromJson(Map<String, dynamic> json) {
    sYMBOL = json['SYMBOL'];
    uNDERLYINGASSET = json['UNDERLYING ASSET'];
    exch = json['exch'];
    companyName = json['company_name'];
    sector = json['sector'];
    industry = json['industry'];
    house = json['house'];
    marketCap = json['market_cap'];
    bseCode = json['bse_code'];
    bseGroup = json['bse_group'];
    bseScripName = json['bse_scrip name'];
    tradingStatus = json['trading_status'];
    nseSymbol = json['nse_symbol'];
    nseSeries = json['nse_series'];
    bseScripId = json['bse_scrip_id'];
    listingStatus = json['listing_status'];
    isinNo = json['isin_no'];
    incorporationYear = json['incorporation_year'];
    zebuToken = json['zebuToken'];
    nSESymbol = json['NSE_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYMBOL'] = this.sYMBOL;
    data['UNDERLYING ASSET'] = this.uNDERLYINGASSET;
    data['exch'] = this.exch;
    data['company_name'] = this.companyName;
    data['sector'] = this.sector;
    data['industry'] = this.industry;
    data['house'] = this.house;
    data['market_cap'] = this.marketCap;
    data['bse_code'] = this.bseCode;
    data['bse_group'] = this.bseGroup;
    data['bse_scrip name'] = this.bseScripName;
    data['trading_status'] = this.tradingStatus;
    data['nse_symbol'] = this.nseSymbol;
    data['nse_series'] = this.nseSeries;
    data['bse_scrip_id'] = this.bseScripId;
    data['listing_status'] = this.listingStatus;
    data['isin_no'] = this.isinNo;
    data['incorporation_year'] = this.incorporationYear;
    data['zebuToken'] = this.zebuToken;
    data['NSE_symbol'] = this.nSESymbol;
    return data;
  }
}