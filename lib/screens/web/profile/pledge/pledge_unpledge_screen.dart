import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/web/profile/pledge/pledge_approve_list_screen.dart';
import 'package:mynt_plus/screens/web/profile/pledge/pledge_history_main_screen.dart';
import 'package:mynt_plus/screens/web/profile/pledge/pledge_filter_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mynt_plus/routes/web_router.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/common_search_fields_web.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class PledgenUnpledge extends StatefulWidget {
  final String ddd;
  const PledgenUnpledge({super.key, required this.ddd});

  @override
  State<PledgenUnpledge> createState() => _PledgenUnpledgeScreenState();
}

class _PledgenUnpledgeScreenState extends State<PledgenUnpledge> {
  // Selected tab: '0' = Available Balance (Pledge), '1' = Pledge Balance (Unpledge), '2' = Non Approved
  String selectedFilterType = '0';

  // Inline screen states
  bool showApproveList = false;
  bool showHistory = false;

  // Search state
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.watch(ledgerProvider);

      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0));
        ledgerprovider.getCurrentDate("pandu");
        ledgerprovider.fetchpledgeandunpledge(context);
      }

      // Calculate counts for cards
      int pledgeListCount = 0;
      int unpledgeListCount = 0;

      if (ledgerprovider.pledgeandunpledge?.data != null) {
        for (var item in ledgerprovider.pledgeandunpledge!.data!) {
          double soh = double.tryParse(item.sOHQTY?.toString() ?? '0') ?? 0;
          double nsoh = double.tryParse(item.nSOHQTY?.toString() ?? '0') ?? 0;
          if ((soh + nsoh) > 0) pledgeListCount++;

          double colQty = double.tryParse(item.cOLQTY?.toString() ?? '0') ?? 0;
          if (colQty > 0) unpledgeListCount++;
        }
      }

      int nonApprovedCount = int.tryParse(
              ledgerprovider.pledgeandunpledge?.noOfNonApprovedStocks
                      ?.toString() ??
                  '0') ??
          0;

      double nonApprovedSum = 0.0;
      if (ledgerprovider.pledgeandunpledge?.data != null) {
        for (var item in ledgerprovider.pledgeandunpledge!.data!) {
          if (item.status == "Not_ok" &&
              (double.tryParse(item.cOLQTY?.toString() ?? '0') ?? 0).toInt() ==
                  0) {
            double scripValue =
                double.tryParse(item.aMOUNT?.toString() ?? '0') ?? 0.0;
            nonApprovedSum += scripValue;
          }
        }
      }

      // Stats for the selected tab
      String displayLabel = '';
      String displayValue = '0.00';

      if (selectedFilterType == '1') {
        displayLabel = 'Available Margin';
        displayValue =
            ledgerprovider.pledgeandunpledge?.marginTotalAvailable?.toString() ??
                '0.00';
        if (displayValue == 'null') displayValue = '0.00';
      } else if (selectedFilterType == '0') {
        displayLabel = 'Est Margin';
        displayValue =
            ledgerprovider.pledgeandunpledge?.estTotalAvailable?.toString() ??
                '0.00';
        if (displayValue == 'null') displayValue = '0.00';
      } else {
        displayLabel = 'Non-Approved';
        displayValue = nonApprovedSum.toStringAsFixed(2);
      }

      // Approve Securities inline screen
      if (showApproveList) {
        return Navigator(
          onDidRemovePage: (page) {
            setState(() {
              showApproveList = false;
            });
          },
          pages: const [
            MaterialPage(child: PledgeApproveListScreen()),
          ],
        );
      }

      // History inline screen
      if (showHistory) {
        return Navigator(
          onDidRemovePage: (page) {
            setState(() {
              showHistory = false;
            });
          },
          pages: const [
            MaterialPage(child: PledgeHistoryMainScreen()),
          ],
        );
      }

      // CDSL web waiting state: show full-panel loader
      if (ledgerprovider.cdslWebWaiting && !ledgerprovider.cdslWebShowReport) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            leadingWidth: 41,
            titleSpacing: 6,
            centerTitle: false,
            elevation: 0.2,
            leading: const SizedBox(),
            title: TextWidget.titleText(
                text: "CDSL Verification",
                textOverflow: TextOverflow.ellipsis,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
                fw: 1),
          ),
          body: Container(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Awaiting CDSL confirmation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Animated dots
                  SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.3, end: 1.0),
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          builder: (context, value, child) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This will take a few seconds.',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        ledgerprovider.cancelCdslWebFlow();
                      },
                      child: TextWidget.subText(
                          text: "Cancel Transaction",
                          color: colors.colorWhite,
                          theme: theme.isDarkMode,
                          fw: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // CDSL web report state: show full-panel pledge report
      if (ledgerprovider.cdslWebShowReport &&
          ledgerprovider.cdslresponsedata != null) {
        return _buildCdslReportScreen(ledgerprovider, theme);
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          // leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          // leading: CustomBackBtn(onBack: () => context.go(WebRoutes.home)),
          elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextWidget.titleText(
                    text: "Pledge",
                    textOverflow: TextOverflow.ellipsis,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () async {
                        ledgerprovider.fetchunpledgehistory(context);
                        ledgerprovider.fetchpledgehistory(context);
                        ledgerprovider.taxpnlExTabchange(0);
                        setState(() {
                          showHistory = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: TextWidget.subText(
                          text: "History",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.secondaryDark
                              : colors.secondaryLight,
                          fw: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () async {
                        ledgerprovider.fetchapprovepledge();
                        setState(() {
                          showApproveList = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: TextWidget.subText(
                          text: "Approve Securities",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.secondaryDark
                              : colors.secondaryLight,
                          fw: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: ledgerprovider.pledgeloader
            ? Center(
                child: Container(
                  color: theme.isDarkMode
                      ? colors.colorBlack
                      : colors.colorWhite,
                  child: CircularLoaderImage(),
                ),
              )
            : SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // ── Stats Cards ──
                        _buildSummaryCards(
                          theme: theme,
                          ledgerprovider: ledgerprovider,
                          displayLabel: displayLabel,
                          displayValue: displayValue,
                        ),

                        // ── Tabs + Search Row ──
                        _buildTabsAndSearchRow(
                          theme: theme,
                          pledgeListCount: pledgeListCount,
                          unpledgeListCount: unpledgeListCount,
                          nonApprovedCount: nonApprovedCount,
                        ),

                        // Divider
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                        ),

                        // ── Table ──
                        Expanded(
                          child: PledgeFilter(
                            activetabe: selectedFilterType,
                            searchQuery: searchQuery,
                          ),
                        ),

                        // Space for bottom action buttons
                        if (ledgerprovider.listforpledge.isNotEmpty)
                          Container(height: screenheight * 0.07),
                      ],
                    ),

                    // ── Bottom Action Buttons ──
                    if (ledgerprovider.listforpledge.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            border: Border(
                              top: BorderSide(
                                color: theme.isDarkMode
                                    ? MyntColors.cardBorderDark
                                    : MyntColors.cardBorder,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Selected scripts count + hover tooltip
                              Expanded(
                                child: _buildSelectedScriptsLabel(
                                    ledgerprovider, theme),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ledgerprovider
                                        .cancelpledgetotal(
                                            ledgerprovider
                                                .screenpledge);
                                    ledgerprovider
                                        .changesegvaldummy('');
                                  },
                                  style:
                                      ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: theme
                                            .isDarkMode
                                        ? colors.textSecondaryDark
                                            .withValues(
                                                alpha: 0.6)
                                        : colors.btnBg,
                                    side: theme.isDarkMode
                                        ? null
                                        : BorderSide(
                                            color: colors
                                                .primaryLight,
                                            width: 1,
                                          ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              5),
                                    ),
                                  ),
                                  child: TextWidget.subText(
                                      text: "Cancel",
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.primaryLight,
                                      theme: theme.isDarkMode,
                                      fw: 2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  style:
                                      ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor:
                                        Colors.transparent,
                                    backgroundColor: theme
                                            .isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              5),
                                    ),
                                  ),
                                          onPressed: () {
                                            ledgerprovider
                                                .changesegvaldummy('');
                                            if (ledgerprovider
                                                    .pledgeoruppledgedelete ==
                                                'unpledgedelete') {
                                              ledgerprovider
                                                  .unpldgedeletefun(
                                                      context,
                                                      ledgerprovider
                                                          .pledgeandunpledge!
                                                          .cLIENTCODE
                                                          .toString(),
                                                      ledgerprovider
                                                          .listforpledge);
                                            } else {
                                              if (ledgerprovider
                                                      .pledgeorunpledge ==
                                                  'unpledge') {
                                                ledgerprovider
                                                    .sendunpledgerequest(
                                                        context,
                                                        ledgerprovider
                                                            .pledgeandunpledge!
                                                            .cLIENTCODE
                                                            .toString(),
                                                        ledgerprovider
                                                            .pledgeandunpledge!
                                                            .bOID
                                                            .toString(),
                                                        ledgerprovider
                                                            .pledgeandunpledge!
                                                            .cLIENTNAME
                                                            .toString(),
                                                        ledgerprovider
                                                            .listforpledge);
                                              } else if (ledgerprovider
                                                      .pledgeorunpledge ==
                                                  'pledge') {
                                                // Show a temporary dialog so beforecdsl's
                                                // Navigator.pop closes it, not the main screen
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.transparent,
                                                  builder: (_) => const SizedBox.shrink(),
                                                );
                                                ledgerprovider.beforecdsl(
                                                    context,
                                                    ledgerprovider
                                                        .pledgeandunpledge!
                                                        .cLIENTCODE
                                                        .toString(),
                                                    ledgerprovider
                                                        .pledgeandunpledge!
                                                        .bOID
                                                        .toString(),
                                                    ledgerprovider
                                                        .pledgeandunpledge!
                                                        .cLIENTNAME
                                                        .toString(),
                                                    ledgerprovider
                                                        .listforpledge);
                                              }
                                            }
                                          },
                                  child: TextWidget.subText(
                                      text: "Submit",
                                      color: colors.colorWhite,
                                      theme: theme.isDarkMode,
                                      fw: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      );
    });
  }

  // ============================================================
  // CDSL Report Full-Panel Screen (shadcn table)
  // ============================================================

  TextStyle _reportCellStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _reportHeaderStyle(BuildContext context) {
    return MyntWebTextStyles.tableHeader(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  shadcn.TableCell _reportHeaderCell(String label) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(label, style: _reportHeaderStyle(context)),
      ),
    );
  }

  shadcn.TableCell _reportDataCell(String value, {Widget? child}) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.centerLeft,
        child: child ?? Text(value, style: _reportCellStyle(context)),
      ),
    );
  }

  Widget _buildCdslReportScreen(
      LDProvider ledgerprovider, ThemesProvider theme) {
    final data = ledgerprovider.cdslresponsedata!;
    final status =
        data.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.resstatus;
    final isinList =
        data.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.isinresdtls ?? [];

    final isDark = theme.isDarkMode;
    final borderColor =
        isDark ? MyntColors.cardBorderDark : MyntColors.cardBorder;
    final textPrimary =
        isDark ? colors.textPrimaryDark : colors.textPrimaryLight;
    final textSecondary =
        isDark ? colors.textSecondaryDark : colors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? colors.colorBlack : colors.colorWhite,
        leadingWidth: 41,
        titleSpacing: 6,
        centerTitle: false,
        elevation: 0.2,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor:
                isDark ? colors.splashColorDark : colors.splashColorLight,
            highlightColor:
                isDark ? colors.highlightDark : colors.highlightLight,
            onTap: () {
              ledgerprovider.resetCdslWebReport(context);
            },
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: textSecondary,
              ),
            ),
          ),
        ),
        title: TextWidget.titleText(
            text: "Pledge Report Details",
            textOverflow: TextOverflow.ellipsis,
            color: textPrimary,
            theme: isDark,
            fw: 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Card (table layout) ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _summaryRow('Client Name',
                                '${data.cLIENTNAME}', theme),
                            const SizedBox(height: 12),
                            _summaryRow(
                                'Client ID', '${data.uccid}', theme),
                            const SizedBox(height: 12),
                            _summaryRow('BO ID',
                                '${data.clientBoId}', theme),
                            const SizedBox(height: 12),
                            _summaryRow(
                                'Request ID',
                                '${data.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.reqid}',
                                theme),
                          ],
                        ),
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 1,
                      color: borderColor,
                    ),
                    // Right column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Status row with badge
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status',
                                    style: MyntWebTextStyles.bodySmall(
                                      context,
                                      darkColor:
                                          MyntColors.textSecondaryDark,
                                      lightColor:
                                          MyntColors.textSecondary,
                                      fontWeight: MyntFonts.medium,
                                    )),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    color: status == '0'
                                        ? colors.profitDark
                                            .withValues(alpha: 0.15)
                                        : status == '1'
                                            ? colors.lossDark
                                                .withValues(alpha: 0.15)
                                            : colors.pending
                                                .withValues(alpha: 0.15),
                                  ),
                                  child: Text(
                                    status == '0'
                                        ? 'Completed'
                                        : status == '1'
                                            ? 'Rejected'
                                            : 'Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: status == '0'
                                          ? isDark
                                              ? colors.profitDark
                                              : colors.profitLight
                                          : status == '1'
                                              ? isDark
                                                  ? colors.lossDark
                                                  : colors.lossLight
                                              : colors.pending,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _summaryRow(
                                'CDSL Requested Time',
                                '${data.pledgeReqTime}',
                                theme),
                            const SizedBox(height: 12),
                            _summaryRow(
                                'CDSL Response Time',
                                '${data.cDSLRespTime}',
                                theme),
                            const SizedBox(height: 12),
                            _summaryRow(
                                'CDSL ID',
                                '${data.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.resid}',
                                theme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Pledge Report Details Table (shadcn) ──
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final isinWidth = totalWidth * 0.25;
                final reqIdWidth = totalWidth * 0.20;
                final resIdWidth = totalWidth * 0.20;
                final qtyWidth = totalWidth * 0.15;
                final statusWidth = totalWidth * 0.20;

                final columnWidths = {
                  0: shadcn.FixedTableSize(isinWidth),
                  1: shadcn.FixedTableSize(reqIdWidth),
                  2: shadcn.FixedTableSize(resIdWidth),
                  3: shadcn.FixedTableSize(qtyWidth),
                  4: shadcn.FixedTableSize(statusWidth),
                };

                return shadcn.OutlinedContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isinList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child:
                                NoDataFound(secondaryEnabled: false),
                          ),
                        )
                      else ...[
                        // Header row
                        shadcn.Table(
                          defaultRowHeight:
                              const shadcn.FixedTableSize(44),
                          columnWidths: columnWidths,
                          rows: [
                            shadcn.TableHeader(
                              cells: [
                                _reportHeaderCell('ISIN'),
                                _reportHeaderCell('Reqired Id'),
                                _reportHeaderCell('Res Id'),
                                _reportHeaderCell('Quantity'),
                                _reportHeaderCell('Status'),
                              ],
                            ),
                          ],
                        ),
                        // Data rows
                        shadcn.Table(
                          defaultRowHeight:
                              const shadcn.FixedTableSize(48),
                          columnWidths: columnWidths,
                          rows: isinList.map((val) {
                            final isCompleted = val.status == '0';
                            return shadcn.TableRow(
                              cells: [
                                _reportDataCell('${val.isin}'),
                                _reportDataCell('${val.isinreqid}'),
                                _reportDataCell('${val.isinresid}'),
                                _reportDataCell('${val.quantity}'),
                                _reportDataCell(
                                  '',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      color: isCompleted
                                          ? colors.profitDark
                                              .withValues(alpha: 0.15)
                                          : colors.lossDark
                                              .withValues(alpha: 0.15),
                                    ),
                                    child: Text(
                                      isCompleted
                                          ? 'Completed'
                                          : 'Rejected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? isDark
                                                ? colors.profitDark
                                                : colors.profitLight
                                            : isDark
                                                ? colors.lossDark
                                                : colors.lossLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: MyntWebTextStyles.bodySmall(
              context,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary,
              fontWeight: MyntFonts.medium,
            )),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: MyntWebTextStyles.bodySmall(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.semiBold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Tabs + Search Row (combined, matching order book style)
  // ============================================================

  Widget _buildTabsAndSearchRow({
    required ThemesProvider theme,
    required int pledgeListCount,
    required int unpledgeListCount,
    required int nonApprovedCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Tabs on the left
          _buildTabItem('Available Balance', pledgeListCount, '0', theme),
          _buildTabItem('Pledge Balance', unpledgeListCount, '1', theme),
          _buildTabItem('Non Approved', nonApprovedCount, '2', theme),
          const Spacer(),
          // Search field
          SizedBox(
            width: 260,
            child: MyntSearchTextField.withSmartClear(
              controller: searchController,
              focusNode: searchFocusNode,
              placeholder: 'Search',
              leadingIcon: assets.searchIcon,
              onChanged: (value) {
                _onSearchChanged(value);
              },
              onClear: () {
                searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
          const SizedBox(width: 8),
          // Filter button
          _buildFilterButton(theme),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemesProvider theme) {
    return Builder(
      builder: (buttonContext) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showFilterPopup(buttonContext, theme),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  assets.searchFilter,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    resolveThemeColor(
                      context,
                      dark: MyntColors.iconDark,
                      light: MyntColors.icon,
                    ),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterPopup(BuildContext context, ThemesProvider theme) {
    shadcn.showPopover(
      context: context,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 8),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(context).borderRadiusLg,
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterMenuItem('All', 'all', theme),
                  _buildFilterMenuItem('Cash', 'cash', theme),
                  _buildFilterMenuItem('Non-Cash', 'noncash', theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterMenuItem(
      String label, String filterValue, ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final ledgerprovider = ref.watch(ledgerProvider);
        final isSelected = ledgerprovider.pledgeCashFilter == filterValue;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ledgerprovider.setPledgeCashFilter(filterValue);
              shadcn.closeOverlay(context);
            },
            splashColor: resolveThemeColor(
              context,
              dark: MyntColors.rippleDark,
              light: MyntColors.rippleLight,
            ),
            highlightColor: resolveThemeColor(
              context,
              dark: MyntColors.highlightDark,
              light: MyntColors.highlightLight,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark.withValues(alpha: 0.12),
                        light: const Color(0xFFE8F0FE),
                      )
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: MyntWebTextStyles.body(
                        context,
                        fontWeight: isSelected
                            ? MyntFonts.semiBold
                            : MyntFonts.medium,
                        color: isSelected
                            ? resolveThemeColor(
                                context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary,
                              )
                            : resolveThemeColor(
                                context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
      String title, int count, String filterType, ThemesProvider theme) {
    final isActive = selectedFilterType == filterType;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilterType = filterType;
            searchController.clear();
            searchQuery = '';
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (theme.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: isActive ? MyntFonts.semiBold : MyntFonts.medium,
                ).copyWith(
                  color: isActive
                      ? shadcn.Theme.of(context).colorScheme.foreground
                      : shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    '$count',
                    style: MyntWebTextStyles.bodySmall(
                      context,
                      fontWeight:
                          isActive ? MyntFonts.semiBold : MyntFonts.medium,
                    ).copyWith(
                      fontSize: 13,
                      color: isActive
                          ? shadcn.Theme.of(context).colorScheme.foreground
                          : shadcn.Theme.of(context)
                              .colorScheme
                              .mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Stats Header
  // ============================================================

  Widget _buildSummaryCards({
    required ThemesProvider theme,
    required LDProvider ledgerprovider,
    required String displayLabel,
    required String displayValue,
  }) {
    final pledgeData = ledgerprovider.pledgeandunpledge;
    final totalValue = pledgeData?.stocksValue?.toString() ?? '0.00';
    final cashEquivalent = pledgeData?.cashEquivalent?.toString() ?? '0.00';
    final nonCashEquivalent = pledgeData?.noncashEquivalent?.toString() ?? '0.00';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 800 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 100,
            ),
            children: [
              _buildStatCard(
                label: 'Total Value',
                value: totalValue == 'null' ? '0.00' : totalValue,
                theme: theme,
              ),
              _buildStatCard(
                label: 'Cash Equivalent / Non Cash',
                value: '${cashEquivalent == 'null' ? '0.00' : cashEquivalent} / ${nonCashEquivalent == 'null' ? '0.00' : nonCashEquivalent}',
                theme: theme,
              ),
              _buildStatCard(
                label: displayLabel,
                value: displayValue,
                prefix: '₹ ',
                theme: theme,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required ThemesProvider theme,
    String? prefix,
  }) {
    return shadcn.Theme(
      data: shadcn.Theme.of(context).copyWith(radius: () => 0.3),
      child: shadcn.Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Row(
            children: [
              const SizedBox(width: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary,
                        ),
                        fontWeight: MyntFonts.medium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prefix ?? ''}$value',
                      style: MyntWebTextStyles.head(
                        context,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary,
                        ),
                        fontWeight: MyntFonts.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Selected Scripts Label with hover tooltip
  // ============================================================

  Widget _buildSelectedScriptsLabel(
      LDProvider ledgerprovider, ThemesProvider theme) {
    final count = ledgerprovider.listforpledge.length;

    final tooltipLines = ledgerprovider.listforpledge.map((item) {
      final symbol = item['symbol'] ?? '-';
      final qty = item['quantity'] ?? '-';
      final segment = item['segments'] ?? '';
      return segment.isNotEmpty
          ? '$symbol  ·  Qty: $qty  ·  $segment'
          : '$symbol  ·  Qty: $qty';
    }).join('\n');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count Script Selected',
          style: MyntWebTextStyles.bodySmall(
            context,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
            fontWeight: MyntFonts.medium,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: tooltipLines,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? const Color(0xFF2A2A2A)
                : colors.colorWhite,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: resolveThemeColor(context,
                  dark: MyntColors.borderMutedDark,
                  light: MyntColors.borderMuted),
            ),
          ),
          textStyle: MyntWebTextStyles.para(
            context,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
            fontWeight: MyntFonts.medium,
          ),
          waitDuration: const Duration(milliseconds: 200),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'View Scripts',
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary),
                fontWeight: MyntFonts.medium,
              ).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: resolveThemeColor(context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PledgeListDetails - kept for backward compatibility
// ============================================================

class PledgeListDetails extends StatefulWidget {
  final String filterType;
  final String title;

  const PledgeListDetails(
      {super.key, required this.filterType, required this.title});

  @override
  State<PledgeListDetails> createState() => _PledgeListDetailsState();
}

class _PledgeListDetailsState extends State<PledgeListDetails> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (isSearching) {
        searchFocusNode.requestFocus();
      } else {
        searchController.clear();
        searchQuery = '';
        searchFocusNode.unfocus();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.watch(ledgerProvider);

      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: widget.title,
              textOverflow: TextOverflow.ellipsis,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 1),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PledgeFilter(
                  activetabe: widget.filterType,
                  searchQuery: searchQuery,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

