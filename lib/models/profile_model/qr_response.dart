class QrResponces {
  String? uniqueId;
  String? device;
  String? os;
  String? browser;
  String? ip;
  String? city;
  String? region;
  String? country;
  String? location;
  String? organization;
  String? postal;
  String? timezone;

  QrResponces(
      {this.uniqueId,
      this.device,
      this.os,
      this.browser,
      this.ip,
      this.city,
      this.region,
      this.country,
      this.location,
      this.organization,
      this.postal,
      this.timezone});

  QrResponces.fromJson(Map<String, dynamic> json) {
    uniqueId = json['unique_id'];
    device = json['Device'];
    os = json['os'];
    browser = json['Browser'];
    ip = json['ip'];
    city = json['City'];
    region = json['Region'];
    country = json['Country'];
    location = json['Location'];
    organization = json['Organization'];
    postal = json['Postal'];
    timezone = json['Timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unique_id'] = uniqueId;
    data['Device'] = device;
    data['os'] = os;
    data['Browser'] = browser;
    data['ip'] = ip;
    data['City'] = city;
    data['Region'] = region;
    data['Country'] = country;
    data['Location'] = location;
    data['Organization'] = organization;
    data['Postal'] = postal;
    data['Timezone'] = timezone;
    return data;
  }
}
