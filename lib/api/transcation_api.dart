import 'dart:developer';

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
import '../sharedWidget/fund_function.dart';
import 'core/api_core.dart';

mixin TranscationApi on ApiCore {
  Future<HdfcPaymentModel> getUPIIDPayment(
      String upiId, String clientId, String accno) async {
    try {
      final uri = Uri.parse(apiLinks.verifyUPI);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode(
              {"VPA": upiId, "clientID": clientId, "bank_acc": accno}));
      final json = jsonDecode(res.body);
      //  log("HDFC STATUS => ${res.body}");
      final hdfcbankpayment = HdfcPaymentModel.fromJson(json);
      return hdfcbankpayment;
    } catch (e) {
      rethrow;
    }
  }

  Future<HdfcUPIStatus> getHdfcUPIStatus(
      String orderNo, String upiTranID) async {
    try {
      final uri = Uri.parse(apiLinks.fundUpiStatus);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "OrderNo": orderNo,
            "upiTranID": upiTranID,
            "clientID": prefs.clientId
          }));
      final json = jsonDecode(res.body);
      log("HDFC UPI STATUS => ${res.body}");
      final hdfcupistatus = HdfcUPIStatus.fromJson(json);
      return hdfcupistatus;
    } catch (e) {
      rethrow;
    }
  }

  Future<HdfcDirectPayment> getUPIAppsPayment(
      String amt, String bankaccno, String clientid, String name) async {
    try {
      final uri = Uri.parse(apiLinks.fundpayment);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "amount": amt,
            "bank_acc": bankaccno,
            "clientID": clientid,
            "Name": name
          }));
      final json = jsonDecode(res.body);
      //   log("HDFC DRIECT PAYMENT => ${res.body}");
      final hdfcdirectbankpayment = HdfcDirectPayment.fromJson(json);
      return hdfcdirectbankpayment;
    } catch (e) {
      rethrow;
    }
  }

  Future<Razorpay> getrazorpay(
      String amt, String accno, String name, String ifsc) async {
    String url =
        "https://fundapi.mynt.in/razorpay/razorpay?amount=$amt&method=netbanking&account_number=$accno&name=$name&ifsc=$ifsc&ccode=${prefs.clientId}";
    log(url);
    try {
      final res = await apiClient.post(
        Uri.parse(url),
        body: jsonEncode({
          'amount': amt,
          'method': 'netbanking',
          'account_number': accno,
          'name': name,
          'ifsc': ifsc,
          'ccode': prefs.clientId
        }),
        headers: razorpaytHeaders,
      );

      final json = jsonDecode(res.body);
      // log("DDDDDDDDD ${res.body} ");
      final razorpay = Razorpay.fromJson(json);
      return razorpay;
    } catch (e) {
      rethrow;
    }
  }

  Future<HdfcPaymentStatus> getHdfcPaymentstatus(
      String ordno, String upiTransid) async {
    try {
      final uri = Uri.parse(apiLinks.tranctiontstatus);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "OrderNo": ordno,
            "upiTranID": upiTransid,
            "clientID": prefs.clientId
          }));
      final json = jsonDecode(res.body);
      // log("HDFC PAYMENTSTATUS => ${res.body}");
      final hdfcbankpaymentstatus = HdfcPaymentStatus.fromJson(json);
      return hdfcbankpaymentstatus;
    } catch (e) {
      rethrow;
    }
  }

  Future<HdfcTranctionModel> getHdfcTranction(
    String upiId,
    int amount,
    String accno,
    String clientId,
  ) async {
    try {
      final uri = Uri.parse(apiLinks.moneytransction);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "VPA": upiId,
            "amount": amount,
            "bank_acc": accno,
            "clientID": clientId
          }));
      final json = jsonDecode(res.body);
      //  log("HDFC tranction => ${res.body}");
      final hdfctranction = HdfcTranctionModel.fromJson(json);
      return hdfctranction;
    } catch (e) {
      rethrow;
    }
  }

  Future<DecryptClientCheck> getClientDetails() async {
    String payload = jsonEncode({"client_code": prefs.clientId});
    String encryptedPayload = encryptionFunction(payload);
    try {
      final uri = Uri.parse(apiLinks.clientcheck);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"code": encryptedPayload}));
      final json = jsonDecode(res.body);

      final decryptedData = decryptionFunction(json["str"]);
      //  log("------------ ${jsonDecode(jsonEncode(decryptedData))}}");

      return DecryptClientCheck.fromJson(jsonDecode(decryptedData));
    } catch (e) {
      rethrow;
    }
  }

  Future<PayoutDetails> getWithdrawPayout() async {
    String payload = jsonEncode({"client_id": prefs.clientId});
    String encryptedPayload = encryptionFunction(payload);
    try {
      final uri = Uri.parse(apiLinks.withdraw);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"string": encryptedPayload}));
      final json = jsonDecode(res.body);
      final decryptedData = decryptionFunction(json["str"]);
      log("------------ ${jsonDecode(jsonEncode(decryptedData))}}");
      return PayoutDetails.fromJson(jsonDecode(decryptedData));
    } catch (e) {
      rethrow;
    }
  }

  Future<BankDetails> getbankDetails() async {
    String payload = jsonEncode({"client_code": prefs.clientId});
    String encryptedPayload = encryptionFunction(payload);
    try {
      final uri = Uri.parse(apiLinks.bankcheck);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"code": encryptedPayload}));
      final json = jsonDecode(res.body);
      final decryptedData = decryptionFunction(json["str"]);
      log("------------ ${jsonDecode(jsonEncode(decryptedData))}}");
      return BankDetails.fromJson(jsonDecode(decryptedData));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ViewUpiIdModel>> getUpiId(
      String bankname, String accountnumber) async {
    String payload = jsonEncode({
      "account_number": accountnumber,
      "bank_name": bankname,
      "client_id": prefs.clientId,
    });
    String encryptedPayload = encryptionFunction(payload);
    try {
      final uri = Uri.parse(apiLinks.fundUpiIdView);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"string": encryptedPayload}));
      final json = jsonDecode(res.body);

      final decryptedData = decryptionFunction(json["str"]);
      List<dynamic> myList = jsonDecode(decryptedData);
      final List<ViewUpiIdModel> data = [];
      for (var element in myList) {
        data.add(ViewUpiIdModel.fromJson(element as Map<String, dynamic>));
      }
      log("VIEW UPI ID ---> $myList");

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
