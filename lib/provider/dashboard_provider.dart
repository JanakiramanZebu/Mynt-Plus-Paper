import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/models/trading_personality_model.dart';
import 'package:mynt_plus/models/mf_model/sip_mf_list_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../api/core/api_export.dart';
import '../models/explore_model/referral_rewards_model.dart';
import '../provider/core/default_change_notifier.dart';
import '../models/explore_model/portfolioanalisys_models.dart';

final dashboardProvider =
    ChangeNotifierProvider((ref) => DashboardProvider(ref));

class DashboardProvider extends DefaultChangeNotifier {
  final Preferences pref = locator<Preferences>();
  final ApiExporter api = locator<ApiExporter>();
  final Ref ref;

  DashboardProvider(this.ref);

  final TextEditingController _brokerageController =
      TextEditingController(text: '0.03');
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
  String get brokerageTypeText =>
      _isPercentageBrokerage ? 'Percentage' : 'Flat';

  @override
  void dispose() {
    _brokerageController.dispose();
    _portfolioSearchController.dispose();

    // Dispose of all percentage controllers
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    _percentageControllers.clear();

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
      final portfolioAnalysis = await api.fetchPortfolioAnalysis(
          "${pref.clientId}", "${pref.clientSession}");
    if(portfolioAnalysis.message == "No data found"){
      _portfolioAnalysis = null;
      return;
    }
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

  ReferralRewards? _referralRewards;
  ReferralRewards? get referralRewards => _referralRewards;

  bool _isReferralRewardsLoading = false;
  bool get isReferralRewardsLoading => _isReferralRewardsLoading;

  referralRewardsloder(bool value) {
    _isReferralRewardsLoading = value;
    notifyListeners();
  } 

  Future getReferralRewards() async {
    try {
      referralRewardsloder(true);
      final referralRewards = await api.fetchReferralBonus('ZC91');
      _referralRewards = referralRewards;
      notifyListeners();
    } catch (e) {
      print("Referral Rewards Error: $e");
      _referralRewards = null;
      rethrow;
    } finally {
      referralRewardsloder(false);
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

  final Map<String, Color> _sectorColorMap = {};

Color getSectorAllocationColor(String sector) {
 List<Color> uniqueColors = [
  Color(0xFF4F46E5), // Indigo - professional
  Color(0xFF059669), // Emerald - growth
  Color(0xFFDC2626), // Red - energy
  Color(0xFF7C3AED), // Purple - unique
  Color(0xFFEA580C), // Orange - warm
  Color(0xFF0891B2), // Cyan - tech
  Color(0xFFCA8A04), // Amber - stable
  Color(0xFFBE185D), // Pink - creative
  Color(0xFF0D9488), // Teal - balance
  Color(0xFF9333EA), // Violet - premium
  Color(0xFF16A34A), // Green - nature
  Color(0xFFDC2626), // Red - finance
  Color(0xFF2563EB), // Blue - trust
  Color(0xFF7C2D12), // Brown - industrial
  Color(0xFF1F2937), // Gray - neutral
  Color(0xFF059669), // Green - healthcare
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
        return Color(0xFF4F46E5); // Indigo - professional and trustworthy
      case 'mid cap':
        return Color(0xFF059669); // Emerald - growth and stability
      case 'small cap':
        return Color(0xFFDC2626); // Red - energy and potential
      case 'others':
        return Color(0xFF7C3AED); // Purple - unique and diverse
      default:
        return Color(0xFF6B7280); // Gray - neutral fallback
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

  final TextEditingController _portfolioSearchController =
      TextEditingController();
  TextEditingController get portfolioSearchController =>
      _portfolioSearchController;

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

  // Quick PnL sign filter for Top Gainers / Top Losers
  // Values: 'all' | 'gainers' | 'losers'
  String _selectedPnLSignFilter = 'all';
  String get selectedPnLSignFilter => _selectedPnLSignFilter;
  void setPnLSignFilter(String value) {
    if (value == _selectedPnLSignFilter) {
      // Toggle off when pressing the same filter again
      _selectedPnLSignFilter = 'all';
    } else {
      _selectedPnLSignFilter = value;
    }
    notifyListeners();
  }

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
    if (_selectedAccountTypes.isNotEmpty ||
        _selectedMarketCaps.isNotEmpty ||
        _selectedSectors.isNotEmpty) {
      _showAll = false;
    } else {
      _showAll = true;
    }
    notifyListeners();
  }

  void updateSelectedMarketCaps(Set<String> marketCaps) {
    _selectedMarketCaps = marketCaps;
    if (_selectedAccountTypes.isNotEmpty ||
        _selectedMarketCaps.isNotEmpty ||
        _selectedSectors.isNotEmpty) {
      _showAll = false;
    } else {
      _showAll = true;
    }
    notifyListeners();
  }

  void updateSelectedSectors(Set<String> sectors) {
    _selectedSectors = sectors;
    if (_selectedAccountTypes.isNotEmpty ||
        _selectedMarketCaps.isNotEmpty ||
        _selectedSectors.isNotEmpty) {
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
    _selectedPnLSignFilter = 'all';
    notifyListeners();
  }

  // Get filtered holdings based on selected filters
  List<TopStocks> getFilteredHoldings(List<TopStocks> allHoldings) {
    if (_showAll ||
        (_selectedAccountTypes.isEmpty &&
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
    return (input ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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
    if (_showAll ||
        (_selectedAccountTypes.isEmpty &&
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
    if (_selectedAccountTypes.isEmpty &&
        _selectedMarketCaps.isEmpty &&
        _selectedSectors.isEmpty) {
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

// MF Basket Collection

  final TextEditingController _investmentController = TextEditingController(text: '100000');
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _strategyNameController = TextEditingController();
  TextEditingController get investmentController => _investmentController;
  TextEditingController get searchController => _searchController;
  TextEditingController get strategyNameController => _strategyNameController;
  // Strategy State basket
  List<FundListModel> _selectedFunds = [];
  List<FundListModel> get selectedFunds => _selectedFunds;

  // Trading Personality Selection
  TradingPersonalityType _selectedPersonality = TradingPersonalityType.aurora;
  TradingPersonalityType get selectedPersonality => _selectedPersonality;
  
  void updateSelectedPersonality(TradingPersonalityType personality) {
    _selectedPersonality = personality;
    notifyListeners();
  }

  // Strategy Name Error Management
  String? _strategyNameError;
  String? get strategyNameError => _strategyNameError;
  
  void setStrategyNameError(String? error) {
    _strategyNameError = error;
    notifyListeners();
  }
  
  void clearStrategyNameError() {
    _strategyNameError = null;
    notifyListeners();
  }

  // Saved Strategies
  SavedStrategyModel? _savedStrategies;
  SavedStrategyModel? get savedStrategies => _savedStrategies;

  // Edit mode tracking
  SavedStrategyModel? _editingStrategy;
  SavedStrategyModel? get editingStrategy => _editingStrategy;
  bool get isEditingMode => _editingStrategy != null;

  // Text controllers for percentage input fields
  Map<String, TextEditingController> _percentageControllers = {};
  Map<String, TextEditingController> get percentageControllers {
    _initializeControllers();
    return _percentageControllers;
  }

  // Initialize controllers for existing funds
  void _initializeControllers() {
    for (final fund in _selectedFunds) {
      if (!_percentageControllers.containsKey(fund.name)) {
        _percentageControllers[fund.name] = TextEditingController(
          text: fund.percentage.round().toString(),
        );
      }
    }
  }

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

  // Loading state management
  strategyLoader(bool value) {
    _isStrategyLoading = value;
    print("Strategy Loading: $_isStrategyLoading");
    notifyListeners();
  }

  Future<void> saveStrategy(String strategyName, BuildContext context) async {
    await createStrategy(strategyName, context);
  }

  Future<SavedStrategyModel> fetchbasketlist() async {
    try {
      strategyLoader(true);
      final responese = await api.fetchbasketlist();
      _savedStrategies = responese;
      return responese;
    } catch (e) {
      print("fetchbasketlist Error: $e");
      rethrow;
    } finally {
      strategyLoader(false);
      notifyListeners();
    }
  }

  Future<void> updateStrategy(BuildContext context) async {
    if (_editingStrategy == null || _selectedFunds.isEmpty ) 
    {
      error(context, "Please add funds to the strategy");
      return;
    }

    try {
      strategyLoader(true);

      final uuid = _editingStrategy!.data?.first.uuid ?? '';
      final schemaValues = _convertFundsToSchemaValues(_selectedFunds);

      await api.updatebasketsStrategy(
        uuid: uuid,
        yearIn: _getYearInFromDuration(_selectedDuration),
        schemeValues: schemaValues,
        basketName: strategyNameController.text ?? '',
        investmentAmount: double.tryParse(_investmentController.text) ?? 0.0,
        invesmentdetail: 'Updated Strategy|personality:${_selectedPersonality.name}',
      );

      await fetchbasketlist();
       Navigator.pop(context);
      Navigator.pop(context);

      _editingStrategy = null;
      _strategyError = null;
    } catch (e) {
      print("Update Strategy Error: $e");
      // error(context, "Failed to update strategy. Please try again.");
      // _strategyError = e.toString();
      rethrow;
    } finally {
      strategyLoader(false);
      notifyListeners();
    }
  }

  Future<void> createStrategy(String basketName, BuildContext context) async {
    if (_selectedFunds.isEmpty || basketName.isEmpty) 
    {
      error(context, "Please add funds to the strategy");
      return;
    }

    try {
      strategyLoader(true);

      final schemaValues = _convertFundsToSchemaValues(_selectedFunds);

      await api.createbasketsStrategy(
        yearIn: _getYearInFromDuration(_selectedDuration),
        schemeValues: schemaValues,
        basketName: basketName,
        investmentAmount: double.tryParse(_investmentController.text) ?? 0.0,
        invesmentdetail: 'Created Strategy|personality:${_selectedPersonality.name}',
      );

      await fetchbasketlist();

      _editingStrategy = null;
      _strategyError = null;
    } catch (e) {
      print("Create Strategy Error: $e");
      rethrow;
    } finally {
      strategyLoader(false);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _convertFundsToSchemaValues(
      List<FundListModel> funds) {
    return funds
        .map((fund) => {
              'name': fund.name,
              'schema_name': fund.schemeName,
              'scheme_type': fund.type,
              'percentage': fund.percentage.round(),
              'isin': fund.isin ?? '',
              'aMCCode': fund.aMCCode ?? '',
              'aum': fund.aum,
            })
        .toList();
  }

  int _getYearInFromDuration(String duration) {
    switch (duration) {
      case '1Y':
        return 1;
      case '3Y':
        return 3;
      case '5Y':
        return 5;
      case '10Y':
        return 10;
      case 'Custom':
        return 3; // Default to 3 years for custom
      default:
        return 3;
    }
  }

  Future<void> deleteStrategy(String strategyId, BuildContext context) async {
    try {
      strategyLoader(true);
      final response = await api.deletebasketsStrategy(strategyId);
      if (response.statusCode == 200) {
        successMessage(context, "Strategy deleted successfully");
        await fetchbasketlist();
      } else {
        warningMessage(context, "Strategy deletion failed");
      }
      _editingStrategy = null;
      _strategyError = null;
      notifyListeners();
    } finally {
      strategyLoader(false);
    }
  }

  void loadStrategy(Data strategyData) {
    clearStrategy();

    _editingStrategy = SavedStrategyModel(
      msg: "Loading strategy",
      data: [strategyData],
    );

    // Convert schema values to FundListModel
    _selectedFunds.clear();
    if (strategyData.schemaValues != null) {
      for (final schema in strategyData.schemaValues!) {
        final fund = FundListModel(
          name: schema.name ?? '',
          schemeName: schema.schemaName ?? '',
          type: schema.schemeType ?? '',
          fiveYearCAGR: 0.0, // Default value since not available in schema
          threeYearCAGR: 0.0, // Default value since not available in schema
          aum: schema.aum?.toDouble() ?? 0.0, // Default value since not available in schema
          sharpe: 0.0, // Default value since not available in schema
          percentage: schema.percentage?.toDouble() ?? 0.0,
          isin: schema.isin ?? '',
          aMCCode: schema.aMCCode ?? '',
        );
        _selectedFunds.add(fund);
      }
    }
    _strategyNameController.text = strategyData.basketName ?? '';
    _investmentController.text = strategyData.investAmount?.toString() ?? '0';

    // Load trading personality information from investment details
    _selectedPersonality = getPersonalityFromInvestmentDetails(strategyData.investmentDetails);

    if (strategyData.years != null) {
      if (strategyData.years! <= 1) {
        _selectedDuration = '1Y';
      } else if (strategyData.years! <= 3) {
        _selectedDuration = '3Y';
      } else if (strategyData.years! <= 5) {
        _selectedDuration = '5Y';
      } else {
        _selectedDuration = '10Y';
      }
    }

    _initializeControllers();
    notifyListeners();
  }

  void addFundToStrategy(FundListModel fund) {
    if (!_selectedFunds.any((f) => f.name == fund.name)) {
      final newFund = FundListModel(
        name: fund.name,
        schemeName: fund.schemeName,
        type: fund.type,
        fiveYearCAGR: fund.fiveYearCAGR,
        threeYearCAGR: fund.threeYearCAGR,
        aum: fund.aum,
        sharpe: fund.sharpe,
        aMCCode: fund.aMCCode,
        isin: fund.isin,
      );
      _selectedFunds.add(newFund);

      _percentageControllers[newFund.name] = TextEditingController(
        text: newFund.percentage.round().toString(),
      );

      _redistributePercentages();
      _updateAllControllerValues();
      notifyListeners();
    }
  }

  void removeFundFromStrategy(FundListModel fund) {
    _selectedFunds.removeWhere((f) => f.name == fund.name);

    _percentageControllers[fund.name]?.dispose();
    _percentageControllers.remove(fund.name);

    _redistributePercentages();
    _updateAllControllerValues();
    notifyListeners();
  }

  void toggleFundLock(FundListModel fund, BuildContext context) {
    final index = _selectedFunds.indexWhere((f) => f.name == fund.name);
    if (index != -1) {
      // Check if trying to lock and there's only one fund
      if (!_selectedFunds[index].isLocked && _selectedFunds.length == 1) {
        error(context, "You need at least 2 funds to lock percentages");
        return;
      }
      
      // Check if trying to lock and all other funds are already locked
      if (!_selectedFunds[index].isLocked) {
        final lockedCount = _selectedFunds.where((f) => f.isLocked).length;
        if (lockedCount >= _selectedFunds.length - 1) {
          error(context, "Cannot lock all funds");
         
          return;
        }
      }
      
      _selectedFunds[index].isLocked = !_selectedFunds[index].isLocked;
      notifyListeners();
    }
  }

  void updateFundPercentage(FundListModel fund, double percentage) {
    final index = _selectedFunds.indexWhere((f) => f.name == fund.name);
    if (index != -1) {
      final roundedPercentage = percentage.round().clamp(0, 100).toDouble();
      _selectedFunds[index].percentage = roundedPercentage;

      _percentageControllers[fund.name]?.text =
          roundedPercentage.round().toString();

      _autoRedistributePercentages(index);
      notifyListeners();
    }
  }

  void _autoRedistributePercentages(int changedIndex) {
    if (_selectedFunds.length <= 1) return;

    final changedFund = _selectedFunds[changedIndex];
    
    // Get locked funds total percentage (excluding the changed fund if it's locked)
    double lockedPercentage = 0.0;
    for (int i = 0; i < _selectedFunds.length; i++) {
      if (i != changedIndex && _selectedFunds[i].isLocked) {
        lockedPercentage += _selectedFunds[i].percentage;
      }
    }

    final remainingPercentage = 100.0 - changedFund.percentage - lockedPercentage;

    // Get unlocked funds (excluding the changed fund)
    List<int> unlockedIndices = [];
    for (int i = 0; i < _selectedFunds.length; i++) {
      if (i != changedIndex && !_selectedFunds[i].isLocked) {
        unlockedIndices.add(i);
      }
    }

    if (remainingPercentage <= 0) {
      // Set all unlocked funds to 0
      for (int i in unlockedIndices) {
        _selectedFunds[i].percentage = 0.0;
      }
      _updateAllControllerValues();
      return;
    }

    if (unlockedIndices.isEmpty) {
      _updateAllControllerValues();
      return;
    }

    final equalPercentage = remainingPercentage / unlockedIndices.length;

    for (int i in unlockedIndices) {
      _selectedFunds[i].percentage = equalPercentage.round().toDouble();
    }

    // Handle rounding differences
    final currentTotal =
        _selectedFunds.fold(0.0, (sum, fund) => sum + fund.percentage);
    final difference = 100.0 - currentTotal;

    if (difference != 0 && unlockedIndices.isNotEmpty) {
      int maxIndex = unlockedIndices.first;
      double maxPercentage = _selectedFunds[maxIndex].percentage;
      
      for (int i in unlockedIndices) {
        if (_selectedFunds[i].percentage > maxPercentage) {
          maxIndex = i;
          maxPercentage = _selectedFunds[i].percentage;
        }
      }

      _selectedFunds[maxIndex].percentage += difference;
      _selectedFunds[maxIndex].percentage =
          _selectedFunds[maxIndex].percentage.clamp(0, 100);
    }
    _updateAllControllerValues();
  }

  void _updateAllControllerValues() {
    for (final fund in _selectedFunds) {
      final controller = _percentageControllers[fund.name];
      if (controller != null) {
        controller.text = fund.percentage.round().toString();
      }
    }
  }

  void _redistributePercentages() {
    if (_selectedFunds.isEmpty) return;

    // Get locked funds and their total percentage
    double lockedPercentage = 0.0;
    List<int> unlockedIndices = [];
    
    for (int i = 0; i < _selectedFunds.length; i++) {
      if (_selectedFunds[i].isLocked) {
        lockedPercentage += _selectedFunds[i].percentage;
      } else {
        unlockedIndices.add(i);
      }
    }

    // If no unlocked funds, nothing to redistribute
    if (unlockedIndices.isEmpty) {
      _updateAllControllerValues();
      return;
    }

    final remainingPercentage = 100.0 - lockedPercentage;
    final equalPercentage = remainingPercentage / unlockedIndices.length;

    // Distribute remaining percentage equally among unlocked funds
    for (int i = 0; i < unlockedIndices.length; i++) {
      final index = unlockedIndices[i];
      if (i == unlockedIndices.length - 1) {
        // Last unlocked fund gets the remaining percentage to ensure total = 100%
        final usedPercentage = lockedPercentage + 
            unlockedIndices.take(i).fold(0.0, (sum, idx) => sum + _selectedFunds[idx].percentage);
        _selectedFunds[index].percentage = (100.0 - usedPercentage).round().toDouble();
      } else {
        _selectedFunds[index].percentage = equalPercentage.round().toDouble();
      }
    }

    _updateAllControllerValues();
  }

  validatepercentage(BuildContext context) {
    if (totalPercentage != 100) {
     error(context, "Total percentage must be 100%");
    } else if(_selectedFunds.any((fund) => fund.percentage == 0) && totalPercentage == 100) {
      error(context, "All funds must have valid percentage values (greater than 0%)");
  }
  }

  void clearStrategy() {
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    _percentageControllers.clear();
    _strategyNameController.clear();
    _investmentController.text = '100000';

    _selectedFunds.clear();
    _searchController.clear();
    _selectedFilter = 'All';
    _selectedDuration = '3Y';
    _editingStrategy = null;
    _investmentError = null;
    _selectedPersonality = TradingPersonalityType.aurora; // Reset to default personality
    notifyListeners();
  }

  bool _showcustomButton = false;
  bool get showcustomButton => _showcustomButton;
  void shocustomButton(bool value) {
    _showcustomButton = value;
    notifyListeners();
  }

  // Method to preload strategy data for editing
  void preloadStrategyData({
    required String strategyName,
    required List<FundListModel> funds,
  }) {
    _strategyNameController.text = strategyName;
    _selectedFunds.clear();
    _selectedFunds.addAll(funds);
    _selectedDuration = '5Y'; // Default duration for predefined strategies
    _initializeControllers();
    notifyListeners();
  }

  // Filter and Search Methods
  void updateSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  bool isFundSelected(FundListModel fund) {
    return _selectedFunds.any((f) => f.name == fund.name);
  }

  // Group selected funds by type
  Map<String, List<FundListModel>> get groupedSelectedFunds {
    Map<String, List<FundListModel>> grouped = {};
    
    for (final fund in _selectedFunds) {
      String category = _getCategoryFromType(fund.type);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(fund);
    }
    
    // Sort categories in preferred order
    Map<String, List<FundListModel>> sortedGrouped = {};
    const order = ['Equity', 'Hybrid', 'Debt'];
    
    for (String category in order) {
      if (grouped.containsKey(category)) {
        sortedGrouped[category] = grouped[category]!;
      }
    }
    
    // Add any other categories not in the predefined order
    for (String category in grouped.keys) {
      if (!order.contains(category)) {
        sortedGrouped[category] = grouped[category]!;
      }
    }
    
    return sortedGrouped;
  }

  String _getCategoryFromType(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('equity') || lowerType.contains('elss') || lowerType.contains('large cap') || 
        lowerType.contains('mid cap') || lowerType.contains('small cap') || lowerType.contains('flexi cap')) {
      return 'Equity';
    } else if (lowerType.contains('hybrid') || lowerType.contains('balanced') || lowerType.contains('arbitrage')) {
      return 'Hybrid';
    } else if (lowerType.contains('debt') || lowerType.contains('liquid') || lowerType.contains('gilt') || 
               lowerType.contains('duration') || lowerType.contains('credit') || lowerType.contains('ultra short')) {
      return 'Debt';
    }
    return 'Other';
  }

  // Helper method to extract trading personality from investment details
  TradingPersonalityType getPersonalityFromInvestmentDetails(String? investmentDetails) {
    if (investmentDetails == null || !investmentDetails.contains('personality:')) {
      return TradingPersonalityType.aurora; // Default to Earth if no personality info found
    }
    
    try {
      final personalityPart = investmentDetails.split('personality:')[1];
      final personalityName = personalityPart.split('|')[0]; // In case there are more parts
      
      // Find the matching personality type by name
      final personality = TradingPersonalities.getPersonalityByName(personalityName);
      if (personality != null) {
        return personality.type;
      }
    } catch (e) {
      // If parsing fails, return default
    }
    
    return TradingPersonalityType.aurora; // Default fallback
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
  double get totalPercentage =>
      _selectedFunds.fold(0.0, (sum, fund) => sum + fund.percentage);

  bool _isStrategyValid = false;
  
  bool get isStrategyValid {
    final investmentAmount = double.tryParse(_investmentController.text);
    final isValidInvestment = investmentAmount != null && investmentAmount >= 10000 && investmentAmount <= 1000000000000;
    final isValidPercentage = totalPercentage.round() == 100;
    final hasSelectedFunds = _selectedFunds.isNotEmpty;
    final hasNoZeroPercentages = _selectedFunds.every((fund) => fund.percentage > 0);
    
    _isStrategyValid = isValidInvestment && isValidPercentage && hasSelectedFunds && hasNoZeroPercentages;
    return _isStrategyValid;
  }

  String? _investmentError;
  String? get investmentError => _investmentError;

  String? validateInvestmentAmount(String value) {
    _investmentController.text = value;
    
    if (value.isEmpty) {
      _isStrategyValid = false;
      _investmentError = "Please enter Investment amount";
      notifyListeners();
      return _investmentError;
    }
    
    final parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      _isStrategyValid = false;
      _investmentError = "Please enter valid Investment amount";
      notifyListeners();
      return _investmentError;
    } 
    
    if (parsedValue <= 0) {
      _isStrategyValid = false;
      _investmentError = "Investment amount must be greater than 0";
      notifyListeners();
      return _investmentError;
    } 
    
    if (parsedValue < 10000) {
      _isStrategyValid = false;
      _investmentError = "Minimum investment amount is ₹10,000";
      notifyListeners();
      return _investmentError;
    }
    
    if (parsedValue > 1000000000000) {
      _isStrategyValid = false;
      _investmentError = "Investment amount cannot exceed ₹1,00,00,00,000";
      notifyListeners();
      return _investmentError;
    } 
    
    _isStrategyValid = true;
    _investmentError = null;
    notifyListeners();
    return null;
  }


  // Check if there are meaningful changes in a new strategy
  bool _hasNewStrategyChanges() {
    if (_selectedFunds.isNotEmpty) return true;
    final investmentAmount = double.tryParse(_investmentController.text);
    if (investmentAmount != null && investmentAmount > 0 && investmentAmount != 100000) return true;
    if (_strategyNameController.text.trim().isNotEmpty) return true;
    if (_selectedInvestmentType != 'One-time') return true;
    
    return false;
  }

  bool _stratergysavebackbutton = false;
  bool get stratergysavebackbutton => _stratergysavebackbutton;
  void stratergySavebackbutton(bool value) {
    _stratergysavebackbutton = value;
    notifyListeners();
  }

  // Change detection methods
  bool get hasStrategyChanged {
    if (!isEditingMode || _editingStrategy == null) {
      return _hasNewStrategyChanges();
    }

    final originalStrategy = _editingStrategy!.data?.first;
    if (originalStrategy == null) return true;

    final currentAmount = double.tryParse(_investmentController.text) ?? 0.0;
    final originalAmount = originalStrategy.investAmount ?? 0.0;
    if (currentAmount != originalAmount) return true;

    final currentName = _strategyNameController.text.trim();
    final originalName = originalStrategy.basketName ?? '';
    if (currentName != originalName) return true;

    final originalFunds = originalStrategy.schemaValues ?? [];
    if (_selectedFunds.length != originalFunds.length) return true;

    final originalDuration = originalStrategy.years ?? 0;
    final currentDuration = _getYearInFromDuration(_selectedDuration);
    if (currentDuration != originalDuration) return true;

    for (final currentFund in _selectedFunds) {
      final originalFund = originalFunds.firstWhere(
        (f) => f.name == currentFund.name,
        orElse: () => SchemaValues(name: '', percentage: 0),
      );
      if ((originalFund.name?.isEmpty ?? true) || 
          (currentFund.percentage - (originalFund.percentage ?? 0)).abs() > 0.01) {
        return true;
      }
    }

    return false;
  }

  // Get button text based on current state
  String get backtestButtonText {
    if (!isEditingMode) {
      return 'Save & Backtest';
    } else if (hasStrategyChanged) {
      return 'Update & Backtest';
    } else {
      return 'Backtest';
    }
  }

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
  Color getFundTypeColor(String type, {bool isDarkMode = false}) {
    switch (type.toLowerCase()) {
      case 'equity':
        return isDarkMode ? colors.successDark : colors.successLight;
      case 'debt':
        return isDarkMode
            ? colors.kColorRedDarkTheme
            : colors.kColorRedDarkTheme;
      case 'hybrid':
        return isDarkMode ? colors.lossDark : colors.lossLight;
      case 'commodities':
        return isDarkMode ? colors.pending : colors.pending;
      default:
        return isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight;
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

  List<MutualFundList>? _basketSearchItems = [];
  List<MutualFundList>? get basketSearchItems => _basketSearchItems;

  Future Basketsearch(String value) async {
    try {
      final basketsearch = await api.getSearchMf(value);

      _basketSearchItems = basketsearch.data ?? [];
      for (var masterMf in _basketSearchItems!) {
        _basketSearchItems!
            .where((m) => m.iSIN == masterMf.iSIN)
            .forEach((m) => m.isAdd = true);
      }
      // Search completed successfully
      notifyListeners();
    } catch (e) {
      print("Basket Search Error: $e");
    }
  }

  void clearBasketSearchResults() {
    _basketSearchItems = [];
    notifyListeners();
  }


  PortfolioAnalysisModel? _analysisData;
  String? _error;
  
  // Chart selection states
  bool _showBenchmarkComparison = true;
  bool _showInflationAdjustment = false;
  String _selectedTimeFrame = '1Y'; // 1Y, 3Y, 5Y, All
  
  // Getters
  PortfolioAnalysisModel? get analysisData => _analysisData;
  // String? get error => _error;
  bool get showBenchmarkComparison => _showBenchmarkComparison;
  bool get showInflationAdjustment => _showInflationAdjustment;
  String get selectedTimeFrame => _selectedTimeFrame;
  
  // Calculate performance vs benchmark
  double get performanceVsBenchmark {
    if (_analysisData == null) return 0.0;
    return _analysisData!.total.xirr - _analysisData!.benchmark.xirr;
  }
  
  // Get total post-tax gains
  double get totalPostTaxGains {
    if (_analysisData == null) return 0.0;
    return _analysisData!.taxDetails.equity.postGainTotal + 
           _analysisData!.taxDetails.debt.postGainTotal;
  }
  
  // Get total tax liability
  double get totalTaxLiability {
    if (_analysisData == null) return 0.0;
    return _analysisData!.taxDetails.equity.tax + 
           _analysisData!.taxDetails.debt.tax;
  }

  
  
  // Toggle benchmark comparison
  void toggleBenchmarkComparison() {
    _showBenchmarkComparison = !_showBenchmarkComparison;
    notifyListeners();
  }
  
  // Toggle inflation adjustment
  void toggleInflationAdjustment() {
    _showInflationAdjustment = !_showInflationAdjustment;
    notifyListeners();
  }
  
  // Change time frame
  void changeTimeFrame(String timeFrame) {
    if (_selectedTimeFrame != timeFrame) {
      _selectedTimeFrame = timeFrame;
      notifyListeners();
    }
  }
  
  // Get filtered chart data based on time frame
  List<double> getFilteredChartData(List<double> originalData) {
    if (_selectedTimeFrame == 'All' || originalData.isEmpty) {
      return originalData;
    }
    
    int dataPoints;
    switch (_selectedTimeFrame) {
      case '1Y':
        dataPoints = 365;
        break;
      case '3Y':
        dataPoints = 365 * 3;
        break;
      case '5Y':
        dataPoints = 365 * 5;
        break;
      default:
        return originalData;
    }
    
    if (originalData.length <= dataPoints) {
      return originalData;
    }
    
    return originalData.sublist(originalData.length - dataPoints);
  }
  
  // Calculate portfolio allocation
  Map<String, double> get portfolioAllocation {
    if (_analysisData == null) return {};
    
    Map<String, double> allocation = {};
    
    // Add equity allocations
    for (var equity in _analysisData!.equity) {
      allocation['Equity'] = (allocation['Equity'] ?? 0) + equity.percentage;
    }
    
    // Add debt allocations
    for (var debt in _analysisData!.debt) {
      allocation['Debt'] = (allocation['Debt'] ?? 0) + debt.percentage;
    }
    
    return allocation;
  }
  
  // Get risk metrics
  Map<String, dynamic> get riskMetrics {
    if (_analysisData == null) return {};
    
    return {
      'volatility': _analysisData!.total.volatility,
      'sharpe_ratio': _analysisData!.total.sharpeRatio,
      'max_drawdown': _analysisData!.total.maxDrawdown,
      'var_95': calculateVaR(), // You can implement this
      'beta': calculateBeta(), // You can implement this
    };
  }
  
  // Calculate Value at Risk (placeholder)
  double calculateVaR() {
    // Implement VaR calculation logic
    return 0.0;
  }
  
  // Calculate Beta (placeholder)
  double calculateBeta() {
    // Implement Beta calculation logic
    return 0.0;
  }
 
  
  // Clear data
  void clearData() {
    _analysisData = null;
    _error = null;
    _isStrategyLoading = false;
    notifyListeners();
  }

  clearsearchcontroller() {
    _searchController.text = "";
    notifyListeners();
  }

 Future<void> backtestAnalysis({required String uuid}) async {
  try {
    strategyLoader(true);
    _error = null;
    // Convert selected funds to schema values
    final schemaValues = _convertFundsToSchemaValues(_selectedFunds)
        .map((map) => SchemeValue(
              name: map['name'] ?? '',
              schemaName: map['schema_name'] ?? '',
              percentage: map['percentage'] ?? 0,
              schemeType: map['scheme_type'].toUpperCase() ?? '',
              isin: map['isin'] ?? '',
              aMCCode: map['aMCCode'] ?? '',
            ))
        .toList();

    // Create the backtest request
    final request = BacktestRequest(
      yearIn: _getYearInFromDuration(_selectedDuration),
      investmentAmount: double.tryParse(_investmentController.text) ?? 0.0,
      schemeValues: schemaValues,
      compareSymbol: "NSE:NIFTYBEES-EQ",
    );

    print("Backtest request created: ${request.toJson()}");

    final portfolioAnalysis = await api.performBacktest(request, uuid);

    if (portfolioAnalysis != null) {
      _analysisData = portfolioAnalysis;
      _error = null;
      print("Backtest analysis completed successfully");
    } else {
      _error = "Failed to get portfolio analysis data";
      print("Backtest analysis returned null");
    }
  } catch (e) {
    print("Portfolio Analysis Error: $e");
    _error = e.toString();
    rethrow;
  } finally {
    strategyLoader(false);
    notifyListeners();
  }
}

  
  // Fetch real mutual fund data for predefined strategies
  Future<List<Map<String, dynamic>>> getRealFundDataForCategory(String category) async {
    try {
      // Search for popular funds in each category
      String searchTerm = '';
      switch (category.toLowerCase()) {
        case 'equity':
          searchTerm = 'Parag Parikh Flexi Cap Fund';
          break;
        case 'debt':
          searchTerm = 'HDFC Money Market Fund';
          break;
        case 'hybrid':
          searchTerm = 'HDFC Balanced Advantage Fund';
          break;
        case 'commodities':
          searchTerm = 'Nippon India ETF Gold BeES';
          break;
        default:
          searchTerm = 'HDFC';
      }
      
      final searchResult = await api.getSearchMf(searchTerm);
      
      if (searchResult.data != null && searchResult.data!.isNotEmpty) {
        // Return the first fund from search results
        final fund = searchResult.data!.first;
        return [{
          'name': fund.schemeName ?? fund.fundname ?? 'Unknown Fund',
          'percentage': 0.0, // Will be set by caller
          'schemeType': fund.schemeType ?? 'EQUITY',
          'isin': fund.iSIN ?? '',
          'amcCode': fund.aMCCode ?? '',
          'fiveYearCAGR': 0.0, // Not available in MutualFundList
          'threeYearCAGR': 0.0, // Not available in MutualFundList
          'aum': double.tryParse(fund.aUM ?? '0') ?? 0.0,
          'sharpe': 0.0, // Not available in MutualFundList
        }];
      }
      
      // Fallback to default values if search fails
      return [{
        'name': '${category} Fund',
        'percentage': 0.0,
        'schemeType': category.toUpperCase(),
        'isin': '',
        'amcCode': '',
        'fiveYearCAGR': 0.0,
        'threeYearCAGR': 0.0,
        'aum': 0.0,
        'sharpe': 0.0,
      }];
    } catch (e) {
      print("Error fetching real fund data for $category: $e");
      // Return fallback data
      return [{
        'name': '${category} Fund',
        'percentage': 0.0,
        'schemeType': category.toUpperCase(),
        'isin': '',
        'amcCode': '',
        'fiveYearCAGR': 0.0,
        'threeYearCAGR': 0.0,
        'aum': 0.0,
        'sharpe': 0.0,
      }];
    }
  }

  // Perform backtest with predefined allocations
  Future<void> performBacktestWithAllocation({
    required String strategyName,
    required List<Map<String, dynamic>> fundAllocations,
    int years = 5,
    double investmentAmount = 100000.0,
    String compareSymbol = "NSE:NIFTYBEES-EQ",
  }) async {
    try {
      strategyLoader(true);
      _error = null;

      // Create scheme values from fund allocations
      final schemeValues = fundAllocations.map((fund) => SchemeValue(
        name: fund['name'] as String,
        schemaName: fund['schema_name'] as String,
        percentage: (fund['percentage'] as double).round(),
        schemeType: fund['schemeType'] as String,
        isin: fund['isin'] as String,
        aMCCode: fund['amcCode'] ?? ''
      )).toList();

      // Create backtest request
      final request = BacktestRequest(
        yearIn: years,
        investmentAmount: investmentAmount,
        schemeValues: schemeValues,
        compareSymbol: compareSymbol,
      );

      print("Predefined backtest request created: ${request.toJson()}");

      // Generate a unique UUID for this predefined strategy
      final uuid = 'predefined_${DateTime.now().millisecondsSinceEpoch}';

      final portfolioAnalysis = await api.performBacktest(request, uuid);

      if (portfolioAnalysis != null) {
        _analysisData = portfolioAnalysis;
        _error = null;
        print("Predefined backtest analysis completed successfully");
      } else {
        _error = "Failed to get portfolio analysis data";
        print("Predefined backtest analysis returned null");
      }
    } catch (e) {
      print("Predefined Backtest Error: $e");
      _error = e.toString();
      rethrow;
    } finally {
      strategyLoader(false);
      notifyListeners();
    }
  }

  // Refresh data
  // Future<void> refreshData(BacktestRequest request) async {
  //   await performBacktest(request);
  // }
}

// Helper extension for formatting
extension NumberFormatting on double {
  String toFormattedCurrency() {
    return '₹${toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match[1]},',
    )}';
  }
  
  String toFormattedPercentage() {
    return '${toStringAsFixed(2)}%';
  }

  // @override
  // void dispose() {
  //   _investmentController.dispose();
  //   _searchController.dispose();
  //   super.dispose();
  // }
}


 void handleSaveStrategy(DashboardProvider strategy, BuildContext context) {
    // Validate strategy name
    if (strategy.strategyNameController.text.trim().isEmpty) {
      strategy.setStrategyNameError('Strategy name is required');
      return;
    }
    
    if (strategy.strategyNameController.text.trim().length < 3) {
      strategy.setStrategyNameError('Strategy name must be at least 3 characters');
      return;
    }

    // Validate total percentage
    if (strategy.totalPercentage != 100) {
      strategy.setStrategyNameError('Total percentage must be 100%');
      return;
    }
    
    // Clear any existing error
    strategy.clearStrategyNameError();
    
    // Proceed with strategy creation/update
    if (strategy.isEditingMode) {
      strategy.updateStrategy(context);
    } else {
      strategy.createStrategy(strategy.strategyNameController.text, context);
    }
    
    // Navigate back after successful save
    Navigator.pop(context);
    Navigator.pop(context);
    if(!strategy.stratergysavebackbutton){
                      Navigator.of(context).pop();
                       strategy.backtestAnalysis(uuid: strategy.editingStrategy?.data?.first.uuid ?? '');
                     }
  }

