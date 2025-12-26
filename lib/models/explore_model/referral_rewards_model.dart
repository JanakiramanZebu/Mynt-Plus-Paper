class ReferralRewards {
  String? msg;
  List<PendingRemovedList>? pendingRemovedList;
  List<Completed>? completed;
  int? coin;

  ReferralRewards(
      {this.msg, this.pendingRemovedList, this.completed, this.coin});

  ReferralRewards.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['pending_removed_list'] != null) {
      pendingRemovedList = <PendingRemovedList>[];
      json['pending_removed_list'].forEach((v) {
        pendingRemovedList!.add(PendingRemovedList.fromJson(v));
      });
    }
    if (json['completed'] != null) {
      completed = <Completed>[];
      json['completed'].forEach((v) {
        completed!.add(Completed.fromJson(v));
      });
    }
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (pendingRemovedList != null) {
      data['pending_removed_list'] =
          pendingRemovedList!.map((v) => v.toJson()).toList();
    }
    if (completed != null) {
      data['completed'] = completed!.map((v) => v.toJson()).toList();
    }
    data['coin'] = coin;
    return data;
  }
}

class PendingRemovedList {
  String? clientcode;
  String? mobile;
  String? initiatedDt;
  String? appStatus;
  String? stage;

  PendingRemovedList(
      {this.clientcode,
      this.mobile,
      this.initiatedDt,
      this.appStatus,
      this.stage});

  PendingRemovedList.fromJson(Map<String, dynamic> json) {
    clientcode = json['clientcode'];
    mobile = json['mobile'];
    initiatedDt = json['initiated_dt'];
    appStatus = json['app_status'];
    stage = json['stage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientcode'] = clientcode;
    data['mobile'] = mobile;
    data['initiated_dt'] = initiatedDt;
    data['app_status'] = appStatus;
    data['stage'] = stage;
    return data;
  }
}

class Completed {
  String? clientcode;
  String? mobile;
  String? activateDt;
  Null appStatus;

  Completed({this.clientcode, this.mobile, this.activateDt, this.appStatus});

  Completed.fromJson(Map<String, dynamic> json) {
    clientcode = json['clientcode'];
    mobile = json['mobile'];
    activateDt = json['activate_dt'];
    appStatus = json['app_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientcode'] = clientcode;
    data['mobile'] = mobile;
    data['activate_dt'] = activateDt;
    data['app_status'] = appStatus;
    return data;
  }
}
