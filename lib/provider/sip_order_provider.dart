// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../res/res.dart';
import 'core/default_change_notifier.dart';

final siprovider = ChangeNotifierProvider((ref) => SipProvider(ref.read));

class SipProvider extends DefaultChangeNotifier {
  final Preferences pref = locator<Preferences>();
  final api = locator<ApiExporter>();
  final Reader ref;
  SipProvider(this.ref);

  final TextEditingController datefield = TextEditingController();
  final TextEditingController numberofSips = TextEditingController();
  final TextEditingController modifysipdate = TextEditingController();
// set sip order start date
  startdatemethod(String value) {
    DateTime now = DateTime.now();
    selectedDateTime = now;
    String sd = DateFormat('dd-MM-yyyy').format(selectedDateTime ?? now);
    datefield.text = sd;
    notifyListeners();
  }

  DateTime? selectedDateTime;
// Date picket dialogue

  Future providedate(
      BuildContext context, ThemesProvider theme, String value) async {
    DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.grey.withOpacity(.3),
              colorScheme: ColorScheme.light(
                  primary: colors.colorBlue,
                  surface: theme.isDarkMode
                      ? const Color.fromARGB(255, 18, 18, 18)
                      : Colors.white,
                  onSurface: theme.isDarkMode ? Colors.white : Colors.black,
                  secondary: theme.isDarkMode ? Colors.black : Colors.white),
            ),
            child: child ?? const Text(""),
          );
        },
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        currentDate: now,
        initialDate: value == "1" ? now : selectedDateTime ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 50));

    if (pickedDate != null) {
      selectedDateTime = pickedDate;
      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDateTime!);
      datefield.text = formattedDate;
      String formattedDates = DateFormat('dd-MM-yyyy').format(pickedDate);
      modifysipdate.text = formattedDates;
    }
    notifyListeners();
  }
}
