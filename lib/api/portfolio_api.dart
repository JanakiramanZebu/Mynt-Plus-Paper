import 'dart:developer';

import '../models/portfolio_model/holdings_model.dart';
import '../models/portfolio_model/mf_holdings_model.dart';
import '../models/portfolio_model/mf_quotes.dart';
import '../models/portfolio_model/position_book_model.dart';
import '../models/portfolio_model/position_convertion_model.dart';
import '../models/portfolio_model/position_group_model.dart';
import 'core/api_core.dart';
import 'core/api_link.dart';

mixin PortfolioAPI on ApiCore {
  Future<List<HoldingsModel>> getHolding() async {
    try {
      final uri = Uri.parse(apiLinks.getHoldings);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}","prd":"C"}&jKey=${prefs.clientSession}''');
      // log("Holdings res=>${res.body} ");
      final List<HoldingsModel> data = [];
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final HoldingsModel ord =
                HoldingsModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(HoldingsModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(HoldingsModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MFHoldingsModel>> getMFHolding() async {
    try {
      final uri = Uri.parse(apiLinks.getMFHoldings);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}","prd":"C"}&jKey=${prefs.clientSession}''');
      // log("MF Holdings res=>${res.body} ");
      final List<MFHoldingsModel> data = [];
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final MFHoldingsModel ord =
                MFHoldingsModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(MFHoldingsModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(MFHoldingsModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<MFQuotes> getMFQutoes(String exch, String token) async {
    try {
      final uri = Uri.parse(apiLinks.getQuotesMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: '''jData={"uid":"${prefs.clientId}",
          "exch":"$exch","token":"$token"}&jKey=${prefs.clientSession}''');

      // log("MF Quotes => ${res.body}");
      final json = jsonDecode(res.body);

      return MFQuotes.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PositionBookModel>> getPositionBook() async {
    try {
      final uri = Uri.parse(apiLinks.getPosition);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
        // log("PositionBook => ${res.body}");

      final List<PositionBookModel> data = [];

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final PositionBookModel ord =
                PositionBookModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(
                  PositionBookModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(
                  PositionBookModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<PositionConvertionModel> getPositionConvertion(
      PositionConvertionInput positionConvertionInput) async {
    try {
      final uri = Uri.parse(apiLinks.positionConvert);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: '''jData={"uid":"${prefs.clientId}",
              "actid":"${prefs.clientId}",
              "exch":"${positionConvertionInput.exch}",
              "tsym":"${positionConvertionInput.tsym}",
              "qty":"${positionConvertionInput.qty}",
              "prd":"${positionConvertionInput.prd}",
              "prevprd":"${positionConvertionInput.prevprd}",
              "trantype":"${positionConvertionInput.trantype}",
              "postype":"${positionConvertionInput.postype}",
              "ordersource":"${ApiLinks.source}"}&jKey=${prefs.clientSession}''');

      // log("Position Convertion => ${res.body}");
      final json = jsonDecode(res.body);

      return PositionConvertionModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GetGroupSymbol>> getGroupPosition() async {
    try {
      final uri =
          Uri.parse("${apiLinks.positionGrp}?clientid=${prefs.clientId}");
      final res = await apiClient.get(uri, headers: defaultHeaders);

      log("Position Group List => ${res.body}");
      final json = jsonDecode(res.body);
      final List<GetGroupSymbol> data = [];

      for (final item in json) {
        data.add(GetGroupSymbol.fromJson(item as Map<String, dynamic>));
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateGroupName> createGroupName(String name) async {
    try {
      final uri = Uri.parse(apiLinks.creatGrpName);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"clientid": "${prefs.clientId}", "posname": name}));

      log("Position Group Name => ${res.body}");
      final json = jsonDecode(res.body);

      return CreateGroupName.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateGroupName> addGroupNameSymbol(String name, Map data) async {
    try {
      final uri = Uri.parse(apiLinks.addSymbolGrp);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "clientid": "${prefs.clientId}",
            "posname": name,
            "symdata": data
          }));

      log("Add symbol Group Name => ${res.body}");
      final json = jsonDecode(res.body);

      return CreateGroupName.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateGroupName> deletePositionGrpName(String name) async {
    try {
      final uri = Uri.parse(
          "${apiLinks.delpositiongrpName}?clientid=${prefs.clientId}&posname=$name");
      final res = await apiClient.get(uri, headers: defaultHeaders);

      log("Delete vPosition Group  Name => ${res.body}");
      final json = jsonDecode(res.body);

      return CreateGroupName.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateGroupName> deletePositionGrpSym(
      String grpName, String tsym) async {
    try {
      final uri = Uri.parse(apiLinks.delpositiongrpSym);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "clientid": "${prefs.clientId}",
            "posname": grpName,
            "tsym": tsym
          }));

      log("Delete Position Group Symbol => ${res.body}");
      final json = jsonDecode(res.body);

      return CreateGroupName.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
// "symbol removed"