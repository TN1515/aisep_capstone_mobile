import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/utils/datetime_utils.dart';

enum EvaluationStatus {
  queued,
  processing,
  partial_completed,
  retry,
  completed,
  failed,
}

enum DocumentSourceType {
  pitchDeck,
  businessPlan,
}

extension DocumentSourceTypeExtension on DocumentSourceType {
  String get apiKey {
    switch (this) {
      case DocumentSourceType.pitchDeck: return 'pitch_deck';
      case DocumentSourceType.businessPlan: return 'business_plan';
    }
  }

  String get label {
    switch (this) {
      case DocumentSourceType.pitchDeck: return 'Pitch Deck';
      case DocumentSourceType.businessPlan: return 'Business Plan';
    }
  }
}

extension EvaluationStatusExtension on EvaluationStatus {
  String get label {
    switch (this) {
      case EvaluationStatus.queued: return 'Đang chờ';
      case EvaluationStatus.processing: return 'Đang xử lý';
      case EvaluationStatus.partial_completed: return 'Hoàn thành một phần';
      case EvaluationStatus.retry: return 'Đang thử lại';
      case EvaluationStatus.completed: return 'Hoàn thành';
      case EvaluationStatus.failed: return 'Thất bại';
    }
  }

  Color get color {
    switch (this) {
      case EvaluationStatus.queued: return Colors.orange;
      case EvaluationStatus.processing: return Colors.blue;
      case EvaluationStatus.partial_completed: return Colors.cyan;
      case EvaluationStatus.retry: return Colors.amber;
      case EvaluationStatus.completed: return Colors.green;
      case EvaluationStatus.failed: return Colors.red;
    }
  }
}

class EvaluationStatusResult {
  final int runId;
  final int startupId;
  final EvaluationStatus status;
  final double? overallScore;
  final String? failureReason;
  final bool isReportReady;
  final bool isReportValid;
  final DateTime submittedAt;
  final DateTime updatedAt;

  EvaluationStatusResult({
    required this.runId,
    required this.startupId,
    required this.status,
    this.overallScore,
    this.failureReason,
    this.isReportReady = false,
    this.isReportValid = false,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory EvaluationStatusResult.fromJson(Map<String, dynamic> json) {
    // Helper to get value regardless of casing (runId or RunId)
    T? getValue<T>(String key) {
      return (json[key] ?? json[key[0].toUpperCase() + key.substring(1)]) as T?;
    }

    return EvaluationStatusResult(
      runId: int.tryParse(getValue<dynamic>('runId')?.toString() ?? '0') ?? 0,
      startupId: int.tryParse(getValue<dynamic>('startupId')?.toString() ?? '0') ?? 0,
      status: _parseStatus(getValue<dynamic>('status')),
      overallScore: double.tryParse(getValue<dynamic>('overallScore')?.toString() ?? ''),
      failureReason: getValue<dynamic>('failureReason')?.toString(),
      isReportReady: getValue<dynamic>('isReportReady') == true,
      isReportValid: getValue<dynamic>('isReportValid') == true,
      submittedAt: DateTimeUtils.parseApiDate(getValue<dynamic>('submittedAt')),
      updatedAt: DateTimeUtils.parseApiDate(getValue<dynamic>('updatedAt')),
    );
  }

  static EvaluationStatus _parseStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'queued': return EvaluationStatus.queued;
      case 'processing': return EvaluationStatus.processing;
      case 'partial_completed': return EvaluationStatus.partial_completed;
      case 'retry': return EvaluationStatus.retry;
      case 'completed': return EvaluationStatus.completed;
      case 'failed': return EvaluationStatus.failed;
      default: return EvaluationStatus.queued;
    }
  }
}

class SubmitEvaluationRequest {
  final int startupId;
  final List<int>? documentIds;

  SubmitEvaluationRequest({
    required this.startupId,
    this.documentIds,
  });

  Map<String, dynamic> toJson() => {
    'startupId': startupId,
    if (documentIds != null) 'documentIds': documentIds,
  };
}

class EvaluationSubmitResult {
  final int runId;
  final int startupId;
  final EvaluationStatus status;
  final String? message;

  EvaluationSubmitResult({
    required this.runId,
    required this.startupId,
    required this.status,
    this.message,
  });

  factory EvaluationSubmitResult.fromJson(Map<String, dynamic> json) {
    dynamic getValue(String key) {
      return (json[key] ?? json[key[0].toUpperCase() + key.substring(1)]);
    }

    return EvaluationSubmitResult(
      runId: int.tryParse(getValue('runId')?.toString() ?? '0') ?? 0,
      startupId: int.tryParse(getValue('startupId')?.toString() ?? '0') ?? 0,
      status: EvaluationStatusResult._parseStatus(getValue('status')),
      message: getValue('message')?.toString(),
    );
  }
}

class EvaluationReportResult {
  final int runId;
  final EvaluationStatus status;
  final bool isReportValid;
  final OverallResult overallResult;
  final List<CriteriaResult> criteriaResults;
  final Classification classification;
  final Narrative narrative;
  final String? validationMessage;

  EvaluationReportResult({
    required this.runId,
    required this.status,
    required this.isReportValid,
    required this.overallResult,
    required this.criteriaResults,
    required this.classification,
    required this.narrative,
    this.validationMessage,
  });

  factory EvaluationReportResult.fromJson(Map<String, dynamic> json) {
    dynamic getValue(String key) {
      return (json[key] ?? json[key[0].toUpperCase() + key.substring(1)]);
    }

    final reportData = getValue('report') as Map<String, dynamic>? ?? {};
    return EvaluationReportResult(
      runId: int.tryParse(getValue('runId')?.toString() ?? '0') ?? 0,
      status: EvaluationStatusResult._parseStatus(getValue('status')),
      isReportValid: getValue('isReportValid') == true,
      overallResult: OverallResult.fromJson(reportData['overall_result'] ?? {}),
      criteriaResults: (reportData['criteria_results'] as List? ?? [])
          .map((e) => CriteriaResult.fromJson(e))
          .toList(),
      classification: Classification.fromJson(reportData['classification'] ?? {}),
      narrative: Narrative.fromJson(reportData['narrative'] ?? {}),
      validationMessage: getValue('validationMessage')?.toString(),
    );
  }
}

class Classification {
  final String industry;
  final String stage;
  final List<String> businessModel;

  Classification({
    required this.industry,
    required this.stage,
    required this.businessModel,
  });

  factory Classification.fromJson(Map<String, dynamic> json) {
    return Classification(
      industry: json['industry']?.toString() ?? 'N/A',
      stage: json['stage']?.toString() ?? 'N/A',
      businessModel: List<String>.from(json['business_model'] ?? json['businessModel'] ?? []),
    );
  }
}

class OverallResult {
  final double score;
  final double confidence;
  final String potentialLevel;

  OverallResult({
    required this.score,
    required this.confidence,
    required this.potentialLevel,
  });

  factory OverallResult.fromJson(Map<String, dynamic> json) {
    // Helper to get value matching multiple possible keys
    dynamic getVal(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) return json[key];
        // Check PascalCase too
        String pascal = key[0].toUpperCase() + key.substring(1);
        if (json.containsKey(pascal)) return json[pascal];
      }
      return null;
    }

    return OverallResult(
      score: double.tryParse(getVal(['overall_score', 'score'])?.toString() ?? '0.0') ?? 0.0,
      confidence: double.tryParse(getVal(['overall_confidence', 'confidence'])?.toString() ?? '0.0') ?? 0.0,
      potentialLevel: getVal(['interpretation_band', 'potential_level', 'potentialLevel'])?.toString() ?? 'N/A',
    );
  }
}

class CriteriaResult {
  final String criteriaName;
  final double score;
  final String explanation;
  final List<int> evidenceLocations;

  CriteriaResult({
    required this.criteriaName,
    required this.score,
    required this.explanation,
    required this.evidenceLocations,
  });

  factory CriteriaResult.fromJson(Map<String, dynamic> json) {
    dynamic getVal(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) return json[key];
        String pascal = key[0].toUpperCase() + key.substring(1);
        if (json.containsKey(pascal)) return json[pascal];
      }
      return null;
    }

    return CriteriaResult(
      criteriaName: getVal(['name', 'criterion', 'criteriaName'])?.toString() ?? 'Unknown',
      score: double.tryParse(getVal(['score', 'final_score'])?.toString() ?? '0.0') ?? 0.0,
      explanation: getVal(['narrative', 'explanation', 'description'])?.toString() ?? '',
      evidenceLocations: (getVal(['evidence_locations']) as List? ?? [])
          .map((e) => int.tryParse(e is Map ? e['slide_number_or_page_number']?.toString() ?? '' : e.toString()) ?? 0)
          .where((e) => e != 0)
          .toList(),
    );
  }
}

class Narrative {
  final List<String> topStrengths;
  final List<String> topConcerns;
  final List<String> recommendations;
  final String summary;

  Narrative({
    required this.topStrengths,
    required this.topConcerns,
    required this.recommendations,
    required this.summary,
  });

  factory Narrative.fromJson(Map<String, dynamic> json) {
    return Narrative(
      topStrengths: List<String>.from((json['top_strengths'] ?? json['topStrengths']) ?? []),
      topConcerns: List<String>.from((json['top_concerns'] ?? json['topConcerns']) ?? []),
      recommendations: ( (json['recommendations'] ?? json['improvement_recommendations']) as List? ?? [])
          .map((e) => e is Map ? e['recommendation']?.toString() ?? '' : e.toString())
          .toList(),
      summary: (json['summary'] ?? json['overall_summary'])?.toString() ?? '',
    );
  }
}


