class IndicesDataModel {
  String? s52WeekHigh;
  String? s52WeekLow;
  String? basicIndustry;
  String? boardStatus;
  String? classofShares;
  String? dateofListing;
  String? derivatives;
  String? exchangeX;
  String? exchangeY;
  String? faceValue;
  String? freeFloatMarketCap;
  String? iSIN;
  String? impactcost;
  String? indexes;
  String? industry;
  String? instrumentX;
  String? instrumentY;
  int? lotSizeX;
  String? issuedCapital;
  double? lotSizeY;
  String? lowerBand;
  String? macroEconomicSector;
  String? priceBand;
  String? sLB;
  String? sector;
  String? sectoralIndex;
  String? sectoralIndexPE;
  String? sessionNo;
  String? status;
  String? surveillanceIndicator;
  String? symbol;
  String? symbolPE;
  double? tickSizeX;
  double? tickSizeY;
  int? tokenX;
  String? tokenY;
  String? totalMarketCap;
  String? tradingSegment;
  String? tradingStatus;
  String? tradingSymbolX;
  String? tradingSymbolY;
  String? unnamed7X;
  String? unnamed7Y;
  String? upperBand;
  String? change;
  String? close;
  String? high;
  String? idxname;
  String? low;
  String? lp;
  String? open;
  String? requestTime;
  String? vol;

  IndicesDataModel(
      {this.s52WeekHigh,
      this.s52WeekLow,
      this.basicIndustry,
      this.boardStatus,
      this.classofShares,
      this.dateofListing,
      this.derivatives,
      this.exchangeX,
      this.exchangeY,
      this.faceValue,
      this.freeFloatMarketCap,
      this.iSIN,
      this.impactcost,
      this.indexes,
      this.industry,
      this.instrumentX,
      this.instrumentY,
      this.issuedCapital,
      this.lotSizeX,
      this.lotSizeY,
      this.lowerBand,
      this.macroEconomicSector,
      this.priceBand,
      this.sLB,
      this.sector,
      this.sectoralIndex,
      this.sectoralIndexPE,
      this.sessionNo,
      this.status,
      this.surveillanceIndicator,
      this.symbol,
      this.symbolPE,
      this.tickSizeX,
      this.tickSizeY,
      this.tokenX,
      this.tokenY,
      this.totalMarketCap,
      this.tradingSegment,
      this.tradingStatus,
      this.tradingSymbolX,
      this.tradingSymbolY,
      this.unnamed7X,
      this.unnamed7Y,
      this.upperBand,
      this.change,
      this.close,
      this.high,
      this.idxname,
      this.low,
      this.lp,
      this.open,
      this.requestTime,
      this.vol});

  IndicesDataModel.fromJson(Map<String, dynamic> json) {
    s52WeekHigh = json['52WeekHigh'];
    s52WeekLow = json['52WeekLow'];
    basicIndustry = json['BasicIndustry'];
    boardStatus = json['BoardStatus'];
    classofShares = json['ClassofShares'];
    dateofListing = json['DateofListing'];
    derivatives = json['Derivatives'];
    exchangeX = json['Exchange_x'];
    exchangeY = json['Exchange_y'];
    faceValue = json['FaceValue'];
    freeFloatMarketCap = json['FreeFloatMarketCap'];
    iSIN = json['ISIN'];
    impactcost = json['Impactcost'];
    indexes = json['Indexes'];
    industry = json['Industry'];
    instrumentX = json['Instrument_x'];
    instrumentY = json['Instrument_y'];
    issuedCapital = json['IssuedCapital'];
    lotSizeX = json['LotSize_x'];
    lotSizeY = json['LotSize_y'];
    lowerBand = json['LowerBand'];
    macroEconomicSector = json['Macro-EconomicSector'];
    priceBand = json['PriceBand'];
    sLB = json['SLB'];
    sector = json['Sector'];
    sectoralIndex = json['SectoralIndex'];
    sectoralIndexPE = json['SectoralIndexP/E'];
    sessionNo = json['SessionNo'];
    status = json['Status'];
    surveillanceIndicator = json['SurveillanceIndicator'];
    symbol = json['Symbol'];
    symbolPE = json['SymbolP/E'];
    tickSizeX = json['TickSize_x'];
    tickSizeY = json['TickSize_y'];
    tokenX = json['Token_x'];
    tokenY = json['Token_y'];
    totalMarketCap = json['TotalMarketCap'];
    tradingSegment = json['TradingSegment'];
    tradingStatus = json['TradingStatus'];
    tradingSymbolX = json['TradingSymbol_x'];
    tradingSymbolY = json['TradingSymbol_y'];
    unnamed7X = unnamed7X == null ? "null" : json['Unnamed: 7_x'];
    unnamed7Y = unnamed7Y == null ? "null" : json['Unnamed: 7_y'];
    upperBand = json['UpperBand'];
    change = json['change'];
    close = json['close'];
    high = json['high'];
    idxname = idxname == null ? "null" : json['idxname'];
    low = json['low'];
    lp = json['lp'];
    open = json['open'];
    requestTime = json['request_time'];
    vol = json['vol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['52WeekHigh'] = s52WeekHigh;
    data['52WeekLow'] = s52WeekLow;
    data['BasicIndustry'] = basicIndustry;
    data['BoardStatus'] = boardStatus;
    data['ClassofShares'] = classofShares;
    data['DateofListing'] = dateofListing;
    data['Derivatives'] = derivatives;
    data['Exchange_x'] = exchangeX;
    data['Exchange_y'] = exchangeY;
    data['FaceValue'] = faceValue;
    data['FreeFloatMarketCap'] = freeFloatMarketCap;
    data['ISIN'] = iSIN;
    data['Impactcost'] = impactcost;
    data['Indexes'] = indexes;
    data['Industry'] = industry;
    data['Instrument_x'] = instrumentX;
    data['Instrument_y'] = instrumentY;
    data['IssuedCapital'] = issuedCapital;
    data['LotSize_x'] = lotSizeX;
    data['LotSize_y'] = lotSizeY;
    data['LowerBand'] = lowerBand;
    data['Macro-EconomicSector'] = macroEconomicSector;
    data['PriceBand'] = priceBand;
    data['SLB'] = sLB;
    data['Sector'] = sector;
    data['SectoralIndex'] = sectoralIndex;
    data['SectoralIndexP/E'] = sectoralIndexPE;
    data['SessionNo'] = sessionNo;
    data['Status'] = status;
    data['SurveillanceIndicator'] = surveillanceIndicator;
    data['Symbol'] = symbol;
    data['SymbolP/E'] = symbolPE;
    data['TickSize_x'] = tickSizeX;
    data['TickSize_y'] = tickSizeY;
    data['Token_x'] = tokenX;
    data['Token_y'] = tokenY;
    data['TotalMarketCap'] = totalMarketCap;
    data['TradingSegment'] = tradingSegment;
    data['TradingStatus'] = tradingStatus;
    data['TradingSymbol_x'] = tradingSymbolX;
    data['TradingSymbol_y'] = tradingSymbolY;
    data['Unnamed: 7_x'] = unnamed7X;
    data['Unnamed: 7_y'] = unnamed7Y;
    data['UpperBand'] = upperBand;
    data['change'] = change;
    data['close'] = close;
    data['high'] = high;
    data['idxname'] = idxname;
    data['low'] = low;
    data['lp'] = lp;
    data['open'] = open;
    data['request_time'] = requestTime;
    data['vol'] = vol;
    return data;
  }
}
