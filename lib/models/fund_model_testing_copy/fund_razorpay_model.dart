class Razorpay {
  int? amount;
  int? amountDue;
  int? amountPaid;
  int? attempts;
  int? createdAt;
  String? currency;
  String? entity;
  String? id;
  List<Null>? notes;
  Null offerId;
  String? receipt;
  String? status;

  Razorpay(
      {this.amount,
      this.amountDue,
      this.amountPaid,
      this.attempts,
      this.createdAt,
      this.currency,
      this.entity,
      this.id,
      this.notes,
      this.offerId,
      this.receipt,
      this.status});

  Razorpay.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    amountDue = json['amount_due'];
    amountPaid = json['amount_paid'];
    attempts = json['attempts'];
    createdAt = json['created_at'];
    currency = json['currency'];
    entity = json['entity'];
    id = json['id'];
    if (json['notes'] != null) {
      notes = <Null>[];
      json['notes'].forEach((v) {
        notes!.add((v));
      });
    }
    offerId = json['offer_id'];
    receipt = json['receipt'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['amount_due'] = amountDue;
    data['amount_paid'] = amountPaid;
    data['attempts'] = attempts;
    data['created_at'] = createdAt;
    data['currency'] = currency;
    data['entity'] = entity;
    data['id'] = id;
    if (notes != null) {
      data['notes'] = notes!.map((v) => (v)).toList();
    }
    data['offer_id'] = offerId;
    data['receipt'] = receipt;
    data['status'] = status;
    return data;
  }
}
