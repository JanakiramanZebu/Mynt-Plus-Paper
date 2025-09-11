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
        pendingRemovedList!.add(new PendingRemovedList.fromJson(v));
      });
    }
    if (json['completed'] != null) {
      completed = <Completed>[];
      json['completed'].forEach((v) {
        completed!.add(new Completed.fromJson(v));
      });
    }
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    if (this.pendingRemovedList != null) {
      data['pending_removed_list'] =
          this.pendingRemovedList!.map((v) => v.toJson()).toList();
    }
    if (this.completed != null) {
      data['completed'] = this.completed!.map((v) => v.toJson()).toList();
    }
    data['coin'] = this.coin;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientcode'] = this.clientcode;
    data['mobile'] = this.mobile;
    data['initiated_dt'] = this.initiatedDt;
    data['app_status'] = this.appStatus;
    data['stage'] = this.stage;
    return data;
  }
}

class Completed {
  String? clientcode;
  String? mobile;
  String? activateDt;
  Null? appStatus;

  Completed({this.clientcode, this.mobile, this.activateDt, this.appStatus});

  Completed.fromJson(Map<String, dynamic> json) {
    clientcode = json['clientcode'];
    mobile = json['mobile'];
    activateDt = json['activate_dt'];
    appStatus = json['app_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientcode'] = this.clientcode;
    data['mobile'] = this.mobile;
    data['activate_dt'] = this.activateDt;
    data['app_status'] = this.appStatus;
    return data;
  }
}
