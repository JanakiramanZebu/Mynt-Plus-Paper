class GlobalIndicesModel {
  String? s2yearsPerChange;
  String? s3monthsPerChange;
  String? s3yearsPerChange;
  String? s52wkHigh;
  String? s52wkLow;
  String? s5yearsPerChange;
  String? s6monthsPerChange;
  String? market;
  String? flagUrl;
  String? high;
  int? index;
  String? lastUpdated;
  String? low;
  String? monthlyPerChange;
  String? name;
  String? netChange;
  String? open;
  String? percentChange;
  String? prevClose;
  String? price;
  String? state;
  String? symbol;
  String? technicalRating;
  String? weeklyPerChange;
  String? yearlyPerChange;
  String? ytdPerChange;

  GlobalIndicesModel(
      {this.s2yearsPerChange,
      this.s3monthsPerChange,
      this.s3yearsPerChange,
      this.s52wkHigh,
      this.s52wkLow,
      this.s5yearsPerChange,
      this.s6monthsPerChange,
      this.market,
      this.flagUrl,
      this.high,
      this.index,
      this.lastUpdated,
      this.low,
      this.monthlyPerChange,
      this.name,
      this.netChange,
      this.open,
      this.percentChange,
      this.prevClose,
      this.price,
      this.state,
      this.symbol,
      this.technicalRating,
      this.weeklyPerChange,
      this.yearlyPerChange,
      this.ytdPerChange});

  GlobalIndicesModel.fromJson(Map<String, dynamic> json) {
    s2yearsPerChange = json['2years_per_change'];
    s3monthsPerChange = json['3months_per_change'];
    s3yearsPerChange = json['3years_per_change'];
    s52wkHigh = json['52wkHigh'];
    s52wkLow = json['52wkLow'];
    s5yearsPerChange = json['5years_per_change'];
    s6monthsPerChange = json['6months_per_change'];
    market = json['Market'];
    flagUrl = json['flag_url'];
    high = json['high'];
    index = json['index'];
    lastUpdated = json['last_updated'];
    low = json['low'];
    monthlyPerChange = json['monthly_per_change'];
    name = json['name'];
    netChange = json['net_change'];
    open = json['open'];
    percentChange = json['percent_change'];
    prevClose = json['prev_close'];
    price = json['price'];
    state = json['state'];
    symbol = json['symbol'];
    technicalRating = json['technical_rating'];
    weeklyPerChange = json['weekly_per_change'];
    yearlyPerChange = json['yearly_per_change'];
    ytdPerChange = json['ytd_per_change'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['2years_per_change'] = s2yearsPerChange;
    data['3months_per_change'] = s3monthsPerChange;
    data['3years_per_change'] = s3yearsPerChange;
    data['52wkHigh'] = s52wkHigh;
    data['52wkLow'] = s52wkLow;
    data['5years_per_change'] = s5yearsPerChange;
    data['6months_per_change'] = s6monthsPerChange;
    data['Market'] = market;
    data['flag_url'] = flagUrl;
    data['high'] = high;
    data['index'] = index;
    data['last_updated'] = lastUpdated;
    data['low'] = low;
    data['monthly_per_change'] = monthlyPerChange;
    data['name'] = name;
    data['net_change'] = netChange;
    data['open'] = open;
    data['percent_change'] = percentChange;
    data['prev_close'] = prevClose;
    data['price'] = price;
    data['state'] = state;
    data['symbol'] = symbol;
    data['technical_rating'] = technicalRating;
    data['weekly_per_change'] = weeklyPerChange;
    data['yearly_per_change'] = yearlyPerChange;
    data['ytd_per_change'] = ytdPerChange;
    return data;
  }
}
