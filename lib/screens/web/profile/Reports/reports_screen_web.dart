import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';

import '../../customizable_split_home_screen.dart' show ScreenType;
import 'ledger/ledger_screen.dart';

/// Report item model
class _ReportItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
      label: 'Trading Activity',
      items: [
        _ReportItem(
          title: 'Ledger',
          subtitle: 'Financial ledger and fund movements',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFFC62828),
        ),       
        _ReportItem(
          title: 'Positions',
          subtitle: 'Open and closed position details',
          icon: Icons.stacked_line_chart_rounded,
          color: Color(0xFF00838F),
        ),
         _ReportItem(
          title: 'Tradebook',
          subtitle: 'Complete history of executed trades',
          icon: Icons.swap_horiz_rounded,
          color: Color(0xFF7B1FA2),
        ),
      ],
    ),
    _ReportCategory(
      label: 'Profit & Loss',
      items: [
        _ReportItem(
          title: 'P&L Summary',
          subtitle: 'Calendar-wise realized P&L overview',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF2E7D32),
        ),
        _ReportItem(
          title: 'Tax P&L',
          subtitle: 'Tax computation for capital gains',
          icon: Icons.receipt_long_rounded,
          color: Color(0xFFE65100),
        ),
        _ReportItem(
          title: 'Notional P&L',
          subtitle: 'Unrealized profit & loss details',
          icon: Icons.trending_up_rounded,
          color: Color(0xFF1565C0),
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
          color: Color(0xFF283593),
        ),
        _ReportItem(
          title: 'Client Master(CMR)',
          subtitle: 'Download client master report',
          icon: Icons.person_outline_rounded,
          color: Color(0xFF558B2F),
        ),
        _ReportItem(
          title: 'CA Events',
          subtitle: 'Corporate action events tracker',
          icon: Icons.event_note_rounded,
          color: Color(0xFFF9A825),
        ),
        _ReportItem(
          title: 'PDF Download',
          subtitle: 'Download reports as PDF files',
          icon: Icons.picture_as_pdf_rounded,
          color: Color(0xFFD32F2F),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = isDarkMode(context);
    final ledgerdate = ref.watch(ledgerProvider);

    return Scaffold(
      backgroundColor:
          dark ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Text(
              'Reports',
              style: MyntWebTextStyles.hero(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Access all your financial reports and documents',
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Categories with card grids
            ..._categories.expand((category) => [
                  // Category label
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
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

                  // Cards grid using LayoutBuilder + Wrap
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount =
                          width > 900 ? 3 : width > 600 ? 2 : 1;
                      const spacing = 8.0;
                      final itemWidth =
                          (width - (spacing * (crossAxisCount - 1))) /
                              crossAxisCount;
                      final itemHeight = itemWidth / 4.5;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: category.items.map((item) {
                          return SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child: _ReportCard(
                              item: item,
                              onTap: () => _handleTap(
                                  context, item.title, ledgerdate),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ]),
          ],
        ),
      ),
    );
  }

  void _handleTap(
      BuildContext context, String title, LDProvider ledgerdate) async {
    switch (title) {
      case 'P&L Summary':
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

/// Individual report card matching Account Settings card layout
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
        ? (dark
            ? MyntColors.primaryDark.withValues(alpha: 0.4)
            : MyntColors.primary.withValues(alpha: 0.25))
        : (dark ? MyntColors.cardBorderDark : MyntColors.cardBorder);

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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: dark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: dark
                      ? item.color.withValues(alpha: 0.9)
                      : item.color,
                ),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: MyntWebTextStyles.body(
                        context,
                        fontWeight: MyntFonts.medium,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        darkColor: MyntColors.textTertiaryDark,
                        lightColor: MyntColors.textTertiary,
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
