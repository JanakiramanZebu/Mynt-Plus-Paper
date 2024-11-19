// ignore_for_file: use_build_context_synchronously, deprecated_member_use
//import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:public_ip_address/public_ip_address.dart';
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
import '../screens/profile_screen/fund_screen/upi_apps_screens/upi_apps_payment_failed.dart';
import '../screens/profile_screen/fund_screen/upi_id_screens/upi_id_payment_fail_or_success.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/fund_function.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final transcationProvider =
    ChangeNotifierProvider((ref) => TranctionProvider(ref.read));

class TranctionProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  TextEditingController amount = TextEditingController();
  TextEditingController upiid = TextEditingController();
  TextEditingController withdrawamount = TextEditingController();

  int _selectedIndex = -1;
  int get selectedindex => _selectedIndex;

  int _intValue = 0;
  int get intValue => _intValue;

  final int _indexss = 0;
  int get indexss => _indexss;

  String _ifsc = '';
  String get ifsc => _ifsc;

  String _bankname = '';
  String get bankname => _bankname;

  String _textValue = '';
  String get textValue => _textValue;

  String _accno = '';
  String get accno => _accno;

  String _initbank = '';
  String get initbank => _initbank;

  String _textResult = "";
  String get textResult => _textResult;

  String _funderror = '';
  String get funderror => _funderror;

  String _maxfunderror = '';
  String get maxfunderror => _maxfunderror;

  String _ipAddress = '';
  String get ipAddress => _ipAddress;

  bool _enable = true;
  bool get enable => _enable;

  bool _upiIdbutton = true;
  bool get upiIdbutton => _upiIdbutton;

  bankselection(int index) {
    _initbank =
        '${bankdetails!.dATA![index][1]}-${hideAccountNumber(bankdetails!.dATA![index][2])}';
    _accno = bankdetails!.dATA![index][2];
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

  final FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  List<String> _companycode = [];
  List<String> get companycodes => _companycode;

  final RegExp _upiPattern = RegExp(r'^[\w.-]+@[\w.-]+$');
  RegExp get upiPattern => _upiPattern;

  bool _isBottomSheetShown = true;
  bool get isBottomSheetShown => _isBottomSheetShown;

  final List _defaultUpiapps = [
    {
      'name': 'UPI APPS',
      'image': 'assets/icon/icons8-bhim.svg',
      'limit': '1,00,000'
    },
    {
      'name': 'UPI ID',
      'image': 'assets/icon/icons8-bhim.svg',
      'limit': '1,00,000'
    },
    {
      'name': 'NET BANKING',
      'image': 'assets/icon/razpay.svg',
      'limit': '5,000,000'
    },
  ];
  List get defaultUpiapps => _defaultUpiapps;

  upiidOnchange(String value) {
    upiid.text = value;
    notifyListeners();
  }

  Ip() async {
    try {
      toggleLoadingOn(true);
      final getIp = await IpAddress().getAllData();
      _ipAddress = getIp['ip'];
      return _ipAddress;
    } finally {
      toggleLoadingOn(false);
    }
  }

  initialdata(BuildContext contex) {
    // get initial data from api
    _intValue = 0;
    _accno = bankdetails!.dATA![indexss][2];
    _ifsc = bankdetails!.dATA![indexss][3];
    _bankname = bankdetails!.dATA![indexss][1];
    _initbank =
        '${bankdetails!.dATA![indexss][1]} - ${hideAccountNumber(accno)}';
    _textValue = decryptclientcheck!.companyCode![0];
    _companycode = decryptclientcheck!.companyCode!;
    _selectedIndex = -1;
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

  changeValue(bool value, BuildContext context) {
    _isBottomSheetShown = value;
    Navigator.pop(context);
    notifyListeners();
  }

  String? amounterror, upiiderror;

  clearerror() {
    upiiderror == null;
    amounterror == null;
    notifyListeners();
  }

  validateUPI(String value) {
    upiid.text = value;
    if (upiid.text.trim().isEmpty) {
      upiiderror = 'Please enter a UPI ID';
    } else if (!_upiPattern.hasMatch(upiid.text)) {
      upiiderror = 'Please enter a valid UPI ID';
    } else {
      _upiIdbutton = false;
      upiiderror = null;
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

  Razorpay? _razorpay;
  Razorpay? get razorpay => _razorpay;

  RazorpayTranstationRes? _razorpayTranstationRes;
  RazorpayTranstationRes? get razorpayTranstationRes => _razorpayTranstationRes;

  HdfcUPIStatus? _hdfcUPIStatus;
  HdfcUPIStatus? get hdfcUPIStatus => _hdfcUPIStatus;

  FundTokenValidation? _fundTokenValidation;
  FundTokenValidation? get fundTokenValidation => _fundTokenValidation;

  final Reader ref;

  TranctionProvider(this.ref);

  redirectToUPI() async {
    String url = '${_hdfcdirectpayment!.data!.upilink}';
    await launch(url);
    notifyListeners();
  }

  Future fetchValidateToken(BuildContext context) async {
    try {
      togglefundLoadingOn(true);

      _fundTokenValidation = await api.getFundvalidateSession();
      if (_fundTokenValidation!.emsg == "invalid token") {
        ref(authProvider).ifSessionExpired(context);
      }

      //  print("------------ ${_fundTokenValidation!.msg}}");
    } catch (e) {
      //  log("validate session:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchUpiPaymentstatus(
    BuildContext context,
    String orderNo,
    String upiTranID,
  ) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      togglefundLoadingOn(true);
      _hdfcUPIStatus = await api.getHdfcUPIStatus(orderNo, upiTranID);
      if (hdfcUPIStatus?.data?.status == "EXPIRED" ||
          hdfcUPIStatus?.data?.status == "REJECTED" ||
          hdfcUPIStatus?.data?.status == "SUCCESS") {
        togglefundLoadingOn(false);
        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            backgroundColor: const Color(0xffffffff),
            isDismissible: false,
            enableDrag: false,
            showDragHandle: false,
            useSafeArea: false,
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: const UPIAppsPaymentSuccessAlert());
            });
      }
    } catch (e) {
      // log("Failed to fetch bank Data:: ${e.toString()}");
      //  ref(TranctionProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchc(BuildContext context) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);

      _decryptclientcheck = await api.getClientDetails();
      // print("------------ ${ApiLinks.token}");
      //print("------------ ${_decryptclientcheck!.clientCheck!.dATA![0]}");
    } catch (e) {
      //log("Failed to fetch Profile Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
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

      if (double.tryParse(_payoutdetails!.totalLedger.toString())! > 0) {
        if (double.tryParse(_payoutdetails!.brkcollamt.toString())! > 0) {
          marg = double.tryParse(_payoutdetails!.brkcollamt.toString())! -
              double.tryParse(_payoutdetails!.margin.toString())!;
        } else {
          if (double.tryParse(_payoutdetails!.collateral.toString())! > 0) {
            marg = double.tryParse(_payoutdetails!.collateral.toString())! -
                double.tryParse(_payoutdetails!.margin.toString())!;
          }
        }

        if (marg <= 0 && double.tryParse(_payoutdetails!.fD.toString())! > 0) {
          reqs = marg + double.tryParse(_payoutdetails!.fD.toString())!;
        }

        if (marg <= 0 &&
            double.tryParse(_payoutdetails!.totalLedger.toString())! > 0) {
          reqs =
              marg + double.tryParse(_payoutdetails!.totalLedger.toString())!;
        }
      }

      _payoutdetails!.withdrawAmount =
          (double.tryParse(_payoutdetails!.margin.toString())! > 0 &&
                  (reqs > 0 || marg > 0))
              ? ((90 / 100) *
                      (reqs > 0
                          ? reqs
                          : double.tryParse(
                                  _payoutdetails!.totalLedger.toString()) ??
                              0))
                  .toStringAsFixed(2)
              : (double.tryParse(_payoutdetails!.withdrawAmount
                          .toString()
                          .toString()) ??
                      0)
                  .toStringAsFixed(2);

      //  print("------------ ${ApiLinks.token}");
      // print("WITHDRAW PAYOUT ${_payoutdetails!.emsg}.");
      // print("WITHDRAW PAYOUT ${_payoutdetails!.withdrawAmount}.");
      // print("WITHDRAW PAYOUT ${_payoutdetails!.cash}.");
    } catch (e) {
      // log("Failed to Get Payout Detial:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
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
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetcUPIIDPayment(
      BuildContext context, String upiId, String clientId, String accno) async {
    try {
      togglefundLoadingOn(true);
      _hdfcpaymentdata = await api.getUPIIDPayment(upiId, clientId, accno);

      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Not Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Not Available") {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, 'Please enter the valid UPI ID'));
      }
      //log("HDFC BANK $hdfcpaymentdata");
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
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
      togglefundLoadingOn(true);
      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Available") {
        _hdfctranction =
            await api.getHdfcTranction(upiId, amount, accno, clientId);
      }
      //print("HDFC BANK ${hdfcpaymentdata!.data!.clientVPA![0]}");
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchUPIPaymet(BuildContext context, String amt, String bankaccno,
      String clientid, String name) async {
    try {
      togglefundLoadingOn(true);

      _hdfcdirectpayment =
          await api.getUPIAppsPayment(amt, bankaccno, clientid, name);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
      } else {
        launch("${_hdfcdirectpayment!.data!.upilink}");
      }
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchHdfcpaymetstatus(
      BuildContext context, String ordno, String upiTransid) async {
    try {
      togglefundLoadingOn(true);

      _hdfcpaymentstatus = await api.getHdfcPaymentstatus(ordno, upiTransid);
      _isBottomSheetShown = true;
      if (hdfcpaymentstatus?.upiId?.status == "EXPIRED" ||
          hdfcpaymentstatus?.upiId?.status == "REJECTED" ||
          hdfcpaymentstatus?.upiId?.status == "SUCCESS") {
        _isBottomSheetShown = false;
        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            backgroundColor: const Color(0xffffffff),
            isDismissible: false,
            enableDrag: false,
            showDragHandle: false,
            useSafeArea: false,
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: const UpiIdSucessorFaliureScreen());
            });
      }

      //print("HDFC PAYMENTSTATUS ${_hdfcpaymentstatus!.upiId!.clientVPA}");
    } catch (e) {
      // log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchrazorpay(BuildContext context, String amt, String accno,
      String name, String ifsc) async {
    try {
      togglefundLoadingOn(true);

      _razorpay = await api.getrazorpay(amt, accno, name, ifsc);
    } catch (e) {
      //  log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchrazorpayStatus(String paymentid) async {
    try {
      togglefundLoadingOn(true);
      _razorpayTranstationRes = await api.getrazorpayStatus(paymentid);
      // log("PAYMENT ID${_razorpayTranstationRes?.id} $paymentid");
    } catch (e) {
      // log("Failed to Razorpay Status:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchupiIdView(String bankname, String accountnumber) async {
    try {
      toggleLoadingOn(true);

      _viewUpiIdModel = await api.getUpiId(bankname, accountnumber);
      amount.clear();
      if (_viewUpiIdModel!.isNotEmpty) {
        upiid.text = "${_viewUpiIdModel![0].upiId}";
      } else {
        upiid.clear();
      }
    } catch (e) {
      //log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchPaymentWithDraw(
      String ip, String amount, String segment, BuildContext context) async {
    try {
      togglefundLoadingOn(true);
      _paymentWithdraw = await api.getpayemntwithdraw(ip, amount, segment);
      if (_paymentWithdraw!.msg == "Sucess") {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'Payment Withdraw Sucessfully'));
        fetchPaymentWithDrawStatus(context);
      }
    } catch (e) {
      //log("Failed to Payment withdraw:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchPaymentWithDrawStatus(BuildContext context) async {
    try {
      togglefundLoadingOn(true);

      _withdrawstatus = await api.getWithDrawStatus();
      //print("${_withdrawstatus?[0].eNTRYTIME}");
      // print("${_withdrawstatus?[0].msg}");
    } catch (e) {
      //log("Failed to Payment withdraw:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      togglefundLoadingOn(false);
    }
  }
}
