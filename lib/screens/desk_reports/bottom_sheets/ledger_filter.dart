import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';

enum SingingCharacter {
  all,
  receipt,
  journal,
  payment,
  systemjournal,
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

class LedgerFilter extends StatefulWidget {
  const LedgerFilter({super.key});

  @override
  State<LedgerFilter> createState() => _LedgerFilter();
}

// SingingCharacter? _character;

class _LedgerFilter extends State<LedgerFilter> {
  @override
  void initState() {
    setState(() {
      // _character = context.read(ledgerProvider).filterval;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerprovider = watch(ledgerProvider);
      final filval = ledgerprovider.filterval;
      final theme = watch(themeProvider);

      return DraggableScrollableSheet(
        initialChildSize: ledgerprovider.currentfilterpage == 'tradebook'
            ? 0.58
            : ledgerprovider.currentfilterpage == 'pdfdownload'
                ? 0.65
                : 0.5, // Adjust for large/small screens
        minChildSize: 0.05, // Adjust min size
        maxChildSize: 0.99, // Always near full screen
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                   color: theme.isDarkMode
                ? Color.fromARGB(255, 0, 0, 0)
                : const Color(0xffF1F3F8)),
          
            child: Column(
              children: [
                Container(
                  color: const Color.fromARGB(255, 219, 218, 218),
                  width: 40,
                  height: 4.0,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 25, left: 20, right: 20),
                  margin: EdgeInsets.only(top: 16),
                ),
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 25.0),
                          child: Text(
                            "Filter",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                20,
                                FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Divider(
                            color: const Color.fromARGB(255, 212, 212, 212),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    // Text("${ledgerprovider.currentfilterpage}"),
                    if (ledgerprovider.currentfilterpage == 'ledger') ...[
                      radiobtn(
                          'All', SingingCharacter.all, ledgerprovider, theme),
                      radiobtn('Receipt', SingingCharacter.receipt,
                          ledgerprovider, theme),
                      radiobtn('Payment', SingingCharacter.payment,
                          ledgerprovider, theme),
                      radiobtn('Journal', SingingCharacter.journal,
                          ledgerprovider, theme),
                      radiobtn('System Journal', SingingCharacter.systemjournal,
                          ledgerprovider, theme),
                    ] else if (ledgerprovider.currentfilterpage == 'pnl') ...[
                      radiobtn(
                          'All', SingingCharacter.all, ledgerprovider, theme),
                      radiobtn(
                          'Equity', SingingCharacter.eq, ledgerprovider, theme),
                      radiobtn(
                          'FNO', SingingCharacter.fno, ledgerprovider, theme),
                      radiobtn('Commodity', SingingCharacter.com,
                          ledgerprovider, theme),
                      radiobtn('Currency', SingingCharacter.cur, ledgerprovider,
                          theme),
                    ] else if (ledgerprovider.currentfilterpage ==
                        'tradebook') ...[
                      radiobtn(
                          'All', SingingCharacter.all, ledgerprovider, theme),
                      radiobtn(
                          'Equity', SingingCharacter.eq, ledgerprovider, theme),
                      radiobtn(
                          'FNO', SingingCharacter.fno, ledgerprovider, theme),
                      radiobtn('Commodity', SingingCharacter.com,
                          ledgerprovider, theme),
                      radiobtn('Currency', SingingCharacter.cur, ledgerprovider,
                          theme),
                      radiobtn(
                          'Buy', SingingCharacter.buy, ledgerprovider, theme),
                      radiobtn(
                          'Sell', SingingCharacter.sell, ledgerprovider, theme),
                    ] else if (ledgerprovider.currentfilterpage ==
                        'pdfdownload') ...[
                      radiobtn(
                          'All', SingingCharacter.all, ledgerprovider, theme),
                      radiobtn(
                          'Margin Statement',
                          SingingCharacter.marginstatement,
                          ledgerprovider,
                          theme),
                      radiobtn('Contract', SingingCharacter.contract,
                          ledgerprovider, theme),
                      radiobtn('Weekly Statement', SingingCharacter.weekstate,
                          ledgerprovider, theme),
                      radiobtn(
                          'CN', SingingCharacter.cn, ledgerprovider, theme),
                      radiobtn('Ledger Detail', SingingCharacter.ledgerdetails,
                          ledgerprovider, theme),
                      radiobtn('Retention Report', SingingCharacter.rr,
                          ledgerprovider, theme),
                      radiobtn('AGTS Report', SingingCharacter.agts,
                          ledgerprovider, theme),
                    ],

                    // ListTile(
                    //   title: const Text('All'),
                    //   leading: Radio<SingingCharacter>(
                    //     value: SingingCharacter.all,
                    //     groupValue: _character,
                    //     activeColor: Colors.black,
                    //     onChanged: (SingingCharacter? value) {
                    //       setState(() {
                    //         _character = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('Receipt'),
                    //   leading: Radio<SingingCharacter>(
                    //     value: SingingCharacter.receipt,
                    //     groupValue: _character,
                    //     activeColor: Colors.black,
                    //     onChanged: (SingingCharacter? value) {
                    //       setState(() {
                    //         _character = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('Payment'),
                    //   leading: Radio<SingingCharacter>(
                    //     value: SingingCharacter.payment,
                    //     groupValue: _character,
                    //     activeColor: Colors.black,
                    //     onChanged: (SingingCharacter? value) {
                    //       setState(() {
                    //         _character = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('Journal'),
                    //   leading: Radio<SingingCharacter>(
                    //     activeColor: Colors.black,
                    //     value: SingingCharacter.journal,
                    //     groupValue: _character,
                    //     onChanged: (SingingCharacter? value) {
                    //       setState(() {
                    //         _character = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('System Journal'),
                    //   leading: Radio<SingingCharacter>(
                    //     value: SingingCharacter.systemjournal,
                    //     activeColor: Colors.black,
                    //     groupValue: _character,
                    //     onChanged: (SingingCharacter? value) {
                    //       setState(() {
                    //         _character = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                // Container(
                //     height: 45,
                //     width: screenWidth - 50,
                //     margin: const EdgeInsets.only(right: 12, top: 15),
                //     child: ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //             elevation: 0,
                //             shadowColor: Colors.transparent,
                //             backgroundColor: colors.colorBlack,
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(50))),
                //         onPressed: () async {
                //           Navigator.pop(context);
                //         },
                //         child: Text("Get",
                //             textAlign: TextAlign.center,
                //             style: textStyle(
                //                 colors.colorWhite, 12, FontWeight.w500)))),
              ],
            ),
          );
        },
      );
    });
  }

  ListTile radiobtn(String test, SingingCharacter value,
      LDProvider ledgerprovider, ThemesProvider theme) {
    return ListTile(
      title: Text(
        test,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500),
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
        // Trigger the same action when tapping on the tile
        _handleSelection(value, ledgerprovider);
      },
    );
  }

  void _handleSelection(SingingCharacter? newvalue, LDProvider ledgerprovider) {
    if (newvalue != null) {
      ledgerprovider.setfilterval = newvalue;
      ledgerprovider.ledgerfiltercall(context,newvalue);
      Navigator.pop(context);
    }
  }
}
