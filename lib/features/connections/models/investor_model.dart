class InvestorModel {
  final String id;
  final String name;
  final String? organization;
  final String position;
  final String? avatarUrl;
  final bool isVerified;
  final String thesis;
  final List<String> preferredIndustries;
  final List<String> preferredStages;
  final List<String> preferredGeographies;
  final String marketScope;
  final String supportOffered;
  final bool isFavorite;
  final double matchScore;

  InvestorModel({
    required this.id,
    required this.name,
    this.organization,
    required this.position,
    this.avatarUrl,
    this.isVerified = false,
    required this.thesis,
    required this.preferredIndustries,
    required this.preferredStages,
    required this.preferredGeographies,
    required this.marketScope,
    required this.supportOffered,
    this.isFavorite = false,
    this.matchScore = 0.0,
  });

  // Helper for toggling favorite state
  InvestorModel copyWith({bool? isFavorite}) {
    return InvestorModel(
      id: id,
      name: name,
      organization: organization,
      position: position,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      thesis: thesis,
      preferredIndustries: preferredIndustries,
      preferredStages: preferredStages,
      preferredGeographies: preferredGeographies,
      marketScope: marketScope,
      supportOffered: supportOffered,
      isFavorite: isFavorite ?? this.isFavorite,
      matchScore: matchScore,
    );
  }
}
