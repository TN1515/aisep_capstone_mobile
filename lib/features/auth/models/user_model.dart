class UserModel {
  final int userId;
  final String email;
  final String userType;
  final bool emailVerified;
  final List<String> roles;

  UserModel({
    required this.userId,
    required this.email,
    required this.userType,
    required this.emailVerified,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      userType: json['userType'] ?? 'Startup',
      emailVerified: json['emailVerified'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'userType': userType,
      'emailVerified': emailVerified,
      'roles': roles,
    };
  }
}
