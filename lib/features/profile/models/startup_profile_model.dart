class StartupProfileModel {
  // 1. Core Info
  String startupName;
  String tagline;
  String description;
  String logoUrl;
  String websiteLink;

  // 2. Industry & Stage
  int? industryId;
  String industry;
  String subIndustry;
  String stage;
  DateTime? foundedDate;
  String location;
  String country;

  // 3. Financials
  double fundingAmountSought;
  double currentFundingRaised;
  DateTime? lastFundingDate;
  double revenue;
  double valuation;

  // 4. Contact Info
  String fullNameOfApplicant;
  String roleOfApplicant;
  String contactEmail;
  String phoneNumber;
  String linkedInUrl;

  // 5. System Metadata
  String profileStatus;
  bool isVisible;
  double profileScore;
  DateTime? createdAt;
  DateTime? updatedAt;
  String kycStatus;

  // 6. Additional fields for back-compat
  String solutionSummary;
  String marketScope;

  StartupProfileModel({
    this.startupName = '',
    this.tagline = '',
    this.description = '',
    this.logoUrl = '',
    this.websiteLink = '',
    this.industryId,
    this.industry = '',
    this.subIndustry = '',
    this.stage = 'Idea',
    this.foundedDate,
    this.location = '',
    this.country = '',
    this.fundingAmountSought = 0,
    this.currentFundingRaised = 0,
    this.lastFundingDate,
    this.revenue = 0,
    this.valuation = 0,
    this.fullNameOfApplicant = '',
    this.roleOfApplicant = '',
    this.contactEmail = '',
    this.phoneNumber = '',
    this.linkedInUrl = '',
    this.profileStatus = 'Draft',
    this.isVisible = false,
    this.profileScore = 0,
    this.createdAt,
    this.updatedAt,
    this.kycStatus = 'Chưa xác thực',
    this.solutionSummary = '',
    this.marketScope = '',
  });

  StartupProfileModel copyWith({
    String? startupName,
    String? tagline,
    String? description,
    String? logoUrl,
    String? websiteLink,
    int? industryId,
    String? industry,
    String? subIndustry,
    String? stage,
    DateTime? foundedDate,
    String? location,
    String? country,
    double? fundingAmountSought,
    double? currentFundingRaised,
    DateTime? lastFundingDate,
    double? revenue,
    double? valuation,
    String? fullNameOfApplicant,
    String? roleOfApplicant,
    String? contactEmail,
    String? phoneNumber,
    String? linkedInUrl,
    String? profileStatus,
    bool? isVisible,
    double? profileScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? kycStatus,
    String? solutionSummary,
    String? marketScope,
  }) {
    return StartupProfileModel(
      startupName: startupName ?? this.startupName,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteLink: websiteLink ?? this.websiteLink,
      industryId: industryId ?? this.industryId,
      industry: industry ?? this.industry,
      subIndustry: subIndustry ?? this.subIndustry,
      stage: stage ?? this.stage,
      foundedDate: foundedDate ?? this.foundedDate,
      location: location ?? this.location,
      country: country ?? this.country,
      fundingAmountSought: fundingAmountSought ?? this.fundingAmountSought,
      currentFundingRaised: currentFundingRaised ?? this.currentFundingRaised,
      lastFundingDate: lastFundingDate ?? this.lastFundingDate,
      revenue: revenue ?? this.revenue,
      valuation: valuation ?? this.valuation,
      fullNameOfApplicant: fullNameOfApplicant ?? this.fullNameOfApplicant,
      roleOfApplicant: roleOfApplicant ?? this.roleOfApplicant,
      contactEmail: contactEmail ?? this.contactEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      profileStatus: profileStatus ?? this.profileStatus,
      isVisible: isVisible ?? this.isVisible,
      profileScore: profileScore ?? this.profileScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kycStatus: kycStatus ?? this.kycStatus,
      solutionSummary: solutionSummary ?? this.solutionSummary,
      marketScope: marketScope ?? this.marketScope,
    );
  }

  // Legacy mappings 
  String get problemStatement => description;
  set problemStatement(String val) => description = val;
}
