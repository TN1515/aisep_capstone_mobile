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
      userId: json['userId'] ?? json['id'] ?? 0,
      email: json['email'] ?? '',
      userType: json['userType'] ?? json['role'] ?? 'Startup',
      emailVerified: json['emailVerified'] ?? json['isEmailVerified'] ?? false,
      roles: List<String>.from(json['roles'] ?? (json['role'] != null ? [json['role']] : [])),
    );
  }

  factory UserModel.fromSimpleData(String data) {
    return UserModel(
      userId: 0,
      email: '',
      userType: data, // Giả định chuỗi "data" này là role/userType
      emailVerified: true,
      roles: [data],
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
