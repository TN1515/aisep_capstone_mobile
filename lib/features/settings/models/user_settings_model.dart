class UserSettingsModel {
  final bool showToInvestors;
  final bool showToAdvisors;
  final bool pushNotifications;
  final bool emailNotifications;

  const UserSettingsModel({
    this.showToInvestors = true,
    this.showToAdvisors = false,
    this.pushNotifications = true,
    this.emailNotifications = true,
  });

  UserSettingsModel copyWith({
    bool? showToInvestors,
    bool? showToAdvisors,
    bool? pushNotifications,
    bool? emailNotifications,
  }) {
    return UserSettingsModel(
      showToInvestors: showToInvestors ?? this.showToInvestors,
      showToAdvisors: showToAdvisors ?? this.showToAdvisors,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}
