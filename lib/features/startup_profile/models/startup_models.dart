import 'dart:io';

class IndustryDto {
  final int id;
  final String name;

  IndustryDto({required this.id, required this.name});

  factory IndustryDto.fromJson(Map<String, dynamic> json) {
    return IndustryDto(
      id: json['id'],
      name: json['name'],
    );
  }
}

class StartupProfileDto {
  final int startupId;
  final String companyName;
  final String oneLiner;
  final String? description;
  final String? location;
  final String? website;
  final String? businessCode;
  final String? industryName;
  final int? industryId;
  final String? stage;
  final String? logoUrl;
  final String? roleOfApplicant;
  final String? contactEmail;
  final String profileStatus; // Approved, PendingKYC, etc.
  final bool isVisible;

  StartupProfileDto({
    required this.startupId,
    required this.companyName,
    required this.oneLiner,
    this.description,
    this.location,
    this.website,
    this.businessCode,
    this.industryName,
    this.industryId,
    this.stage,
    this.logoUrl,
    this.roleOfApplicant,
    this.contactEmail,
    required this.profileStatus,
    required this.isVisible,
  });

  factory StartupProfileDto.fromJson(Map<String, dynamic> json) {
    return StartupProfileDto(
      startupId: json['startupID'] ?? json['id'] ?? json['StartupID'] ?? 0,
      companyName: json['companyName'] ?? json['CompanyName'] ?? '',
      oneLiner: json['oneLiner'] ?? json['OneLiner'] ?? '',
      description: json['description'] ?? json['Description'],
      location: json['location'] ?? json['Location'],
      website: json['website'] ?? json['Website'],
      businessCode: json['businessCode'] ?? json['BusinessCode'],
      industryName: json['industryName'] ?? json['IndustryName'],
      industryId: json['industryID'] ?? json['IndustryID'],
      stage: json['stage'] ?? json['Stage'],
      logoUrl: json['logoURL'] ?? json['LogoUrl'] ?? json['LogoURL'],
      roleOfApplicant: json['roleOfApplicant'] ?? json['RoleOfApplicant'] ?? json['role'],
      contactEmail: json['contactEmail'] ?? json['ContactEmail'] ?? json['email'],
      profileStatus: json['profileStatus'] ?? json['ProfileStatus'] ?? 'Draft',
      isVisible: json['isVisible'] ?? json['IsVisible'] ?? false,
    );
  }
}

class TeamMemberDto {
  final int id;
  final String fullName;
  final String role;
  final String? photoUrl;
  final String? bio;

  TeamMemberDto({
    required this.id,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.bio,
  });

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      id: json['id'] ?? json['ID'] ?? 0,
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
      photoUrl: json['photoURL'] ?? json['PhotoUrl'] ?? json['PhotoURL'],
      bio: json['bio'] ?? json['Bio'],
    );
  }
}

/// Model cho yêu cầu tạo/cập nhật Profile (truyền vào Service)
class CreateStartupProfileRequest {
  final String companyName;
  final String oneLiner;
  final int stage; // 0-6 (Idea to Growth)
  final String fullNameOfApplicant;
  final String roleOfApplicant;
  final String contactEmail;
  
  // Optional / Optimization Fields
  final int? industryId;
  final String? subIndustry;
  final String? description;
  final DateTime? foundedDate;
  final String? website;
  final String? location;
  final String? country;
  final String? teamSize;
  final String? linkedInUrl;
  final String? contactPhone;
  final String? marketScope;
  final String? productStatus;
  final String? problemStatement;
  final String? solutionSummary;
  final String? metricSummary;
  final List<String>? currentNeeds;
  final double? fundingAmountSought;
  final double? currentFundingRaised;
  final double? valuation;
  final String? businessCode;
  final String? pitchDeckUrl;
  
  // Files
  final File? logoFile;
  final File? fileCertificateBusiness;

  CreateStartupProfileRequest({
    required this.companyName,
    required this.oneLiner,
    required this.stage,
    required this.fullNameOfApplicant,
    required this.roleOfApplicant,
    required this.contactEmail,
    this.industryId,
    this.subIndustry,
    this.description,
    this.foundedDate,
    this.website,
    this.location,
    this.country,
    this.teamSize,
    this.linkedInUrl,
    this.contactPhone,
    this.marketScope,
    this.productStatus,
    this.problemStatement,
    this.solutionSummary,
    this.metricSummary,
    this.currentNeeds,
    this.fundingAmountSought,
    this.currentFundingRaised,
    this.valuation,
    this.businessCode,
    this.pitchDeckUrl,
    this.logoFile,
    this.fileCertificateBusiness,
  });
}
