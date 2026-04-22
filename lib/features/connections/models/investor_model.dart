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
  final String? email;
  final String? phone;
  final String? linkedinUrl;

  // Legacy/UI Compatibility fields
  final double matchScore;
  final bool isFavorite;

  // Stats & Ticket Size
  final double? ticketSizeMin;
  final double? ticketSizeMax;
  final int acceptedConnectionCount;

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
    this.email,
    this.phone,
    this.linkedinUrl,
    this.matchScore = 0.0,
    this.isFavorite = false,
    this.ticketSizeMin,
    this.ticketSizeMax,
    this.acceptedConnectionCount = 0,
  });

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    // Highly resilient parsing to support various backend DTO naming conventions
    final idVal = json['id'] ?? json['Id'] ?? json['investorId'] ?? json['InvestorId'] ?? json['investor_id'] ?? json['investorID'] ?? json['ID'];
    
    // Nested parsing support: check if investor info is wrapped
    final partnerData = json['investor'] ?? json['Investor'] ?? json['partner'] ?? json['Partner'] ?? json['user'] ?? json['User'] ?? json['profile'] ?? json['Profile'];
    final Map<String, dynamic> targetJson = (partnerData is Map<String, dynamic>) ? partnerData : json;

    final fullNameVal = json['fullName'] ?? json['FullName'] ?? json['name'] ?? json['Name'] ??
                       targetJson['fullName'] ?? targetJson['FullName'] ?? targetJson['name'] ?? targetJson['Name'];
                       
    final firmNameVal = json['firmName'] ?? json['FirmName'] ?? json['organization'] ?? json['Organization'] ??
                       targetJson['firmName'] ?? targetJson['FirmName'] ?? targetJson['organization'] ?? targetJson['Organization'];
                       
    final bioVal = json['bio'] ?? json['Bio'] ?? targetJson['bio'] ?? targetJson['Bio'];
    
    final avatarUrlVal = json['avatarUrl'] ?? json['AvatarUrl'] ?? json['AvatarURL'] ?? 
                        json['profilePhotoURL'] ?? json['ProfilePhotoURL'] ?? json['ProfilePhotoUrl'] ??
                        json['investorPhotoURL'] ?? json['InvestorPhotoURL'] ??
                        json['profileImage'] ?? json['ProfileImage'] ?? 
                        json['imageUrl'] ?? json['ImageUrl'] ?? 
                        json['logo'] ?? json['Logo'] ??
                        json['picture'] ?? json['Picture'] ??
                        targetJson['avatarUrl'] ?? targetJson['AvatarUrl'] ?? targetJson['AvatarURL'] ??
                        targetJson['profilePhotoURL'] ?? targetJson['ProfilePhotoURL'] ?? targetJson['ProfilePhotoUrl'] ??
                        targetJson['investorPhotoURL'] ?? targetJson['InvestorPhotoURL'] ??
                        targetJson['profileImage'] ?? targetJson['ProfileImage'] ??
                        targetJson['imageUrl'] ?? targetJson['ImageUrl'] ??
                        targetJson['logo'] ?? targetJson['Logo'] ??
                        targetJson['logoURL'] ?? targetJson['LogoURL'] ??
                        targetJson['picture'] ?? targetJson['Picture'];

    final isVerifiedVal = json['isVerified'] ?? json['IsVerified'] ?? json['kycVerified'] ?? json['KycVerified'] ??
                         targetJson['isVerified'] ?? targetJson['IsVerified'] ?? targetJson['kycVerified'] ?? targetJson['KycVerified'] ??
                         json['profileStatus'] == 'Approved' ?? json['ProfileStatus'] == 'Approved' ??
                         targetJson['profileStatus'] == 'Approved' ?? targetJson['ProfileStatus'] == 'Approved';

    final marketScopeVal = json['marketScope'] ?? json['MarketScope'] ?? targetJson['marketScope'] ?? targetJson['MarketScope'];
    final supportOfferedVal = json['supportOffered'] ?? json['SupportOffered'] ?? targetJson['supportOffered'] ?? targetJson['SupportOffered'];
    final thesisVal = json['investmentThesis'] ?? json['InvestmentThesis'] ?? json['thesis'] ?? json['Thesis'] ??
                      targetJson['investmentThesis'] ?? targetJson['InvestmentThesis'] ?? targetJson['thesis'] ?? targetJson['Thesis'];
                     
    final stagesVal = json['preferredStages'] ?? json['PreferredStages'] ?? targetJson['preferredStages'] ?? targetJson['PreferredStages'] ??
                     json['stages'] ?? json['Stages'] ?? targetJson['stages'] ?? targetJson['Stages'];
                     
    final industriesVal = json['preferredIndustries'] ?? json['PreferredIndustries'] ?? targetJson['preferredIndustries'] ?? targetJson['PreferredIndustries'] ??
                         json['industries'] ?? json['Industries'] ?? targetJson['industries'] ?? targetJson['Industries'];
                         
    final locationVal = json['location'] ?? json['Location'] ?? targetJson['location'] ?? targetJson['Location'];
    final websiteVal = json['website'] ?? json['Website'] ?? json['websiteUrl'] ?? json['websiteURL'] ??
                    targetJson['website'] ?? targetJson['Website'] ?? targetJson['websiteUrl'] ?? targetJson['websiteURL'];
    final matchScoreVal = json['matchScore'] ?? json['MatchScore'] ?? targetJson['matchScore'] ?? targetJson['MatchScore'];
    final isFavoriteVal = json['isFavorite'] ?? json['IsFavorite'] ?? targetJson['isFavorite'] ?? targetJson['IsFavorite'];
    final typeVal = json['investorType'] ?? json['InvestorType'] ?? json['type'] ?? json['Type'] ??
                   targetJson['investorType'] ?? targetJson['InvestorType'] ?? json['type'] ?? targetJson['Type'];
    final emailVal = json['email'] ?? json['Email'] ?? json['contactEmail'] ?? json['ContactEmail'] ??
                    targetJson['email'] ?? targetJson['Email'] ?? targetJson['contactEmail'] ?? targetJson['ContactEmail'];
    final phoneVal = json['phone'] ?? json['Phone'] ?? json['contactPhone'] ?? json['ContactPhone'] ??
                    targetJson['phone'] ?? targetJson['Phone'] ?? targetJson['contactPhone'] ?? targetJson['ContactPhone'];
    final linkedinVal = json['linkedinUrl'] ?? json['LinkedinUrl'] ?? json['LinkedInURL'] ?? json['linkedin_url'] ?? json['linkedInURL'] ?? json['linkedInUrl'] ??
                       targetJson['linkedinUrl'] ?? targetJson['LinkedinUrl'] ?? targetJson['LinkedInURL'] ?? targetJson['linkedin_url'] ?? targetJson['linkedInURL'] ?? targetJson['linkedInUrl'];

    final ticketMinVal = json['ticketSizeMin'] ?? json['TicketSizeMin'] ?? 
                         json['min_ticket_size'] ?? json['minTicketSize'] ?? json['MinTicketSize'] ??
                         json['ticketMin'] ?? json['TicketMin'] ??
                         targetJson['ticketSizeMin'] ?? targetJson['TicketSizeMin'] ??
                         targetJson['min_ticket_size'] ?? targetJson['minTicketSize'] ?? targetJson['MinTicketSize'] ??
                         targetJson['ticketMin'] ?? targetJson['TicketMin'];
    final ticketMaxVal = json['ticketSizeMax'] ?? json['TicketSizeMax'] ?? 
                         json['max_ticket_size'] ?? json['maxTicketSize'] ?? json['MaxTicketSize'] ??
                         json['ticketMax'] ?? json['TicketMax'] ??
                         targetJson['ticketSizeMax'] ?? targetJson['TicketSizeMax'] ??
                         targetJson['max_ticket_size'] ?? targetJson['maxTicketSize'] ?? targetJson['MaxTicketSize'] ??
                         targetJson['ticketMax'] ?? targetJson['TicketMax'];
    final statsJson = json['stats'] ?? json['Stats'] ?? targetJson['stats'] ?? targetJson['Stats'];
    final Map<String, dynamic> stats = (statsJson is Map<String, dynamic>) ? statsJson : {};

    // Extract connection count with extreme resilience
    var connCountVal = json['acceptedConnectionCount'] ?? json['AcceptedConnectionCount'] ?? 
                         json['accepted_connection_count'] ?? json['accepted_connections'] ??
                         json['connections'] ?? json['Connections'] ?? json['connection_count'] ??
                         json['totalConnections'] ?? json['TotalConnections'] ?? json['total_connections'] ??
                         json['connectionCount'] ?? json['ConnectionCount'] ??
                         json['startupCount'] ?? json['StartupCount'] ?? json['startup_count'] ??
                         json['connectedStartups'] ?? json['ConnectedStartups'] ?? json['connected_startups'] ??
                         json['investments'] ?? json['Investments'] ?? json['total_investments'] ??
                         stats['acceptedConnectionCount'] ?? stats['AcceptedConnectionCount'] ??
                         stats['accepted_connection_count'] ?? stats['accepted_connections'] ??
                         stats['connections'] ?? stats['Connections'] ?? stats['connection_count'] ??
                         stats['totalConnections'] ?? stats['TotalConnections'] ?? stats['total_connections'] ??
                         stats['connectionCount'] ?? stats['ConnectionCount'] ??
                         stats['startupCount'] ?? stats['StartupCount'] ?? stats['startup_count'] ??
                         stats['connectedStartups'] ?? stats['ConnectedStartups'] ?? stats['connected_startups'] ??
                         stats['investments'] ?? stats['Investments'] ?? stats['total_investments'] ??
                         targetJson['acceptedConnectionCount'] ?? targetJson['AcceptedConnectionCount'] ??
                         targetJson['accepted_connection_count'] ?? targetJson['accepted_connections'] ??
                         targetJson['connections'] ?? targetJson['Connections'] ?? targetJson['connection_count'] ??
                         targetJson['totalConnections'] ?? targetJson['TotalConnections'] ?? targetJson['total_connections'] ??
                         targetJson['connectionCount'] ?? targetJson['ConnectionCount'] ??
                         targetJson['startupCount'] ?? targetJson['StartupCount'] ?? targetJson['startup_count'] ??
                         targetJson['connectedStartups'] ?? targetJson['ConnectedStartups'] ?? targetJson['connected_startups'] ??
                         targetJson['investments'] ?? targetJson['Investments'] ?? targetJson['total_investments'];

    // If it's a list, take the length
    if (connCountVal is List) {
      connCountVal = connCountVal.length;
    } else if (json['connections'] is List) {
      connCountVal = (json['connections'] as List).length;
    } else if (targetJson['connections'] is List) {
      connCountVal = (targetJson['connections'] as List).length;
    }

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
      email: emailVal?.toString(),
      phone: phoneVal?.toString(),
      linkedinUrl: linkedinVal?.toString(),
      matchScore: double.tryParse(matchScoreVal?.toString() ?? '0') ?? 0.0,
      isFavorite: isFavoriteVal == true,
      ticketSizeMin: double.tryParse(ticketMinVal?.toString() ?? ''),
      ticketSizeMax: double.tryParse(ticketMaxVal?.toString() ?? ''),
      acceptedConnectionCount: int.tryParse(connCountVal?.toString() ?? '0') ?? 0,
    );
  }

  // Legacy mappings for UI compatibility
  String get name => fullName;
  String? get organization => firmName;
  String? get position {
    if (investorType == null || investorType!.isEmpty) return 'nhà đầu tư';
    
    // Format: INDIVIDUAL_ANGEL -> Individual Angel
    return investorType!
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
  String get thesis => investmentThesis ?? 'Chưa có thông tin';
  List<String> get industries => preferredIndustries;
  List<String> get stages => preferredStages;

  InvestorModel copyWith({
    bool? isFavorite,
    bool? isVerified,
    int? acceptedConnectionCount,
    double? ticketSizeMin,
    double? ticketSizeMax,
    String? fullName,
    String? firmName,
    String? bio,
    String? avatarUrl,
    String? investmentThesis,
    List<String>? preferredStages,
    List<String>? preferredIndustries,
    String? location,
    String? website,
    String? investorType,
    String? email,
    String? phone,
    String? linkedinUrl,
  }) {
    return InvestorModel(
      id: id,
      fullName: fullName ?? this.fullName,
      firmName: firmName ?? this.firmName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      marketScope: marketScope,
      supportOffered: supportOffered,
      investmentThesis: investmentThesis ?? this.investmentThesis,
      preferredStages: preferredStages ?? this.preferredStages,
      preferredIndustries: preferredIndustries ?? this.preferredIndustries,
      location: location ?? this.location,
      website: website ?? this.website,
      investorType: investorType ?? this.investorType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      matchScore: matchScore,
      isFavorite: isFavorite ?? this.isFavorite,
      ticketSizeMin: ticketSizeMin ?? this.ticketSizeMin,
      ticketSizeMax: ticketSizeMax ?? this.ticketSizeMax,
      acceptedConnectionCount: acceptedConnectionCount ?? this.acceptedConnectionCount,
    );
  }
}
