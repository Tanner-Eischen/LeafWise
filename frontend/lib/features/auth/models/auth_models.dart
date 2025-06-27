import 'package:json_annotation/json_annotation.dart';
import 'package:plant_social/core/models/user.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String? fullName;
  final String? inviteCode;

  const RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.fullName,
    this.inviteCode,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      fullName: json['fullName'] as String?,
      inviteCode: json['inviteCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'fullName': fullName,
      'inviteCode': inviteCode,
    };
  }
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final String? tokenType;
  final int? expiresIn;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.tokenType,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokenType: json['tokenType'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

@JsonSerializable()
class VerifyEmailRequest {
  final String token;

  const VerifyEmailRequest({
    required this.token,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) {
    return VerifyEmailRequest(
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

@JsonSerializable()
class ResendVerificationRequest {
  final String email;

  const ResendVerificationRequest({
    required this.email,
  });

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) {
    return ResendVerificationRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Response models
@JsonSerializable()
class MessageResponse {
  final String message;
  final bool? success;

  const MessageResponse({
    required this.message,
    this.success,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      message: json['message'] as String,
      success: json['success'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}

@JsonSerializable()
class TokenValidationResponse {
  final bool isValid;
  final String? message;
  final DateTime? expiresAt;

  const TokenValidationResponse({
    required this.isValid,
    this.message,
    this.expiresAt,
  });

  factory TokenValidationResponse.fromJson(Map<String, dynamic> json) {
    return TokenValidationResponse(
      isValid: json['isValid'] as bool,
      message: json['message'] as String?,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'message': message,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

// Validation extensions
extension RegisterRequestValidation on RegisterRequest {
  bool get isValid {
    return email.isNotEmpty &&
           username.isNotEmpty &&
           password.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           password == confirmPassword &&
           isValidEmail &&
           isValidUsername &&
           isValidPassword;
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  bool get isValidUsername {
    // Username should be 3-30 characters, alphanumeric and underscores only
    return RegExp(r'^[a-zA-Z0-9_]{3,30}$').hasMatch(username);
  }
  
  bool get isValidPassword {
    // Password should be at least 8 characters with at least one letter and one number
    return password.length >= 8 &&
           RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }
  
  bool get passwordsMatch {
    return password == confirmPassword;
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!isValidEmail) {
      errors.add('Please enter a valid email address');
    }
    
    if (username.isEmpty) {
      errors.add('Username is required');
    } else if (!isValidUsername) {
      errors.add('Username must be 3-30 characters and contain only letters, numbers, and underscores');
    }
    
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (!isValidPassword) {
      errors.add('Password must be at least 8 characters with at least one letter and one number');
    }
    
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (!passwordsMatch) {
      errors.add('Passwords do not match');
    }
    
    return errors;
  }
}

extension LoginRequestValidation on LoginRequest {
  bool get isValid {
    return email.isNotEmpty && password.isNotEmpty && isValidEmail;
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!isValidEmail) {
      errors.add('Please enter a valid email address');
    }
    
    if (password.isEmpty) {
      errors.add('Password is required');
    }
    
    return errors;
  }
}

extension ChangePasswordRequestValidation on ChangePasswordRequest {
  bool get isValid {
    return currentPassword.isNotEmpty &&
           newPassword.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           newPassword == confirmPassword &&
           isValidNewPassword &&
           currentPassword != newPassword;
  }
  
  bool get isValidNewPassword {
    // Password should be at least 8 characters with at least one letter and one number
    return newPassword.length >= 8 &&
           RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(newPassword);
  }
  
  bool get passwordsMatch {
    return newPassword == confirmPassword;
  }
  
  bool get isDifferentFromCurrent {
    return currentPassword != newPassword;
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (currentPassword.isEmpty) {
      errors.add('Current password is required');
    }
    
    if (newPassword.isEmpty) {
      errors.add('New password is required');
    } else if (!isValidNewPassword) {
      errors.add('New password must be at least 8 characters with at least one letter and one number');
    } else if (!isDifferentFromCurrent) {
      errors.add('New password must be different from current password');
    }
    
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your new password');
    } else if (!passwordsMatch) {
      errors.add('Passwords do not match');
    }
    
    return errors;
  }
}

extension ResetPasswordRequestValidation on ResetPasswordRequest {
  bool get isValid {
    return token.isNotEmpty &&
           newPassword.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           newPassword == confirmPassword &&
           isValidNewPassword;
  }
  
  bool get isValidNewPassword {
    // Password should be at least 8 characters with at least one letter and one number
    return newPassword.length >= 8 &&
           RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(newPassword);
  }
  
  bool get passwordsMatch {
    return newPassword == confirmPassword;
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (token.isEmpty) {
      errors.add('Reset token is required');
    }
    
    if (newPassword.isEmpty) {
      errors.add('New password is required');
    } else if (!isValidNewPassword) {
      errors.add('Password must be at least 8 characters with at least one letter and one number');
    }
    
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (!passwordsMatch) {
      errors.add('Passwords do not match');
    }
    
    return errors;
  }
}