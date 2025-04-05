class PdfDownloadModel {
  List<Data>? data;

  PdfDownloadModel({this.data});

  PdfDownloadModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? docDate;
  String? docFileName;
  String? docType;
  String? generateDate;
  String? recno;

  Data(
      {this.docDate,
      this.docFileName,
      this.docType,
      this.generateDate,
      this.recno});

  Data.fromJson(Map<String, dynamic> json) {
    docDate = json['DocDate'];
    docFileName = json['DocFileName'];
    docType = json['DocType'];
    generateDate = json['GenerateDate'];
    recno = json['recno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['DocDate'] = this.docDate;
    data['DocFileName'] = this.docFileName;
    data['DocType'] = this.docType;
    data['GenerateDate'] = this.generateDate;
    data['recno'] = this.recno;
    return data;
  }
}