import 'package:flutter/material.dart';

enum AdvisorStatus { active, inactive, busy }

class AdvisorModel {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String avatarUrl;
  final List<String> expertise;
  final double rating;
  final int totalSessions;
  final int yearsExperience;
  final AdvisorStatus status;
  final bool isBookmarked;
  final double hourlyRate;
  final Map<int, int> ratingDistribution; // New: 5: 100, 4: 20 etc.
  final List<String> certifications; // New: Certs

  const AdvisorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    required this.avatarUrl,
    required this.expertise,
    required this.rating,
    required this.totalSessions,
    required this.yearsExperience,
    this.status = AdvisorStatus.active,
    this.isBookmarked = false,
    required this.hourlyRate,
    this.ratingDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.certifications = const [],
  });

  AdvisorModel copyWith({
    String? name,
    String? title,
    String? bio,
    String? avatarUrl,
    List<String>? expertise,
    double? rating,
    int? totalSessions,
    int? yearsExperience,
    AdvisorStatus? status,
    bool? isBookmarked,
    double? hourlyRate,
    Map<int, int>? ratingDistribution,
    List<String>? certifications,
  }) {
    return AdvisorModel(
      id: id,
      name: name ?? this.name,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      expertise: expertise ?? this.expertise,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      status: status ?? this.status,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      certifications: certifications ?? this.certifications,
    );
  }
}
