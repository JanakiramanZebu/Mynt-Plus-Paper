import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';


enum SingingCharacter { all, eq, fno, com, cur }

class PnlFliter extends StatefulWidget {
  const PnlFliter({super.key});

  @override
  State<PnlFliter> createState() => _PnlFliter();
}

SingingCharacter? _character = SingingCharacter.all;

class _PnlFliter extends State<PnlFliter> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerprovider = watch(ledgerProvider);
      final filval = ledgerprovider.filterval;

      // if (filval == 'all') {
      //   _character = SingingCharacter.all;
      // } else {
      //   _character = SingingCharacter.fno;
      // }
      return DraggableScrollableSheet(
        initialChildSize: 0.43,
        minChildSize: .05,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(
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
                        padding: const EdgeInsets.only(top: 15.0, left: 25.0),
                        child: Text(
                          "Filter",
                          style: textStyle(Colors.black, 20, FontWeight.w500),
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
                  radiobtn('All', SingingCharacter.all),
                  radiobtn('Equity', SingingCharacter.eq),
                  radiobtn('FNO', SingingCharacter.fno),
                  radiobtn('Commodity', SingingCharacter.com),
                  radiobtn('Currency', SingingCharacter.cur),
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
                  //   title: const Text('eq'),
                  //   leading: Radio<SingingCharacter>(
                  //     value: SingingCharacter.eq,
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
                  //   title: const Text('com'),
                  //   leading: Radio<SingingCharacter>(
                  //     value: SingingCharacter.com,
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
                  //   title: const Text('fno'),
                  //   leading: Radio<SingingCharacter>(
                  //     activeColor: Colors.black,
                  //     value: SingingCharacter.fno,
                  //     groupValue: _character,
                  //     onChanged: (SingingCharacter? value) {
                  //       setState(() {
                  //         _character = value;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // ListTile(
                  //   title: const Text('System fno'),
                  //   leading: Radio<SingingCharacter>(
                  //     value: SingingCharacter.cur,
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
          );
        },
      );
    });
  }

  ListTile radiobtn(String test, SingingCharacter value) {
    return ListTile(
      title: Text(test),
      leading: Radio<SingingCharacter>(
        value: value,
        groupValue: _character,
        activeColor: Colors.black,
        onChanged: (SingingCharacter? newvalue) {
          setState(() {
            // Ensure UI rebuilds when selection changes
            Navigator.pop(context);
            print("${newvalue}");
            _character = newvalue;
          });
        },
      ),
    );
  }
}
