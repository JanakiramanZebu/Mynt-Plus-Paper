// portfolio_analysis_model.dart
class PortfolioAnalysisModel {
  final PortfolioTotal total;
  final BenchmarkData benchmark;
  final InflationAdjustedData inflationAdjusted;
  final List<EquityScheme> equity;
  final List<DebtScheme> debt;
  final TaxDetails taxDetails;

  PortfolioAnalysisModel({
    required this.total,
    required this.benchmark,
    required this.inflationAdjusted,
    required this.equity,
    required this.debt,
    required this.taxDetails,
  });

  factory PortfolioAnalysisModel.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing PortfolioAnalysisModel from JSON with keys: ${json.keys.toList()}");
      
      return PortfolioAnalysisModel(
        total: _safeFromJson<PortfolioTotal>(
          json['total'], 
          (data) => PortfolioTotal.fromJson(data),
          () => PortfolioTotal(
            investmentAmount: 0.0,
            currentValue: 0.0,
            gain: 0.0,
            gainPerc: 0.0,
            xirr: 0.0,
            volatility: 0.0,
            sharpeRatio: 0.0,
            maxDrawdown: 0.0,
            chartData: [],
          ),
        ),
        benchmark: _safeFromJson<BenchmarkData>(
          json['benchmark'], 
          (data) => BenchmarkData.fromJson(data),
          () => BenchmarkData(
            investmentAmount: 0.0,
            currentValue: 0.0,
            gain: 0.0,
            gainPerc: 0.0,
            xirr: 0.0,
            volatility: 0.0,
            sharpeRatio: 0.0,
            maxDrawdown: 0.0,
            chartData: [],
            schemeName: '',
          ),
        ),
        inflationAdjusted: _safeFromJson<InflationAdjustedData>(
          json['inflation_adjusted'], 
          (data) => InflationAdjustedData.fromJson(data),
          () => InflationAdjustedData(
            finalValue: 0.0,
            gain: 0.0,
            sharpeRatio: 0.0,
            maxDrawdown: 0.0,
            xirr: 0.0,
          ),
        ),
        equity: _safeListFromJson<EquityScheme>(
          json['EQUITY'],
          (data) => EquityScheme.fromJson(data),
        ),
        debt: _safeListFromJson<DebtScheme>(
          json['DEBT'],
          (data) => DebtScheme.fromJson(data),
        ),
        taxDetails: _safeFromJson<TaxDetails>(
          json['tax_details'], 
          (data) => TaxDetails.fromJson(data),
          () => TaxDetails(
            equity: TaxCategory(tax: 0.0, postGainTotal: 0.0),
            debt: TaxCategory(tax: 0.0, postGainTotal: 0.0),
          ),
        ),
      );
    } catch (e) {
      print("Error parsing PortfolioAnalysisModel: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  static T _safeFromJson<T>(dynamic data, T Function(Map<String, dynamic>) fromJson, T Function() fallback) {
    if (data is Map<String, dynamic>) {
      try {
        return fromJson(data);
      } catch (e) {
        print("Error parsing $T: $e");
        return fallback();
      }
    }
    return fallback();
  }

  static List<T> _safeListFromJson<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List<dynamic>) {
      return data
          .where((e) => e is Map<String, dynamic>)
          .map((e) {
            try {
              return fromJson(e as Map<String, dynamic>);
            } catch (e) {
              print("Error parsing list item: $e");
              return null;
            }
          })
          .where((e) => e != null)
          .cast<T>()
          .toList();
    }
    return <T>[];
  }
}

class PortfolioTotal {
  final double investmentAmount;
  final double currentValue;
  final double gain;
  final double gainPerc;
  final double xirr;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final List<double> chartData;

  PortfolioTotal({
    required this.investmentAmount,
    required this.currentValue,
    required this.gain,
    required this.gainPerc,
    required this.xirr,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.chartData,
  });

  factory PortfolioTotal.fromJson(Map<String, dynamic> json) {
    return PortfolioTotal(
      investmentAmount: (json['investment_amount'] ?? 0.0).toDouble(),
      currentValue: (json['current_value'] ?? 0.0).toDouble(),
      gain: (json['gain'] ?? 0.0).toDouble(),
      gainPerc: (json['gain_perc'] ?? 0.0).toDouble(),
      xirr: (json['xirr'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      chartData: List<double>.from(json['chart_data'] ?? []),
    );
  }
}

class BenchmarkData {
  final double investmentAmount;
  final double currentValue;
  final double gain;
  final double gainPerc;
  final double xirr;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final List<double> chartData;
  final String schemeName;

  BenchmarkData({
    required this.investmentAmount,
    required this.currentValue,
    required this.gain,
    required this.gainPerc,
    required this.xirr,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.chartData,
    required this.schemeName,
  });

  factory BenchmarkData.fromJson(Map<String, dynamic> json) {
    return BenchmarkData(
      investmentAmount: (json['investment_amount'] ?? 0.0).toDouble(),
      currentValue: (json['current_value'] ?? 0.0).toDouble(),
      gain: (json['gain'] ?? 0.0).toDouble(),
      gainPerc: (json['gain_perc'] ?? 0.0).toDouble(),
      xirr: (json['xirr'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      chartData: List<double>.from(json['chart_data'] ?? []),
      schemeName: json['scheme_name'] ?? '',
    );
  }
}

class InflationAdjustedData {
  final double finalValue;
  final double gain;
  final double sharpeRatio;
  final double maxDrawdown;
  final double xirr;

  InflationAdjustedData({
    required this.finalValue,
    required this.gain,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.xirr,
  });

  factory InflationAdjustedData.fromJson(Map<String, dynamic> json) {
    return InflationAdjustedData(
      finalValue: (json['final_value'] ?? 0.0).toDouble(),
      gain: (json['gain'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      xirr: (json['xirr'] ?? 0.0).toDouble(),
    );
  }
}

class EquityScheme {
  final String schemaName;
  final int percentage;
  final double investmentAmount;
  final double currentValue;
  final double gain;
  final double gainPerc;
  final double xirr;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final List<double> chartData;

  EquityScheme({
    required this.schemaName,
    required this.percentage,
    required this.investmentAmount,
    required this.currentValue,
    required this.gain,
    required this.gainPerc,
    required this.xirr,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.chartData,
  });

  factory EquityScheme.fromJson(Map<String, dynamic> json) {
    return EquityScheme(
      schemaName: json['schema_name'] ?? '',
      percentage: json['percentage'] ?? 0,
      investmentAmount: (json['investment_amount'] ?? 0.0).toDouble(),
      currentValue: (json['current_value'] ?? 0.0).toDouble(),
      gain: (json['gain'] ?? 0.0).toDouble(),
      gainPerc: (json['gain_perc'] ?? 0.0).toDouble(),
      xirr: (json['xirr'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      chartData: List<double>.from(json['chart_data'] ?? []),
    );
  }
}

class DebtScheme {
  final String schemaName;
  final int percentage;
  final double investmentAmount;
  final double currentValue;
  final double gain;
  final double gainPerc;
  final double xirr;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final List<double> chartData;

  DebtScheme({
    required this.schemaName,
    required this.percentage,
    required this.investmentAmount,
    required this.currentValue,
    required this.gain,
    required this.gainPerc,
    required this.xirr,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.chartData,
  });

  factory DebtScheme.fromJson(Map<String, dynamic> json) {
    return DebtScheme(
      schemaName: json['schema_name'] ?? '',
      percentage: json['percentage'] ?? 0,
      investmentAmount: (json['investment_amount'] ?? 0.0).toDouble(),
      currentValue: (json['current_value'] ?? 0.0).toDouble(),
      gain: (json['gain'] ?? 0.0).toDouble(),
      gainPerc: (json['gain_perc'] ?? 0.0).toDouble(),
      xirr: (json['xirr'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      chartData: List<double>.from(json['chart_data'] ?? []),
    );
  }
}

class TaxDetails {
  final TaxCategory equity;
  final TaxCategory debt;

  TaxDetails({
    required this.equity,
    required this.debt,
  });

  factory TaxDetails.fromJson(Map<String, dynamic> json) {
    return TaxDetails(
      equity: TaxCategory.fromJson(json['EQUITY']),
      debt: TaxCategory.fromJson(json['DEBT']),
    );
  }
}

class TaxCategory {
  final double tax;
  final double postGainTotal;

  TaxCategory({
    required this.tax,
    required this.postGainTotal,
  });

  factory TaxCategory.fromJson(Map<String, dynamic> json) {
    return TaxCategory(
      tax: (json['tax'] ?? 0.0).toDouble(),
      postGainTotal: (json['post_gain_total'] ?? 0.0).toDouble(),
    );
  }
}

class BacktestRequest {
  final int yearIn;
  final double investmentAmount;
  final List<SchemeValue> schemeValues;
  final String compareSymbol;

  BacktestRequest({
    required this.yearIn,
    required this.investmentAmount,
    required this.schemeValues,
    required this.compareSymbol,
  });

  Map<String, dynamic> toJson() {
    return {
      'year_in': yearIn,
      'investment_amount': investmentAmount,
      'scheme_values': schemeValues.map((e) => e.toJson()).toList(),
      'compare_symbol': compareSymbol,
    };
  }
}

class SchemeValue {
  final String schemaName;
  final int percentage;
  final String schemeType;

  SchemeValue({
    required this.schemaName,
    required this.percentage,
    required this.schemeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'schema_name': schemaName,
      'percentage': percentage,
      'scheme_type': schemeType,
    };
  }
}
