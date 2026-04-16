class EodChartData {
  final String time;
  final double into;  // open
  final double inth;  // high
  final double intl;  // low
  final double intc;  // close
  final int ssboe;    // epoch timestamp
  final double intv;  // volume

  EodChartData({
    required this.time,
    required this.into,
    required this.inth,
    required this.intl,
    required this.intc,
    required this.ssboe,
    required this.intv,
  });

  factory EodChartData.fromJson(Map<String, dynamic> json) {
    return EodChartData(
      time: json['time'],
      into: double.parse(json['into']),
      inth: double.parse(json['inth']),
      intl: double.parse(json['intl']),
      intc: double.parse(json['intc']),
      ssboe: int.parse(json['ssboe']),
      intv: double.parse(json['intv']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'into': into.toString(),
      'inth': inth.toString(),
      'intl': intl.toString(),
      'intc': intc.toString(),
      'ssboe': ssboe.toString(),
      'intv': intv.toString(),
    };
  }
}