class ClientHistoryResponse {
  final List<ClientHistoryItem>? data;

  ClientHistoryResponse({this.data});

  factory ClientHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ClientHistoryResponse(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ClientHistoryItem.fromJson(e))
              .toList()
          : null,
    );
  }
}

class ClientHistoryItem {
  final String? amount;
  final String? bankifsc;
  final String? clientid;
  final String? dateTime;
  final String? orderNumber;
  final String? status;
  final String? statusDescription;
  final String? transtype;
  final String? vendor;

  ClientHistoryItem({
    this.amount,
    this.bankifsc,
    this.clientid,
    this.dateTime,
    this.orderNumber,
    this.status,
    this.statusDescription,
    this.transtype,
    this.vendor,
  });

  factory ClientHistoryItem.fromJson(Map<String, dynamic> json) {
    return ClientHistoryItem(
      amount: json['amount'],
      bankifsc: json['bankifsc'],
      clientid: json['clientid'],
      dateTime: json['date_time'],
      orderNumber: json['orderNumber'],
      status: json['status'],
      statusDescription: json['status_description'],
      transtype: json['transtype'],
      vendor: json['vendor'],
    );
  }
}
