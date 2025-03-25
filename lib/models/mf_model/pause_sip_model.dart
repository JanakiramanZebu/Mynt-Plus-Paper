class pause_spi_res {
  String? bseremarks;
  String? msg;
  String? sipRegisterNumber;
  String? stat;

  pause_spi_res({this.bseremarks, this.msg, this.sipRegisterNumber, this.stat});

  pause_spi_res.fromJson(Map<String, dynamic> json) {
    bseremarks = json['bseremarks'];
    msg = json['msg'];
    sipRegisterNumber = json['sip_register_number'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bseremarks'] = this.bseremarks;
    data['msg'] = this.msg;
    data['sip_register_number'] = this.sipRegisterNumber;
    data['stat'] = this.stat;
    return data;
  }
}
