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
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['data'] ?? {}),
    );
  }
}
