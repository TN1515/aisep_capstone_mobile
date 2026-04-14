import 'advisor_model.dart';

enum MentorshipStatus {
  requested(0),
  rejected(1),
  accepted(2),
  inProgress(3),
  completed(4),
  cancelled(7);

  final int value;
  const MentorshipStatus(this.value);

  static MentorshipStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'requested': return MentorshipStatus.requested;
      case 'rejected': return MentorshipStatus.rejected;
      case 'accepted': return MentorshipStatus.accepted;
      case 'inprogress': return MentorshipStatus.inProgress;
      case 'completed': return MentorshipStatus.completed;
      case 'cancelled': return MentorshipStatus.cancelled;
      default: return MentorshipStatus.requested;
    }
  }

  static MentorshipStatus fromInt(int value) {
    return MentorshipStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MentorshipStatus.requested,
    );
  }
}

enum StartupSubscriptionPlan {
  free(0, 2),
  pro(1, 10),
  fundraising(2, 999999);

  final int value;
  final int requestLimit;
  const StartupSubscriptionPlan(this.value, this.requestLimit);

  static StartupSubscriptionPlan fromInt(int value) {
    return StartupSubscriptionPlan.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StartupSubscriptionPlan.free,
    );
  }
}

class MentorshipDto {
  final int id;
  final int advisorId;
  final String? advisorName;
  final String? advisorAvatar;
  final MentorshipStatus status;
  final String challengeDescription;
  final String specificQuestions;
  final String preferredFormat;
  final String expectedDuration;
  final String expectedScope;
  final int price;
  final DateTime createdAt;
  final List<MentorshipSession> sessions;
  final List<MentorshipReport> reports;

  MentorshipDto({
    required this.id,
    required this.advisorId,
    this.advisorName,
    this.advisorAvatar,
    required this.status,
    required this.challengeDescription,
    this.specificQuestions = '',
    this.preferredFormat = '',
    this.expectedDuration = '',
    this.expectedScope = '',
    this.price = 0,
    required this.createdAt,
    this.sessions = const [],
    this.reports = const [],
  });

  double get progress {
    if (status == MentorshipStatus.completed) return 1.0;
    if (status == MentorshipStatus.rejected || status == MentorshipStatus.cancelled) return 0.0;
    
    if (sessions.isEmpty) return 0.0;
    
    int completed = sessions.where((s) => s.status.toLowerCase() == 'completed' || s.status.toLowerCase() == 'finished').length;
    return (completed / sessions.length).clamp(0.0, 1.0);
  }

  factory MentorshipDto.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) => val is int ? val : int.tryParse(val.toString()) ?? 0;
    
    return MentorshipDto(
      id: parseId(json['mentorshipID'] ?? json['id']),
      advisorId: parseId(json['advisorId']),
      advisorName: json['advisorName'] ?? json['name'],
      advisorAvatar: json['advisorAvatar'] ?? json['avatarUrl'],
      status: json['status'] is String 
          ? MentorshipStatus.fromString(json['status'])
          : json['mentorshipStatus'] is String
              ? MentorshipStatus.fromString(json['mentorshipStatus'])
              : MentorshipStatus.fromInt(json['status'] ?? 0),
      challengeDescription: json['challengeDescription'] ?? '',
      specificQuestions: json['specificQuestions'] ?? '',
      preferredFormat: json['preferredFormat'] ?? '',
      expectedDuration: json['expectedDuration'] ?? '',
      expectedScope: json['expectedScope'] ?? '',
      price: json['price'] ?? 0,
      createdAt: json['requestedAt'] != null 
          ? DateTime.tryParse(json['requestedAt']) ?? DateTime.now()
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now()),
      sessions: (json['sessions'] as List?)?.map((s) => MentorshipSession.fromJson(s)).toList() ?? [],
      reports: (json['reports'] as List?)?.map((r) => MentorshipReport.fromJson(r)).toList() ?? [],
    );
  }
}

class MentorshipSession {
  final int id;
  final DateTime scheduledStartAt;
  final int durationMinutes;
  final String? meetingURL;
  final String status;

  MentorshipSession({
    required this.id,
    required this.scheduledStartAt,
    required this.durationMinutes,
    this.meetingURL,
    required this.status,
  });

  factory MentorshipSession.fromJson(Map<String, dynamic> json) {
    return MentorshipSession(
      id: json['sessionID'] ?? 0,
      scheduledStartAt: DateTime.tryParse(json['scheduledStartAt'] ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 0,
      meetingURL: json['meetingURL'],
      status: json['sessionStatus'] ?? 'Scheduled',
    );
  }
}

class MentorshipReport {
  final String summary;
  final String recommendations;
  final DateTime submittedAt;

  MentorshipReport({
    required this.summary,
    required this.recommendations,
    required this.submittedAt,
  });

  factory MentorshipReport.fromJson(Map<String, dynamic> json) {
    return MentorshipReport(
      summary: json['reportSummary'] ?? '',
      recommendations: json['recommendations'] ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class CreateMentorshipRequest {
  final int advisorId;
  final String challengeDescription;
  final String specificQuestions;
  final String preferredFormat;
  final String expectedDuration;
  final String expectedScope;
  final List<RequestedSlot> requestedSlots;

  CreateMentorshipRequest({
    required this.advisorId,
    required this.challengeDescription,
    required this.specificQuestions,
    required this.preferredFormat,
    required this.expectedDuration,
    required this.expectedScope,
    required this.requestedSlots,
  });

  Map<String, dynamic> toJson() => {
    'advisorId': advisorId,
    'challengeDescription': challengeDescription,
    'specificQuestions': specificQuestions,
    'preferredFormat': preferredFormat,
    'expectedDuration': expectedDuration,
    'expectedScope': expectedScope,
    'requestedSlots': requestedSlots.map((s) => s.toJson()).toList(),
  };
}

class RequestedSlot {
  final DateTime startAt;
  final DateTime endAt;

  RequestedSlot({required this.startAt, required this.endAt});

  Map<String, dynamic> toJson() => {
    'startAt': startAt.toIso8601String(),
    'endAt': endAt.toIso8601String(),
  };
}

class PaymentInfoDto {
  final String checkoutUrl;
  final int orderCode;

  PaymentInfoDto({required this.checkoutUrl, required this.orderCode});

  factory PaymentInfoDto.fromJson(Map<String, dynamic> json) {
    return PaymentInfoDto(
      checkoutUrl: json['checkoutUrl'],
      orderCode: json['orderCode'],
    );
  }
}

class ReportDto {
  final int id;
  final String content;
  final DateTime createdAt;

  ReportDto({required this.id, required this.content, required this.createdAt});

  factory ReportDto.fromJson(Map<String, dynamic> json) {
    return ReportDto(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CreateFeedbackRequest {
  final int? sessionId;
  final int rating;
  final String comment;

  CreateFeedbackRequest({
    this.sessionId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'rating': rating,
    'comment': comment,
  };
}
