class StockData {
  List<MFholdings>? mFholdings;
  List<Fundamental>? fundamental;
  PeersComparison? peersComparison;
  List<Returns>? returns;
  List<Shareholdings>? shareholdings;
  String? stockDescription;
  StockEvents? stockEvents;
  StockFinancialsConsolidated? stockFinancialsConsolidated;
  StockFinancialsConsolidated? stockFinancialsStandalone;
  String? msg;
  String? emsg;
 

  Map? peerComparisonChart;

  StockData(
      {this.mFholdings,
      this.fundamental,
      this.peersComparison,
      this.returns,
      this.shareholdings,
      this.stockDescription,
      this.stockEvents,
      this.stockFinancialsConsolidated,
      this.stockFinancialsStandalone,
      this.msg,
      this.peerComparisonChart,this.emsg});

  StockData.fromJson(Map<String, dynamic> json) {
    peerComparisonChart = json['peerComparisonChart'] ?? {};
    if (json['MFholdings'] != null) {
      mFholdings = <MFholdings>[];
      json['MFholdings'].forEach((v) {
        mFholdings!.add(MFholdings.fromJson(v));
      });
    }
    if (json['fundamental'] != null) {
      fundamental = <Fundamental>[];
      json['fundamental'].forEach((v) {
        fundamental!.add(Fundamental.fromJson(v));
      });
    }

    peersComparison = json['peersComparison'] != null
        ? PeersComparison.fromJson(json['peersComparison'])
        : null;
    if (json['returns'] != null) {
      returns = <Returns>[];
      json['returns'].forEach((v) {
        returns!.add(Returns.fromJson(v));
      });
    }
    if (json['shareholdings'] != null) {
      shareholdings = <Shareholdings>[];
      json['shareholdings'].forEach((v) {
        shareholdings!.add(Shareholdings.fromJson(v));
      });
    }
    stockDescription = json['stockDescription'];
    stockEvents = json['stockEvents'] != null
        ? StockEvents.fromJson(json['stockEvents'])
        : null;
    stockFinancialsConsolidated = json['stockFinancialsConsolidated'] != null
        ? StockFinancialsConsolidated.fromJson(
            json['stockFinancialsConsolidated'])
        : null;
    stockFinancialsStandalone = json['stockFinancialsStandalone'] != null
        ? StockFinancialsConsolidated.fromJson(
            json['stockFinancialsStandalone'])
        : null;
    msg = json['msg'];
    emsg=json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mFholdings != null) {
      data['MFholdings'] = mFholdings!.map((v) => v.toJson()).toList();
    }
    if (fundamental != null) {
      data['fundamental'] = fundamental!.map((v) => v.toJson()).toList();
    }

    if (peersComparison != null) {
      data['peersComparison'] = peersComparison!.toJson();
    }
    if (returns != null) {
      data['returns'] = returns!.map((v) => v.toJson()).toList();
    }
    if (shareholdings != null) {
      data['shareholdings'] = shareholdings!.map((v) => v.toJson()).toList();
    }
    data['stockDescription'] = stockDescription;
    if (stockEvents != null) {
      data['stockEvents'] = stockEvents!.toJson();
    }
    if (stockFinancialsConsolidated != null) {
      data['stockFinancialsConsolidated'] =
          stockFinancialsConsolidated!.toJson();
    }
    if (stockFinancialsStandalone != null) {
      data['stockFinancialsStandalone'] = stockFinancialsStandalone!.toJson();
    }
    if (peerComparisonChart != null) {
      data['peerComparisonChart'] = peerComparisonChart;
    }
    data['msg'] = msg;
    data[ "emsg"]=emsg;
    return data;
  }
}

class MFholdings {
  String? marketCapHeld;
  String? marketValue;
  String? mfAum;
  String? mfHoldingPercent;
  String? mutualFund;

  MFholdings(
      {this.marketCapHeld,
      this.marketValue,
      this.mfAum,
      this.mfHoldingPercent,
      this.mutualFund});

  MFholdings.fromJson(Map<String, dynamic> json) {
    marketCapHeld = json['market_cap_Held'].toString();
    marketValue = json['market_value'].toString();
    mfAum = json['mf_aum'].toString();
    mfHoldingPercent = json['mf_holding_percent'].toString();
    mutualFund = json['mutual_fund'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['market_cap_Held'] = marketCapHeld;
    data['market_value'] = marketValue;
    data['mf_aum'] = mfAum;
    data['mf_holding_percent'] = mfHoldingPercent;
    data['mutual_fund'] = mutualFund;
    return data;
  }
}

class Fundamental {
  String? bookValue;
  String? companyName;
  String? debtToEquity;
  String? dividendYieldPercent;
  String? eps;
  String? evEbitda;
  String? fixedCapitalToSales;
  String? fv;
  String? industry;
  String? marketCap;
  String? marketCapType;
  String? pe;
  String? priceBookValue;
  String? roaPercent;
  String? rocePercent;
  String? roePercent;
  String? salesToWorkingCapital;
  String? sector;
  String? sectorPe;

  Fundamental(
      {this.bookValue,
      this.companyName,
      this.debtToEquity,
      this.dividendYieldPercent,
      this.eps,
      this.evEbitda,
      this.fixedCapitalToSales,
      this.fv,
      this.industry,
      this.marketCap,
      this.marketCapType,
      this.pe,
      this.priceBookValue,
      this.roaPercent,
      this.rocePercent,
      this.roePercent,
      this.salesToWorkingCapital,
      this.sector,
      this.sectorPe});

  Fundamental.fromJson(Map<String, dynamic> json) {
    bookValue = json['book_value'].toString();
    companyName = json['company_name'].toString();
    debtToEquity = json['debt_to_equity'].toString();
    dividendYieldPercent = json['dividend_yield_percent'].toString();
    eps = json['eps'].toString();
    evEbitda = json['ev_ebitda'].toString();
    fixedCapitalToSales = json['fixed_capital_to_sales'].toString();
    fv = json['fv'].toString();
    industry = json['industry'].toString();
    marketCap = json['market_cap'].toString();
    marketCapType = json['market_cap_type'].toString();
    pe = json['pe'].toString();
    priceBookValue = json['price_book_value'].toString();
    roaPercent = json['roa_percent'].toString();
    rocePercent = json['roce_percent'].toString();
    roePercent = json['roe_percent'].toString();
    salesToWorkingCapital = json['sales_to_working_capital'].toString();
    sector = json['sector'].toString();
    sectorPe = json['sector_pe'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['book_value'] = bookValue;
    data['company_name'] = companyName;
    data['debt_to_equity'] = debtToEquity;
    data['dividend_yield_percent'] = dividendYieldPercent;
    data['eps'] = eps;
    data['ev_ebitda'] = evEbitda;
    data['fixed_capital_to_sales'] = fixedCapitalToSales;
    data['fv'] = fv;
    data['industry'] = industry;
    data['market_cap'] = marketCap;
    data['market_cap_type'] = marketCapType;
    data['pe'] = pe;
    data['price_book_value'] = priceBookValue;
    data['roa_percent'] = roaPercent;
    data['roce_percent'] = rocePercent;
    data['roe_percent'] = roePercent;
    data['sales_to_working_capital'] = salesToWorkingCapital;
    data['sector'] = sector;
    data['sector_pe'] = sectorPe;
    return data;
  }
}

class PeersComparison {
  List<Stock>? peers;
  List<Stock>? stock;

  PeersComparison({this.peers, this.stock});

  PeersComparison.fromJson(Map<String, dynamic> json) {
    if (json['peers'] != null) {
      peers = <Stock>[];
      json['peers'].forEach((v) {
        peers!.add(Stock.fromJson(v));
      });
    }
    if (json['stock'] != null) {
      stock = <Stock>[];
      json['stock'].forEach((v) {
        stock!.add(Stock.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (peers != null) {
      data['peers'] = peers!.map((v) => v.toJson()).toList();
    }
    if (stock != null) {
      data['stock'] = stock!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stock {
  String? zebuToken;
  String? companyName;
  String? industry;
  String? roePercent;
  String? rocePercent;
  String? roaPercent;
  String? debtToEquity;
  String? evEbitda;
  String? bookValue;
  String? salesToWorkingCapital;
  String? fixedCapitalToSales;
  String? marketCap;
  String? priceBookValue;
  String? dividendYieldPercent;
  String? fv;
  String? pe;
  String? sectorPe;
  String? sYMBOL;
  String? ltp;

  Stock(
      {this.zebuToken,
      this.companyName,
      this.industry,
      this.roePercent,
      this.rocePercent,
      this.roaPercent,
      this.debtToEquity,
      this.evEbitda,
      this.bookValue,
      this.salesToWorkingCapital,
      this.fixedCapitalToSales,
      this.marketCap,
      this.priceBookValue,
      this.dividendYieldPercent,
      this.fv,
      this.pe,
      this.sectorPe,
      this.sYMBOL,
      this.ltp});

  Stock.fromJson(Map<String, dynamic> json) {
    zebuToken = json['zebuToken'].toString();
    companyName = json['company_name'].toString();
    industry = json['industry'].toString();
    roePercent = json['roe_percent'].toString();
    rocePercent = json['roce_percent'].toString();
    roaPercent = json['roa_percent'].toString();
    debtToEquity = json['debt_to_equity'].toString();
    evEbitda = json['ev_ebitda'].toString();
    bookValue = json['book_value'].toString();
    salesToWorkingCapital = json['sales_to_working_capital'].toString();
    fixedCapitalToSales = json['fixed_capital_to_sales'].toString();
    marketCap = json['market_cap'].toString();
    priceBookValue = json['price_book_value'].toString();
    dividendYieldPercent = json['dividend_yield_percent'].toString();
    fv = json['fv'].toString();
    pe = json['pe'].toString();
    sectorPe = json['sector_pe'].toString();
    sYMBOL = json['SYMBOL'].toString();
    ltp = json['ltp'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['zebuToken'] = zebuToken;
    data['company_name'] = companyName;
    data['industry'] = industry;
    data['roe_percent'] = roePercent;
    data['roce_percent'] = rocePercent;
    data['roa_percent'] = roaPercent;
    data['debt_to_equity'] = debtToEquity;
    data['ev_ebitda'] = evEbitda;
    data['book_value'] = bookValue;
    data['sales_to_working_capital'] = salesToWorkingCapital;
    data['fixed_capital_to_sales'] = fixedCapitalToSales;
    data['market_cap'] = marketCap;
    data['price_book_value'] = priceBookValue;
    data['dividend_yield_percent'] = dividendYieldPercent;
    data['fv'] = fv;
    data['pe'] = pe;
    data['sector_pe'] = sectorPe;
    data['SYMBOL'] = sYMBOL;
    data['ltp'] = ltp;
    return data;
  }
}

class Returns {
  String? returns;
  String? type;

  Returns({this.returns, this.type});

  Returns.fromJson(Map<String, dynamic> json) {
    returns = json['returns'].toString();
    type = json['type'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['returns'] = returns;
    data['type'] = type;
    return data;
  }
}

class Shareholdings {
  String? date;
  String? dii;
  String? fiiFpi;
  String? mutualFunds;
  String? promoters;
  String? retailAndOthers;
  String? convDate;

  Shareholdings(
      {this.date,
      this.dii,
      this.fiiFpi,
      this.mutualFunds,
      this.promoters,
      this.retailAndOthers,
      this.convDate});

  Shareholdings.fromJson(Map<String, dynamic> json) {
    date = json['date'].toString();
    dii = json['dii'].toString();
    fiiFpi = json['fii_fpi'].toString();
    mutualFunds = json['mutual funds'].toString();
    promoters = json['promoters'].toString();
    retailAndOthers = json['retail_and_others'].toString();
    convDate = json['convDate'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['dii'] = dii;
    data['fii_fpi'] = fiiFpi;
    data['mutual funds'] = mutualFunds;
    data['promoters'] = promoters;
    data['retail_and_others'] = retailAndOthers;
    data['convDate'] = convDate;
    return data;
  }
}

class StockEvents {
  List<Announcement>? announcement;
  List<Bonus>? bonus;
  List<Dividend>? dividend;
  List<Rights>? rights;
  List<Split>? split;

  StockEvents(
      {this.announcement, this.bonus, this.dividend, this.rights, this.split});

  StockEvents.fromJson(Map<String, dynamic> json) {
    if (json['announcement'] != null) {
      announcement = <Announcement>[];
      json['announcement'].forEach((v) {
        announcement!.add(Announcement.fromJson(v));
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
    if (json['rights'] != null) {
      rights = <Rights>[];
      json['rights'].forEach((v) {
        rights!.add(Rights.fromJson(v));
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
    if (announcement != null) {
      data['announcement'] = announcement!.map((v) => v.toJson()).toList();
    }
    if (bonus != null) {
      data['bonus'] = bonus!.map((v) => v.toJson()).toList();
    }
    if (dividend != null) {
      data['dividend'] = dividend!.map((v) => v.toJson()).toList();
    }
    if (rights != null) {
      data['rights'] = rights!.map((v) => v.toJson()).toList();
    }
    if (split != null) {
      data['split'] = split!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Announcement {
  String? agenda;
  String? boardMeetingDate;
  String? sourceDate;

  Announcement({this.agenda, this.boardMeetingDate, this.sourceDate});

  Announcement.fromJson(Map<String, dynamic> json) {
    agenda = json['agenda'].toString();
    boardMeetingDate = json['board meeting date'].toString();
    sourceDate = json['source date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agenda'] = agenda;
    data['board meeting date'] = boardMeetingDate;
    data['source date'] = sourceDate;
    return data;
  }
}

class Bonus {
  String? cumBonusDate;
  String? exBonusDate;
  String? ratioD;
  String? ratioN;
  String? recordDate;
  String? sourceDate;

  Bonus(
      {this.cumBonusDate,
      this.exBonusDate,
      this.ratioD,
      this.ratioN,
      this.recordDate,
      this.sourceDate});

  Bonus.fromJson(Map<String, dynamic> json) {
    cumBonusDate = json['cum_bonus_date'].toString();
    exBonusDate = json['ex_bonus_date'].toString();
    ratioD = json['ratio_d'].toString();
    ratioN = json['ratio_n'].toString();
    recordDate = json['record_date'].toString();
    sourceDate = json['source_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  String? details;
  String? dividendDate;
  String? dividendPercent;
  String? dividendpershare;
  String? exDate;
  String? recordDate;

  Dividend(
      {this.details,
      this.dividendDate,
      this.dividendPercent,
      this.dividendpershare,
      this.exDate,
      this.recordDate});

  Dividend.fromJson(Map<String, dynamic> json) {
    details = json['details'].toString();
    dividendDate = json['dividend date'].toString();
    dividendPercent = json['dividend percent'].toString();
    dividendpershare = json['dividendpershare'].toString();
    exDate = json['ex-date'].toString();
    recordDate = json['record date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['details'] = details;
    data['dividend date'] = dividendDate;
    data['dividend percent'] = dividendPercent;
    data['dividendpershare'] = dividendpershare;
    data['ex-date'] = exDate;
    data['record date'] = recordDate;
    return data;
  }
}

class Rights {
  String? exRightsDate;
  String? offerPrice;
  String? premiumRs;
  String? ratioN;
  String? rationD;
  String? recordDate;
  String? sourceDate;

  Rights(
      {this.exRightsDate,
      this.offerPrice,
      this.premiumRs,
      this.ratioN,
      this.rationD,
      this.recordDate,
      this.sourceDate});

  Rights.fromJson(Map<String, dynamic> json) {
    exRightsDate = json['ex_rights_date'].toString();
    offerPrice = json['offer price'].toString();
    premiumRs = json['premium_rs'].toString();
    ratioN = json['ratio_n'].toString();
    rationD = json['ration_d'].toString();
    recordDate = json['record date'].toString();
    sourceDate = json['source date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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

class StockFinancialsConsolidated {
  List<BalanceSheet>? balanceSheet;
  List<CashflowSheet>? cashflowSheet;
  List<IncomeSheet>? incomeSheet;

  StockFinancialsConsolidated(
      {this.balanceSheet, this.cashflowSheet, this.incomeSheet});

  StockFinancialsConsolidated.fromJson(Map<String, dynamic> json) {
    if (json['balanceSheet'] != null) {
      balanceSheet = <BalanceSheet>[];
      json['balanceSheet'].forEach((v) {
        balanceSheet!.add(BalanceSheet.fromJson(v));
      });
    }
    if (json['cashflowSheet'] != null) {
      cashflowSheet = <CashflowSheet>[];
      json['cashflowSheet'].forEach((v) {
        cashflowSheet!.add(CashflowSheet.fromJson(v));
      });
    }
    if (json['incomeSheet'] != null) {
      incomeSheet = <IncomeSheet>[];
      json['incomeSheet'].forEach((v) {
        incomeSheet!.add(IncomeSheet.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (balanceSheet != null) {
      data['balanceSheet'] = balanceSheet!.map((v) => v.toJson()).toList();
    }
    if (cashflowSheet != null) {
      data['cashflowSheet'] = cashflowSheet!.map((v) => v.toJson()).toList();
    }
    if (incomeSheet != null) {
      data['incomeSheet'] = incomeSheet!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BalanceSheet {
  String? borrowings;
  String? cashAndBank;
  String? currentsInvestments;
  String? deferredTaxAssetsAndLiabilities;
  String? deposits;
  String? grossBlock;
  String? inventories;
  String? longTermLoansAndAdvances;
  String? longTermTradePayables;
  String? nonCurrentAssets;
  String? nonCurrentInvestments;
  String? otherCurrentAssets;
  String? otherCurrentLiabilities;
  String? otherLiabilitiesAndProvisions;
  String? otherLongTermLiabilities;
  String? otherNonCurrentAssets;
  String? securedLoans;
  String? shortTermBorrowings;
  String? shortTermLoansAndAdvances;
  String? shortTermProvisions;
  String? sundryDebtors;
  String? totalAssets;
  String? totalCurrentAssets;
  String? totalCurrentLiabilities;
  String? totalLiabilities;
  String? totalNonCurrentAssets;
  String? totalNonCurrentLiabilities;
  String? tradePayables;
  String? unsecuredLoans;
  String? yearEndDate;
  String? convDate;
  BalanceSheet(
      {this.borrowings,
      this.cashAndBank,
      this.currentsInvestments,
      this.deferredTaxAssetsAndLiabilities,
      this.deposits,
      this.grossBlock,
      this.inventories,
      this.longTermLoansAndAdvances,
      this.longTermTradePayables,
      this.nonCurrentAssets,
      this.nonCurrentInvestments,
      this.otherCurrentAssets,
      this.otherCurrentLiabilities,
      this.otherLiabilitiesAndProvisions,
      this.otherLongTermLiabilities,
      this.otherNonCurrentAssets,
      this.securedLoans,
      this.shortTermBorrowings,
      this.shortTermLoansAndAdvances,
      this.shortTermProvisions,
      this.sundryDebtors,
      this.totalAssets,
      this.totalCurrentAssets,
      this.totalCurrentLiabilities,
      this.totalLiabilities,
      this.totalNonCurrentAssets,
      this.totalNonCurrentLiabilities,
      this.tradePayables,
      this.unsecuredLoans,
      this.yearEndDate,
      this.convDate});

  BalanceSheet.fromJson(Map<String, dynamic> json) {
    borrowings = json['borrowings'].toString();
    cashAndBank = json['cash_and_bank'].toString();
    currentsInvestments = json['currents_investments'].toString();
    deferredTaxAssetsAndLiabilities =
        json['deferred_tax_assets__and__liabilities'].toString();
    deposits = json['deposits'].toString();
    grossBlock = json['gross_block'].toString();
    inventories = json['inventories'].toString();
    longTermLoansAndAdvances =
        json['long_term_loans__and__advances'].toString();
    longTermTradePayables = json['long_term_trade_payables'].toString();
    nonCurrentAssets = json['non_current_assets'].toString();
    nonCurrentInvestments = json['non_current_investments'].toString();
    otherCurrentAssets = json['other_current_assets'].toString();
    otherCurrentLiabilities = json['other_current_liabilities'].toString();
    otherLiabilitiesAndProvisions =
        json['other_liabilities_and_provisions'].toString();
    otherLongTermLiabilities = json['other_long_term_liabilities'].toString();
    otherNonCurrentAssets = json['other_non_current_assets'].toString();
    securedLoans = json['secured_loans'].toString();
    shortTermBorrowings = json['short_term_borrowings'].toString();
    shortTermLoansAndAdvances =
        json['short_term_loans_and_advances'].toString();
    shortTermProvisions = json['short_term_provisions'].toString();
    sundryDebtors = json['sundry_debtors'].toString();
    totalAssets = json['total_assets'].toString();
    totalCurrentAssets = json['total_current_assets'].toString();
    totalCurrentLiabilities = json['total_current_liabilities'].toString();
    totalLiabilities = json['total_liabilities'].toString();
    totalNonCurrentAssets = json['total_non_current_assets'].toString();
    totalNonCurrentLiabilities =
        json['total_non_current_liabilities'].toString();
    tradePayables = json['trade_payables'].toString();
    unsecuredLoans = json['unsecured_loans'].toString();
    yearEndDate = json['year_end_date'].toString();
    convDate = json['convDate'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['borrowings'] = borrowings;
    data['cash_and_bank'] = cashAndBank;
    data['currents_investments'] = currentsInvestments;
    data['deferred_tax_assets__and__liabilities'] =
        deferredTaxAssetsAndLiabilities;
    data['deposits'] = deposits;
    data['gross_block'] = grossBlock;
    data['inventories'] = inventories;
    data['long_term_loans__and__advances'] = longTermLoansAndAdvances;
    data['long_term_trade_payables'] = longTermTradePayables;
    data['non_current_assets'] = nonCurrentAssets;
    data['non_current_investments'] = nonCurrentInvestments;
    data['other_current_assets'] = otherCurrentAssets;
    data['other_current_liabilities'] = otherCurrentLiabilities;
    data['other_liabilities_and_provisions'] = otherLiabilitiesAndProvisions;
    data['other_long_term_liabilities'] = otherLongTermLiabilities;
    data['other_non_current_assets'] = otherNonCurrentAssets;
    data['secured_loans'] = securedLoans;
    data['short_term_borrowings'] = shortTermBorrowings;
    data['short_term_loans_and_advances'] = shortTermLoansAndAdvances;
    data['short_term_provisions'] = shortTermProvisions;
    data['sundry_debtors'] = sundryDebtors;
    data['total_assets'] = totalAssets;
    data['total_current_assets'] = totalCurrentAssets;
    data['total_current_liabilities'] = totalCurrentLiabilities;
    data['total_liabilities'] = totalLiabilities;
    data['total_non_current_assets'] = totalNonCurrentAssets;
    data['total_non_current_liabilities'] = totalNonCurrentLiabilities;
    data['trade_payables'] = tradePayables;
    data['unsecured_loans'] = unsecuredLoans;
    data['year_end_date'] = yearEndDate;
    data['convDate'] = convDate;
    return data;
  }
}

class CashflowSheet {
  String? cashFlowFromInvestingActivities;
  String? cashFromFinancingActivities;
  String? cashFromOperatingActivities;
  String? yearEndDate;
  String? convDate;

  CashflowSheet(
      {this.cashFlowFromInvestingActivities,
      this.cashFromFinancingActivities,
      this.cashFromOperatingActivities,
      this.yearEndDate,
      this.convDate});

  CashflowSheet.fromJson(Map<String, dynamic> json) {
    cashFlowFromInvestingActivities =
        json['cash_flow_from_investing_activities'].toString();
    cashFromFinancingActivities =
        json['cash_from_financing_activities'].toString();
    cashFromOperatingActivities =
        json['cash_from_operating_activities'].toString();
    yearEndDate = json['year_end_date'].toString();
    convDate = json['convDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash_flow_from_investing_activities'] =
        cashFlowFromInvestingActivities;
    data['cash_from_financing_activities'] = cashFromFinancingActivities;
    data['cash_from_operating_activities'] = cashFromOperatingActivities;
    data['year_end_date'] = yearEndDate;
    data['convDate'] = convDate;
    return data;
  }
}

class IncomeSheet {
  String? earningsPerShare;
  String? equityDividendPercent;
  String? expenditure;
  String? operatingProfit;
  String? otherIncome;
  String? profitAfterTax;
  String? profitBeforeTax;
  String? revenue;
  String? tax;
  String? convDate;
  String? yearEndDate;

  IncomeSheet(
      {this.earningsPerShare,
      this.equityDividendPercent,
      this.expenditure,
      this.operatingProfit,
      this.otherIncome,
      this.profitAfterTax,
      this.profitBeforeTax,
      this.revenue,
      this.tax,
      this.yearEndDate,
      this.convDate});

  IncomeSheet.fromJson(Map<String, dynamic> json) {
    earningsPerShare = json['earnings_per_share'].toString();
    equityDividendPercent = json['equity_dividend_percent'].toString();
    expenditure = json['expenditure'].toString();
    operatingProfit = json['operating_profit'].toString();
    otherIncome = json['other_income'].toString();
    profitAfterTax = json['profit_after_tax'].toString();
    profitBeforeTax = json['profit_before_tax'].toString();
    revenue = json['revenue'].toString();
    tax = json['tax'].toString();
    yearEndDate = json['year_end_date'].toString();
    convDate = json['convDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earnings_per_share'] = earningsPerShare;
    data['equity_dividend_percent'] = equityDividendPercent;
    data['expenditure'] = expenditure;
    data['operating_profit'] = operatingProfit;
    data['other_income'] = otherIncome;
    data['profit_after_tax'] = profitAfterTax;
    data['profit_before_tax'] = profitBeforeTax;
    data['revenue'] = revenue;
    data['tax'] = tax;
    data['year_end_date'] = yearEndDate;
    data['convDate'] = convDate;
    return data;
  }
}

class Split {
  String? exDate;
  String? fvChangeFrom;
  String? fvChangeTo;
  String? recordDate;

  Split({this.exDate, this.fvChangeFrom, this.fvChangeTo, this.recordDate});

  Split.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'];
    fvChangeFrom = json['fv_change_from'];
    fvChangeTo = json['fv_change_to'];
    recordDate = json['record date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ex_date'] = exDate;
    data['fv_change_from'] = fvChangeFrom;
    data['fv_change_to'] = fvChangeTo;
    data['record date'] = recordDate;
    return data;
  }
}

class PrcComparisionChartData {
  PrcComparisionChartData(this.yValue, this.xValue);

  double xValue;
  String yValue;
}
