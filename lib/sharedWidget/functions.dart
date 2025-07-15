import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final NumberFormat numberFormat = NumberFormat("##,##,##,##,##0.00", "hi");
final numberFormatter = NumberFormat("##,##,###", "en_IN");

bool checkIsInfOrNullOrNan({String? value}) {
  if (value == null ||
      value.isEmpty ||
      value.toLowerCase().startsWith('infi') ||
      value.toLowerCase().startsWith('nan') ||
      value.toLowerCase().startsWith('null') ||
      value.toLowerCase().startsWith('-infi') ||
      value.toLowerCase().startsWith('-nan') ||
      value.toLowerCase().startsWith('-null') ||
      value.toLowerCase() == '0' ||
      value.toLowerCase() == '0.00' ||
      value.toLowerCase() == '0.0' ||
      value.toLowerCase() == '00.00' ||
      value.toLowerCase() == '00.0000' ||
      value.toLowerCase() == '-0' ||
      value.toLowerCase() == '-0.00' ||
      value.toLowerCase() == '-0.0' ||
      value.toLowerCase() == '-00.00' ||
      value.toLowerCase() == '-00.0000') {
    return true;
  }
  return false;
}

// Coverting Number format
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

// Making a positive value become a negative one
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

// Time Validation based condition
timevalidation(String startTime, String endTime) {
  final now = DateTime.now();
  final opentime = DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(startTime.split(":")[0]),
    int.parse(startTime.split(":")[1]),
    int.parse(startTime.split(":")[2]),
  );
  final closetime = DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(endTime.split(":")[0]),
    int.parse(endTime.split(":")[1]),
    int.parse(endTime.split(":")[2]),
  );

  String status = "";
  if (now.isAfter(opentime) && now.isBefore(closetime)) {
    status = "OPEN";
  } else {
    status = "CLOSE";
  }
  return status.toString();
}

modifyButtonStatus(String startdate, String enddate) {
  // Format the datetime in the desired format
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  String conEndDate = convertDatestart(enddate);
  String startcovDate = convertDatestart(startdate);
  final startDate = dateFormat.parse(startcovDate);
  final endDate = dateFormat.parse(conEndDate);
  final now = DateTime.now();
  final currentDate = DateTime(now.year, now.month, now.day);
  String status = "";
  if (currentDate.isBefore(startDate)) {
    status = "Pre-open";
  } else if (endDate.isBefore(currentDate)) {
    status = "Closed";
  } else {
    status = "Open";
  }
  return status.toString();
}

// Converting value to currency format
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

String convertCurrencyINRStandard(dynamic value) {
  return numberFormatter.format(value);
}

// Convert the number to crores
String formatInCrore(int number) {
  double croreValue = number / 1e7;
  // Format to show only the first three significant digits
  String formattedValue = croreValue.toStringAsFixed(2);
  return '$formattedValue Cr';
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

String formatDate(String inputDate) {
  // Parse the input string to a DateTime object
  DateTime dateTime = DateTime.parse(inputDate);

  // Format the date into "MMM dd" format
  String formattedDate = DateFormat('MMM dd').format(dateTime);

  return formattedDate;
}

String formatToDateTime(String timestamp) {
  List<String> parts = timestamp.split(' ');
  String time = parts[0];
  String date = parts[1];

  // Convert '27-03-2024' into '2024-03-27' for DateTime parsing
  List<String> dateParts = date.split('-');
  String formattedDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
  return '$formattedDate $time';
}

DateTime parseDate(String dateStr) {
  return DateFormat('ddMMyyyy').parse(dateStr);
}

Map spilitTsym({required String value}) {
  String symbol = "";
  String expDate = "";
  String option = "";
  // Format the date in the desired format
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
    // Format the datetime in the desired format
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
  // Format the datetime in the desired format
  final dateFormatter = DateFormat('dd-MM-yyyy');

  final formattedDate = dateFormatter.format(dateTime);

  return formattedDate;
}

String getInputType(String value) {
  final numberOnly = RegExp(r'^[0-9]+$'); // Matches only numbers
  final alphanumeric = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$'); // Matches both alphabets and numbers

  if (numberOnly.hasMatch(value)) {
    return "mobile";
  } else if (alphanumeric.hasMatch(value)) {
    return "clientid";
  }
  return "clientid"; // Fallback if it doesn't match any
}

String convertToISOFormat(String dateTimeString) {
  List<String> parts = dateTimeString.split(' ');
  List<String> timeParts = parts[0].split(':');
  List<String> dateParts = parts[1].split('-');
  return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T${timeParts[0]}:${timeParts[1]}:${timeParts[2]}';
}

TextStyle textStylebanner(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
          fontWeight: fWeight,
          color: color,
          fontSize: fontSize,
          decoration: TextDecoration.none));
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle:
          TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
}

TextStyle textStylewithls(Color color, double fontSize, fWeight, ls) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
          fontWeight: fWeight,
          color: color,
          fontSize: fontSize,
          letterSpacing: ls));
}

ipostartdate(String startdate, String enddate) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  String conEndDate = convertDateend(enddate);
  String startcovDate = convertDatestart(startdate);
  final startDate = dateFormat.parse(startcovDate);
  final endDate = dateFormat.parse(conEndDate);
  final now = DateTime.now();
  final currentDate = DateTime(now.year, now.month, now.day);
  String status = "";
  if (currentDate.isBefore(startDate)) {
    status = "Pre-open";
  } else if (endDate.isBefore(currentDate)) {
    status = "Closed";
  } else {
    status = "Open";
  }
  return status.toString();
}

String convertDatestart(String dateString) {
  DateFormat inputFormat =
      DateFormat("dd-MM-yyyy"); // Format the datetime in the desired format
  DateFormat outputFormat = DateFormat("yyyy-MM-dd");
  DateTime dateTime = inputFormat.parseUTC(dateString);
  String formattedDate = outputFormat.format(dateTime);
  return formattedDate;
}

String convertDateend(String dateString) {
  DateFormat inputFormat = DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss"); // Format the datetime in the desired format
  DateFormat outputFormat = DateFormat("yyyy-MM-dd");
  DateTime dateTime = inputFormat.parseUTC(dateString);
  String formattedDate = outputFormat.format(dateTime);
  return formattedDate;
}

String convertClosedIpoDates(
    String dateString, String inputDateFormat, String outputDateFormat) {
  DateFormat inputFormat = DateFormat(inputDateFormat); // "MMM dd, yyyy"t
  DateFormat outputFormat =
      DateFormat(outputDateFormat); // "EEE, dd MMM yyyy HH:mm:ss"
  DateTime dateTime = inputFormat.parseUTC(dateString);
  String formattedDate = outputFormat.format(dateTime);
  return formattedDate;
}

DateTime convertIpoDates(String dateString, String inputDateFormat) {
  DateFormat inputFormat = DateFormat(inputDateFormat); // "MMM dd, yyyy"t
  DateTime dateTime = inputFormat.parseUTC(dateString);
  return dateTime;
}

String ipodateres(String dt1) {
  DateTime dateTime =
      DateTime.parse(dt1); // Format the datetime in the desired format
  String formattedDate = DateFormat('dd-MM-yyyy - hh:mm a').format(dateTime);
  return formattedDate;
}

double mininv(double price, int qty) {
  double value1 = price;
  int value2 = qty;

  double result = value1 * value2;

  return result;
}

sipdateformat(String date) {
  DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);

  // Format the date to the desired format
  String formattedDate = DateFormat('ddMMyyyy').format(parsedDate);
  return formattedDate.toString();
}

String convDateWithTime() {
  final now = DateTime.now();

  final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final inputDatetime = inputFormat.parse("$now");
  // Format the datetime in the desired format
  final outputFormat = DateFormat("dd MMM yyyy, hh:mm a");
  final formattedDatetime = outputFormat.format(inputDatetime);
  return formattedDatetime.toString();
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String formatDateTimepaymet({required String value}) {
  String formatedDate = '';
  // Check if value is valid before trying to parse
  if (value.isNotEmpty && value != "NA" && value != "null" && value != "NULL") {
    try {
      final inputDatetimeString = value;
      final inputFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
      final inputDatetime = inputFormat.parse(inputDatetimeString);
      // Format the datetime in the desired format
      final outputFormat = DateFormat("dd MMM yyyy, hh:mm a");
      final formattedDatetime = outputFormat.format(inputDatetime);
      formatedDate = formattedDatetime;
      // print("Formatted Datetime: $formattedDatetime");
    } catch (e) {
      // If parsing fails, return empty string or default message
      formatedDate = "";
    }
  }
  return formatedDate;
}

String dateFormatChangeForLedger(String value) {
  String formatedDate = '';
  if (value.isNotEmpty) {
    final inputDatetimeString = value;
    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final inputDatetime = inputFormat.parse(inputDatetimeString);
    // Format the datetime in the desired format
    final outputFormat = DateFormat("dd/MM/yyyy");
    final formattedDatetime = outputFormat.format(inputDatetime);
    formatedDate = formattedDatetime;
    // print("Formatted Datetime: $formattedDatetime");
  }
  return formatedDate;
}
