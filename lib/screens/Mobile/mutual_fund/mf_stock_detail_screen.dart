import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/mynt_loader.dart';
import 'mf_order_screen.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import 'widget/allocation.dart';
import 'widget/overview.dart';
import 'widget/performance.dart';
import 'widget/scheme.dart';

class MFStockDetailScreen extends StatefulWidget {
  final MutualFundList mfStockData;
  final bool fromSearch;
  final VoidCallback? onBack;

  const MFStockDetailScreen({
    super.key,
    required this.mfStockData,
    this.fromSearch = false,
    this.onBack,
  });

  @override
  State<MFStockDetailScreen> createState() => _MFStockDetailScreenState();
}

class _MFStockDetailScreenState extends State<MFStockDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<String> _tabTitles = ['Overview', 'Scheme', 'Allocation'];

  // Keys to track section positions
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _schemeKey = GlobalKey();
  final GlobalKey _allocationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    // Add listener to handle tab clicks
    _tabController.addListener(_onTabTapped);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.removeListener(_onTabTapped);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped() {
    if (_tabController.indexIsChanging) {
      _scrollToSection(_tabController.index);
    }
  }

  void _scrollToSection(int index) {
    GlobalKey? targetKey;
    switch (index) {
      case 0:
        targetKey = _overviewKey;
        break;
      case 1:
        targetKey = _schemeKey;
        break;
      case 2:
        targetKey = _allocationKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    final overviewPos = _getWidgetPosition(_overviewKey);
    final schemePos = _getWidgetPosition(_schemeKey);
    final allocationPos = _getWidgetPosition(_allocationKey);

    // Determine which section is currently visible (closest to top)
    const threshold = 100.0; // Offset from top to trigger tab change

    int newIndex = 0;
    if (allocationPos != null && allocationPos <= threshold) {
      newIndex = 2;
    } else if (schemePos != null && schemePos <= threshold) {
      newIndex = 1;
    } else {
      newIndex = 0;
    }

    if (_tabController.index != newIndex && !_tabController.indexIsChanging) {
      _tabController.animateTo(newIndex);
    }
  }

  double? _getWidgetPosition(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      return position.dy;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final mfData = ref.watch(mfProvider);
      final isDark = theme.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? colors.colorBlack : colors.colorWhite,
        body: Stack(
          children: [
            Column(
              children: [
                // Header with breadcrumb
                _buildHeader(isDark, mfData),

                // Tab bar with action buttons
                _buildTabBarWithActions(isDark, mfData),

                // Scrollable content with all sections
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fund info card with stats (now scrollable)
                        _buildFundInfoCard(isDark, mfData),

                        // Overview Section
                        Container(
                          key: _overviewKey,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? colors.darkColorDivider : colors.colorDivider,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                MFOverview(mfStockData: widget.mfStockData),
                                MFPerformance(mfStockData: widget.mfStockData),
                              ],
                            ),
                          ),
                        ),
                        // Scheme Section
                        Container(
                          key: _schemeKey,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? colors.darkColorDivider : colors.colorDivider,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MFSchemeInfo(mfStockData: widget.mfStockData),
                          ),
                        ),
                        // Allocation Section
                        Container(
                          key: _allocationKey,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? colors.darkColorDivider : colors.colorDivider,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MFAllocation(mfStockData: widget.mfStockData),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Loading overlay
            if (mfData.singleloader == true)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: MyntLoader(size: MyntLoaderSize.large),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? colors.colorBlack : colors.colorWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? colors.darkColorDivider : colors.colorDivider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            InkWell(
              onTap: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: isDark ? colors.colorGrey : colors.colorBlack,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Breadcrumb
            Expanded(
              child: Row(
                children: [
                  Text(
                    "Mutual Fund",
                    style: MyntWebTextStyles.body(
                      context,
                      color: isDark
                          ? MyntColors.textSecondaryDark
                          : MyntColors.textSecondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isDark
                          ? WebColors.textSecondaryDark
                          : WebColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatFundName(mfData),
                      style: MyntWebTextStyles.body(
                        context,
                        color: isDark
                            ? MyntColors.textPrimaryDark
                            : MyntColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarWithActions(bool isDark, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? colors.colorBlack : colors.colorWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? colors.darkColorDivider : colors.colorDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Tab bar
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: isDark ? WebColors.primary : WebColors.primary,
              unselectedLabelColor: isDark
                  ? WebColors.textSecondaryDark
                  : WebColors.textSecondary,
              labelStyle: MyntWebTextStyles.body(
                context,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: MyntWebTextStyles.body(
                context,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: WebColors.primary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),

          // Action buttons
          Row(
            children: [
              // One-time button (outlined)
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: mfData.singleloader == true ? null : () => _handleOneTimeTap(mfData),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    side: const BorderSide(
                      color: WebColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "One-time",
                    style: MyntWebTextStyles.body(
                      context,
                      color: MyntColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // SIP button (filled)
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: mfData.singleloader == true ? null : () => _handleSIPTap(mfData),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    backgroundColor: WebColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "SIP",
                    style: MyntWebTextStyles.body(
                      context,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundInfoCard(bool isDark, MFProvider mfData) {
    final factSheet = mfData.factSheetDataModel?.data;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.colorBlack : colors.colorWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? colors.darkColorDivider : colors.colorDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fund logo, name, and type
          Row(
            children: [
              // Fund logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? colors.darkColorDivider : colors.colorDivider,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    "https://v3.mynt.in/mfapi/static/images/mf/${factSheet?.amccode ?? widget.mfStockData.aMCCode ?? 'default'}.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance,
                      size: 20,
                      color: isDark ? WebColors.textSecondaryDark : WebColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatFundName(mfData),
                      style: MyntWebTextStyles.title(
                        context,
                        color: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Text(
                        //   "NAV: ₹${factSheet?.currentNAV ?? '--'}",
                        //   style: MyntWebTextStyles.para(
                        //     context,
                        //     color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                        //   ),
                        // ),
                        // const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            // color: (isDark ? WebColors.textSecondaryDark : WebColors.textSecondary).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.mfStockData.type ?? "Equity",
                            style: MyntWebTextStyles.para(
                              context,
                              color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                "Aum (cr)",
                _formatAum(widget.mfStockData.aUM),
                isDark,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                "NAV",
                factSheet?.currentNAV ?? '--',
                isDark,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                "Min. Inv",
                widget.mfStockData.minimumPurchaseAmount ?? '500',
                isDark,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                "5Yr CAGR",
                _formatPercentage(widget.mfStockData.fIVEYEARDATA),
                isDark,
                isPercentage: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark, {bool isPercentage = false}) {
    Color valueColor = isDark ? WebColors.textPrimaryDark : WebColors.textPrimary;

    if (isPercentage && value != '--') {
      final numValue = double.tryParse(value.replaceAll('%', '')) ?? 0;
      if (numValue > 0) {
        valueColor = isDark ? WebColors.profitDark : WebColors.profit;
      } else if (numValue < 0) {
        valueColor = isDark ? WebColors.lossDark : WebColors.loss;
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.para(
              context,
              color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: MyntWebTextStyles.body(
              context,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? colors.darkColorDivider : colors.colorDivider,
    );
  }

  void _handleOneTimeTap(MFProvider mfData) async {
    final isin = widget.mfStockData.iSIN;
    final schemeCode = widget.mfStockData.schemeCode;

    // Show loader while fetching dependencies
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: MyntLoader(size: MyntLoaderSize.large)),
    );

    if (widget.mfStockData.sIPFLAG == "Y" && isin != null && schemeCode != null) {
      await mfData.invertfun(isin, schemeCode, context);
      String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
      mfData.invAmt.text = amt.split('.').first;
    }
    mfData.orderchangetitle("One-time");
    mfData.orderpagetite("SDS");
    mfData.chngOrderType("One-time");

    // Close loader
    if (mounted) Navigator.pop(context);

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.25; // 25% width
    final dialogHeight = screenSize.height * 0.60; // 60% height

    // Show order popup
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MFOrderScreen(mfData: widget.mfStockData),
          ),
        ),
      ),
    );
  }

  void _handleSIPTap(MFProvider mfData) async {
    final isin = widget.mfStockData.iSIN;
    final schemeCode = widget.mfStockData.schemeCode;

    // Show loader while fetching dependencies
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: MyntLoader(size: MyntLoaderSize.large)),
    );

    if (widget.mfStockData.sIPFLAG == "Y" && isin != null && schemeCode != null) {
      await mfData.invertfun(isin, schemeCode, context);
      String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
      mfData.installmentAmt.text = amt.split('.').first;
    }
    mfData.orderchangetitle("SIP");
    mfData.chngOrderType("SIP");
    mfData.orderpagetite("SDS");

    // Close loader
    if (mounted) Navigator.pop(context);

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.25; // 25% width
    final dialogHeight = screenSize.height * 0.60; // 60% height

    // Show order popup
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MFOrderScreen(mfData: widget.mfStockData),
          ),
        ),
      ),
    );
  }

  String _formatFundName(MFProvider mfData) {
    if (mfData.factSheetDataModel?.data?.name != null) {
      return mfData.factSheetDataModel!.data!.name!
          .replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ');
    }
    return widget.mfStockData.schemeName ?? widget.mfStockData.fSchemeName ?? 'Unknown Fund';
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "--";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "--";
    }
  }

  String _formatPercentage(String? value) {
    if (value == null || value.isEmpty) return "--";
    return "$value%";
  }
}
