class AiEvaluationModel {
  final String id;
  final String documentId;
  final String documentName;
  final double overallScore;
  final DateTime evaluationDate;
  final String summary;
  final Map<String, double> metrics; // e.g., {'Market': 8.5, 'Product': 9.0}
  final List<String> strengths;
  final List<String> weaknesses;
  final String fullReportUrl;

  AiEvaluationModel({
    required this.id,
    required this.documentId,
    required this.documentName,
    required this.overallScore,
    required this.evaluationDate,
    required this.summary,
    required this.metrics,
    required this.strengths,
    required this.weaknesses,
    required this.fullReportUrl,
  });
}
