import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final NumberFormat numberFormat = NumberFormat("##,##,##,##,##0.00", "hi");

String getFormatter(
    {required double value, required bool v4d, required bool noDecimal}) {
  const String formatWith2 = "##,##,##,##,##0.00";
  const String formatWith4 = "##,##,##,##,##0.0000";
  const String formatWith0 = "##,##,##,###";
  return NumberFormat(noDecimal
          ? formatWith0
          : v4d
              ? formatWith4
              : formatWith2)
      .format(value);
}

bool isNumberNegative(String num) {
  return num.startsWith('-');
}

String getFormatedNumValue(
  String number, {
  bool showSign = true,
  required int afterPoint,
}) {
  final String num = (number == "inf" || number == 'null') ? "0.00" : number;
  final bool isNeg = num.startsWith('-');
  final double val = double.parse(isNeg
      ? num.toString().replaceAll(',', '').substring(1)
      : num.toString().replaceAll(',', ''));

  if (val == 0) {
    return afterPoint == 0 ? "00" : "00.00";
  } else {
    return isNeg
        ? "-${val.toStringAsFixed(afterPoint)}"
        : showSign
            ? "+${val.toStringAsFixed(afterPoint)}"
            : val.toStringAsFixed(afterPoint);
  }
}

String formatCurrencyStandard({required String value}) {
  String formatedCurrency = '';
  if (value.isNotEmpty) {
    if (value.indexOf(",") > 0) {
      value = value.replaceAll(',', '');
    }
    final double formatValue = double.parse(value);
    formatedCurrency = numberFormat.format(formatValue);
  }
  return formatedCurrency;
}

String formatDateTime({required String value}) {
  String formatedDate = '';
  if (value.isNotEmpty) {
    final inputDatetimeString = value;
    final inputFormat = DateFormat("HH:mm:ss dd-MM-yyyy");
    final inputDatetime = inputFormat.parse(inputDatetimeString);
    // Format the datetime in the desired format
    final outputFormat = DateFormat("dd MMM yyyy, hh:mm a");
    final formattedDatetime = outputFormat.format(inputDatetime);
    formatedDate = formattedDatetime;
    // print("Formatted Datetime: $formattedDatetime");
  }
  return formatedDate;
}

Map spilitTsym({required String value}) {
  String symbol = "";
  String expDate = "";
  String option = "";

  RegExp datePattern = RegExp(r'\d{2}[A-Z]{3}\d{2,4}');

  String? dateMatch = datePattern.firstMatch(value)?.group(0);
  if (dateMatch != null) {
    int index = value.indexOf(dateMatch);

    symbol = value.substring(0, index);
    String date = dateMatch;
    String day = date.substring(0, 2);
    String month = date.substring(2, 5);
    String year = date.substring(5);

    expDate = '$day $month $year';
    if (value.substring(index + dateMatch.length).contains("P")) {
      option = value.substring(index + dateMatch.length).replaceAll("P", "PE ");
    } else if (value.substring(index + dateMatch.length).contains("C")) {
      option = value.substring(index + dateMatch.length).replaceAll("C", "CE ");
    } else if (value.substring(index + dateMatch.length).contains("F")) {
      option =
          value.substring(index + dateMatch.length).replaceAll("F", "FUT ");
    } else {
      option = value.substring(index + dateMatch.length);
    }
    if (option.isNotEmpty) {
      List<String> swapStr = option.split(" ");
      option = "${swapStr[1]} ${swapStr[0]}";
    }
  } else {
    symbol = value;
    expDate = "";
    option = "";
  }
  return {"symbol": symbol, "expDate": expDate, "option": option};
}

String sipformatDateTime({required String value}) {
  String formatedDate = '';
  String inputDateString = value;
  if (value.length == 8) {
    int day = int.parse(inputDateString.substring(0, 2));
    int month = int.parse(inputDateString.substring(2, 4));
    int year = int.parse(inputDateString.substring(4));

    DateTime inputDate = DateTime(year, month, day);

    final formattedDateString = DateFormat("dd-MMM-yyyy").format(inputDate);

    formatedDate = formattedDateString;
  }
  return formatedDate;
}

String duedateformate({required String value}) {
  String formatedDate = '';
  String inputDateString = value;
  if (value.length == 8) {
    int day = int.parse(inputDateString.substring(0, 2));
    int month = int.parse(inputDateString.substring(2, 4));
    int year = int.parse(inputDateString.substring(4));

    DateTime inputDate = DateTime(year, month, day);

    final formattedDateString = DateFormat("dd-MM-yyyy").format(inputDate);

    formatedDate = formattedDateString;
  }
  return formatedDate;
}

String readTimestamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  final dateFormatter = DateFormat('dd-MM-yyyy');

  final formattedDate = dateFormatter.format(dateTime);

  return formattedDate;
}

String convertToISOFormat(String dateTimeString) {
  List<String> parts = dateTimeString.split(' ');
  List<String> timeParts = parts[0].split(':');
  List<String> dateParts = parts[1].split('-');
  return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T${timeParts[0]}:${timeParts[1]}:${timeParts[2]}';
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle:
          TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
}
