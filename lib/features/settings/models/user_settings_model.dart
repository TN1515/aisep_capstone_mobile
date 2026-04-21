class UserSettingsModel {
  final bool isVisible;
  final bool isDarkMode;

  const UserSettingsModel({
    this.isVisible = false,
    this.isDarkMode = false,
  });

  UserSettingsModel copyWith({
    bool? isVisible,
    bool? isDarkMode,
  }) {
    return UserSettingsModel(
      isVisible: isVisible ?? this.isVisible,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
