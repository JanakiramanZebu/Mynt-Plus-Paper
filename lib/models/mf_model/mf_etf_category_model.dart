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
        indices!.add(Indices.fromJson(v));
      });
    }
    if (json['Sector & Theme'] != null) {
      sectorTheme = <SectorTheme>[];
      json['Sector & Theme'].forEach((v) {
        sectorTheme!.add(SectorTheme.fromJson(v));
      });
    }
    if (json['Strategy Based'] != null) {
      strategyBased = <StrategyBased>[];
      json['Strategy Based'].forEach((v) {
        strategyBased!.add(StrategyBased.fromJson(v));
      });
    }
    if (json['Global'] != null) {
      global = <Global>[];
      json['Global'].forEach((v) {
        global!.add(Global.fromJson(v));
      });
    }
    if (json['Debt'] != null) {
      debt = <Debt>[];
      json['Debt'].forEach((v) {
        debt!.add(Debt.fromJson(v));
      });
    }
    if (json['Gold & Silver'] != null) {
      goldSilver = <GoldSilver>[];
      json['Gold & Silver'].forEach((v) {
        goldSilver!.add(GoldSilver.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (indices != null) {
      data['Indices'] = indices!.map((v) => v.toJson()).toList();
    }
    if (sectorTheme != null) {
      data['Sector & Theme'] =
          sectorTheme!.map((v) => v.toJson()).toList();
    }
    if (strategyBased != null) {
      data['Strategy Based'] =
          strategyBased!.map((v) => v.toJson()).toList();
    }
    if (global != null) {
      data['Global'] = global!.map((v) => v.toJson()).toList();
    }
    if (debt != null) {
      data['Debt'] = debt!.map((v) => v.toJson()).toList();
    }
    if (goldSilver != null) {
      data['Gold & Silver'] = goldSilver!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SYMBOL'] = sYMBOL;
    data['UNDERLYING ASSET'] = uNDERLYINGASSET;
    data['exch'] = exch;
    data['company_name'] = companyName;
    data['sector'] = sector;
    data['industry'] = industry;
    data['house'] = house;
    data['market_cap'] = marketCap;
    data['bse_code'] = bseCode;
    data['bse_group'] = bseGroup;
    data['bse_scrip name'] = bseScripName;
    data['trading_status'] = tradingStatus;
    data['nse_symbol'] = nseSymbol;
    data['nse_series'] = nseSeries;
    data['bse_scrip_id'] = bseScripId;
    data['listing_status'] = listingStatus;
    data['isin_no'] = isinNo;
    data['incorporation_year'] = incorporationYear;
    data['zebuToken'] = zebuToken;
    data['NSE_symbol'] = nSESymbol;
    return data;
  }
}