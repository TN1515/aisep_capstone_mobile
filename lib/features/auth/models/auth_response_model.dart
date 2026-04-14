import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: null, // Schema provided doesn't show refreshToken in Login/Verify
      user: UserModel.fromSimpleData(json['data']?.toString() ?? 'Startup'),
    );
  }
}
