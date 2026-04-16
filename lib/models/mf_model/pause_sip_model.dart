class pause_spi_res {
  String? registrationNumber;
  String? bseRemarks;
  String? statusFlag;
  String? filler;
  String? stat;
  String? status;

  pause_spi_res(
      {this.registrationNumber,
      this.bseRemarks,
      this.statusFlag,
      this.filler,
      this.stat,
      this.status});

  pause_spi_res.fromJson(Map<String, dynamic> json) {
    registrationNumber = json['RegistrationNumber'];
    bseRemarks = json['BseRemarks'];
    statusFlag = json['StatusFlag'];
    filler = json['filler'];
    stat = json['stat'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RegistrationNumber'] = registrationNumber;
    data['BseRemarks'] = bseRemarks;
    data['StatusFlag'] = statusFlag;
    data['filler'] = filler;
    data['stat'] = stat;
    data['status'] = status;
    return data;
  }
}
