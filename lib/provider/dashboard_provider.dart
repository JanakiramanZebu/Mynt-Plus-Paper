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
    _portfolioSearchController.dispose();
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

  clearPortfolioAnalysis() {
    _portfolioAnalysis = null;
    notifyListeners();
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

 final Map<String, Color> _sectorColorMap = {};

Color getSectorAllocationColor(String sector) {
 List<Color> uniqueColors = [
  Color(0xFF1ABC9C), // Teal
  Color(0xFF27AE60), // Emerald Green
  Color(0xFF2980B9), // Strong Blue
  Color(0xFF9B59B6), // Purple
  Color(0xFFE67E22), // Orange
  Color(0xFFE74C3C), // Red
  Color(0xFFF1C40F), // Yellow
  Color(0xFF34495E), // Dark Blue Gray
  Color(0xFF16A085), // Dark Cyan
  // Color(0xFF8E44AD), // Deep Violet
  Color(0xFFD35400), // Burnt Orange
  Color(0xFF2C3E50), // Navy Blue
  Color(0xFF7D3C98), // Violet
  Color(0xFF229954), // Forest Green
  Color(0xFFCA6F1E), // Amber Brown
  Color(0xFF117A65), // Sea Green
];


  // If already assigned, return it
  if (_sectorColorMap.containsKey(sector)) {
    return _sectorColorMap[sector]!;
  }

  // Assign next available color
  final color = uniqueColors[_sectorColorMap.length % uniqueColors.length];
  _sectorColorMap[sector] = color;

  return color;
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
        return Color(0xFF1E3A8A); // Darkest blue
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

  // Portfolio Search State Management
  bool _showPortfolioSearch = false;
  bool get showPortfolioSearch => _showPortfolioSearch;

  final TextEditingController _portfolioSearchController = TextEditingController();
  TextEditingController get portfolioSearchController => _portfolioSearchController;

  List<TopStocks> _portfolioSearchItems = [];
  List<TopStocks> get portfolioSearchItems => _portfolioSearchItems;

  // Show/hide portfolio search
   showPortfolioAnalysisSearch(bool value) {
    _showPortfolioSearch = value;
    if (!_showPortfolioSearch) {
      _portfolioSearchItems = [];
    }
    _portfolioSearchController.clear();
    notifyListeners();
  }

  // Clear portfolio search
   clearPortfolioSearch() {
    _portfolioSearchController.clear();
    _portfolioSearchItems = [];
    // Don't automatically hide search - let the UI handle it
    notifyListeners();
  }

  // Search portfolio holdings
  void searchPortfolioHoldings(String query, List<TopStocks> allHoldings) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _portfolioSearchItems = [];
    } else {
      _portfolioSearchItems = allHoldings.where((holding) {
        final name = holding.name?.toLowerCase() ?? '';
        final tsym = holding.tsym?.toLowerCase() ?? '';
        final queryLower = trimmedQuery.toLowerCase();
        
        return name.contains(queryLower) || tsym.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  // Portfolio Filter State Management
  bool _showAll = true; // Default: show all data
  bool get showAll => _showAll;

  Set<String> _selectedAccountTypes = {};
  Set<String> get selectedAccountTypes => _selectedAccountTypes;

  Set<String> _selectedMarketCaps = {};
  Set<String> get selectedMarketCaps => _selectedMarketCaps;

  Set<String> _selectedSectors = {};
  Set<String> get selectedSectors => _selectedSectors;

  // Update filter states
  void updateShowAll(bool value) {
    _showAll = value;
    if (_showAll) {
      _selectedAccountTypes.clear();
      _selectedMarketCaps.clear();
      _selectedSectors.clear();
    }
    notifyListeners();
  }

  void updateSelectedAccountTypes(Set<String> accountTypes) {
    _selectedAccountTypes = accountTypes;
    if (_selectedAccountTypes.isNotEmpty || _selectedMarketCaps.isNotEmpty || _selectedSectors.isNotEmpty) {
      _showAll = false;
    } else {
      _showAll = true;
    }
    notifyListeners();
  }

  void updateSelectedMarketCaps(Set<String> marketCaps) {
    _selectedMarketCaps = marketCaps;
    if (_selectedAccountTypes.isNotEmpty || _selectedMarketCaps.isNotEmpty || _selectedSectors.isNotEmpty) {
      _showAll = false;
    } else {
      _showAll = true;
    }
    notifyListeners();
  }

  void updateSelectedSectors(Set<String> sectors) {
    _selectedSectors = sectors;
    if (_selectedAccountTypes.isNotEmpty || _selectedMarketCaps.isNotEmpty || _selectedSectors.isNotEmpty) {
      _showAll = false;
    } else {
      _showAll = true;
    }
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _showAll = true;
    _selectedAccountTypes.clear();
    _selectedMarketCaps.clear();
    _selectedSectors.clear();
    notifyListeners();
  }

  // Get filtered holdings based on selected filters
  List<TopStocks> getFilteredHoldings(List<TopStocks> allHoldings) {
    if (_showAll || (_selectedAccountTypes.isEmpty && 
        _selectedMarketCaps.isEmpty && 
        _selectedSectors.isEmpty)) {
      return allHoldings; // Show all when "All" is selected or no filters applied
    }

    // Build a quick lookup from tsym -> sector from fundamentals
    final fundamentals = _portfolioAnalysis?.fundamentals ?? [];
    final Map<String, String> tsymToSector = {
      for (final f in fundamentals)
        if ((f.tsym ?? '').isNotEmpty && (f.sector ?? '').isNotEmpty)
          f.tsym!: f.sector!
    };

    return allHoldings.where((holding) {
      // Filter by category (account type) with normalization so
      // 'Gold' matches categories like 'Gold_Bond', 'Gold ETF', etc.
      final holdingCategoryNorm = _normalize(holding.category);
      bool matchesAccountType = _selectedAccountTypes.isEmpty ||
          _selectedAccountTypes.any(
            (seg) => holdingCategoryNorm.contains(_normalize(seg)),
          );
      
      // Filter by market cap type
      bool matchesMarketCap = _selectedMarketCaps.isEmpty || 
          _selectedMarketCaps.contains(holding.marketCapType);
      
      // Sector filtering: infer sector via fundamentals using tsym
      final holdingSector = tsymToSector[holding.tsym ?? ''];
      final holdingSectorNorm = _normalize(holdingSector);
      bool matchesSector = _selectedSectors.isEmpty ||
          _selectedSectors.any(
            (s) => holdingSectorNorm.contains(_normalize(s)),
          );
      
      return matchesAccountType && matchesMarketCap && matchesSector;
    }).toList();
  }

  // Normalizes strings for robust comparisons (case-insensitive, ignore spaces/underscores/hyphens)
  String _normalize(String? input) {
    return (input ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Helper methods for filter state checking
  bool isAccountTypeSelected(String accountType) {
    return _selectedAccountTypes.contains(accountType);
  }

  bool isMarketCapSelected(String marketCap) {
    return _selectedMarketCaps.contains(marketCap);
  }

  bool isSectorSelected(String sector) {
    return _selectedSectors.contains(sector);
  }

  // Toggle filter methods
  void toggleAccountType(String accountType) {
    if (_selectedAccountTypes.contains(accountType)) {
      _selectedAccountTypes.remove(accountType);
    } else {
      _selectedAccountTypes.add(accountType);
    }
    _updateShowAllState();
    notifyListeners();
  }

  void toggleMarketCap(String marketCap) {
    if (_selectedMarketCaps.contains(marketCap)) {
      _selectedMarketCaps.remove(marketCap);
    } else {
      _selectedMarketCaps.add(marketCap);
    }
    _updateShowAllState();
    notifyListeners();
  }

  void toggleSector(String sector) {
    if (_selectedSectors.contains(sector)) {
      _selectedSectors.remove(sector);
    } else {
      _selectedSectors.add(sector);
    }
    _updateShowAllState();
    notifyListeners();
  }

  // Remove specific filter
  void removeFilter(String label, String filterType) {
    switch (filterType) {
      case 'accountType':
        _selectedAccountTypes.remove(label);
        break;
      case 'marketCap':
        _selectedMarketCaps.remove(label);
        break;
      case 'sector':
        _selectedSectors.remove(label);
        break;
    }
    _updateShowAllState();
    notifyListeners();
  }

  // Apply portfolio filters (placeholder method for screen compatibility)
  void applyPortfolioFilters() {
    // This method is called from the screen but doesn't need to do anything
    // as the filtering is handled automatically through the getFilteredHoldings method
    notifyListeners();
  }

  // Check if a holding passes the current filters
  bool isHoldingFiltered(TopStocks holding) {
    if (_showAll || (_selectedAccountTypes.isEmpty && 
        _selectedMarketCaps.isEmpty && 
        _selectedSectors.isEmpty)) {
      return true; // Show all when no filters applied
    }

    // Build a quick lookup from tsym -> sector from fundamentals
    final fundamentals = _portfolioAnalysis?.fundamentals ?? [];
    final Map<String, String> tsymToSector = {
      for (final f in fundamentals)
        if ((f.tsym ?? '').isNotEmpty && (f.sector ?? '').isNotEmpty)
          f.tsym!: f.sector!
    };

    // Filter by category (account type) with normalization
    final holdingCategoryNorm = _normalize(holding.category);
    bool matchesAccountType = _selectedAccountTypes.isEmpty ||
        _selectedAccountTypes.any(
          (seg) => holdingCategoryNorm.contains(_normalize(seg)),
        );
    
    // Filter by market cap type
    bool matchesMarketCap = _selectedMarketCaps.isEmpty || 
        _selectedMarketCaps.contains(holding.marketCapType);
    
    // Sector filtering: infer sector via fundamentals using tsym
    final holdingSector = tsymToSector[holding.tsym ?? ''];
    final holdingSectorNorm = _normalize(holdingSector);
    bool matchesSector = _selectedSectors.isEmpty ||
        _selectedSectors.any(
          (s) => holdingSectorNorm.contains(_normalize(s)),
        );
    
    return matchesAccountType && matchesMarketCap && matchesSector;
  }

  // Helper method to update showAll state based on other filters
  void _updateShowAllState() {
    if (_selectedAccountTypes.isEmpty && _selectedMarketCaps.isEmpty && _selectedSectors.isEmpty) {
      _showAll = true;
    } else {
      _showAll = false;
    }
  }
  // Brokerage Calculator Methods
  Map<String, double> calculateBrokerageCharges({
    required int segment,
    required int subSegment,
    required double quantity,
    required double buyPrice,
    required double sellPrice,
  }) {
    final brokerageRate = double.tryParse(_brokerageController.text) ?? 0;
    final turnover = (buyPrice + sellPrice) * quantity;
    
    return _getChargesForSegment(
      segment,
      subSegment,
      quantity,
      buyPrice,
      sellPrice,
      turnover,
      brokerageRate,
    );
  }

  Map<String, double> _getChargesForSegment(
      int segment,
      int subSegment,
      double quantity,
      double buyPrice,
      double sellPrice,
      double turnover,
      double brokerageRate) {
    double brokerage = _isPercentageBrokerage
        ? (turnover * brokerageRate) / 100
        : brokerageRate;

    double stt = 0, ctt = 0, transactionCharges = 0, stampDuty = 0;

    switch (segment) {
      case 0: // Equity
        if (subSegment == 0) {
          // Intraday
          stt = (sellPrice * quantity * 0.025) / 100;
          transactionCharges = (turnover * 0.00297) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        } else {
          // Delivery
          stt = (turnover * 0.1) / 100;
          transactionCharges = (turnover * 0.00297) / 100;
          stampDuty = (buyPrice * quantity * 0.015) / 100;
        }
        break;
      case 1: // F&O
        if (subSegment == 0) {
          // Futures
          stt = (sellPrice * quantity * 0.02) / 100;
          transactionCharges = (turnover * 0.00173) / 100;
          stampDuty = (buyPrice * quantity * 0.002) / 100;
        } else {
          // Options
          stt = (sellPrice * quantity * 0.1) / 100;
          transactionCharges = (turnover * 0.035) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        }
        break;
      case 2: // Currency
        transactionCharges = subSegment == 0
            ? (turnover * 0.00035) / 100
            : (turnover * 0.03110) / 100;
        stampDuty = (buyPrice * quantity * 0.0001) / 100;
        break;
      case 3: // Commodity
        if (subSegment == 0) {
          // Non-Agri
          ctt = (sellPrice * quantity * 0.01) / 100;
          transactionCharges = (turnover * 0.0021) / 100;
          stampDuty = (buyPrice * quantity * 0.002) / 100;
        } else if (subSegment == 1) {
          // Agri
          transactionCharges = (turnover * 0.0021) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        } else {
          // Options
          ctt = (sellPrice * quantity * 0.041) / 100;
          transactionCharges = (turnover * 0.04180) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        }
        break;
    }

    double sebiCharges = (turnover * 0.0001) / 100;
    double gst = ((brokerage + transactionCharges + sebiCharges) * 18) / 100;
    double totalTaxes =
        brokerage + stt + ctt + transactionCharges + sebiCharges + gst;
    double totalCharges = totalTaxes + stampDuty;
    double netProfit =
        (sellPrice * quantity) - (buyPrice * quantity) - totalCharges;
    double breakEven = totalCharges / quantity;

    return {
      'turnover': turnover,
      'brokerage': brokerage,
      'stt': stt,
      'ctt': ctt,
      'transactionCharges': transactionCharges,
      'sebiCharges': sebiCharges,
      'gst': gst,
      'stampDuty': stampDuty,
      'totalCharges': totalCharges,
      'netProfit': netProfit,
      'breakEven': breakEven,
    };
  }

final TextEditingController _investmentController = TextEditingController(text: '1,00,000');
  final TextEditingController _searchController = TextEditingController();
  
  TextEditingController get investmentController => _investmentController;
  TextEditingController get searchController => _searchController;

  // Strategy State
  List<FundModel> _selectedFunds = [];
  List<FundModel> get selectedFunds => _selectedFunds;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  String _selectedInvestmentType = 'One-time';
  String get selectedInvestmentType => _selectedInvestmentType;

  String _selectedDuration = '3Y';
  String get selectedDuration => _selectedDuration;

  String _selectedStrategyType = 'Buy and Hold';
  String get selectedStrategyType => _selectedStrategyType;

  bool _isStrategyLoading = false;
  bool get isStrategyLoading => _isStrategyLoading;

  String? _strategyError;
  String? get strategyError => _strategyError;

  // Static fund list based on your images
  final List<FundModel> _staticFunds = [
    FundModel(
      name: 'SBI Nifty 50 ETF',
      type: 'Equity',
      fiveYearCAGR: 17.7,
      threeYearCAGR: 13.19,
      aum: 20815.73,
      sharpe: 0.8,
    ),
    FundModel(
      name: 'SBI BSE Sensex ETF',
      type: 'Equity',
      fiveYearCAGR: 16.82,
      threeYearCAGR: 12.29,
      aum: 11725.54,
      sharpe: 0.74,
    ),
    FundModel(
      name: 'Parag Parikh Flexi Cap Fund - Regular Plan',
      type: 'Equity',
      fiveYearCAGR: 21.77,
      threeYearCAGR: 20.49,
      aum: 11328.67,
      sharpe: 1.23,
    ),
    FundModel(
      name: 'HDFC Balanced Advantage Fund - Regular Plan',
      type: 'Hybrid',
      fiveYearCAGR: 22.34,
      threeYearCAGR: 18.24,
      aum: 10772.60,
      sharpe: 1.4,
    ),
    FundModel(
      name: 'Aditya Birla Sun Life Liquid Fund - Direct Plan',
      type: 'Debt',
      fiveYearCAGR: 5.73,
      threeYearCAGR: 7.13,
      aum: 51915.25,
      sharpe: 1.59,
    ),
    FundModel(
      name: 'ICICI Prudential Large Cap Fund',
      type: 'Equity',
      fiveYearCAGR: 25.54,
      threeYearCAGR: 21.63,
      aum: 5375.52,
      sharpe: 1.41,
    ),
  ];

  List<FundModel> get staticFunds => _staticFunds;

  // Loading state management
  strategyLoader(bool value) {
    _isStrategyLoading = value;
    print("Strategy Loading: $_isStrategyLoading");
    notifyListeners();
  }

  // Fund Management Methods
  void addFundToStrategy(FundModel fund) {
    if (!_selectedFunds.any((f) => f.name == fund.name)) {
      final newFund = FundModel(
        name: fund.name,
        type: fund.type,
        fiveYearCAGR: fund.fiveYearCAGR,
        threeYearCAGR: fund.threeYearCAGR,
        aum: fund.aum,
        sharpe: fund.sharpe,
      );
      _selectedFunds.add(newFund);
      _redistributePercentages();
      notifyListeners();
    }
  }

  void removeFundFromStrategy(FundModel fund) {
    _selectedFunds.removeWhere((f) => f.name == fund.name);
    _redistributePercentages();
    notifyListeners();
  }

  void updateFundPercentage(FundModel fund, double percentage) {
    final index = _selectedFunds.indexWhere((f) => f.name == fund.name);
    if (index != -1) {
      _selectedFunds[index].percentage = percentage;
      notifyListeners();
    }
  }

  void _redistributePercentages() {
    if (_selectedFunds.isEmpty) return;
    
    final equalPercentage = 100.0 / _selectedFunds.length;
    for (int i = 0; i < _selectedFunds.length; i++) {
      _selectedFunds[i].percentage = i == _selectedFunds.length - 1 
          ? 100.0 - (equalPercentage * (_selectedFunds.length - 1))
          : equalPercentage;
    }
  }

  void clearStrategy() {
    _selectedFunds.clear();
    _searchController.clear();
    _selectedFilter = 'All';
    notifyListeners();
  }

  // Filter and Search Methods
  void updateSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<FundModel> getFilteredFunds() {
    List<FundModel> funds = List.from(_staticFunds);
    
    // Apply filter
    if (_selectedFilter != 'All') {
      funds = funds.where((fund) => fund.type == _selectedFilter).toList();
    }
    
    // Apply search
    if (_searchController.text.isNotEmpty) {
      funds = funds.where((fund) => 
        fund.name.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return funds;
  }

  bool isFundSelected(FundModel fund) {
    return _selectedFunds.any((f) => f.name == fund.name);
  }

  // Investment Configuration Methods
  void updateInvestmentType(String type) {
    _selectedInvestmentType = type;
    notifyListeners();
  }

  void updateDuration(String duration) {
    _selectedDuration = duration;
    notifyListeners();
  }

  void updateStrategyType(String type) {
    _selectedStrategyType = type;
    notifyListeners();
  }

  // Getters
  double get totalPercentage => _selectedFunds.fold(0.0, (sum, fund) => sum + fund.percentage);
  
  bool get isStrategyValid => totalPercentage == 100.0 && _selectedFunds.isNotEmpty;

  // Format amount for display (following your pattern)
  // String formatAmount(double amount) {
  //   if (amount >= 10000000) {
  //     return '${(amount / 10000000).toStringAsFixed(2)}Cr';
  //   } else if (amount >= 100000) {
  //     return '${(amount / 100000).toStringAsFixed(2)}L';
  //   } else if (amount >= 1000) {
  //     return '${(amount / 1000).toStringAsFixed(2)}K';
  //   } else {
  //     return amount.toStringAsFixed(2);
  //   }
  // }

  // Fund Type Helpers
  Color getFundTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'equity':
        return colors.colorBlue;
      case 'debt':
        return colors.successLight;
      case 'hybrid':
        return colors.KColorLightBlueBg;
      case 'commodities':
        return colors.colorbluegrey;
      default:
        return colors.textSecondaryLight;
    }
  }

  IconData getFundTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'equity':
        return Icons.trending_up;
      case 'debt':
        return Icons.account_balance;
      case 'hybrid':
        return Icons.pie_chart;
      case 'commodities':
        return Icons.landscape;
      default:
        return Icons.monetization_on;
    }
  }

  // Save Strategy Method
  Future<void> saveStrategy() async {
    try {
      strategyLoader(true);
      
      // Here you would call your API to save the strategy
      // await api.saveStrategy(strategyData);
      
      // For now, just simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _strategyError = null;
      print("Strategy saved successfully");
      
    } catch (e) {
      print("Strategy Save Error: $e");
      _strategyError = e.toString();
      rethrow;
    } finally {
      _strategyError = null;
      strategyLoader(false);
      notifyListeners();
    }
  }

  // @override
  // void dispose() {
  //   _investmentController.dispose();
  //   _searchController.dispose();
  //   super.dispose();
  // }
}

// Fund Model
class FundModel {
  final String name;
  final String type;
  final double fiveYearCAGR;
  final double threeYearCAGR;
  final double aum;
  final double sharpe;
  double percentage;

  FundModel({
    required this.name,
    required this.type,
    required this.fiveYearCAGR,
    required this.threeYearCAGR,
    required this.aum,
    required this.sharpe,
    this.percentage = 0.0,
  });
}
