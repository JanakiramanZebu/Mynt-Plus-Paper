 
import '../models/notification_model/broker_message_model.dart';
import '../models/notification_model/exchange_message_model.dart';
import '../models/notification_model/exchange_status_model.dart';
import 'core/api_core.dart'; 


mixin NotificationApi on ApiCore {
  Future<List<ExchangeMessageModel>> getexchmsg() async {
    try {
      final uri = Uri.parse(apiLinks.exchMsg);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');


      //log("Exchange message=>${res.body} ");
      final List<ExchangeMessageModel> data = [];
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final ExchangeMessageModel ord =
                ExchangeMessageModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(
                  ExchangeMessageModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(
                  ExchangeMessageModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }


  Future<List<ExchangeStatusModel>> getexchstatus() async {
    try {
      final uri = Uri.parse(apiLinks.exchStatus);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');


      final List<ExchangeStatusModel> data = [];
      //log("Exchange Status=>${res.body} ");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final ExchangeStatusModel ord =
                ExchangeStatusModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(
                  ExchangeStatusModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(
                  ExchangeStatusModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }


  Future<List<BrokerMessage>> getbrokermsg() async {
    try {
      final uri = Uri.parse(apiLinks.brokermsg);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');


      final List<BrokerMessage> data = [];
     // log("broker msg=>${res.body} ");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final BrokerMessage ord =
                BrokerMessage.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(BrokerMessage.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(BrokerMessage.fromJson(item as Map<String, dynamic>));
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





