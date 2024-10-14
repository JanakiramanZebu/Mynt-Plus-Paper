// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../models/func_model_testing_copy/fund_direct_payment_model.dart';
import '../models/func_model_testing_copy/fund_pay.model.dart';
import '../models/func_model_testing_copy/fund_payment_status_model.dart';
import '../models/func_model_testing_copy/fund_razorpay_model.dart';
import '../models/func_model_testing_copy/fund_tranction_his_model.dart';
import '../models/func_model_testing_copy/fund_upi_status_model.dart';
import '../models/func_model_testing_copy/fund_withdraw_model.dart';
import '../models/func_model_testing_copy/secured_bank_detalis_model.dart';
import '../models/func_model_testing_copy/secured_client_data_model.dart';
import '../models/func_model_testing_copy/view_upi_id.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final transcationProvider =
    ChangeNotifierProvider((ref) => TranctionProvider(ref.read));

class TranctionProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  TextEditingController amount = TextEditingController();
  TextEditingController upiid = TextEditingController();

  bool _isUpiAppAvailable = false;
  bool get isUpiAppAvailable => _isUpiAppAvailable;

  String? amounterror, upiiderror;

  clearerror() {
    upiiderror == null;
    amounterror == null;
    notifyListeners();
  }

  bool validateamount() {
    clearerror();
    if (amount.text.trim().isEmpty) {
      amounterror = "Please enter the amount";
    } else {
      amounterror == null;
    }
    notifyListeners();
    return amounterror == null;
  }

  bool validateUPI() {
    clearerror();
    if (upiid.text.trim().isEmpty) {
      upiiderror = 'Please enter a  UPI ID';
    } else if (!RegExp(r'^[a-zA-Z0-9.-]{2, 256}@[a-zA-Z][a-zA-Z]{2, 64}$')
        .hasMatch(upiid.text)) {
      upiiderror = 'Please enter a valid UPI ID';
    } else {
      upiiderror == null;
    }
    notifyListeners();
    return upiiderror == null && amounterror == null;
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

  HdfcDirectPayment? _hdfcdirectpayment;
  HdfcDirectPayment? get hdfcdirectpayment => _hdfcdirectpayment;

  BankDetails? _bankdetails;
  BankDetails? get bankdetails => _bankdetails;

  Razorpay? _razorpay;
  Razorpay? get razorpay => _razorpay;

  HdfcUPIStatus? _hdfcUPIStatus;
  HdfcUPIStatus? get hdfcUPIStatus => _hdfcUPIStatus;

  final List _upimenu = [
    {
      "title": "Paying with UPI apps",
      "leading": "assets/img/bankimage.png",
      "subTitle": "₹50 - ₹2,00,000"
    },
    {
      "title": "Paying with UPI ID",
      "leading": "assets/img/upi_logo_icon.png",
      "subTitle": "₹50 - ₹2,00,000"
    },
    {
      "title": "Paying with Razorpay",
      "leading": "assets/img/razorpay-icon.png",
      "subTitle": "₹50 - ₹2,00,000"
    }
  ];
  final List _bankdetail = [
    {"title": "HDFC", "logo": "assets/icon/hdfc_bank_vector_logo.png"},
    {"title": "ATOM", "logo": "assets/icon/images (1).png"}
  ];
  final List _netbanking = [
    {"title": "RAZORPAY", "logo": "assets/icon/images.png"},
    {"title": "ATOM", "logo": "assets/icon/images (1).png"}
  ];
  List get bankdetail => _bankdetail;
  List get netbanking => _netbanking;

  List get upimenu => _upimenu;

  List _margin = [];
  List _equity = [];
  List _utlization = [];
  List get margin => _margin;
  List get equity => _equity;
  List get utlization => _utlization;

  List _logError = [];
  List get logError => _logError;

  final Reader ref;

  TranctionProvider(this.ref);

  redirectToUPI() async {
    String url = '${_hdfcdirectpayment!.data!.upilink}';
    await launch(url);
    notifyListeners();
  }

  Future fetchUpiPaymentstatus(
    BuildContext context,
    String orderNo,
    String upiTranID,
  ) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);
      _hdfcUPIStatus = await api.getHdfcUPIStatus(orderNo, upiTranID);

      print("------------ ${_hdfcUPIStatus!.data!.orderNumber}");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      //  ref(TranctionProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchc(BuildContext context) async {
    //final localstorage = await SharedPreferences.getInstance();
    try {
      toggleLoadingOn(true);

      _decryptclientcheck = await api.getClientDetails();
      // print("------------ ${ApiLinks.token}");
      print("------------ ${_decryptclientcheck!.clientCheck!.dATA![0]}");
    } catch (e) {
      log("Failed to fetch Profile Data:: ${e.toString()}");
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

      _payoutdetails = await api.getWithdrawPayout();
      //  print("------------ ${ApiLinks.token}");
      print("WITHDRAW PAYOUT $_payoutdetails");
    } catch (e) {
      log("Failed to fetch Profile Data:: ${e.toString()}");
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
      print("------------ ${_bankdetails!}");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetcUPIIDPayment(
      BuildContext context, String upiId, String clientId, String accno) async {
    try {
      toggleLoadingOn(true);
      _hdfcpaymentdata = await api.getUPIIDPayment(upiId, clientId, accno);
      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Not Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Not Available") {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, 'Please enter the valid UPI ID'));
      }
      log("HDFC BANK $hdfcpaymentdata");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
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
      toggleLoadingOn(true);
      if (hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Available" ||
          hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Available") {
        _hdfctranction =
            await api.getHdfcTranction(upiId, amount, accno, clientId);
      }
      print("HDFC BANK ${hdfcpaymentdata!.data!.clientVPA![0]}");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchUPIPaymet(BuildContext context, String amt, String bankaccno,
      String clientid, String name) async {
    try {
      toggleLoadingOn(true);

      _hdfcdirectpayment =
          await api.getUPIAppsPayment(amt, bankaccno, clientid, name);
      //launch("${_hdfcdirectpayment!.data!.upilink}");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchHdfcpaymetstatus(
      BuildContext context, String ordno, String upiTransid) async {
    try {
      toggleLoadingOn(true);

      _hdfcpaymentstatus = await api.getHdfcPaymentstatus(ordno, upiTransid);

      print("HDFC PAYMENTSTATUS ${_hdfcpaymentstatus!.data!.clientVPA}");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchrazorpay(BuildContext context, String amt, String accno,
      String name, String ifsc) async {
    try {
      toggleLoadingOn(true);

      _razorpay = await api.getrazorpay(amt, accno, name, ifsc);
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchupiIdView(String bankname, String accountnumber) async {
    try {
      toggleLoadingOn(true);

      _viewUpiIdModel = await api.getUpiId(bankname, accountnumber);
      if (_viewUpiIdModel!.isNotEmpty) {
        upiid.text = "${_viewUpiIdModel![0].upiId}";
      } else {
        upiid.clear();
      }
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }
}
