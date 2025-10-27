// ignore_for_file: use_build_context_synchronously, deprecated_member_use
//import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:public_ip_address/public_ip_address.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../models/fund_model_testing_copy/fund_direct_payment_model.dart';
import '../models/fund_model_testing_copy/fund_pay.model.dart';
import '../models/fund_model_testing_copy/fund_payment_status_model.dart';
import '../models/fund_model_testing_copy/fund_payment_withdraw.dart';
import '../models/fund_model_testing_copy/fund_razorpay_model.dart';
import '../models/fund_model_testing_copy/fund_razorpay_status_model.dart';
import '../models/fund_model_testing_copy/fund_tranction_his_model.dart';
import '../models/fund_model_testing_copy/fund_upi_status_model.dart';
import '../models/fund_model_testing_copy/fund_validation_token.dart';
import '../models/fund_model_testing_copy/fund_withdraw_model.dart';
import '../models/fund_model_testing_copy/fund_withdraw_status_model.dart';
import '../models/fund_model_testing_copy/secured_bank_detalis_model.dart';
import '../models/fund_model_testing_copy/secured_client_data_model.dart';
import '../models/fund_model_testing_copy/view_upi_id.dart';
import '../res/res.dart';
import '../screens/Mobile/profile_screen/fund_screen/upi_apps_screens/cancel_request_alert_box.dart';
import '../screens/Mobile/profile_screen/fund_screen/upi_apps_screens/no_upi_apps_alert.dart';
import '../screens/Mobile/profile_screen/fund_screen/upi_apps_screens/upi_apps_payment_failed.dart';
import '../screens/Mobile/profile_screen/fund_screen/upi_id_screens/upi_id_payment_fail_or_success.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/fund_function.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
// import 'package:http/http.dart' as http;

final transcationProvider =
    ChangeNotifierProvider((ref) => TranctionProvider(ref));

class TranctionProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  TextEditingController amount = TextEditingController();
  TextEditingController upiid = TextEditingController();
  TextEditingController withdrawamount = TextEditingController();

  // TranctionHistoryModel? _tranctionHistoryModel;
  // TranctionHistoryModel? get tranctionHistoryModel => _tranctionHistoryModel;

  int _selectedIndex = -1;
  int get selectedindex => _selectedIndex;

  int _intValue = 0;
  int get intValue => _intValue;

  int _indexss = 0;
  int get indexss => _indexss;

  String _ifsc = '';
  String get ifsc => _ifsc;

  String _bankname = '';
  String get bankname => _bankname;

  String _textValue = '';
  String get textValue => _textValue;

  String _accno = '';
  String get accno => _accno;

  String _multipleAccno = '';
  String get multipleAccno => _multipleAccno;

  String _initbank = '';
  String get initbank => _initbank;

  String _textResult = "";
  String get textResult => _textResult;

  String _funderror = '';
  String get funderror => _funderror;

  String _allacc = "";

  String _maxfunderror = '';
  String get maxfunderror => _maxfunderror;

  String _ipAddress = '';
  String get ipAddress => _ipAddress;

  bool _enable = true;
  bool get enable => _enable;

  bool _upiIdbutton = true;
  bool get upiIdbutton => _upiIdbutton;

  List<String>? _urls = [];
  List<String>? get url => _urls;

  Map<String, dynamic>? _dsds = {};
  Map<String, dynamic>? get dsds => _dsds;

  upiAppsAccnoFormat(String accono) {
    List y = [accono];

    for (var i in bankdetails!.dATA!) {
      if (y.length == 4) {
        break;
      }
      if (!y.contains(i[2])) {
        y.add(i[2]);
      }
    }

    String number = y.join("!");
    _multipleAccno = number;
    // print("DDDDDDDDDDD $number");
  }

  bankselection(int index) {
    _initbank =
        '${bankdetails!.dATA![index][1]}-${hideAccountNumber(bankdetails!.dATA![index][2])}';

    _accno = bankdetails!.dATA![index][2];
    upiAppsAccnoFormat(_accno);
    _ifsc = bankdetails!.dATA![index][3];
    _bankname = bankdetails!.dATA![index][1];

    notifyListeners();
  }

  segmentselection(int index) {
    _textValue = decryptclientcheck!.companyCode![index];
    notifyListeners();
  }

  changeIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  changebool(bool value) {
    _enable = value;
    notifyListeners();
  }

  textFiledonChange(String value) {
    _selectedIndex = 0;
    if (amount.text.isNotEmpty) {
      var val = int.parse(value);
      _intValue = val;

      if (_intValue < 50) {
        _funderror = "Min amount ₹50";
      } else if (_intValue > 100000) {
        _selectedIndex = 2;
      }
      if (_intValue > 5000000) {
        _maxfunderror = "Max amount ₹5,000,000";
      }
    }

    int number = int.tryParse(value) ?? 0;
    String result = NumberToWord().convert('en-in', number);
    _textResult = capitalizeFirstLetter(result);
    notifyListeners();
  }

  FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  List<String> _companycode = [];
  List<String> get companycodes => _companycode;

  RegExp _upiPattern = RegExp(r'^[\w.-]+@[\w.-]+$');
  RegExp get upiPattern => _upiPattern;

  // Replace single bottom sheet flag with two separate flags
  bool _isUpiAppsBottomSheetShown = false;
  bool get isUpiAppsBottomSheetShown => _isUpiAppsBottomSheetShown;

  bool _isUpiIdBottomSheetShown = false;
  bool get isUpiIdBottomSheetShown => _isUpiIdBottomSheetShown;

  final List _defaultUpiapps = [
    {'name': 'UPI APPS', 'image': assets.upiIcon1, 'limit': '1,00,000'},
    {'name': 'UPI ID', 'image': assets.upiIcon1, 'limit': '1,00,000'},
    {
      'name': 'NET BANKING',
      'image': assets.netbankingIcon,
      'limit': '5,000,000'
    },
  ];
  List get defaultUpiapps => _defaultUpiapps;

  final List _addfundIcons = [
    {
      'image': assets.upiIcon,
    },
    {
      'image': assets.upiIcon,
    },
    {
      'image': assets.netbankingIcon,
    },
  ];
  List get addfundIcons => _addfundIcons;

  upiidOnchange(String value) {
    // upiid.text = value;
    notifyListeners();
  }

  ip() async {
    try {
      toggleLoadingOn(true);
      String ip = await IpAddress().getIp();
      _ipAddress = ip;
      return _ipAddress;
    } finally {
      toggleLoadingOn(false);
    }
  }

  initialdata(BuildContext contex) {
    // Reset form state
    _intValue = 0;
    _funderror = '';
    _maxfunderror = '';
    amount.clear();
    // upiid.clear();

    // Reset other form-related states
    _selectedIndex = -1;
    _upiIdbutton = true;
    upiiderror = null;
    amounterror = null;

    // Reset bottom sheet state
    _isUpiAppsBottomSheetShown = false;
    _isUpiIdBottomSheetShown = false;

    // Initialize bank and account data
    _multipleAccno = _accno = bankdetails!.dATA![index][2];
    _ifsc = bankdetails!.dATA![indexss][3];
    _bankname = bankdetails!.dATA![indexss][1];
    upiAppsAccnoFormat(bankdetails!.dATA![indexss][2]);
    _initbank =
        '${bankdetails!.dATA![indexss][1]} - ${hideAccountNumber(accno)}';
    _textValue = decryptclientcheck!.companyCode![0];
    _companycode = decryptclientcheck!.companyCode!;
    setAccountslist(_accno);
    if (_companycode.contains("NSE_FNO")) {
      _textValue = "NSE_FNO";
    } else if (_companycode.contains("NSE_CASH")) {
      _textValue = "NSE_CASH";
    } else if (_companycode.contains("MCX")) {
      _textValue = "MCX";
    } else {
      _textValue = decryptclientcheck!.companyCode![0];
    }
  }

  changeValue(bool value, BuildContext context, {bool isUpiApps = true}) {
    if (isUpiApps) {
      _isUpiAppsBottomSheetShown = value;
    } else {
      _isUpiIdBottomSheetShown = value;
    }
    Navigator.pop(context);
    notifyListeners();
  }

  // Reset bottom sheet state when starting a new payment process
  void resetBottomSheetState() {
    _isUpiAppsBottomSheetShown = false;
    _isUpiIdBottomSheetShown = false;
    notifyListeners();
  }

  String? amounterror, upiiderror;

  clearerror() {
    upiiderror = null;
    amounterror = null;
    notifyListeners();
  }

  validateUPI(String value) {
    // upiid.text = value;
    if (upiid.text.isEmpty) {
      upiiderror = 'Please enter a UPI ID';
    } else if (!_upiPattern.hasMatch(upiid.text)) {
      upiiderror = 'Please enter a valid UPI ID';
    } else {
      _upiIdbutton = false;
      upiiderror = null;
      upiiderror = "";
    }
    notifyListeners();
    return upiiderror == null && _upiIdbutton == false;
  }

  int index = 0;

  List<ViewUpiIdModel>? _viewUpiIdModel;
  List<ViewUpiIdModel>? get viewUpiIdModel => _viewUpiIdModel;

  DecryptClientCheck? _decryptclientcheck;
  DecryptClientCheck? get decryptclientcheck => _decryptclientcheck;

  PayoutDetails? _payoutdetails;
  PayoutDetails? get payoutdetails => _payoutdetails;

  HdfcPaymentModel? _hdfcpaymentdata;
  HdfcPaymentModel? get hdfcpaymentdata => _hdfcpaymentdata;

  HdfcTranctionModel? _hdfctranction;
  HdfcTranctionModel? get hdfctranction => _hdfctranction;

  HdfcPaymentStatus? _hdfcpaymentstatus;
  HdfcPaymentStatus? get hdfcpaymentstatus => _hdfcpaymentstatus;

  List<UpiId>? _upiid;
  List<UpiId>? get upiId => _upiid;

  List<WithdrawStatus>? _withdrawstatus = [];
  List<WithdrawStatus>? get withdrawstatus => _withdrawstatus;

  PaymentWithdraw? _paymentWithdraw;
  PaymentWithdraw? get paymentWithdraw => _paymentWithdraw;

  HdfcDirectPayment? _hdfcdirectpayment;
  HdfcDirectPayment? get hdfcdirectpayment => _hdfcdirectpayment;

  BankDetails? _bankdetails;
  BankDetails? get bankdetails => _bankdetails;

  Razorpays? _razorpay;
  Razorpays? get razorpay => _razorpay;

  RazorpayTranstationRes? _razorpayTranstationRes;
  RazorpayTranstationRes? get razorpayTranstationRes => _razorpayTranstationRes;

  HdfcUPIStatus? _hdfcUPIStatus;
  HdfcUPIStatus? get hdfcUPIStatus => _hdfcUPIStatus;

  FundTokenValidation? _fundTokenValidation;
  FundTokenValidation? get fundTokenValidation => _fundTokenValidation;

  final Ref ref;

  TranctionProvider(this.ref);

  redirectToUPI() async {
    String url = '${_hdfcdirectpayment!.data!.upilink}';
    await launch(url);
    notifyListeners();
  }

  Future fetchValidateToken(BuildContext context) async {
    try {
      togglefundLoading(true);

      _fundTokenValidation = await api.getFundvalidateSession();
      if (_fundTokenValidation!.emsg == "invalid token") {
        ref.read(authProvider).ifSessionExpired(context);
        notifyListeners();
      }
      notifyListeners();
      //  print("------------ ${_fundTokenValidation!.msg}}");
    } catch (e) {
      //  log("validate session:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchValidateToken", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchUpiPaymentstatus(
    BuildContext context,
    String orderNo,
    String upiTranID,
  ) async {
    print(
        "fetchUpiPaymentstatus called with orderNo: $orderNo, upiTranID: $upiTranID");
    //final localstorage = await SharedPreferences.getInstance();
    try {
      if (!context.mounted) {
        return false;
      }
      togglefundLoading(true);
      _hdfcUPIStatus = await api.getHdfcUPIStatus(orderNo, upiTranID);
      print("UPI Apps Payment Status Response");
      if (!context.mounted) {
        return false;
      }
      if (hdfcUPIStatus?.data?.status == "FAILED" ||
          hdfcUPIStatus?.data?.status == "REJECTED" ||
          hdfcUPIStatus?.data?.status == "SUCCESS") {
        if (!_isUpiAppsBottomSheetShown) {
          _isUpiAppsBottomSheetShown = true;
          if (context.mounted) {
            showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                backgroundColor: const Color(0xffffffff),
                isDismissible: false,
                enableDrag: false,
                showDragHandle: false,
                useSafeArea: false,
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return PopScope(
                      canPop: false,
                      onPopInvokedWithResult: (didPop, result) async {
                        if (didPop) return;
                      },
                      child: const UPIAppsPaymentSuccessAlert());
                }).whenComplete(() {
              _isUpiAppsBottomSheetShown = false;
            });
          }
        }
        return false;
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ref
            .read(indexListProvider)
            .logError
            .add({"type": "fetchUpiPaymentstatus", "Error": "$e"});
        notifyListeners();
      }
      return true;
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchc(BuildContext context) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);

      _decryptclientcheck = await api.getClientDetails();

      // print("client emsg ${_decryptclientcheck!.emsg}");
      //   print("------------ ${_decryptclientcheck!.companyCode!}");
    } catch (e) {
      //log("Failed to fetch Profile Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchclient", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchcwithdraw(BuildContext context) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);

      _payoutdetails = await api.getWithdrawPayout(context);

      fetchPaymentWithDrawStatus(context);
      double marg = 0;
      double reqs = 0;

      double ledger =
          double.tryParse(_payoutdetails!.totalLedger.toString()) ?? 0;

      double brkColl =
          double.tryParse(_payoutdetails!.brkcollamt.toString()) ?? 0;
      double collateral =
          double.tryParse(_payoutdetails!.collateral.toString()) ?? 0;
      double margin = double.tryParse(_payoutdetails!.margin.toString()) ?? 0;
      double fd = double.tryParse(_payoutdetails!.fD.toString()) ?? 0;

      if (ledger > 0) {
        marg = brkColl > 0
            ? brkColl - margin
            : collateral > 0
                ? collateral - margin
                : 0;

        if (marg <= 0 && fd > 0) {
          reqs = marg + fd;
        }
        if (reqs <= 0) {
          reqs = reqs + ledger;
        }
      }

      _payoutdetails!.withdrawAmount = (margin > 0 && (reqs > 0 || marg > 0))
          ? ((reqs > 0 ? reqs : ledger)).toStringAsFixed(2)
          : (double.tryParse(_payoutdetails!.withdrawAmount.toString()) ?? 0)
              .toStringAsFixed(2);

      //  print("------------ ${ApiLinks.token}");

      // print("WITHDRAW PAYOUT ${_payoutdetails!.withdrawAmount}.");
      // print("WITHDRAW PAYOUT ${_payoutdetails!.cash}.");
    } catch (e) {
      // log("Failed to Get Payout Detial:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchcwithdraw", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchfundbank(BuildContext context) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);
      _bankdetails = await api.getbankDetails();
      // print("------------ ${_bankdetails!}");
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchfundbank", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetcUPIIDPayment(
      BuildContext context, String upiId, String clientId, String accno) async {
    try {
      togglefundLoading(true);
      print(
          "UPI ID Payment Initiation: upiId=$upiId, clientId=$clientId, accno=$accno, bankname=$_bankname, segment=$_textValue");
      _hdfcpaymentdata =
          await api.getUPIIDPayment(upiId, clientId, accno, _bankname);

// print("bankname()*(*):: ${bankdetails!.dATA![indexss][1]}");
      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Not Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Not Available") {
        upiiderror = 'UPI ID is Invaild';
        notifyListeners();

        return; // Stop the flow if UPI ID is invalid
      }
      print("HDFC BANK $hdfcpaymentdata");
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetcUPIIDPayment", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchHdfctranction(
    BuildContext context,
    String upiId,
    int amount,
    String accno,
    String clientId,
  ) async {
    try {
      togglefundLoading(true);
      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Available") {
        _hdfctranction =
            await api.getHdfcTranction(upiId, amount, _allacc, clientId);
      }
      //print("HDFC BANK ${hdfcpaymentdata!.data!.clientVPA![0]}");
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchHdfctranction", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchUPIPaymet(BuildContext context, String amt, String bankaccno,
      String clientid, String name) async {
    try {
      togglefundLoading(true);
      print(
          "UPI Apps Payment Initiation: amt=$amt, bankaccno=$bankaccno, clientid=$clientid, name=$name, segment=$_textValue");
      _hdfcdirectpayment =
          await api.getUPIAppsPayment(amt, _allacc, clientid, name);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
      } else {
        if (_fundTokenValidation?.emsg == "invalid token") {
        } else {
          checkAndLaunchUrl("${_hdfcdirectpayment!.data!.upilink}", context);
        }
      }
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchUPIPaymet", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  setAccountslist(String accno) {
    List<AccountItem> items = [];
    for (var i = 0; i < _bankdetails!.dATA!.length; i++) {
      if (accno != _bankdetails?.dATA?[i][2]) {
        items.add(AccountItem(
            accno: _bankdetails?.dATA?[i][2], ifsc: _bankdetails?.dATA?[i][3]));
      }
    }
    _allacc =
        "$accno${items.isNotEmpty ? '!' : ''}${getFormattedAccountNumbers(items)}";
    print("_allacc $_allacc");
  }

  String setAccountis(AccountItem item) {
    String selectedAccNo = item.accno;
    if (item.ifsc.startsWith("SBIN") || item.ifsc.startsWith("CBIN")) {
      int bankcount = selectedAccNo.length;
      if (bankcount <= 17) {
        int remaining = 17 - bankcount;
        String paddedAccountNumber = '0' * remaining + selectedAccNo;
        selectedAccNo = paddedAccountNumber;
      }
    }
    return selectedAccNo;
  }

  String getFormattedAccountNumbers(List<AccountItem> items) {
    List<String> selectedAccounts = items.take(3).map(setAccountis).toList();
    return selectedAccounts.join("!");
  }

  Future<void> checkAndLaunchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // Only show bottom sheet if it hasn't been shown yet
      if (!_isUpiIdBottomSheetShown) {
        _isUpiIdBottomSheetShown = true;

        // Final check before showing bottom sheet
        if (context.mounted) {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              backgroundColor: const Color(0xffffffff),
              isDismissible: false,
              enableDrag: false,
              showDragHandle: false,
              useSafeArea: false,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) async {
                      if (didPop) return;
                    },
                    child: const PaymentCancelAlert());
              });
        }
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Only show bottom sheet if it hasn't been shown yet
      if (!_isUpiIdBottomSheetShown) {
        _isUpiIdBottomSheetShown = true;

        // Final check before showing bottom sheet
        if (context.mounted) {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              backgroundColor: const Color(0xffffffff),
              context: context,
              builder: (BuildContext context) {
                return const NoUPIAppsAlert();
              });
        }
      }
    }
  }

  Future<bool> fetchHdfcpaymetstatus(
      BuildContext context, String ordno, String upiTransid) async {
    try {
      if (!context.mounted) {
        return false;
      }
      togglefundLoading(true);
      _hdfcpaymentstatus = await api.getHdfcPaymentstatus(ordno, upiTransid);
      print("UPI ID Payment Status Response  [32m");
      if (!context.mounted) {
        return false;
      }
      if (hdfcpaymentstatus?.upiId?.status == "EXPIRED" ||
          hdfcpaymentstatus?.upiId?.status == "REJECTED" ||
          hdfcpaymentstatus?.upiId?.status == "SUCCESS" ||
          hdfcpaymentstatus?.upiId?.status == "FAILED") {
        if (!_isUpiIdBottomSheetShown) {
          _isUpiIdBottomSheetShown = true;
          if (context.mounted) {
            showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                backgroundColor: Colors.transparent,
                isDismissible: false,
                enableDrag: false,
                showDragHandle: false,
                useSafeArea: false,
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return PopScope(
                      canPop: false,
                      onPopInvokedWithResult: (didPop, result) async {
                        if (didPop) return;
                      },
                      child:
                          Container(child: const UpiIdSucessorFaliureScreen()));
                }).whenComplete(() {
              _isUpiIdBottomSheetShown = false;
            });
          }
        }
        return false;
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ref
            .read(indexListProvider)
            .logError
            .add({"type": "fetchHdfcpaymetstatus", "Error": "$e"});
        notifyListeners();
      }
      return true;
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchrazorpay(
    BuildContext context,
    String amt,
    String accno,
    String name,
    String ifsc,
    Razorpay razorpay,
  ) async {
    try {
      togglefundLoading(true);
      print(
          "Net Banking Payment Initiation: amt=$amt, accno=$accno, name=$name, ifsc=$ifsc, segment=$_textValue");
      _razorpay = await api.getrazorpay(amt, accno, name, ifsc);
      if (_razorpay!.status == "created") {
        var options = {
          'key': 'rzp_live_M3tazzVCcFf8Iq',
          'amount': int.parse("${_razorpay!.amount}").toString(),
          'name': 'Zebu Fund',
          'currency': 'INR',
          'order_id': _razorpay!.id,
          'image': "https://zebuetrade.com/wp-content/uploads/2020/07/logo.png",
          'description':
              "Fund add to ${_decryptclientcheck!.clientCheck!.dATA![_indexss][0]}",
          'send_sms_hash': true,
          'prefill': {
            'name': _decryptclientcheck!.clientCheck!.dATA![_indexss][2],
            'email': _decryptclientcheck!.clientCheck!.dATA![_indexss][4],
            'contact': _decryptclientcheck!.clientCheck!.dATA![_indexss][5],
            'method': 'netbanking',
            'bank': _bankname,
          },
          'notes': {
            'clientcode':
                "${_decryptclientcheck!.clientCheck!.dATA![_indexss][0]}",
            'acc_no': _accno,
            'ifsc': _ifsc,
            'bankname': _bankname,
            'company_code': _textValue,
          },
          'theme': {
            'color': "#3399cc",
          },
          'retry': {
            'enabled': false,
            'max_count': 0,
          },
        };

        razorpay.open(options);
      }
    } catch (e) {
      //  log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "RAZORPAY", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchrazorpayStatus(String paymentid) async {
    _razorpayTranstationRes = null;
    try {
      togglefundLoading(true);
      _razorpayTranstationRes = await api.getrazorpayStatus(paymentid);
      print(
          "Net Banking (Razorpay) Payment Status Response $_razorpayTranstationRes");
      // log("PAYMENT ID${_razorpayTranstationRes?.id} $paymentid");
    } catch (e) {
      // log("Failed to Razorpay Status:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchrazorpayStatus", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchupiIdView(String bankname, String accountnumber) async {
    try {
      toggleLoadingOn(true);

      _viewUpiIdModel = await api.getUpiId(bankname, accountnumber);
      amount.clear();
      if (_viewUpiIdModel!.isNotEmpty) {
        upiid.text = "${_viewUpiIdModel![0].upiId}";
        ref.read(ipoProvide).viewupiid.text = "${_viewUpiIdModel![0].upiId}";
      } else {
        upiid.clear();
      }
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchupiIdView", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchPaymentWithDraw(
      String ip, String amount, String segment, BuildContext context) async {
    try {
      togglefundLoading(true);
      _paymentWithdraw = await api.getpayemntwithdraw(ip, amount, segment);
      if (_paymentWithdraw!.msg == "Sucess") {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'Withdrawal request sent successfully'));
        withdrawamount.clear();
        fetchPaymentWithDrawStatus(context);
      } else {
        print("Withdrawal failed with message: ${_paymentWithdraw!.msg}");
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context, 'Withdrawal failed: ${_paymentWithdraw!.msg}'));
      }
    } catch (e) {
      print("Withdrawal error: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchPaymentWithDraw", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }

  Future fetchPaymentWithDrawStatus(BuildContext context) async {
    try {
      togglefundLoading(true);

      _withdrawstatus = await api.getWithDrawStatus();
      //print("${_withdrawstatus?[0].eNTRYTIME}");
      // print("${_withdrawstatus?[0].msg}");
    } catch (e) {
      //log("Failed to Payment withdraw:: ${e.toString()}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "fetchPaymentWithDrawStatus", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoading(false);
    }
  }
}
