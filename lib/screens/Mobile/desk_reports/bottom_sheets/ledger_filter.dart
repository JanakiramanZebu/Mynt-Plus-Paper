import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/Mobile/authentication/password/forgot_pass_unblock_user.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';
import 'package:flutter_svg/svg.dart';

enum SingingCharacter {
  receipt,
  journal,
  payment,
  systemjournal,
  billmargin, // Add this
  eq,
  fno,
  com,
  cur,
  buy,
  sell,
  marginstatement,
  contract,
  weekstate,
  cn,
  ledgerdetails,
  rr,
  agts
}

class LedgerFilter extends ConsumerStatefulWidget {
  const LedgerFilter({super.key});

  @override
  ConsumerState<LedgerFilter> createState() => _LedgerFilter();
}

class _LedgerFilter extends ConsumerState<LedgerFilter> {
  Set<SingingCharacter> selectedLedgerFilters = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFilters = ref.read(ledgerProvider).selectedFilters;
      final allFilters = {
        SingingCharacter.receipt,
        SingingCharacter.payment,
        SingingCharacter.journal,
        SingingCharacter.systemjournal,
        SingingCharacter.billmargin
      };
      setState(() {
        if (currentFilters.length == allFilters.length &&
            allFilters.difference(currentFilters).isEmpty) {
          // If provider's filters are 'all', show all selected
          selectedLedgerFilters = allFilters;
        } else if (currentFilters.isEmpty) {
          // First time: select all
          selectedLedgerFilters = allFilters;
        } else {
          selectedLedgerFilters = Set.from(currentFilters);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ledgerprovider = ref.watch(ledgerProvider);
    final theme = ref.watch(themeProvider);

    return SafeArea(
      child: Container(
       decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
      
           
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const CustomDragHandler(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      text: "Filter",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 10),
            const ListDivider(),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.6, // Max 60% of screen height
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (ledgerprovider.currentfilterpage == 'ledger') ...[
                      checkboxTile('Receipt', SingingCharacter.receipt, theme),
                      checkboxTile('Payment', SingingCharacter.payment, theme),
                      checkboxTile('Journal', SingingCharacter.journal, theme),
                      checkboxTile('System Journal', SingingCharacter.systemjournal, theme),
                      checkboxTile('Bill Margin', SingingCharacter.billmargin, theme),
                      const ListDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            minimumSize: const Size(0, 45),
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  ledgerprovider.applyLedgerMultiFilter(
                                      context, selectedLedgerFilters.toList());
                                  Future.microtask(() => Navigator.pop(context));
                                },
                          child: _isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.colorWhite),
                                  ),
                                )
                              : TextWidget.subText(
                                  text: "Apply",
                                  color: colors.colorWhite,
                                  theme: theme.isDarkMode,
                                  fw: 2,
                                ),
                        ),
                      ),
                    ] else if (ledgerprovider.currentfilterpage == 'pnl') ...[
                          radiobtn(
                              'Equity', SingingCharacter.eq, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn(
                              'FNO', SingingCharacter.fno, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('Commodity', SingingCharacter.com, ledgerprovider,
                              theme),
                          const ListDivider(),
                          radiobtn('Currency', SingingCharacter.cur, ledgerprovider,
                              theme),
                        ] else if (ledgerprovider.currentfilterpage ==
                            'tradebook') ...[
                          radiobtn(
                              'Equity', SingingCharacter.eq, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn(
                              'FNO', SingingCharacter.fno, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('Commodity', SingingCharacter.com, ledgerprovider,
                              theme),
                          const ListDivider(),
                          radiobtn('Currency', SingingCharacter.cur, ledgerprovider,
                              theme),
                          const ListDivider(),
                          radiobtn(
                              'Buy', SingingCharacter.buy, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn(
                              'Sell', SingingCharacter.sell, ledgerprovider, theme),
                        ] else if (ledgerprovider.currentfilterpage ==
                            'pdfdownload') ...[
                          radiobtn(
                              'Margin Statement',
                              SingingCharacter.marginstatement,
                              ledgerprovider,
                              theme),
                          const ListDivider(),
                          radiobtn('Contract', SingingCharacter.contract,
                              ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('Weekly Statement', SingingCharacter.weekstate,
                              ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('CN', SingingCharacter.cn, ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('Ledger Detail', SingingCharacter.ledgerdetails,
                              ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('Retention Report', SingingCharacter.rr,
                              ledgerprovider, theme),
                          const ListDivider(),
                          radiobtn('AGTS Report', SingingCharacter.agts,
                              ledgerprovider, theme),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
      
    
  }

  Widget checkboxTile(
      String label, SingingCharacter value, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        onTap: () {
          setState(() {
            if (selectedLedgerFilters.contains(value)) {
              selectedLedgerFilters.remove(value);
            } else {
              selectedLedgerFilters.add(value);
            }
          });
        },
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 24,
          leading: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              theme.isDarkMode
                  ? selectedLedgerFilters.contains(value)
                      ? assets.darkCheckedboxIcon
                      : assets.darkCheckboxIcon
                  : selectedLedgerFilters.contains(value)
                      ? assets.ckeckedboxIcon
                      : assets.ckeckboxIcon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          title: TextWidget.subText(
            text: label,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ),
      ),
    );
  }

  ListTile radiobtn(String test, SingingCharacter value,
      LDProvider ledgerprovider, ThemesProvider theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      minLeadingWidth: 24,
      title: TextWidget.subText(
        text: test,
        color:
            theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        theme: theme.isDarkMode,
        fw: 0,
      ),
      leading: Radio<SingingCharacter>(
        value: value,
        groupValue: ledgerprovider.filterval,
        activeColor: theme.isDarkMode ? Colors.white : Colors.black,
        onChanged: (SingingCharacter? newvalue) {
          _handleSelection(newvalue, ledgerprovider);
        },
      ),
      onTap: () {
        _handleSelection(value, ledgerprovider);
      },
    );
  }

  void _handleSelection(SingingCharacter? newvalue, LDProvider ledgerprovider) {
    if (newvalue != null) {
      ledgerprovider.setfilterval = newvalue;
      ledgerprovider.ledgerfiltercall(context, newvalue);
      Future.microtask(() => Navigator.pop(context));
    }
  }
}
