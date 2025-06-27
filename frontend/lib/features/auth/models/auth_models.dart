import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plant_social/core/models/user.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    String? fullName,
    String? inviteCode,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required User user,
    String? tokenType,
    int? expiresIn,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
}

@freezed
class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({
    required String email,
  }) = _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestFromJson(json);
}

@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
}

@freezed
class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
}

@freezed
class VerifyEmailRequest with _$VerifyEmailRequest {
  const factory VerifyEmailRequest({
    required String token,
  }) = _VerifyEmailRequest;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
}

@freezed
class ResendVerificationRequest with _$ResendVerificationRequest {
  const factory ResendVerificationRequest({
    required String email,
  }) = _ResendVerificationRequest;

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) => _$ResendVerificationRequestFromJson(json);
}

// Response models
@freezed
class MessageResponse with _$MessageResponse {
  const factory MessageResponse({
    required String message,
    bool? success,
  }) = _MessageResponse;

  factory MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);
}

@freezed
class TokenValidationResponse with _$TokenValidationResponse {
  const factory TokenValidationResponse({
    required bool isValid,
    String? message,
    DateTime? expiresAt,
  }) = _TokenValidationResponse;

  factory TokenValidationResponse.fromJson(Map<String, dynamic> json) => _$TokenValidationResponseFromJson(json);
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