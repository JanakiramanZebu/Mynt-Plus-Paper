class AllholdModel {
  final dynamic equities;  // Can be a Map<String, dynamic> or String
  final dynamic mutualfunds;  // Can be a Map<String, dynamic> or String
  final String syncDatetime;

  // Constructor to initialize AllholdModel
  AllholdModel({
    required this.equities,
    required this.mutualfunds,
    required this.syncDatetime,
  });

  // Factory constructor to create an instance from JSON
  factory AllholdModel.fromJson(Map<String, dynamic> json) {
    return AllholdModel(
      equities: json['equities'] ?? {},  // Handling default value
      mutualfunds: json['mutualfunds'] ?? {},  // Handling default value
      syncDatetime: json['sync_datetime'] ?? '',  // Default empty string if missing
    );
  }

  // Method to convert AllholdModel instance to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'equities': equities,
      'mutualfunds': mutualfunds,
      'sync_datetime': syncDatetime,
    };
  }

  // Getter to check if the model contains any data
  bool get isNotEmpty =>
      (equities is String ? equities.isNotEmpty : equities.isNotEmpty) ||
      (mutualfunds is String ? mutualfunds.isNotEmpty : mutualfunds.isNotEmpty);
}
