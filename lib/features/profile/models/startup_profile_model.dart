class StartupProfileModel {
  String startupName;
  String tagline;
  String stage;
  String industry;
  String location;
  String websiteLink;
  String productLink;
  String demoLink;
  String logoUrl;
  
  // Quick business snapshot
  String problemStatement;
  String solutionSummary;
  String marketScope; // B2B / B2C / B2G
  String productStatus;
  String currentNeeds;

  // Team snapshot
  String founderNames; // Can be multi-line
  String founderRoles;
  String teamSize;

  // Validation snapshot
  String validationStatus; // No validation / Interviews / Pilot / Users / Revenue
  String metricSummary;

  StartupProfileModel({
    this.startupName = '',
    this.tagline = '',
    this.stage = '',
    this.industry = '',
    this.location = '',
    this.websiteLink = '',
    this.productLink = '',
    this.demoLink = '',
    this.logoUrl = '',
    this.problemStatement = '',
    this.solutionSummary = '',
    this.marketScope = '',
    this.productStatus = '',
    this.currentNeeds = '',
    this.founderNames = '',
    this.founderRoles = '',
    this.teamSize = '',
    this.validationStatus = '',
    this.metricSummary = '',
  });

  StartupProfileModel copyWith({
    String? startupName,
    String? tagline,
    String? stage,
    String? industry,
    String? location,
    String? websiteLink,
    String? productLink,
    String? demoLink,
    String? logoUrl,
    String? problemStatement,
    String? solutionSummary,
    String? marketScope,
    String? productStatus,
    String? currentNeeds,
    String? founderNames,
    String? founderRoles,
    String? teamSize,
    String? validationStatus,
    String? metricSummary,
  }) {
    return StartupProfileModel(
      startupName: startupName ?? this.startupName,
      tagline: tagline ?? this.tagline,
      stage: stage ?? this.stage,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      websiteLink: websiteLink ?? this.websiteLink,
      productLink: productLink ?? this.productLink,
      demoLink: demoLink ?? this.demoLink,
      logoUrl: logoUrl ?? this.logoUrl,
      problemStatement: problemStatement ?? this.problemStatement,
      solutionSummary: solutionSummary ?? this.solutionSummary,
      marketScope: marketScope ?? this.marketScope,
      productStatus: productStatus ?? this.productStatus,
      currentNeeds: currentNeeds ?? this.currentNeeds,
      founderNames: founderNames ?? this.founderNames,
      founderRoles: founderRoles ?? this.founderRoles,
      teamSize: teamSize ?? this.teamSize,
      validationStatus: validationStatus ?? this.validationStatus,
      metricSummary: metricSummary ?? this.metricSummary,
    );
  }
}
