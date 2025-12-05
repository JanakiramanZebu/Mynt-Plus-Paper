class CreateAlgoStrategyRequestModel {
  final String algorithmName;
  final String submittedBy;
  final String type;
  final String category;
  final String riskLevel;
  final String description;
  final String logicDescription;
  final String? codeLang;

  CreateAlgoStrategyRequestModel({
    required this.algorithmName,
    required this.submittedBy,
    required this.type,
    required this.category,
    required this.riskLevel,
    required this.description,
    required this.logicDescription,
    this.codeLang,
  });

  Map<String, dynamic> toJson() {
    return {
      'algorithm_name': algorithmName,
      'submitted_by': submittedBy,
      'type': type,
      'category': category,
      'risk_level': riskLevel,
      'description': description,
      'logic_description': logicDescription,
      'code_lang': codeLang,
    };
  }
}

