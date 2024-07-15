class FundamentalData {
  List<Fundamental>? fundamental;
  List<Shareholdings>? shareholdings;
  StockEvents? stockEvents;
  StockFinancialsConsolidated? stockFinancialsConsolidated;
  StockFinancialsStandalone? stockFinancialsStandalone;  String? msg;

  FundamentalData(
      {this.fundamental,
      this.shareholdings,
      this.stockEvents,
      this.stockFinancialsConsolidated,
      this.stockFinancialsStandalone,this.msg});

  FundamentalData.fromJson(Map<String, dynamic> json) {
    if (json['fundamental'] != null) {
      fundamental = <Fundamental>[];
      json['fundamental'].forEach((v) {
        fundamental!.add(Fundamental.fromJson(v));
      });
    }
    if (json['shareholdings'] != null) {
      shareholdings = <Shareholdings>[];
      json['shareholdings'].forEach((v) {
        shareholdings!.add(Shareholdings.fromJson(v));
      });
    }
    stockEvents = json['stockEvents'] != null
        ? StockEvents.fromJson(json['stockEvents'])
        : null;
    stockFinancialsConsolidated = json['stockFinancialsConsolidated'] != null
        ? StockFinancialsConsolidated.fromJson(
            json['stockFinancialsConsolidated'])
        : null;
    stockFinancialsStandalone = json['stockFinancialsStandalone'] != null
        ? StockFinancialsStandalone.fromJson(
            json['stockFinancialsStandalone'])
        : null;
         msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fundamental != null) {
      data['fundamental'] = fundamental!.map((v) => v.toJson()).toList();
    }
    if (shareholdings != null) {
      data['shareholdings'] = shareholdings!.map((v) => v.toJson()).toList();
    }
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
        data['msg'] =  msg;
    return data;
  }
}

class Fundamental {
  String? bookValue;
  String? code;
  String? companyName;
  String? debtToEquity;
  String? dividendYieldPercent;
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
      this.code,
      this.companyName,
      this.debtToEquity,
      this.dividendYieldPercent,
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
    code = json['code'].toString();
    companyName = json['company name'].toString();
    debtToEquity = json['debt_to_equity'].toString();
    dividendYieldPercent = json['dividend_yield_percent'].toString();
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
    data['code'] = code;
    data['company name'] = companyName;
    data['debt_to_equity'] = debtToEquity;
    data['dividend_yield_percent'] = dividendYieldPercent;
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

class Shareholdings {
  String? code;
  String? companyName;
  String? date;
  String? dii;
  String? fiiFpi;
  String? mutualFunds;
  String? promoters;
  String? retailAndOthers;

  Shareholdings(
      {this.code,
      this.companyName,
      this.date,
      this.dii,
      this.fiiFpi,
      this.mutualFunds,
      this.promoters,
      this.retailAndOthers});

  Shareholdings.fromJson(Map<String, dynamic> json) {
    code = json['code'].toString();
    companyName = json['company name'].toString();
    date = json['date'].toString();
    dii = json['dii'].toString();
    fiiFpi = json['fii_fpi'].toString();
    mutualFunds = json['mutual funds'].toString();
    promoters = json['promoters'].toString();
    retailAndOthers = json['retail_and_others'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['company name'] = companyName;
    data['date'] = date;
    data['dii'] = dii;
    data['fii_fpi'] = fiiFpi;
    data['mutual funds'] = mutualFunds;
    data['promoters'] = promoters;
    data['retail_and_others'] = retailAndOthers;
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

class Split {
  String? exDate;
  String? fvChangeFrom;
  String? fvChangeTo;
  String? recordDate;

  Split({this.exDate, this.fvChangeFrom, this.fvChangeTo, this.recordDate});

  Split.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'].toString();
    fvChangeFrom = json['fv_change_from'].toString();
    fvChangeTo = json['fv_change_to'].toString();
    recordDate = json['record date'].toString();
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

class StockFinancialsConsolidated {
  List<ConsolidatedBalanceSheet>? balanceSheet;
  List<CashflowSheet>? cashflowSheet;
  List<IncomeSheet>? incomeSheet;

  StockFinancialsConsolidated(
      {this.balanceSheet, this.cashflowSheet, this.incomeSheet});

  StockFinancialsConsolidated.fromJson(Map<String, dynamic> json) {
    if (json['balanceSheet'] != null) {
      balanceSheet = <ConsolidatedBalanceSheet>[];
      json['balanceSheet'].forEach((v) {
        balanceSheet!.add(ConsolidatedBalanceSheet.fromJson(v));
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

class ConsolidatedBalanceSheet {
  String? costOfSoftwareDevelopment;
  String? earningsPerShare;
  String? employeeCost;
  String? equityDividendPercent;
  String? generalAndAdministrationExpenses;
  String? increaseAndDecreaseInStock;
  String? lessExcise;
  String? lessExpensesCapitalised;
  String? lessInterDivisionalTransfers;
  String? lessSalesReturns;
  String? miscellaneousExpenses;
  String? netSales;
  String? operatingAndManufacturingExpenses;
  String? operatingProfit;
  String? otherIncome;
  String? powerAndFuelCost;
  String? profitAfterTax;
  String? profitBeforeTax;
  String? provisionForTax;
  String? rawMaterialConsumed;
  String? salesTurnover;
  String? sellingAndDistributionExpenses;
  String? totalExpenditure;
  String? yearEndDate;

  ConsolidatedBalanceSheet(
      {this.costOfSoftwareDevelopment,
      this.earningsPerShare,
      this.employeeCost,
      this.equityDividendPercent,
      this.generalAndAdministrationExpenses,
      this.increaseAndDecreaseInStock,
      this.lessExcise,
      this.lessExpensesCapitalised,
      this.lessInterDivisionalTransfers,
      this.lessSalesReturns,
      this.miscellaneousExpenses,
      this.netSales,
      this.operatingAndManufacturingExpenses,
      this.operatingProfit,
      this.otherIncome,
      this.powerAndFuelCost,
      this.profitAfterTax,
      this.profitBeforeTax,
      this.provisionForTax,
      this.rawMaterialConsumed,
      this.salesTurnover,
      this.sellingAndDistributionExpenses,
      this.totalExpenditure,
      this.yearEndDate});

  ConsolidatedBalanceSheet.fromJson(Map<String, dynamic> json) {
    costOfSoftwareDevelopment = json['cost_of_software_development'].toString();
    earningsPerShare = json['earnings_per_share'].toString();
    employeeCost = json['employee_cost'].toString();
    equityDividendPercent = json['equity_dividend_percent'].toString();
    generalAndAdministrationExpenses =
        json['general_and_administration_expenses'].toString();
    increaseAndDecreaseInStock = json['increase_and_decrease_in_stock'].toString();
    lessExcise = json['less_excise'].toString();
    lessExpensesCapitalised = json['less_expenses_capitalised'].toString();
    lessInterDivisionalTransfers = json['less_inter_divisional_transfers'].toString();
    lessSalesReturns = json['less_sales_returns'].toString();
    miscellaneousExpenses = json['miscellaneous_expenses'].toString();
    netSales = json['net_sales'].toString();
    operatingAndManufacturingExpenses =
        json['operating__and__manufacturing_expenses'].toString();
    operatingProfit = json['operating_profit'].toString();
    otherIncome = json['other_income'].toString();
    powerAndFuelCost = json['power__and__fuel_cost'].toString();
    profitAfterTax = json['profit_after_tax'].toString();
    profitBeforeTax = json['profit_before_tax'].toString();
    provisionForTax = json['provision_for_tax'].toString();
    rawMaterialConsumed = json['raw_material_consumed'].toString();
    salesTurnover = json['sales_turnover'].toString();
    sellingAndDistributionExpenses = json['selling_and_distribution_expenses'].toString();
    totalExpenditure = json['total_expenditure'].toString();
    yearEndDate = json['year_end_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cost_of_software_development'] = costOfSoftwareDevelopment;
    data['earnings_per_share'] = earningsPerShare;
    data['employee_cost'] = employeeCost;
    data['equity_dividend_percent'] = equityDividendPercent;
    data['general_and_administration_expenses'] =
        generalAndAdministrationExpenses;
    data['increase_and_decrease_in_stock'] = increaseAndDecreaseInStock;
    data['less_excise'] = lessExcise;
    data['less_expenses_capitalised'] = lessExpensesCapitalised;
    data['less_inter_divisional_transfers'] = lessInterDivisionalTransfers;
    data['less_sales_returns'] = lessSalesReturns;
    data['miscellaneous_expenses'] = miscellaneousExpenses;
    data['net_sales'] = netSales;
    data['operating__and__manufacturing_expenses'] =
        operatingAndManufacturingExpenses;
    data['operating_profit'] = operatingProfit;
    data['other_income'] = otherIncome;
    data['power__and__fuel_cost'] = powerAndFuelCost;
    data['profit_after_tax'] = profitAfterTax;
    data['profit_before_tax'] = profitBeforeTax;
    data['provision_for_tax'] = provisionForTax;
    data['raw_material_consumed'] = rawMaterialConsumed;
    data['sales_turnover'] = salesTurnover;
    data['selling_and_distribution_expenses'] = sellingAndDistributionExpenses;
    data['total_expenditure'] = totalExpenditure;
    data['year_end_date'] = yearEndDate;
    return data;
  }
}

class CashflowSheet {
  String? cashFlowFromInvestingActivities;
  String? cashFromFinancingActivities;
  String? cashFromOperatingActivities;
  String? yearEndDate;

  CashflowSheet(
      {this.cashFlowFromInvestingActivities,
      this.cashFromFinancingActivities,
      this.cashFromOperatingActivities,
      this.yearEndDate});

  CashflowSheet.fromJson(Map<String, dynamic> json) {
    cashFlowFromInvestingActivities =
        json['cash_flow_from_investing_activities'].toString();
    cashFromFinancingActivities = json['cash_from_financing_activities'].toString();
    cashFromOperatingActivities = json['cash_from_operating_activities'].toString();
    yearEndDate = json['year_end_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash_flow_from_investing_activities'] =
        cashFlowFromInvestingActivities;
    data['cash_from_financing_activities'] = cashFromFinancingActivities;
    data['cash_from_operating_activities'] = cashFromOperatingActivities;
    data['year_end_date'] = yearEndDate;
    return data;
  }
}

class StockFinancialsStandalone {
  List<StandaloneBalanceSheet>? balanceSheet;
  List<CashflowSheet>? cashflowSheet;
  List<IncomeSheet>? incomeSheet;

  StockFinancialsStandalone(
      {this.balanceSheet, this.cashflowSheet, this.incomeSheet});

  StockFinancialsStandalone.fromJson(Map<String, dynamic> json) {
    if (json['balanceSheet'] != null) {
      balanceSheet = <StandaloneBalanceSheet>[];
      json['balanceSheet'].forEach((v) {
        balanceSheet!.add(StandaloneBalanceSheet.fromJson(v));
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

class StandaloneBalanceSheet {
  String? cashAndBank;
  String? currentsInvestments;
  String? deferredTaxAssetsAndLiabilities;
  String? grossBlock;
  String? inventories;
  String? longTermLoansAndAdvances;
  String? longTermTradePayables;
  String? nonCurrentAssets;
  String? nonCurrentInvestments;
  String? otherCurrentAssets;
  String? otherCurrentLiabilities;
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

  StandaloneBalanceSheet(
      {this.cashAndBank,
      this.currentsInvestments,
      this.deferredTaxAssetsAndLiabilities,
      this.grossBlock,
      this.inventories,
      this.longTermLoansAndAdvances,
      this.longTermTradePayables,
      this.nonCurrentAssets,
      this.nonCurrentInvestments,
      this.otherCurrentAssets,
      this.otherCurrentLiabilities,
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
      this.yearEndDate});

  StandaloneBalanceSheet.fromJson(Map<String, dynamic> json) {
    cashAndBank = json['cash_and_bank'].toString();
    currentsInvestments = json['currents_investments'].toString();
    deferredTaxAssetsAndLiabilities =
        json['deferred_tax_assets__and__liabilities'].toString();
    grossBlock = json['gross_block'].toString();
    inventories = json['inventories'].toString();
    longTermLoansAndAdvances = json['long_term_loans__and__advances'].toString();
    longTermTradePayables = json['long_term_trade_payables'].toString();
    nonCurrentAssets = json['non_current_assets'].toString();
    nonCurrentInvestments = json['non_current_investments'].toString();
    otherCurrentAssets = json['other_current_assets'].toString();
    otherCurrentLiabilities = json['other_current_liabilities'].toString();
    otherLongTermLiabilities = json['other_long_term_liabilities'].toString();
    otherNonCurrentAssets = json['other_non_current_assets'].toString();
    securedLoans = json['secured_loans'].toString();
    shortTermBorrowings = json['short_term_borrowings'].toString();
    shortTermLoansAndAdvances = json['short_term_loans_and_advances'].toString();
    shortTermProvisions = json['short_term_provisions'].toString();
    sundryDebtors = json['sundry_debtors'].toString();
    totalAssets = json['total_assets'].toString();
    totalCurrentAssets = json['total_current_assets'].toString();
    totalCurrentLiabilities = json['total_current_liabilities'].toString();
    totalLiabilities = json['total_liabilities'].toString();
    totalNonCurrentAssets = json['total_non_current_assets'].toString();
    totalNonCurrentLiabilities = json['total_non_current_liabilities'].toString();
    tradePayables = json['trade_payables'].toString();
    unsecuredLoans = json['unsecured_loans'].toString();
    yearEndDate = json['year_end_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash_and_bank'] = cashAndBank;
    data['currents_investments'] = currentsInvestments;
    data['deferred_tax_assets__and__liabilities'] =
        deferredTaxAssetsAndLiabilities;
    data['gross_block'] = grossBlock;
    data['inventories'] = inventories;
    data['long_term_loans__and__advances'] = longTermLoansAndAdvances;
    data['long_term_trade_payables'] = longTermTradePayables;
    data['non_current_assets'] = nonCurrentAssets;
    data['non_current_investments'] = nonCurrentInvestments;
    data['other_current_assets'] = otherCurrentAssets;
    data['other_current_liabilities'] = otherCurrentLiabilities;
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
    return data;
  }
}

class IncomeSheet {
  String? costOfSoftwareDevelopment;
  String? earningsPerShare;
  String? employeeCost;
  String? equityDividendPercent;
  String? generalAndAdministrationExpenses;
  String? increaseAndDecreaseInStock;
  String? lessExcise;
  String? lessExpensesCapitalised;
  String? lessInterDivisionalTransfers;
  String? lessSalesReturns;
  String? miscellaneousExpenses;
  String? netSales;
  String? operatingAndManufacturingExpenses;
  String? operatingProfit;
  String? otherIncome;
  String? powerAndFuelCost;
  String? profitAfterTax;
  String? profitBeforeTax;
  String? provisionForTax;
  String? rawMaterialConsumed;
  String? salesTurnover;
  String? sellingAndDistributionExpenses;
  String? totalExpenditure;
  String? yearEndDate;

  IncomeSheet(
      {this.costOfSoftwareDevelopment,
      this.earningsPerShare,
      this.employeeCost,
      this.equityDividendPercent,
      this.generalAndAdministrationExpenses,
      this.increaseAndDecreaseInStock,
      this.lessExcise,
      this.lessExpensesCapitalised,
      this.lessInterDivisionalTransfers,
      this.lessSalesReturns,
      this.miscellaneousExpenses,
      this.netSales,
      this.operatingAndManufacturingExpenses,
      this.operatingProfit,
      this.otherIncome,
      this.powerAndFuelCost,
      this.profitAfterTax,
      this.profitBeforeTax,
      this.provisionForTax,
      this.rawMaterialConsumed,
      this.salesTurnover,
      this.sellingAndDistributionExpenses,
      this.totalExpenditure,
      this.yearEndDate});

  IncomeSheet.fromJson(Map<String, dynamic> json) {
    costOfSoftwareDevelopment = json['cost_of_software_development'].toString();
    earningsPerShare = json['earnings_per_share'].toString();
    employeeCost = json['employee_cost'].toString();
    equityDividendPercent = json['equity_dividend_percent'].toString();
    generalAndAdministrationExpenses =
        json['general_and_administration_expenses'].toString();
    increaseAndDecreaseInStock = json['increase_and_decrease_in_stock'].toString();
    lessExcise = json['less_excise'].toString();
    lessExpensesCapitalised = json['less_expenses_capitalised'].toString();
    lessInterDivisionalTransfers = json['less_inter_divisional_transfers'].toString();
    lessSalesReturns = json['less_sales_returns'].toString();
    miscellaneousExpenses = json['miscellaneous_expenses'].toString();
    netSales = json['net_sales'].toString();
    operatingAndManufacturingExpenses =
        json['operating__and__manufacturing_expenses'].toString();
    operatingProfit = json['operating_profit'].toString();
    otherIncome = json['other_income'].toString();
    powerAndFuelCost = json['power__and__fuel_cost'].toString();
    profitAfterTax = json['profit_after_tax'].toString();
    profitBeforeTax = json['profit_before_tax'].toString();
    provisionForTax = json['provision_for_tax'].toString();
    rawMaterialConsumed = json['raw_material_consumed'].toString();
    salesTurnover = json['sales_turnover'].toString();
    sellingAndDistributionExpenses = json['selling_and_distribution_expenses'].toString();
    totalExpenditure = json['total_expenditure'].toString();
    yearEndDate = json['year_end_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cost_of_software_development'] = costOfSoftwareDevelopment;
    data['earnings_per_share'] = earningsPerShare;
    data['employee_cost'] = employeeCost;
    data['equity_dividend_percent'] = equityDividendPercent;
    data['general_and_administration_expenses'] =
        generalAndAdministrationExpenses;
    data['increase_and_decrease_in_stock'] = increaseAndDecreaseInStock;
    data['less_excise'] = lessExcise;
    data['less_expenses_capitalised'] = lessExpensesCapitalised;
    data['less_inter_divisional_transfers'] = lessInterDivisionalTransfers;
    data['less_sales_returns'] = lessSalesReturns;
    data['miscellaneous_expenses'] = miscellaneousExpenses;
    data['net_sales'] = netSales;
    data['operating__and__manufacturing_expenses'] =
        operatingAndManufacturingExpenses;
    data['operating_profit'] = operatingProfit;
    data['other_income'] = otherIncome;
    data['power__and__fuel_cost'] = powerAndFuelCost;
    data['profit_after_tax'] = profitAfterTax;
    data['profit_before_tax'] = profitBeforeTax;
    data['provision_for_tax'] = provisionForTax;
    data['raw_material_consumed'] = rawMaterialConsumed;
    data['sales_turnover'] = salesTurnover;
    data['selling_and_distribution_expenses'] = sellingAndDistributionExpenses;
    data['total_expenditure'] = totalExpenditure;
    data['year_end_date'] = yearEndDate;
    return data;
  }
}
