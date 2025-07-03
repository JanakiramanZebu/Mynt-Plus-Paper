import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/desk_reports_model/pdf_download_model.dart';
import 'package:mynt_plus/models/desk_reports_model/pnl_seg_charges_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/core/api_core.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/client_profile_all_details/profile_all_details_model.dart';
import '../models/desk_reports_model/SharingResponseCalendar_model.dart';
import '../models/desk_reports_model/ca_events_model.dart';
import '../models/desk_reports_model/calender_pnl_model.dart';
import '../models/desk_reports_model/cdsl_response_model.dart';
import '../models/desk_reports_model/cp_action_model.dart';
import '../models/desk_reports_model/dercomcur_taxpnl_model.dart';
import '../models/desk_reports_model/editreport_model.dart';
import '../models/desk_reports_model/holdings_model.dart';
import '../models/desk_reports_model/ledger_bill_model.dart';
import '../models/desk_reports_model/ledger_model.dart';
import '../models/desk_reports_model/order_response_cop.dart';
import '../models/desk_reports_model/pledge_history_model.dart';
import '../models/desk_reports_model/pledge_segment_check_model.dart';
import '../models/desk_reports_model/pledge_unpledge_model.dart';
import '../models/desk_reports_model/pnl_model.dart';
import '../models/desk_reports_model/pnl_summary_model.dart';
import '../models/desk_reports_model/position_model.dart';
import '../models/desk_reports_model/sharing_on_off_model.dart';
import '../models/desk_reports_model/tax_pnl_Eq_charge_model.dart';
import '../models/desk_reports_model/taxpnl_eq_model.dart';
import '../models/desk_reports_model/tradebook_model.dart';
import '../models/desk_reports_model/unpledge_history_model.dart';
import '../routes/route_names.dart';
import '../screens/desk_reports/bottom_sheets/ledger_filter.dart';
import '../sharedWidget/fund_function.dart';
import 'core/default_change_notifier.dart';
import 'package:intl/intl.dart';

final ledgerProvider = ChangeNotifierProvider((ref) => LDProvider(ref));

class LDProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  LDProvider(this.ref);
  List<dynamic> _taxpnlyeararray = [];
  List<dynamic> get taxpnlyeararray => _taxpnlyeararray;

  List<dynamic> _listforpledge = [];
  List<dynamic> get listforpledge => _listforpledge;

  List<dynamic> _tradebookfilterarray = [];

  List<dynamic> _isinlistforcopedisdata = [];

  List<dynamic> get tradebookfilterarray => _tradebookfilterarray;

  Map<DateTime, double> _heatmapData = {};
  Map<DateTime, double> get heatmapData => _heatmapData;

  Map<DateTime, List<TradeData>> grouped = {};

  LedgerModelData? _ledgerAllData;
  LedgerModelData? get ledgerAllData => _ledgerAllData;

  LedgerModelData? _ledgerAllDataDummy;
  LedgerModelData? get ledgerAllDataDummy => _ledgerAllDataDummy;

  CPActionModule? _cpactiondata;
  CPActionModule? get cpactiondata => _cpactiondata;

  GetOrderlistCopModel? _orderdetailsdatacop;
  GetOrderlistCopModel? get orderdetailsdatacop => _orderdetailsdatacop;

  EdisReportModel? _edisreportdata;
  EdisReportModel? get edisreportdata => _edisreportdata;

  // ProfileAllDetails? _profiledetails;
  // ProfileAllDetails? get profiledetails => _profiledetails;

  PnlModel? _pnlAllData;
  PnlModel? get pnlAllData => _pnlAllData;

  UnpledgeHistoryModel? _unPledgeHistoryData;
  UnpledgeHistoryModel? get unPledgeHistoryData => _unPledgeHistoryData;

  PledgeHistoryModel? _pledgeHistoryData;
  PledgeHistoryModel? get pledgeHistoryData => _pledgeHistoryData;

  PnlModel? _pnlAllDatadummy;
  PnlModel? get pnlAllDataDummy => _pnlAllDatadummy;

  CalenderpnlModel? _calenderpnlAllData;
  CalenderpnlModel? get calenderpnlAllData => _calenderpnlAllData;

  TradeBookModel? _tradebookdata;
  TradeBookModel? get tradebookdata => _tradebookdata;

  TradeBookModel? _tradebookdataDummy;
  TradeBookModel? get tradebookdataDummy => _tradebookdataDummy;
  PdfDownloadModel? _pdfdaataDummy;
  PdfDownloadModel? get pdfdaataDummy => _pdfdaataDummy;

  PdfDownloadModel? _pdfdownload;
  PdfDownloadModel? get pdfdownload => _pdfdownload;

  PledgeAndUnpledgeModel? _pledgeandunpledge;
  PledgeAndUnpledgeModel? get pledgeandunpledge => _pledgeandunpledge;

  CAEventsModel? _caeventalldata;
  CAEventsModel? get caeventalldata => _caeventalldata;

  CdslReponseModel? _cdslresponsedata;
  CdslReponseModel? get cdslresponsedata => _cdslresponsedata;

  PledgeSegmentCheckModel? _pledgesegmentcheck;
  PledgeSegmentCheckModel? get pledgesegmentcheck => _pledgesegmentcheck;

  TaxPnlEqModel? _taxpnleq;
  TaxPnlEqModel? get taxpnleq => _taxpnleq;

  DercomcurModel? _taxpnldercomcur;
  DercomcurModel? get taxpnldercomcur => _taxpnldercomcur;

  PositionModel? _positiondata;
  PositionModel? get positiondata => _positiondata;

  var taxpnleqselectedtabdata;

  var taxpnlderselectedtabdata;

  var taxpnlcomselectedtabdata;

  var taxpnlcurselectedtabdata;

  HoldingModel? _holdingsAllData;
  HoldingModel? get holdingsAllData => _holdingsAllData;

  SharingResponse? _sharingdatacalendar;
  SharingResponse? get sharingdatacalendar => _sharingdatacalendar;

  OnorOffSharingModel? _sharingturonandoff;
  OnorOffSharingModel? get sharingturonandoff => _sharingturonandoff;

  LedgerBillModel? _ledgerBillData;
  LedgerBillModel? get ledgerBillData => _ledgerBillData;

  PnlSummaryModel? _pnlSummaryData;
  PnlSummaryModel? get pnlSummaryData => _pnlSummaryData;

  PnlSegCharge? _pnlsegCharge;
  PnlSegCharge? get pnlsegCharge => _pnlsegCharge;

  TaxPnlEqCharges? _taxpnleqCharge;
  TaxPnlEqCharges? get taxpnleqCharge => _taxpnleqCharge;

  final List<List<dynamic>> _tablearray = [];
  List<List<dynamic>> get tablearray => _tablearray;

//   List<List<dynamic>> _tableArray;
// List get tablearray = _tableArray;
  DateTime? _endsDate;
  DateTime? get endsDate => _endsDate;

  DateTime _curDate = DateTime.now();

  DateTime get curDate => _curDate;
  DateTime? _pickedStartDate;
  DateTime? get pickedStartDate => _pickedStartDate;

  DateTime? _pickedEndDate;

  String _dummyStartYear = "";
  String _pdfresponse = "";

  Timer? _timer;
  Timer? get timer => _timer;

  bool _edisclickfromcpaction = false;
  bool get edisclickfromcpaction => _edisclickfromcpaction;

  String _timedis = '';
  String get timedis => _timedis;

  String _requiredamountforofs = 'Required Amount to bid';
  String get requiredamountforofs => _requiredamountforofs;

  set requireamountsetter(val) {
    _requiredamountforofs = val;
  }

  String _captionforofs = 'Enter bid quantity and price';
  String get captionforofs => _captionforofs;

  String _noticenewfeature = '';
  String get noticenewfeature => _noticenewfeature;

  set settime(String? val) {
    _timedis = val.toString();
  }

  bool _valforcheck = false;
  bool get valforcheck => _valforcheck;

  bool _cutoffcheckboxofs = false;
  bool get cutoffcheckboxofs => _cutoffcheckboxofs;

  bool _pricevalidcp = false;
  bool get pricevalidcp => _pricevalidcp;

  bool _qtyvalidcp = false;
  bool get qtyvalidcp => _qtyvalidcp;

  bool _pnlrmtm = true;
  bool get pnlrmtm => _pnlrmtm;

  bool _loader = false;
  bool get loader => _loader;

  String _dummyStartdate = "";
  String _dummyStartmonth = "";
  String _dummyEndYear = "";

  SingingCharacter? _filterval;
  SingingCharacter? get filterval => _filterval;

  set setfilterval(SingingCharacter? val) {
    _filterval = val;
    print("${_filterval}yyyyyyyy");
  }

  set setterfornullallSwitch(val) {
    _ledgerAllData = val;
    _holdingsAllData = val;
    _pnlAllData = val;
    _calenderpnlAllData = val;
    _taxpnleq = val;
    _taxpnldercomcur = val;
    _tradebookdata = val;
    _pdfdownload = val;
    _pledgeandunpledge = val;
    _positiondata = val;
    _caeventalldata = val;
    _sharingdatacalendar = val;
    _cpactiondata = val;
  }

  String _eqtypestring = "";
  String get eqtypestring => _eqtypestring;

  String _ucode = "";
  String get ucode => _ucode;

  String _dayforpledgeunpledge = "";
  String get dayforpledgeunpledge => _dayforpledgeunpledge;

  String _segmentvalue = "";
  String get segmentvalue => _segmentvalue;

  String _segmentvaluedummy = "";
  String get segmentvaluedummy => _segmentvaluedummy;

  String _screenpledge = "";
  String get screenpledge => _screenpledge;

  String _pledgeorunpledge = "";
  String get pledgeorunpledge => _pledgeorunpledge;

  String _pledgeoruppledgedelete = "";
  String get pledgeoruppledgedelete => _pledgeoruppledgedelete;

  String _cpactionerrormsg = "";
  String get cpactionerrormsg => _cpactionerrormsg;

  bool _cpactionsubtn = false;
  bool get cpactionsubtn => _cpactionsubtn;

  Map _segresponse = {};
  Map get segresponse => _segresponse;

  int _holdingdetailindex = 0;
  int get holdingdetailindex => _holdingdetailindex;

  set setholdingdetailindex(val) {
    _holdingdetailindex = val;
  }

  String _currentfilterpage = "";
  String get currentfilterpage => _currentfilterpage;

  set setfilterpage(val) {
    _currentfilterpage = val;
  }

  String _selectvalueofcpaction = "Buyback";
  String get selectvalueofcpaction => _selectvalueofcpaction;

  set setselectvalueofcpaction(val) {
    _selectvalueofcpaction = val;
    notifyListeners();
  }

  set setedisclickfromcpaction(val) {
    _edisclickfromcpaction = val;
    notifyListeners();
  }

  // Filtered CP Action data based on selected action type
  List<dynamic> get filteredCPActionData {
    if (_cpactiondata?.corporateAction == null) return [];

    return _cpactiondata!.corporateAction!.where((item) {
      switch (_selectvalueofcpaction) {
        case 'Buyback':
          return item.issueType == 'BB' || item.issueType == 'BUYBACK';
        case 'Delisting':
          return item.issueType == 'DLST' || item.issueType == 'DS';
        case 'Takeover':
          return item.issueType == 'TAKEOVER' || item.issueType == 'TO';
        case 'OFS':
          return item.issueType == 'IS' || item.issueType == 'RS';
        case 'RIGHTS':
          return item.issueType == 'RIGHTS';
        default:
          return false;
      }
    }).toList();
  }

//loadingsssssssssssssssssssssssssssssssss reportssssssssssssssss
  bool _reportsloading = false;
  bool get reportsloading => _reportsloading;

  bool _pledgeloader = false;
  bool get pledgeloader => _pledgeloader;

  bool _ledgerloading = false;
  bool get ledgerloading => _ledgerloading;

  bool _cpactionloader = true;
  bool get cpactionloader => _cpactionloader;

  bool _pledgehistory = false;
  bool get pledgehistory => _pledgehistory;

  bool _positionloading = false;
  bool get positionloading => _positionloading;

  bool _holdingsloading = false;
  bool get holdingsloading => _holdingsloading;

  bool _pnlloading = false;
  bool get pnlloading => _pnlloading;

  bool _calendarpnlloading = false;
  bool get calendarpnlloading => _calendarpnlloading;

  bool _taxderloading = false;
  bool get taxderloading => _taxderloading;

  bool _caeventloading = false;
  bool get caeventloading => _caeventloading;

  bool _tradebookloading = false;
  bool get tradebookloading => _tradebookloading;

  bool _pdfdownloadloading = false;
  bool get pdfdownloadloading => _pdfdownloadloading;

  bool _isDaily = false;
  bool get isDaily => _isDaily;

  bool _reportsloadingforcharges = false;
  bool get reportsloadingforcharges => _reportsloadingforcharges;

  String _dertypestring = "";
  String get dertypestring => _dertypestring;

  String _comtypestring = "";
  String get comtypestring => _comtypestring;

  String _curtypestring = "";
  String get curtypestring => _curtypestring;

  set clickedvaluecur(val) {
    _curtypestring = val;
    print("${_filterval}yyyyyyyy");
  }

  int _activeTabTaxPnl = 0;
  int get activeTabTaxPnl => _activeTabTaxPnl;

  int _yearforTaxpnl = 0;
  int get yearforTaxpnl => _yearforTaxpnl;

  int _yearforTaxpnlDummy = 0;
  int get yearforTaxpnlDummy => _yearforTaxpnlDummy;

  set clickedvaluecom(val) {
    _comtypestring = val;
  }

  set clickedvalue(val) {
    _eqtypestring = val;
  }

  set screenclickedpledge(val) {
    _screenpledge = val;
  }

  int _eqdertabvalue = 0;
  int get eqdertabvalue => _eqdertabvalue;

  set clickedtabvalue(val) {
    _eqdertabvalue = val;
    print("${_filterval}yyyyyyyy");
  }

  set clickedvalueder(val) {
    _dertypestring = val;
    print("${_filterval}yyyyyyyy");
  }

  String _startDate = "";
  String get startDate => _startDate;

  String _lastweekdate = "";
  String get lastweekdate => _lastweekdate;

  String _today = "";
  String get today => _today;

  String _endDate = "";
  String get endDate => _endDate;

  set clickchangemtmandpnl(val) {
    _pnlrmtm = val;
    notifyListeners();
  }

  getYearlistTaxpnl() {
    DateTime today = DateTime.now();
    int yyyy = today.year;
    int mm = today.month;
    _taxpnlyeararray = [];
    int yearmount = (mm < 4) ? (yyyy - 1) : yyyy;
    // int startYear = yearmount - 4;
    int startYear = yearmount;
    _yearforTaxpnl = startYear;
    _yearforTaxpnlDummy = startYear;
    for (int year = yearmount; year >= startYear; year--) {
      _taxpnlyeararray.add(year);
    }

    print("Current Year: $yearmount");
    print("Generated Years: $_taxpnlyeararray");
  }

  getCurrentDate(String trade) {
    if (trade == 'pandu') {
      var date = DateTime.now();

      _dayforpledgeunpledge = DateFormat('EEEE').format(date);
      print("$_dayforpledgeunpledge loakdsdejkvh");
    }
    _curDate = DateTime.now();
    _pickedStartDate = null;

    DateTime seventhDayBefore = _curDate.subtract(Duration(days: 7));

    // Define the date format
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    // Print in reverse order
    print(dateFormat.format(seventhDayBefore)); // 7th day before
    print(dateFormat.format(curDate)); // Current date
    final date =
        _curDate.day.toString().padLeft(2, '0'); // Ensures "01", "02", etc.
    final month =
        _curDate.month.toString().padLeft(2, '0'); // Ensures "04" for April
    final year = _curDate.year.toString();

    print("$date-$month-$year"); // Example Output: 20-04-2024

    if (_curDate.month > 3) {
      _dummyStartYear = _curDate.year.toString();
      _dummyEndYear = "${_curDate.year + 1}";
      _dummyStartdate = _curDate.day.toString();
      _dummyStartmonth = _curDate.month.toString();
    } else {
      print("less");
      _dummyStartYear = "${_curDate.year - 1}";
      _dummyEndYear = _curDate.year.toString();

      print("$_curDate");
    }
    print("$date, $month , $year vaavavaavva");

    _today = "$date/$month/$year";
    if (trade == 'tradebook') {
      _startDate = dateFormat.format(seventhDayBefore);
      _endDate = "$date/$month/$year";
    } else if (trade == 'caevent') {
      // _startDate = "$year-$month-$date";
      // _endDate = "$year-$month-$date";
      _startDate = "$date/$month/$year";
      _endDate = "$date/$month/$year";
    } else {
      _startDate = "01/04/$_dummyStartYear";
      _endDate = "31/03/${_dummyEndYear}";
    }

    notifyListeners();
  }

  void datePickerStart(BuildContext context, ThemesProvider theme) async {
    DateTime? pickedDate = _pickedStartDate ?? _curDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300, // Adjust the calendar height
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: theme.isDarkMode
                          ? Colors.white
                          : Colors.black, // Selected date highlight color
                      onPrimary: theme.isDarkMode
                          ? Colors.black
                          : Colors.white, // Selected text color
                      surface: theme.isDarkMode ? Colors.black : Colors.white,
                      onSurface: theme.isDarkMode
                          ? Colors.white
                          : Colors.black, // Text color
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: pickedDate,
                    firstDate: DateTime(_curDate.year - 200),
                    lastDate: DateTime(_curDate.year + 200),
                    onDateChanged: (date) {
                      pickedDate = date;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: theme.isDarkMode
                            ? Colors.grey[300]
                            : theme.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (pickedDate != null) {
                        _pickedStartDate = pickedDate;
                        _startDate =
                            "${_pickedStartDate!.day}/${_pickedStartDate!.month}/${_pickedStartDate!.year}";
                        notifyListeners();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: theme.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // datePickerEnd(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       currentDate: _pickedEndDate ?? _curDate,
  //       context: context,
  //       initialDate: _pickedEndDate ?? _curDate,
  //       firstDate: DateTime(_curDate.year - 200),
  //       lastDate: DateTime(_curDate.year + 200));
  //   if (picked != null) {
  //     _pickedEndDate = picked;
  //     _endDate =
  //         "${_pickedEndDate!.day}/${_pickedEndDate!.month}/${_pickedEndDate!.year}";

  //   }
  // }

  void datePickerEnd(BuildContext context, ThemesProvider theme) async {
    DateTime? pickedDate = _endsDate ?? _curDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300, // Adjust the calendar height
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: theme.isDarkMode
                          ? Colors.white
                          : Colors.black, // Selected date highlight color
                      onPrimary: theme.isDarkMode
                          ? Colors.black
                          : Colors.white, // Selected text color
                      surface: theme.isDarkMode ? Colors.black : Colors.white,
                      onSurface: theme.isDarkMode
                          ? Colors.white
                          : Colors.black, // Text color
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: pickedDate,
                    firstDate: DateTime(_curDate.year - 2),
                    lastDate: DateTime(_curDate.year + 2),
                    onDateChanged: (date) {
                      pickedDate = date;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: theme.isDarkMode
                            ? Colors.grey[300]
                            : theme.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (pickedDate != null) {
                        _endsDate = pickedDate;
                        _endDate =
                            "${_endsDate!.day}/${_endsDate!.month}/${_endsDate!.year}";
                        notifyListeners();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: theme.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // datePickerEnd(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       currentDate: _endsDate ?? _curDate,
  //       context: context,
  //       initialDate: _endsDate ?? _curDate,
  //       firstDate: DateTime(_curDate.year - 2),
  //       lastDate: DateTime(_curDate.year + 2));
  //   if (picked != null) {
  //     _endsDate = picked;
  //     _endDate = "${_endsDate!.day}/${_endsDate!.month}/${_endsDate!.year}";
  //   }
  //   notifyListeners();
  // }

  filtervalchange() {
    // _ledgerAllData = null;
    notifyListeners();
  }
  ////API CALL

  // Future fetchprofiledata() async {
  //   try {
  //     notifyListeners();

  //     _profiledetails = await api.getClientProfileAllDetailsApi();
  //     notifyListeners();
  //   } catch (e) {
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   warningMessage(context, 'Error occurred try again later'),
  //     // );
  //     debugPrint("$e");
  //   }
  // }

  Future fetchLegerData(BuildContext context, String from, String to) async {
    try {
      _ledgerloading = true;
      notifyListeners();

      _ledgerAllDataDummy = await api.getLedgerdata(from, to);
      //  _ledgerAllData = new LedgerModelData();

      _ledgerAllData = LedgerModelData.fromJson(_ledgerAllDataDummy!.toJson());
      _ledgerAllData!.fullStat?.sort((a, b) {
        return int.parse(b.sortNo!).compareTo(int.parse(a.sortNo!));
      });
      _filterval = SingingCharacter.all;
      _ledgerloading = false;
      notifyListeners();
    } catch (e) {
      _ledgerloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future fetchunpledgehistory(BuildContext context) async {
    try {
      _pledgehistory = true;
      notifyListeners();

      _unPledgeHistoryData = await api.getunpledgehistory();
      //  _ledgerAllData = new LedgerModelData();
    } catch (e) {
      _pledgehistory = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future fetchpledgehistory(BuildContext context) async {
    try {
      _pledgehistory = true;
      notifyListeners();
      _pledgeHistoryData = await api.getpledgehistory();
      //  _ledgerAllData = new LedgerModelData();
      _pledgehistory = false;
      notifyListeners();
    } catch (e) {
      _pledgehistory = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future fetchposition(BuildContext context) async {
    try {
      _positionloading = true;
      notifyListeners();

      _positiondata = await api.getposition();
      _positionloading = false;
      calltimes();

      notifyListeners();
    } catch (e) {
      _positionloading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error occurred in positions try again later'),
      );
      debugPrint("$e");
    }
  }

  calltimes() {
    if (_timer != null) {
      _timer!.cancel();

      print("Timer cancelled");
      _timer = null;
      notifyListeners();
    } else {
      print("No active timer to cancel");
    }
    if (_timedis == '') {
      final time = DateFormat('hh:mm:ss a').format(DateTime.now());
      _timedis = time;
    }
    _timer = Timer.periodic(Duration(seconds: 5), (_) async {
      final time = DateFormat('hh:mm:ss a').format(DateTime.now());
      _timedis = time;
      _positiondata = await api.getposition();
      print("objectobjectobjectobjectobjectobjectobjectobject $time");
      notifyListeners();
    });
  }

  ccancelalltimes() {
    if (_timer != null) {
      _timer!.cancel();
      print("Timer cancelled");
      _timer = null;
      notifyListeners();
    } else {
      print("No active timer to cancel");
    }
  }

  Future fetchholdingsData(String from, BuildContext context) async {
    try {
      _holdingsloading = true;
      _cpactionloader = true;

      notifyListeners();

      _holdingsAllData = await api.getHoldingsdata(from);
      print(_holdingsAllData);
      _holdingsloading = false;
      notifyListeners();

      print("${_holdingsAllData}rererere");
    } catch (e) {
      _holdingsloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
      print("${e}eeeeee");
    } finally {
      await requestWS(context: context, isSubscribe: true);
      notifyListeners();
    }
  }

  Future fetchcpactiondata(BuildContext context) async {
    try {
      _cpactionloader = true;
      // notifyListeners();

      _cpactiondata = await api.getcpactiondata();
      // print(
      //     "${_cpactiondata?.corporateAction} ........................._cpactiondata");

      if (_cpactiondata != null) {
        await hodlingshavecheckfunction();
      }

      //  _ledgerAllData = new LedgerModelData();

      _cpactionloader = false;
      notifyListeners();
    } catch (e) {
      _cpactionloader = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
      notifyListeners();
    }
  }

  ordercheckfunction() async {
    try {
      // Fetch order details once before processing
      _orderdetailsdatacop = await api.getorderdetails();

      for (var i = 0; i < _cpactiondata!.corporateAction!.length; i++) {
        final data = _cpactiondata!.corporateAction![i];
        bool matchFound = false;

        if (_orderdetailsdatacop?.msg != null) {
          // Search for matching order details
          for (var j = 0; j < _orderdetailsdatacop!.msg!.length; j++) {
            final data2 = _orderdetailsdatacop!.msg![j];
            if (data.symbol == data2.symbol) {
              // Match found - set order details
              data.orderstatus = data2.status;
              data.bidqty = data2.bidQuan;
              data.appno = data2.applicationNo;
              data.orderprice = data2.price;

              matchFound = true;
              // Exit inner loop once match is found
            }
          }
        }

        // If no match found, set default values
        if (!matchFound) {
          data.orderstatus = 'null';
          data.bidqty = 'null';
          data.appno = 'null';
          data.orderprice = 'null';
        }
      }

      await edischeckfunction('');
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  hodlingshavecheckfunction() async {
    for (var i = 0; i < _cpactiondata!.corporateAction!.length; i++) {
      final data = _cpactiondata!.corporateAction![i];
      data.eligibleornot = 'no';
      if (_holdingsAllData != null) {
        for (var y = 0; y < _holdingsAllData!.holdings!.length; y++) {
          final data2 = _holdingsAllData!.holdings![y];
          if (data.isin == data2['ISIN']) {
            print(
                "${data.isin} /////${data2['ISIN']} ............................data.isin == data2['ISIN']");
            data.eligibleornot = 'yes';
            data.havingqty = data2['NET'].toString();
            _isinlistforcopedisdata.add(data2['ISIN']);

            break;
          }
        }
      }
    }
    await ordercheckfunction();

    notifyListeners();
  }

  edischeckfunction(String key) async {
    if (key == 'fromedit') {
      _cpactionloader = true;
    }
    _edisreportdata = await api.geteditsdata(_isinlistforcopedisdata);
    if (_edisreportdata?.data != null) {
      for (var i = 0; i < _cpactiondata!.corporateAction!.length; i++) {
        final data = _cpactiondata!.corporateAction![i];
        data.approvedqty = '0';
        for (var j = 0; j < _edisreportdata!.data!.length; j++) {
          final data2 = _edisreportdata!.data![j];
          if (data.isin == data2.isin) {
            data.approvedqty = data2.qty.toString();
          }
        }
      }
    }
    if (key == 'fromedit') {
      _cpactionloader = false;
    }
    notifyListeners();
  }

  Future putordercopaction(
      String tabval,
      String sym,
      String exchange,
      String issueType,
      String qty,
      String price,
      BuildContext context,
      String ordertype,
      String appno) async {
    try {
      _cpactionloader = true;
      notifyListeners();

      // Pop only after API result to avoid context issues
      final res = await api.putorderapicopaction(
          tabval, sym, exchange, issueType, qty, price, ordertype, appno);

      if (res.msg == 'success') {
        await ordercheckfunction();
        _cpactionloader = false;

        // Safely show snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            successMessage(
              context,
              ordertype == 'ER' ? 'Order placed' : 'Order cancelled',
            ),
          );
           
        }
      }else  if (res.msg == 'error occured on data fetch') {
        await ordercheckfunction();
        _cpactionloader = false;

        // Safely show snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(
              context,
             "${res.msg}", // 'Order cancelled',
            ),
          );
         
        }
      }
       Navigator.pop(context); // Pop after snackbar
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, '$e'),
        );
      }
 Navigator.pop(context); // Pop after snackbar
      debugPrint("$e");
    } finally {
      _cpactionloader = false;
      notifyListeners();
    }
  }

  Future fetchsharingdata(
      String from, String to, String seg, BuildContext context) async {
    try {
      _sharingdatacalendar = await api.getsharingdata(from, to, seg);
      if (_sharingdatacalendar?.data != null) {
        if (_sharingdatacalendar!.data![0].sharing == 'True') {
          _ucode = "${_sharingdatacalendar!.data![0].uqCode}";
          notsharing = false;
        } else {
          notsharing = true;
          _ucode = '';
        }
      } else {
        notsharing = true;
        _ucode = '';
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );

      debugPrint("$e");
      print("${e}eeeeee");
    } finally {
      notifyListeners();
    }
  }

  Future sendsharing(String ucode, from, to, res, bool status, seg,
      BuildContext context) async {
    try {
      _calendarpnlloading = true;
      notifyListeners();

      _sharingturonandoff =
          await api.senddharingdataapi(ucode, from, to, res, status, seg);

      if (_sharingturonandoff != null &&
          _sharingturonandoff!.data != null &&
          _sharingturonandoff!.data!.uqCode != null) {
        notsharing = false;
        _calendarpnlloading = false;

        _ucode = "${_sharingturonandoff!.data!.uqCode}";
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, "Sharing Turned on"),
        );
      } else {
        if (_sharingturonandoff!.msg != null) {
          if (_sharingturonandoff!.msg == 'Sharing Turned Off') {
            notsharing = true;
            _calendarpnlloading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Sharing Turned off"),
            );
          } else {
            notsharing = false;
            _calendarpnlloading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Sharing Turned on"),
            );
          }
        }
      }
      print("${_calendarpnlloading} printprint");
    } catch (e) {
      _calendarpnlloading = false;

      if (notsharing == false) {
        notsharing == true;
      } else {
        notsharing == false;
      }
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Sharing error'),
      );
      debugPrint("$e");
      print("${e}eeeeee");
    } finally {
      _calendarpnlloading = false;
      notifyListeners();
    }
  }

  requestWS({required bool isSubscribe, required BuildContext context}) async {
    String input = "";
    if (_holdingsAllData != null) {
      if (_holdingsAllData!.holdings != null) {
        for (var element in _holdingsAllData!.holdings!) {
          if (element["Token"] != '') {
            input += "${element["Exchange"]}|${element["Token"]}#";
          }
        }
      }
      print('${input} sub val');
    }

    if (input.isNotEmpty) {
      // lastScbTok(input);
      await ref.read(websocketProvider).establishConnection(
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
  }

  Future fetchpnldata(
      BuildContext context, String from, String to, bool yrn) async {
    try {
      _pnlloading = true;
      _reportsloadingforcharges = true;
      notifyListeners();
      _pnlAllData = await api.getpnldata(from, to, yrn);
      _pnlAllDatadummy = PnlModel.fromJson(_pnlAllData!.toJson());
      _valforcheck = yrn;
      _pnlloading = false;
      _reportsloadingforcharges = false;
      _filterval = SingingCharacter.all;
      print("${_pnlAllData} valval");
      notifyListeners();
    } catch (e) {
      _pnlloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  setthenotice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("notice", "yes");
    print(prefs.getString('notice'));
    _noticenewfeature = prefs.getString('notice').toString();
    notifyListeners();
  }

  Future fetchcalenderpnldata(
      BuildContext context, String from, String to, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // await prefs.remove("notice");
      _noticenewfeature = prefs.getString("notice").toString();

      print(_noticenewfeature);

      _calendarpnlloading = true;
      notifyListeners();
      _calenderpnlAllData = await api.getcalenderpnldata(from, to, type);
      grouped = {};
      if (_calenderpnlAllData != null) {
        _heatmapData = {}; // Reset before adding new data

        if (_calenderpnlAllData!.journal != null) {
          _filterval = SingingCharacter.all;

          for (var element in _calenderpnlAllData!.journal!) {
            print("realised : ${element.realisedpnl}");
            if (element.realisedpnl != '0.0') {
              String dateString = element.tRADEDATE!;

              try {
                               DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

                DateTime parsedDate = inputFormat.parse(dateString);
                print("${element.realisedpnl}");
                _heatmapData[DateTime(
                        parsedDate.year, parsedDate.month, parsedDate.day)] =
                    double.parse(element.realisedpnl ?? "0.0");
              } catch (e) {
                print("Error parsing date: $dateString - $e");
              }
            }
          }
        }
        if (_calenderpnlAllData!.data != null) {
          for (var trade in _calenderpnlAllData!.data!) {
                            DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

            DateTime parsedDate = inputFormat.parse(trade.tRADEDATE!);
            final dateKey =
                DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
            if (!grouped.containsKey(dateKey)) {
              grouped[dateKey] = [];
            }
            grouped[dateKey]!.add(trade);
          }
        }
      }
      setFinancialYear(selectedFinancialYear);

      print("objectobject${_heatmapData}");
      _calendarpnlloading = false;
      notifyListeners();
    } catch (e) {
      _calendarpnlloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future fetchtradebookdata(
      BuildContext context, String from, String to) async {
    try {
      _tradebookloading = true;
      notifyListeners();
      _tradebookdata = await api.gettradebookdata(from, to);

      _tradebookdataDummy = TradeBookModel.fromJson(_tradebookdata!.toJson());
      _filterval = SingingCharacter.all;
      print("$_tradebookdata object");
      _tradebookloading = false;
      // print("${_calenderpnlAllData} valval");
      notifyListeners();
    } catch (e) {
      _tradebookloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future pdfdownloadfunction(
      BuildContext context, String recno, String filename) async {
    try {
      _pdfdownloadloading = true;
      notifyListeners();

      // Request storage permission
      // var status = await Permission.storage.request();
      // if (status.isDenied || status.isPermanentlyDenied) {
      //   _reportsloading = false;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Storage permission is required!")),
      //   );

      //   return;

      // }

      // Download the file
      _pdfresponse = await api.getpdffileapi(recno, filename);
      if (_pdfresponse == 'File downloaded successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'PDF Downloaded, Check Your Download'),
        );

        // Open the Downloads folder
        // String downloadsDir = "/storage/emulated/0/Download";
        // await OpenFile.open(downloadsDir);

        _pdfdownloadloading = false;
      } else {
        print("$_pdfresponse Error occurred");
      }

      _pdfdownloadloading = false;
      notifyListeners();
    } catch (e) {
      _pdfdownloadloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future pdfdownloadfortaxpnl(
      BuildContext context, eq, dercomcur, eqcharge, year) async {
    if (year <= _yearforTaxpnlDummy) {
      try {
        _taxderloading = true;
        notifyListeners();

        _pdfresponse =
            await api.getpdffileapitaxpnl(eq, dercomcur, eqcharge, year);
        if (_pdfresponse == 'File downloaded successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'PDF Downloaded, Check Your Download'),
          );
          _taxderloading = false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, '$_pdfresponse'),
          );
          _taxderloading = false;
        }

        _taxderloading = false;
        notifyListeners();
      } catch (e) {
        _taxderloading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, 'Error occurred try again later'),
        );
        debugPrint("$e");
      }
    }
  }

  Future pdfdownloadforledger(
      BuildContext context, res, dr, cr, op, clb, stdate, edate) async {
    try {
      _ledgerloading = true;
      notifyListeners();
      _pdfresponse =
          await api.getpdffileapiledger(res, dr, cr, op, clb, stdate, edate);
      if (_pdfresponse == 'File downloaded successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'PDF Downloaded, Check Your Download'),
        );
        _ledgerloading = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, '$_pdfresponse'),
        );
        _ledgerloading = false;
      }

      _ledgerloading = false;
      notifyListeners();
    } catch (e) {
      _ledgerloading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error occurred try again later'),
      );
      debugPrint("$e");
    }
  }

  Future pdfdownloadforpnl(BuildContext context, res, stdate, edate, string,
      notional, chargevalue) async {
    try {
      _pnlloading = true;
      notifyListeners();
      _pdfresponse = await api.getpdffileapipnl(
          res, stdate, edate, string, notional, chargevalue);
      if (_pdfresponse == 'File downloaded successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'PDF Downloaded, Check Your Download'),
        );
        _pnlloading = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, '$_pdfresponse'),
        );
        _pnlloading = false;
      }

      _pnlloading = false;
      notifyListeners();
    } catch (e) {
      _pnlloading = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future fetchpdfdownload(BuildContext context, String from, String to) async {
    try {
      _pdfdownloadloading = true;
      notifyListeners();
      _pdfdownload = await api.getpdfdownload(from, to);
      print("$_pdfdownload object");
      _pdfdaataDummy = PdfDownloadModel.fromJson(_pdfdownload!.toJson());
      // final dummy = [];
      // for (var i = 0; i < _pdfdownload!.data!.length; i++) {
      //   dummy.add(_pdfdownload!.data![i].docType);
      // }
      // _tradebookfilterarray = dummy.toSet().toList();
      // print(_tradebookfilterarray);
      _filterval = SingingCharacter.all;
      _pdfdownloadloading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
      _pdfdownloadloading = false;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
    }
  }

  Future fetchpledgeandunpledge(BuildContext context) async {
    try {
      _pledgeloader = true;
      notifyListeners();
      _pledgeandunpledge = await api.getpledgeandunpledge();
      _pledgesegmentcheck = await api.getsegforpledge();
      _listforpledge = [];

      if (_pledgesegmentcheck?.str != null) {}
      _segresponse =
          jsonDecode(decryptionFunction(_pledgesegmentcheck!.str.toString()));
      print("$_segresponse response32e3423");
      // final dummy = [];
      // for (var i = 0; i < _pdfdownload!.data!.length; i++) {
      //   dummy.add(_pdfdownload!.data![i].docType);
      // }
      // _tradebookfilterarray = dummy.toSet().toList();
      // print(_tradebookfilterarray);
      _filterval = SingingCharacter.all;
      _pledgeloader = false;
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
      _pledgeloader = false;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
    }
  }

  Future fetchcaeventsdata(
      BuildContext context, String start, String end) async {
    try {
      _caeventloading = true;
      notifyListeners();
      _caeventalldata = await api.getcaevents(start, end);

      // final dummy = [];
      // for (var i = 0; i < _pdfdownload!.data!.length; i++) {
      //   dummy.add(_pdfdownload!.data![i].docType);
      // }
      // _tradebookfilterarray = dummy.toSet().toList();
      // print(_tradebookfilterarray);

      _caeventloading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
      _caeventloading = false;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
    }
  }

  Future fetchtaxpnleqdata(BuildContext context, int from) async {
    if (from <= _yearforTaxpnlDummy) {
      _yearforTaxpnl = from;

      try {
        _reportsloading = true;
        _taxderloading = true;
        notifyListeners();

        _taxpnleq = await api.gettaxpnleq(from);
        _taxpnldercomcur = await api.gettaxpnldercomcur(from);

        _filterval = SingingCharacter.all;

        final taxEqData = _taxpnleq?.data;
        if (taxEqData != null) {
          if (taxEqData.aSSETS != null) {
            _eqtypestring = 'Asserts';
            taxpnleqselectedtab('Asserts');
          } else if (taxEqData.lIABILITIES != null) {
            _eqtypestring = 'Liabilities';
            taxpnleqselectedtab('Liabilities');
          } else if (taxEqData.sHORTTERM != null) {
            _eqtypestring = 'Short Term';
            taxpnleqselectedtab('Short Term');
          } else if (taxEqData.tRADING != null) {
            _eqtypestring = 'Long Term';
            taxpnleqselectedtab('Long Term');
          }
        }

        final derData = _taxpnldercomcur?.data?.derivatives;
        if (derData != null) {
          if (derData.derFutBooked != null) {
            _dertypestring = 'Future Closed';
            taxpnlderselectedtab();
          } else if (derData.derFutOpen != null) {
            _dertypestring = 'Future Open';
            taxpnlderselectedtab();
          } else if (derData.derOptBooked != null) {
            _dertypestring = 'Option Closed';
            taxpnlderselectedtab();
          } else if (derData.derOptOpen != null) {
            _dertypestring = 'Option Open';
          }
        }

        final comData = _taxpnldercomcur?.data?.commodity;
        if (comData != null) {
          if (comData.comFutBooked != null) {
            _comtypestring = 'Future Closed';
            taxpnlcomselectedtab();
          } else if (comData.comFutOpen != null) {
            _comtypestring = 'Future Open';
            taxpnlcomselectedtab();
          } else if (comData.comOptBooked != null) {
            _comtypestring = 'Option Closed';
            taxpnlcomselectedtab();
          } else if (comData.comOptOpen != null) {
            _comtypestring = 'Option Open';
            taxpnlcomselectedtab();
          }
        }

        final curData = _taxpnldercomcur?.data?.currency;
        if (curData != null) {
          if (curData.currFutBooked != null) {
            _curtypestring = 'Future Closed';
            taxpnlcurselectedtab();
          } else if (curData.currFutOpen != null) {
            _curtypestring = 'Future Open';
            taxpnlcurselectedtab();
          } else if (curData.currOptBooked != null) {
            _curtypestring = 'Option Closed';
            taxpnlcurselectedtab();
          } else if (curData.currOptOpen != null) {
            _curtypestring = 'Option Open';
            taxpnlcurselectedtab();
          }
        }

        final charges = _taxpnldercomcur?.data?.charges;
        _reportsloading = false;
        _taxderloading = false;
        notifyListeners();

        print("${_taxpnleq} mainresponse");
        print("Assertsvalva $charges");

        notifyListeners();
      } catch (e) {
        _taxderloading = false;

        // ScaffoldMessenger.of(context).showSnackBar(
        //   warningMessage(context, 'Error occurred try again later'),
        // );
        debugPrint("Error fetching tax pnl data: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Cant move already in $_yearforTaxpnlDummy'),
      );
    }
  }

  Future fetchBillDetails(BuildContext context, String sett, String mrktyp,
      String comc, String tdate) async {
    try {
      _ledgerloading = true;
      notifyListeners();

      _ledgerBillData = await api.getLedgerBilldata(sett, mrktyp, comc, tdate);
      _ledgerloading = false;

      // if (_ledgerAllData!.stat == "Ok") {
      //   // for (var element in _ledgerAllData!.topSchemes!) {

      //   // }
      // }
      // formatedList(_ledgerBillData!.fullStat!);
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
      _ledgerloading = false;

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error occurred try again later'),
      );
    }
  }

  Future fetchpnlSummary(BuildContext context, String script, String comcode,
      String from, String to) async {
    try {
      _pnlloading = true;
      notifyListeners();
      _pnlSummaryData = await api.getPnlSummary(script, comcode, from, to);
      // if (_ledgerAllData!.stat == "Ok") {
      //   // for (var element in _ledgerAllData!.topSchemes!) {
      //   // }
      // }
      // formatedList(_ledgerBillData!.fullStat!);
      _pnlloading = false;
      notifyListeners();
    } catch (e) {
      _pnlloading = false;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   warningMessage(context, 'Error occurred try again later'),
      // );
      debugPrint("$e");
    }
  }

  Future sendunpledgerequest(BuildContext context, String uccid, String boid,
      String cname, List list) async {
    try {
      _pledgeloader = true;
      notifyListeners();
      final responce = await api.sendunpledgeapi(uccid, boid, cname, list);
      if (responce['msg'] == 'data updated successfully') {
        _pledgeandunpledge = await api.getpledgeandunpledge();
        _pledgeoruppledgedelete = '';
        _pledgeorunpledge = '';
        _listforpledge = [];
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'Scripts Unpledged'),
        );
        // _reportsloading = false;
      }
      // if (_ledgerAllData!.stat == "Ok") {
      //   // for (var element in _ledgerAllData!.topSchemes!) {
      //   // }
      // }
      // formatedList(_ledgerBillData!.fullStat!);
      _pledgeloader = false;
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
      _pledgeloader = false;

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error occurred try again later'),
      );
    }
  }

  Future unpldgedeletefun(BuildContext context, String uccid, List list) async {
    try {
      _pledgeloader = true;
      notifyListeners();
      final responce = await api.sendunpledgedeleteapi(uccid, list);
      if (responce['msg'] == 'request deleted') {
        _pledgeandunpledge = await api.getpledgeandunpledge();
        _pledgeorunpledge = '';
        _listforpledge = [];
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'Request Deleted '),
        );
        // _reportsloading = false;
      }
      // if (_ledgerAllData!.stat == "Ok") {
      //   // for (var element in _ledgerAllData!.topSchemes!) {
      //   // }
      // }
      // formatedList(_ledgerBillData!.fullStat!);
      _pledgeloader = false;
      notifyListeners();
    } catch (e) {
      _pledgeloader = false;

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error occurred try again later'),
      );
      debugPrint("$e");
    }
  }

  Future chargesforpnlseg(BuildContext context, String seg) async {
    try {
      _reportsloadingforcharges = true;
      notifyListeners();
      _pnlsegCharge =
          await api.getpnlsegcharge(seg, _startDate, _today, _valforcheck);
      _pnlAllData!.expenseAmt = _pnlsegCharge!.expenseAmt;
      print("${_pnlsegCharge?.expenseAmt} expense");
      // if (_ledgerAllData!.stat == "Ok") {
      //   // for (var element in _ledgerAllData!.topSchemes!) {

      //   // }
      // }
      // formatedList(_ledgerBillData!.fullStat!);
      _reportsloadingforcharges = false;
      notifyListeners();
    } catch (e) {
      _reportsloadingforcharges = false;

      ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, 'Error in getting charges'),
      );
      debugPrint("$e");
    }
  }

  Future chargesforeqtaxpnl(BuildContext context, int from) async {
    if (from <= _yearforTaxpnlDummy) {
      try {
        _reportsloadingforcharges = true;
        notifyListeners();
        _taxpnleqCharge = await api.GettaxpnleqCharge('eq', from);

        // _pnlAllData!.expenseAmt = _pnlsegCharge!.expenseAmt;
        print("${from}  expensevalvalvalval");

        // if (_ledgerAllData!.stat == "Ok") {
        //   // for (var element in _ledgerAllData!.topSchemes!) {

        //   // }
        // }
        // formatedList(_ledgerBillData!.fullStat!);
        _reportsloadingforcharges = false;
        notifyListeners();
      } catch (e) {
        _reportsloadingforcharges = false;

        ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, 'Error occurred try again later'),
        );
        debugPrint("$e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(warningMessage(
          context, 'Cant move already in ${_yearforTaxpnlDummy}'));
    }
  }

  ledgerfiltercall(BuildContext context, val) {
    // _ledgerAllData!.fullStat = [];

    if (_currentfilterpage == 'ledger') {
      List<FullStat> originalList = [];
      originalList = List.from(_ledgerAllDataDummy!.fullStat ?? []);
      if (_ledgerAllDataDummy != null) {
        if (val == SingingCharacter.receipt) {
          _ledgerAllData!.fullStat =
              originalList.where((o) => o.tYPE == 'Reciept').toList();
          double totalCrAmt = 0.0;

          for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
            totalCrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].cRAMT?.toString() ?? '0') ??
                0.0;
          }

          _ledgerAllData!.crAmt = totalCrAmt.toStringAsFixed(2);
          _ledgerAllData!.drAmt = '0.0';
          _ledgerAllData!.openingBalance = '0.0';
        } else if (val == SingingCharacter.journal) {
          _ledgerAllData!.fullStat =
              originalList.where((o) => o.tYPE == 'Journal').toList();
          double totalCrAmt = 0.0;
          double totalDrAmt = 0.0;

          for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
            totalCrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].cRAMT?.toString() ?? '0') ??
                0.0;
            totalDrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].dRAMT?.toString() ?? '0') ??
                0.0;
          }
          _ledgerAllData!.openingBalance = '0.0';

          _ledgerAllData!.crAmt = totalCrAmt.toStringAsFixed(2);
          _ledgerAllData!.drAmt = totalDrAmt.toStringAsFixed(2);
        } else if (val == SingingCharacter.payment) {
          _ledgerAllData!.fullStat =
              originalList.where((o) => o.tYPE == 'Payment').toList();
          double totalCrAmt = 0.0;
          double totalDrAmt = 0.0;

          for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
            totalDrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].dRAMT?.toString() ?? '0') ??
                0.0;
          }
          _ledgerAllData!.openingBalance = '0.0';

          _ledgerAllData!.crAmt = '0.0';
          _ledgerAllData!.drAmt = totalDrAmt.toStringAsFixed(2);
        } else if (val == SingingCharacter.systemjournal) {
          _ledgerAllData!.fullStat =
              originalList.where((o) => o.tYPE == 'Bill').toList();
          double totalCrAmt = 0.0;
          double totalDrAmt = 0.0;

          for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
            totalCrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].cRAMT?.toString() ?? '0') ??
                0.0;
            totalDrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].dRAMT?.toString() ?? '0') ??
                0.0;
          }
          _ledgerAllData!.openingBalance = '0.0';

          _ledgerAllData!.crAmt = totalCrAmt.toStringAsFixed(2);
          _ledgerAllData!.drAmt = totalDrAmt.toStringAsFixed(2);
        } else if (val == SingingCharacter.all) {
          _ledgerAllData!.fullStat =
              List.from(originalList); // Ensure full reset
          double totalCrAmt = 0.0;
          double totalDrAmt = 0.0;

          for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
            totalCrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].cRAMT?.toString() ?? '0') ??
                0.0;
            totalDrAmt += double.tryParse(
                    _ledgerAllData!.fullStat![i].dRAMT?.toString() ?? '0') ??
                0.0;
          }
          _ledgerAllData!.openingBalance = _ledgerAllDataDummy!.openingBalance;

          _ledgerAllData!.crAmt = totalCrAmt.toStringAsFixed(2);
          _ledgerAllData!.drAmt = totalDrAmt.toStringAsFixed(2);
        }
        _ledgerAllData!.fullStat?.sort((a, b) {
          return int.parse(a.sortNo!).compareTo(int.parse(b.sortNo!));
        });
        for (var i = 0; i < _ledgerAllData!.fullStat!.length; i++) {
          if (i == 0) {
            _ledgerAllData!.fullStat![i].nETAMT =
                (double.parse(_ledgerAllData!.fullStat![i].cRAMT!) -
                        double.parse(_ledgerAllData!.fullStat![i].dRAMT!))
                    .toStringAsFixed(2);
          } else {
            _ledgerAllData!.fullStat![i].nETAMT =
                (double.parse(_ledgerAllData!.fullStat![i - 1].nETAMT!) +
                        (double.parse(_ledgerAllData!.fullStat![i].cRAMT!) -
                            double.parse(_ledgerAllData!.fullStat![i].dRAMT!)))
                    .toStringAsFixed(2);
          }
        }
        _ledgerAllData!.fullStat?.sort((a, b) {
          return int.parse(b.sortNo!).compareTo(int.parse(a.sortNo!));
        });
        if (_ledgerAllData!.fullStat != null &&
            _ledgerAllData!.fullStat!.isNotEmpty) {
          if (_ledgerAllData!.fullStat![0].nETAMT != null) {
            _ledgerAllData!.closingBalance =
                _ledgerAllData!.fullStat![0].nETAMT!;
          }
        } else {
          _ledgerAllData!.closingBalance = '0.00';
        }
      }
    } else if (_currentfilterpage == 'pnl') {
      if (_pnlAllData?.transactions != null) {
        if (val == SingingCharacter.eq) {
          _pnlAllData!.transactions = _pnlAllDatadummy!.transactions!
              .where((o) =>
                  o.companyCode == 'BSE_CASH' ||
                  o.companyCode == 'NSE_CASH' ||
                  o.companyCode == 'MF_BSE' ||
                  o.companyCode == 'MF_NSE' ||
                  o.companyCode == 'NSE_SLBM' ||
                  o.companyCode == 'NSE_SPT')
              .toList();
          chargesforpnlseg(context, 'eq');
        }
        if (val == SingingCharacter.fno) {
          _pnlAllData!.transactions = _pnlAllDatadummy!.transactions!
              .where((o) =>
                  o.companyCode == 'NSE_FNO' || o.companyCode == 'BSE_FNO')
              .toList();
          chargesforpnlseg(context, 'fno');
        }
        if (val == SingingCharacter.com) {
          _pnlAllData!.transactions = _pnlAllDatadummy!.transactions!
              .where((o) =>
                  o.companyCode == 'MCX' ||
                  o.companyCode == 'NCDEX' ||
                  o.companyCode == 'NSE_COM' ||
                  o.companyCode == 'BSE_COM')
              .toList();
          chargesforpnlseg(context, 'comm');
        }
        if (val == SingingCharacter.cur) {
          _pnlAllData!.transactions = _pnlAllDatadummy!.transactions!
              .where((o) =>
                  o.companyCode == 'CD_NSE' ||
                  o.companyCode == 'CD_MCX' ||
                  o.companyCode == 'CD_USE' ||
                  o.companyCode == 'CD_BSE')
              .toList();
          chargesforpnlseg(context, 'curr');
        }
        if (val == SingingCharacter.all) {
          _pnlAllData!.transactions =
              List.from(_pnlAllDatadummy!.transactions ?? []);
          _pnlAllData!.expenseAmt = _pnlAllDatadummy!.expenseAmt;
        }
      }
    } else if (_currentfilterpage == 'tradebook') {
      if (_tradebookdata!.trades != null) {
        if (val == SingingCharacter.eq) {
          _tradebookdata!.trades = _tradebookdataDummy!.trades!
              .where((o) => o.cOMPANYCODE == 'NSE_CASH')
              .toList();
        }
        if (val == SingingCharacter.fno) {
          _tradebookdata!.trades = (_tradebookdataDummy!.trades ?? [])
              .where((o) => o.cOMPANYCODE == 'NSE_FNO')
              .toList();
        }
        if (val == SingingCharacter.com) {
          _tradebookdata!.trades = (_tradebookdataDummy!.trades ?? [])
              .where((o) => o.cOMPANYCODE == 'MCX')
              .toList();
        }
        if (val == SingingCharacter.cur) {
          _tradebookdata!.trades = (_tradebookdataDummy!.trades ?? [])
              .where((o) => o.cOMPANYCODE == 'CD_NSE')
              .toList();
        }
        if (val == SingingCharacter.buy) {
          _tradebookdata!.trades = (_tradebookdataDummy!.trades ?? [])
              .where((o) => o.showtype == 'BUY')
              .toList();
        }
        if (val == SingingCharacter.sell) {
          _tradebookdata!.trades = (_tradebookdataDummy!.trades ?? [])
              .where((o) => o.showtype == 'SELL')
              .toList();
        }
        if (val == SingingCharacter.all) {
          _tradebookdata!.trades = List.from(_tradebookdataDummy!.trades ?? []);
        }
      }
    } else if (_currentfilterpage == 'pdfdownload') {
      if (val == SingingCharacter.marginstatement) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'Margin Statement')
            .toList();
      } else if (val == SingingCharacter.contract) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'Contract')
            .toList();
      } else if (val == SingingCharacter.weekstate) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'Weekly Statement')
            .toList();
      } else if (val == SingingCharacter.rr) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'Retention Report')
            .toList();
      } else if (val == SingingCharacter.agts) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'AGTS Report')
            .toList();
      } else if (val == SingingCharacter.ledgerdetails) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'Ledger Detail')
            .toList();
      } else if (val == SingingCharacter.cn) {
        _pdfdownload!.data = (_pdfdaataDummy!.data ?? [])
            .where((o) => o.docType == 'CN')
            .toList();
      } else if (val == SingingCharacter.all) {
        _pdfdownload!.data = List.from(_pdfdaataDummy!.data ?? []);
      }
    }

    notifyListeners(); // Notify UI of changes
  }

  taxpnleqselectedtab(String value) {
    taxpnleqselectedtabdata = _eqtypestring == 'Asserts'
        ? taxpnleq!.data!.aSSETS!
        : _eqtypestring == 'Liabilities'
            ? taxpnleq!.data!.lIABILITIES!
            : _eqtypestring == 'Short Term'
                ? taxpnleq!.data!.sHORTTERM!
                : _eqtypestring == 'Long Term'
                    ? taxpnleq!.data!.tRADING!
                    : [];
  }

  taxpnlderselectedtab() {
    taxpnlderselectedtabdata = _dertypestring == 'Future Closed'
        ? taxpnldercomcur!.data!.derivatives!.derFutBooked != null
            ? taxpnldercomcur!.data!.derivatives!.derFutBooked!
            : []
        : _dertypestring == 'Future Open'
            ? taxpnldercomcur!.data!.derivatives!.derFutOpen!
            : _dertypestring == 'Option Closed'
                ? taxpnldercomcur!.data!.derivatives!.derOptBooked!
                : _dertypestring == 'Option Open'
                    ? taxpnldercomcur!.data!.derivatives!.derOptOpen!
                    : [];

    // taxpnlderselectedtabdata = _dertypestring == 'Future Closed'
    //     ? taxpnldercomcur!.data!.commodity!.comFutBooked!
    //     : _dertypestring == 'Future Open'
    //         ? taxpnldercomcur!.data!.commodity!.comFutOpen!
    //         : _dertypestring == 'Option Closed'
    //             ? taxpnldercomcur!.data!.commodity!.comOptBooked!
    //             : _dertypestring == 'Option Open'
    //                 ? taxpnldercomcur!.data!.commodity!.comOptOpen!
    //                 : [];

    // else if (value == '3') {
    //   taxpnlderselectedtabdata = _dertypestring == 'Future Closed'
    //       ? taxpnldercomcur!.data!.derivatives!.derFutBooked!
    //       : _dertypestring == 'Future Open'
    //           ? taxpnldercomcur!.data!.derivatives!.derFutOpen!
    //           : _dertypestring == 'Option Closed'
    //               ? taxpnldercomcur!.data!.derivatives!.derOptBooked!
    //               : _dertypestring == 'Option Open'
    //                   ? taxpnldercomcur!.data!.derivatives!.derOptOpen!
    //                   : [];
    // }
  }

  taxpnlcomselectedtab() {
    taxpnlcomselectedtabdata = _comtypestring == 'Future Closed'
        ? taxpnldercomcur!.data!.commodity!.comFutBooked!
        : _comtypestring == 'Future Open'
            ? taxpnldercomcur!.data!.commodity!.comFutOpen!
            : _comtypestring == 'Option Closed'
                ? taxpnldercomcur!.data!.commodity!.comOptBooked!
                : _comtypestring == 'Option Open'
                    ? taxpnldercomcur!.data!.commodity!.comOptOpen!
                    : [];

    // else if (value == '3') {
    //   taxpnlderselectedtabdata = _dertypestring == 'Future Closed'
    //       ? taxpnldercomcur!.data!.derivatives!.derFutBooked!
    //       : _dertypestring == 'Future Open'
    //           ? taxpnldercomcur!.data!.derivatives!.derFutOpen!
    //           : _dertypestring == 'Option Closed'
    //               ? taxpnldercomcur!.data!.derivatives!.derOptBooked!
    //               : _dertypestring == 'Option Open'
    //                   ? taxpnldercomcur!.data!.derivatives!.derOptOpen!
    //                   : [];
    // }
  }

  chngPnlmonthordaily(bool value) {
    isMonthly = value;
    notifyListeners();
  }

  sharingornotsharing(bool value) {
    notsharing = value;
    notifyListeners();
  }

  falseloader(String value) {
    if (value == 'ledger') {
      _ledgerloading = false;
    } else if (value == 'holdings') {
      _holdingsloading = false;
    } else if (value == 'pnl') {
      _pnlloading = false;
    } else if (value == 'calpnl') {
      _calendarpnlloading = false;
    } else if (value == 'tradebook') {
      _tradebookloading = false;
    } else if (value == 'taxpnl') {
      _taxderloading = false;
    } else if (value == 'download') {
      _pdfdownloadloading = false;
    }
    notifyListeners();
  }

  taxpnlcurselectedtab() {
    taxpnlcurselectedtabdata = _curtypestring == 'Future Closed'
        ? taxpnldercomcur!.data!.currency!.currFutBooked!
        : _curtypestring == 'Future Open'
            ? taxpnldercomcur!.data!.currency!.currFutOpen!
            : _curtypestring == 'Option Closed'
                ? taxpnldercomcur!.data!.currency!.currOptBooked!
                : _curtypestring == 'Option Open'
                    ? taxpnldercomcur!.data!.currency!.currOptOpen!
                    : [];

    // else if (value == '3') {
    //   taxpnlderselectedtabdata = _dertypestring == 'Future Closed'
    //       ? taxpnldercomcur!.data!.derivatives!.derFutBooked!
    //       : _dertypestring == 'Future Open'
    //           ? taxpnldercomcur!.data!.derivatives!.derFutOpen!
    //           : _dertypestring == 'Option Closed'
    //               ? taxpnldercomcur!.data!.derivatives!.derOptBooked!
    //               : _dertypestring == 'Option Open'
    //                   ? taxpnldercomcur!.data!.derivatives!.derOptOpen!
    //                   : [];
    // }
  }

  taxpnlExTabchange(val) {
    _activeTabTaxPnl = val;
    notifyListeners(); // Notify UI of changes
  }

  //

  // True if Monthly tab is active; false if Daily tab is active.
  bool isMonthly = true;

  bool notsharing = true;

  // The selected financial year, e.g., "2024-2025"
  late String selectedFinancialYear;

  String selectedSegment = 'Equity';
  String changeornot = '';

  // A list of available financial years (last 5 years).
  late List<String> availableFinancialYears;

  List<String> availableSegments = ['Equity', 'Fno', 'Commodity', 'Currency'];
  List<String> dailyormonthly = ['Monthly', 'Daily'];

  // Start and end dates for the selected financial year.
  late DateTime startTaxDate;
  late DateTime endTaxDate;

  late String formattedStartDate;
  late String formattedendDate;

  // The currently selected month for the Daily view.
  late DateTime selectedMonth;
  // late String selectnetpledge;
  TextEditingController selectnetpledge = TextEditingController();
  TextEditingController selectedqtyforcpaction =
      TextEditingController(text: '');
  TextEditingController selectedpriceforcpaction =
      TextEditingController(text: '');

  late bool pledgesubtn = true;
  late String pledgedropdown;

  String _pledgeerrormsg = "";
  String get pledgeerrormsg => _pledgeerrormsg;
  // Aggregated monthly P&L (key format: "YYYY-MM")
  Map<String, double> monthlyPnL = {};

  calendarProvider() {
    // Generate and store the last 5 financial years.
    availableFinancialYears = _generateFinancialYears(5);
    // Default to the first (current) financial year.
    selectedFinancialYear = availableFinancialYears.first;
    // Initialize startDate, endDate, selectedMonth, and monthlyPnL.
    setFinancialYear(selectedFinancialYear);
  }

  /// Sets the active tab: true for Monthly, false for Daily.
  void setTab(bool monthly) {
    isMonthly = monthly;
    notifyListeners();
  }

  /// Sets the currently selected month (for Daily view).
  void setSelectedMonth(DateTime month) {
    selectedMonth = month;
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////ofs/////////////////////////////////////////////////

  void setordervalueforofs(String qty, String price, String balance) {
    
    selectedqtyforcpaction.text = qty;

    final int qtyInt = int.parse(qty);
    final num priceNum =
        price.contains('.') ? double.parse(price) : int.parse(price);
    selectedpriceforcpaction.text = priceNum.toString();


    final num requiredAmount = qtyInt * priceNum;
    _requiredamountforofs = requiredAmount.toString();
    _cpactionerrormsg = '';
    // final balanceDouble =
    //     balance.contains('.') ? double.parse(balance) : int.parse(balance);
    //     _cpactionerrormsg = '';
          _pricevalidcp = true;
          _qtyvalidcp = true;
    checkbalace(_requiredamountforofs, balance);
  
    notifyListeners();
  }

  setCutoffcheckboxforofs(bool val, String cutOffPrice,String balance) {
    _cutoffcheckboxofs = val;
    if (val) {
      // Keep existing quantity, set price to cutoff price
      selectedpriceforcpaction.text = cutOffPrice;
      _pricevalidcp = true;
      checkbalace(_requiredamountforofs, balance);
      _cpactionerrormsg = '';

    } else {
      selectedpriceforcpaction.text = '';
      _pricevalidcp = false;
        _cpactionsubtn = false;
      _cpactionerrormsg = 'Price cannot be empty';

    }
    
    
    notifyListeners();
  }

  setofpricebox(String price, String balance, String base) {
    selectedpriceforcpaction.text = price;
    final baseprice = base.contains('.')
        ? double.parse(base)
        : int.parse(base);
    final priceText = selectedpriceforcpaction.text.trim();
    // final balanceDouble =
    //     balance.contains('.') ? double.parse(balance) : int.parse(balance);
    final parsedPrice = price != '' ? int.parse(priceText) : 0;

    _requiredamountforofs =
        (parsedPrice * int.parse(selectedqtyforcpaction.text)).toString();

    if (priceText.isEmpty) {
      _cpactionerrormsg = 'Price cannot be empty';
      _pricevalidcp = false;
        _cpactionsubtn = false;

    }  else {
      final parsedPrice = int.tryParse(priceText);
      if (parsedPrice != null && parsedPrice > 0) {
       
          _cpactionerrormsg = '';
          if (baseprice > parsedPrice) {
            _captionforofs = 'Price cannot be less than base price ₹$base';
            _pricevalidcp = false;
            _cpactionsubtn = false;
          } else {
            _cpactionerrormsg = '';
            _qtyvalidcp = true;
            _pricevalidcp = true; 
            _cpactionsubtn = true;
            checkbalace(_requiredamountforofs, balance);
          }
          
         
      } else {
        _cpactionerrormsg = 'Invalid price input';
        _pricevalidcp = false;
        _cpactionsubtn = false;
      }
    }
    

    notifyListeners();
  }

  setofqtybox(String qty, String balance) {
    selectedqtyforcpaction.text = qty;
    // Validate quantity input
    final int qtyInt = int.tryParse(qty) ?? 0;
    final num priceNum = selectedpriceforcpaction.text.contains('.')
        ? double.parse(selectedpriceforcpaction.text)
        : int.parse(selectedpriceforcpaction.text);
    // final balanceDouble =
    //     balance.contains('.') ? double.parse(balance) : int.parse(balance);

    _requiredamountforofs = (qtyInt * priceNum).toString();
    if (qty.isEmpty) {
      _cpactionerrormsg = 'Quantity cannot be empty';
        _cpactionsubtn = false; 
      _qtyvalidcp = false;

    } else if (qty.contains('.')) {
      _cpactionerrormsg = 'Quantity cannot be decimal';
      _cpactionsubtn = false;
      
      _qtyvalidcp = false;
       

    }   else {
      final qtyInt = int.parse(qty);
      if (qtyInt > 0) {
        _cpactionerrormsg = '';
        _cpactionsubtn = true;

        _qtyvalidcp = true;
      } else {
        _cpactionerrormsg = 'Invalid quantity input';
        _cpactionsubtn = false;

        _qtyvalidcp = false;
      }
    }

    checkbalace(_requiredamountforofs, balance);

    notifyListeners();
  }

  checkbalace(String req, String balance) {
    final balanceDouble =
        balance.contains('.') ? double.parse(balance) : int.parse(balance);
    final requiredAmount = req.contains('.')
        ? double.parse(req)
        : int.parse(req);

   
     if (requiredAmount > 200000) {
      _captionforofs = 'Bid amount ₹$requiredAmount exceeds limit of ₹200,000';
      _cpactionsubtn = false;
    } 
    else if ((balanceDouble < requiredAmount) ) {
      _captionforofs = 'Insufficient balance for bid';
      _cpactionsubtn = false;
    }
    else if (balanceDouble >= requiredAmount && _qtyvalidcp == true && _pricevalidcp == true) {
      _captionforofs = 'Required amount for bid';
      _cpactionsubtn = true;
    }else{
      _captionforofs = 'Enter bid quantity and price';
      _cpactionsubtn = false; 
    }
   
    notifyListeners();

  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Helper method to recalculate OFS amount
  void _recalculateOFSAmount(String balance) {
    final qtyText = selectedqtyforcpaction.text.trim();
    final priceText = selectedpriceforcpaction.text.trim();

    final qtyInt = int.tryParse(qtyText) ?? 0;
    final priceInt = int.tryParse(priceText) ?? 0;
    final balanceDouble = double.tryParse(balance) ?? 0.0;

    if (qtyInt > 0 && priceInt > 0) {
      final totalAmount = qtyInt * priceInt;
      _requiredamountforofs = totalAmount.toString();

      // Update caption based on validation rules
      if (totalAmount > 200000) {
        _captionforofs = 'Bid amount ₹$totalAmount exceeds limit of ₹200,000';
        _cpactionsubtn = false;
      } else if (totalAmount > balanceDouble) {
        _captionforofs = 'Insufficient balance for bid: ₹$totalAmount';
        _cpactionsubtn = false;
      } else {
        _captionforofs = 'Required amount for bid: ₹$totalAmount';
        _cpactionsubtn = _qtyvalidcp && _pricevalidcp;
      }
    } else {
      _requiredamountforofs = '0';
      _captionforofs = 'Enter bid quantity and price';
      _cpactionsubtn = false;
    }
    notifyListeners();
  }

  void setCutoffcheckboxofs(bool val, String cutOffPrice, String balance) {
    _cutoffcheckboxofs = val;
    if (val) {
      // Keep existing quantity, set price to cutoff price
      selectedpriceforcpaction.text = cutOffPrice;
      _pricevalidcp = true;
      _cpactionerrormsg = '';
    } else {
      selectedpriceforcpaction.text = '';
      _pricevalidcp = false;
      _cpactionerrormsg = '';
    }
    _recalculateOFSAmount(balance);
    notifyListeners();
  }

  void setCPActionQty(String setnet, String qty, String type, String balance) {
    if (type == 'OFS') {
      selectedqtyforcpaction.text = setnet;

      // Validate quantity input for OFS
      if (setnet.isEmpty) {
        _cpactionerrormsg = 'Quantity cannot be empty';
        _qtyvalidcp = false;
      } else {
        final qtyInt = int.tryParse(setnet);
        if (qtyInt != null && qtyInt > 0) {
          _qtyvalidcp = true;
          _cpactionerrormsg = '';
        } else {
          _cpactionerrormsg = 'Invalid quantity input';
          _qtyvalidcp = false;
        }
      }

      // Recalculate amount using existing price
      _recalculateOFSAmount(balance);
    } else {
      final net = int.tryParse(setnet);
      final qtyDouble = double.tryParse(qty);
      final qtyInt = qtyDouble != null ? (qtyDouble.toInt()) : null;
      if (setnet.isEmpty) {
        _cpactionerrormsg = 'Quantity cannot be empty';
        _qtyvalidcp = false;
      } else if (net != null && qtyInt != null) {
        if (net > qtyInt) {
          _cpactionerrormsg = 'Qty must be less than or equal to $qty';
          _qtyvalidcp = false;
        } else {
          _qtyvalidcp = true;
        }
      } else {
        _cpactionerrormsg = 'Invalid quantity input';
        _qtyvalidcp = false;
      }

      selectedqtyforcpaction.text = setnet;
      _evaluateCPActionValidation();
    }
    notifyListeners();
  }

  void setCPActionPrice(
      String setprice, double min, double max, String type, String balance) {
    if (type == 'OFS') {
      selectedpriceforcpaction.text = setprice;

      // Validate price input for OFS
      if (setprice.isEmpty) {
        _pricevalidcp = false;
        _cpactionerrormsg = 'Price cannot be empty';
      } else {
        final parsedPrice = int.tryParse(setprice);
        if (parsedPrice != null && parsedPrice > 0) {
          if (parsedPrice < min) {
            _pricevalidcp = false;
            _cpactionerrormsg =
                'Price cannot be below base price (₹${min.toInt()})';
          } else {
            _pricevalidcp = true;
            _cpactionerrormsg = '';
          }
        } else {
          _pricevalidcp = false;
          _cpactionerrormsg = 'Invalid price input';
        }
      }

      // Recalculate amount using existing quantity
      _recalculateOFSAmount(balance);
    } else {
      if (setprice.isEmpty) {
        _pricevalidcp = false;
        _cpactionerrormsg = 'Price cannot be empty';
        selectedpriceforcpaction.text = '';
        _evaluateCPActionValidation();
        notifyListeners();
        return;
      }

      final parsedValue = double.tryParse(setprice);

      if (parsedValue != null) {
        if (parsedValue >= min && parsedValue <= max) {
          _pricevalidcp = true;
        } else {
          _pricevalidcp = false;
          _cpactionerrormsg = 'Price must be between $min - $max';
        }
      } else {
        _pricevalidcp = false;
        _cpactionerrormsg = 'Invalid price input'; /////
      }

      selectedpriceforcpaction.text = setprice;
      _evaluateCPActionValidation();
    }

    notifyListeners();
  }

  /// Combines the result of both validations
  void _evaluateCPActionValidation() {
    // For OFS, we need to check both validation flags and the required amount
    if (_qtyvalidcp && _pricevalidcp) {
      // Don't override the button state set by captioncheckofs for OFS
      // For non-OFS actions, enable the button
      if (_requiredamountforofs == '0') {
        _cpactionsubtn = false;
      } else {
        // For non-OFS or when OFS has valid amount
        if (_captionforofs.contains('exceeds') ||
            _captionforofs.contains('Insufficient')) {
          _cpactionsubtn = false;
        } else {
          _cpactionsubtn = true;
        }
      }
      _cpactionerrormsg = '';
    } else {
      _cpactionsubtn = false;
      // Error message is already set in the individual validation methods
    }
  }

  void setselectnetpledge(String setnet, String net) {
    _pledgeoruppledgedelete = '';
    selectnetpledge.text = setnet;

    if (setnet != 'null') {
      print("setnet ${int.tryParse(setnet)} net ${int.tryParse(net)}");

      if (((int.tryParse(setnet) != null ? int.tryParse(setnet)! : 0) <=
              (int.tryParse(net) != null ? int.tryParse(net)! : 0)) &&
          int.tryParse(setnet) != 0 &&
          setnet != "") {
        _pledgeerrormsg = '';
        pledgesubtn = true;
      } else {
        _pledgeerrormsg = 'Qty between 0 - $net';
        pledgesubtn = false;
      }
    } else {
      _pledgeerrormsg = 'Qty between 0 - $net';
      pledgesubtn = false;
    }

    notifyListeners();
  }

  /// Sets the financial year and updates the startDate, endDate, selectedMonth,
  /// and monthlyPnL aggregation using the provided [heatmapData].
  void setFinancialYear(String fy) {
    // Only update if the value has changed.
    if (fy == "") {
      selectedFinancialYear = availableFinancialYears.first;
      fy = selectedFinancialYear;
    } else {
      selectedFinancialYear = fy;
    }

    // Parse "YYYY-YYYY" to extract the start year.
    final parts = fy.split('-');
    final startYear = int.parse(parts[0]);

    // Define the financial year range: April of startYear to March of startYear+1.
    startTaxDate = DateTime(startYear, 4, 1);
    formattedStartDate = DateFormat("dd/MM/yyyy").format(startTaxDate);
    endTaxDate = DateTime(startYear + 1, 3, 31);
    formattedendDate = DateFormat("dd/MM/yyyy").format(endTaxDate);

    // Determine current financial year based on today's date.
    final now = DateTime.now();
    final currentFYStartYear = now.month < 4 ? now.year - 1 : now.year;

    // If the selected FY is the current one, default to current month in Daily view;
    // otherwise, default to the FY start date.
    selectedMonth = (startYear == currentFYStartYear)
        ? DateTime(now.year, now.month, 1)
        : startTaxDate;

    if (_heatmapData != {}) {
      // Aggregate monthly P&L data for this financial year.
      monthlyPnL = _aggregateMonthlyPnL(_heatmapData, startTaxDate, endTaxDate);
    }
    // Schedule notifyListeners to run after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setSegment(String seg) {
    selectedSegment = seg;
    notifyListeners();
  }

  void changeormountedsharing(String change) {
    changeornot = change;
    notifyListeners();
  }

  void changesegval(String seg, int index) {
    _pledgeandunpledge!.data![index].segmentselect = seg;

    _segmentvalue = seg;
    notifyListeners();
  }

  void changesegvaldummy(String seg) {
    print("object ${_listforpledge}");
    if (_listforpledge == []) {
      _segmentvaluedummy = '';
    } else {
      _segmentvaluedummy = seg;
    }
    notifyListeners();
  }

  void dummypledgeval(int share, String net, String type) {
    if (type == 'pledge') {
      pledgeandunpledge!.data![share].dummvalue = net;
      _pledgeorunpledge = 'pledge';
    } else {
      pledgeandunpledge!.data![share].dummunpledgevalue = net;
      _pledgeorunpledge = 'unpledge';
    }
    notifyListeners();
  }

  void unpledgedeletereqfun(context, String isin, int index) {
    _pledgeoruppledgedelete = 'unpledgedelete';
    bool found = false;
    for (var i = 0; i < _pledgeandunpledge!.data!.length; i++) {
      _pledgeandunpledge!.data![index].deleteselected = 'selected';
    }
    for (var i = 0; i < _listforpledge.length; i++) {
      if (_listforpledge[i] == isin) {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'Script Already added'),
        );
        found = true;
        break; // No need to check further
      }
    }

    if (!found) {
      _listforpledge.add(isin);
      ScaffoldMessenger.of(context).showSnackBar(
        successMessage(context, 'Script Added'),
      );
    }
    print("${_listforpledge.length}loakdsdejkvh");
    notifyListeners();
  }

  Future beforecdsl(BuildContext context, String ccode, String boid,
      String cname, List list) async {
    try {
      _pledgeloader = true;
      notifyListeners();

      final res = await api.geturlforcdsl(ccode, boid, cname, list);
      Navigator.pop(context);

      Navigator.pushNamed(context, Routes.cdslWebView, arguments: res);

      // Navigator.pushNamed(context, Routes.camsWebView,
      //     arguments: res);+
      Future.delayed(Duration(milliseconds: 1000));

      cancelpledgetotal('pledge');
      _pledgeloader = false;
      notifyListeners();
    } catch (e) {
      _pledgeloader = false;

      notifyListeners();
    } finally {
      toggleLoad(false);
    }
  }

  Future cdslresponsepage(BuildContext context, String response) async {
    try {
      _pledgeloader = true;
      notifyListeners();

      _cdslresponsedata = await api.getresponsefromcdsl(response);
      _pledgeloader = false;

      // Navigator.pushNamed(context, Routes.camsWebView,
      //     arguments: res);
      notifyListeners();
    } catch (e) {
      _pledgeloader = false;

      notifyListeners();
    } finally {
      toggleLoad(false);
    }
  }

  void listforpledgefunction(
      BuildContext context,
      String seg,
      String sym,
      String isin,
      String value,
      String qty,
      String net,
      String type,
      int index) {
    print("object");
    bool found = false;
    if (type == 'pledge') {
      _pledgeandunpledge!.data![index].segmentselect = seg;

      for (var i = 0; i < _listforpledge.length; i++) {
        if (_listforpledge[i]['isin'] == isin) {
          _listforpledge[i]['quantity'] = qty;
          ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'Script Updated'),
          );
          found = true;
          break; // No need to check further
        }
      }

      if (!found) {
        _listforpledge.add({
          "segments": seg,
          "symbol": sym,
          "isin": isin,
          "value": value,
          "quantity": qty,
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            successMessage(context, 'Script Added'),
          );
      }
    } else {
      for (var i = 0; i < _listforpledge.length; i++) {
        if (_listforpledge[i]['ISIN'] == isin) {
          _listforpledge[i]['COLQTY'] = qty;
          _listforpledge[i]['unplege_qty'] = qty;
          ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'Script Updated'),
          );
          found = true;
          break; // No need to check further
        }
      }

      if (!found) {
        _listforpledge.add({
          "COLQTY": qty,
          "ISIN": isin,
          "NET": net,
          "NSE_SYMBOL": sym,
          "unplege_qty": qty,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'Script Added'),
        );
      }
    }
    print("$_listforpledge listforpledgefunction");
    notifyListeners();
  }

  void cancelpledgetotal(String type) {
    pledgesubtn = false;

    if (type == 'pledge') {
      if (_pledgeandunpledge != null && _pledgeandunpledge!.data != null) {
        for (var i = 0; i < _pledgeandunpledge!.data!.length; i++) {
          _pledgeandunpledge!.data![i].dummvalue = 'null';
          _pledgeandunpledge!.data![i].segmentselect = 'null';
          _pledgeandunpledge!.data![i].deleteselected = '';
        }
      }

      _pledgeoruppledgedelete = '';
      _pledgeorunpledge = '';

      _listforpledge = [];
    } else {
      if (_pledgeandunpledge != null && _pledgeandunpledge!.data != null) {
        for (var i = 0; i < _pledgeandunpledge!.data!.length; i++) {
          _pledgeandunpledge!.data![i].dummunpledgevalue = 'null';
          _pledgeandunpledge!.data![i].deleteselected = '';
        }
      }

      _listforpledge = [];
      _pledgeorunpledge = '';
    }
    //  _pledgeandunpledge!.data = [];

    notifyListeners();
  }

  /// Aggregates daily P&L into monthly sums for the given [start] and [end] dates.
  /// The key format is "YYYY-MM".
  Map<String, double> _aggregateMonthlyPnL(
      Map<DateTime, double> data, DateTime start, DateTime end) {
    final Map<String, double> result = {};
    data.forEach((date, pnl) {
      if (date.isBefore(start) || date.isAfter(end)) return;
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      result[key] = (result[key] ?? 0) + pnl;
    });
    return result;
  }

  /// Generates a list of the last [count] financial years (in descending order).
  /// Each financial year is represented as a string "YYYY-YYYY".
  List<String> _generateFinancialYears(int count) {
    final now = DateTime.now();
    // If current month is before April, current FY started last year.
    int currentFYStartYear = now.month < 4 ? now.year - 1 : now.year;
    final years = <String>[];
    for (int i = 0; i < count; i++) {
      final startY = currentFYStartYear - i;
      years.add("$startY-${startY + 1}");
    }
    return years;
  }

  void clearOFSFields() {
    selectedqtyforcpaction.text = '';
    selectedpriceforcpaction.text = '';
    _requiredamountforofs = '0';
    _captionforofs = 'Enter bid quantity and price';
    _qtyvalidcp = false;
    _pricevalidcp = false;
    _cpactionsubtn = false;
    _cpactionerrormsg = '';
    _cutoffcheckboxofs = false;
    notifyListeners();
  }
}
// List<double> getCustItemsHeight() {
//   List<double> itemsHeights = [];
//   for (var i = 0; i < (_paymentMethod.length * 2) - 1; i++) {
//     if (i.isEven) {
//       itemsHeights.add(40);
//     }
//     if (i.isOdd) {
//       itemsHeights.add(4);
//     }
//   }
//   return itemsHeights;
// }
