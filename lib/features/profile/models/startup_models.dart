import 'dart:io';

enum StartupStage {
  idea,      // 0
  preSeed,   // 1
  seed,      // 2
  seriesA,   // 3
  seriesB,   // 4
  seriesC,   // 5
  growth,    // 6
}

enum ProfileStatus {
  draft,     // 0
  pending,   // 1
  approved,  // 2
  rejected,  // 3
}

class IndustryDto {
  final int id;
  final String name;

  IndustryDto({required this.id, required this.name});

  factory IndustryDto.fromJson(Map<String, dynamic> json) {
    return IndustryDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StartupProfileDto {
  final int startupId;
  final String companyName;
  final String oneLiner;
  final String? description;
  final String? logoUrl;
  final String? website;
  
  final int? industryId;
  final String? industryName;
  final String? subIndustry;
  final dynamic stage; 
  final DateTime? foundedDate;
  final String? location;
  final String? country;

  final double? fundingAmountSought;
  final double? currentFundingRaised;
  final DateTime? lastFundingDate;
  final double? revenue;
  final double? valuation;

  final String? fullNameOfApplicant;
  final String? roleOfApplicant;
  final String? contactEmail;
  final String? phoneNumber;
  final String? linkedInUrl;

  final String profileStatus;
  final bool isVisible;
  final double profileScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final String? kycStatus;

  // Additional fields used by service/view
  final String? teamSize;
  final String? marketScope;
  final String? productStatus;
  final String? problemStatement;
  final String? solutionSummary;
  final String? metricSummary;
  final String? businessCode;
  final List<String>? currentNeeds;
  final int? subscriptionPlan;
  final DateTime? subscriptionEndDate;

  StartupProfileDto({
    required this.startupId,
    required this.companyName,
    required this.oneLiner,
    this.description,
    this.logoUrl,
    this.website,
    this.industryId,
    this.industryName,
    this.subIndustry,
    this.stage,
    this.foundedDate,
    this.location,
    this.country,
    this.fundingAmountSought,
    this.currentFundingRaised,
    this.lastFundingDate,
    this.revenue,
    this.valuation,
    this.fullNameOfApplicant,
    this.roleOfApplicant,
    this.contactEmail,
    this.phoneNumber,
    this.linkedInUrl,
    required this.profileStatus,
    required this.isVisible,
    this.profileScore = 0,
    this.createdAt,
    this.updatedAt,
    this.kycStatus,
    this.teamSize,
    this.marketScope,
    this.productStatus,
    this.problemStatement,
    this.solutionSummary,
    this.metricSummary,
    this.businessCode,
    this.currentNeeds,
    this.subscriptionPlan,
    this.subscriptionEndDate,
  });

  factory StartupProfileDto.fromJson(Map<String, dynamic> json) {
    return StartupProfileDto(
      startupId: json['startupID'] ?? json['id'] ?? 0,
      companyName: json['companyName'] ?? json['CompanyName'] ?? '',
      oneLiner: json['oneLiner'] ?? json['OneLiner'] ?? '',
      description: json['description'] ?? json['Description'],
      logoUrl: json['logoURL'] ?? json['LogoUrl'],
      website: json['website'] ?? json['Website'],
      industryId: json['industryID'] ?? json['IndustryID'],
      industryName: json['industryName'] ?? json['IndustryName'],
      subIndustry: json['subIndustry'] ?? json['SubIndustry'],
      stage: json['stage'] ?? json['Stage'],
      foundedDate: json['foundedDate'] != null ? DateTime.parse(json['foundedDate']) : null,
      location: json['location'] ?? json['Location'],
      country: json['country'] ?? json['Country'],
      fundingAmountSought: (json['fundingAmountSought'] ?? json['FundingAmountSought'])?.toDouble(),
      currentFundingRaised: (json['currentFundingRaised'] ?? json['CurrentFundingRaised'])?.toDouble(),
      lastFundingDate: json['lastFundingDate'] != null ? DateTime.parse(json['lastFundingDate']) : null,
      revenue: (json['revenue'] ?? json['Revenue'])?.toDouble(),
      valuation: (json['valuation'] ?? json['Valuation'])?.toDouble(),
      fullNameOfApplicant: json['fullNameOfApplicant'] ?? json['FullNameOfApplicant'],
      roleOfApplicant: json['roleOfApplicant'] ?? json['RoleOfApplicant'],
      contactEmail: json['contactEmail'] ?? json['ContactEmail'],
      phoneNumber: json['phoneNumber'] ?? json['PhoneNumber'],
      linkedInUrl: json['linkedInUrl'] ?? json['LinkedinUrl'] ?? json['LinkedInURL'],
      profileStatus: json['profileStatus'] ?? 'Draft',
      isVisible: json['isVisible'] ?? false,
      profileScore: (json['profileScore'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      kycStatus: json['kycStatus'],
      teamSize: json['teamSize'] ?? json['TeamSize'],
      marketScope: json['marketScope'] ?? json['MarketScope'],
      productStatus: json['productStatus'] ?? json['ProductStatus'],
      problemStatement: json['problemStatement'] ?? json['ProblemStatement'],
      solutionSummary: json['solutionSummary'] ?? json['SolutionSummary'],
      metricSummary: json['metricSummary'] ?? json['MetricSummary'],
      businessCode: json['businessCode'] ?? json['BusinessCode'],
      currentNeeds: json['currentNeeds'] != null ? List<String>.from(json['currentNeeds']) : null,
      subscriptionPlan: json['subscriptionPlan'] ?? json['SubscriptionPlan'],
      subscriptionEndDate: json['subscriptionEndDate'] != null ? DateTime.parse(json['subscriptionEndDate']) : 
                           json['SubscriptionEndDate'] != null ? DateTime.parse(json['SubscriptionEndDate']) : null,
    );
  }
}

class CreateStartupProfileRequest {
  final String companyName;
  final String oneLiner;
  final String? description;
  final String? website;
  
  final int stage;
  final int? industryId;
  final String? subIndustry;
  final DateTime? foundedDate;
  final String? location;
  final String? country;

  final double? fundingAmountSought;
  final double? currentFundingRaised;
  final DateTime? lastFundingDate;
  final double? revenue;
  final double? valuation;

  final String fullNameOfApplicant;
  final String roleOfApplicant;
  final String contactEmail;
  final String? phoneNumber;
  final String? linkedInUrl;

  final File? logoFile;
  
  // Necessary fields for StartupService
  final String? teamSize;
  final String? contactPhone;
  final String? marketScope;
  final String? productStatus;
  final String? problemStatement;
  final String? solutionSummary;
  final String? metricSummary;
  final String? businessCode;
  final String? pitchDeckUrl;
  final List<String>? currentNeeds;
  final File? fileCertificateBusiness;

  CreateStartupProfileRequest({
    required this.companyName,
    required this.oneLiner,
    this.description,
    this.website,
    required this.stage,
    this.industryId,
    this.subIndustry,
    this.foundedDate,
    this.location,
    this.country,
    this.fundingAmountSought,
    this.currentFundingRaised,
    this.lastFundingDate,
    this.revenue,
    this.valuation,
    required this.fullNameOfApplicant,
    required this.roleOfApplicant,
    required this.contactEmail,
    this.phoneNumber,
    this.linkedInUrl,
    this.logoFile,
    this.teamSize,
    this.contactPhone,
    this.marketScope,
    this.productStatus,
    this.problemStatement,
    this.solutionSummary,
    this.metricSummary,
    this.businessCode,
    this.pitchDeckUrl,
    this.currentNeeds,
    this.fileCertificateBusiness,
  });
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
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      photoUrl: json['photoURL'] ?? json['PhotoUrl'],
      bio: json['bio'] ?? json['Bio'],
    );
  }
}
