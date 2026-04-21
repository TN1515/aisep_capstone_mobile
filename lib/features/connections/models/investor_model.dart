class InvestorModel {
  final int id;
  final String fullName;
  final String? firmName;
  final String? bio;
  final String? avatarUrl;
  final bool isVerified;
  final String marketScope; // Restore for UI
  final String supportOffered; // Restore for UI
  
  // Detailed fields
  final String? investmentThesis;
  final List<String> preferredStages;
  final List<String> preferredIndustries;
  final String? location;
  final String? website;
  final String? investorType;

  // Legacy/UI Compatibility fields
  final double matchScore;
  final bool isFavorite;

  InvestorModel({
    required this.id,
    required this.fullName,
    this.firmName,
    this.bio,
    this.avatarUrl,
    this.isVerified = false,
    this.marketScope = 'Toàn quốc',
    this.supportOffered = 'Liên hệ để biết thêm chi tiết',
    this.investmentThesis,
    this.preferredStages = const [],
    this.preferredIndustries = const [],
    this.location,
    this.website,
    this.investorType,
    this.matchScore = 0.0,
    this.isFavorite = false,
  });

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    // Resilience against PascalCase, camelCase, snake_case and variations
    final idVal = json['id'] ?? json['Id'] ?? json['investorId'] ?? json['InvestorId'] ?? json['investor_id'] ?? json['investorID'] ?? json['ID'];
    final fullNameVal = json['fullName'] ?? json['FullName'] ?? json['name'] ?? json['Name'];
    final firmNameVal = json['firmName'] ?? json['FirmName'] ?? json['organization'] ?? json['Organization'];
    final bioVal = json['bio'] ?? json['Bio'];
    final avatarUrlVal = json['avatarUrl'] ?? json['AvatarUrl'] ?? json['AvatarURL'] ?? 
                        json['profileImage'] ?? json['ProfileImage'] ?? 
                        json['imageUrl'] ?? json['ImageUrl'] ?? 
                        json['logo'] ?? json['Logo'] ??
                        json['picture'] ?? json['Picture'] ??
                        json['profilePicture'] ?? json['ProfilePicture'];
    final isVerifiedVal = json['isVerified'] ?? json['IsVerified'] ?? json['profileStatus'] == 'Approved' ?? json['ProfileStatus'] == 'Approved';
    final marketScopeVal = json['marketScope'] ?? json['MarketScope'];
    final supportOfferedVal = json['supportOffered'] ?? json['SupportOffered'];
    final thesisVal = json['investmentThesis'] ?? json['InvestmentThesis'] ?? json['bio'] ?? json['Bio'] ?? json['thesis'] ?? json['Thesis'];
    final stagesVal = json['preferredStages'] ?? json['PreferredStages'] ?? json['stages'] ?? json['Stages'];
    final industriesVal = json['preferredIndustries'] ?? json['PreferredIndustries'] ?? json['industries'] ?? json['Industries'];
    final locationVal = json['location'] ?? json['Location'];
    final websiteVal = json['website'] ?? json['Website'];
    final matchScoreVal = json['matchScore'] ?? json['MatchScore'];
    final isFavoriteVal = json['isFavorite'] ?? json['IsFavorite'];
    final typeVal = json['investorType'] ?? json['InvestorType'] ?? json['type'] ?? json['Type'];

    return InvestorModel(
      id: int.tryParse(idVal?.toString() ?? '0') ?? 0,
      fullName: fullNameVal?.toString() ?? 'Unknown',
      firmName: firmNameVal?.toString(),
      bio: bioVal?.toString(),
      avatarUrl: avatarUrlVal?.toString(),
      isVerified: isVerifiedVal == true,
      marketScope: marketScopeVal?.toString() ?? 'Toàn quốc',
      supportOffered: supportOfferedVal?.toString() ?? 'Liên hệ để biết thêm chi tiết',
      investmentThesis: thesisVal?.toString(),
      preferredStages: (stagesVal as List?)?.map((e) => e.toString()).toList() ?? [],
      preferredIndustries: (industriesVal as List?)?.map((e) => e.toString()).toList() ?? [],
      location: locationVal?.toString(),
      website: websiteVal?.toString(),
      investorType: typeVal?.toString(),
      matchScore: double.tryParse(matchScoreVal?.toString() ?? '0') ?? 0.0,
      isFavorite: isFavoriteVal == true,
    );
  }

  // Legacy mappings for UI compatibility
  String get name => fullName;
  String? get organization => firmName;
  String? get position => 'Nhà đầu tư';
  String get thesis => investmentThesis ?? 'Chưa có thông tin';
  List<String> get industries => preferredIndustries;
  List<String> get stages => preferredStages;

  InvestorModel copyWith({bool? isFavorite}) {
    return InvestorModel(
      id: id,
      fullName: fullName,
      firmName: firmName,
      bio: bio,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      marketScope: marketScope,
      supportOffered: supportOffered,
      investmentThesis: investmentThesis,
      preferredStages: preferredStages,
      preferredIndustries: preferredIndustries,
      location: location,
      website: website,
      investorType: investorType,
      matchScore: matchScore,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}


