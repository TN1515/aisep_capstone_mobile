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

class IndustryCategory {
  final String name;
  final List<String> subIndustries;

  IndustryCategory({required this.name, required this.subIndustries});
}

class IndustryDto {
  final int id;
  final String name;
  final String? description;
  final List<IndustryDto> subIndustries;

  IndustryDto({
    required this.id, 
    required this.name, 
    this.description,
    this.subIndustries = const [],
  });

  factory IndustryDto.fromJson(Map<String, dynamic> json) {
    return IndustryDto(
      id: json['id'] ?? json['industryID'] ?? 0,
      name: json['name'] ?? json['industryName'] ?? '',
      description: json['description'],
      subIndustries: json['subIndustries'] != null 
          ? (json['subIndustries'] as List).map((i) => IndustryDto.fromJson(i)).toList()
          : [],
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
  final String? tractionIndex;
  final DateTime? approvedAt;

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
    this.tractionIndex,
    this.approvedAt,
  });

  factory StartupProfileDto.fromJson(Map<String, dynamic> json) {
    // Xử lý subscriptionPlan một cách linh hoạt (chấp nhận cả String và int)
    int? parseSubscriptionPlan(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase().contains('free')) return 0;
        if (value.toLowerCase().contains('pro')) return 1;
        return int.tryParse(value);
      }
      return null;
    }

    return StartupProfileDto(
      startupId: json['startupID'] ?? json['id'] ?? 0,
      companyName: json['companyName'] ?? json['CompanyName'] ?? '',
      oneLiner: json['oneLiner'] ?? json['OneLiner'] ?? '',
      description: json['description'] ?? json['Description'],
      logoUrl: json['logoURL'] ?? json['logoUrl'] ?? json['LogoUrl'],
      website: json['website'] ?? json['Website'],
      industryId: json['industryID'] ?? json['id'] ?? 0,
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
      phoneNumber: json['contactPhone'] ?? json['phoneNumber'] ?? json['PhoneNumber'] ?? json['ContactPhone'],
      linkedInUrl: json['linkedInURL'] ?? json['linkedInUrl'] ?? json['LinkedinUrl'] ?? json['LinkedInURL'] ?? json['LinkedInUrl'],
      profileStatus: json['profileStatus'] ?? 'Draft',
      isVisible: json['isVisible'] ?? false,
      profileScore: (json['profileScore'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      kycStatus: json['kycStatus'],
      teamSize: json['teamSize']?.toString() ?? json['TeamSize']?.toString(), // To String for safety
      marketScope: json['marketScope'] ?? json['MarketScope'],
      productStatus: json['productStatus'] ?? json['ProductStatus'],
      problemStatement: json['problemStatement'] ?? json['ProblemStatement'],
      solutionSummary: json['solutionSummary'] ?? json['SolutionSummary'],
      metricSummary: json['metricSummary'] ?? json['MetricSummary'],
      businessCode: json['businessCode'] ?? json['BusinessCode'],
      currentNeeds: json['currentNeeds'] != null ? List<String>.from(json['currentNeeds']) : null,
      subscriptionPlan: parseSubscriptionPlan(json['subscriptionPlan'] ?? json['SubscriptionPlan']),
      subscriptionEndDate: json['subscriptionEndDate'] != null ? DateTime.parse(json['subscriptionEndDate']) : 
                           json['SubscriptionEndDate'] != null ? DateTime.parse(json['SubscriptionEndDate']) : null,
      tractionIndex: json['tractionIndex'] ?? json['TractionIndex'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : 
                  json['ApprovedAt'] != null ? DateTime.parse(json['ApprovedAt']) : null,
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
  final String? tractionIndex;
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
    this.tractionIndex,
    this.fileCertificateBusiness,
  });
}

class TeamMemberDto {
  final int id;
  final String fullName;
  final String role;
  final String? photoUrl;
  final String? title;
  final String? bio;
  final String? participationType;
  final int? experienceYears;
  final String? linkedInUrl;
  final bool isFounder;

  TeamMemberDto({
    required this.id,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.title,
    this.bio,
    this.participationType,
    this.experienceYears,
    this.linkedInUrl,
    this.isFounder = false,
  });

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
      title: json['title'] ?? json['Title'],
      photoUrl: json['PhotoURL'] ?? json['photoURL'] ?? json['PhotoUrl'] ?? json['photoUrl'] ?? json['avatarUrl'] ?? json['AvatarUrl'] ?? json['imageUrl'] ?? json['ImageUrl'],
      bio: json['bio'] ?? json['Bio'],
      participationType: json['participationType'] ?? json['ParticipationType'],
      experienceYears: int.tryParse((json['YearsOfExperience'] ?? json['yearsOfExperience'] ?? json['experience_years'] ?? json['experienceYears'] ?? json['ExperienceYears'] ?? '').toString()),
      linkedInUrl: json['linkedInUrl'] ?? json['LinkedInUrl'] ?? json['LinkedInURL'],
      isFounder: json['isFounder'] ?? json['IsFounder'] ?? false,
    );
  }
}
