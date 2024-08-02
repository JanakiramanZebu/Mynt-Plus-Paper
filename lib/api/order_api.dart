import 'dart:developer';
import '../models/order_book_model/cancel_order_model.dart';
import '../models/order_book_model/get_brokerage.dart';
import '../models/order_book_model/gtt_order_book.dart';
import '../models/order_book_model/modify_order_model.dart';
import '../models/order_book_model/order_book_model.dart';
import '../models/order_book_model/order_history_model.dart';
import '../models/order_book_model/order_margin_model.dart';
import '../models/order_book_model/place_gtt_order.dart';
import '../models/order_book_model/place_order_model.dart';
import '../models/order_book_model/sip_order_book.dart';
import '../models/order_book_model/sip_order_cancel.dart';
import '../models/order_book_model/sip_place_order.dart';
import '../models/order_book_model/trade_book_model.dart';
import 'core/api_core.dart';
import 'core/api_link.dart';

mixin OrderAPI on ApiCore {
  Future<PlaceOrderModel> getPlaceOrder(PlaceOrderInput placeOrderInput) async {
    try {
      final uri = Uri.parse(apiLinks.placeOrder);
      Map payload = {
        "uid": prefs.clientId,
        "actid": prefs.clientId,
        "exch": placeOrderInput.exch,
        "tsym": placeOrderInput.tsym.contains("&")
            ? placeOrderInput.tsym.replaceAll("&", "%26")
            : placeOrderInput.tsym,
        "qty": placeOrderInput.qty.replaceAll("-", ""),
        "prc": placeOrderInput.prc,
        "prd": placeOrderInput.prd,
        "trantype": placeOrderInput.trantype,
        "prctyp": placeOrderInput.prctype,
        "ret": placeOrderInput.ret,
        "channel": placeOrderInput.channel,
        "usr_agent": placeOrderInput.userAgent,
        "app_inst_id": placeOrderInput.appInstaId,
        "ordersource": ApiLinks.source
      };
      if (placeOrderInput.amo == "Yes") {
        payload.addAll({"amo": "Yes"});
      }
      if (placeOrderInput.blprc.isNotEmpty) {
        payload.addAll({"blprc": placeOrderInput.blprc});
      }
      if (placeOrderInput.bpprc.isNotEmpty) {
        payload.addAll({"bpprc": placeOrderInput.bpprc});
      }
      if (placeOrderInput.trailprc.isNotEmpty) {
        payload.addAll({"trailprc": placeOrderInput.trailprc});
      }
      if (placeOrderInput.trgprc.isNotEmpty) {
        payload.addAll({"trgprc": placeOrderInput.trgprc});
      }
      if (placeOrderInput.mktProt.isNotEmpty) {
        payload.addAll({"mkt_protection": placeOrderInput.mktProt});
      }

      // log("PlaceOrder Input => $payload");

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');
      // log("PlaceOrder => ${res.body}");
      final json = jsonDecode(res.body);

      return PlaceOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderBookModel>> getOrderBook() async {
    try {
      final uri = Uri.parse(apiLinks.getOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}" }&jKey=${prefs.clientSession}''');
      //  log("ORDER BOOK RESPONSE ::: ${res.body}");
      // log(res.statusCode.toString());

      final List<OrderBookModel> data = [];

      final json = jsonDecode(res.body);
      try {
        if (json['stat'] == 'Not_Ok') {
          final OrderBookModel ord =
              OrderBookModel.fromJson(json as Map<String, dynamic>);
          return [ord];
        } else {
          for (final item in json) {
            data.add(OrderBookModel.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        if (res.statusCode == 200) {
          for (final item in json) {
            data.add(OrderBookModel.fromJson(item as Map<String, dynamic>));
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TradeBookModel>> getTradeBook() async {
    try {
      final uri = Uri.parse(apiLinks.tradeBook);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      // log("Trade BOOK RESPONSE ::: ${res.body}");
      // log(res.statusCode.toString());

      final List<TradeBookModel> data = [];

      final json = jsonDecode(res.body);
      try {
        if (json['stat'] == 'Not_Ok') {
          final TradeBookModel ord =
              TradeBookModel.fromJson(json as Map<String, dynamic>);
          return [ord];
        } else {
          for (final item in json) {
            data.add(TradeBookModel.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        if (res.statusCode == 200) {
          for (final item in json) {
            data.add(TradeBookModel.fromJson(item as Map<String, dynamic>));
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderHistoryModel>> getOrderHistory(String orderNum) async {
    try {
      final uri = Uri.parse(apiLinks.orderHistory);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","norenordno":"$orderNum"}&jKey=${prefs.clientSession}''');
      // log("ORDER History RESPONSE ::: ${res.body}");

      final List<OrderHistoryModel> data = [];

      final json = jsonDecode(res.body);
      try {
        if (json['stat'] == 'Not_Ok') {
          final OrderHistoryModel ord =
              OrderHistoryModel.fromJson(json as Map<String, dynamic>);
          return [ord];
        } else {
          for (final item in json) {
            data.add(OrderHistoryModel.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        if (res.statusCode == 200) {
          for (final item in json) {
            data.add(OrderHistoryModel.fromJson(item as Map<String, dynamic>));
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<CancelOrderModel> getCancelOrder(String orderNo) async {
    try {
      final uri = Uri.parse(apiLinks.cancelOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","norenordno":"$orderNo","ordersource":"${ApiLinks.source}"}&jKey=${prefs.clientSession}''');

      // log("Cancel Order => ${res.body}");
      final json = jsonDecode(res.body);

      return CancelOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<CancelOrderModel> getExitSNOOrder(String orderNo, String prd) async {
    try {
      final uri = Uri.parse(apiLinks.exitSNOOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","norenordno":"$orderNo","prd":"$prd"}&jKey=${prefs.clientSession}''');

      // log("Exit SNO OrderModel => ${res.body}");
      final json = jsonDecode(res.body);

      return CancelOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderMarginModel> getOrderMargin(OrderMarginInput input) async {
    try {
      final uri = Uri.parse(apiLinks.orderMargin);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}","exch":"${input.exch}","tsym":"${input.tsym.contains("&") ? input.tsym.replaceAll("&", "%26") : input.tsym}","qty":"${input.qty}","prc":"${input.prc}","prd":"${input.prd}","trantype":"${input.trantype}","prctyp":"${input.prctyp}","rorgqty":"${input.rorgqty}","rorgprc":"${input.rorgprc}","blprc": "${input.blprc}","trgprc": "${input.trgprc}"}&jKey=${prefs.clientSession}''');

      // log("Order Margin => ${res.body}");
      final json = jsonDecode(res.body);

      return OrderMarginModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<GetBrokerageModel> getBrokerage(BrokerageInput input) async {
    try {
      final uri = Uri.parse(apiLinks.getBrokerage);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}","exch":"${input.exch}","tsym":"${input.tsym}","qty":"${input.qty}","prc":"${input.prc}","prd":"${input.prd}","trantype":"${input.trantype}" }&jKey=${prefs.clientSession}''');

      // log("Order Brokerage => ${res.body} ");
      final json = jsonDecode(res.body);

      return GetBrokerageModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceGttOrderModel> getCancelGTTorder(String cancelId) async {
    try {
      final uri = Uri.parse(apiLinks.cancelGTTOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","al_id":"$cancelId" }&jKey=${prefs.clientSession}''');

      // log("Cancel GTT => ${res.body} ");
      final json = jsonDecode(res.body);

      return PlaceGttOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ModifyOrderModel> getModifyOrder(ModifyOrderInput input) async {
    try {
      final uri = Uri.parse(apiLinks.mdifyOrder);
      Map payload = {
        "uid": prefs.clientId,
        "actid": prefs.clientId,
        "exch": input.exch,
        "tsym": input.tsym.contains("&")
            ? input.tsym.replaceAll("&", "%26")
            : input.tsym,
        "qty": input.qty.replaceAll("-", ""),
        "prc": input.prc,
        "norenordno": input.orderNum,
        "prctyp": input.prctyp,
        "ret": input.ret,
        "dscqty": input.dscqty,
        "ordersource": ApiLinks.source
      };
   
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');

      log("Modify order=> ${res.body}");
      final json = jsonDecode(res.body);

      return ModifyOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SipPlaceOrderModel> getPlaceSipOrder(
      SipInputField sipInputField) async {
    try {
      final uri = Uri.parse(apiLinks.placeSipOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "uid": prefs.clientId,
            "st": sipInputField.st,
            "ed": sipInputField.ed,
            "frequency": sipInputField.frequency,
            "sip_name": sipInputField.tsym,
            "scripts": [
              {
                "exch": sipInputField.exch,
                "tsym": sipInputField.tsym,
                "prd": sipInputField.prd,
                "token": sipInputField.token,
                "qty": sipInputField.qty
              }
            ],
            "session": prefs.clientSession
          }));

      // log("PlaceOrdersip => ${res.body}");
      final json = jsonDecode(res.body);

      return SipPlaceOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      log("PlaceOrdersip Error::$e");
      rethrow;
    }
  }

  Future<SipOrderBookModel> getSipOrderBook() async {
    try {
      final uri = Uri.parse(apiLinks.sipOrderBook);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      // log("SIP Order BOOK => ${jsonDecode(res.body)}");
      final json = jsonDecode(res.body);

      return SipOrderBookModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      log("RESPONCE SIP HISTORY $e");
      rethrow;
    }
  }

  Future<CancleSipOrder> getSipCancelOrder(String sipOrderno) async {
    try {
      final uri = Uri.parse(apiLinks.cancleSiporder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"SipId":"$sipOrderno"}&jKey=${prefs.clientSession}''');

      // log("Cancel SIP Order => ${res.body}");
      final json = jsonDecode(res.body);

      return CancleSipOrder.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      log("SIP CANCEL ERRROR LOG :: $e");
      rethrow;
    }
  }

  Future<PlaceGttOrderModel> getPlaceGTTOrder(PlaceGTTOrderInput input) async {
    try {
      final uri = Uri.parse(apiLinks.placeGTTOrder);
      Map payload = {
        "uid": prefs.clientId,
        "tsym": input.tsym,
        "exch": input.exch,
        "ai_t": input.ait,
        "validity": input.validity,
        "d": input.d,
        "trantype": input.trantype,
        "prctyp": input.prctyp,
        "prd": input.prd,
        "ret": input.ret,
        "actid": prefs.clientId,
        "qty": input.qty,
        "prc": input.prc
      };

      if (input.trgprc.isNotEmpty) {
        payload.addAll({"trgprc": input.trgprc});
      }
      if (input.remarks.isNotEmpty) {
        payload.addAll({"remarks": input.remarks});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');
      // log("Place GTT Order => ${res.body}");
      final json = jsonDecode(res.body);

      return PlaceGttOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceGttOrderModel> getModifyGTTOrder(PlaceGTTOrderInput input) async {
    try {
      final uri = Uri.parse(apiLinks.modifyGTTOrder);
      Map payload = {
        "uid": prefs.clientId,
        "tsym": input.tsym,
        "exch": input.exch,
        "ai_t": input.ait,
        "validity": input.validity,
        "d": input.d,
        "trantype": input.trantype,
        "prctyp": input.prctyp,
        "prd": input.prd,
        "ret": input.ret,
        "actid": prefs.clientId,
        "qty": input.qty,
        "prc": input.prc,
        "al_id": input.alid
      };

      if (input.trgprc.isNotEmpty) {
        payload.addAll({"trgprc": input.trgprc});
      }
      if (input.remarks.isNotEmpty) {
        payload.addAll({"remarks": input.remarks});
      }
      log("Modify GTT Order => $payload");
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');
      // log("Modify GTT Order => ${res.body}");
      final json = jsonDecode(res.body);

      return PlaceGttOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceGttOrderModel> getPlaceOcoOrder(PlaceOcoOrderInput input) async {
    try {
      final uri = Uri.parse(apiLinks.placeOCOOrder);
      Map payload = {
        "uid": prefs.clientId,
        "ai_t": "LMT_BOS_O",
        "validity": "GTT",
        "tsym": input.tsym,
        "exch": input.exch,
        "oivariable": [
          {"d": input.d1, "var_name": "x"},
          {"d": input.d2, "var_name": "y"}
        ],
        "place_order_params": {
          "tsym": input.tsym,
          "exch": input.exch,
          "trantype": input.trantype,
          "prctyp": input.prctyp1,
          "prd": input.prd1,
          "ret": "DAY",
          "actid": prefs.clientId,
          "uid": prefs.clientId,
          "ordersource": ApiLinks.source,
          "qty": input.qty1,
          "prc": input.prc1,
          "trgprc": input.trgprc1
        },
        "place_order_params_leg2": {
          "tsym": input.tsym,
          "exch": input.exch,
          "trantype": input.trantype,
          "prctyp": input.prctyp2,
          "prd": input.prd2,
          "ret": "DAY",
          "actid": prefs.clientId,
          "uid": prefs.clientId,
          "ordersource": ApiLinks.source,
          "qty": input.qty2,
          "prc": input.prc2,
          "trgprc": input.trgprc2,
        }
      };

      if (input.remarks.isNotEmpty) {
        payload.addAll({"remarks": input.remarks});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');
      // log("Place OCO Order => ${res.body}");
      final json = jsonDecode(res.body);

      return PlaceGttOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceGttOrderModel> getModifyOcoOrder(PlaceOcoOrderInput input) async {
    try {
      final uri = Uri.parse(apiLinks.modifyOCOOrder);
      Map payload = {
        "uid": prefs.clientId,
        "ai_t": "LMT_BOS_O",
        "validity": input.validity,
        "tsym": input.tsym,
        "exch": input.exch,
        "al_id": input.alid,
        "oivariable": [
          {"d": input.d1, "var_name": "x"},
          {"d": input.d2, "var_name": "y"}
        ],
        "place_order_params": {
          "tsym": input.tsym,
          "exch": input.exch,
          "trantype": input.trantype,
          "prctyp": input.prctyp1,
          "prd": input.prd1,
          "ret": "DAY",
          "actid": prefs.clientId,
          "uid": prefs.clientId,
          "ordersource": ApiLinks.source,
          "qty": input.qty1,
          "prc": input.prc1,
          "trgprc": input.trgprc1
        },
        "place_order_params_leg2": {
          "tsym": input.tsym,
          "exch": input.exch,
          "trantype": input.trantype,
          "prctyp": input.prctyp2,
          "prd": input.prd2,
          "ret": "DAY",
          "actid": prefs.clientId,
          "uid": prefs.clientId,
          "ordersource": ApiLinks.source,
          "qty": input.qty2,
          "prc": input.prc2,
          "trgprc": input.trgprc2,
        }
      };

      if (input.remarks.isNotEmpty) {
        payload.addAll({"remarks": input.remarks});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: '''jData=${jsonEncode(payload)}&jKey=${prefs.clientSession}''');
      // log("Place Modify OCO Order => ${res.body}");
      final json = jsonDecode(res.body);

      return PlaceGttOrderModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GttOrderBookModel>> getGTTOrderBook() async {
    try {
      final uri = Uri.parse(apiLinks.pendingGttorder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}" }&jKey=${prefs.clientSession}''');
      // log("GTT ORDER BOOK RESPONSE ::: ${res.body}");
      // log(res.statusCode.toString());

      final List<GttOrderBookModel> data = [];

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final GttOrderBookModel ord =
                GttOrderBookModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(
                  GttOrderBookModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(
                  GttOrderBookModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
