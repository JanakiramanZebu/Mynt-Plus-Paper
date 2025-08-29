import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../api/core/api_export.dart';
import '../provider/core/default_change_notifier.dart';
import '../models/explore_model/portfolioanalisys_models.dart';

final dashboardProvider =
    ChangeNotifierProvider((ref) => DashboardProvider(ref));

class DashboardProvider extends DefaultChangeNotifier {
  final Preferences pref = locator<Preferences>();
  final ApiExporter api = locator<ApiExporter>();
  final Ref ref;

  DashboardProvider(this.ref);


  final TextEditingController _brokerageController = TextEditingController(text: '0.03');
  TextEditingController get brokerageController => _brokerageController;

  // Brokerage type persistence
  bool _isPercentageBrokerage = true;
  bool get isPercentageBrokerage => _isPercentageBrokerage;

  // Method to update brokerage type
  void updateBrokerageType(bool isPercentage) {
    _isPercentageBrokerage = isPercentage;
    // Also update the controller text based on type
    if (isPercentage) {
      _brokerageController.text = '0.03';
    } else {
      _brokerageController.text = '20';
    }
    notifyListeners();
  }

  // Method to get current brokerage type as string
  String get brokerageTypeText => _isPercentageBrokerage ? 'Percentage' : 'Flat';

  @override
  void dispose() {
    _brokerageController.dispose();
    super.dispose();
  }

  // Portfolio Analysis State

  PortfolioResponse? _portfolioAnalysis;
  PortfolioResponse? get portfolioAnalysis => _portfolioAnalysis;

  bool _isPortfolioLoading = false;
  bool get isPortfolioLoading => _isPortfolioLoading;

  portfolioloader(bool value) {
    _isPortfolioLoading = value;
    print("Portfolio Loading: $_isPortfolioLoading");
    notifyListeners();
  }

  String? _portfolioError;

  // Portfolio getters
  String? get portfolioError => _portfolioError;

  Future getPortfolioAnalysis() async {

    try {
      portfolioloader(true);
      final portfolioAnalysis =
          await api.fetchPortfolioAnalysis("${pref.clientId}", "${pref.clientSession}");

      _portfolioAnalysis = portfolioAnalysis;
      _portfolioError = null;
    } catch (e) {
      print("Portfolio Analysis Error: $e");
      _portfolioError = e.toString();
      rethrow;
    } finally {
      _portfolioError = null;
      portfolioloader(false);
      notifyListeners();
    }
  }

  // Portfolio Analysis Methods
  String getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  // // Update selected time period
  // void updateSelectedPeriod(String newPeriod) {
  //   selectedPeriod = newPeriod;
  //   notifyListeners();
  // }

  // Format amount for display
  String formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  // Get account type color
  Color getAccountTypeColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'equity':
        return Color(0xFF60A5FA); // Light blue
      case 'mutual funds':
        return Color(0xFF3B82F6); // Medium blue
      case 'bonds':
        return Color(0xFF1D4ED8); // Darker blue
      case 'cash':
        return Color(0xFF1E3A8A); // Darkest blue
      case 'commodities':
        return Color(0xFF0F172A); // Very dark blue
      default:
        // Use a blue color palette for other account types
        List<Color> blueColors = [
          Color(0xFF60A5FA), // Light blue
          Color(0xFF3B82F6), // Medium blue
          Color(0xFF1D4ED8), // Darker blue
          Color(0xFF1E3A8A), // Darkest blue
          Color(0xFF0F172A), // Very dark blue
        ];
        return blueColors[accountType.hashCode % blueColors.length];
    }
  }

  // Get account type icon
  IconData getAccountTypeIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'equity':
        return Icons.trending_up;
      case 'mutual funds':
        return Icons.account_balance;
      case 'bonds':
        return Icons.security;
      case 'cash':
        return Icons.account_balance_wallet;
      case 'commodities':
        return Icons.inventory;
      default:
        return Icons.account_balance;
    }
  }

  // Get sector allocation color
  Color getSectorAllocationColor(String sector) {
    switch (sector.toLowerCase()) {
      case 'financial services':
        return Color(0xFF60A5FA); // Light blue
      case 'industrial':
        return Color(0xFF3B82F6); // Medium blue
      case 'consumer cyclical':
        return Color(0xFF1D4ED8); // Darker blue
      case 'others':
        return Color(0xFF1E3A8A); // Darkest blue
      default:
        // Use a blue color palette for other sectors
        List<Color> blueColors = [
          Color(0xFF60A5FA), // Light blue
          Color(0xFF3B82F6), // Medium blue
          Color(0xFF1D4ED8), // Darker blue
          Color(0xFF1E3A8A), // Darkest blue
          Color(0xFF0F172A), // Very dark blue
        ];
        return blueColors[sector.hashCode % blueColors.length];
    }
  }

  // Get market cap allocation color
  Color getMarketCapAllocationColor(String marketCapType) {
    switch (marketCapType.toLowerCase()) {
      case 'large cap':
        return Color(0xFF60A5FA); // Light blue
      case 'mid cap':
        return Color(0xFF3B82F6); // Medium blue
      case 'small cap':
        return Color(0xFF1D4ED8); // Darker blue
      case 'others':
        return Color(0xFF1E3A8A); // Darkest blue
      default:
        // Use a blue color palette for other market cap types
        List<Color> blueColors = [
          Color(0xFF60A5FA), // Light blue
          Color(0xFF3B82F6), // Medium blue
          Color(0xFF1D4ED8), // Darker blue
          Color(0xFF1E3A8A), // Darkest blue
          Color(0xFF0F172A), // Very dark blue
        ];
        return blueColors[marketCapType.hashCode % blueColors.length];
    }
  }

  // Get market cap color
  Color getMarketCapColor(String capType) {
    final theme = ref.watch(themeProvider);
    switch (capType.toLowerCase()) {
      case 'large cap':
        return theme.isDarkMode ? colors.successDark : colors.successLight;
      case 'mid cap':
        return Color(0xFF1976D2);
      case 'small cap':
        return Color(0xFFFF7043);
      default:
        return Color(0xFF6C7B93);
    }
  }

  // Get sector color
  Color getSectorColor(String sector) {
    List<Color> colors = [
      Color(0xFF059B3C),
      Color(0xFF1976D2),
      Color(0xFFFF7043),
      Color(0xFF7B1FA2),
      Color(0xFF388E3C),
      Color(0xFFE64A19),
      Color(0xFF0288D1),
      Color(0xFF8E24AA),
      Color(0xFF43A047),
      Color(0xFFFFA726),
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
    ];
    return colors[sector.hashCode % colors.length];
  }
}
