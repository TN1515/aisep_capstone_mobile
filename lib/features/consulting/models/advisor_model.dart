import 'package:flutter/material.dart';

enum AdvisorStatus { active, inactive, busy }

class AdvisorModel {
  final int id;
  final String fullName;
  final String title;
  final String bio;
  final String profilePhotoURL;
  final List<String> expertise;
  final List<Map<String, dynamic>> industry;
  final double averageRating;
  final int reviewCount;
  final int completedSessions;
  final int yearsOfExperience;
  final bool isVerified;
  final String availabilityHint;
  final double hourlyRate;
  final String? mentorshipPhilosophy;
  final List<String> skills;
  final String? experiencesJson;
  final Map<String, dynamic>? availability;
  final List<dynamic> reviews; // Added to match AdvisorDetailDto
  final Map<int, int> ratingDistribution;
  final AdvisorStatus status;
  final bool isBookmarked;

  const AdvisorModel({
    required this.id,
    required this.fullName,
    required this.title,
    required this.bio,
    required this.profilePhotoURL,
    required this.expertise,
    this.industry = const [],
    required this.averageRating,
    this.reviewCount = 0,
    required this.completedSessions,
    required this.yearsOfExperience,
    this.isVerified = false,
    this.availabilityHint = '',
    required this.hourlyRate,
    this.mentorshipPhilosophy,
    this.skills = const [],
    this.experiencesJson,
    this.availability,
    this.reviews = const [],
    this.ratingDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.status = AdvisorStatus.active,
    this.isBookmarked = false,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return AdvisorModel(
      id: parseId(json['advisorID'] ?? json['id']),
      fullName: json['fullName'] ?? json['name'] ?? 'Unknown',
      title: json['title'] ?? 'Advisor',
      bio: json['bio'] ?? '',
      profilePhotoURL: json['profilePhotoURL'] ?? json['ProfilePhotoURL'] ?? json['avatarUrl'] ?? json['AvatarUrl'] ?? json['imageUrl'] ?? json['ImageUrl'] ?? '',
      expertise: List<String>.from(json['expertise'] ?? json['Expertise'] ?? []),
      industry: List<Map<String, dynamic>>.from(json['industry'] ?? []),
      averageRating: parseDouble(json['averageRating'] ?? json['rating']),
      reviewCount: parseInt(json['reviewCount'] ?? 0),
      completedSessions: parseInt(json['completedSessions'] ?? json['totalSessions'] ?? 0),
      yearsOfExperience: parseInt(json['yearsOfExperience'] ?? json['yearsExperience'] ?? 0),
      isVerified: json['isVerified'] ?? false,
      availabilityHint: json['availabilityHint'] ?? '',
      hourlyRate: parseDouble(json['hourlyRate']),
      mentorshipPhilosophy: json['mentorshipPhilosophy'],
      skills: List<String>.from(json['skills'] ?? []),
      experiencesJson: json['experiencesJson'],
      availability: json['availability'],
      reviews: json['reviews'] ?? [],
      ratingDistribution: json['ratingDistribution'] != null 
        ? Map<int, int>.from((json['ratingDistribution'] as Map).map((k, v) => MapEntry(parseInt(k), parseInt(v))))
        : {5: (parseInt(json['reviewCount'] ?? 0)) ~/ 2, 4: (parseInt(json['reviewCount'] ?? 0)) ~/ 4, 3: (parseInt(json['reviewCount'] ?? 0)) ~/ 4, 2: 0, 1: 0},
      status: AdvisorStatus.active, 
      isBookmarked: false,
    );
  }

  AdvisorModel copyWith({
    String? fullName,
    String? title,
    String? bio,
    String? profilePhotoURL,
    List<String>? expertise,
    double? averageRating,
    int? completedSessions,
    int? yearsOfExperience,
    AdvisorStatus? status,
    bool? isBookmarked,
    double? hourlyRate,
    String? availabilityHint,
    bool? isVerified,
    List<dynamic>? reviews,
    String? mentorshipPhilosophy,
    List<String>? skills,
  }) {
    return AdvisorModel(
      id: id,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      profilePhotoURL: profilePhotoURL ?? this.profilePhotoURL,
      expertise: expertise ?? this.expertise,
      industry: industry,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount,
      completedSessions: completedSessions ?? this.completedSessions,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isVerified: isVerified ?? this.isVerified,
      availabilityHint: availabilityHint ?? this.availabilityHint,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      mentorshipPhilosophy: mentorshipPhilosophy ?? this.mentorshipPhilosophy,
      skills: skills ?? this.skills,
      experiencesJson: experiencesJson,
      availability: availability,
      reviews: reviews ?? this.reviews,
      status: status ?? this.status,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
