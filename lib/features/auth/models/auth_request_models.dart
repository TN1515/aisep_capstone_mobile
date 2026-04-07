class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String userType; // Luôn là 'Startup' qua logic Service

  RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.userType = 'Startup',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'userType': userType,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class VerifyEmailRequest {
  final String email;
  final String otp;

  VerifyEmailRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}
