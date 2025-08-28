import 'package:flutter/material.dart';

class PortfolioResponse {
  final double xirrResult;
  final Map<String, double> accountAllocation;
  final Map<String, double> marketCapAllocation;
  final Map<String, double> sectorAllocation;
  final List<TopStock> topStocks;
  final List<Fundamental> fundamentals;
  final ChartData? chartData;

  PortfolioResponse({
    required this.xirrResult,
    required this.accountAllocation,
    required this.marketCapAllocation,
    required this.sectorAllocation,
    required this.topStocks,
    required this.fundamentals,
    this.chartData,
  });

  factory PortfolioResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioResponse(
      xirrResult: (json['xirr_result'] ?? 0.0).toDouble(),
      accountAllocation: Map<String, double>.from(
        (json['account_allocation'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
        ),
      ),
      marketCapAllocation: Map<String, double>.from(
        (json['market_cap_allocation'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
        ),
      ),
      sectorAllocation: Map<String, double>.from(
        (json['sector_allocation'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
        ),
      ),
      topStocks: (json['top_stocks'] as List<dynamic>? ?? [])
          .map((item) => TopStock.fromJson(item))
          .toList(),
      fundamentals: (json['fundamentals'] as List<dynamic>? ?? [])
          .map((item) => Fundamental.fromJson(item))
          .toList(),
      chartData: json['chart_data'] != null 
          ? ChartData.fromJson(json['chart_data']) 
          : null,
    );
  }
}

class TopStock {
  final String name;
  final String tsym;
  final double allocationPercent;
  final String marketCapType;

  TopStock({
    required this.name,
    required this.tsym,
    required this.allocationPercent,
    required this.marketCapType,
  });

  factory TopStock.fromJson(Map<String, dynamic> json) {
    return TopStock(
      name: json['name'] ?? '',
      tsym: json['tsym'] ?? '',
      allocationPercent: (json['allocation_percent'] ?? 0.0).toDouble(),
      marketCapType: json['market_cap_type'] ?? '',
    );
  }
}

class Fundamental {
  final int? code;
  final String? sector;
  final double? marketCap;
  final String? companyName;
  final String? marketCapType;
  final String? exch;
  final String? tsym;
  final String? industry;
  final String? house;
  final int? bseCode;
  final String? bseGroup;
  final String? bseScripName;
  final String? tradingStatus;
  final String? nseSymbol;
  final String? nseSeries;
  final String? bseScripId;
  final String? listingStatus;
  final String? isinNo;
  final int? incorporationYear;
  final String? symbol;
  final String? zebuToken;
  final int? qty;
  final double? uploadedPrice;
  final double? value;
  final String? category;
  final double? roePercent;
  final double? rocePercent;
  final double? roaPercent;
  final double? debtToEquity;
  final double? evEbitda;
  final double? bookValue;
  final double? salesToWorkingCapital;
  final double? fixedCapitalToSales;
  final double? priceBookValue;
  final double? eps;
  final double? dividendYieldPercent;
  final double? fv;
  final double? pe;
  final double? sectorPe;

  Fundamental({
    this.code,
    this.sector,
    this.marketCap,
    this.companyName,
    this.marketCapType,
    this.exch,
    this.tsym,
    this.industry,
    this.house,
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
    this.symbol,
    this.zebuToken,
    this.qty,
    this.uploadedPrice,
    this.value,
    this.category,
    this.roePercent,
    this.rocePercent,
    this.roaPercent,
    this.debtToEquity,
    this.evEbitda,
    this.bookValue,
    this.salesToWorkingCapital,
    this.fixedCapitalToSales,
    this.priceBookValue,
    this.eps,
    this.dividendYieldPercent,
    this.fv,
    this.pe,
    this.sectorPe,
  });

  factory Fundamental.fromJson(Map<String, dynamic> json) {
    return Fundamental(
      code: json['code']?.toInt(),
      sector: json['sector'],
      marketCap: json['market_cap']?.toDouble(),
      companyName: json['company_name'],
      marketCapType: json['market_cap_type'],
      exch: json['exch'],
      tsym: json['tsym'],
      industry: json['industry'],
      house: json['house'],
      bseCode: json['bse_code']?.toInt(),
      bseGroup: json['bse_group'],
      // Fixed: Handle the space in field name
      bseScripName: json['bse_scrip name'] ?? json['bse_scrip_name'],
      tradingStatus: json['trading_status'],
      nseSymbol: json['nse_symbol'],
      nseSeries: json['nse_series'],
      bseScripId: json['bse_scrip_id'],
      listingStatus: json['listing_status'],
      isinNo: json['isin_no'],
      incorporationYear: json['incorporation_year']?.toInt(),
      symbol: json['SYMBOL'],
      zebuToken: json['zebuToken'],
      qty: json['qty']?.toInt(),
      uploadedPrice: json['uploaded_price']?.toDouble(),
      value: json['value']?.toDouble(),
      category: json['category'],
      roePercent: json['roe_percent']?.toDouble(),
      rocePercent: json['roce_percent']?.toDouble(),
      roaPercent: json['roa_percent']?.toDouble(),
      debtToEquity: json['debt_to_equity']?.toDouble(),
      evEbitda: json['ev_ebitda']?.toDouble(),
      bookValue: json['book_value']?.toDouble(),
      salesToWorkingCapital: json['sales_to_working_capital']?.toDouble(),
      fixedCapitalToSales: json['fixed_capital_to_sales']?.toDouble(),
      priceBookValue: json['price_book_value']?.toDouble(),
      eps: json['eps']?.toDouble(),
      dividendYieldPercent: json['dividend_yield_percent']?.toDouble(),
      fv: json['fv']?.toDouble(),
      pe: json['pe']?.toDouble(),
      sectorPe: json['sector_pe']?.toDouble(),
    );
  }
}


class ChartData {
  final List<String> dates;
  final List<double> totalInvestedValue;
  final List<double> totalCurrentValue;

  ChartData({
    required this.dates,
    required this.totalInvestedValue,
    required this.totalCurrentValue,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      dates: (json['date'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      totalInvestedValue: (json['total_invested_value'] as List<dynamic>? ?? [])
          .map((item) => (item ?? 0.0).toDouble())
          .toList()
          .cast<double>(),
      totalCurrentValue: (json['total_current_value'] as List<dynamic>? ?? [])
          .map((item) => (item ?? 0.0).toDouble())
          .toList()
          .cast<double>(),
    );
  }
}
