class MFFactSheetDataModel {
  Data? data;
  String? stat;

  MFFactSheetDataModel({this.data, this.stat});

  MFFactSheetDataModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['stat'] = stat;
    return data;
  }
}

class Data {
  String? d10Year;
  String? d1Day;
  String? d1Year;
  String? d2Year;
  String? d30Day;
  String? d3Month;
  String? d3Year;
  String? d5Year;
  String? d6Month;
  String? d7Year;
  String? managerCommoditiesHighestReturnsPercentage;
  String? managerDebtHighestReturnsPercentage;
  String? managerEquityHighestReturnsPercentage;
  String? managerHybridHighestReturnsPercentage;
  String? managerTaxSaverHighestReturnsPercentage;
  String? managerActiveFundsAumSum;
  String? managerDesignation;
  String? managerDetailedDescription;
  String? managerNumberOfActiveFunds;
  String? managerTotalExperience;
  String? alpha;
  String? avgMat;
  String? benchmark;
  List<BenchmarkCalenderReturn>? benchmarkCalenderReturn;
  String? benchmarkSchid;
  BenchmarkTrailingReturn? benchmarkTrailingReturn;
  String? beta;
  List<BenchmarkCalenderReturn>? calenderReturn;
  String? category;
  String? changePercent;
  String? closeEnded;
  String? corpus;
  String? currentNAV;
  String? exitLoad;
  String? expenseRatio;
  String? factSheetDate;
  String? fundManager;
  String? fundName;
  String? fundRat;
  String? globalEquityPercent;
  String? goldPercent;
  List<Holdings>? holdings;
  String? launchDate;
  String? mean;
  String? modifiedDuration;
  String? name;
  String? navDate;
  String? overview;
  String? overview1;
  String? overview2;
  String? purchaseMinAmount;
  String? risk;
  String? schObjective;
  List<Sectors>? sectors;
  String? sharpRatio;
  String? sipMinAmount;
  String? standardDev;
  String? taxSaving;
  String? taxStat;
  TrailingReturn? trailingReturn;
  String? vDebt;
  String? vEquity;
  String? vOther;
  String? weekHigh;
  String? weekHighDate;
  String? weekLow;
  String? weekLowDate;
  String? ytm;
  bool?isAdd;

  Data(
      {this.d10Year,
      this.d1Day,
      this.d1Year,
      this.d2Year,
      this.d30Day,
      this.d3Month,
      this.d3Year,
      this.d5Year,
      this.d6Month,
      this.d7Year,
      this.managerCommoditiesHighestReturnsPercentage,
      this.managerDebtHighestReturnsPercentage,
      this.managerEquityHighestReturnsPercentage,
      this.managerHybridHighestReturnsPercentage,
      this.managerTaxSaverHighestReturnsPercentage,
      this.managerActiveFundsAumSum,
      this.managerDesignation,
      this.managerDetailedDescription,
      this.managerNumberOfActiveFunds,
      this.managerTotalExperience,
      this.alpha,
      this.avgMat,
      this.benchmark,
      this.benchmarkCalenderReturn,
      this.benchmarkSchid,
      this.benchmarkTrailingReturn,
      this.beta,
      this.calenderReturn,
      this.category,
      this.changePercent,
      this.closeEnded,
      this.corpus,
      this.currentNAV,
      this.exitLoad,
      this.expenseRatio,
      this.factSheetDate,
      this.fundManager,
      this.fundName,
      this.fundRat,
      this.globalEquityPercent,
      this.goldPercent,
      this.holdings,
      this.launchDate,
      this.mean,
      this.modifiedDuration,
      this.name,
      this.navDate,
      this.overview,
      this.purchaseMinAmount,
      this.risk,
      this.schObjective,
      this.sectors,
      this.sharpRatio,
      this.sipMinAmount,
      this.standardDev,
      this.taxSaving,
      this.taxStat,
      this.trailingReturn,
      this.vDebt,
      this.vEquity,
      this.vOther,
      this.weekHigh,
      this.weekHighDate,
      this.weekLow,
      this.weekLowDate,
      this.ytm,
      this.overview1,
      this.overview2,this.isAdd});

  Data.fromJson(Map<String, dynamic> json) {
    d10Year = json['10Year'].toString();
    d1Day = json['1Day'].toString();
    d1Year = json['1Year'].toString();
    d2Year = json['2Year'].toString();
    d30Day = json['30Day'].toString();
    d3Month = json['3Month'].toString();
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    d6Month = json['6Month'].toString();
    d7Year = json['7Year'].toString();
    managerCommoditiesHighestReturnsPercentage =
        json['Manager_Commodities_highestReturnsPercentage'].toString();
    managerDebtHighestReturnsPercentage =
        json['Manager_Debt_highestReturnsPercentage'].toString();
    managerEquityHighestReturnsPercentage =
        json['Manager_Equity_highestReturnsPercentage'].toString();
    managerHybridHighestReturnsPercentage =
        json['Manager_Hybrid_highestReturnsPercentage'].toString();
    managerTaxSaverHighestReturnsPercentage =
        json['Manager_TaxSaver_highestReturnsPercentage'].toString();
    managerActiveFundsAumSum = json['Manager_activeFundsAumSum'].toString();
    managerDesignation = json['Manager_designation'].toString();
    managerDetailedDescription = json['Manager_detailedDescription'].toString();
    managerNumberOfActiveFunds = json['Manager_numberOfActiveFunds'].toString();
    managerTotalExperience = json['Manager_totalExperience'].toString();
    alpha = json['alpha'].toString();
    avgMat = json['avgMat'].toString();
    benchmark = json['benchmark'].toString();
    if (json['benchmarkCalenderReturn'] != null) {
      benchmarkCalenderReturn = <BenchmarkCalenderReturn>[];
      json['benchmarkCalenderReturn'].forEach((v) {
        benchmarkCalenderReturn!.add(BenchmarkCalenderReturn.fromJson(v));
      });
    }
    benchmarkSchid = json['benchmarkSchid'].toString();
    benchmarkTrailingReturn = json['benchmarkTrailingReturn'] != null
        ? BenchmarkTrailingReturn.fromJson(json['benchmarkTrailingReturn'])
        : null;
    beta = json['beta'].toString();
    if (json['calenderReturn'] != null) {
      calenderReturn = <BenchmarkCalenderReturn>[];
      json['calenderReturn'].forEach((v) {
        calenderReturn!.add(BenchmarkCalenderReturn.fromJson(v));
      });
    }
    category = json['category'].toString();
    changePercent = json['changePercent'].toString();
    closeEnded = json['closeEnded'].toString();
    corpus = json['corpus'].toString();
    currentNAV = json['currentNAV'].toString();
    exitLoad = json['exitLoad'].toString();
    expenseRatio = json['expenseRatio'].toString();
    factSheetDate = json['factSheetDate'].toString();
    fundManager = json['fundManager'].toString();
    fundName = json['fundName'].toString();
    fundRat = json['fundRat'].toString();
    globalEquityPercent = json['globalEquityPercent'].toString();
    goldPercent = json['goldPercent'].toString();
    if (json['holdings'] != null) {
      holdings = <Holdings>[];
      json['holdings'].forEach((v) {
        holdings!.add(Holdings.fromJson(v));
      });
    }
    launchDate = json['launchDate'].toString();
    mean = json['mean'].toString();
    modifiedDuration = json['modifiedDuration'].toString();
    name = json['name'].toString();
    navDate = json['navDate'].toString();
    overview = json['overview'].toString();
    purchaseMinAmount = json['purchaseMinAmount'].toString();
    risk = json['risk'].toString();
    schObjective = json['schObjective'].toString();
    if (json['sectors'] != null) {
      sectors = <Sectors>[];
      json['sectors'].forEach((v) {
        sectors!.add(Sectors.fromJson(v));
      });
    }
    sharpRatio = json['sharpRatio'].toString();
    sipMinAmount = json['sipMinAmount'].toString();
    standardDev = json['standardDev'].toString();
    taxSaving = json['taxSaving'].toString();
    taxStat = json['taxStat'].toString();
    trailingReturn = json['trailingReturn'] != null
        ? TrailingReturn.fromJson(json['trailingReturn'])
        : null;
    vDebt = json['vDebt'].toString();
    vEquity = json['vEquity'].toString();
    vOther = json['vOther'].toString();
    weekHigh = json['weekHigh'].toString();
    weekHighDate = json['weekHighDate'].toString();
    weekLow = json['weekLow'].toString();
    weekLowDate = json['weekLowDate'].toString();
    ytm = json['ytm'].toString();
     isAdd=json['isAdd']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['10Year'] = d10Year;
    data['1Day'] = d1Day;
    data['1Year'] = d1Year;
    data['2Year'] = d2Year;
    data['30Day'] = d30Day;
    data['3Month'] = d3Month;
    data['3Year'] = d3Year;
    data['5Year'] = d5Year;
    data['6Month'] = d6Month;
    data['7Year'] = d7Year;
    data['Manager_Commodities_highestReturnsPercentage'] =
        managerCommoditiesHighestReturnsPercentage;
    data['Manager_Debt_highestReturnsPercentage'] =
        managerDebtHighestReturnsPercentage;
    data['Manager_Equity_highestReturnsPercentage'] =
        managerEquityHighestReturnsPercentage;
    data['Manager_Hybrid_highestReturnsPercentage'] =
        managerHybridHighestReturnsPercentage;
    data['Manager_TaxSaver_highestReturnsPercentage'] =
        managerTaxSaverHighestReturnsPercentage;
    data['Manager_activeFundsAumSum'] = managerActiveFundsAumSum;
    data['Manager_designation'] = managerDesignation;
    data['Manager_detailedDescription'] = managerDetailedDescription;
    data['Manager_numberOfActiveFunds'] = managerNumberOfActiveFunds;
    data['Manager_totalExperience'] = managerTotalExperience;
    data['alpha'] = alpha;
    data['avgMat'] = avgMat;
    data['benchmark'] = benchmark;
    if (benchmarkCalenderReturn != null) {
      data['benchmarkCalenderReturn'] =
          benchmarkCalenderReturn!.map((v) => v.toJson()).toList();
    }
    data['benchmarkSchid'] = benchmarkSchid;
    if (benchmarkTrailingReturn != null) {
      data['benchmarkTrailingReturn'] = benchmarkTrailingReturn!.toJson();
    }
    data['beta'] = beta;
    if (calenderReturn != null) {
      data['calenderReturn'] = calenderReturn!.map((v) => v.toJson()).toList();
    }
    data['category'] = category;
    data['changePercent'] = changePercent;
    data['closeEnded'] = closeEnded;
    data['corpus'] = corpus;
    data['currentNAV'] = currentNAV;
    data['exitLoad'] = exitLoad;
    data['expenseRatio'] = expenseRatio;
    data['factSheetDate'] = factSheetDate;
    data['fundManager'] = fundManager;
    data['fundName'] = fundName;
    data['fundRat'] = fundRat;
    data['globalEquityPercent'] = globalEquityPercent;
    data['goldPercent'] = goldPercent;
    if (holdings != null) {
      data['holdings'] = holdings!.map((v) => v.toJson()).toList();
    }
    data['launchDate'] = launchDate;
    data['mean'] = mean;
    data['modifiedDuration'] = modifiedDuration;
    data['name'] = name;
    data['navDate'] = navDate;
    data['overview'] = overview;
    data['purchaseMinAmount'] = purchaseMinAmount;
    data['risk'] = risk;
    data['schObjective'] = schObjective;
    if (sectors != null) {
      data['sectors'] = sectors!.map((v) => v.toJson()).toList();
    }
    data['sharpRatio'] = sharpRatio;
    data['sipMinAmount'] = sipMinAmount;
    data['standardDev'] = standardDev;
    data['taxSaving'] = taxSaving;
    data['taxStat'] = taxStat;
    if (trailingReturn != null) {
      data['trailingReturn'] = trailingReturn!.toJson();
    }
    data['vDebt'] = vDebt;
    data['vEquity'] = vEquity;
    data['vOther'] = vOther;
    data['weekHigh'] = weekHigh;
    data['weekHighDate'] = weekHighDate;
    data['weekLow'] = weekLow;
    data['weekLowDate'] = weekLowDate;
    data['ytm'] = ytm;
        data['isAdd']=isAdd;
    return data;
  }
}

class BenchmarkCalenderReturn {
  String? rET;
  String? year;

  BenchmarkCalenderReturn({this.rET, this.year});

  BenchmarkCalenderReturn.fromJson(Map<String, dynamic> json) {
    rET = json['RET'].toString();
    year = json['Year'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RET'] = rET;
    data['Year'] = year;
    return data;
  }
}

class BenchmarkTrailingReturn {
  String? d10YearBenchMarkReturn;
  String? d1YearBenchMarkReturn;
  String? d2YearBenchMarkReturn;
  String? d30DayBenchMarkReturn;
  String? d3MonthBenchMarkReturn;
  String? d3YearBenchMarkReturn;
  String? d5YearBenchMarkReturn;
  String? d6MonthBenchMarkReturn;
  String? d7YearBenchMarkReturn;

  BenchmarkTrailingReturn(
      {this.d10YearBenchMarkReturn,
      this.d1YearBenchMarkReturn,
      this.d2YearBenchMarkReturn,
      this.d30DayBenchMarkReturn,
      this.d3MonthBenchMarkReturn,
      this.d3YearBenchMarkReturn,
      this.d5YearBenchMarkReturn,
      this.d6MonthBenchMarkReturn,
      this.d7YearBenchMarkReturn});

  BenchmarkTrailingReturn.fromJson(Map<String, dynamic> json) {
    d10YearBenchMarkReturn = json['10YearBenchMarkReturn'].toString();
    d1YearBenchMarkReturn = json['1YearBenchMarkReturn'].toString();
    d2YearBenchMarkReturn = json['2YearBenchMarkReturn'].toString();
    d30DayBenchMarkReturn = json['30DayBenchMarkReturn'].toString();
    d3MonthBenchMarkReturn = json['3MonthBenchMarkReturn'].toString();
    d3YearBenchMarkReturn = json['3YearBenchMarkReturn'].toString();
    d5YearBenchMarkReturn = json['5YearBenchMarkReturn'].toString();
    d6MonthBenchMarkReturn = json['6MonthBenchMarkReturn'].toString();
    d7YearBenchMarkReturn = json['7YearBenchMarkReturn'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['10YearBenchMarkReturn'] = d10YearBenchMarkReturn;
    data['1YearBenchMarkReturn'] = d1YearBenchMarkReturn;
    data['2YearBenchMarkReturn'] = d2YearBenchMarkReturn;
    data['30DayBenchMarkReturn'] = d30DayBenchMarkReturn;
    data['3MonthBenchMarkReturn'] = d3MonthBenchMarkReturn;
    data['3YearBenchMarkReturn'] = d3YearBenchMarkReturn;
    data['5YearBenchMarkReturn'] = d5YearBenchMarkReturn;
    data['6MonthBenchMarkReturn'] = d6MonthBenchMarkReturn;
    data['7YearBenchMarkReturn'] = d7YearBenchMarkReturn;
    return data;
  }
}

class Holdings {
  String? holdings;
  String? instruments;
  String? netAsset;
  String? sector;

  Holdings({this.holdings, this.instruments, this.netAsset, this.sector});

  Holdings.fromJson(Map<String, dynamic> json) {
    holdings = json['holdings'].toString();
    instruments = json['instruments'].toString();
    netAsset = json['netAsset'].toString();
    sector = json['sector'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['holdings'] = holdings;
    data['instruments'] = instruments;
    data['netAsset'] = netAsset;
    data['sector'] = sector;
    return data;
  }
}

class Sectors {
  String? netAsset;
  String? sectorRating;

  Sectors({this.netAsset, this.sectorRating});

  Sectors.fromJson(Map<String, dynamic> json) {
    netAsset = json['netAsset'].toString();
    sectorRating = json['sectorRating'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['netAsset'] = netAsset;
    data['sectorRating'] = sectorRating;
    return data;
  }
}

class TrailingReturn {
  String? d10Year;
  String? d1Year;
  String? d2Year;
  String? d30Day;
  String? d3Month;
  String? d3Year;
  String? d5Year;
  String? d6Month;
  String? d7Year;

  TrailingReturn(
      {this.d10Year,
      this.d1Year,
      this.d2Year,
      this.d30Day,
      this.d3Month,
      this.d3Year,
      this.d5Year,
      this.d6Month,
      this.d7Year});

  TrailingReturn.fromJson(Map<String, dynamic> json) {
    d10Year = json['10Year'].toString();
    d1Year = json['1Year'].toString();
    d2Year = json['2Year'].toString();
    d30Day = json['30Day'].toString();
    d3Month = json['3Month'].toString();
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    d6Month = json['6Month'].toString();
    d7Year = json['7Year'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['10Year'] = d10Year;
    data['1Year'] = d1Year;
    data['2Year'] = d2Year;
    data['30Day'] = d30Day;
    data['3Month'] = d3Month;
    data['3Year'] = d3Year;
    data['5Year'] = d5Year;
    data['6Month'] = d6Month;
    data['7Year'] = d7Year;
    return data;
  }
}
