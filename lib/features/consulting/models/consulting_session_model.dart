import 'advisor_model.dart';

enum ConsultingStatus {
  requested,
  proposed,
  confirmed,
  payable,
  paid,
  conducted,
  completed,
  cancelled,
  failed,
}

enum ConsultingMode { online, offline, chat }

class ConsultingSessionModel {
  final String id;
  final String advisorId;
  final AdvisorModel? advisor;
  final String objective;
  final String scope;
  final ConsultingMode mode;
  final ConsultingStatus status;
  final DateTime? scheduledAt;
  final DateTime requestedAt;
  final double amount;
  final String? txHash;
  final String? reportUrl;
  final List<String>? reportCards; // New: Structure Card content
  final double? feedbackRating;
  final String? feedbackComment;
  final DateTime? completedAt; // New: Completion timestamp

  const ConsultingSessionModel({
    required this.id,
    required this.advisorId,
    this.advisor,
    required this.objective,
    required this.scope,
    this.mode = ConsultingMode.online,
    this.status = ConsultingStatus.requested,
    this.scheduledAt,
    required this.requestedAt,
    required this.amount,
    this.txHash,
    this.reportUrl,
    this.reportCards,
    this.feedbackRating,
    this.feedbackComment,
    this.completedAt,
  });

  ConsultingSessionModel copyWith({
    AdvisorModel? advisor,
    ConsultingStatus? status,
    DateTime? scheduledAt,
    String? txHash,
    String? reportUrl,
    List<String>? reportCards,
    double? feedbackRating,
    String? feedbackComment,
    DateTime? completedAt,
  }) {
    return ConsultingSessionModel(
      id: id,
      advisorId: advisorId,
      advisor: advisor ?? this.advisor,
      objective: objective,
      scope: scope,
      mode: mode,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      requestedAt: requestedAt,
      amount: amount,
      txHash: txHash ?? this.txHash,
      reportUrl: reportUrl ?? this.reportUrl,
      reportCards: reportCards ?? this.reportCards,
      feedbackRating: feedbackRating ?? this.feedbackRating,
      feedbackComment: feedbackComment ?? this.feedbackComment,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
