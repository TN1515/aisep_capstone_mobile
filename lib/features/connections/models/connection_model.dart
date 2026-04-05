import 'package:flutter/material.dart';

enum ConnectionRole {
  investor,
  advisor,
}

enum ConnectionStatus {
  pending,      // Startup sent, waiting for Investor
  received,     // Investor sent, waiting for Startup
  active,       // Both accepted (Connected)
  rejected,     // Declined by either party
  cancelled,    // Revoked by sender
  expired,      // No action taken in time
}

class ConnectionModel {
  final String id;
  final String name;
  final String? organization;
  final String position;
  final ConnectionRole role;
  final ConnectionStatus status;
  final String? bio;
  final List<String> tags;
  final double matchScore; // 0.0 to 1.0
  final DateTime lastUpdated;
  final String? avatarUrl;
  final bool isVerified;
  final String? requestId; // Link to detailed request if exists

  ConnectionModel({
    required this.id,
    required this.name,
    this.organization,
    required this.position,
    required this.role,
    required this.status,
    this.bio,
    required this.tags,
    this.matchScore = 0.0,
    required this.lastUpdated,
    this.avatarUrl,
    this.isVerified = false,
    this.requestId,
  });

  ConnectionModel copyWith({
    ConnectionStatus? status,
    DateTime? lastUpdated,
    String? requestId,
  }) {
    return ConnectionModel(
      id: id,
      name: name,
      organization: organization,
      position: position,
      role: role,
      status: status ?? this.status,
      bio: bio,
      tags: tags,
      matchScore: matchScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      requestId: requestId ?? this.requestId,
    );
  }
}
