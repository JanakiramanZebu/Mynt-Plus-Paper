class AlgoStrategyModel {
  final String algorithmName;
  final String submittedBy;
  final String submissionDate;
  final String type;
  final String category;
  final String description;
  final String submissionId;
  final String status;
  final String reason;
  final String algoId;
  final String logicDescription;
  final String riskLevel;
  final String filePath;

  AlgoStrategyModel({
    required this.algorithmName,
    required this.submittedBy,
    required this.submissionDate,
    required this.type,
    required this.category,
    required this.description,
    required this.submissionId,
    required this.status,
    required this.reason,
    required this.algoId,
    required this.logicDescription,
    required this.riskLevel,
    required this.filePath,
  });

  factory AlgoStrategyModel.fromJson(Map<String, dynamic> json) {
    return AlgoStrategyModel(
      algorithmName: json['algorithm_name'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      submissionDate: json['submission_date'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      submissionId: json['submission_id'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      algoId: json['algo_id'] ?? '',
      logicDescription: json['logic_description'] ?? '',
      riskLevel: json['risk_level'] ?? '',
      filePath: json['file_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'algorithm_name': algorithmName,
      'submitted_by': submittedBy,
      'submission_date': submissionDate,
      'type': type,
      'category': category,
      'description': description,
      'submission_id': submissionId,
      'status': status,
      'reason': reason,
      'algo_id': algoId,
      'logic_description': logicDescription,
      'risk_level': riskLevel,
      'file_path': filePath,
    };
  }

  @override
  String toString() {
    return 'AlgoStrategyModel{algorithmName: $algorithmName, submittedBy: $submittedBy, submissionDate: $submissionDate, type: $type, category: $category, description: $description, submissionId: $submissionId, status: $status, reason: $reason, algoId: $algoId, logicDescription: $logicDescription, riskLevel: $riskLevel, filePath: $filePath}';
  }
}
