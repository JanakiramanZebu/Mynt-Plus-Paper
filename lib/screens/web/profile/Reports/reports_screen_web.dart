import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/app_spacing.dart';
import 'package:mynt_plus/res/responsive_extensions.dart';

import '../../customizable_split_home_screen.dart' show ScreenType;
import 'ledger/ledger_screen.dart';

/// Report item model
class _ReportItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgLight;
  final Color iconBgDark;
  final Color iconColorLight;
  final Color iconColorDark;

  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgLight,
    required this.iconBgDark,
    required this.iconColorLight,
    required this.iconColorDark,
  });
}

/// Report category model
class _ReportCategory {
  final String label;
  final List<_ReportItem> items;

  const _ReportCategory({required this.label, required this.items});
}

class ReportsScreenWeb extends ConsumerWidget {
  final Function(dynamic)? onNavigateToScreen;

  const ReportsScreenWeb({super.key, this.onNavigateToScreen});

  static const _categories = [
    _ReportCategory(
      label: 'Profit & Loss',
      items: [
        _ReportItem(
          title: 'Calender P&L',
          subtitle: 'Calendar-wise realized P&L overview',
          icon: Icons.calendar_month_rounded,
          iconBgLight: Color(0xFFE8F5E9),
          iconBgDark: Color(0xFF1B3A26),
          iconColorLight: Color(0xFF2E7D32),
          iconColorDark: Color(0xFF66BB6A),
        ),
        _ReportItem(
          title: 'Tax P&L',
          subtitle: 'Tax computation for capital gains',
          icon: Icons.receipt_long_rounded,
          iconBgLight: Color(0xFFFFF3E0),
          iconBgDark: Color(0xFF3A2E1B),
          iconColorLight: Color(0xFFE65100),
          iconColorDark: Color(0xFFFFB74D),
        ),
        _ReportItem(
          title: 'Notional P&L',
          subtitle: 'Unrealized profit & loss details',
          icon: Icons.trending_up_rounded,
          iconBgLight: Color(0xFFE3F2FD),
          iconBgDark: Color(0xFF1B2A3A),
          iconColorLight: Color(0xFF1565C0),
          iconColorDark: Color(0xFF64B5F6),
        ),
      ],
    ),
    _ReportCategory(
      label: 'Trading Activity',
      items: [
        _ReportItem(
          title: 'Tradebook',
          subtitle: 'Complete history of executed trades',
          icon: Icons.swap_horiz_rounded,
          iconBgLight: Color(0xFFF3E5F5),
          iconBgDark: Color(0xFF2A1B3A),
          iconColorLight: Color(0xFF7B1FA2),
          iconColorDark: Color(0xFFCE93D8),
        ),
        _ReportItem(
          title: 'Positions',
          subtitle: 'Open and closed position details',
          icon: Icons.stacked_line_chart_rounded,
          iconBgLight: Color(0xFFE0F7FA),
          iconBgDark: Color(0xFF1B3338),
          iconColorLight: Color(0xFF00838F),
          iconColorDark: Color(0xFF4DD0E1),
        ),
        _ReportItem(
          title: 'Ledger',
          subtitle: 'Financial ledger and fund movements',
          icon: Icons.account_balance_wallet_rounded,
          iconBgLight: Color(0xFFFCE4EC),
          iconBgDark: Color(0xFF3A1B24),
          iconColorLight: Color(0xFFC62828),
          iconColorDark: Color(0xFFEF9A9A),
        ),
      ],
    ),
    _ReportCategory(
      label: 'Documents',
      items: [
        _ReportItem(
          title: 'Contract Note',
          subtitle: 'Daily trade contract notes',
          icon: Icons.description_rounded,
          iconBgLight: Color(0xFFE8EAF6),
          iconBgDark: Color(0xFF1B1F3A),
          iconColorLight: Color(0xFF283593),
          iconColorDark: Color(0xFF9FA8DA),
        ),
        _ReportItem(
          title: 'Client Master(CMR)',
          subtitle: 'Download client master report',
          icon: Icons.person_outline_rounded,
          iconBgLight: Color(0xFFF1F8E9),
          iconBgDark: Color(0xFF243A1B),
          iconColorLight: Color(0xFF558B2F),
          iconColorDark: Color(0xFFAED581),
        ),
        _ReportItem(
          title: 'CA Events',
          subtitle: 'Corporate action events tracker',
          icon: Icons.event_note_rounded,
          iconBgLight: Color(0xFFFFF8E1),
          iconBgDark: Color(0xFF3A351B),
          iconColorLight: Color(0xFFF9A825),
          iconColorDark: Color(0xFFFFD54F),
        ),
        _ReportItem(
          title: 'PDF Download',
          subtitle: 'Download reports as PDF files',
          icon: Icons.picture_as_pdf_rounded,
          iconBgLight: Color(0xFFFFEBEE),
          iconBgDark: Color(0xFF3A1B1B),
          iconColorLight: Color(0xFFD32F2F),
          iconColorDark: Color(0xFFEF5350),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = isDarkMode(context);
    final ledgerdate = ref.watch(ledgerProvider);

    return Scaffold(
      backgroundColor: dark
          ? MyntColors.backgroundColorDark
          : MyntColors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
                child: Text(
                  'Reports',
                  style: MyntWebTextStyles.hero(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                child: Text(
                  'Access all your financial reports and documents',
                  style: MyntWebTextStyles.para(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                ),
              ),
            ),

            // Categories
            ..._categories.expand((category) => [
                  // Category label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                          AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                      child: Text(
                        category.label,
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          fontWeight: MyntFonts.semiBold,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary),
                        ),
                      ),
                    ),
                  ),

                  // Cards grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = context.responsiveValue(
                          mobile: 1,
                          smallTablet: 2,
                          tablet: 2,
                          desktop: 3,
                          largeDesktop: 3,
                          widescreen: 4,
                        );
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: context.responsiveValue(
                              mobile: 3.8,
                              smallTablet: 2.8,
                              tablet: 2.8,
                              desktop: 3.0,
                              largeDesktop: 3.2,
                            ),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _ReportCard(
                              item: category.items[index],
                              onTap: () => _handleTap(
                                  context,
                                  category.items[index].title,
                                  ledgerdate),
                            ),
                            childCount: category.items.length,
                          ),
                        );
                      },
                    ),
                  ),
                ]),

            // Bottom spacing + version
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      ref.watch(authProvider).versiontext,
                      style: MyntWebTextStyles.caption(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textTertiaryDark,
                            light: MyntColors.textTertiary),
                      ),
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

  void _handleTap(
      BuildContext context, String title, LDProvider ledgerdate) async {
    switch (title) {
      case 'Calender P&L':
        await ledgerdate.getCurrentDate('pandu');
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.calendarPnl);
        }
        break;
      case 'Tax P&L':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.taxPnl);
        }
        break;
      case 'Notional P&L':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.notionalPnl);
        }
        break;
      case 'Ledger':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.ledger);
        } else {
          await ledgerdate.getCurrentDate('else');
          ledgerdate.fetchLegerData(context, ledgerdate.startDate,
              ledgerdate.endDate, ledgerdate.includeBillMargin);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LedgerScreen(ddd: "DDDDD"),
            ),
          );
        }
        break;
      case 'Tradebook':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.tradebook);
        }
        break;
      case 'Contract Note':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.contractNote);
        }
        break;
      case 'Client Master(CMR)':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.clientMaster);
        }
        break;
      case 'Positions':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.reportPositions);
        }
        break;
      case 'CA Events':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.corporateActions);
        }
        break;
      case 'PDF Download':
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(ScreenType.pdfDownload);
        }
        break;
    }
  }
}

/// Individual report card with hover effect
class _ReportCard extends StatefulWidget {
  final _ReportItem item;
  final VoidCallback onTap;

  const _ReportCard({required this.item, required this.onTap});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    final item = widget.item;

    final bgColor = _hovered
        ? (dark ? MyntColors.cardHoverDark : MyntColors.cardHover)
        : (dark ? MyntColors.cardDark : MyntColors.card);

    final borderColor = _hovered
        ? (dark ? MyntColors.primaryDark.withValues(alpha: 0.4) : MyntColors.primary.withValues(alpha: 0.25))
        : (dark ? MyntColors.cardBorderDark : MyntColors.cardBorder);

    // final shadow = _hovered
    //     ? (dark ? MyntShadows.cardHoverDark : MyntShadows.cardHover)
    //     : (dark ? MyntShadows.cardDark : MyntShadows.card);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: Border.all(color: borderColor, width: 1),
            // boxShadow: shadow,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dark ? item.iconBgDark : item.iconBgLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: dark ? item.iconColorDark : item.iconColorLight,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),

              // Text content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: MyntWebTextStyles.bodyMedium(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: MyntWebTextStyles.caption(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textTertiaryDark,
                            light: MyntColors.textTertiary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _hovered ? 1.0 : 0.4,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _hovered
                      ? (dark
                          ? MyntColors.primaryDark
                          : MyntColors.primary)
                      : resolveThemeColor(context,
                          dark: MyntColors.textTertiaryDark,
                          light: MyntColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
