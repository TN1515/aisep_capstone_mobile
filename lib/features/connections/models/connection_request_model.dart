import 'connection_model.dart';

class ConnectionRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RequestTimelineEvent> timeline;

  ConnectionRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.timeline,
  });
}

class RequestTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final ConnectionStatus status;

  RequestTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}
