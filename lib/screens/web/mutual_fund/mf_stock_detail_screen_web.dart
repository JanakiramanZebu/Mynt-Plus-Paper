import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import 'mf_order_screen_web.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import 'widget/allocation_web.dart';
import 'widget/overview_web.dart';
import 'widget/performance_web.dart';
import 'widget/scheme_web.dart';
import 'widget/comparison_table_web.dart';

class MFStockDetailScreenWeb extends StatefulWidget {
  final MutualFundList mfStockData;
  final bool fromSearch;
  final VoidCallback? onBack;

  const MFStockDetailScreenWeb({
    super.key,
    required this.mfStockData,
    this.fromSearch = false,
    this.onBack,
  });

  @override
  State<MFStockDetailScreenWeb> createState() => _MFStockDetailScreenWebState();
}

class _MFStockDetailScreenWebState extends State<MFStockDetailScreenWeb>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<String> _tabTitles = ['Overview', 'Scheme', 'Allocation'];

  // Track section offsets instead of using GlobalKeys for scroll detection
  double _schemeOffset = 0;
  double _allocationOffset = 0;
  bool _isScrollListenerEnabled = true;

  // Button loading state
  bool _isOneTimeLoading = false;
  bool _isSIPLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabTapped);

    // Calculate offsets after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSectionOffsets();
    });
  }

  @override
  void dispose() {
    _isScrollListenerEnabled = false;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.removeListener(_onTabTapped);
    _tabController.dispose();
    super.dispose();
  }

  void _updateSectionOffsets() {
    // Use approximate fixed offsets based on typical section heights
    // This avoids needing to access render objects during rebuilds
    _schemeOffset = 600; // Approximate offset for scheme section
    _allocationOffset = 1000; // Approximate offset for allocation section
  }

  void _onTabTapped() {
    if (!mounted || !_isScrollListenerEnabled) return;
    if (_tabController.indexIsChanging) {
      _scrollToSection(_tabController.index);
    }
  }

  void _scrollToSection(int index) {
    if (!mounted || !_isScrollListenerEnabled) return;

    double targetOffset = 0;
    switch (index) {
      case 0:
        targetOffset = 0;
        break;
      case 1:
        targetOffset = _schemeOffset;
        break;
      case 2:
        targetOffset = _allocationOffset;
        break;
    }

    try {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // Ignore errors
    }
  }

  void _onScroll() {
    if (!mounted || !_isScrollListenerEnabled) return;

    try {
      final scrollOffset = _scrollController.offset;

      int newIndex = 0;
      if (scrollOffset >= _allocationOffset - 100) {
        newIndex = 2;
      } else if (scrollOffset >= _schemeOffset - 100) {
        newIndex = 1;
      } else {
        newIndex = 0;
      }

      if (_tabController.index != newIndex && !_tabController.indexIsChanging) {
        _tabController.animateTo(newIndex);
      }
    } catch (e) {
      // Ignore errors during rebuilds
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final mfData = ref.watch(mfProvider);
      final isDark = theme.isDarkMode;

      return Scaffold(
        // backgroundColor: isDark ? colors.colorBlack : colors.colorWhite,
        backgroundColor: isDark ? MyntColors.backgroundColorDark :MyntColors.backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                // Tab bar with action buttons (includes back arrow)
                _buildTabBarWithActions(isDark, mfData),

                // Scrollable content with all sections
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Section
                        Column(
                          children: [
                            MFOverviewWeb(
                              mfStockData: widget.mfStockData,
                              fundName: _formatFundName(mfData),
                              fundCategory: widget.mfStockData.type ?? "Equity",
                              fundImage: "https://v3.mynt.in/mfapi/static/images/mf/${mfData.factSheetDataModel?.data?.amccode ?? widget.mfStockData.aMCCode ?? 'default'}.png",
                            ),
                            MFPerformanceWeb(mfStockData: widget.mfStockData),
                          ],
                        ),
                        // Scheme Section
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                MFSchemeInfoWeb(mfStockData: widget.mfStockData),
                          ),
                        ),
                        // Allocation Section
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: MFAllocationWeb(mfStockData: widget.mfStockData),
                        ),
                        // Comparison Table Section
                        MFComparisonTableWeb(mfStockData: widget.mfStockData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }


  Widget _buildTabBarWithActions(bool isDark, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // color: isDark ? colors.colorBlack : colors.colorWhite,
        color: isDark ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
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
            // Back arrow button - using GestureDetector for instant response
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: isDark ? colors.colorGrey : colors.colorBlack,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tab bar
            Expanded(
              child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: isDark ? MyntColors.primaryDark : MyntColors.primary,
              unselectedLabelColor: isDark
                  ? MyntColors.textSecondaryDark
                  : MyntColors.textSecondary,
              labelStyle: MyntWebTextStyles.body(
                context,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: MyntWebTextStyles.body(
                context,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: isDark ? MyntColors.primaryDark : MyntColors.primary,
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
                width: 100,
                child: OutlinedButton(
                  onPressed: (_isOneTimeLoading || _isSIPLoading)
                      ? null
                      : () => _handleOneTimeTap(mfData),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: BorderSide(
                      color: (_isOneTimeLoading || _isSIPLoading)
                          ? isDark ? MyntColors.primaryDark.withValues(alpha: 0.5) : MyntColors.primary.withValues(alpha: 0.5)
                          : isDark ? MyntColors.primaryDark : MyntColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isOneTimeLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                WebColors.primary),
                          ),
                        )
                      : Text(
                          "One-time",
                          style: MyntWebTextStyles.body(
                            context,
                            color: _isSIPLoading
                                ? isDark ? MyntColors.primaryDark.withValues(alpha: 0.5) : MyntColors.primary.withValues(alpha: 0.5)
                                : isDark ? MyntColors.primaryDark : MyntColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              // SIP button (filled)
              SizedBox(
                height: 36,
                width: 80,
                child: ElevatedButton(
                  onPressed: (_isOneTimeLoading || _isSIPLoading)
                      ? null
                      : () => _handleSIPTap(mfData),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: (_isOneTimeLoading || _isSIPLoading)
                        ? resolveThemeColor(context, dark: MyntColors.secondary.withValues(alpha: 0.5), light: MyntColors.primary.withValues(alpha: 0.5))
                        : resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isSIPLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
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
      ),
    );
  }

  void _handleOneTimeTap(MFProvider mfData) async {
    setState(() => _isOneTimeLoading = true);

    // Set investment amount
    String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
    mfData.invAmt.text = amt.split('.').first;

    mfData.orderchangetitle("One-time");
    mfData.orderpagetite("SDS");
    mfData.chngOrderType("One-time");

    if (mounted) setState(() => _isOneTimeLoading = false);

    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.30).clamp(380.0, 500.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: dialogWidth,
          child: MFOrderScreenWeb(mfData: widget.mfStockData),
        ),
      ),
    );
  }

  void _handleSIPTap(MFProvider mfData) async {
    setState(() => _isSIPLoading = true);

    String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
    mfData.installmentAmt.text = amt.split('.').first;

    mfData.orderchangetitle("SIP");
    mfData.chngOrderType("SIP");
    mfData.orderpagetite("SDS");

    if (mounted) setState(() => _isSIPLoading = false);

    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.30).clamp(380.0, 500.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: dialogWidth,
          child: MFOrderScreenWeb(mfData: widget.mfStockData),
        ),
      ),
    );
  }

  String _formatFundName(MFProvider mfData) {
    if (mfData.factSheetDataModel?.data?.name != null) {
      return mfData.factSheetDataModel!.data!.name!
          .replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ');
    }
    return widget.mfStockData.schemeName ??
        widget.mfStockData.fSchemeName ??
        'Unknown Fund';
  }
}
